Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$event_log = [System.Collections.ArrayList]::new()

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\Plugify\Packages\Chocolatey\softwares.txt")

#Calling InstallExe function to run .exe or .msi 
installExe -Installer (Get-Content -Path ".\Clientes\Plugify\Packages\Installers\softwares.txt")

#Generates the installation log on the desktop
$serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
Write-Output -InputObject $event_log > "~\Desktop\Yuca - $serial.txt"

#Calling endExibitiom function
endExibition