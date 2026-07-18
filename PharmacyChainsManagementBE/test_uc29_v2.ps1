function Invoke-MyRest {
    param (
        [string]$Uri,
        [string]$Method,
        [Hashtable]$Headers,
        [string]$Body
    )
    
    try {
        if ($Method -eq "GET") {
            $resp = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $Headers -UseBasicParsing -ErrorAction Stop
        } else {
            $resp = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $Headers -Body $Body -ContentType "application/json" -UseBasicParsing -ErrorAction Stop
        }
        $content = $resp.Content | ConvertFrom-Json
        return @{ StatusCode = [int]$resp.StatusCode; Data = $content }
    } catch {
        $ex = $_.Exception
        if ($ex.Response) {
            $stream = $ex.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
            try { $content = $content | ConvertFrom-Json } catch {}
            return @{ StatusCode = [int]$ex.Response.StatusCode; Data = $content }
        }
        return @{ StatusCode = 500; Data = $ex.Message }
    }
}

$loginBody = @{ email = "founder@pharmacy.com"; password = "Founder@123" } | ConvertTo-Json
$loginResult = Invoke-MyRest -Uri "http://localhost:7000/api/v1/auth/login" -Method "POST" -Headers @{} -Body $loginBody
$token = $loginResult.Data.token

$headers = @{ "Authorization" = "Bearer $token" }

Write-Host "=== STEP 1: GET ADMIN LIST ==="
$listResult = Invoke-MyRest -Uri "http://localhost:7000/api/v1/business-admin" -Method "GET" -Headers $headers -Body ""
$listResult | ConvertTo-Json -Depth 5

$adminId = $listResult.Data.data[0].userId

Write-Host "Admin ID: $adminId"

Write-Host "=== STEP 2: EMPTY REASON (EXPECT 400) ==="
$body2 = @{ reason = "" } | ConvertTo-Json
$res2 = Invoke-MyRest -Uri "http://localhost:7000/api/v1/business-admin/$adminId/deactivate" -Method "POST" -Headers $headers -Body $body2
$res2 | ConvertTo-Json -Depth 5

Write-Host "=== STEP 3: VALID REASON (EXPECT 200) ==="
$body3 = @{ reason = "Vi pham noi quy" } | ConvertTo-Json
$headersIdemp = @{ "Authorization" = "Bearer $token"; "Idempotency-Key" = "test-key-123" }
$res3 = Invoke-MyRest -Uri "http://localhost:7000/api/v1/business-admin/$adminId/deactivate" -Method "POST" -Headers $headersIdemp -Body $body3
$res3 | ConvertTo-Json -Depth 5

Write-Host "=== STEP 4: RETRY (EXPECT 200 OR 409) ==="
$body4 = @{ reason = "Test Retry" } | ConvertTo-Json
$res4 = Invoke-MyRest -Uri "http://localhost:7000/api/v1/business-admin/$adminId/deactivate" -Method "POST" -Headers $headersIdemp -Body $body4
$res4 | ConvertTo-Json -Depth 5

Write-Host "=== STEP 5: DEACTIVATE AGAIN (EXPECT 400) ==="
$body5 = @{ reason = "Khoa lai" } | ConvertTo-Json
$res5 = Invoke-MyRest -Uri "http://localhost:7000/api/v1/business-admin/$adminId/deactivate" -Method "POST" -Headers $headers -Body $body5
$res5 | ConvertTo-Json -Depth 5

Write-Host "=== STEP 6: VERIFY STATUS ==="
$res6 = Invoke-MyRest -Uri "http://localhost:7000/api/v1/business-admin/$adminId/status" -Method "GET" -Headers $headers -Body ""
$res6 | ConvertTo-Json -Depth 5
