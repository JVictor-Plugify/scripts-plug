Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

$event_log = [System.Collections.ArrayList]::new()

#validates that the script has already run the first time
if (-Not (Test-Path "~\Desktop\validate.txt")){

    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

    #Configure Consorciei's VPN
    Install-Module -Name VPNCredentialsHelper

    $name = "Consorciei"
    $address = "vpn.cnsrc.io"
    $username = "Plugify"
    $plainpassword = "Csr123@"

    Add-VpnConnection -Name $name -ServerAddress $address -TunnelType Pptp -EncryptionLevel Required -AuthenticationMethod Eap -Force:$true -RememberCredential:$true -SplitTunneling:$false 
    Set-VpnConnectionUsernamePassword -connectionname $name -username $username -password $plainpassword -domain ''


    choco install anydesk.install -y --ignore-checksums


    [void][System.Windows.MessageBox]::Show('Por favor, conecte na VPN e depois clique no "OK" para poder continuar e inserir a maquina no dominio da Celcoin.', 'Imagem Consorciei', 'OK', 'Warning')

    #Inserts the machine in the domain of Consorciei
    $credencial_plug = New-Object pscredential -ArgumentList ([pscustomobject]@{
        UserName = 'plugify'
        Password = (ConvertTo-SecureString -String 'Csr123@' -AsPlainText -Force)[0]
    })

    [void](New-Item -Path "~\Desktop\validate.txt" -ItemType File)

    Add-Computer -Domain "consorciei.local" -Credential $credencial_plug -Restart


}else {
    
    #Checks which of consorciei's two user profiles will be installed
    [int]$user_type = Read-Host "`n`nDigite o tipo do usuario que sera configurado. `n1 - Heavy User`n2 - Operacoes`n"

    if ($user_type -eq 1) {

        $user = "hard_user"

    }elseif ($user_type -eq 2) {

        $user = "ops_user"

    }else {
        Write-Host "Digite uma opcao valida."
        exit 5
    }

    #Calling InstallPackage function to install Chocolatey packages
    installPackage -PackageList (Get-Content -Path ".\Clientes\Consorciei\Packages\Chocolatey\$user.txt")

    #Calling InstallExe function to run .exe or .msi 
    installExe -Installer (Get-Content -Path ".\Clientes\Consorciei\Packages\Installers\$user.txt")

    #Generates the installation log on the desktop
    $serial = (Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber
    Write-Output -InputObject $event_log > "~\Desktop\Consorciei - $serial.txt"

    #Sets the administrator user's password
    $password = ConvertTo-SecureString 'dyRmareMb5qQwkuP$' -AsPlainText -Force
    $localUser = Get-LocalUser
    $localUser | Set-LocalUser -Password $password

    #Changes the default name "Consorciei" by customer name
    Rename-LocalUser -Name "Consorciei" -NewName "consorciei-root"

    endExibition

}