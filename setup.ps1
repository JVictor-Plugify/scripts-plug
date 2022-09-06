#Setting the default encoding to UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

#Verify if the user is running the script with administrator privileges
$admin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match 'S-1-5-32-544')
if (-not ($admin)) {

    [System.Windows.MessageBox]::Show('Por favor, inicie o script como administrador!', 'Script de Imagem', 'OK', 'Error')

    exit 5

}

#Verify the internet connection
if ((Get-NetConnectionProfile).IPv4Connectivity -notcontains "Internet" -and (Get-NetConnectionProfile).IPv6Connectivity -notcontains "Internet"){
    
    [System.Windows.MessageBox]::Show('Por favor, verifique a conexão com a Internet!', 'Script de Imagem', 'OK', 'Error')

    exit 5

}

#Install NuGet
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
[void](Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force)

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest https://community.chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

#Check the connection with the server
#If "TRUE" - Change Chocolatey repository to local server
if (Test-NetConnection -ComputerName 172.16.0.40 -Port 8082 -InformationLevel Quiet){

    choco source disable -n=chocolatey

    choco source add -n=nexus -s="http://172.16.0.40:8082/repository/chocolatey-group/"

}else {

    Write-Host "`n`nNão foi possível estabelecer conexão com o repositório Nexus, por favor, avise o grupo de Helpdesk/Infra!`n`n" -ForegroundColor Red

}

#Install NuGet packages from a Chocolatey repository - Nexus or Community
function installPackage {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [array]$PackageList
    )
    
    begin {
        Write-Host "`n`nComeçando a instalação dos softwares Chocolatey da Plugify`n`n" -ForegroundColor Green -
    }
    
    process {

        foreach($package in $PackageList){

            choco install $package -y --ignore-checksums

            if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1641 -or $LASTEXITCODE -eq 3010){

                Write-Host "`n`n$package instalado com sucesso!`n`n" -ForegroundColor Green
        
                $status = 'Instalado'
        
            }else {
        
                Write-Host "`n`nA instalação do $package falhou, tentando novamente.`n`n" -ForegroundColor Red
        
                choco install $package -y --ignore-checksums --force
        
                if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1641 -or $LASTEXITCODE -eq 3010){
        
                    Write-Host "`n`n$package instalado com sucesso`n`n" -ForegroundColor Green
        
                    $status = 'Instalado'
        
                }else {
                
                    Write-Host "`n`nA instalação do $package falhou novamente, por favor, instale o software manualmente!`n`n" -ForegroundColor Red
        
                    $status = 'Instalacao Falhou'
        
                }                
            }

            [void]$event_log.Add(
                @([pscustomobject]@{PackageName = $package; Status = $status; ErrorCode = $LASTEXITCODE; SystemDate = Get-Date -Format "dd/MM/yyyy HH:mm"})
            )
        }
    }
    
    end {
        
        #Write-Output -InputObject $logInstall > 'C:\Users\All Users\Desktop\loginstall.txt'          

    }
}

#Run .exe or .msi to install sillently
function installExe {

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [array]$Installer
    )
    
    begin {
        Write-Host "`n`nComeçando a instalação dos softwares com instaladores da $env:USERNAME `n`n" -ForegroundColor Green -
    }
    
    process {

        foreach ($exe in $Installer){

            & .\Clientes\$env:USERNAME\Packages\Installers\$exe /S

            if ($?) {

                Write-Host "`n`n$exe foi instalado com sucesso!`n`n" -ForegroundColor Green

                $status = 'Instalado'
                $LASTEXITCODE = 0

            } else {
                
                Write-Host "`n`nA instalação do $exe falhou, tentando novamente.`n`n" -ForegroundColor Red

                & .\Clientes\$env:USERNAME\Packages\Installers\$exe 
                
                if ($?) {

                    Write-Host "`n`n$exe foi instalado com sucesso!`n`n" -ForegroundColor Green

                    $status = 'Instalado'
                    $LASTEXITCODE = 0

                } else {

                    Write-Host "`n`nA instalação do $exe falhou, pulando instalação!`n`n ErrorCode: $LASTEXITCODE" -ForegroundColor Red

                    $status = 'Instalacao Falhou'
                    $LASTEXITCODE = 1

                }
            }

            [void]$event_log.Add(
                @([pscustomobject]@{PackageName = $exe; Status = $status; ErrorCode = $LASTEXITCODE; SystemDate = Get-Date -Format "dd/MM/yyyy HH:mm"})
            )
        }
    }
    
    end {
        
        #Write-Output -InputObject $logInstall > '~\Desktop\logExeInstall.txt'            

    }

}

