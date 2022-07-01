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
      dronFPS $file $limitValue
    }
  }
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

  PARAM( $path=".")

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
          $folderName = "$($Matches.3)-$($Matches.1)-$($Matches.2)/videos"
        }
        

        if((Test-Path $folderName) -eq $False)
        {
          mkDir $folderName > $null
        }

        copy $file -Destination $folderName

        # Start-BitsTransfer -Source $file -Destination $folderName -Description $file -DisplayName $file
        # Remove-Item $file   
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

Export-ModuleMember -function dronFPS, dronFPSPath, separarPorFecha

