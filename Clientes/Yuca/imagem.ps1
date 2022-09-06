Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$event_log = [System.Collections.ArrayList]::new()

#Asks the customer's username that will be configured
[string]$user_name = Read-Host "`nDigite o nome do colaborador da Yuca:`n"

#Asks for the profile that will be installed
[string]$user_profile
switch (Read-Host "`n===========================================================`n
  Por favor, digite qual o perfil que sera configurado:
  `n===========================================================`n
  Perfil A - Adobe Reader, Autocad, pCon.planner, Miro, SketchUp, Slack, OCS`n
  Perfil B - Adobe Reader, Miro, Slack, OCS`n
  Perfil C - Office, Slack, OCS`n
  Perfil D - Construct, Slack, OCS`n
  Perfil E - Office, Slack, OCS`n
  Perfil F - Adobe DC, DWG TrueView, FileStream, Office, Slack, OCS`n
  Perfil G - Figma, FileStream, Miro, Slack, OCS`n
  Perfil H - OCS`n") {
    
    'A'{
        Write-Host "`n `nO perfil A foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "perfil_a"
    }
    'B'{
        Write-Host "`n `nO perfil B foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "perfil_b"
    }
    'C'{
        Write-Host "`n `nO perfil C foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "perfil_c"
    }
    'D'{
        Write-Host "`n `nO perfil D foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "perfil_d"
    }
    'E'{
        Write-Host "`n `nO perfil E foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "perfil_e"
    }
    'F'{
        Write-Host "`n `nO perfil F foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "perfil_f"
    }
    'G'{
        Write-Host "`n `nO perfil G foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "perfil_g"
    }
    'H'{
        Write-Host " `n `nO perfil H foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "perfil_h"
    }
    Default {
        [System.Windows.MessageBox]::Show('Por favor, digite um perfil de configuração válido!', 'Script de Imagem da Yuca', 'OK', 'Error')
        exit 5
    }
}

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\Yuca\Packages\Chocolatey\${user_profile}.txt")

#Calling InstallExe function to run .exe or .msi 
installExe -Installer (Get-Content -Path ".\Clientes\Yuca\Packages\Installers\${user_profile}.txt")

#Sets the user's password
$password = ConvertTo-SecureString 'Yuca1234!' -AsPlainText -Force
$user = Get-LocalUser
$user | Set-LocalUser -Password $password

#Changes the default name "Yuca" by customer name
Rename-LocalUser -Name "Yuca" -NewName $user_name

#Generates the installation log on the desktop
$serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
Write-Output -InputObject $event_log > "~\Desktop\Yuca - $serial.txt"

#Calling endExibitiom function
endExibition