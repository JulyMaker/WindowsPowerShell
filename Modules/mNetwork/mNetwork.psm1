####### NETWORK MODULE #######

##########################################
############## NETWORK ###################
##########################################

Function houseLan
{ 
    <#
    .SYNOPSIS
      Muestra ips y dispositivos en red
    .DESCRIPTION 
      Muestra ips y dispositivos en red
    
    .EXAMPLE 
      houseLan
    #> 

    nmap -sn 192.168.1.0/24 -oG -
    nmap -sn 192.168.1.0/24
}

Function inventario{
   <#  
    .SYNOPSIS  
       inventario de ordenadores de red
    .DESCRIPTION 
       Inventario en excel, pasando el nombre de los ordenadores por fichero
    .EXAMPLE 
      inventario $ordenadoresFile
   #>

      PARAM( $ordenadoresFile="nombreOrdenadores.txt")

  get-Content $ordenadoresFile | ipsdinamicas.ps1 | Export-Excel -Path inventario.xlsx -AutoSize -BoldTopRow -AutoFilter -ConditionalText $(
  New-ConditionalText FALSO
  New-ConditionalText VERDADERO -BackgroundColor LightGreen -ConditionalTextColor DarkGreen)-IncludePivotTable -PivotTableName TablaDinamica -PivotRows IsDHCPEnabled -PivotData ComputerName -PivotColumns IPAddress
}

##########################################
############## PORTS #####################
##########################################

Function puertos{
    <#  
    .SYNOPSIS  
       Muestra los puertos escuchando
    .DESCRIPTION 
       Muestra los puertos escuchando
    .EXAMPLE 
      puertos 
   #>
  NETSTAT -AN|FINDSTR /C:LISTENING
}

Function pingP{
    <#  
    .SYNOPSIS  
       ping a ip y puerto especifico
    .DESCRIPTION 
       ping a ip y puerto especifico
    .EXAMPLE 
      pingP $ip $puerto 
   #>

  PARAM( $ip,
         $puerto)
  $ping = New-Object System.Net.Networkinformation.ping
  $ping.Send($ip, $puerto)
}

Function tcpP{
   <#  
    .SYNOPSIS  
       Conexion tcp
    .DESCRIPTION 
       Conexion tcp a ip y puerto especificos
    .EXAMPLE 
      tcpP $ip $puerto 
   #>

  PARAM( $ip,
         $puerto)
  $tcpClient = New-Object System.Net.Sockets.TCPClient
  $tcpClient.Connect($ip, $puerto)
}




Export-ModuleMember -function houseLan, puertos, pingP, tcpP, inventario