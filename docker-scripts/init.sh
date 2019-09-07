#!/bin/bash

cd /mcserv

declare server_exec=$(ls | grep minecraft_server)
exec java -jar $server_exec
