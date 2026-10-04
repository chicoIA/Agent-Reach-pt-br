# Social media & communities

XiaoHongShu, Twitter/X, Bilibili, V2EX, Reddit, Facebook, Instagram.

## XiaoHongShu / 小红书 (multi-backend)

XiaoHongShu has three backends. **Run `agent-reach doctor --json` first and read
xiaohongshu's `active_backend`**, then use the matching command group.

### Backend A: OpenCLI (desktop first choice)

```bash
# Search notes
opencli xiaohongshu search "query" -f yaml

# Read note body + engagement (use the full URL from search results, incl. xsec_token)
opencli xiaohongshu note "NOTE_URL" -f yaml

# Comments (nested replies supported)
opencli xiaohongshu comments NOTE_ID -f yaml

# Home recommendation feed
opencli xiaohongshu feed -f yaml

# A user's public notes
opencli xiaohongshu user USER_ID -f yaml
```

> Requires Chrome open with the OpenCLI extension. OpenCLI uses only a Chrome
> session that already exists and that the user explicitly controls; Agent Reach
> does not log in for the user and does not read browser cookies.
> `agent-reach configure xhs-cookies` does NOT inject cookies into OpenCLI.
> If there is no existing session, do not log in automatically; use backend B/C
> and configure it through the manual Cookie-Editor export flow.

### Backend B: xiaohongshu-mcp (server scenario)

```bash
# Before authenticating, have the user export cookies manually with Cookie-Editor, then import explicitly
agent-reach configure xhs-cookies

# Read-only status check
mcporter call xiaohongshu.check_login_status --timeout 120000

# Search
mcporter call xiaohongshu.search_feeds keyword="query" --timeout 120000

# Note detail + comments (feed_id and xsec_token come from the search results)
mcporter call xiaohongshu.get_feed_detail feed_id="..." xsec_token="..." --timeout 120000
```

> The first call automatically downloads a ~150 MB headless browser, so always
> pass `--timeout 120000`.
> Authentication is by manual Cookie-Editor export only; run `check_login_status`
> right after importing.
> The explicit command saves/imports the cookie set of the xiaohongshu.com domain
> that the user provides — have the user confirm the scope. Cookies from other
> domains are ignored.

### Backend C: xhs-cli (legacy fallback, upstream unmaintained since 2026-03)

```bash
xhs search "query"          # search
xhs read NOTE_ID_OR_URL     # read a note (must use the URL/ID from search results, not a bare note_id)
xhs comments NOTE_ID_OR_URL # comments
xhs hot                     # trending
xhs feed                    # recommendations
```

> Known unstable: `xhs user` / `xhs user-posts` / `xhs favorites` may return API
> errors (upstream unmaintained, nobody fixes them). New installs should go
> straight to backend A/B.

### General notes

> **Authentication boundary**: Agent Reach must not log in to XiaoHongShu for the
> user and must not read browser cookies. OpenCLI may only use a Chrome session
> that the user already has and explicitly controls; xiaohongshu-mcp / legacy
> tools use a manual Cookie-Editor export.
>
> **xsec_token restriction**: XiaoHongShu enforces an xsec_token mechanism, so you
> **cannot read a bare note_id directly**. Correct flow: search/feed first, then
> read using the full URL/ID from the results. Same for all three backends.
>
> **Rate control**: high-frequency requests (bulk search, deep comment paging)
> trigger CAPTCHAs; this platform limit cannot be bypassed. Wait 2–3 seconds
> between operations.
>
> **Write operations (post/comment/like)**: read-only is recommended. xhs-cli
> v0.6.x writes may return 406 due to signing problems.
>
> The content is in Chinese: present findings to the user in Portuguese.

## Twitter/X (twitter-cli)

### Authentication prerequisites

