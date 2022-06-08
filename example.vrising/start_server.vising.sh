#!/bin/bash

Xvfb :0 -screen 0 1024x768x16 &
exec wine VRisingServer.exe -address 0.0.0.0 -persistentDataPath ./save-data -serverName "VRisingServer"
