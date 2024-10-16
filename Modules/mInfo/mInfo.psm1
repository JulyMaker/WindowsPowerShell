####### MODULO INFO #######

############### Alias ####################
Set-Alias elem numElem


############# Function ###################


##########################################
############# SYSTEM #####################
##########################################

Function GetInfo
{
    <#
    .SYNOPSIS
      Muestra informacion del portatil
    .DESCRIPTION 
      Muestra informacion del portatil, saca una pantalla con desplegables
    
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
      Muestra versiones de los programas python, powershell, Ruby, Bundler, Jekyll
    
    .EXAMPLE 
      GetVersion  
   #> 

    $pythonversion = python --version
    "Python version: $pythonversion" 
    echo ""

    "PowerShell version: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Build).$($PSVersionTable.PSVersion.Revision)"
    echo ""

    $rubyversion = ruby -v
    "Ruby version: $rubyversion" 
    echo ""

    $bundlerversion = bundler -v
    "Bundler version: $bundlerversion" 
    echo ""

    $jekyllversion = bundle exec jekyll -v
    "Jekyll version: $jekyllversion" 
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
       Muestra el uso de los 10 primeros programas que mas ram usen o el numero que se le pase por parametro 
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
       Muestra el uso de los 10 primeros programas que mas cpu usen o el numero que se le pase por parametro 
    .EXAMPLE 
      cpu 
    .EXAMPLE 
      cpu $num
   #> 
  PARAM ([int]$cuantos = 10)
  get-process |sort-object cpu -desc | select-object -first $cuantos
}

Function slotsram 
{
  <#  
    .SYNOPSIS  
       Info de RAM
    .DESCRIPTION 
       Info de RAM poco util
    .EXAMPLE 
      slotsram 
   #>
  Get-WmiObject -class "Win32_PhysicalMemoryArray"
}

Function inforam
{
    <#  
    .SYNOPSIS  
       Numero de slots y capacidad
    .DESCRIPTION 
       Numero de slots y capacidad
    .EXAMPLE 
      inforam 
   #>
  Get-WmiObject -class "Win32_PhysicalMemory" | Measure-Object -Property Capacity -Sum;
}

Function inforam2
{
  <#  
    .SYNOPSIS 
      Capacidad y serial number
    .DESCRIPTION 
      Capacidad y serial number
    .EXAMPLE 
      inforam2 
   #>
  Get-WmiObject -class "Win32_PhysicalMemory" | FT PSComputerName,Name,DeviceLocator,Manufacturer,Capacity,SerialNumber;
}


Function espacio
{
  <#  
    .SYNOPSIS  
       Espacio disponible en todos los discos
    .DESCRIPTION 
       Espacio disponible en todos los discos
    .EXAMPLE 
      espacio
   #>
   # Function espacioC {Gwmi -class Win32_volume | select name, capacity | where {$_.name -like "c*"}}
   

  Get-WmiObject -Class Win32_logicaldisk | Format-Table -Property @{
      Name       = 'Unidad'
      Expression = {$_.DeviceID}
  }, @{
      Name       = 'TamanoTotal(GB)'
      Expression = {[decimal]('{0:N0}' -f($_.Size/1gb))}
  }, @{
      Name       = 'Disponible(GB)'
      Expression = {[decimal]('{0:N0}'-f($_.Freespace/1gb))}
  }, @{
      Name       = 'Disponible(%)'
      Expression = {'{0,6:P0}' -f(($_.Freespace/1gb) / ($_.size/1gb))}
  } -AutoSize
}

Function seguridad
{
    <#  
    .SYNOPSIS 
      Estado de las politicas de seguridad
    .DESCRIPTION 
      Estado de las politicas de seguridad en powershell
    .EXAMPLE 
      seguridad 
    #>
  Get-ExecutionPolicy -List
}


#************************ Screen Info******************************#

