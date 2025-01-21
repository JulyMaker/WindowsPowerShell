Import-Module mExtra
Import-Module mCifrado
Import-Module mlogos
Import-Module mLSColor
Import-Module mCompression
Import-Module mEmail
Import-Module mFiles
Import-Module mInfo
Import-Module mFTP
Import-Module mMouse
Import-Module mGit
Import-Module mXFlow
Import-Module mNetwork
Import-Module PSReadLine
Import-Module posh-git
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


############################################################
###################    Promp    ############################
############################################################

#Function prompt { "PS $pwd$" }
Function prompt 
{
   # $GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
   # $GitPromptSettings.DefaultPromptAbbreviateGitDirectory = $true
   # $GitPromptSettings.DefaultPromptPath.ForegroundColor = [ConsoleColor]::DarkGray # 0xFFA500
   $GitPromptSettings.DefaultPromptSuffix = ""
   $GitPromptSettings.DefaultPromptPath = ""
   $GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::Green
   $GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::Green

   $branch = git rev-parse --abbrev-ref HEAD;

   $prompt =  Write-Prompt "`nPS "
   $prompt += Write-Prompt "$pwd" -ForegroundColor ([ConsoleColor]::DarkGray)
   if($branch){
    $prompt += Write-Prompt " ($branch)" -ForegroundColor ([ConsoleColor]::Green);
    $prompt += & $GitPromptScriptBlock
   }


   $prompt += Write-Prompt ">`n" -ForegroundColor ([ConsoleColor]::White)
   $prompt += Write-Prompt "$" -ForegroundColor ([ConsoleColor]::DarkYellow)

   if ($prompt) { "$prompt " } else { " " } 
}

#$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
#Function prompt 
#{
# Write-Host -NoNewLine $env:COMPUTERNAME -ForegroundColor DarkGreen;
# Write-Host -NoNewLine " MINGW64 " -ForegroundColor DarkMagenta;
# Write-Host -NoNewLine $(Get-PromptPath) -ForegroundColor DarkYellow;
#  $branch = git rev-parse --abbrev-ref HEAD;
#
#   if($branch){Write-Host -NoNewLine -ForegroundColor Cyan " ($branch)"}
#   Write-Host -ForegroundColor White ">";
#    return "$ " 
#}

############################################################
###############    Functions    ############################
############################################################



Function admin {Start-Process powershell -Verb runAs;}
Function admin2 {Start-Process powershell -Verb runAs; exit}
Function orden {ls | sort $args[0] | select $args[0]}
Function buscar {ls -r -i * | select-string $args[0]}
Function grepExt([string] $ext) {ls -r -i *.$ext | select-string $args[0]}

Function profileDir{abrir ([system.io.fileinfo]$profile).DirectoryName}
Function profileFile{ sublime $profile }
Function profile{cd ([system.io.fileinfo]$profile).DirectoryName}

