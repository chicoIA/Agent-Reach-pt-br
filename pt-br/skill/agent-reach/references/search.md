# Search tools

Exa AI search engine.

## Exa AI search

High-quality AI search engine, good for technical docs, official examples and related web pages.

```bash
mcporter call exa.web_search_exa query="query" numResults=5
mcporter call exa.web_search_exa query="library API code example" numResults=5
```

### Use cases

| Scenario | Parameters |
|-----|------|
| Web search | `web_search_exa(query: "...", numResults: 5)` |
| Technical / code material | `web_search_exa(query: "framework name API example", numResults: 5)` |

> The Exa MCP tool `get_code_context_exa` is deprecated and not registered by
> default. Use `web_search_exa` for code questions too; for exact repository
> content search, use the GitHub search in `dev.md` instead.

### Characteristics

- Strong on English content and technical docs
- Query wording can target official docs and code examples
- High result quality

## Comparison with other search tools

| Tool | Source | Best for |
|-----|------|---------|
| Exa | agent-reach | English / technical / code search |
| Zhipu search | my-mcp-tools | Chinese-language search |
| GitHub search | agent-reach (dev.md) | Repository / code search |
