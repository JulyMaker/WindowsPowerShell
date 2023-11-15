####### MODULO EXTRAS #######


# Function serial
Function serial
{
  (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
}


Function cuentaAtras
{
    <#
    .SYNOPSIS
      Inicia una cuenta atras
    .DESCRIPTION 
      Inicia una cuenta atras desde un tiempo dado en milisegundos
    
    .EXAMPLE 
      cuentaAtras $time  
   #> 

    PARAM(
        [int]$time = 200
    )
    $Longitud1 = 0
    $Longitud2 = 0
    ""
    Write-Host "Elemento N      " -NoNewLine
    $time..0| ForEach{ `
        Start-Sleep -Milliseconds 5
        $Incremento = $Longitud1 - $Longitud2
        $Longitud1 = ("{0:N0}" -f ($_ + 1)).Length
        $Numero = "{0:N0}" -f $_
        $Longitud2 = $Numero.Length
        $Borrado = " " * ($Longitud1 - $Longitud2)
        $Retroceso = "`b" * ($Longitud1 + $Incremento)
        Write-Host "$Retroceso$Numero$Borrado" -NoNewLine
    }
}

Function cuenta
{
   <#
    .SYNOPSIS
      Inicia una cuenta
    .DESCRIPTION 
      Inicia una cuenta alante hasta un tiempo dado en segundos, interfaz colores
    
    .EXAMPLE 
      cuenta $time  
   #> 
    PARAM(
        [int]$time = 10
    )

    Write-Host -NoNewLine "Counting from 1 to ${time} (in seconds):  "

    $tercio = $time * 1/3

    if ($time -eq 1)
    {
         Write-Host -NoNewLine  "1 " -BackgroundColor "Green" -ForegroundColor "Black"
         Start-Sleep -Seconds 1
    }

    if($time -gt 1)
    {
       $tercio = $time * 1/3
       foreach($element in 1..$tercio){
         Write-Host -NoNewLine  "${element} " -BackgroundColor "Green" -ForegroundColor "Black"
         Start-Sleep -Seconds 1
       }
    

       if($time -gt 2)
       {
          $tercio++
          $dostercios = $time * 2/3
          foreach($element in $tercio..$dostercios){
            Write-Host -NoNewLine  "${element} " -BackgroundColor "Yellow" -ForegroundColor "Black"
            Start-Sleep -Seconds 1
          }
       }else{
         Write-Host -NoNewLine  "2 " -BackgroundColor "Yellow" -ForegroundColor "Black"
         Start-Sleep -Seconds 1
       }

       if($time -gt 2)
       {
          $dostercios++
          foreach($element in $dostercios..$time){
            Write-Host -NoNewLine  "${element} " -BackgroundColor "Red" -ForegroundColor "Black"
            Start-Sleep -Seconds 1
          }
       }
    }

    Write-Host ""
    Write-Host ""
    Write-Host "FIN !!!"
}

Function GetInicio{ 
   <#
    .SYNOPSIS
      Programas que inician con inicio de Windows
    .DESCRIPTION 
      Programas que inician con inicio de Windows
    
    .EXAMPLE 
      GetInicio  
   #>

   Get-WmiObject -Class win32_startupCommand 

}

Function shader {
   <#
    .SYNOPSIS
      Validador de shaders
    .DESCRIPTION 
      Validador de shaders
    
    .EXAMPLE 
      shader  
   #>

  glslangValidator -V $args[0]

}

Function trf {
   <#
    .SYNOPSIS
      Funcion tr en linux para fichero
    .DESCRIPTION 
      Permite cambiar una palabra de un fichero por otra
    
    .EXAMPLE 
      trf $file $from $to  
   #> 

  PARAM ($file, $from ="", $to="")
  
  ((Get-Content -path $file) -replace $from, $to) | Set-Content -Path $file
}

Function linkSimbolico {
   <#
    .SYNOPSIS
      Crea un link simbolico a una ruta
    .DESCRIPTION 
      Crea un link simbolico de la ruta 1 a la ruta 2
    
    .EXAMPLE 
      linkSimbolico $path1 $path2  
   #> 

  PARAM ([Parameter(Mandatory=$true)]$path1, [Parameter(Mandatory=$true)]$path2)
  
  New-Item -ItemType SymbolicLink -Path $path1 -Target $path2
}



Export-ModuleMember -function  cuentaAtras, cuenta, GetInicio, shader, trf, linkSimbolico

