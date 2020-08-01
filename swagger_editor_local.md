# Swagger Editor - Windows 10 Local

> 2020-08-01, Based on personal experience and tips in "[Swagger to parse local files](https://carolinafernandez.github.io/development/2017/09/25/Swagger-to-parse-local-files)".

<!-- TOC -->

- [Swagger Editor - Windows 10 Local](#swagger-editor---windows-10-local)
  - [Introduction](#introduction)
  - [Create Local Directories](#create-local-directories)
  - [Get Swagger Editor Artefacts](#get-swagger-editor-artefacts)
  - [Download and "Configure" Jetty Servlet Container](#download-and-configure-jetty-servlet-container)
  - [Start jetty](#start-jetty)
  - [Create test API Specification](#create-test-api-specification)
  - [Tell Swagger Editor where to find the YAML file](#tell-swagger-editor-where-to-find-the-yaml-file)
  - [Test Swagger Editor](#test-swagger-editor)
  - [Bonus Material - Windows 10 Shortcuts](#bonus-material---windows-10-shortcuts)
    - [Start jetty server](#start-jetty-server)
    - [Stop jetty server](#stop-jetty-server)
    - [Run Swagger Editor in Chrome](#run-swagger-editor-in-chrome)
    - [Run VS Code](#run-vs-code)
    - [Run powershell Here](#run-powershell-here)
  - [License](#license)

<!-- /TOC -->

## Introduction

This document describes the steps needed to set up a local Swagger Editor environment on Windows 10 / 8 / 7 for editing local Swagger and Open API specs.

The swagger editor used here is the most recent version 3.0 editor.

__*Note*__ that the Swagger Editor, set up the way it is described here, will NOT automatically save edits to the file in the local file system, even though it sees and reads the file in the local file system. See [Test Swagger Editor](#test-swagger-editor) for a brief discussion and a "solution", which makes the workflow usable.

This setup does not require docker or Windows Subsystem for Linux. It is assumed that __java__ is installed, which is most likely to be the case.

An effort was made to minimise dependencies and the need to __install__ software. Downloading a package such as __jetty__ and running it from the command line does NOT count as __install__ since it can be __"uninstalled"__ by merely deleting a directory tree.

[[Top](#swagger-editor---windows-10-local)]

## Create Local Directories

Adjust drives and paths as needed.

``` powershell
D:
cd \
mkdir \my_proj\dist
mkdir \my_proj\scripts
mkdir \my_proj\api
cd \my_proj

```

[[Top](#swagger-editor---windows-10-local)]

## Get Swagger Editor Artefacts

Only selected artefacts are needed. Adjust drives and paths as needed. This must be executed in a powershell window.

``` powershell
D:
cd \my_proj
(new-object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/swagger-api/swagger-editor/master/index.html", 'd:\my_proj\index.html')

(new-object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor-bundle.js", 'd:\my_proj\dist\swagger-editor-bundle.js')

(new-object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor-standalone-preset.js", 'd:\my_proj\dist\swagger-editor-standalone-preset.js')

(new-object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor.css", 'd:\my_proj\dist\swagger-editor.css')

```

[[Top](#swagger-editor---windows-10-local)]

## Download and "Configure" Jetty Servlet Container

We don't need a servlet container, merely a http server. Alas, apache httpd, and others, that one could consider, are cumbersome to install and configure for such a simple need. The only free Windows 10 app from the "Microsoft App Store", "Simple http Server", is not configurable so it is useless for the purpose. __jetty__will do fine, as you will see, even if it needs Java to run.
Adjust drives and paths as needed.
Commands  must be executed in a powershell window

``` powershell
cd D:\my_proj

(new-object System.Net.WebClient).DownloadFile("https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.4.31.v20200723/jetty-distribution-9.4.31.v20200723.zip", 'd:\my_proj\jetty-distribution-9.4.31.v20200723.zip')

unzip .\jetty-distribution-9.4.31.v20200723.zip
ren jetty-distribution-9.4.31.v20200723 jetty

@'
<Configure class="org.eclipse.jetty.server.handler.ContextHandler">
  <Set name="contextPath">/</Set>
  <Set name="handler">
    <New class="org.eclipse.jetty.server.handler.ResourceHandler">
      <!-- 
http://localhost:3001 
$JETTY_BASE = "d:\my_proj\jetty\"; java -jar ${JETTY_BASE}start.jar jetty.http.port=3001 jetty.base=${JETTY_BASE}
      -->
      <Set name="resourceBase">.</Set>
      <Set name="directoriesListed">true</Set>
    </New>
  </Set>
</Configure>
'@ > d:\my_proj\jetty\webapps\scratch.xml

del d:\my_proj\jetty-distribution-9.4.31.v20200723.zip

```

[[Top](#swagger-editor---windows-10-local)]

## Start jetty

The following command will run the jetty server in the powershell window until aborted with ^C

``` powershell
$JETTY_BASE = "d:\my_proj\jetty\"; cd ${JETTY_BASE}\..; java -jar ${JETTY_BASE}start.jar jetty.http.port=3001 jetty.base=${JETTY_BASE}

```

[[Top](#swagger-editor---windows-10-local)]

## Create test API Specification

Copy/paste the following text into a file `d:\my_proj\api\openapi.yaml` using the dumbest editor you can lay your hands on. One that can save text as pure ASCII or at worst utf-8.

``` powershell
openapi: "3.0.1"
info:
  title: Weather API
  description: |
    This API is a __test__ API for validation of local swagger editor
    and swagger ui deployment and configuration
  version: 1.0.0
servers:
  - url: "http://localhost:3003/"
tags:
  - name: Weather
    description: Weather, and so on
paths:
  /weather:
    get:
      tags:
        - Weather
      description: |
        It is __Good__ to be a _King_, Harry of the Golden River
      operationId: getWeather
      responses:
        "200":
          description: "All is _well_, but not quite"
          content: {}
        "500":
          description: Unexpected Error
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/response_500"
components:
  schemas:
    response_500:
      type: object
      properties:
        message:
          type: string
```

[[Top](#swagger-editor---windows-10-local)]

## Tell Swagger Editor where to find the YAML file

If we do nothing further, and run a web browser pointed to `http://localhost:3001`, the archetypical "Pet Store" will be shown. This is because the Swagger Editor index.html does not specify which API YAML document to read and there is none provided.

Use a text editor and modify the swagger editor's `index.html` so that instead of saying:

``` javascript
        const editor = SwaggerEditorBundle({
          dom_id: '#swagger-editor',
          layout: 'StandaloneLayout',
          presets: [SwaggerEditorStandalonePreset],
    });
```

it says (note the addition of the "url" attribute):

``` javascript
    const editor = SwaggerEditorBundle({
          url: 'api/openapi.yaml',
          dom_id: '#swagger-editor',
          layout: 'StandaloneLayout',
          presets: [SwaggerEditorStandalonePreset],
    });
```

The `url`attribute value is a path to the specific YAML file relative to the location of the `index.html` file. It can be any valid url pointing to a yaml file.

[[Top](#swagger-editor---windows-10-local)]

## Test Swagger Editor

Run a web browser, preferably chrome, and direct it to url `http://localhost:3001`.

__*Note*__ that the Swagger Editor, set up the way it is described here, will NOT automatically save edits to the file in the local file system, even though it sees and reads the file in the local file system.

> Changes are said to be saved to the local browser cache. Maybe. I have seen no evidence of that.

To save the changes back to the local file system, and update the original file, pull down the File menu, choose Save as YAML and save to the specific directory.

![image-20200801161450396](image-20200801161450396.png)

![image-20200801161616204](image-20200801161616204.png)

Not the safest and most efficient workflow but it does work.

I found it expedient to use the VSCode with some YAML extensions to edit the open ai specs and validate and visualise them using the Swagger Editor set up as described here.

It is also the case that VSCode extension "Swagger Preview" can dispense with Swagger Editor as described here all together.

[[Top](#swagger-editor---windows-10-local)]

## Bonus Material - Windows 10 Shortcuts

Create them using powershell.

### Start jetty server

``` powershell
cd D:\my_proj
mkdir scripts -ErrorAction 'ignore'

@'
$JETTY_BASE = ".\jetty\"
$JettyHttpPort = $Args[0]
java -jar ${JETTY_BASE}start.jar -D"STOP.PORT=12345" -D"STOP.KEY=secret" jetty.http.port=$JettyHttpPort jetty.base=${JETTY_BASE}
'@ >scripts/_start_jetty.ps1

$NORMAL_WINDOW=0
$MAXIMIZED=3
$MINIMIZED=7

$pIconLocation="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$pShortcutPath="d:\my_proj\_Start Jetty on 3001.LNK"
$TargetPath="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$WorkingDirectory="%~dp0"
$pWindowStyle=${NORMAL_WINDOW}
$pArguments="scripts/_start_jetty.ps1 3001"

$s=(New-Object -COM WScript.Shell).CreateShortcut($pShortcutPath)
$s.TargetPath=$TargetPath;
$s.WorkingDirectory=${WorkingDirectory};
$s.WindowStyle=${pWindowStyle};
$s.IconLocation=${pIconLocation};
$s.Arguments=${pArguments};
$s.Save()

```

[[Top](#swagger-editor---windows-10-local)]

### Stop jetty server

``` powershell
cd d:\my_proj
mkdir scripts -ErrorAction 'ignore'

@'
$JETTY_BASE = ".\jetty\"
java -jar ${JETTY_BASE}start.jar -D"STOP.PORT=12345" -D"STOP.KEY=secret" --stop
'@ >scripts/_stop_jetty.ps1

$NORMAL_WINDOW=0
$MAXIMIZED=3
$MINIMIZED=7

$pIconLocation="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$pShortcutPath="d:\my_proj\_Stop Jetty.LNK"
$TargetPath="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$WorkingDirectory="%~dp0"
$pWindowStyle=${NORMAL_WINDOW}
$pArguments="scripts/_stop_jetty.ps1"

$s=(New-Object -COM WScript.Shell).CreateShortcut($pShortcutPath)
$s.TargetPath=$TargetPath;
$s.WorkingDirectory=${WorkingDirectory};
$s.WindowStyle=${pWindowStyle};
$s.IconLocation=${pIconLocation};
$s.Arguments=${pArguments};
$s.Save()

```

[[Top](#swagger-editor---windows-10-local)]

### Run Swagger Editor in Chrome

``` powershell
cd d:\my_proj

$NORMAL_WINDOW=0
$MAXIMIZED=3
$MINIMIZED=7

$pIconLocation="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$pShortcutPath="d:\my_proj\_Swagger Editor on 3001.LNK"
$TargetPath="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
$WorkingDirectory="%~dp0"
$pWindowStyle=${NORMAL_WINDOW}
$pArguments="-new-window  http://localhost:3001/#"

$s=(New-Object -COM WScript.Shell).CreateShortcut($pShortcutPath)
$s.TargetPath="${TargetPath}";
$s.WorkingDirectory="${WorkingDirectory}";
$s.WindowStyle=${pWindowStyle};
$s.IconLocation="${pIconLocation}";
$s.Arguments="${pArguments}";
$s.Save()

```

[[Top](#swagger-editor---windows-10-local)]

### Run VS Code

``` powershell
cd d:\my_proj

$NORMAL_WINDOW=0
$MAXIMIZED=3
$MINIMIZED=7

$pIconLocation="C:\Program Files\Microsoft VS Code\Code.exe"
$pShortcutPath="d:\my_proj\_VS Code Here.LNK"
$TargetPath="C:\Program Files\Microsoft VS Code\Code.exe"
$WorkingDirectory="%~dp0"
$pWindowStyle=${NORMAL_WINDOW}
$pArguments="."

$s=(New-Object -COM WScript.Shell).CreateShortcut($pShortcutPath)
$s.TargetPath="${TargetPath}";
$s.WorkingDirectory="${WorkingDirectory}";
$s.WindowStyle=${pWindowStyle};
$s.IconLocation="${pIconLocation}";
$s.Arguments="${pArguments}";
$s.Save()

```

[[Top](#swagger-editor---windows-10-local)]

### Run powershell Here

``` powershell
cd d:\my_proj

$NORMAL_WINDOW=0
$MAXIMIZED=3
$MINIMIZED=7

$pIconLocation="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$pShortcutPath="d:\my_proj\_powershell Here.LNK"
$TargetPath="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$WorkingDirectory="%~dp0"
$pWindowStyle=${NORMAL_WINDOW}
$pArguments=""

$s=(New-Object -COM WScript.Shell).CreateShortcut($pShortcutPath)
$s.TargetPath="${TargetPath}";
$s.WorkingDirectory="${WorkingDirectory}";
$s.WindowStyle=${pWindowStyle};
$s.IconLocation="${pIconLocation}";
$s.Arguments="${pArguments}";
$s.Save()

```

[[Top](#swagger-editor---windows-10-local)]

## License

MIT License

Copyright &copy; 2020, Michael Czapski
