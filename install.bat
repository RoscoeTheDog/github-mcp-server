@echo off
setlocal enabledelayedexpansion

echo 🚀 GitHub MCP Server Installation Starting...
echo.

REM Check prerequisites
echo 📋 Checking prerequisites...

REM Check Go installation
go version >nul 2>&1
if errorlevel 1 (
    echo ❌ Go is not installed. Please install Go 1.23.7 or later from https://golang.org/dl/
    pause
    exit /b 1
)

for /f "tokens=3" %%a in ('go version 2^>nul') do (
    echo ✅ Go %%a found
    goto :go_found
)
:go_found

REM Check Claude Code installation
claude mcp list >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Claude Code not found or not configured. Installation will continue.
    echo    You may need to configure Claude Code manually after installation.
    echo.
)

REM Step 1: Build the server
echo 🔨 Building GitHub MCP Server...
go build -o github-mcp-server.exe ./cmd/github-mcp-server
if errorlevel 1 (
    echo ❌ Build failed
    pause
    exit /b 1
)
echo ✅ Build completed successfully

REM Step 2: Create installation directory
echo 📁 Creating installation directory...
if not exist "%USERPROFILE%\.local\bin" mkdir "%USERPROFILE%\.local\bin"

REM Step 3: Install files
echo 📦 Installing files...
copy github-mcp-server.exe "%USERPROFILE%\.local\bin\" >nul
copy github-mcp-config.json "%USERPROFILE%\.local\bin\" >nul
copy github-mcp-wrapper.bat "%USERPROFILE%\.local\bin\" >nul

echo ✅ Files installed to %USERPROFILE%\.local\bin\

REM Step 4: Check for GitHub token
echo 🔑 Checking GitHub token configuration...
if "%GITHUB_PERSONAL_ACCESS_TOKEN%"=="" (
    echo ⚠️  GITHUB_PERSONAL_ACCESS_TOKEN environment variable not set
    echo    Please set your GitHub Personal Access Token:
    echo.
    echo    PowerShell:
    echo    [Environment]::SetEnvironmentVariable^("GITHUB_PERSONAL_ACCESS_TOKEN", "your_token_here", "User"^)
    echo.
    echo    Command Prompt:
    echo    setx GITHUB_PERSONAL_ACCESS_TOKEN "your_token_here"
    echo.
) else (
    echo ✅ GitHub token found in environment
)

REM Step 5: Add to Claude Code (if available)
claude mcp list >nul 2>&1
if not errorlevel 1 (
    echo 🔧 Configuring Claude Code...
    
    REM Remove existing configuration if it exists
    claude mcp remove github >nul 2>&1
    
    REM Add the server configuration using the wrapper script
    claude mcp add github "%USERPROFILE%\.local\bin\github-mcp-wrapper.bat" stdio
    
    if not errorlevel 1 (
        echo ✅ Claude Code configured
    ) else (
        echo ⚠️  Failed to configure Claude Code automatically
    )
    
    REM Verify installation
    echo 🔍 Verifying installation...
    claude mcp list | findstr "github" >nul && (
        echo ✅ GitHub MCP server appears in Claude Code
    ) || (
        echo ⚠️  GitHub MCP server not found in Claude Code list
    )
) else (
    echo ⚠️  Claude Code not accessible. Manual configuration required:
    echo    Run: claude mcp add github "%USERPROFILE%\.local\bin\github-mcp-wrapper.bat" stdio
)

echo.
echo 🎉 Installation completed!
echo.
echo Next steps:
echo 1. Ensure GITHUB_PERSONAL_ACCESS_TOKEN is set (see above if not set^)
echo 2. Restart Claude Code
echo 3. Test with: 'List my GitHub repositories'
echo.
echo For troubleshooting, see INSTALL.md

pause