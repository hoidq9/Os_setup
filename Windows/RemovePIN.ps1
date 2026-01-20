param(
    [Parameter(Mandatory = $true)]
    [string] $TargetUserUPN
)

# ===============================
# 1. Connect Microsoft Graph
# ===============================
$Scopes = @(
    "UserAuthenticationMethod.ReadWrite.All"
)

Connect-MgGraph -Scopes $Scopes

# ===============================
# 2. Xác định identity đang kết nối Graph
# ===============================
try {
    $Context = Get-MgContext
    $ConnectedUPN = $Context.Account
}
catch {
    Write-Host "❌ Khong the xac dinh tai khoan dang ket noi Graph" -ForegroundColor Red
    exit 1
}

Write-Host "🔐 Graph connected as: $ConnectedUPN" -ForegroundColor Cyan
Write-Host "🎯 Target UPN:         $TargetUserUPN" -ForegroundColor Cyan

# ===============================
# 3. So sánh – CHẶN TỰ XÓA WHFB
# ===============================
if ($ConnectedUPN.ToLower() -eq $TargetUserUPN.ToLower()) {
    Write-Host ""
    Write-Host "❌ BI CHAN HANH DONG NGUY HIEM" -ForegroundColor Red
    Write-Host "❌ Khong duoc tu xoa Windows Hello for Business cua chinh minh" -ForegroundColor Red
    Write-Host "❌ Hay dung tai khoan admin KHAC de thuc hien" -ForegroundColor Red
    exit 1
}

# ===============================
# 4. Lấy danh sách WHFB methods
# ===============================
try {
    $Methods = Get-MgUserAuthenticationWindowsHelloForBusinessMethod `
        -UserId $TargetUserUPN
}
catch {
    Write-Host "❌ Loi khi lay WHFB methods cua user" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

if (-not $Methods -or $Methods.Count -eq 0) {
    Write-Host "ℹ User khong co WHFB methods nao" -ForegroundColor Yellow
    exit 0
}

# ===============================
# 5. Xóa từng WHFB method (co xac nhan)
# ===============================
foreach ($m in $Methods) {
    Write-Host ""
    Write-Host "🔐 WHFB ID: $($m.Id)" -ForegroundColor Yellow
    Write-Host "    Created: $($m.CreatedDateTime)"
    Write-Host "    Strength: $($m.KeyStrength)"

    $confirm = Read-Host "👉 Xoa WHFB ID nay? (y/n)"

    if ($confirm -eq "y") {
        try {
            Remove-MgUserAuthenticationWindowsHelloForBusinessMethod `
                -UserId $TargetUserUPN `
                -WindowsHelloForBusinessAuthenticationMethodId $m.Id

            Write-Host "✅ Da xoa WHFB ID $($m.Id)" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Loi khi xoa WHFB ID $($m.Id)" -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    }
    else {
        Write-Host "⏭ Bo qua WHFB ID $($m.Id)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "🏁 Hoan thanh xu ly WHFB cho $TargetUserUPN" -ForegroundColor Cyan
