# Web reading

Generic web pages and RSS.

## Generic web pages (Jina Reader)

```bash
# Read any web page
curl -s "https://r.jina.ai/URL"

# Example
curl -s "https://r.jina.ai/https://example.com/article"
```

**Use for**: most web pages can be read directly with Jina Reader.

## Web Reader (MCP)

```bash
# Read page content (Markdown)
mcporter call web-reader.webReader url="https://example.com"

# Keep images
mcporter call web-reader.webReader url="https://example.com" retain_images=true

# Plain-text format
mcporter call web-reader.webReader url="https://example.com" return_format="text"
```

**Use for**: when you need finer control over the output format.

## RSS (feedparser)

```python
python3 -c "
import feedparser
for e in feedparser.parse('FEED_URL').entries[:5]:
    print(f'{e.title} — {e.link}')
"
```

**Use for**: blogs, news sources, podcasts and other RSS/Atom feeds.

## Selection guide

| Scenario | Recommended tool |
|-----|---------|
| Generic web page | Jina Reader (`curl r.jina.ai`) |
| Need images / format control | web-reader MCP |
| RSS subscription | feedparser |
