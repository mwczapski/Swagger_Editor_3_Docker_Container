#!/bin/bash

cd /swagger_tools/swagger-editor

# convert yaml to jason and back again example
# not needed for work with the Swagger Editor server
#
cd /swagger_tools/swagger-editor/ 

java -jar /swagger_tools/swagger-codegen/swagger-codegen-cli.jar generate -i /swagger_tools/swagger-editor/openapi.yaml -l openapi -o /swagger_tools/swagger-editor

java -jar /swagger_tools/swagger-codegen/swagger-codegen-cli.jar generate -i /swagger_tools/swagger-editor/openapi.json -l openapi-yaml -o /swagger_tools/swagger-editor/converted

