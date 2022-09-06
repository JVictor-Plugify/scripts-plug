Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$event_log = [System.Collections.ArrayList]::new()

#Asks the customer's username that will be configured
[string]$user_name = Read-Host "`nDigite o nome do colaborador da New Hope:`n"

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\New Hope\Packages\Chocolatey\softwares.txt")

#Calling InstallExe function to run .exe or .msi 
installExe -Installer (Get-Content -Path ".\Clientes\New Hope\Packages\Installers\softwares.txt")

#Sets the user's password
$password = ConvertTo-SecureString '123' -AsPlainText -Force
$user = Get-LocalUser
$user | Set-LocalUser -Password $password

#Changes the default name "New Hope" by customer name
Rename-LocalUser -Name "New Hope" -NewName $user_name

#Generates the installation log on the desktop
$serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
Write-Output -InputObject $event_log > "~\Desktop\New Hope - $serial.txt"

endExibition