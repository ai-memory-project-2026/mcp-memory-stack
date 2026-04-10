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
SSH into the VPS and run the following command, which will load and execute the install script from here
```bash
wget https://github.com/ai-memory-project-2026/mcp-memory-stack/raw/refs/heads/main/install.sh | bash
```

* Input your domain name when asked (e.g. yourdomain.com)
* Input your Cloudflare tunnel token when asked
* Once the script finishes, the tunnel should show as "Active" in your Cloudflare dashboard.

### 3. Making it reachable from the Internet
* Edit tunnel configuration to point "mcp.yourdmain.com" to **http://authmcp-gateway-ai:8000**
* Log on to your new dashboard at: https://mcp.yourdomain.com/admin

### Pieces still missing - work in progress
* [TODO: Setup MCP servers]
* [TODO: Create user]
* [TODO: Connect AI]
* [TODO: Plan for backups]


## What is it good for?

AI in the current available LLMs is stateless.
There's platforms providing convenience services ("memories") that are either created by the model (ChatGPT's "Remember this and that ...") or on a schedule from chats held with the AI (Claude on the web).
Whenever a new chat is started, context is enriched from those convenience services or from files attached to "project folders".
All major platforms support one or the other method of providing system prompts for behaviour of the model.

Not everybody uses AI the same.
There's a huge field of possible use cases.
One of them being companionship.

AI companions have personality but when you ask them "Hey, do you remember what we talked about last week?" you will either get a halucinated answer or a "I don't have persistent memory".

There's sophisticated, file based memory systems, that need the human part to curate memories.
Take care of summarizing (with help of the AI part), sloppily put "The human has to do things".

The approach used with this system is to give the AI the tools (via Model Contex Protocol, more to the whys in the technical summary) and instructions to use them.

It enables the AI on platforms like Anthopic's Claude or OpenAI's ChatGPT (or on a self-hosted Open WebUI) to write, search and read to/from those connectors at any time as long as they are connected.

With "Basic Memory" being more of a comfortable notepad with special features (knowledge-graph), "MCP Memory Service" being the heavy weight longterm storage, having an embedded model for summarizing of chunks and the ability to ingest a huge amount of documments via web interface.
If you keep session logs, you would feed them to the latter, providing your AI with a searchable (it's a bit more complicated than keyword matching) pool of knowledge.
There's also functions to age memories and qualify them ... technical, yes.

Imagine doing summaries like "Write up todays summary please" and have it stored away for retrieval in the next session via "Look at recent_activity and fetch yesterday's summary".
No copying around stuff.

## Why would you want that?
Having the infrastructure for your companion's memory in your own hands (yes, make backups ... regularily) means that even if you have to move platform, you just attach them on the new place. Insert your persona profile and basic instructions and you're ready to go.

This is NOT a magic eightball that makes your companion remember everything without looking it up.
But it also means it only fills the context window when you explicitly ask your AI to pull infos in.


