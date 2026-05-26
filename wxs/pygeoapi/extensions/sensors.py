from http import HTTPStatus

from shapely.geometry import Point, shape
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from pygeoapi.plugin import load_plugin
from pygeoapi.provider.base import (
    ProviderGenericError,
    ProviderInvalidDataError,
    ProviderQueryError,
)
from pygeoapi.provider.xarray_edr import XarrayEDRProvider
from pygeoapi.provider.sql import PostgreSQLProvider


class ProviderConflictError(ProviderGenericError):
    """provider conflict error"""

    ogc_exception_code = 'Conflict'
    http_status_code = HTTPStatus.CONFLICT
    default_msg = 'conflict'


class SensorsPostgreSQLProvider(PostgreSQLProvider):
    """PostgreSQL provider for the sensors collection."""

    def create(self, item):
        """
        Create a new sensor item.

        Accepts the sensor identifier from the feature id or from
        properties.sensor_id so clients can submit the business identifier
        they already know.
        """

        identifier, json_data = self._load_and_prepare_item(
            item, accept_missing_identifier=True, raise_if_exists=False
        )

        if identifier is None:
            identifier = json_data['properties'].get(self.id_field)

        if identifier is None:
            raise ProviderInvalidDataError(f'Missing {self.id_field}')

        new_instance = self._feature_to_sqlalchemy(json_data, identifier)
        with Session(self._engine) as session:
            try:
                session.add(new_instance)
                session.commit()
                result_id = getattr(new_instance, self.id_field)
            except IntegrityError as err:
                session.rollback()
                raise ProviderConflictError(
                    f'{self.id_field} already exists',
                    user_msg=f'{self.id_field} already exists'
                ) from err

        return result_id


class SensorsLocationsEDRProvider(XarrayEDRProvider):
    """EDR provider that maps feature locations to xarray coverage queries."""

    def __init__(self, provider_def):
        super().__init__(provider_def)

        feature_provider_def = provider_def.get('feature_provider')
        if feature_provider_def is None:
            raise ProviderQueryError('feature_provider config is required')

        self._feature_provider = load_plugin('provider', feature_provider_def)

    def locations(self, select_properties=None, bbox=None, datetime_=None,
                  location_id=None, limit=10, z=None, format_=None,
                  instance=None, **kwargs):
        """
        List feature locations or query coverage at a specific location.

        :returns: FeatureCollection (no location_id) or CoverageJSON
        """

        if location_id is None:
            return self._feature_provider.query(
                bbox=bbox or [],
                datetime_=datetime_,
                limit=limit,
                resulttype='results'
            )

        feature = self._feature_provider.get(location_id)
        if feature is None or feature.get('geometry') is None:
            raise ProviderQueryError(f'location not found: {location_id}')

        geom = shape(feature['geometry'])
        if geom.geom_type == 'Point':
            point = Point(geom.x, geom.y)
        else:
            point = geom.centroid

        selected_properties = select_properties or list(self.fields.keys())
        numeric_properties = [
            name for name in selected_properties
            if self.fields.get(name, {}).get('type') in ('float', 'integer')
        ]

        if not numeric_properties:
            raise ProviderQueryError('No numeric parameters found for coverage')

        return self.position(
            wkt=point,
            datetime_=datetime_,
            select_properties=numeric_properties,
            z=z,
            format_=format_,
            instance=instance
        )
