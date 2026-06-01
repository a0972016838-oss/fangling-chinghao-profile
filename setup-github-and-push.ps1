$ErrorActionPreference = "Stop"

$RepoName = "fangling-chinghao-profile"
$Description = "Personal marketing website for Fang-Ling Hsu with Ching Hao company profile."

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

Write-Host ""
Write-Host "Preparing GitHub tools..."

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

if (-not (Command-Exists git)) {
  throw "Git is still not available. Please close and reopen PowerShell, then run this script again."
}

if (-not (Command-Exists gh)) {
  throw "GitHub CLI is still not available. Please close and reopen PowerShell, then run this script again."
}

Write-Host ""
Write-Host "Checking GitHub login..."
$AuthStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "Please log in to GitHub in the browser window that opens."
  gh auth login --web --git-protocol https
}

if (-not (Test-Path ".git")) {
  git init
}

git branch -M main
git add .

$HasChanges = git status --porcelain
if ($HasChanges) {
  git commit -m "Initial Fangling Ching Hao site"
} else {
  Write-Host "No file changes to commit."
}

$RepoExists = $false
gh repo view $RepoName *> $null
if ($LASTEXITCODE -eq 0) {
  $RepoExists = $true
}

if (-not $RepoExists) {
  gh repo create $RepoName --public --description $Description --source . --remote origin --push
} else {
  if (-not (git remote get-url origin 2>$null)) {
    $User = gh api user --jq ".login"
    git remote add origin "https://github.com/$User/$RepoName.git"
  }
  git push -u origin main
}

$User = gh api user --jq ".login"
$Url = "https://github.com/$User/$RepoName"
$Url | Set-Content -LiteralPath "github-url.txt" -Encoding UTF8

Write-Host ""
Write-Host "GitHub repository:"
Write-Host $Url
Write-Host ""
Write-Host "Saved to github-url.txt"
