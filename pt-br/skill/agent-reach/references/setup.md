# Setup: install, update, configure channels

Reference for installing Agent Reach, updating it, and configuring channels that
need credentials. Derived from the upstream `docs/install.md` / `docs/update.md`.
All talk to the user is in Brazilian Portuguese (see `user-messages-pt-br.md`).

## Boundaries (stay inside these when fixing things)

- **DO NOT** run commands with `sudo` unless the user explicitly approved.
- **DO NOT** modify system files outside `~/.agent-reach/`.
- **DO NOT** install packages that are not listed in this guide.
- **DO NOT** disable firewalls, security settings or system protections.
- **DO NOT** clone repos, create files or run commands inside the agent
  workspace / working directory.
- If something needs elevated permissions, tell the user what is needed and let
  them decide.

## Directory rules

| Purpose | Directory |
|---------|-----------|
| Config & tokens | `~/.agent-reach/` (e.g. `~/.agent-reach/config.json`) |
| Upstream tool repos | `~/.agent-reach/tools/` |
| Temporary files | `/tmp/` |

## Step 1: install the basics

```bash
# Recommended: pipx
pipx install https://github.com/Panniantong/agent-reach/archive/main.zip
agent-reach install --env=auto               # read-only check (default)
# After the user explicitly approves system changes:
agent-reach install --env=auto --system

# If Python comes from Homebrew / PEP 668 (externally-managed-environment), use a venv:
python3 -m venv ~/.agent-reach-venv
source ~/.agent-reach-venv/bin/activate
pip install https://github.com/Panniantong/agent-reach/archive/main.zip
agent-reach install --env=auto
```

Windows: if `python3 --version` opens the Microsoft Store, `python3` is only a
Store alias. Use the Python Launcher instead:

```powershell
py -3 -m venv $env:USERPROFILE\.agent-reach-venv
$env:USERPROFILE\.agent-reach-venv\Scripts\Activate.ps1
python -m pip install https://github.com/Panniantong/agent-reach/archive/main.zip
agent-reach install --env=auto
```

Install modes:

```bash
agent-reach install --env=auto             # check only; safe default
agent-reach install --env=auto --safe      # same check-only behavior (compatibility)
agent-reach install --env=auto --system    # explicitly allow external/system installs
agent-reach install --env=auto --dry-run   # preview what --system would do
```

The default only checks the machine. With explicit `--system` approval it
installs/configures the core pieces (gh CLI, Node.js, mcporter, Exa search,
yt-dlp config) and activates the zero-config channels: Web (Jina Reader),
YouTube, GitHub, RSS, Exa Search, V2EX, Bilibili (basic).

## Step 2: ask which optional channels the user wants

Ask in Portuguese (wording in `user-messages-pt-br.md`), then run:

```bash
agent-reach install --env=auto --system --channels=opencli,xiaohongshu   # desktop user chose XHS
agent-reach install --env=auto --system --channels=facebook,instagram    # desktop Meta channels
agent-reach install --env=local --system --channels=boss                 # desktop Boss直聘
agent-reach install --env=auto --system --channels=all                   # user approved everything
```

Supported channel names: `opencli`, `twitter`, `xiaoyuzhou`, `xueqiu`,
`xiaohongshu`, `reddit`, `facebook`, `instagram`, `bilibili`, `linkedin`, `boss`, `all`.

## Step 3: fix what is broken, then configure what needs the user

Run `agent-reach doctor` and try to get as many channels as possible to ✅,
within the boundaries above. Ask the user only when you genuinely need their
input (credentials, permissions).

**Security tip to give the user (in Portuguese):** for platforms that need
cookies or browser sessions (Twitter, XiaoHongShu, Reddit, Facebook, Instagram,
Boss直聘) recommend a **dedicated/secondary account** instead of the main one:
(1) the platform may detect non-browser calls and restrict/ban the account;
(2) cookies grant full account access, so a secondary account limits the damage
if credentials leak.

### Cookies (Cookie-Editor export)

For platforms whose CLI needs cookies (Twitter, Xueqiu, ...), prefer the
Cookie-Editor import:

1. The user logs in to the platform in their own browser.
2. Install the Cookie-Editor extension:
   https://chromewebstore.google.com/detail/cookie-editor/hlkenndednhfkekhgcdicdfddnkalmdm
3. Click the extension → Export → Header String.
4. The user sends the exported string to you.

Manual alternative (no extension): open the site logged in → F12 → Network tab →
refresh → click any request → Request Headers → copy the whole value after
`Cookie: `.

