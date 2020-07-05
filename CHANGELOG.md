<!--lint disable prohibited-strings-->
<!--lint disable maximum-line-length-->
<!--lint disable no-literal-urls-->
<!--lint disable no-trailing-spaces-->

# Swagger Editor 3.0 Docker Image

## 2020-07-05

### Externalised and updated run_editor_server.sh

Script run_editor_server.sh no longer created in Dockerfile.
This makes it easier to enhance and test the script.

### Swagger Editor Server startup conditional

Swagger Editor startup on container start or restart is now conditional.
Presence of a file named `.no_autostart` in container directory `/api` will prevent Swagger Editor server starting at container start or restart.

To have the Swagger Editor server started on container start or re-start delete `/api/.no_autostart`

### Externalised swagger-codegen YAML to JASON and JSON to YAML conversion as an example

The original Dockerfile included commands to convert the openapi.yaml to JSON and the resulting openapi.json to YAML again.  
Commands to accomplish this are externalised to a script `/swagger_tools/swagger-codegen_convert_example.sh`. While this script is still executed at Image build, it is now persisted in the Image and can be viewed as an example in the container.

### Added section __Use swagger-codegen to convert yaml to json and back__

Added section "Use swagger-codegen to convert yaml to json and back" with examples of container commands and commands that can be used from the host.
