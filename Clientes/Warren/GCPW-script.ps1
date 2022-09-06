# Este script faz o download do Provedor de credenciais do Google para Windows em https://tools.google.com/dlpage/gcpw/, alÃ©m de instalar e configurar esse recurso.

#O acesso de administrador do Windows Ã© obrigatÃ³rio para usar o script. #>



<# Defina a chave a seguir para os domÃ­nios de onde vocÃª quer permitir que os usuÃ¡rios faÃ§am login.



Por exemplo:



$domainsAllowedToLogin = "acme1.com,acme2.com"

#>



$domainsAllowedToLogin = "warren.com.br"



Add-Type -AssemblyName System.Drawing

Add-Type -AssemblyName PresentationFramework



<# Verifique se um ou mais domÃ­nios estÃ£o definidos #>

if ($domainsAllowedToLogin.Equals('')) {

    $msgResult = [System.Windows.MessageBox]::Show('The list of domains cannot be empty! Edite este script.', 'GCPW', 'OK', 'Error')

    exit 5

}



function Is-Admin() {

    $admin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match 'S-1-5-32-544')

    return $admin

}



<# Verifique se o usuÃ¡rio atual Ã© um administrador e saia caso nÃ£o seja. #>

if (-not (Is-Admin)) {

    $result = [System.Windows.MessageBox]::Show('Please run as administrator!', 'GCPW', 'OK', 'Error')

    exit 5

}



<# Escolha o arquivo do GCPW para fazer o download. As versÃµes de 32 bits e 64 bits tÃªm nomes diferentes #>

$gcpwFileName = 'gcpwstandaloneenterprise.msi'

if ([Environment]::Is64BitOperatingSystem) {

    $gcpwFileName = 'gcpwstandaloneenterprise64.msi'

}



<# FaÃ§a o download do instalador do GCPW. #>

$gcpwUrlPrefix = 'https://dl.google.com/credentialprovider/'

$gcpwUri = $gcpwUrlPrefix + $gcpwFileName

Write-Host 'Downloading GCPW from' $gcpwUri

Invoke-WebRequest -Uri $gcpwUri -OutFile $gcpwFileName



<# Execute o instalador do GCPW e aguarde atÃ© que a instalaÃ§Ã£o termine #>

$arguments = "/i `"$gcpwFileName`""

$installProcess = (Start-Process msiexec.exe -ArgumentList $arguments -PassThru -Wait)



<# Verifique se a instalaÃ§Ã£o foi concluÃ­da #>

if ($installProcess.ExitCode -ne 0) {

    #$result = [System.Windows.MessageBox]::Show('Installation failed!', 'GCPW', 'OK', 'Error')
    
	Write-Output "Instalacao do GCPW falhou!"
    
    exit $installProcess.ExitCode

}

else {

    #$result = [System.Windows.MessageBox]::Show('Installation completed successfully!', 'GCPW', 'OK', 'Info')

	Write-Output "Instalacao do GCPW completa com sucesso!"
	
}



<# Set the required registry key with the allowed domains #>

$registryPath = 'HKEY_LOCAL_MACHINE\Software\Google\GCPW'

$name = 'domains_allowed_to_login'

[microsoft.win32.registry]::SetValue($registryPath, $name, $domainsAllowedToLogin)



$domains = Get-ItemPropertyValue HKLM:\Software\Google\GCPW -Name $name



if ($domains -eq $domainsAllowedToLogin) {

    #$msgResult = [System.Windows.MessageBox]::Show('Configuration completed successfully!', 'GCPW', 'OK', 'Info')

	Write-Output "Configuracao do GCPW completa com sucesso!"

}

else {

    #$msgResult = [System.Windows.MessageBox]::Show('Could not write to registry. Configuration was not completed.', 'GCPW', 'OK', 'Error')

	Write-Output "A configuracao do GCPW falhou, não foi possível escrever no registro!"

}