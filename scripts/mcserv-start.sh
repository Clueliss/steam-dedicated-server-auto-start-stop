#!/bin/bash

server_exec=$(ls | grep forge)
jvm_args=$(cat jvm_args)

exec setpriv --reuid=957 --regid=952 --clear-groups --inh-caps=-all java $jvm_args -jar $server_exec
