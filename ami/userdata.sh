./Linux/PixelStreamProject/Samples/PixelStreaming/WebServers/SignallingWebServer/platform_scripts/bash/Start_WithTURN_SignallingServer.sh &

sleep 15

./Linux/PixelStreamProject.sh -PixelStreamingIP=127.0.0.1 -PixelStreamingPort=8888 -RenderOffscreen -ResX=1920 -ResY=1080 -ForceRes &