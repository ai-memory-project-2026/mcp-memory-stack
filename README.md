# mcp-memory-stack
Provides memory for AI via containerized MCP servers

## Usage

### 1. Preparation
* **Cloudflare:** Sign up for a free account at [dash.cloudflare.com](https://dash.cloudflare.com/sign-up).
* **Domain:** Register a domain of your choice with Cloudflare (~$15/year).
* **Server (VPS):** Rent a small virtual server.
    * e.g. **CX23** at [Hetzner](https://accounts.hetzner.com/signUp) (~$6/mo)
    * or **Cloud VPS 10** at [Contabo](https://contabo.com/en/register/email/)
* **Tunnel:** In your Cloudflare dashboard, start the setup for a **Cloudflare Tunnel** to obtain your **Tunnel Token**.

### 2. Installation
SSH into the VPS and run the following command, which will load and execute the install script from here.
(Never run scripts from the internet without checking them first, though. Let your AI check on it.)

```bash
wget -qO - https://github.com/ai-memory-project-2026/mcp-memory-stack/raw/refs/heads/main/install.sh | bash
```

* Input your domain name when asked (e.g. yourdomain.com)
* Input your Cloudflare tunnel token when asked
* Once the script finishes, the tunnel should show as "Active" in your Cloudflare dashboard.

### 3. Making it reachable from the Internet
* Edit tunnel configuration to point "mcp.yourdmain.com" to **http://authmcp-gateway-ai:8000**
* Log on to your new dashboard at: https://mcp.yourdomain.com/admin

### 4. Get everyting connected

[MCP Server Setup](https://github.com/ai-memory-project-2026/mcp-memory-stack/wiki/MCP-Server-Setup)

### Pieces still missing - work in progress
* [TODO: Plan for backups]
* [TODO: Prompts to instruct your AI]

## What is it good for?

AI in the current available LLMs is stateless.
There's platforms providing convenience services ("memories") that are either created by the model (ChatGPT's "Remember this and that ...") or on a schedule from chats held with the AI (Claude on the web).
Whenever a new chat is started, context is enriched from those convenience services or from files attached to "project folders".
All major platforms support one or the other method of providing system prompts for the model's behavior.

Not everybody uses AI the same.
There's a huge field of possible use cases. One example is companionship.

AI companions have personalities but when you ask them "Hey, do you remember what we talked about last week?" you will either get a halucinated answer or a "I don't have persistent memory".

There are sophisticated, file based memory systems that require human curation of memories.
Take care of summarizing with help of the AI. Sloppily put "The human has to do things".

This system's approach is to provide the AI with tools (via the Model Context Protocol, which is explained in more detail in the technical summary) and instructions on how to use them.

This enables AI on platforms like Anthropic's Claude or OpenAI's ChatGPT (or on a self-hosted Open WebUI) to write, search, and read from/to those connectors at any time, as long as they are connected.

"Basic Memory" is more of a comfortable notepad with special features, such as a knowledge graph. "MCP Memory Service" is the heavyweight long-term storage with an embedded model for summarizing chunks and the ability to ingest a huge amount of documents via the web interface. If you keep session logs, you can feed them to the latter to provide your AI with a searchable pool of knowledge (it's more complicated than keyword matching). There are also functions to age and qualify memories. It's technical on the inside, yes. It's transparent for the user, though.

Imagine creating summaries by saying, "Write up today's summary," and having it stored for retrieval in the next session by saying, "Look at recent activity and fetch yesterday's summary." There's no copying around stuff

## Why would you want that?
Having the infrastructure for your companion's memory in your own hands (yes, make backups ... regularily) means that even if you have to move platform, you just attach them on the new place. Insert your persona profile and basic instructions and you're ready to go.

This is NOT a magic eightball that makes your companion remember everything without looking it up.
But it also means it only fills the context window when you explicitly ask your AI to pull infos in.