Cookies saved through hidden input by `agent-reach configure twitter-cookies` are
used only by `agent-reach doctor` to check that explicit credentials are
complete. `doctor` does not run the upstream `twitter status` and does not
configure the current shell. Before running any `twitter` command below, you must
explicitly provide these in the same shell or child-process environment (never
print the values):

```bash
export TWITTER_AUTH_TOKEN="..."
export TWITTER_CT0="..."
```

### Stable commands

```bash
# Home timeline (most stable)
twitter feed -n 20

# Read one tweet (with replies)
twitter tweet URL_OR_ID

# Read a long post / X Article
twitter article URL_OR_ID

# A user's timeline
twitter user-posts @username -n 20

# User profile
twitter user @username
```

### Possibly unstable commands

```bash
# Search tweets (Twitter changes GraphQL endpoints often; may 404)
twitter search "query" -n 10

# likes (since 2024 you can only see your own — platform restriction)
twitter likes
```

### Retry chain when `search` fails (in order; stop at first success)

1. Retry once directly (intermittent failures are common): `twitter search "query" -n 10`
2. Upgrade, then retry: `pipx upgrade twitter-cli && twitter search "query" -n 10`
3. Switch to the OpenCLI alternative (desktop, reuses browser login state): `opencli twitter search "query" -f yaml`
4. If all fail, work around it with stable commands such as `twitter feed` / `twitter user-posts @somebody`

### Important notes

> **Install**: `pipx install twitter-cli` (make sure v0.8.5+)
>
> **Auth**: Cookie-Editor manual export only, then set the environment variables
> `TWITTER_AUTH_TOKEN` + `TWITTER_CT0` explicitly; do not rely on automatic
> browser reading.
>
> **IP risk control**: do not call frequently from VPS/data-center IPs,
> especially followers/following — there is a risk of account suspension. Use a
> residential proxy or the local machine.
>
> **OpenCLI alternative**: if OpenCLI is installed on the desktop,
> `opencli twitter search/article/user-posts -f yaml` is fully usable (browser
> login state, no cookie environment variables needed).
>
> **Output format**: prefer `--yaml` or `--json` for structured output that suits
> AI agents.

## Bilibili

> ⚠️ **Do not use yt-dlp for Bilibili** (risk control returns 412 everywhere; no
> workaround). Use bili-cli / OpenCLI.

```bash
# Search / trending / video detail (bili-cli, read-only, no login)
bili search "query" --type video -n 5
bili hot -n 10
bili video BVxxx

# Subtitles (OpenCLI, needs desktop Chrome)
opencli bilibili subtitle BVxxx
```

> Detailed commands (audio transcription, direct-API fallback) are in [video.md](video.md).

## V2EX (public API)

No authentication needed; call the public API directly.

### Hot topics

```bash
curl -s "https://www.v2ex.com/api/topics/hot.json" -H "User-Agent: agent-reach/1.0"
```

### Node topics

```bash
# node_name e.g.: python, tech, jobs, qna, programmers
curl -s "https://www.v2ex.com/api/topics/show.json?node_name=python&page=1" -H "User-Agent: agent-reach/1.0"
```

### Topic detail

```bash
# topic_id comes from the URL, e.g. https://www.v2ex.com/t/1234567
curl -s "https://www.v2ex.com/api/topics/show.json?id=TOPIC_ID" -H "User-Agent: agent-reach/1.0"
```

### Topic replies

```bash
curl -s "https://www.v2ex.com/api/replies/show.json?topic_id=TOPIC_ID&page=1" -H "User-Agent: agent-reach/1.0"
```

### User info

```bash
curl -s "https://www.v2ex.com/api/members/show.json?username=USERNAME" -H "User-Agent: agent-reach/1.0"
```

### Python example

```python
from agent_reach.channels.v2ex import V2EXChannel

ch = V2EXChannel()

# Hot topics
topics = ch.get_hot_topics(limit=10)
for t in topics:
    print(f"[{t['node_title']}] {t['title']} ({t['replies']} replies)")

# Topics of a node
node_topics = ch.get_node_topics("python", limit=5)

# Topic detail + replies
topic = ch.get_topic(1234567)
print(topic["title"], "—", topic["author"])

# User info
user = ch.get_user("Livid")
```

