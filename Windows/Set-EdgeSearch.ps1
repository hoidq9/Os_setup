# Chạy PowerShell với quyền Administrator

# Đảm bảo key tồn tại
if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Force | Out-Null
}

# Thêm/đặt giá trị
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "DefaultSearchProviderEnabled"   -Value 1    -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "DefaultSearchProviderName"     -Value "Google" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "DefaultSearchProviderSearchURL" -Value "https://www.google.com/search?q={searchTerms}" -PropertyType String -Force

Write-Host "Đã cấu hình xong. Vui lòng khởi động lại Microsoft Edge."
