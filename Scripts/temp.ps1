#.\Links\openhardwaremonitor-v0.9.6\OpenHardwareMonitor\OpenHardwareMonitor.exe

# Configurar la URL del servidor web de OpenHardwareMonitor
$ohmUrl = "http://localhost:8085/data.json"

# Intentar obtener los datos desde el servidor web de OpenHardwareMonitor
try {
    $response = Invoke-RestMethod -Uri $ohmUrl -Method Get
    Write-Output "Datos obtenidos exitosamente."
} catch {
    Write-Error "No se pudo conectar con el servidor remoto: $_"
    exit
}

# Función para recorrer la estructura JSON y encontrar sensores de temperatura
function Get-TemperatureSensors {
    param ($node)

    $results = @()
    foreach ($child in $node.Children) {
        if ($child.Text -eq "Temperatures") {
            foreach ($sensor in $child.Children) {
                $results += [PSCustomObject]@{
                    SensorName = $sensor.Text
                    Value      = $sensor.Value
                }
            }
        }
        # Llamada recursiva para explorar todos los nodos
        $results += Get-TemperatureSensors -node $child
    }
    return $results
}

# Obtener las temperaturas
$temperatures = Get-TemperatureSensors -node $response

# Mostrar las temperaturas
$temperatures | ForEach-Object {
    Write-Output "Sensor: $($_.SensorName), Value: $($_.Value)"
}