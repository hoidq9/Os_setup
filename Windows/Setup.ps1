# Kiểm tra xem script có đang chạy với quyền admin không

# Thư mục đích
$destDir = "C:\themes"

# Tạo thư mục C:\themes nếu chưa tồn tại
if (-not (Test-Path $destDir)) {
    New-Item -Path $destDir -ItemType Directory -Force | Out-Null
}

# Đường dẫn file omp.json (cùng thư mục với setup.ps1)
$sourceFile = Join-Path $PSScriptRoot "wholespace.omp.json"

# Copy file vào C:\themes
Copy-Item -Path $sourceFile -Destination $destDir -Force

function Test-IsAdmin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Nếu không phải admin thì thông báo và thoát
if (-not (Test-IsAdmin)) {
    Write-Host "Need run with Administrator" -ForegroundColor Red
    exit
}

# Nếu là admin, tiếp tục thực thi phần code còn lại
Write-Host "Running with Administrator" -ForegroundColor Green
$currentPolicy = Get-ExecutionPolicy

if ($currentPolicy -ne "RemoteSigned") {
    Set-ExecutionPolicy RemoteSigned
}

# Cài đặt các module
Install-Module Terminal-Icons -Force
Install-Module PSReadLine -Force


Copy-Item -Path "Profile.ps1" -Destination "$PSHOME" -Recurse -force


# Tải và chạy script cài đặt Oh My Posh
# $currentdir = $PWD.Path
# $webClient = New-Object System.Net.WebClient
# $url = "https://ohmyposh.dev/install.ps1"  # Thay thế bằng URL của tệp bạn muốn tải xuống
# $outputFile = "$currentdir\install.ps1"  # Đặt tên tệp muốn lưu trên máy tính

# $webClient.DownloadFile($url, $outputFile)
# ./install.ps1 -AllUsers
# Remove-Item .\install.ps1

$dest = "C:\Program Files\oh-my-posh"
$exe = "$dest\oh-my-posh.exe"

New-Item $dest -ItemType Directory -Force | Out-Null
Invoke-WebRequest https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-windows-amd64.exe -OutFile $exe
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$dest", "Machine")


$scriptDir = $PSScriptRoot
$scriptPath = Join-Path -Path $scriptDir -ChildPath "Set-Edge.ps1"
& $scriptPath