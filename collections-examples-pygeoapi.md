# Weather Stream OGC API: Collections Examples

This document shows example requests for:

- adding a feature to the `sensors` collection
- retrieving data from a feature location

## 1. Add a feature

Use `POST /collections/sensors/items` with `Content-Type: application/geo+json`.

### Example request

```bash
curl -X POST "http://localhost:5000/collections/sensors/items" \
  -H "Content-Type: application/geo+json" \
  -H "Accept: application/json" \
  -d '{
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [-75.123, 45.421]
    },
    "properties": {
      "sensor_id": "sensor-1001",
      "sensor_name": "Downtown Station",
      "available_variables": "temperature,humidity",
      "valid_start_datetime": "2026-05-01T00:00:00Z",
      "valid_end_datetime": "2026-05-31T23:59:59Z"
    }
  }'
```

### Expected result

- Status: `201 Created`
- Location header: URL of the created item, e.g. `http://localhost:5000/collections/sensors/items/1`
- The feature is added to the `sensors` collection.

### Verify the feature was added

The feature `id` as the item identifier, retrieve it directly:

```bash
curl "http://localhost:5000/collections/sensors/items/1?f=json"
```

You can also search the collection by a property value:

```bash
curl "http://localhost:5000/collections/sensors/items?f=json&sensor_id=sensor-1001"
```

## 2. Retrieve data from the location of a feature

There are two related location-based endpoints in this API:

- `GET /collections/sensors/locations` lists available predefined locations
- `GET /collections/sensors/locations/{locId}` retrieves coverage data for one location

### Step 1: list available locations

```bash
curl "http://localhost:5000/collections/sensors/locations?f=json"
```

### Example result

The response should return one or more locations. Pick a location identifier from the result, for example `1`.

### Step 2: retrieve coverage data for one location

```bash
curl "http://localhost:5000/collections/sensors/locations/1?f=json"
```

### Retrieve a specific variable at that location

Request a single variable:

```bash
curl "http://localhost:5000/collections/sensors/locations/1?parameter-name=2m_temperature&f=json"
```

### Retrieve data for a time range or instant

```bash
curl "http://localhost:5000/collections/sensors/locations/1?datetime=2026-05-12T12:00:00Z&f=json"
```

Or an interval:

```bash
curl "http://localhost:5000/collections/sensors/locations/1?datetime=2026-05-12T00:00:00Z/2026-05-13T23:59:59Z&parameter-name=2m_temperature&f=json"
```

### Expected result

- Status: `200 OK`
- Content type: `application/prs.coverage+json`
- Body: CoverageJSON payload for the requested location

