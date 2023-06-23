set ROBOT_APP=C:\Robot\app
set PATH2CHROME=C:\Programmes\Google\Chrome\Application\chrome.exe

set MY_BOT=Inscription_NouvelUtilisateur
set MY_BROWSER=chrome
set MY_LOGLEVEL=TRACE 
set MY_DATASET=C:\Users\qlourenc\OneDrive - Capgemini\Documents\Robot\Projet DataDriven\services\template\data_test.xlsx

python -m robot ^
--loglevel %MY_LOGLEVEL%^
-V Variables.yaml ^
tests/%MY_BOT%.robot
pause