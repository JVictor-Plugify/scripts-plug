Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$event_log = [System.Collections.ArrayList]::new()

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\Celcoin\Packages\Chocolatey\softwares.txt")

#Calling InstallExe function to run .exe or .msi 
installExe -Installer (Get-Content -Path ".\Clientes\Celcoin\Packages\Installers\softwares.txt")

#Generates the installation log on the desktop
$serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
Write-Output -InputObject $event_log > "~\Desktop\Celcoin - $serial.txt"

[void][System.Windows.MessageBox]::Show('Por favor, configure a VPN e depois clique no "OK" para poder continuar e inserir a máquina no domínio da Celcoin.', 'Imagem Celcoin', 'OK', 'Warning')

#Sets the user's password
$password = ConvertTo-SecureString 'PluG!fy@Adm!n' -AsPlainText -Force
$user = Get-LocalUser
$user | Set-LocalUser -Password $password

#Inserts into the domain and exchanges the hostname of the machine
$credencial_plug = New-Object pscredential -ArgumentList ([pscustomobject]@{
    UserName = 'plugifyuser'
    Password = (ConvertTo-SecureString -String 'BS8sadpi' -AsPlainText -Force)[0]
})
Add-Computer -Domain "devcenter.com.br" -NewName ("NTBPLG$serial") -Credential $credencial_plug -Restart

#Calling endExibitiom function
endExibition