Function screensSize
{
  Add-Type -AssemblyName System.Windows.Forms
  $screens = [System.Windows.Forms.Screen]::AllScreens

  $output = @()
    ForEach($screen in $screens)
    {
        $width = $screen.Bounds.Width
        $height = $screen.Bounds.Height

        $output += [PSCustomObject]@{
            "Nombre del monitor" = $screen.DeviceName
            "Ancho de pantalla (px)" = $width
            "Altura de pantalla (px)" = $height
        }
    }

    $output | Format-Table -AutoSize
}



##########################################
########### POWERSHELL ###################
##########################################

Function funciones{  

    <#  
    .SYNOPSIS  
       Muestra las funciones de los modulos
    .DESCRIPTION 
       Muestra las funciones de los modulos
    .EXAMPLE 
      funciones 
    .EXAMPLE 
      funciones $num
   #>

  PARAM([int]$numModules = (modulos | Where{$_.ModuleType -like "Script"}).Count - 1)

	$funciones = Get-Module -ListAvailable | select-object Name -first $numModules

	ForEach ($item in $funciones)
	{	
    if($item.Name -eq "ImportExcel"){ continue; }
    Write-Host ""
		$item.Name
		$func = Get-Command -Module $item.Name | select-object Name
    $par= 0
		ForEach ($name in $func)
		{
      if($par%2 -eq 0)
      {
        Write-Host ("{0,25}" -f $name.Name) -foregroundcolor "Cyan" -noNewLine
      }else{
        Write-Host ("{0,30}" -f $name.Name) -foregroundcolor "Cyan"
      }  
      $par++ 
		}
    Write-Host ""
	}

  Write-Host ""
  Write-Host "Profile"
  $funciones = Get-Command | where{$_.source -eq ""} | Select-Object Name
  $par= 0
    ForEach ($name in $funciones)
    {
      if( $name -notmatch "[A-Z]:" -AND $name -notmatch "TabExpansion2|more|Pause|ImportSystemModules|cd..|Get-Verb|Clear-Host|oss|mkdir|help" )
      {
        if($par%4 -eq 0)
        {
          Write-Host ("{0,10}" -f $name.Name) -foregroundcolor "Cyan" -noNewLine
        }elseif($par%4 -eq 1){
          Write-Host ("{0,20}" -f $name.Name) -foregroundcolor "Cyan" -noNewLine
        }elseif ($par%4 -eq 2){
          Write-Host ("{0,25}" -f $name.Name) -foregroundcolor "Cyan" -noNewLine
        } else{
          Write-Host ("{0,30}" -f $name.Name) -foregroundcolor "Cyan"
        }   
        $par++ 
      } 
    }
}

Function funcDescrip{  

   <#  
   .SYNOPSIS  
      Muestra la descripcion de las funciones de cada modulos
   .DESCRIPTION 
      Muestra la descripcion de las funciones de cada modulos
   .EXAMPLE 
     funcDescrip 
   .EXAMPLE 
     funcDescrip $num
  #>
   PARAM([int]$numModules = (modulos | Where{$_.ModuleType -like "Script"}).Count-2)

  $funciones = Get-Module -ListAvailable | select-object Name -first $numModules

  ForEach ($item in $funciones)
  {	
   if($item.Name -eq "ImportExcel"){ continue; }
   Write-Host ""
   Write-Host " $($item.Name)" -foregroundcolor "Red"

   $func = Get-Command -Module $item.Name | select-object Name

     ForEach ($name in $func)
     {
       Write-Host "  $($name.Name)" -foregroundcolor "Cyan"
       $description = (get-help $name.Name).description
       Write-Host "   $($description.Text)" -foregroundcolor "Green"
     }  
   Write-Host ""
  }

 Write-Host ""
 Write-Host "Profile"
 $funciones = Get-Command | where{$_.source -eq ""} | Select-Object Name
 $par= 0
   ForEach ($name in $funciones)
   {
     if( $name -notmatch "[A-Z]:" -AND $name -notmatch "TabExpansion2|more|Pause|ImportSystemModules|cd..|Get-Verb|Clear-Host|oss|mkdir|help" )
     {
       if($par%4 -eq 0)
       {
         Write-Host ("{0,10}" -f $name.Name) -foregroundcolor "Cyan" -noNewLine
       }elseif($par%4 -eq 1){
         Write-Host ("{0,20}" -f $name.Name) -foregroundcolor "Cyan" -noNewLine
       }elseif ($par%4 -eq 2){
         Write-Host ("{0,25}" -f $name.Name) -foregroundcolor "Cyan" -noNewLine
       } else{
         Write-Host ("{0,30}" -f $name.Name) -foregroundcolor "Cyan"
       }   
       $par++ 
     } 
   }
}