> **Node list**: https://www.v2ex.com/planes

## Reddit (multi-backend, login required)

**Reddit has no zero-config path**: anonymous `.json` endpoints are blocked (403)
and the official API has been manual-approval-only (and almost never approved)
since 2025-11. Both backends rely on a logged-in session — run
`agent-reach doctor --json` first and read reddit's `active_backend`. Access from
mainland China needs a proxy.

### Backend A: OpenCLI (desktop first choice, reuses the browser session)

```bash
# Search posts
opencli reddit search "query" -f yaml

# Read a post's full text + comments
opencli reddit read POST_ID -f yaml

# Browse a subreddit / hot / Popular
opencli reddit subreddit LocalLLaMA -f yaml
opencli reddit hot -f yaml
opencli reddit popular -f yaml

# Subreddit metadata (subscribers, description)
opencli reddit subreddit-info LocalLLaMA -f yaml
```

> Requires Chrome open and logged in to reddit.com in the browser.

### Backend B: rdt-cli (legacy/server fallback, upstream unmaintained since 2026-03)

```bash
rdt search "query" --limit 10   # search posts
rdt read POST_ID                # read a post's full text + comments
rdt sub python --limit 20       # browse a subreddit
rdt popular --limit 10          # browse popular
rdt all --limit 10              # browse /r/all
```

> **Install**: `pipx install 'git+https://github.com/public-clis/rdt-cli.git'`
> (the PyPI release lags; install v0.4.2+ from GitHub). Run `rdt login` first to
> search and read (on a server without a browser, write the cookie manually —
> follow doctor's hint).
> Prefer `--yaml` output, friendlier to AI agents.

### Advanced option: official API + PRAW (only for users who already have credentials)

Users who registered a Reddit script app before 2025-11 (holding client_id /
client_secret) can use PRAW against the official API (100 QPM free). New
applications need manual approval and personal projects are almost never
approved — **do not recommend this route to new users**.

## Facebook (OpenCLI, login required)

Facebook goes through OpenCLI, reusing the user's facebook.com login in Chrome.
Run `agent-reach doctor --json` first and read facebook's `active_backend`; it
should normally be `OpenCLI`. Do not recommend Jina/Exa/Graph API as the default path.

```bash
# Search users / pages / posts
opencli facebook search "query" -f yaml

# User or page info
opencli facebook profile zuck -f yaml

# Current account's News Feed
opencli facebook feed --limit 10 -f yaml

# Groups visible to the current account / recent activity
opencli facebook groups --limit 20 -f yaml
```

> Requires Chrome open with the OpenCLI extension and a logged-in facebook.com.
> Facebook Groups currently only promises reading the list of groups visible to
> the current account / recent activity, not arbitrary group posts and comments.

## Instagram (OpenCLI, login required)

Instagram goes through OpenCLI, reusing the user's instagram.com login in Chrome.
Run `agent-reach doctor --json` first and read instagram's `active_backend`; it
should normally be `OpenCLI`. Do not restore instaloader by default; historically
its cookies/401/429 behavior was unstable.

```bash
# Search users (NOT a site-wide post keyword search)
opencli instagram search "query" -f yaml

# User profile
opencli instagram profile nasa -f yaml

# A user's recent posts
opencli instagram user nasa --limit 12 -f yaml

# Explore / Discover
opencli instagram explore --limit 20 -f yaml

# Current account's saved items
opencli instagram saved --limit 20 -f yaml
```

> Requires Chrome open with the OpenCLI extension and a logged-in instagram.com.
> `instagram search` is a user search; to read posts, determine the username
> first, then use `instagram user USERNAME`. On 429 / login required, ask the
> user (in Portuguese) to log in again in Chrome and lower the request rate.