Hidden-input commands (for non-interactive use pipe the value through stdin and
add `--stdin`; **never** put cookies in process arguments):

```bash
agent-reach configure twitter-cookies
agent-reach configure xhs-cookies
agent-reach configure groq-key
agent-reach configure openai-key
agent-reach configure proxy
agent-reach configure github-token
agent-reach configure youtube-cookies
```

### Twitter/X

```bash
agent-reach configure twitter-cookies
```

Saves `twitter_auth_token` and `twitter_ct0` only for `doctor`'s configuration
check. `doctor` does not run `twitter status` and does not change the current
shell. Before running `twitter search/read/...` you must set, in that process
environment:

```bash
export TWITTER_AUTH_TOKEN="..."
export TWITTER_CT0="..."
twitter search "query" -n 10
```

### Proxy (restricted networks, e.g. mainland China)

twitter-cli and rdt-cli are Python tools and read proxy variables:

1. Make sure the user configured a proxy: `agent-reach configure proxy` (hidden input).
2. `export HTTP_PROXY="..." HTTPS_PROXY="..."` when calling those tools.
3. If the user reports "fetch failed", see the Twitter troubleshooting below.

Most users need no proxy. Server IPs flagged by risk control may need a
residential proxy (e.g. webshare.io, about US$1/month).

### Reddit (login mandatory)

Anonymous endpoints are blocked and the official API needs manual approval.
Desktop: OpenCLI (user logged in to reddit.com in Chrome). Server/legacy: rdt-cli.

```bash
# PyPI lags; install from GitHub (same pinned version as _RDT_GIT_SOURCE in the code)
pipx install 'git+https://github.com/public-clis/rdt-cli.git@5e4fb3720d5c174e976cd425ccc3b879d52cac66'
rdt login   # extracts browser cookies; on a server without a browser write the cookie manually per doctor's hint
```

### XiaoHongShu (multi-backend)

Boundary: Agent Reach does not log in for the user and does not read browser
cookies. OpenCLI uses only an existing user-controlled Chrome session;
`agent-reach configure xhs-cookies` does not inject cookies into OpenCLI or
Chrome. With no existing session, do not log in automatically: use a manual
Cookie-Editor export for xiaohongshu-mcp / the legacy tool. The explicit command
imports the user-provided xiaohongshu.com cookie set (confirm the scope first;
cookies from other domains are ignored).

**Desktop (OpenCLI, recommended):**

```bash
agent-reach install --system --channels opencli
```

Then guide the user through the one manual step (Chrome security prevents
automating it): open
https://chromewebstore.google.com/detail/opencli/ildkmabpimmkaediidaifkhjpohdnifk
→ "Add to Chrome" → run `opencli doctor` (success = `Extension: connected`).

**Server / no desktop (xiaohongshu-mcp):**
1. Download the binary for the platform from https://github.com/xpzouying/xiaohongshu-mcp/releases into `~/.agent-reach/tools/`.
2. Start the service (first run downloads a ~150 MB headless browser; wait for it).
3. Import cookies via the Cookie-Editor flow above.
4. Connect: `mcporter config add xiaohongshu http://localhost:18060/mcp --scope home`
5. Always call with `--timeout 120000`.

**Legacy (xhs-cli):** installed copies keep working as a fallback (upstream
unmaintained since 2026-03, not recommended for new installs); authentication is
still the Cookie-Editor manual export.

### Facebook / Instagram (desktop OpenCLI)

Reuses the user's Chrome login; no passwords stored, no Meta Graph API review.
Servers / no-desktop environments are not recommended.

```bash
agent-reach install --system --channels facebook,instagram
```

Afterwards: confirm the OpenCLI extension passes `opencli doctor`; have the user
log in to facebook.com / instagram.com in Chrome; then call `opencli facebook ...`
/ `opencli instagram ...` (see `social.md`). Facebook Groups only covers the
group list / recent activity visible to the logged-in account. Instagram `search`
is user search, not site-wide post search; on 429/login errors ask the user to
log in again in Chrome and lower the request rate.

### Xueqiu (雪球)

Needs a logged-in cookie. The user logs in to xueqiu.com in Chrome, then:

```bash
agent-reach configure --from-browser chrome --platform xueqiu
```

Reads and stores only the minimal cookie Xueqiu needs; nothing from other platforms.

### Xiaoyuzhou podcast (Groq Whisper)

The script is installed with Agent Reach; the user only supplies a free Groq key:

