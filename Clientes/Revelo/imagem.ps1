Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$event_log = [System.Collections.ArrayList]::new()

#Requests the technician to inform the employee's name
[string]$user_name = Read-Host "`nDigite o nome do colaborador da Revelo:`n"

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\Revelo\Packages\Chocolatey\softwares.txt")

#Sets the admin user's password
$password = ConvertTo-SecureString 'revelo.admin2020@' -AsPlainText -Force
$user = Get-LocalUser
$user | Set-LocalUser -Password $password

#Creates the contributor user and adds to the group "Administradores"
New-LocalUser $user_name -Password (ConvertTo-SecureString 'revelo123' -AsPlainText -Force) -FullName $user_name -Description "UsuÃ¡rio do colaborador Revelo"
Add-LocalGroupMember -Group "Administradores" -Member $user_name

#Generates the installation log on the desktop
$serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
Write-Output -InputObject $event_log > "~\Desktop\Revelo - $serial.txt"

endExibition