Function pw { start powershell }
Function pwi { start powershell ISE; exit}
Function ip { ipconfig | findstr "Direccion IPv4"}
Function ip2 {(Test-Connection -ComputerName $env:computername -Count 1).IPV4Address.IPAddressToString}
Function ipp {  Invoke-RestMethod http://ipinfo.io/json | Select -exp ip }
Function ippublic { wget "http://checkip.amazonaws.com/"  | Select -exp RawContent }
Function home { cd $home }
Function calen { PARAM($anyo = (Get-Date).Year, $isVacaciones = $true, $isDiasSenalados = $true) calendario $anyo $isVacaciones $isDiasSenalados }

Function dumpbin{	cd "$env:ProgramFiles (x86)\Microsoft Visual Studio 14.0\VC\bin";	.\dumpbin.exe $args[0] $args[1]}
Function nano { PARAM($File) bash -c "nano $File" }
Function hibernar { &"$env:windir\System32\rundll32.exe" powrprof.dll,SetSuspendState Hibernate }
Function killer {ps msiexec| Select-Object id |  %{kill -id $_.Id}; ps winsdksetup| Select-Object id |  %{kill -id $_.Id}; ps adksetup| Select-Object id |  %{kill -id $_.Id}}
Function repo{ cd "E:\personal\Repos\AdventOfCode\2023\build"}

Function historial {sublime (Get-PSReadLineOption | select -ExpandProperty HistorySavePath)}
Function cmakeVS {cmake  .. -G "Visual Studio 16 2019"}          
Function pingDNS { ping july.myddns.me }
Function openDir { PARAM($dir=".") explorer.exe $dir}            
Function hosts{ cat "$env:windir\System32\drivers\etc\hosts"}
Function pwdhosts{ echo "$env:windir\System32\drivers\etc\hosts"}
Function addhosts { PARAM($File) Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value $File }

############################################################
#################    Alias    ##############################
############################################################

set-alias fecha             Get-Date
set-alias abrir             explorer.exe
set-alias view              Out-GridView
set-alias columna           Select-Object
set-alias modulos           Get-Module
set-alias particiones       Get-partition
set-alias monitor           resmon
set-alias licencia          serial
set-alias cambiarColores    Get-PSReadLineOption
set-alias rename            Rename-Item
set-alias sublime           "$env:ProgramFiles\Sublime Text 3\sublime_text.exe"
set-alias code              "$env:ProgramFiles\Microsoft VS Code\code.exe"
set-alias sz                "$env:ProgramFiles\7-Zip\7z.exe"
set-alias slicer            "$env:ProgramFiles\slicer\Slic3r.exe"
set-alias repetier          "$env:ProgramFiles\Repetier-Host\RepetierHost.exe"
set-alias cmakes            "$env:ProgramFiles\CMake\bin\cmake.exe"  
set-alias pyt               "C:\python\python.exe"

############################################################
#################    Admin    ##############################
############################################################

Function isAdministrador { 
	$user = [Security.Principal.WindowsIdentity]::GetCurrent(); 
	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::administrator) 
}

Function inicio{
  clear

  #Set-PSReadLineOption -Colors @{"String" ="#5bc799"} 
  Set-ItemProperty -Path HKCU:\console -Name WindowAlpha -Value 210
    $user = '                         *'
  if (isAdministrador) {
        $user = 'Admin session            *';
        $host.UI.RawUI.WindowTitle = "July Admin Windows PowerShell"
    }

    echo "
     ****************************************
     *             $user                     
     *           July Powershell            *
     *                                      *
     ****************************************
    "
}

############################################################

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
inicio


############################################################
####################    EJEMPLOS    ########################
############################################################

# $env:PSModulePath
# (Get-Item $FileNamePath ).Extension (.Basename / .Name /.DirectoryName / .FullName)
# PS C:\Users\jmn6> dir "C:\Program Files" -File -Recurse | Sort-Object Count -Descending | Select-Object Name, Count | Out-GridView
# Get-Command | Select-Object Name,source | Where-Object {$_.source -eq "mLSColor"} |Get-Help | Out-File C:\Users\jmn6\Desktop\Ayuda.txt
# Save-Help -Force -UICulture "en-us" -DestinationPath C:\PowerShell-Help
# Update-Help -Force -UICulture "en-us" -SourcePath C:\PowerShell-Help
# systeminfo | Select-String "^OS Name","^OS Version"
# ipconfig | select-string -pattern 192
# Set-ExecutionPolicy Unrestricted | RemoteSigned | AllSigned | Restricted | Default | Bypass | Undefined
# Get-ExecutionPolicy -List
# $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
# Function virtualMachineCopy {"$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe" clonehd "$args[0]\Ubuntu.vdi" "$args[0]\Ubuntu_25.vdi" --existing}
# &"${Env:ProgramFiles}\Sublime Text 3\sublime_text.exe" $args
# robocopy dirOrigen dirDestino *.MOV *.AVI *.mpeg *.mp4 *.WAV /S  (no copia los existentes)
# ls *.txt* | Rename-Item -NewName {$_.Name.insert($_.Name.IndexOf(".txt"),'.ext')}
# ls -r *.scr | %{rm ($_).FullName}