```bash
agent-reach configure groq-key
```

Getting a Groq key (free, no credit card, ~30 s): open https://console.groq.com →
sign in with Google/GitHub → API Keys → Create API Key → copy the key (starts with `gsk_`).

Usage: when the user sends a Xiaoyuzhou link run
`bash ~/.agent-reach/tools/xiaoyuzhou/transcribe.sh https://www.xiaoyuzhoufm.com/episode/xxxxx`
(downloads audio → transcodes/slices → Groq Whisper → full Chinese transcript).
Limits: about 2 hours of audio per hour (7200 s, then wait 15 min), Whisper
large-v3 quality, no speaker separation; split episodes longer than 2 hours.

### LinkedIn (optional — mcp-server-linkedin)

Basic content is readable through Jina Reader; full features (profile detail,
people/job search) need mcp-server-linkedin. Install `uv` first
(https://docs.astral.sh/uv/getting-started/installation/), then:

```bash
mcporter config add linkedin --command uvx --arg mcp-server-linkedin@latest --env UV_HTTP_TIMEOUT=300 --scope home
uvx mcp-server-linkedin@latest --login     # needs a browser window; the user logs in manually
```

The login is saved to `~/.linkedin-mcp/profile/`. A server without a desktop
needs a visible desktop (e.g. VNC) to run the login command.

### Boss直聘 (desktop only — boss-agent-cli + CDP)

Follow the Boss直聘 section of `career.md` end to end. Short version:
1. Explain (in Portuguese) that you will install an upstream CLI, start a separate Chrome profile, and ask for system-install approval.
2. After approval: `agent-reach install --env=local --system --channels=boss`.
3. Launch the dedicated loopback-only Chrome for the OS (commands in `career.md`).
4. Pause: the user visually confirms login (avatar top right) or logs in / scans / solves sliders themselves. Never ask for or enter credentials.
5. Then `boss --cdp-url http://localhost:9222 login --cdp` and `agent-reach doctor`.

Security: anything that can reach port 9222 fully controls that Chrome — bind to
`127.0.0.1` only; reuse the dedicated profile; close it when idle. Servers /
no-desktop environments are not supported.

## Step 4: final check

Run `agent-reach doctor` once more and report the result to the user in Portuguese.

## Updating

```bash
agent-reach check-update
pip install --upgrade https://github.com/Panniantong/agent-reach/archive/main.zip
# if PEP 668 complains: pipx install --force https://github.com/Panniantong/agent-reach/archive/main.zip
#                       or activate ~/.agent-reach-venv first
agent-reach doctor
```

Only upgrade tools that are already installed; do not install tools the user
never asked for (single exception: OpenCLI on desktop). The full upstream update
runbook is https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/update.md —
fetch it when the user asks for a complete update and follow it.

## Scheduled monitoring (OpenClaw only)

If running inside OpenClaw, offer (in Portuguese) a daily check. If the user
agrees, create a daily cron job (`sessionTarget: "isolated"`, `delivery: "announce"`)
whose task is: run `agent-reach watch`; if the output says everything is OK,
finish silently; if it shows problems (❌ ⚠️) or a new version (🆕), send the full
report to the user in Portuguese with suggested fixes and ask whether to upgrade.

## Twitter troubleshooting (twitter-cli connection failures)

Cause: twitter-cli needs `TWITTER_AUTH_TOKEN` and `TWITTER_CT0` in the process
environment; a network that needs a proxy to reach x.com also needs one set.

1. Environment variables + proxy:
   ```bash
   export TWITTER_AUTH_TOKEN="..."
   export TWITTER_CT0="..."
   export HTTP_PROXY="http://user:pass@host:port"
   export HTTPS_PROXY="http://user:pass@host:port"
   twitter search "test" -n 1
   ```
2. Global proxy tool (ClashX/Surge "enhanced mode" on macOS; proxychains/tun2socks on Linux): `proxychains twitter search "test" -n 1`
3. Drop twitter-cli and use Exa: `mcporter call exa.web_search_exa query="site:x.com search terms" numResults=5`
4. Check auth: `twitter check` ("Missing credentials" = set the variables in that process). An installed bird CLI (`npm install -g @steipete/bird`) also works as a fallback.

## Xueqiu HTTP 400 in doctor

Xueqiu's API needs a login cookie. Ask the user to log in to xueqiu.com in Chrome,
run `agent-reach configure --from-browser chrome --platform xueqiu`, then
`agent-reach doctor` again. Re-run when the cookie expires.
