#!/bin/bash

server_exec=$(ls | grep minecraft_server)
exec java -jar $server_exec >> server.log 2>&1
