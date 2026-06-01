$ErrorActionPreference = "Stop"

$ProjectName = "fangling-chinghao-profile"
$Token = Read-Host "Paste your Vercel Token"

if ([string]::IsNullOrWhiteSpace($Token)) {
  throw "Vercel Token is required."
}

$Files = @(
  "index.html",
  "fangling.html",
  "package.json",
  "vercel.json",
  "README.md"
)

$PayloadFiles = foreach ($File in $Files) {
  @{
    file = $File
    data = Get-Content -LiteralPath $File -Raw -Encoding UTF8
  }
}

$Payload = @{
  name = $ProjectName
  target = "production"
  files = $PayloadFiles
  projectSettings = @{
    framework = $null
  }
} | ConvertTo-Json -Depth 10

$Headers = @{
  Authorization = "Bearer $Token"
  "Content-Type" = "application/json"
}

Write-Host "Deploying $ProjectName to Vercel..."
$Result = Invoke-RestMethod `
  -Uri "https://api.vercel.com/v13/deployments" `
  -Method Post `
  -Headers $Headers `
  -Body $Payload

$Url = "https://$($Result.url)"
$Url | Set-Content -LiteralPath "vercel-url.txt" -Encoding UTF8

Write-Host ""
Write-Host "Deployment created:"
Write-Host $Url
Write-Host ""
Write-Host "Saved to vercel-url.txt"
