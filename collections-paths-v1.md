# Weather Stream OGC API: Collections Paths

This document includes only the `/collections/*` endpoints from the provided OpenAPI document.

## `/collections`

### `GET` Collections

Lists available collections.

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `f` | string | No | Output format. Default: `json`. Allowed: `json`, `html`, `jsonld` |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Success |
| `400` | Invalid parameter |
| `500` | Server error |

## `/collections/sensors`

### `GET` Get Sensors metadata

Returns metadata for the `sensors` collection.

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `f` | string | No | Output format. Default: `json`. Allowed: `json`, `html`, `jsonld` |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Collection metadata |
| `400` | Invalid parameter |
| `404` | Not found |
| `500` | Server error |

## `/collections/sensors/items`

### `GET` Get Sensors items

Returns items from the `sensors` collection.

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `f` | string | No | Default: `json`. Allowed: `json`, `csv` |
| `bbox` | number[] | No | 4 or 6 numbers |
| `properties` | string[] | No | Allowed: `sensor_id`, `sensor_name`, `available_variables`, `valid_start_datetime`, `valid_end_datetime` |
| `datetime` | external ref | No | Datetime filter |
| `sensor_id` | string | No | Filter by sensor id |
| `sensor_name` | string | No | Filter by sensor name |
| `available_variables` | string | No | Filter by available variables |
| `valid_start_datetime` | string(date-time) | No | Filter by valid start datetime |
| `valid_end_datetime` | string(date-time) | No | Filter by valid end datetime |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Features returned |
| `400` | Invalid parameter |
| `404` | Not found |
| `500` | Server error |


### `POST` Add item

Creates a new item

**Request body**

| Content-Type | Meaning |
|---|---|
| `application/geo+json` | Add item to collection |

To add an item to the collection, properties should contain: 
| Name | Type |
|---|---|
| Sensor_id | str |
| Sensor_name | str |
| available_variables  | str (comma-separated list) |
| valid_start_datetime | str (date-time) |
| valid_end_datetime | str (date-time) or None |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Features returned |
| `201` | Successful creation |
| `400` | Invalid parameter |
| `500` | Server error |

## `/collections/sensors/items/{featureId}`

### `GET` Get Sensors item by id

Returns a single sensor item.

**Path parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `featureId` | string | Yes | Feature identifier |

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `f` | string | No | Output format |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Feature returned |
| `400` | Invalid parameter |
| `404` | Not found |
| `500` | Server error |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Options response |


## `/collections/sensors/locations`

### `GET` Get pre-defined locations of Sensor locations

Returns predefined locations for the `sensors` collection.

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `bbox` | external ref | No | bbox parameter |
| `datetime` | external ref | No | Datetime filter |
| `f` | string | No | Output format |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Features returned |
| `400` | Invalid parameter |
| `500` | Server error |

## `/collections/sensors/locations/{locId}`

### `GET` Retrieve coverage data by location

Returns coverage data for a specific location.

**Path parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `locId` | string | Yes | Location identifier |

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `datetime` | external ref | No | Datetime filter. It can be range, this is the time of the forecast and will be decomposed to time (Forecast_reference_time) and step (forecast_period). The forecast with the lowest step value is returned for every datetime requested. A datetime between modeled times will be interpolated from the nearest available forecast. Intervals may be bounded or half-bounded (double-dots at start or end). A date-time: "2018-02-12T23:20:50Z" A bounded interval: "2018-02-12T00:00:00Z/2018-03-18T12:31:12Z" Half-bounded intervals: "2018-02-12T00:00:00Z/.." or "../2018-03-18T12:31:12Z"  |
| `parameter-name` | external ref | No | EDR parameter selector. Available names are those in the icechunk repo |
| `method` | external ref | No | interpolation method at the sensor location and requested time. Defaults to linear and will eventually support a method for bias corrected forecast. |
| `crs` | string | No | CRS for results |
| `f` | string | No | Output format |


**Responses**

| Status | Meaning |
|---|---|
| `200` | CoverageJSON response (`application/prs.coverage+json`) |

