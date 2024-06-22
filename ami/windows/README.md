# Install Nvidia GRID drivers
1. Transfer your application to your instance
2. Open 80 port in Windows Firewall
3. Run following script with Powershell:
```
$Bucket = "ec2-windows-nvidia-drivers"
$KeyPrefix = "latest"
$LocalPath = "$home\Desktop\NVIDIA"
$Objects = Get-S3Object -BucketName $Bucket -KeyPrefix $KeyPrefix -Region us-east-1
foreach ($Object in $Objects) {
   $LocalFileName = $Object.Key
   if ($LocalFileName -ne '' -and $Object.Size -ne 0) {
       $LocalFilePath = Join-Path $LocalPath $LocalFileName
       Copy-S3Object -BucketName $Bucket -Key $Object.Key -LocalFile $LocalFilePath -Region us-east-1
   }
}
```
4. Install the downloaded Nvidia GRID driver stored in `~\Desktop\NVIDIA`

# Install Pixel Streaming Infrastructure
1. Run `<project_folder>\Windows\<project_name>\Samples\PixelStreaming\WebServers\get_ps_servers.bat`

# Run your Pixel Streaming App
1. Run `<project_folder>\Windows\<project_name>\Samples\PixelStreaming\WebServers\SignallingWebServer\platform_scripts\cmd\Start_WithTURN_SignallingServer.ps1` on one side
2. Run `<project_folder>\Windows\<project_name>.exe -PixelStreamingURL=ws://127.0.0.1:8888 -RenderOffscreen -AllowPixelStreamingCommands` on the other side
3. Connect to your instance public IP with a web browser and enjoy!