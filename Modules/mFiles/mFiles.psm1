####### MODULO FILES #######

Function dronFPS{
    <#  
    .SYNOPSIS  
       dronFPS por si existe error de escritura en SD del dron
    .DESCRIPTION 
       dronFPS por si existe error de escritura en SD del dron
    .EXAMPLE 
      dronFPS myFile.txt 30
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


Export-ModuleMember -function dronFPS

