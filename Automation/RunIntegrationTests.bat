@echo off

:: Lansează emulatorul
"C:\Users\HP\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd Pixel_6_Pro_API_33 -no-boot-anim

:: Așteaptă ca emulatorul să fie detectat de adb
echo Așteptare emulatorul să fie detectat de adb...
:wait_for_device
adb devices | find "emulator-5554" >nul
if %errorlevel% neq 0 (
    timeout /t 5 >nul
    goto wait_for_device
)
echo Emulatorul este detectat.

:: Așteaptă finalizarea procesului de boot
echo Așteptare finalizarea procesului de boot...
:wait_for_boot
adb shell getprop sys.boot_completed | find "1" >nul
if %errorlevel% neq 0 (
    timeout /t 5 >nul
    goto wait_for_boot
)
echo Procesul de boot s-a terminat. Emulatorul este gata.

:: Navighează la directorul proiectului
cd "C:\Users\HP\AndroidStudioProjects\EpicDiceEvents_1.4"

:: Rulează testele Flutter
echo Rulez testele Flutter...
flutter run integration_test/app_test_automated.dart --device-id emulator-5554
