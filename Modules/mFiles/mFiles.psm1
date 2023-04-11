####### MODULO FILES #######

Function dronFPS{
    <#  
    .SYNOPSIS  
       dronFPS por si existe error de escritura en SD del dron
    .DESCRIPTION 
       dronFPS por si existe error de escritura en SD del dron
    .EXAMPLE 
      dronFPS myFile.txt 34
    #>

  PARAM( $file, $limitValue=34)

  $regex = "(\d+)ms"
  $count = 0
  $total = 0

  foreach($line in Get-Content $file) 
  {
    if($line -match $regex)
    {
        $total++
        if( [int]$Matches.1 -gt $limitValue)
        {
          $count++
        }
    }
  }

  if($count -eq 0)
  {
     Write-Host "SIN PERDIDA !!! " -ForegroundColor Green
  }
  else
  {
    Write-Host "Hemos perdido " -NoNewline
    Write-Host "$($count)" -NoNewline -ForegroundColor Red
    Write-Host " frames de " -NoNewline
    Write-Host "$($total)" -ForegroundColor White
  }
}

Function dronFPSPath{
    <#  
    .SYNOPSIS  
       dronFPSPath por si existe error de escritura en SD del dron
    .DESCRIPTION 
       dronFPSPath por si existe error de escritura en SD del dron
    .EXAMPLE 
      dronFPSPath myPath
    #>

  PARAM( $path=".", $limitValue=34)

  $files = ls $path

  $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  $srt = New-Object System.Text.RegularExpressions.Regex(
        '\.(srt)$', $regex_opts)

  foreach($file in $files) 
  {
    if(($srt.IsMatch($file.Name)))
    {
      Write-Host "Testeando $($file)" -ForegroundColor Green
      Write-Host "  " -NoNewline
      dronFPS "$($path)/$($file)" $limitValue
    }
  }
}

Function separatedFiles{
    <#  
    .SYNOPSIS  
       Separar ficheros en carpetas por fecha con script python
    .DESCRIPTION 
       Separar ficheros en carpetas por fecha con script python
    .EXAMPLE 
      separatedFiles $path $moveVideo
    #>

  PARAM( $path=".", $moveVideo= $true)

  $script = ([system.io.fileinfo]$profile).DirectoryName + "\Modules\mFiles\separatedFiles2.py"
  
  if (-not $moveVideo)
  {
    python $script $path False
    return
  }

  python $script $path
}


Function separarPorFecha{
    <#  
    .SYNOPSIS  
       Separar ficheros en carpetas por fecha
    .DESCRIPTION 
       Separar ficheros en carpetas por fecha
    .EXAMPLE 
      separarPorFecha $path
    #>

  PARAM( $path=".", $moveVideo= $true)

  $files = ls $path
  $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  $img = New-Object System.Text.RegularExpressions.Regex(
        '\.(jpg|jpeg|png|jpge|bmp|gif|ico)$', $regex_opts)

  $regex = "(\d+)/(\d+)/(\d+) *.*"

  $progress = 0
  $progresBar = "_"
  $count = 0

  Write-Host -NoNewLine "Copying files:        "
  foreach($file in $files) 
  {
    $count++
    $skipVideo = $false

    if($file.LastWriteTime -match $regex)
    {
      if($file -is [System.IO.FileInfo])
      {
        if(($img.IsMatch($file.Name)))
        {
          $folderName = "$($Matches.3)-$($Matches.1)-$($Matches.2)/images"
        }
        else
        {
          if($moveVideo)
          {
            $folderName = "$($Matches.3)-$($Matches.1)-$($Matches.2)/videos"
          }
          else
          {
            $skipVideo = $true
          }
          
        }
        

        if((Test-Path $folderName) -eq $False)
        {
          mkDir $folderName > $null
        }

        if(!$skipVideo)
        {
          copy $file -Destination $folderName
          Remove-Item $file
        }
        
        # Start-BitsTransfer -Source $file -Destination $folderName -Description $file -DisplayName $file   
      } 
    }

    $progress = ($count*100)/$files.Length
    $num = "{0:N2}" -f ($progress)
    $progresBar= "$($progresBar)_"

    $Retroceso = "`b" * ($num.Length + $progresBar.Length)

    Write-Host "$Retroceso$progresBar" -NoNewLine -BackgroundColor "White" -ForegroundColor "White"
    Write-Host "$num%" -NoNewLine -BackgroundColor "White" -ForegroundColor "Black"
  }

  Write-Host ""
  Write-Host -NoNewLine "OK" -ForegroundColor "Green"
}

Function starMonitor{
    <#  
    .SYNOPSIS  
       Crea un watcher en una carpeta dada
    .DESCRIPTION 
       Crea un watcher que vigila la creacion de un fichero en una carpeta dada
    .EXAMPLE 
      starMonitor $path
    #>

  PARAM( $path=".")

  $watcher = New-Object System.IO.FileSystemWatcher
  $watcher.Path = $path
  $watcher.EnableRaisingEvents = $true
  
  $action =
  {
      $FullPath = $event.SourceEventArgs.FullPath
      $ChangeType = $event.SourceEventArgs.ChangeType
      Write-Host "$(Get-Date) $FullPath detectado $ChangeType"
  
      #Emitimos pitido    
      [console]::Beep()
  }

  Register-ObjectEvent $watcher 'Created' -Action $action
}

Function stopMonitor{
    <#  
    .SYNOPSIS  
       Cancela todos los monitores
    .DESCRIPTION 
       Lista y cancela todos los monitores
    .EXAMPLE 
      stopMonitor
    #>

  Get-EventSubscriber | Unregister-Event
}

Function showMonitors{
    <#  
    .SYNOPSIS  
       Lista todos los monitores activos
    .DESCRIPTION 
       Lista todos los monitores activos
    .EXAMPLE 
      showMonitors
    #>

   Get-EventSubscriber
}

Export-ModuleMember -function dronFPS, dronFPSPath, separarPorFecha, separatedFiles, starMonitor, stopMonitor, showMonitors

