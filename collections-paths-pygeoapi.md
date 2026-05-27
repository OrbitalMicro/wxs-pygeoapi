# Weather Stream OGC API: Collections Paths

This document includes only the `/collections/*` endpoints from the provided OpenAPI document.

## `/collections`

### `GET` Collections

Lists available collections.

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `f` | string | No | Output format. Default: `json`. Allowed: `json`, `html`, `jsonld` |
| `lang` | string | No | Response language. Default: `en-US` |

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
| `lang` | string | No | Response language. Default: `en-US` |

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
| `f` | string | No | Default: `json`. Allowed: `json`, `html`, `jsonld`, `csv` |
| `lang` | string | No | Response language |
| `bbox` | number[] | No | 4 or 6 numbers |
| `limit` | integer | No | Default: `10`, min: `1`, max: `50` |
| `crs` | string | No | CRS for results |
| `bbox-crs` | string | No | CRS for bbox |
| `properties` | string[] | No | Allowed: `sensor_id`, `sensor_name`, `available_variables`, `valid_start_datetime`, `valid_end_datetime` |
| `vendorSpecificParameters` | object | No | Free-form extra parameters |
| `skipGeometry` | boolean | No | Default: `false` |
| `sortby` | external ref | No | OGC Records sort parameter |
| `offset` | integer | No | Default: `0` |
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

### `OPTIONS` Options for Sensors items

Returns supported options for the collection items endpoint.

**Responses**

| Status | Meaning |
|---|---|
| `200` | Options response |

### `POST` Get Sensors items with CQL2 or add item

Either queries items using CQL2 or creates a new item, depending on content type.

**Request body**

| Content-Type | Meaning |
|---|---|
| `application/json` | CQL2 query |
| `application/geo+json` | Add item to collection |

To add an item to the collection, properties should at a minimum contain: 
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
| `crs` | string | No | CRS for results |
| `f` | string | No | Output format |
| `lang` | string | No | Response language |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Feature returned |
| `400` | Invalid parameter |
| `404` | Not found |
| `500` | Server error |

### `OPTIONS` Options for Sensors item by id

Returns supported options for the single-item endpoint.

**Path parameters**

| Name | Type | Required |
|---|---|---:|
| `featureId` | string | Yes |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Options response |

### `PUT` Update Sensors items

Creates or updates an existing sensor item.

**Path parameters**

| Name | Type | Required |
|---|---|---:|
| `featureId` | string | Yes |

**Request body**

| Content-Type | Meaning |
|---|---|
| `application/geo+json` | Updated feature payload |

**Responses**

| Status | Meaning |
|---|---|
| `204` | No content, update successful |
| `400` | Invalid parameter |
| `500` | Server error |

### `DELETE` Delete Sensors items

Deletes a sensor item.

**Path parameters**

| Name | Type | Required |
|---|---|---:|
| `featureId` | string | Yes |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Successful delete |
| `400` | Invalid parameter |
| `500` | Server error |

## `/collections/sensors/locations`

### `GET` Get pre-defined locations of Sensor locations

Returns predefined locations for the `sensors` collection.

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `bbox` | external ref | No | EDR bbox parameter |
| `datetime` | external ref | No | Datetime filter |
| `f` | string | No | Output format |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Features returned |
| `400` | Invalid parameter |
| `500` | Server error |

## `/collections/sensors/locations/{locId}`

### `GET` Query Sensor locations by location

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

## `/collections/sensors/queryables`

### `GET` Get Sensors queryables

Returns queryable properties for the `sensors` collection.

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `properties` | string[] | No | Allowed: `sensor_id`, `sensor_name`, `available_variables`, `valid_start_datetime`, `valid_end_datetime` |
| `f` | string | No | Output format |
| `profile` | string | No | Allowed: `actual-domain`, `valid-domain` |
| `lang` | string | No | Response language |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Queryables returned |
| `400` | Invalid parameter |
| `404` | Not found |
| `500` | Server error |

## `/collections/sensors/schema`

### `GET` Get Sensors schema

Returns schema information for the `sensors` collection.

**Query parameters**

| Name | Type | Required | Notes |
|---|---|---:|---|
| `f` | string | No | Output format |
| `lang` | string | No | Response language |

**Responses**

| Status | Meaning |
|---|---|
| `200` | Schema returned |
| `400` | Invalid parameter |
| `404` | Not found |
| `500` | Server error |