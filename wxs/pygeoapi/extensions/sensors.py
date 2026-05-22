from http import HTTPStatus

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from pygeoapi.provider.base import (
    ProviderGenericError,
    ProviderInvalidDataError,
)
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
