$ips = 33..199 | ForEach-Object { Test-Connection -ComputerName 192.168.1.$_ -Count 1 -ErrorAction SilentlyContinue } | Where-Object { $_.StatusCode -eq 0 } | ForEach-Object { $_.Address }

foreach ($ip in $ips) 
{
    $dnsResult = Resolve-DnsName -Name $ip -ErrorAction SilentlyContinue
    if ($dnsResult) {
        $hostname = $dnsResult.NameHost
        Write-Host "$ip - $hostname"
    } else {
        Write-Host "$ip - No se pudo resolver el nombre de host"
    }
}