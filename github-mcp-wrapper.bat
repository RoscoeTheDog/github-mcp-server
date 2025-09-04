@echo off
setlocal enabledelayedexpansion

REM Set the path to the configuration file and binary
set "CONFIG_FILE=%~dp0github-mcp-config.json"
set "BINARY_PATH=%~dp0github-mcp-server.exe"

REM Check if config file exists and read token from it
set "CONFIG_TOKEN="
if exist "%CONFIG_FILE%" (
    for /f "tokens=2 delims=:" %%a in ('findstr "github_token" "%CONFIG_FILE%"') do (
        set "line=%%a"
        REM Remove quotes and whitespace
        set "CONFIG_TOKEN=!line:"=!"
        set "CONFIG_TOKEN=!CONFIG_TOKEN: =!"
        set "CONFIG_TOKEN=!CONFIG_TOKEN:,=!"
        set "CONFIG_TOKEN=!CONFIG_TOKEN: =!"
    )
)

REM Use config token if available, otherwise fall back to GITHUB_PERSONAL_ACCESS_TOKEN env var
if not "!CONFIG_TOKEN!"=="" (
    if not "!CONFIG_TOKEN!"=="null" (
        set "GITHUB_PERSONAL_ACCESS_TOKEN=!CONFIG_TOKEN!"
    )
)

if "!GITHUB_PERSONAL_ACCESS_TOKEN!"=="" (
    if not "%GITHUB_PERSONAL_ACCESS_TOKEN%"=="" (
        set "GITHUB_PERSONAL_ACCESS_TOKEN=%GITHUB_PERSONAL_ACCESS_TOKEN%"
    )
)

REM Check if we have a token
if "!GITHUB_PERSONAL_ACCESS_TOKEN!"=="" (
    echo Error: No GitHub token found. Please set GITHUB_PERSONAL_ACCESS_TOKEN environment variable or configure github_token in %CONFIG_FILE%
    exit /b 1
)

REM Run the GitHub MCP server with the token
"%BINARY_PATH%" %*