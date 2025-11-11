' Tạo FSO để xử lý đường dẫn
Set fso = CreateObject("Scripting.FileSystemObject")

' full path đến chính file .vbs
vbsFullPath = WScript.ScriptFullName

' thư mục chứa file .vbs
vbsFolder = fso.GetParentFolderName(vbsFullPath)

' ghép đường dẫn tới Run-GoCourse.ps1 (ở cùng thư mục)
ps1FullPath = fso.BuildPath(vbsFolder, "Run-GoCourse.ps1")

' tạo shell và chạy Powershell ẩn
Set objShell = CreateObject("Wscript.Shell")
objShell.Run _
  "powershell.exe -WindowStyle Hidden -NoProfile -NonInteractive -File """ & ps1FullPath & """" _
  , 0, False
