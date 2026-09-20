@echo off
cd /d "C:\vcpkg"

echo --- Dang chay Git Pull ---
git pull

echo --- Dang chay Bootstrap ---
call bootstrap-vcpkg.bat

echo --- Hoan thanh cap nhat vcpkg ---
exit
