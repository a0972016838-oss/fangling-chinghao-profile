$ErrorActionPreference = "Stop"

$ProjectName = "fangling-chinghao-profile"

function Command-Exists($Name) {
  return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Refresh-Path {
  $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
  $user = [Environment]::GetEnvironmentVariable("Path", "User")
  $env:Path = "$machine;$user"
}

function Install-With-Winget($Id, $Name) {
  if (-not (Command-Exists winget)) {
    throw "winget is not available on this computer. Please install $Name manually, then run this script again."
  }

  Write-Host "Installing $Name..."
  winget install --id $Id --exact --accept-package-agreements --accept-source-agreements
}

Write-Host ""
Write-Host "Preparing deployment tools..."

if (-not (Command-Exists git)) {
  Install-With-Winget "Git.Git" "Git"
  Refresh-Path
} else {
  Write-Host "Git is already installed."
}

if (-not (Command-Exists gh)) {
  Install-With-Winget "GitHub.cli" "GitHub CLI"
  Refresh-Path
} else {
  Write-Host "GitHub CLI is already installed."
}

if (-not (Command-Exists node)) {
  Install-With-Winget "OpenJS.NodeJS.LTS" "Node.js LTS"
  Refresh-Path
} else {
  Write-Host "Node.js is already installed."
}

if (-not (Command-Exists npm)) {
  Refresh-Path
}

if (-not (Command-Exists npm)) {
  throw "npm is still not available. Please close and reopen PowerShell, then run this script again."
}

if (-not (Command-Exists vercel)) {
  Write-Host "Installing Vercel CLI..."
  npm install -g vercel
  Refresh-Path
} else {
  Write-Host "Vercel CLI is already installed."
}

$Token = Read-Host "Paste your Vercel Token"
if ([string]::IsNullOrWhiteSpace($Token)) {
  throw "Vercel Token is required."
}

Write-Host ""
Write-Host "Linking Vercel project: $ProjectName"
vercel link --yes --project $ProjectName --token $Token

Write-Host ""
Write-Host "Deploying production site..."
$DeploymentUrl = vercel deploy --prod --yes --token $Token
$DeploymentUrl = ($DeploymentUrl | Select-Object -Last 1).Trim()

$DeploymentUrl | Set-Content -LiteralPath "vercel-url.txt" -Encoding UTF8

Write-Host ""
Write-Host "Deployment complete:"
Write-Host $DeploymentUrl
Write-Host ""
Write-Host "Saved to vercel-url.txt"
