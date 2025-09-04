# GitHub MCP Server - Claude Code Installation

> **For Claude Code**: This file contains complete installation instructions that Claude Code can execute automatically. Simply ask Claude Code to "read @INSTALL.md and install the GitHub MCP server".

## Automated Installation for Claude Code

**Prerequisites Check:**
- Go 1.23.7+ required (check with `go version`)
- GitHub Personal Access Token needed (create at https://github.com/settings/tokens with scopes: `repo`, `read:org`, `workflow`)

**Installation Steps for Claude Code:**

1. **Build the server locally:**
   ```bash
   go build -o github-mcp-server.exe ./cmd/github-mcp-server
   ```

2. **Create project-local MCP configuration:**
   ```bash
   cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "./github-mcp-wrapper.bat",
      "args": ["stdio"],
      "env": {}
    }
  }
}
EOF
   ```

3. **Verify installation:**
   ```bash
   claude mcp list
   ```

4. **Test functionality:**
   The server should show as "Connected" in the MCP list. Test with a simple GitHub operation.

**Environment Variable Setup:**
The installation expects `GITHUB_PERSONAL_ACCESS_TOKEN` to be set. If not set during installation, the user must set it:

- **Windows (Command):** `setx GITHUB_PERSONAL_ACCESS_TOKEN "your_token_here"`
- **Windows (PowerShell):** `[Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "your_token_here", "User")`
- **Linux/Mac:** `echo 'export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"' >> ~/.bashrc && source ~/.bashrc`

**Success Criteria:**
- `claude mcp list` shows "github: ... - ✓ Connected"
- GitHub API calls work (user profile retrieval, repository access)
- No authentication errors in Claude Code
- Server runs from local project directory (not global installation)

**Project Benefits:**
- ✅ **Containerized**: All files stay in project directory
- ✅ **No global pollution**: Doesn't affect other projects
- ✅ **Version controlled**: `.mcp.json` can be committed to repo
- ✅ **Portable**: Works when project is moved or cloned

**Security Notes:**
- ⚠️ **Never commit tokens**: The `github-mcp-config.json` template has empty fields - keep them empty
- ✅ **Use environment variables**: Set `GITHUB_PERSONAL_ACCESS_TOKEN` in your environment, not in files
- ✅ **Local configuration**: Any modified config files are automatically gitignored
- ✅ **Generated files**: CLAUDE.md with user data is gitignored to prevent credential leaks

**Troubleshooting for Claude Code:**
- If build fails: Ensure Go is installed and in PATH
- If `claude mcp add` fails: Claude Code may need to be restarted
- If server shows as disconnected: Check that `GITHUB_PERSONAL_ACCESS_TOKEN` is set
- If authentication fails: Verify token has correct scopes and is not expired

## Manual Installation Steps

If you prefer manual installation or the automated script doesn't work:

### Step 1: Build Locally

```bash
# Navigate to the project directory
cd github-mcp-server

# Build the server executable locally
go build -o github-mcp-server.exe ./cmd/github-mcp-server

# Create project-local MCP configuration
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "./github-mcp-wrapper.bat",
      "args": ["stdio"],
      "env": {}
    }
  }
}
EOF
```

### Step 2: Set Up GitHub Token

Set your GitHub Personal Access Token as an environment variable:

**Windows (PowerShell):**
```powershell
[Environment]::SetEnvironmentVariable("GITHUB_PERSONAL_ACCESS_TOKEN", "your_github_token_here", "User")
```

**Windows (Command Prompt):**
```cmd
setx GITHUB_PERSONAL_ACCESS_TOKEN "your_github_token_here"
```

**Linux/Mac:**
```bash
# Add to your shell profile for persistence
echo 'export GITHUB_PERSONAL_ACCESS_TOKEN="your_github_token_here"' >> ~/.bashrc
source ~/.bashrc
```

> **Note:** Replace `your_github_token_here` with your actual GitHub token. The configuration file will automatically use the environment variable.

### Step 3: Verify Installation

1. **Check server list:**
   ```bash
   claude mcp list
   ```

2. **Test connection:**
   Start Claude Code and verify the GitHub MCP server appears as "Connected"

3. **Quick test:**
   In Claude Code, try: "List my GitHub repositories"

## Configuration Options

### GitHub MCP Configuration File

The `github-mcp-config.json` file supports the following options:

```json
{
  "description": "GitHub MCP Server Configuration",
  "github_token": "",           // Your GitHub PAT (leave empty to use env var)
  "github_username": "",        // Your GitHub username/email
  "fallback_to_env": true,      // Whether to fallback to GITHUB_PERSONAL_ACCESS_TOKEN env var
  "server_config": {
    "toolsets": ["all"],        // Available toolsets: all, repos, issues, etc.
    "dynamic_toolsets": false,  // Enable dynamic toolset discovery
    "read_only": false,         // Restrict to read-only operations
    "enable_command_logging": false,  // Log all commands
    "content_window_size": 5000 // Content window size for responses
  }
}
```

### Environment Variables

The server respects these environment variables:

- `GITHUB_PERSONAL_ACCESS_TOKEN` - Your GitHub Personal Access Token
- `GITHUB_PERSONAL_ACCESS_TOKEN` - Alternative name for the token
- `GITHUB_HOST` - GitHub hostname (for Enterprise)
- `GITHUB_TOOLSETS` - Comma-separated list of enabled toolsets
- `GITHUB_READ_ONLY` - Set to "1" to enable read-only mode
- `GITHUB_DYNAMIC_TOOLSETS` - Set to "1" to enable dynamic toolsets

## Advanced Configuration

### Using Specific Toolsets

If you want to limit which GitHub features are available, you can specify toolsets:

```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "./github-mcp-server.exe",
      "args": ["stdio", "--toolsets", "repos,issues"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_PERSONAL_ACCESS_TOKEN"
      }
    }
  }
}
```

### Read-Only Mode

To run the server in read-only mode, edit `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "./github-mcp-server.exe",
      "args": ["stdio", "--read-only"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_PERSONAL_ACCESS_TOKEN"
      }
    }
  }
}
```

### GitHub Enterprise Server

For GitHub Enterprise Server installations, edit `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "./github-mcp-server.exe",
      "args": ["stdio", "--gh-host", "https://your-github-enterprise.com"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$GITHUB_PERSONAL_ACCESS_TOKEN"
      }
    }
  }
}
```

## Available Toolsets

The GitHub MCP Server provides the following toolsets:

| Toolset | Description |
|---------|-------------|
| `context` | **Strongly recommended**: Tools that provide context about the current user and GitHub context |
| `actions` | GitHub Actions workflows and CI/CD operations |
| `code_security` | Code security related tools, such as GitHub Code Scanning |
| `dependabot` | Dependabot tools |
| `discussions` | GitHub Discussions related tools |
| `gists` | GitHub Gist related tools |
| `issues` | GitHub Issues related tools |
| `notifications` | GitHub Notifications related tools |
| `orgs` | GitHub Organization related tools |
| `pull_requests` | GitHub Pull Request related tools |
| `repos` | GitHub Repository related tools |
| `secret_protection` | Secret protection related tools |
| `security_advisories` | Security advisories related tools |
| `users` | GitHub User related tools |

## Automated Installation

You can use the provided installation scripts for easier setup:

### Windows
```cmd
# Run the installation script
install.bat

# Test the installation
test-installation.bat
```

### Project-Local Configuration 

The installation creates a `.mcp.json` file in the project directory. This file is automatically detected by Claude Code:

```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "./github-mcp-wrapper.bat",
      "args": ["stdio"],
      "env": {}
    }
  }
}
```

**Benefits:** This approach keeps the installation containerized to the project without affecting global Claude Code settings.

## Troubleshooting

### Server Not Connecting

1. **Check your GitHub token**: Ensure your token has the necessary permissions
2. **Verify local files**: Make sure `github-mcp-server.exe` and `.mcp.json` exist in project directory
3. **Check environment variables**: Ensure `GITHUB_PERSONAL_ACCESS_TOKEN` is set in your environment
4. **Test manually**: Run the server directly to see any error messages:
   ```bash
   GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" ./github-mcp-server.exe stdio
   ```
5. **Rebuild if needed**: Run `go build -o github-mcp-server.exe ./cmd/github-mcp-server` to rebuild

### Environment Variable Issues

The wrapper script (`github-mcp-wrapper.bat`) automatically handles token resolution. If you have issues:

1. **Check Windows environment variables**:
   ```cmd
   echo %GITHUB_PERSONAL_ACCESS_TOKEN%
   ```
   Make sure it returns your token value.

2. **Alternative**: Edit `github-mcp-config.json` and set `github_token` field directly (not recommended for version control)

### Permission Errors

If you get permission errors, make sure your GitHub token has the appropriate scopes:

- `repo` - Repository access
- `read:org` - Organization team access
- `read:packages` - Package access (if needed)
- `workflow` - GitHub Actions (if using actions toolset)

### Token Security

For security best practices:

1. **Use environment variables** instead of hardcoding tokens in config files
2. **Set minimal scopes** - only grant necessary permissions
3. **Rotate tokens regularly**
4. **Keep tokens out of version control**
5. **Use separate tokens** for different projects/environments

## Updating

To update the server:

1. Pull the latest changes from the repository
2. Rebuild the binary: `go build -o github-mcp-server.exe ./cmd/github-mcp-server`
3. Restart Claude Code to pick up changes (no file copying needed)

## Uninstalling

To remove the GitHub MCP server:

```bash
# Remove project files
rm -f github-mcp-server.exe
rm -f .mcp.json

# Optionally remove config files (if you want to start fresh)
# rm -f github-mcp-config.json
# rm -f github-mcp-wrapper.bat
```

## Support

If you encounter issues:

1. Check the [GitHub MCP Server repository](https://github.com/github/github-mcp-server) for documentation
2. Review the server logs for error messages
3. Ensure all prerequisites are properly installed
4. Verify your GitHub token has the necessary permissions

## File Structure

After installation, your project directory should contain:

```
github-mcp-server/
├── github-mcp-server.exe      # Main server binary (built locally)
├── github-mcp-config.json     # Configuration file
├── github-mcp-wrapper.bat     # Wrapper script for configuration handling
├── .mcp.json                  # Project-local MCP server configuration
├── cmd/                       # Source code directory
├── pkg/                       # Go packages
└── ... (other source files)
```

**Key Benefits:**
- **Self-contained**: All files remain in the project directory
- **Version controllable**: `.mcp.json` can be committed to version control
- **No system pollution**: Doesn't affect global Claude Code configuration
- **Portable**: Works when project is moved or shared