#!/bin/bash

server_exec=$(ls | grep forge)
jvm_args=$(cat jvm_args)

exec java $jvm_args -jar $server_exec
