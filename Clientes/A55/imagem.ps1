Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$event_log = [System.Collections.ArrayList]::new()

#Requests the technician to inform the employee's name
[string]$user_name = Read-Host "`nDigite o nome do colaborador da A55:`n"

#Prompts the technician to inform the configuration profile for the machine
[string]$user_profile
switch (Read-Host "`n===========================================================`n
  Por favor, digite qual o perfil que será configurado:
  `n===========================================================`n
  1 - Perfil Simples - Gsuite Sync, Teamviewer, Drive File Stream, Office, OCS`n
  2 - Perfil UX/Data - OpenVPN, Gsuite Sync, Teamviewer, Drive File Stream, Office, OCS`n
  3 - Perfil Produto - GsuiteSync, Teamviewer, Drive File Stream, Google Hangouts, Office, OCS`n
  4 - Perfil Mercado - Chrome, Winrar, Gsuite Sync, Teamviewer, Drive File Stream, Office, OCS`n") {
    
    '1'{
        Write-Host "`n `nO perfil de instalação Simples foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "padrao"
    }
    '2'{
        Write-Host "`n `nO perfil de instalação UX/Data foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "ux-data"
    }
    '3'{
        Write-Host "`n `nO perfil de instalação Produto foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "produto"
    }
    '4'{
        Write-Host "`n `nO perfil de instalação Mercado foi selecionado`n " -ForegroundColor Green -BackgroundColor Black
        $user_profile = "mercado"
    }
    Default {
        [System.Windows.MessageBox]::Show('Por favor, digite um perfil de configuração válido!', 'Script de Imagem da A55', 'OK', 'Error')
        exit 5
    }
}

#Sets the administrator user's password
$password = ConvertTo-SecureString 'a55tech' -AsPlainText -Force
$user = Get-LocalUser
$user | Set-LocalUser -Password $password

#Calling InstallPackage function to install Chocolatey packages
installPackage -PackageList (Get-Content -Path ".\Clientes\A55\Packages\Chocolatey\${user_profile}.txt")

#Calling InstallExe function to run .exe or .msi 
installExe -Installer (Get-Content -Path ".\Clientes\A55\Packages\Installers\softwares.txt")

#Creates the contributor´s user
New-LocalUser $user_name -Password (ConvertTo-SecureString 'a55' -AsPlainText -Force) -FullName $user_name
Add-LocalGroupMember -Group "Administradores" -Member $user_name

#Generates the installation log on the desktop
$serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
Write-Output -InputObject $event_log > "~\Desktop\A55 - $serial.txt"

endExibition