# Career / recruiting

LinkedIn, Boss直聘 (BOSS Zhipin, Chinese job platform).

## LinkedIn

```bash
# Get a profile
mcporter call linkedin.get_person_profile linkedin_username="username" sections="experience,education"

# Search people
mcporter call linkedin.search_people keywords="AI engineer" location="Sao Paulo"

# Get a company profile
mcporter call linkedin.get_company_profile company_name="openai" sections="posts,jobs"

# Search jobs
mcporter call linkedin.search_jobs keywords="software engineer" location="Remote" max_pages=2
```

> **Login required**: before first use run `uvx mcp-server-linkedin@latest --login`
> to save a valid login state.

### Fallback

If the MCP server is unavailable, use Jina Reader:

```bash
curl -s "https://r.jina.ai/https://linkedin.com/in/username"
```

## Boss直聘

When the user asks to set up Boss直聘, follow this section for installation,
launching the dedicated Chrome, waiting for the user's manual login, and the
final verification. Do not dump implementation details such as port 9222 on the
user, and never type credentials, scan QR codes or solve sliders on their behalf.
Search content is in Chinese: present results to the user in Portuguese.

> **Key distinction: login gate ≠ anti-bot security check.** After landing on
> zhipin.com the browser may sit on three kinds of page: the logged-in
> `web/geek/job`, the logged-out `web/user/` (QR / phone login), and the
> anti-bot **security-check page** (URL contains `security-check` /
> `zhipin-security` / `_security_check`). The security-check page is unrelated to
> login: **it also appears when logged in** (almost always with a CDP-debug
> Chrome). Never judge login state from the current page URL.

> **Two login-state stores (in strict `existing-browser` CDP mode the browser is
> the source of truth).** Two credential stores exist; **neither may be deleted**,
> but they authenticate different channels:
>
> | Store | Role |
> |---|---|
> | `~/.boss-agent/auth/session.enc` | (1) Hard gate: `_get_browser()` calls `get_token()` unconditionally; if it cannot be read it raises `AuthRequired`, so CDP search fails before even connecting to the browser. (2) It is **not** the credential used by search: when CDP reuses the real Chrome's `contexts[0]`, its cookies are injected only in the "no context" branch and never actually take effect. (3) The httpx channel (low-risk ops: `status` / `detail` / `cities` / `job_card_httpx`) really uses its cookies + stoken, and the code-37 `force_refresh()` writes back to it. |
> | Browser cookies inside the dedicated Chrome profile | The credential that high-risk ops such as search/greet actually carry in CDP mode. |
>
> **`boss status` / `status --live` only validate session.enc** — even when they
> report `logged_in: true`, that does not mean the CDP browser is logged in.
> Therefore:
> 1. After launching the dedicated Chrome, the first step is to **pause and have
>    the user visually confirm** the window is logged in (avatar at the top
>    right); only then may you search.
> 2. The boss row of `agent-reach doctor` probes the browser for a `wt2` cookie
>    directly — treat that as authoritative.
> 3. **`AUTH_EXPIRED` is ground truth**: if search reports it, go straight to the
>    login runbook (user logs in inside the dedicated window → `login --cdp`) and
>    never reinterpret it as a "security check". A `_security_check` page is
>    treated as a slider challenge only when `AUTH_EXPIRED` is absent.
> 4. Do not delete session.enc "to clean old credentials"; refresh it by running
>    `login --cdp`.

> **Dependency status**: the required public strict-CDP API comes from
> boss-agent-cli follow-up split PRs #403–#407 (#402/#382 were split at the
> maintainer's request), all merged upstream into master. The Agent Reach
> installer pins the upstream commit
> `4c991b77086a203173bf08a4cb64a23af6514fe6` rather than a moving branch; once
> upstream cuts a release, the installer should return to a version constraint.

Health check (no side effects, no search):

```bash
agent-reach doctor          # boss row: off = not installed or CDP unreachable; warn = pipeline ready,
                            # the message says whether the browser holds a wt2 login cookie (browser is authoritative)
```

Search + JD use the public API (`browser_source` / `job_card_browser` /
`JobItem.lid`). Because pipx/uv tool environments are isolated, plain `python`
may not be able to import the installed tool; use `uv run --with` so the script
and the pinned dependency share one interpreter environment:

```bash
uv run --isolated --no-project \
  --with 'git+https://github.com/can4hou6joeng4/boss-agent-cli.git@4c991b77086a203173bf08a4cb64a23af6514fe6' \
  python - <<'PY'
from pathlib import Path

from boss_agent_cli.api.client import AccountRiskError, BossClient, EnvironmentRiskError
from boss_agent_cli.auth.manager import AuthManager
from boss_agent_cli.platforms.zhipin import BossPlatform

auth = AuthManager(Path.home() / ".boss-agent")

# Strict CDP mode: reuse the logged-in browser, raise immediately on CDP failure, never headless
with BossClient(
    auth,
    cdp_url="http://localhost:9222",
    browser_source="existing-browser",
) as boss:
    raw = boss.search_jobs("大模型", city="深圳", page=1)
    if raw.get("code") != 0:
        code, message = BossPlatform(boss).parse_error(raw)
        raise RuntimeError(f"{code}: {message}")
    items = raw.get("zpData", {}).get("jobList", [])
    for item in items:
        card = boss.job_card_browser(item["securityId"], item["lid"])
        post_desc = card.get("zpData", {}).get("jobCard", {}).get(
            "postDescription", ""
        )
        print(item.get("jobName"), post_desc)

# AccountRiskError / EnvironmentRiskError → stop immediately, no automatic retry;
# a code 37 that explicitly means token/stoken expired is refreshed and retried at most once by BossClient.
PY
```

### Environment check and recovery (mandatory before scraping)

If `agent-reach doctor` reports boss as `off` or `warn` before a search, follow
this runbook instead of reading source code and guessing:

1. **Is the CDP port reachable?**
   ```bash
   curl -s http://localhost:9222/json/version   # a Browser field = port reachable
   ```

2. **Debug Chrome not running / closed**: launch the dedicated Chrome for the OS
   (its login state is independent and does not pollute the daily browser):
   ```bash
   # macOS
   open -na "Google Chrome" --args --remote-debugging-address=127.0.0.1 \
     --remote-debugging-port=9222 --user-data-dir="$HOME/.boss-chrome-profile" \
     "https://www.zhipin.com/web/geek/job"

   # Linux
   google-chrome --remote-debugging-address=127.0.0.1 \
     --remote-debugging-port=9222 --user-data-dir="$HOME/.boss-chrome-profile" \
     "https://www.zhipin.com/web/geek/job"
   ```

   Windows PowerShell:
   ```powershell
   Start-Process chrome.exe -ArgumentList '--remote-debugging-address=127.0.0.1','--remote-debugging-port=9222',"--user-data-dir=$env:USERPROFILE\.boss-chrome-profile",'https://www.zhipin.com/web/geek/job'
   ```

   Bind to the loopback address only. Any process that can reach 9222 has full
   control of this Chrome; never listen on a public interface. Reuse this
   dedicated profile long-term to keep a stable login; do not delete or recreate
   it on each run and do not switch to the daily main Chrome by default. Close
   the dedicated window when not in use.

   **First step after launching: pause and have the user visually confirm the
   window is logged in (avatar at the top right).** Do not substitute
   `boss status` — it only validates the local session.enc, not the browser.

3. **User logs in manually (when the browser is logged out)**: the verdict comes
   from doctor's browser-cookie probe (no wt2 = browser logged out), then from
   the user's visual confirmation; `boss status` is reference only. Ask the user
   to log in or scan the QR code in this dedicated window. Once they confirm,
   save the CDP login state:
   ```bash
   boss --cdp-url http://localhost:9222 login --cdp
   ```

   If the window sits on a security-check page (`security-check` /
   `zhipin-security`), that is an anti-bot challenge, not a login page: wait for
   it to clear automatically or ask the user to pass the slider manually; do not
   treat it as "logged out" and re-run the QR login.

4. **Is the login state valid?** (browser cookie probe + stoken expiry):
   ```bash
   agent-reach doctor     # read the browser wt2 cookie probe result in the boss row message
   boss status            # reflects only local session.enc; reference only
   ```

5. **Error-code handling** (during search / JD fetch):
   - `AUTH_EXPIRED` (user not logged in) → **ground truth**: the CDP browser is
     logged out (regardless of what `boss status` says); go straight to step 3
     (login flow + `login --cdp`); never interpret it as a "security check";
   - code 36 (ACCOUNT_RISK) → stop immediately; the user must handle it
     manually on the BOSS site; never auto-retry;
   - code 9 (RATE_LIMITED) → cool down, then retry;
   - code 37 + `环境存在异常` → `ENVIRONMENT_RISK`: stop immediately, do not
     refresh the token, do not log in again, do not auto-retry;
   - only a code 37 whose message clearly says token/stoken expired is
     `TOKEN_REFRESH_FAILED`; the client refreshes and retries at most once
     automatically; if it still fails, log in again.

When the user asks you to start searching, you must specify strict CDP mode
(global options go before the subcommand):

```bash
boss --browser-source existing-browser --cdp-url http://localhost:9222 search "大模型" --city 广州 --page 1
```

Do not page through results continuously without being asked. boss-agent-cli
PR #383 adds a persistent 5–10 second list budget for ordinary searches across
CLI processes; until that PR is merged and released, still throttle proactively
and call serially.

> **Waiting is expected, not a hang**: when consecutive searches hit throttling,
> boss-agent-cli silently waits 5–10 seconds (on a TTY it shows a "throttle
> waiting Ns…" hint; Agent Reach invokes it with `--json`, so you will not see
> the hint). During the wait window do not retry, do not launch a new browser,
> do not switch profile.
