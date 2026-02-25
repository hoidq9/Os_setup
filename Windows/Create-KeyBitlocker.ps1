# Create-KeyBitlocker.ps1
# Chạy bằng Administrator
# Tạo 1 RecoveryPassword mới cho C:
# Xóa toàn bộ RecoveryPassword cũ
# Ghi đúng key mới vào C:\Secure\bitlocker_key.txt
# Không in password ra console

function Test-IsAdmin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host "Run as Administrator" -ForegroundColor Red
    exit 1
}

$MountPoint = "C:"
$OutPath = "C:\Secure\bitlocker_key.txt"

try {

    # Lưu danh sách protector trước khi thêm
    $before = (Get-BitLockerVolume -MountPoint $MountPoint).KeyProtector
    $beforeIds = @()
    if ($before) {
        $beforeIds = $before | ForEach-Object { $_.KeyProtectorId }
    }

    # Thêm Recovery Password mới
    $new = Add-BitLockerKeyProtector -MountPoint $MountPoint -RecoveryPasswordProtector 3>$null

    # Lấy danh sách sau khi thêm
    $all = (Get-BitLockerVolume -MountPoint $MountPoint).KeyProtector

    $newId = $null
    $recoveryPassword = $null

    # Trường hợp có .Password trả về
    if ($new -and $new.PSObject.Properties.Name -contains 'Password' -and $new.Password) {
        $recoveryPassword = $new.Password
        if ($new.PSObject.Properties.Name -contains 'KeyProtectorId') {
            $newId = $new.KeyProtectorId
        }
    }
    else {
        # Tìm protector mới (after - before)
        $candidate = $all | Where-Object {
            $_.KeyProtectorType -eq 'RecoveryPassword' -and
            ($beforeIds -notcontains $_.KeyProtectorId)
        } | Select-Object -First 1

        if ($candidate) {
            $newId = $candidate.KeyProtectorId
            $recoveryPassword = $candidate.RecoveryPassword
        }
        else {
            throw "Cannot determine new RecoveryPassword."
        }
    }

    if (-not $recoveryPassword) {
        throw "RecoveryPassword not found."
    }

    # Xóa tất cả RecoveryPassword cũ (giữ lại key mới)
    $all | Where-Object {
        $_.KeyProtectorType -eq 'RecoveryPassword' -and
        $_.KeyProtectorId -ne $newId
    } | ForEach-Object {
        Remove-BitLockerKeyProtector -MountPoint $MountPoint -KeyProtectorId $_.KeyProtectorId -Confirm:$false
    }

    # Tạo thư mục nếu chưa tồn tại
    $dir = Split-Path $OutPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }

    # Ghi file (ghi đè)
    [System.IO.File]::WriteAllText($OutPath, $recoveryPassword)

    exit 0
}
catch {
    Write-Error $_
    exit 1
}