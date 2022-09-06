Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$event_log = [System.Collections.ArrayList]::new()

#Uninstall OneDrive
Get-Process OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process "${env:windir}\SysWOW64\OneDriveSetup.exe" "/uninstall"

#Set administrator's password
$password = ConvertTo-SecureString 'Wr67hg@#' -AsPlainText -Force
$user = Get-LocalUser
$user | Set-LocalUser -Password $password

#Change notebook's hostname
$serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
$hostname = 'NWRN-' + $serial
Rename-Computer -NewName $hostname

#Disable IPV6 on Wi-Fi interface
Disable-NetAdapterBinding -Name "Wi-Fi" -ComponentID ms_tcpip6

#Install and validate Google Credential Provider with Warren's domain
if (.\Clientes\Warren\GCPW-script -eq 0){

    [void]$event_log.Add(@([PSCustomObject]@{PackageName = 'GCPW'; Status = 'Instalado'; ErrorCode = 0; SystemDate = Get-Date -Format "dd/MM/yyyy HH:mm"}))

}else {

    [void]$event_log.Add([PSCustomObject]@{PackageName = 'GCPW'; Status = 'Não Instalado'; ErrorCode = 5; SystemDate = Get-Date -Format "dd/MM/yyyy HH:mm" })

}

#Install OpenVPN's certificate, a requirement to PritUNL
certutil -addstore TrustedPublisher ".\Clientes\Warren\Packages\Installers\openvpn.cer"

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\Warren\Packages\Chocolatey\softwares.txt")

#Download Kaspersky
New-Item -Path "~\Desktop\" -ItemType  -Name "Kaspersky"
Invoke-WebRequest "https://warren-security.s3.amazonaws.com/windows/warren-security-for-windows.exe" -OutFile "~\Desktop\Kaspersky\warren-security-for-windows.exe"

#Calling InstallExe function to run .exe or .msi 
installExe -Installer (Get-Content -Path ".\Clientes\Warren\Packages\Installers\softwares.txt")

#Generates the installation log on the desktop
Write-Output -InputObject $event_log > "~\Desktop\Warren - ${serial}.txt"

#Calling endExibitiom function
endExibition