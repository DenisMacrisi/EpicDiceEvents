@echo off
:: Script pentru salvarea raportului de testare

:: Verificare dacă fișierul există pe dispozitiv înainte de a-l extrage
adb shell "ls /storage/emulated/0/Android/data/com.example.epic_dice_events/files/test_report.html" >nul 2>&1
if %errorlevel% neq 0 (
    echo Fișierul test_report.html nu a fost găsit pe dispozitiv. Verifică dacă testele au fost executate corect.
    exit /b
)

:: Execută comanda adb pull pentru a copia fișierul pe PC
echo Copiere raport de test din emulator...
adb pull /storage/emulated/0/Android/data/com.example.epic_dice_events/files/test_report.html D:\temp

:: Verifică dacă fișierul a fost copiat cu succes
if %errorlevel% equ 0 (
    echo Raportul de test a fost copiat cu succes în D:\temp.
) else (
    echo Eroare la copierea raportului de test.
)

