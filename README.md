# mcp-memory-stack
Provides memory for AI via containerized MCP servers

# Usage
* Sign up for a free Cloudflare account
    (https://dash.cloudflare.com/sign-up)
* Register a domain of your choice with Cloudflare (~15$/year)
* Get a VPS
    * e.g. CX23 at https://accounts.hetzner.com/signUp ~$6/mo
    * or Cloud VPS 10 at https://contabo.com/de/register/email/
    * or ask someone who can make a recommendation.
* Start setup of a Cloudflare tunnel to get a tunnel token
* SSH into the VPS and run
    * wget https://github.com/ai-memory-project-2026/mcp-memory-stack/raw/refs/heads/main/install.sh | bash
* Input your domain name when asked (e.g. natasha-ai.me)
* Input your Cloudflare tunnel token when asked
* Tunnel should register on the Cloudflare dashboard
* Edit tunnel configuration to point "mcp.yourdmain.com" to http://authmcp-gateway-ai:8000
* Logon to https://mcp.yourdomain.com/admin

* [Setup MCP servers]
* [Create user]
* [Connect AI]
* [Plan for backups]
