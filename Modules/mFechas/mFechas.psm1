####### MODULO FECHAS #######

Function fechasCoche 
{ 
  <#
    .SYNOPSIS
      Muestra fechas relevantes para el coche
    
    .DESCRIPTION 
      Muestra fechas relevantes para el coche
    
    .EXAMPLE 
      fechasCoche
  #> 

  $startDate=[datetime]"2019/03/14"
  
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

Function cuentaAtrasCoche
{
  <#
    .SYNOPSIS
      Muestra cuenta atras para llegada del coche
    
    .DESCRIPTION 
      Muestra cuenta atras para llegada del coche
    
    .EXAMPLE 
      cuentaAtrasCoche
  #> 

	  $startDate=[datetime]"2019/03/14"

    $coche = [math]::round((NEW-TIMESPAN -Start $startDate -End (GET-DATE)).Totaldays,3)
    $faltan = [math]::round(90 - $coche,3)
    $dosMeses = [math]::round(60 - $coche,3)
    $dosMedio = [math]::round(60 - $coche + 15, 3)
    Write-Host "Dias coche: ${coche}      Faltan: ${faltan}       Dos Meses: ${dosMeses}     Dos Meses&medio: ${dosMedio}" -ForegroundColor Yellow
}

Export-ModuleMember -function fechasCoche, cuentaAtrasCoche