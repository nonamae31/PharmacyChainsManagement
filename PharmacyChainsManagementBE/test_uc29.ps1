$tokenResp = curl.exe -s -X POST http://localhost:7000/api/v1/auth/login -H "Content-Type: application/json" -d '{\"email\":\"founder@pharmacy.com\",\"password\":\"Founder@123\"}'
$token = ($tokenResp | ConvertFrom-Json).token

echo "--- STEP 1: GET list ---"
$admins = curl.exe -s -X GET http://localhost:7000/api/v1/business-admin -H "Authorization: Bearer $token"
echo $admins
$adminId = ($admins | ConvertFrom-Json).data.items | Where-Object { $_.status -eq 'ACTIVE' } | Select-Object -First 1 -ExpandProperty id
if (-not $adminId) {
    $adminId = ($admins | ConvertFrom-Json).data.items[0].id
}
echo "Selected Admin ID: $adminId"

echo "--- STEP 2: Empty reason ---"
curl.exe -s -w "\nHTTP_CODE: %{http_code}\n" -X POST http://localhost:7000/api/v1/business-admin/$adminId/deactivate -H "Authorization: Bearer $token" -H "Content-Type: application/json" -d '{\"reason\":\"\"}'

echo "--- STEP 3: Valid reason ---"
curl.exe -s -w "\nHTTP_CODE: %{http_code}\n" -X POST http://localhost:7000/api/v1/business-admin/$adminId/deactivate -H "Authorization: Bearer $token" -H "Content-Type: application/json" -H "Idempotency-Key: step3-key-123" -d '{\"reason\":\"Vi pham noi quy\"}'

echo "--- STEP 4: Retry with same idempotency key ---"
curl.exe -s -w "\nHTTP_CODE: %{http_code}\n" -X POST http://localhost:7000/api/v1/business-admin/$adminId/deactivate -H "Authorization: Bearer $token" -H "Content-Type: application/json" -H "Idempotency-Key: step3-key-123" -d '{\"reason\":\"Test Retry\"}'

echo "--- STEP 5: Deactivate already deactivated ---"
curl.exe -s -w "\nHTTP_CODE: %{http_code}\n" -X POST http://localhost:7000/api/v1/business-admin/$adminId/deactivate -H "Authorization: Bearer $token" -H "Content-Type: application/json" -H "Idempotency-Key: step5-key" -d '{\"reason\":\"Khoa lai\"}'

echo "--- STEP 6: Verify status ---"
curl.exe -s -w "\nHTTP_CODE: %{http_code}\n" -X GET http://localhost:7000/api/v1/business-admin/$adminId/status -H "Authorization: Bearer $token"
