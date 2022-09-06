#Instalando e inserindo a chave Jumpcloud
cd $env:temp | Invoke-Expression; Invoke-RestMethod -Method Get -URI https://raw.githubusercontent.com/TheJumpCloud/support/master/scripts/windows/InstallWindowsAgent.ps1 -OutFile InstallWindowsAgent.ps1 | Invoke-Expression; ./InstallWindowsAgent.ps1 -JumpCloudConnectKey 473f613b5866254706e0829e8dfeace48426f367

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\Digibee\Packages\Chocolatey\softwares.txt")

#Calling InstallExe function to run .exe or .msi 
installExe -Installer (Get-Content -Path ".\Clientes\Digibee\Packages\Installers\softwares.txt")

#Inserindo senha Admin
$password = ConvertTo-SecureString 'Digi_plug@2022' -AsPlainText -Force
$user = Get-LocalUser
$user | Set-LocalUser -Password $password

#Calling endExibition function
endExibition