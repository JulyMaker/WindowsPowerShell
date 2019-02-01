####### MODULO INFO #######

Function GetInfo
{
    <#
    .SYNOPSIS
      Muestra informacion del portatil
    .DESCRIPTION 
      Muestra informacion del portatil
    
    .EXAMPLE 
      GetInfo  
   #> 

    [CmdletBinding()]
    #PARAM ($ComputerName)
    # Computer System
    $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName "localhost" #$ComputerName
    # Operating System
    $OperatingSystem = Get-WmiObject -Class win32_OperatingSystem -ComputerName "localhost" #$ComputerName
    # BIOS
    $Bios = Get-WmiObject -class win32_BIOS -ComputerName "localhost" #$ComputerName
    
    # Prepare Output
    $Properties = @{
        ComputerName = "localhost" #$ComputerName
        Manufacturer = $ComputerSystem.Manufacturer
        Model = $ComputerSystem.Model
        OperatingSystem = $OperatingSystem.Caption
        OperatingSystemVersion = $OperatingSystem.Version
        SerialNumber = $Bios.SerialNumber
    }
    
    # Output Information
    New-Object -TypeName PSobject -Property $Properties
    Get-WmiObject -query "select * from CIM_Processor" | Group-Object Description
    MSINFO32
    
}


Function GetVersion
{
    <#
    .SYNOPSIS
      Muestra versiones de programas
    .DESCRIPTION 
      Muestra versiones de los programas php, python y powershell
    
    .EXAMPLE 
      GetVersion  
   #> 

    $phpversion =  php -v | select-string ^PHP | cut -d' ' -f2
    "PHP version: $phpversion" 
    echo ""

    $pythonversion = python --version
    "Python version: $pythonversion" 
    echo ""

    "PowerShell version: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Build).$($PSVersionTable.PSVersion.Revision)"
    echo ""
}


Function serial{
  <#  
    .SYNOPSIS  
       Muestra serial de windows  
    .DESCRIPTION 
       Muestra serial de windows    
    .EXAMPLE 
      serial 
   #> 
  (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
}

Function path{ 
   <#  
    .SYNOPSIS  
       Muestra el path  
    .DESCRIPTION 
       Muestra el path en una ventana    
    .EXAMPLE 
      path 
   #> 
  $pathJuly = $env:Path; $pathJuly.split(";") | Out-GridView
}

Function ram {
    <#  
    .SYNOPSIS  
       Muestra el uso de ram
    .DESCRIPTION 
       Muestra el uso de los 10 primeros programas que mas ram usen o el número que se le pase por parametro 
    .EXAMPLE 
      ram 
    .EXAMPLE 
      ram $num
   #> 
  PARAM ([int]$cuantos = 10)
  get-process |sort-object pm -desc | select-object -first $cuantos
}

Function cpu {
    <#  
    .SYNOPSIS  
       Muestra el uso de cpu
    .DESCRIPTION 
       Muestra el uso de los 10 primeros programas que mas cpu usen o el número que se le pase por parametro 
    .EXAMPLE 
      cpu 
    .EXAMPLE 
      cpu $num
   #> 
  PARAM ([int]$cuantos = 10)
  get-process |sort-object cpu -desc | select-object -first $cuantos
}

Function slotsram {Get-WmiObject -class "Win32_PhysicalMemoryArray"}
Function inforam{Get-WmiObject -class "Win32_PhysicalMemory" | Measure-Object -Property Capacity -Sum;}
Function inforam2{Get-WmiObject -class "Win32_PhysicalMemory" | FT PSComputerName,Name,DeviceLocator,Manufacturer,Capacity,SerialNumber;}

Function espacioC {Gwmi -class Win32_volume | select name, capacity | where {$_.name -like "c*"}}

Function seguridad{  Get-ExecutionPolicy -List}


Export-ModuleMember -function GetInfo, GetVersion, serial, seguridad, path, ram, cpu,slotsram, inforam, inforam2, espacioC