Function modulo{  

   <#  
   .SYNOPSIS  
      Muestra la descripcion de las funciones de un modulo dado
   .DESCRIPTION 
      Muestra la descripcion de las funciones de un modulo dado
   .EXAMPLE 
     modulo $moduleName
  #>
   PARAM($moduleName="mInfo", $desc=$true, [int]$numModules = (modulos | Where{$_.ModuleType -like "Script"}).Count-2)

  $funciones = Get-Module -ListAvailable | select-object Name -first $numModules

  ForEach ($item in $funciones)
  { 
   if($item.Name -ne $moduleName){ continue; }
   Write-Host ""
   Write-Host " $($item.Name)" -foregroundcolor "Red"

   $func = Get-Command -Module $item.Name | select-object Name

   if($desc)
   {
    ForEach ($name in $func)
     {
       Write-Host "  $($name.Name)" -foregroundcolor "Cyan"
       $description = (get-help $name.Name).description
       Write-Host "   $($description.Text)" -foregroundcolor "Green"
     }  
   }else{
    $par= 0
    ForEach ($name in $func)
    {
      if($par%2 -eq 0)
      {
        Write-Host ("{0,25}" -f $name.Name) -foregroundcolor "Cyan" -noNewLine
      }else{
        Write-Host ("{0,30}" -f $name.Name) -foregroundcolor "Cyan"
      }  
      $par++ 
    }
   }
     
   Write-Host ""
   break
  }
}

Function scripts{  

  <#  
    .SYNOPSIS  
       Muestra los scripts
    .DESCRIPTION 
       Muestra un listado de los scripts
    .EXAMPLE 
      scripts 
   #>

   $dir = ([system.io.fileinfo]$profile).DirectoryName 
   $scripts = ls $dir/Scripts *.ps1 | %{$_.BaseName}
   ForEach ($name in $scripts)
   {
     Write-Host ("  ${name}")  -foregroundcolor "Cyan"
   }  

   Write-Host "pythonScripts" -foreGroundColor "Yellow" 
   $scripts = ls -r $dir/pythonScripts *.py | %{$_.BaseName}
   ForEach ($name in $scripts)
   {
     Write-Host ("  ${name}")  -foregroundcolor "Cyan"
   }  
}

Function ayuda{  

  <#  
    .SYNOPSIS  
       Muestra los ejemplos de una funcion dada
    .DESCRIPTION 
       Muestra los ejemplos de una funcion dada
    .EXAMPLE 
      ayuda $comando
   #>

   PARAM($comando="ayuda") 
   get-help $comando -examples
}


##########################################
############### NUMFILES #################
##########################################

