$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/a0972016838-oss/fangling-chinghao-profile.git"

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
    throw "winget is not available. Please install $Name manually, then run this script again."
  }

  Write-Host "Installing $Name..."
  winget install --id $Id --exact --accept-package-agreements --accept-source-agreements
}

if (-not (Command-Exists git)) {
  Install-With-Winget "Git.Git" "Git"
  Refresh-Path
}

if (-not (Command-Exists gh)) {
  Install-With-Winget "GitHub.cli" "GitHub CLI"
  Refresh-Path
}

if (-not (Command-Exists git)) {
  throw "Git is still not available. Please close and reopen PowerShell, then run this script again."
}

if (-not (Command-Exists gh)) {
  throw "GitHub CLI is still not available. Please close and reopen PowerShell, then run this script again."
}

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host "Please log in to GitHub in the browser window that opens."
  gh auth login --web --git-protocol https
}

if (-not (Test-Path ".git")) {
  git init
}

git branch -M main

$Origin = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
  git remote add origin $RepoUrl
} elseif ($Origin -ne $RepoUrl) {
  git remote set-url origin $RepoUrl
}

git add .

$HasChanges = git status --porcelain
if ($HasChanges) {
  git commit -m "Initial Fangling Ching Hao site"
} else {
  Write-Host "No file changes to commit."
}

git push -u origin main

"https://github.com/a0972016838-oss/fangling-chinghao-profile" | Set-Content -LiteralPath "github-url.txt" -Encoding UTF8

Write-Host ""
Write-Host "Pushed to GitHub:"
Write-Host "https://github.com/a0972016838-oss/fangling-chinghao-profile"
