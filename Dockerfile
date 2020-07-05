FROM node:latest

ENV TZ_PATH="Australia/Sydney"
ENV TZ_NAME="Australia/Sydney"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    dos2unix \
    openjdk-8-jdk && \
  \
  npm i -g \
    http-server \
    nodemon && \
    \
  # set timezone
  #
  cp -v /usr/share/zoneinfo/${TZ_PATH} /etc/localtime && \
  echo "${TZ_NAME}" > /etc/timezone && \
  \
  # create the api directory (to be masked by bound volume if required)
  #
  mkdir -pv /api && \
  mkdir -pv /swagger_tools

# bring in external files
#
COPY api/openapi.yaml /api
COPY scripts/run_editor_server.sh /swagger_tools
COPY scripts/swagger-codegen_convert_example.sh /swagger_tools


RUN \
\
  # copy openapi.yaml to swagger-editor
  #
  mkdir -pv /swagger_tools/swagger-editor && \
  cp -v /api/openapi.yaml /swagger_tools/swagger-editor && \
\
  # "install" swagger-codegen
  #
  mkdir -pv /swagger_tools/swagger-codegen && \
  wget https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.20/swagger-codegen-cli-3.0.20.jar -O /swagger_tools/swagger-codegen/swagger-codegen-cli.jar && \
\
  # make scripts runnable
  #
  chmod u+x /swagger_tools/run_editor_server.sh && \
  chmod u+x /swagger_tools/swagger-codegen_convert_example.sh && \
\
  # convert yaml to jason and back again, as an example
  #
  /swagger_tools/swagger-codegen_convert_example.sh && \
\
  # Install swagger-editor
  #
  cd /swagger_tools/  && \
  npm init -y && \
  npm i swagger-editor-dist  && \
  cp -rv node_modules/swagger-editor-dist/* /swagger_tools/swagger-editor && \
\
  # update index.html to use the local openapi.json
  #
  cd /swagger_tools/swagger-editor && \
  sed -i "s|const editor = SwaggerEditorBundle({|const editor = SwaggerEditorBundle({ url: 'http://localhost:3001/openapi.yaml',|" index.html && \
  echo "Done" && \
\
  # instrument docker-entrypoint.sh to execute the /swagger_tools/run_editor_server.sh on start/re-start
  #
  sed -i '/set -e/a test $( ps -C run_editor_serv -o stat --no-headers ) == "S" || nohup /swagger_tools/run_editor_server.sh 0</dev/null 1>/dev/null 2>/dev/null &' /usr/local/bin/docker-entrypoint.sh

EXPOSE 3001