Function numElem
{
    <#
    .SYNOPSIS
      Devuelve el numero de elementos de un directorio y sus subcarpetas
    
    .DESCRIPTION 
      Devuelve el numero de elementos de un directorio y sus subcarpetas de forma recursiva
    
    .EXAMPLE 
      numElem  
   #> 

    param ($dir)
    $elements = 0
    $totalElem = 0
    $color = "Yellow"

    #Write-Host
    #dir -recurse |  ?{ $_.PSIsContainer } | %{ Write-Host $_.Name (dir $_.FullName | measure).Count }
    Write-Host
    $elements+= (dir . | ?{$_ -is [System.IO.FileInfo] } | measure).Count
    $totalElem += $elements
    Write-Host $pwd $elements

    dir . |  ?{ $_.PSIsContainer } | %{
     $elements = 0
     $elements+= (dir $_.FullName | ?{$_ -is [System.IO.FileInfo] } | measure).Count
     dir -r $_.FullName | ?{ $_.PSIsContainer } | foreach-object {

      $elements+= (dir $_.FullName| ?{$_ -is [System.IO.FileInfo] } | measure).Count
     }
     $totalElem += $elements
     Write-Host $_.Name $elements 
    }

    Write-Host
    Write-Host ("    Total elements: " + $totalElem) -foregroundcolor $color 
}


Function visualizacion 
{ 
  <#
    .SYNOPSIS
      Muestra fechas relevantes para el coche en forma de tabla
    
    .DESCRIPTION 
      Muestra fechas relevantes para el coche en forma de tabla
    
    .EXAMPLE 
      visualizacion
  #> 

  $startDate=[datetime]"2023/11/23"
  
  $color ="Yellow"
  $color2 = "White"
  $coche = [math]::round((NEW-TIMESPAN -Start $startDate -End (GET-DATE)).Totaldays,3)
  $unMeses = 30 - $coche
  $unMid = $unMeses + 15
  $dosMeses = [math]::round(60 - $coche,3)
  $dosMid = [math]::round($dosMeses + 15,3)
  $tresMeses = [math]::round(90 - $coche, 3)

  Write-Host ""
  Write-host (" {0,11} {1,8} {2,7} {3,7} {4,7}" -f "Mode   ", "  DeadLine", " Date", "      Mid", "      Date") -foregroundcolor Cyan
  Write-host ("|{0,11} | {1,8} | {2,7} | {3,7} | {4,7} |" -f "----------", "--------", "-------", "-------", "-------") -foregroundcolor $color
  Write-host ("|{0,11} | {1,8} | {2,7} | {3,7} | {4,7} |" -f "Esperando", $coche, "", "", "") -foregroundcolor $color 
  Write-host ("|{0,11} | {1,8} | {2,7} | {3,7} | {4,7} |" -f "----------", "--------", "-------", "-------", "-------") -foregroundcolor $color
  Write-host ("|{0,11} | {1,8} | {2,7} | {3,7} | {4,7} |" -f "Un Mes", $unMeses, "13 ABR", $unMid, "28 ABR") -foregroundcolor $color 
  Write-host ("|{0,11} | {1,8} | {2,7} | {3,7} | {4,7} |" -f "Dos Meses", $dosMeses, "13 MAY", $dosMid, "28 MAY") -foregroundcolor $color
  Write-host ("|{0,11} | {1,8} | {2,7} | {3,7} | {4,7} |" -f "Tres Meses", $tresMeses, "13 JUN", "", "") -foregroundcolor $color
  Write-host ("|{0,11} | {1,8} | {2,7} | {3,7} | {4,7} |" -f "----------", "--------", "-------", "-------", "-------") -foregroundcolor $color 
  Write-Host ""
}

##########################################
############### EMBALSES #################
##########################################

Function embalses{
    <#  
    .SYNOPSIS  
       Da datos de embalses con script python
    .DESCRIPTION 
       Da datos de embalses con script python por defecto Madrid
    .EXAMPLE 
      embalses
    .EXAMPLE 
      embalses $url
    .EXAMPLE 
      embalses $provincia
    #>

  PARAM( $url="", $p="")

  $script = ([system.io.fileinfo]$profile).DirectoryName + "\pythonScripts\embalses\embalses.py"
  
  if (-not $url -and -not $p)
  {
    pyt $script
    return
  }

  if(-not $p)
  {
    pyt $script --url $url
  }
  
  if(-not $url)
  {
    pyt $script --provincia $p
  }
}

Export-ModuleMember -function * -Alias *

