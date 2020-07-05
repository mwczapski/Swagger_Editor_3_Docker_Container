#!/bin/bash

cd /swagger_tools/swagger-editor

[[ -f /api/.no_autostart ]] && exit

nodemon -L -w index.html -w /api/openapi.yaml -w /api/*.pdf -x "cp -v /api/* /swagger_tools/swagger-editor/ && http-server -p 3001"
