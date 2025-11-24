param(
    [string]$Server = "127.0.0.1",
    [int]$Port = 5001,
    [string]$Message
)

$client = New-Object System.Net.Sockets.TcpClient
$client.Connect($Server, $Port)

$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

$writer.WriteLine($Message)

$writer.Close()
$client.Close()
