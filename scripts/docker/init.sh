#!/bin/bash

cd /mcserv

server_exec=$(ls | grep minecraft_server)
exec java -jar $server_exec
