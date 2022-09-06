Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

Install-Module -Name UMN-Google
Import-Module UMN-Google

$event_log = [System.Collections.ArrayList]::new()

Function Use-Culture (
[System.Globalization.CultureInfo]$culture = (throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"),
[ScriptBlock]$script= (throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}")){
    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    trap 
    {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
    }
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
    Invoke-Command $script
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture
}

# Set security protocol to TLS 1.2 to avoid TLS errors
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Copy the certificate to access spreadsheet
$null = New-Item -ItemType Directory -Path 'C:\certificate'
$file = Get-Item 'C:\certificate'
$file.Attributes = 'Hidden'
Copy-Item -Path '.\Clientes\Mindlab\mindlab-hostname-7df19be70787.p12' -Destination 'C:\certificate'

# Google API Authozation
$scope = "https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/drive.file"
$certPath = "C:\certificate\mindlab-hostname-7df19be70787.p12"
$iss = 'powershell-up@mindlab-hostname.iam.gserviceaccount.com'
$certPswd = 'notasecret'
$spreadSheetID = '1v0Y25SG_8dsVFoOaEJ1Qkeaj0xNgOKTJPKEDxxMPlMQ'

$accessToken = Use-Culture en-US {
    $accessToken = Get-GOAuthTokenService -scope $scope -certPath $certPath -certPswd $certPswd -iss $iss
    return $accessToken
}

#Asks the customer's username that will be configured
[string]$user = Read-Host "`nDigite o nome do colaborador da Mindlab:`n"

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\Mindlab\Packages\Chocolatey\softwares.txt")

#Calling InstallExe function to run .exe or .msi 
installExe -Installer (Get-Content -Path ".\Clientes\Mindlab\Packages\Installers\softwares.txt")

#Getting the total number of notebooks
[int]$number = (Get-GSheetData -accessToken $accessToken -cell 'Range' -rangeA1 'F1:F2' -sheetName 'Mindlab' -spreadSheetID $spreadSheetID).'Total de Maquinas'

#Generates the installation log on the desktop
$serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
Write-Output -InputObject $event_log > "~\Desktop\Mindlab - $serial.txt"

#Get Anydesk's ID
$anydeskID = & ".\Clientes\Mindlab\anydeskID.bat"
echo "MindPG@753159" | & "C:\Program Files (x86)\AnyDeskMSI\AnyDeskMSI.exe" --set-password

#Change notebook's hostname
$hostname = 'MINDLAB-PG' + ('{0:d4}' -f ($number + 1))
Rename-Computer -NewName $hostname

#Create the ArrayList and add values to it
$machine = [System.Collections.ArrayList]::new()
[void]$machine.Add(@($serial; $user; $hostname; $anydeskID))

#Set the values of "Serial", "User", "Hostname" and "AnydeskID" on spreadsheet
$row = $number + 2;
$null = Set-GSheetData -accessToken $accessToken -rangeA1 "A${row}:D${row}" -sheetName 'Mindlab' -spreadSheetID $spreadSheetID -values $machine

#Update the quantity of notebooks
$newNumber = [System.Collections.ArrayList]::new()
[void]$newNumber.Add(@([String]($number+ 1)))
$null = Set-GSheetData -accessToken $accessToken -rangeA1 "F2" -sheetName 'Mindlab' -spreadSheetID $spreadSheetID -values $newNumber

Remove-item -Path C:\certificate -Recurse -Force

#Calling endExibition function
endExibition