#Show if the script have installed everything correctly
function endExibition {

    function Set-ConsoleColor ($bc, $fc) {
        $Host.UI.RawUI.BackgroundColor = $bc
        $Host.UI.RawUI.ForegroundColor = $fc
        Clear-Host
    }

    function Write-HostCenter { param($Message) Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message)}
    
    foreach ($event in $event_log){
        if($event.Status -eq "Instalado"){
            $result = $true
        }else {
            $result = $false
            break
        }
    }

    if ($result){

        Set-ConsoleColor 'black' 'green'
    
        Write-HostCenter 'EEEEEEEEEEEEEEEEEEEEEE  NNNNNNNN        NNNNNNNN  DDDDDDDDDDDDD        '
        Write-HostCenter 'E::::::::::::::::::::E  N:::::::N       N::::::N  D::::::::::::DDD     '
        Write-HostCenter 'E::::::::::::::::::::E  N::::::::N      N::::::N  D:::::::::::::::DD   '
        Write-HostCenter 'EE::::::EEEEEEEEE::::E  N:::::::::N     N::::::N  DDD:::::DDDDD:::::D  '
        Write-HostCenter '  E:::::E       EEEEEE  N::::::::::N    N::::::N    D:::::D    D:::::D '
        Write-HostCenter '  E:::::E               N:::::::::::N   N::::::N    D:::::D     D:::::D'
        Write-HostCenter '  E::::::EEEEEEEEEE     N:::::::N::::N  N::::::N    D:::::D     D:::::D'
        Write-HostCenter '  E:::::::::::::::E     N::::::N N::::N N::::::N    D:::::D     D:::::D'
        Write-HostCenter '  E:::::::::::::::E     N::::::N  N::::N:::::::N    D:::::D     D:::::D'
        Write-HostCenter '  E::::::EEEEEEEEEE     N::::::N   N:::::::::::N    D:::::D     D:::::D'
        Write-HostCenter '  E:::::E               N::::::N    N::::::::::N    D:::::D     D:::::D'
        Write-HostCenter '  E:::::E       EEEEEE  N::::::N     N:::::::::N    D:::::D    D:::::D '
        Write-HostCenter 'EE::::::EEEEEEEE:::::E  N::::::N      N::::::::N  DDD:::::DDDDD:::::D  '
        Write-HostCenter 'E::::::::::::::::::::E  N::::::N       N:::::::N  D:::::::::::::::DD   '
        Write-HostCenter 'E::::::::::::::::::::E  N::::::N        N::::::N  D::::::::::::DDD     '
        Write-HostCenter 'EEEEEEEEEEEEEEEEEEEEEE  NNNNNNNN         NNNNNNN  DDDDDDDDDDDDD        '

    }else {
        Set-ConsoleColor 'black' 'red'

        Write-HostCenter 'FFFFFFFFFFFFFFFFFFFFFF        AAA                 IIIIIIIIII  LLLLLLLLLLL             '
        Write-HostCenter 'F::::::::::::::::::::F       A:::A                I::::::::I  L:::::::::L             '
        Write-HostCenter 'F::::::::::::::::::::F      A:::::A               I::::::::I  L:::::::::L             '
        Write-HostCenter 'FF::::::FFFFFFFFF::::F     A:::::::A              II::::::II  LL:::::::LL             '
        Write-HostCenter '  F:::::F       FFFFFF    A:::::::::A               I::::I      L:::::L               '
        Write-HostCenter '  F:::::F                A:::::A:::::A              I::::I      L:::::L               '
        Write-HostCenter '  F::::::FFFFFFFFFF     A:::::A A:::::A             I::::I      L:::::L               '
        Write-HostCenter '  F:::::::::::::::F    A:::::A   A:::::A            I::::I      L:::::L               '
        Write-HostCenter '  F:::::::::::::::F   A:::::A     A:::::A           I::::I      L:::::L               '
        Write-HostCenter '  F::::::FFFFFFFFFF  A:::::AAAAAAAAA:::::A          I::::I      L:::::L               '
        Write-HostCenter '  F:::::F           A:::::::::::::::::::::A         I::::I      L:::::L               '
        Write-HostCenter '  F:::::F          A:::::AAAAAAAAAAAAA:::::A        I::::I      L:::::L         LLLLLL'
        Write-HostCenter 'FF:::::::FF       A:::::A             A:::::A     II::::::II  LL:::::::LLLLLLLLL:::::L'
        Write-HostCenter 'F::::::::FF      A:::::A               A:::::A    I::::::::I  L::::::::::::::::::::::L'
        Write-HostCenter 'F::::::::FF     A:::::A                 A:::::A   I::::::::I  L::::::::::::::::::::::L'
        Write-HostCenter 'FFFFFFFFFFF    AAAAAAA                   AAAAAAA  IIIIIIIIII  LLLLLLLLLLLLLLLLLLLLLLLL'
    }
    
    $event_log

}


#Run the image configuration script
& .\Clientes\$env:USERNAME\imagem.ps1