# CreateDimensions

A Business Central AL package for automatically creating dimensions and dimension values via a web service API.

## Features

- Creates dimensions if they don't exist
- Creates dimension values from a provided list
- Skips existing dimension values
- RESTful JSON API for easy integration
- Cloud-ready for Business Central Online

## Web Service API

### Endpoint
The package exposes a web service via the `CD Handler` codeunit (Codeunit 50151) with the `CreateDimensions` procedure.

The service accepts a JSON object wrapped in a `requestBody` parameter.

### Request Format

**JSON Input:**
```json
{
  "name": "ACTPERIOD",
  "values": [
    {
      "code": "202501",
      "name": "2025-01"
    },
    {
      "code": "202502",
      "name": "2025-02"
    },
    {
      "code": "202503",
      "name": "2025-03"
    }
  ]
}
```

**Parameters:**
- `name` (required): Dimension code/name (e.g., 'ACTPERIOD', 'CONTRACT')
- `values` (required): Array of dimension value objects with:
  - `code` (required): Dimension value code (max 20 characters)
  - `name` (optional): Dimension value name (max 50 characters). If omitted, the code will be used as the name

### Response Format

**Success Response:**
```json
{
  "success": true,
  "dimension": "ACTPERIOD",
  "processed": 3,
  "results": [
    {
      "code": "202501",
      "status": "created"
    },
    {
      "code": "202502",
      "status": "skipped"
    },
    {
      "code": "202503",
      "status": "created"
    }
  ]
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Missing or invalid \"name\" field."
}
```

**Response Fields:**
- `success`: Boolean indicating if the operation was successful
- `dimension`: The dimension code that was processed
- `processed`: Total number of values processed
- `results`: Array of result objects with:
  - `code`: The dimension value code
  - `status`: Either "created" (newly added) or "skipped" (already existed)
- `error`: Error message (only present on failure)

## How to Use

1. **Enable the Web Service:**
   - In Business Central, go to Web Services administration
   - Add a new web service pointing to Codeunit 50151 "CD Handler"
   - Set the Service name to "CreateDimensions"
   - Publish the service

2. **Call the API:**
   - POST request to the web service endpoint
   - Wrap the JSON payload in a `requestBody` parameter
   - The service will create the dimension and its values, returning a detailed response

3. **Example cURL Request:**
   ```bash
   curl -X POST https://[your-bc-instance]/api/microsoft/automation/v2.0/companies/[company-id]/codeunits/createDimensions_CreateDimensions?company=[company-name] \
     -H "Content-Type: application/json" \
     -d '{"requestBody":"{\"name\":\"ACTPERIOD\",\"values\":[{\"code\":\"202501\",\"name\":\"2025-01\"},{\"code\":\"202502\",\"name\":\"2025-02\"},{\"code\":\"202503\",\"name\":\"2025-03\"}]}"}'
   ```

4. **PHP Integration (Using GuzzleHttp):**
   ```php
   $payload = [
       'name' => 'ACTPERIOD',
       'values' => [
           ['code' => '202501', 'name' => '2025-01'],
           ['code' => '202502', 'name' => '2025-02'],
           ['code' => '202503', 'name' => '2025-03'],
       ]
   ];
   
   $data = [
       'requestBody' => json_encode($payload)
   ];
   
   $response = self::OData($auth, 'POST', $environment, 'CreateDimensions_CreateDimensions?company=' . urlencode($company), $data);
   ```

## Architecture

### Codeunits

- **CD Dimension Helpers (50150):** Core business logic for dimension and dimension value creation
- **CD Handler (50151):** Web service entry point that accepts JSON requests and processes dimension creation

## Publisher

Northern Partners ApS
