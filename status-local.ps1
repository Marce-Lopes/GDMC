"# GDMC-EU — Status check local
Write-Host ""
Write-Host "GDMC-EU Platform Status" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
Write-Host ""

# Docker containers
Write-Host "Containers:" -ForegroundColor Yellow
& docker-compose -f docker-compose-local.yml ps

Write-Host ""
Write-Host "Health Checks:" -ForegroundColor Yellow

$services = @(
    @{Name="Master Data";       Port=8075},
    @{Name="Org User";          Port=8079},
    @{Name="Channel DC";       Port=8078},
    @{Name="Leads";            Port=8077},
    @{Name="Sales Order";      Port=8091},
    @{Name="Purchase Order";   Port=8090},
    @{Name="Inventory";        Port=8092},
    @{Name="Transport Order";  Port=8093},
    @{Name="Payment";          Port=8094},
    @{Name="Campaign";         Port=8095},
    @{Name="Consent";          Port=8096},
    @{Name="Retail";           Port=8097},
    @{Name="Warranty";         Port=8098},
    @{Name="Technical";        Port=8099},
    @{Name="Report";           Port=8088},
    @{Name="SAP Integration";  Port=9010},
    @{Name="WMS Integration";  Port=9011},
    @{Name="MDM Integration";  Port=9012},
    @{Name="GBOM Integration"; Port=9013},
    @{Name="IDMS Integration"; Port=9014},
    @{Name="Web BFF";          Port=8001},
    @{Name="Mobile BFF";       Port=8002},
    @{Name="API Gateway";      Port=8000}
)

foreach ($svc in $services) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$($svc.Port)/actuator/health" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
        $status = if ($response.StatusCode -eq 200) { "UP" } else { "ISSUE" }
        $color = if ($status -eq "UP") { "Green" } else { "Yellow" }
        Write-Host ("  {0,-20} :{1} => {2}" -f $svc.Name, $svc.Port, $status) -ForegroundColor $color
    } catch {
        Write-Host ("  {0,-20} :{1} => DOWN" -f $svc.Name, $svc.Port) -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Infrastructure:" -ForegroundColor Yellow

# MySQL
try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect("localhost", 3306)
    $tcp.Close()
    Write-Host "  MySQL:3306           => UP" -ForegroundColor Green
} catch { Write-Host "  MySQL:3306           => DOWN" -ForegroundColor Red }

# Redis
try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect("localhost", 6379)
    $tcp.Close()
    Write-Host "  Redis:6379           => UP" -ForegroundColor Green
} catch { Write-Host "  Redis:6379           => DOWN" -ForegroundColor Red }

# Kafka
try {
    $tcp = New-Object System.Net.Sockets.TcpClient
    $tcp.Connect("localhost", 9092)
    $tcp.Close()
    Write-Host "  Kafka:9092           => UP" -ForegroundColor Green
} catch { Write-Host "  Kafka:9092           => DOWN" -ForegroundColor Red }