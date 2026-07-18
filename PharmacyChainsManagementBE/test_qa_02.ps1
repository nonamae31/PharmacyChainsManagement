$ErrorActionPreference = "Stop"

Write-Host "=== TEST: Login Founder ==="
$loginBody = @{
    email = "founder@pharmacy.com"
    password = "Founder@123"
} | ConvertTo-Json

$loginResp = Invoke-RestMethod -Uri "http://localhost:7000/api/v1/auth/login" -Method Post -Headers @{ "Content-Type" = "application/json" } -Body $loginBody
$token = $loginResp.token
Write-Host "Token Acquired: $token"

$headers = @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" }

Write-Host "=== TEST: Create Business Admin ==="
$createBody = @{
    fullName = "Test QA User"
    email = "qa.testuser.03@pharmacy.com"
    phone = "0987654321"
} | ConvertTo-Json

try {
    $createResp = Invoke-RestMethod -Uri "http://localhost:7000/api/v1/business-admin" -Method Post -Headers $headers -Body $createBody
    Write-Host "Status: Success"
    $accountId = $createResp.data.userId
    Write-Host "Created Account ID: $accountId"
} catch {
    Write-Host "Error creating user: $_"
    exit 1
}

Write-Host "`n=== TEST: Soft Delete ==="
try {
    $deleteResp = Invoke-RestMethod -Uri "http://localhost:7000/api/v1/business-admin/$accountId" -Method Delete -Headers $headers
    Write-Host "Status: Success"
} catch {
    Write-Host "Error deleting user: $_"
}

Write-Host "`n=== TEST: Verify List (After Delete) ==="
try {
    $listResp1 = Invoke-RestMethod -Uri "http://localhost:7000/api/v1/business-admin" -Method Get -Headers $headers
    Write-Host "Status: Success"
    $userInList1 = $listResp1.data | Where-Object { $_.userId -eq $accountId }
    if ($null -eq $userInList1) { 
        Write-Host "SUCCESS: User correctly removed from list" 
    } else { 
        Write-Host "ERROR: User still in list. Status is $($userInList1.status)" 
    }
} catch {
    Write-Host "Error getting list: $_"
}

Write-Host "`n=== TEST: Reactivate ==="
try {
    $reactivateResp = Invoke-RestMethod -Uri "http://localhost:7000/api/v1/business-admin/$accountId/reactivate" -Method Patch -Headers $headers
    Write-Host "Status: Success"
} catch {
    Write-Host "Error reactivating user: $_"
}

Write-Host "`n=== TEST: Verify List (After Reactivate) ==="
try {
    $listResp2 = Invoke-RestMethod -Uri "http://localhost:7000/api/v1/business-admin" -Method Get -Headers $headers
    Write-Host "Status: Success"
    $userInList2 = $listResp2.data | Where-Object { $_.userId -eq $accountId }
    if ($null -ne $userInList2) { 
        Write-Host "SUCCESS: User correctly appeared in list. Status is $($userInList2.status)" 
    } else { 
        Write-Host "ERROR: User not in list" 
    }
} catch {
    Write-Host "Error getting list: $_"
}

Write-Host "`n=== DONE ==="
