param(
  [Parameter(Mandatory = $true)]
  [string]$ServerIp,

  [string]$User = "root",
  [int]$SshPort = 22,
  [int]$LocalPort = 9443
)

$target = "$User@$ServerIp"
Write-Host "Opening SSH tunnel to $target ..."
Write-Host "Portainer URL: https://localhost:$LocalPort"
ssh -p $SshPort -L "${LocalPort}:127.0.0.1:9443" $target
