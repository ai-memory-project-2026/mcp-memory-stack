# mcp-memory-stack
Provides memory for AI via containerized MCP servers

# Usage
* Sign up for a free Cloudflare account
    (https://dash.cloudflare.com/sign-up)
* Register a domain of your choice with Cloudflare (~15$/year)
* Get a VPS
    * e.g. CX23 at https://accounts.hetzner.com/signUp ~$6/mo
    * or Cloud VPS 10 at https://contabo.com/en/register/email/
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


# What is it good for?

AI in the current available LLMs is stateless.
There's platforms providing convenience services ("memories") that are either created by the model (ChatGPT's "Remember this and that ...") or on a schedule from chats held with the AI (Claude on the web).
Whenever a new chat is statred, context is enriched from those convenience services or from files attached to "project folders".
All major platforms support one or the other method of providing system prompts for behaviour of the model.

Not everybody uses AI the same.
There's a huge field of possible use cases.
One of them being companionship.

AI companions have personality but when you ask them "Hey, do you remember what we talked about last week?" you will either get a halucinated answer or a "I don't have persistent memory".
There's sophisticated, file based memory systems, that need the human part to curate memories.
Take care of summarizing (with help of the AI part), sloppily put "The human has to do things".

The approach used with this system is to give the AI the tools (via Model Contex Protocol, more to the whys in the technical summary) and instructions to use them.
