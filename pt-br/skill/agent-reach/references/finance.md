# Market data

Xueqiu (雪球) stock quotes, search and trending content. Quotes may be delayed;
nothing here is investment advice — say so to the user when presenting prices.

## Check status first

```bash
agent-reach doctor --json
```

When `xueqiu.active_backend` has a value, use that backend; `null` only means
Doctor did not complete a live content check. Xueqiu needs a logged-in session or
a minimal cookie — never treat HTTP 400 as "the stock does not exist".

## OpenCLI (preferred when the desktop Chrome already has a session)

```bash
# Verify the current login state
opencli xueqiu whoami -f yaml

# Stock search and live quotes
opencli xueqiu search "英伟达" -f yaml
opencli xueqiu stock NVDA -f yaml

# Trending posts and trending stocks
opencli xueqiu hot -f yaml
opencli xueqiu hot-stock -f yaml

# List all read-only commands
opencli xueqiu --help
```

OpenCLI only reuses a browser session that already exists and that the user
explicitly controls. Do not run `opencli xueqiu login` automatically. If there is
no session, ask the user (in Portuguese) to log in to xueqiu.com in Chrome, or to
explicitly import the minimal Xueqiu cookie:

```bash
agent-reach configure --from-browser chrome --platform xueqiu
```

This reads and stores only `xq_a_token`; it does not collect cookies of any
other platform.

## Acceptance and failure handling

- Success = a stock name, code, price, or a non-empty content list. Exit code 0
  with empty fields is NOT success.
- HTTP 400 is usually a session/cookie problem, not a missing ticker.
- If `whoami` succeeds but `stock` / `hot` fail, report it as an adapter-parsing
  or platform-API problem; do not misdiagnose it as "not logged in".
