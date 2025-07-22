# Định nghĩa đường dẫn
$prjPath = Join-Path $Env:USERPROFILE 'Prj'
$gocoursePath = Join-Path $prjPath 'GoCourse'
$logPath = Join-Path $prjPath 'Os_setup\Windows\logs'

# Nếu chưa có thư mục GoCourse
if (-not (Test-Path $gocoursePath)) {
    # Tạo Prj nếu chưa tồn tại
    if (-not (Test-Path $prjPath)) {
        New-Item -Path $prjPath -ItemType Directory | Out-Null
    }
    Push-Location $prjPath
    git clone https://github.com/RedHatOfficial/GoCourse.git
    Pop-Location
}

if (-not (Test-Path $logPath)) {
        New-Item -Path $logPath -ItemType Directory | Out-Null
    }
    
# Chuyển vào GoCourse và chạy present
Push-Location $gocoursePath
"$(Get-Date): Gocourse script started" | Out-File "$Env:USERPROFILE\Prj\Os_setup\Windows\logs\gocourse.log" -Append
go get golang.org/x/tools/cmd/present
go run golang.org/x/tools/cmd/present
Pop-Location
