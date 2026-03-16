# Disable Password Credential Provider

function Test-IsAdmin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "Run as Administrator" -ForegroundColor Red
    exit 1
}

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

# Tạo key nếu chưa có
if (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}

# GUID Password Provider
$PasswordProvider = "{60B78E88-EAD8-445C-9CFD-0B87F74EA6CD}"

# Set ExcludeCredentialProviders
New-ItemProperty `
    -Path $RegPath `
    -Name "ExcludedCredentialProviders" `
    -PropertyType MultiString `
    -Value $PasswordProvider `
    -Force

Write-Output "Password Credential Provider disabled."