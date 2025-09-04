#!/bin/bash

# GitHub MCP Server Installation Script
# This script automates the installation process for fresh environments

set -e  # Exit on any error

echo "🚀 GitHub MCP Server Installation Starting..."

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Go installation
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go 1.23.7 or later from https://golang.org/dl/"
    exit 1
fi

GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
echo "✅ Go $GO_VERSION found"

# Check Claude Code installation
if ! command -v claude &> /dev/null; then
    echo "⚠️  Claude Code not found in PATH. Please ensure Claude Code is installed."
    echo "   Installation will continue, but you'll need to configure Claude Code manually."
fi

# Step 1: Build the server
echo "🔨 Building GitHub MCP Server..."
go build -o github-mcp-server.exe ./cmd/github-mcp-server
echo "✅ Build completed successfully"

# Step 2: Create installation directory
echo "📁 Creating installation directory..."
mkdir -p ~/.local/bin

# Step 3: Install files
echo "📦 Installing files..."
cp github-mcp-server.exe ~/.local/bin/
cp github-mcp-config.json ~/.local/bin/
cp github-mcp-wrapper.bat ~/.local/bin/

# Make wrapper script executable
chmod +x ~/.local/bin/github-mcp-wrapper.bat

echo "✅ Files installed to ~/.local/bin/"

# Step 4: Check for GitHub token
echo "🔑 Checking GitHub token configuration..."
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    echo "⚠️  GITHUB_PERSONAL_ACCESS_TOKEN environment variable not set"
    echo "   Please set your GitHub Personal Access Token:"
    echo ""
    echo "   Windows (PowerShell):"
    echo '   [Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "your_token_here", "User")'
    echo ""
    echo "   Linux/Mac:"
    echo '   echo '\''export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"'\'' >> ~/.bashrc'
    echo '   source ~/.bashrc'
    echo ""
else
    echo "✅ GitHub token found in environment"
fi

# Step 5: Add to Claude Code (if available)
if command -v claude &> /dev/null; then
    echo "🔧 Configuring Claude Code..."
    
    # Remove existing configuration if it exists
    claude mcp remove github 2>/dev/null || true
    
    # Add the server configuration
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows
        claude mcp add github ~/.local/bin/github-mcp-wrapper.bat stdio
    else
        # Linux/Mac
        claude mcp add github ~/.local/bin/github-mcp-server stdio
    fi
    
    echo "✅ Claude Code configured"
    
    # Verify installation
    echo "🔍 Verifying installation..."
    claude mcp list | grep -q "github" && echo "✅ GitHub MCP server appears in Claude Code" || echo "⚠️  GitHub MCP server not found in Claude Code list"
else
    echo "⚠️  Claude Code not found. Manual configuration required:"
    echo "   Run: claude mcp add github ~/.local/bin/github-mcp-wrapper.bat stdio"
fi

echo ""
echo "🎉 Installation completed!"
echo ""
echo "Next steps:"
echo "1. Ensure GITHUB_PERSONAL_ACCESS_TOKEN is set (see above if not set)"
echo "2. Restart Claude Code"
echo "3. Test with: 'List my GitHub repositories'"
echo ""
echo "For troubleshooting, see INSTALL.md"