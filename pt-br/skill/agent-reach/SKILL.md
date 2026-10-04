---
name: agent-reach
description: >
  MUST USE when the user wants to research / search / look up / find anything on
  the internet. Typical requests (Portuguese or English): "pesquise sobre X",
  "faça uma pesquisa completa sobre X", "procure X na internet", "o que estão
  falando sobre X", "veja o que as pessoas acham de X", "busque X", "research
  this topic", "look this up".

  Also MUST USE when the user mentions any platform or shares any URL/link:
  Twitter/X, Reddit, Facebook, Instagram, YouTube, GitHub, Bilibili,
  XiaoHongShu (小红书), Xiaoyuzhou podcast (小宇宙), LinkedIn, Boss直聘 / job
  search / recruiting ("vagas", "emprego"), V2EX, Xueqiu (雪球 / stock quotes),
  RSS feeds, or any web page.

  16 platforms, multi-backend routing (OpenCLI / per-platform CLIs / APIs).
  Zero config for 6 channels. Run `agent-reach doctor --json` to see which
  backend serves each platform right now.

  NOT for: writing reports / analysis / translation (this skill only FETCHES
  internet content); posting, commenting or liking (write operations);
  platforms that already have a dedicated skill installed (prefer that skill).

  Routing: this file holds the routing table and the common commands. For
  complex cases read the matching references/*.md category file.
metadata:
  homepage: https://github.com/Panniantong/Agent-Reach
  edition: pt-BR (agent instructions in English, user-facing text in Brazilian Portuguese)
---

# Agent Reach — internet capability router (pt-BR edition)

16 platforms, multiple backends each. **When this skill exists, use it for
these platforms — do not invent your own approach.**

## Language policy (read first, applies for the whole session)

- **Everything the user sees MUST be in Brazilian Portuguese (pt-BR):** status
  messages, questions, approval requests, step-by-step instructions you give the
  user, error explanations, summaries, final reports, and the update notice.
- **Everything addressed to you (this skill and `references/`) is in English.**
  Do not translate or paraphrase commands, flags, JSON keys, file paths, URLs,
  error codes (`AUTH_EXPIRED`, `ENVIRONMENT_RISK`, ...) or tool names — keep them
  verbatim, including inside Portuguese sentences.
- Content fetched from the internet (tweets, posts, subtitles, pages) keeps its
  original language. When you summarize or quote it for the user, write the
  summary in Portuguese and, if useful, keep short original-language quotes next
  to a Portuguese translation. Say clearly when something is a translation.
- Platform names stay as the platforms spell them (XiaoHongShu / 小红书,
  Boss直聘, Xueqiu / 雪球). Add a short Portuguese gloss on first mention.
- Ready-made Portuguese wording for the most common interactions (announcing the
  backend, asking for approval, cookie export steps, login confirmation, failure
  reports, update notice) is in [references/user-messages-pt-br.md](references/user-messages-pt-br.md).
  Read it before your first user-facing message.

## Standing rules (apply for the whole session)

1. **Health-check before acting**: for multi-backend / login-backed platforms
   (XiaoHongShu / Reddit / Bilibili / Twitter / Facebook / Instagram / Boss直聘),
   run `agent-reach doctor --json` first. Use a populated `active_backend`;
   `active_backend: null` means Doctor deliberately skipped a live probe to avoid
   browser-cookie reads or remote writes, not that no backend exists. Doctor is a
   point-in-time snapshot: if you suspect the login state or channel has changed,
   re-verify with the matching reference's recovery runbook (e.g. the Boss直聘 CDP
   checks in `career.md`) before running read-only commands. Only run a
   reference's verification command when the user's task requires that platform.
2. **Announce what you use**: before starting, tell the user in Portuguese which
   platform and backend you are using (e.g. "Usando o agent-reach: plataforma
   Reddit via OpenCLI.").
3. **On failure, follow the retry chains in `references/`** — never guess commands.
4. **For broad research tasks**: combine platforms (Exa for web search +
   Twitter/Reddit for discussions + XiaoHongShu/Bilibili for Chinese
   perspectives), collect in parallel, then synthesize in Portuguese.
5. **Watch versions for the user**: after finishing a substantial multi-platform
   task, run `agent-reach check-update` (fast, one API call). If a new version
   exists, append one Portuguese line to your wrap-up (template in
   `references/user-messages-pt-br.md`). Never interrupt the current task to
   update; never nag about the same version twice.
6. **Read-only by default**: this skill fetches content. Do not post, comment,
   like, follow or otherwise write to a platform unless the user explicitly asks
   and the reference says it is supported.
7. **Secrets**: never print, log or echo cookies, tokens or API keys. Prefer
   hidden prompts / `--stdin` (see `references/setup.md`).

## Routing table

| User intent | Category | Details |
|---------|------|---------|
| Web search / code search | search | [references/search.md](references/search.md) |
| XiaoHongShu / Twitter / Bilibili / V2EX / Reddit / Facebook / Instagram | social | [references/social.md](references/social.md) |
| Jobs / LinkedIn / Boss直聘 | career | [references/career.md](references/career.md) |
| GitHub / code | dev | [references/dev.md](references/dev.md) |
| Web pages / articles / RSS | web | [references/web.md](references/web.md) |
| YouTube / Bilibili / podcast transcripts | video | [references/video.md](references/video.md) |
| Xueqiu / stock quotes | finance | [references/finance.md](references/finance.md) |
| Install, update, configure a channel, cookies, proxy | setup | [references/setup.md](references/setup.md) |

## Zero-config quick commands

```bash
# Exa web search
mcporter call exa.web_search_exa query="query" numResults=5

# Read any web page
curl -s "https://r.jina.ai/URL"

# GitHub search
gh search repos "query" --sort stars --limit 10

# YouTube subtitles (never use yt-dlp for Bilibili; retry chain in video.md)
yt-dlp --write-sub --write-auto-sub --skip-download -o "/tmp/%(id)s" "URL"

# V2EX hot topics
curl -s "https://www.v2ex.com/api/topics/hot.json" -H "User-Agent: agent-reach/1.0"

# Bilibili search (bili-cli, no login needed)
bili search "query" --type video -n 5
```

## Login-backed platforms (pick by doctor's `active_backend`)

Twitter boundary: cookies saved by `agent-reach configure twitter-cookies` are
used only by `doctor` to check whether explicit credentials are present.
`doctor` does not run `twitter status` or configure the current shell. Before
calling `twitter` directly, explicitly provide `TWITTER_AUTH_TOKEN` and
`TWITTER_CT0` in the child-process environment without logging their values.

XiaoHongShu boundary: Agent Reach must not log the user in or read browser
cookies. OpenCLI may use only an existing Chrome session explicitly controlled by
the user. If none exists, do not automate login; use a manual Cookie-Editor
export with xiaohongshu-mcp or a legacy tool instead.

```bash
# Twitter search (twitter-cli preferred; retry chain in social.md)
twitter search "query" -n 10

# Reddit (NO zero-config path — OpenCLI or rdt-cli, login required)
opencli reddit search "query" -f yaml   # desktop
rdt search "query" --limit 10            # legacy/server

# XiaoHongShu (desktop prefers OpenCLI)
opencli xiaohongshu search "query" -f yaml

# Facebook / Instagram (desktop OpenCLI, browser session)
opencli facebook search "query" -f yaml
opencli facebook groups -f yaml
opencli instagram search "query" -f yaml       # user search
opencli instagram user USERNAME -f yaml        # recent posts from one user
```

## Environment check

```bash
# Channel availability + which backend serves each platform
agent-reach doctor --json
```

If `agent-reach` is not on PATH, the CLI is not installed yet: follow
`references/setup.md` (ask the user in Portuguese before installing anything).

## Boss直聘 setup trigger

When the user asks to set up Boss直聘 ("configura o Boss直聘", "帮我配 Boss直聘"),
read the Boss section of `references/career.md`. After explicit install approval,
run `agent-reach install --env=local --system --channels=boss`, launch the
dedicated loopback-only Chrome profile for their OS, then **pause and have the
user visually confirm** the window is logged in (avatar at the top right); if
not, have them log in manually. Then verify with
`boss --cdp-url http://localhost:9222 login --cdp` and `agent-reach doctor`. Do
not make the user assemble CDP flags. Keep reusing the dedicated Chrome profile;
do not recreate it for every run or switch to the user's daily profile. Search
with `boss --browser-source existing-browser --cdp-url http://localhost:9222 search ...`.
On `ENVIRONMENT_RISK`, stop without refreshing, relogging, or retrying.

**Do not trust `boss status` for CDP browser login state** — it only validates
the local `~/.boss-agent/auth/session.enc` store, which does not represent the
dedicated Chrome profile's cookies that `existing-browser` searches actually use.
Use the browser `wt2` cookie probe in `agent-reach doctor` plus the user's visual
confirmation. Never judge login state from the page URL: `security-check` /
`zhipin-security` / `_security_check` pages are anti-bot challenges that appear
even when logged in. `AUTH_EXPIRED` from a search is the ground truth for a
logged-out browser — go straight to the login flow + `login --cdp` instead of
interpreting it as a security check.

## Discovering OpenCLI adapters

When the routing table lacks a needed platform or command, run `opencli list`,
then inspect `opencli <platform> --help`. Discovery proves only that an adapter
exists, not that authentication or target content works. Run read-only commands
only when the user's task requires that platform, and require non-empty content.

## Workspace rules

**Never create files in the agent workspace.** Use `/tmp/` for temporary output
and `~/.agent-reach/` for persistent data.

## Detailed references

Read the matching file when you need specifics (the commands above cover the
common cases; references hold per-backend command groups, caveats and retry
chains). All reference files are in English; commands are universal.

- [Search](references/search.md) — Exa AI search
- [Social](references/social.md) — XiaoHongShu, Twitter, Bilibili, V2EX, Reddit, Facebook, Instagram
- [Career](references/career.md) — LinkedIn, Boss直聘
- [Dev](references/dev.md) — GitHub CLI
- [Web](references/web.md) — Jina Reader, RSS
- [Video](references/video.md) — YouTube, Bilibili, Xiaoyuzhou podcast
- [Finance](references/finance.md) — Xueqiu quotes, search and market content
- [Setup](references/setup.md) — install, update, cookies, proxy, per-channel configuration
- [User messages (pt-BR)](references/user-messages-pt-br.md) — Portuguese wording for user-facing interactions
