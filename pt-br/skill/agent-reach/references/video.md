# Video / podcast

Subtitles and transcripts for YouTube, Bilibili and Xiaoyuzhou podcasts.

## YouTube (yt-dlp)

### Video metadata

```bash
yt-dlp --dump-json "URL"
```

### Download subtitles

```bash
# Download subtitles (no video)
yt-dlp --write-sub --write-auto-sub --sub-lang "zh-Hans,zh,en" --skip-download -o "/tmp/%(id)s" "URL"

# Then read the .vtt file
cat /tmp/VIDEO_ID.*.vtt
```

For Portuguese-speaking users you may add `pt,pt-BR` to `--sub-lang`
(e.g. `--sub-lang "pt,pt-BR,en,zh-Hans"`).

### Comments

```bash
# Extract comments (best-effort, not guaranteed complete)
yt-dlp --write-comments --skip-download --write-info-json \
  --extractor-args "youtube:max_comments=20" \
  -o "/tmp/%(id)s" "URL"
# Comments are in the `comments` field of the .info.json
```

### Search videos

```bash
yt-dlp --dump-json "ytsearch5:query"
```

> **Subtitle note**: manually uploaded subtitles extract reliably; auto-generated
> subtitles may contain duplicated lines and need post-processing.
> **Comment note**: `--write-comments` scrapes the web page (not the YouTube Data
> API), so some comments may be missing.

### Retry chain when subtitles fail (in order; stop once you have substantive content)

`doctor` only confirms that yt-dlp itself and a JS runtime can execute; it never
requests a specific video. `active_backend: yt-dlp` therefore does not mean the
target video's subtitles passed a live check.

1. Run the `yt-dlp --write-sub --write-auto-sub` command above first.
2. If you get a bot check, an empty subtitle response, or no subtitle file is
   produced, and OpenCLI is connected: `opencli youtube transcript "URL" -f yaml`.
3. If OpenCLI returns `Caption URL returned empty response`, retry up to 3 times;
   this is an intermittent expiry of the time-limited caption URL. Never read an
   empty response as "the video has no subtitles".
4. Still failing, or the video really has no subtitles: `agent-reach transcribe "URL"`
   (downloads the audio and transcribes it).

Success criterion: you actually obtained non-empty subtitle/transcript content —
not an exit code and not doctor's version probe.

### No-subtitle fallback: Whisper audio transcription

```bash
# Fallback when a video has no subtitles: download audio and transcribe with Whisper (a free Groq key is enough)
agent-reach transcribe "https://www.youtube.com/watch?v=VIDEO_ID"
agent-reach transcribe ./local_audio.mp3 -o /tmp/transcript.txt
```

> `agent-reach transcribe` accepts only public http(s) URLs or local audio files.
> When searching with `ytsearch5:`, pick a specific video URL from the yt-dlp
> results first, then transcribe it.
> A key must be configured first: `agent-reach configure groq-key` (hidden input;
> free, console.groq.com) or `agent-reach configure openai-key`. The default auto
> mode uses only the first configured provider (Groq first, otherwise OpenAI) and
> stops on failure; it never sends the audio to a second provider on its own.
> `--allow-provider-fallback` explicitly authorizes cross-provider fallback: the
> same audio could be processed by both Groq and OpenAI and may incur OpenAI
> cost. Use it only after confirming (with the user) that the content may be
> shared with both.

## Bilibili (bili-cli first, OpenCLI for subtitles)

> ⚠️ **Do not use yt-dlp for Bilibili**: Bilibili's risk control now blocks yt-dlp
> with HTTP 412 everywhere (latest version, direct/proxy/with cookies — all
> verified to fail). Use yt-dlp for YouTube only.

### Video detail / search / hot / ranking (bili-cli, read-only, no login)

```bash
# Video detail (title / uploader / duration / play+engagement stats / subtitle availability)
bili video BVxxx

# Search videos
bili search "query" --type video -n 5

# Trending videos / rankings
bili hot -n 10
bili rank -n 10

# Download audio and split into ASR-ready WAV (pair with agent-reach transcribe when there are no subtitles)
bili audio BVxxx
```

### Subtitles (OpenCLI, needs desktop Chrome)

```bash
# Subtitles line by line with timestamps
opencli bilibili subtitle BVxxx

# OpenCLI can also search / read video metadata (alternative)
opencli bilibili search "query" -f yaml
opencli bilibili video BVxxx -f yaml
```

### Zero-config fallback: search API direct

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
curl -s -c /tmp/bili_ck.txt -o /dev/null -A "$UA" "https://www.bilibili.com/"
curl -s -b /tmp/bili_ck.txt -A "$UA" -e "https://www.bilibili.com/" \
  "https://api.bilibili.com/x/web-interface/search/all/v2?keyword=QUERY&page=1"
```

> **Installing bili-cli**: `pipx install bilibili-cli` (upstream stopped updating
> in 2026-03 but is verified healthy; read-only use needs no login. `bili login`
> by QR unlocks personal features such as feed/favorites).

## Xiaoyuzhou podcast (小宇宙)

### Transcribe one episode (optional `--polish` for better punctuation)

```bash
# Writes a Markdown file to /tmp/. --polish lets Llama 3.3 70B add Chinese punctuation + sensible paragraphing
~/.agent-reach/tools/xiaoyuzhou/transcribe.sh --polish "https://www.xiaoyuzhoufm.com/episode/EPISODE_ID"
```

> The transcription prompt already asks Whisper for Chinese punctuation. If the
> result is still poor, add `--polish` to use the free Llama 3.3 70B on Groq for
> punctuation + paragraphing (about +7 s for a 9-minute episode). It costs one
> extra LLM call per transcription, so use it on demand.
> The transcript is in Chinese: summarize/translate it into Portuguese for the user.

### Prerequisites

1. **ffmpeg**: `brew install ffmpeg`
2. **Groq API key** (free): https://console.groq.com/keys
3. **Configure the key**: `agent-reach configure groq-key` (hidden input)
4. **First run**: `agent-reach install --env=auto --system --channels=xiaoyuzhou` (requires the user's explicit approval)

### Check status

```bash
agent-reach doctor
```

> Output Markdown files are saved to `/tmp/` by default.

## Selection guide

| Scenario | Recommended tool |
|-----|---------|
| YouTube subtitles | yt-dlp; on failure OpenCLI (max 3 tries) → agent-reach transcribe |
| Bilibili video detail / search | bili-cli |
| Bilibili subtitles | opencli bilibili subtitle |
| Podcast transcript | Xiaoyuzhou transcribe.sh |
| Audio/video without subtitles | agent-reach transcribe (Bilibili audio: `bili audio` first) |
