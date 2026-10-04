<h1 align="center">👁️ Agent Reach — edição pt-BR</h1>

<p align="center">
  <strong>Dê ao seu agente de IA acesso à internet inteira com um comando</strong>
</p>

<p align="center">
  O caminho de acesso mais confiável para cada plataforma — escolhido, instalado e diagnosticado para você.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="Licença MIT"></a>
  <a href="https://www.python.org/"><img src="https://img.shields.io/badge/Python-3.10+-green.svg?style=for-the-badge&logo=python&logoColor=white" alt="Python 3.10+"></a>
</p>

<p align="center">
  <a href="#-início-rápido">Início rápido</a> · <a href="pt-br/MANUAL.md">Manual completo</a> · <a href="#-plataformas-suportadas">Plataformas</a> · <a href="docs/README_zh.md">中文</a> · <a href="docs/README_en.md">English</a> · <a href="docs/README_ja.md">日本語</a> · <a href="docs/README_ko.md">한국어</a>
</p>

> Este repositório é um fork em português do
> [Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach).
> A skill fala com o agente em **inglês** (onde os modelos seguem regras com mais
> precisão) e com você em **português do Brasil**.

---

## 📦 Comece por aqui: pasta `pt-br/`

| Arquivo | Para quê |
|---|---|
| [`pt-br/MANUAL.md`](pt-br/MANUAL.md) | Manual completo em português |
| [`pt-br/agent-reach-skill-pt-br.zip`](pt-br/agent-reach-skill-pt-br.zip) | Skill pronta para importar (`agent-reach/SKILL.md` + `references/`) |
| [`pt-br/skill/agent-reach/`](pt-br/skill/agent-reach/) | Fonte da skill (o conteúdo do zip) |
| [`pt-br/build-zip.sh`](pt-br/build-zip.sh) | Regera o zip depois de editar a skill |

---

## Por que o Agent Reach?

Agentes de IA já acessam a internet — mas "conseguir abrir um site" é só o começo.

A informação mais valiosa está espalhada em redes sociais e plataformas de nicho:
discussões no Twitter, opiniões no Reddit, tutoriais no YouTube, atividade no
GitHub… E cada plataforma tem suas barreiras:

| Problema | Realidade |
|---|---|
| API do Twitter | Paga por uso; uso moderado custa ~US$ 215/mês |
| Reddit | IPs de servidor recebem 403 |
| XiaoHongShu | Exige login para navegar |
| Bilibili | Bloqueia IPs de fora da China / de servidor |

Conectar o agente a tudo isso significa achar ferramentas, instalar dependências
e depurar configurações, uma por uma. **O Agent Reach resolve isso com um comando.**

### ✅ Bom saber antes de começar

| | |
|---|---|
| 💰 **Gratuito** | Todas as ferramentas são open source e as APIs são gratuitas. O único custo possível é um proxy (~US$ 1/mês), e só em redes restritas |
| 🔒 **Privacidade** | Cookies ficam na sua máquina. Nada é enviado. Código aberto para auditar |
| 🔄 **Sempre atualizado** | Cada plataforma tem um backend principal e alternativas. Se um caminho morre, o próximo assume |
| 🤖 **Qualquer agente** | Claude Code, Claude.ai, OpenClaw, Cursor, Windsurf… qualquer agente que rode comandos |
| 🩺 **Diagnóstico embutido** | `agent-reach doctor` mostra o que funciona, o que não funciona e como consertar |

---

## 🚀 Início rápido

### 1. Importe a skill em português

**Claude Code:**

```bash
unzip pt-br/agent-reach-skill-pt-br.zip -d ~/.claude/skills/
```

**Claude.ai / Claude Desktop:** *Configurações → Capacidades → Skills → Enviar skill*
e selecione `pt-br/agent-reach-skill-pt-br.zip`.

**OpenClaw e outros:** copie `pt-br/skill/agent-reach/` para a pasta de skills do agente
(ex.: `~/.openclaw/skills/agent-reach/`).

### 2. Peça ao agente para instalar

```
Instale o Agent Reach com segurança, primeiro só verificando o que falta.
```

Ou manualmente:

```bash
pipx install https://github.com/Panniantong/agent-reach/archive/main.zip
agent-reach install --env=auto            # só verifica (padrão seguro)
agent-reach install --env=auto --system   # instala de fato, após sua aprovação
```

> 🛡️ **Seguro por padrão:** `agent-reach install` só verifica a máquina. Alterações
> no sistema exigem `--system`, e o agente sempre pede sua autorização antes.

> ⚠️ **Atenção:** `agent-reach skill --install` e `agent-reach install --system`
> sobrescrevem a skill pela versão original (chinês/inglês). Se usar esses
> comandos, reimporte o zip pt-BR depois.

> ⚠️ **Usuários do OpenClaw:** habilitem a permissão `exec` antes
> (`openclaw config set tools.profile "coding"` e reiniciem o gateway).

---

## 🌐 Plataformas suportadas

| Plataforma | O que faz | Configuração | Observações |
|---|---|:-:|---|
| 🌐 **Web** | Ler | Nenhuma | Qualquer URL → Markdown limpo ([Jina Reader](https://github.com/jina-ai/reader)) |
| 🔍 **Busca na web** | Buscar | Automática | Busca semântica gratuita, sem chave ([Exa](https://exa.ai) via [mcporter](https://github.com/nicobailon/mcporter)) |
| 📦 **GitHub** | Ler · Buscar | Nenhuma | [gh CLI](https://cli.github.com); `gh auth login` libera fork, issues e PRs |
| 📺 **YouTube** | Ler · Buscar | Nenhuma | Legendas e busca ([yt-dlp](https://github.com/yt-dlp/yt-dlp)) |
| 📡 **RSS** | Ler | Nenhuma | Qualquer feed RSS/Atom ([feedparser](https://github.com/kurtmckee/feedparser)) |
| 💻 **V2EX** | Tópicos · Respostas · Usuários | Nenhuma | API pública em JSON |
| 📺 **Bilibili** | Ler · Buscar | Nenhuma | Busca e detalhes via [bili-cli](https://github.com/public-clis/bilibili-cli) (sem login); legendas via [OpenCLI](https://github.com/jackwener/opencli). O yt-dlp é bloqueado (412) pela Bilibili |
| 🐦 **Twitter/X** | Ler · Buscar | Cookie | [twitter-cli](https://github.com/public-clis/twitter-cli); exige `TWITTER_AUTH_TOKEN` e `TWITTER_CT0` no ambiente |
| 📖 **Reddit** | Buscar · Ler | OpenCLI / Cookie | Sem acesso anônimo. Desktop: OpenCLI com sua sessão do navegador; ou [rdt-cli](https://github.com/public-clis/rdt-cli) |
| 📘 **Facebook** | Busca · Perfis · Feed · Grupos | OpenCLI | Só desktop; reaproveita sua sessão do Chrome |
| 📷 **Instagram** | Usuários · Perfis · Posts recentes · Explorar | OpenCLI | Só desktop; reaproveita sua sessão do Chrome |
| 💼 **LinkedIn** | Perfis · Empresas · Vagas | mcp-server-linkedin | Páginas públicas funcionam via Jina Reader |
| 📕 **XiaoHongShu (小红书)** | Ler · Buscar · Comentários | OpenCLI / MCP | OpenCLI usa apenas uma sessão do Chrome já aberta por você; MCP usa exportação manual pelo Cookie-Editor |
| 📈 **Xueqiu (雪球)** | Cotações · Busca · Em alta | Cookie | Bolsa chinesa |
| 🎙️ **Xiaoyuzhou (小宇宙)** | Transcrição | Chave Groq gratuita | Podcast → texto com Whisper |
| 🎯 **Boss直聘** | Vagas · Descrições | Chrome dedicado | Login sempre feito por você |

---

## 💬 Uso no dia a dia

Peça em português — o agente lê a skill e sabe o que chamar:

- "Leia este link e me resuma: https://…" → `curl https://r.jina.ai/URL`
- "Do que fala este vídeo?" → `yt-dlp` para as legendas
- "Busque no GitHub frameworks de LLM" → `gh search repos "LLM framework"`
- "Leia este tweet" → `twitter tweet URL` (com `TWITTER_AUTH_TOKEN` / `TWITTER_CT0` definidos)
- "Pesquise o que estão falando sobre X no Reddit e no Twitter" → combina plataformas e resume em português

O agente sempre avisa o que está usando, por exemplo:
*"Usando o agent-reach: plataforma Reddit via OpenCLI."*

---

## 🔓 Libere mais quando precisar

Não usa? Não configura. Todo passo é opcional.

### 🍪 Cookies — grátis, 2 minutos

Diga ao agente "configura os cookies do Twitter" — ele guia a exportação manual
pelo **Cookie-Editor** (*Export → Header String*). O Agent Reach salva os valores
só para o `doctor` verificar se as credenciais existem; o `doctor` não roda
`twitter status`. Os comandos `twitter` ainda precisam de `TWITTER_AUTH_TOKEN` e
`TWITTER_CT0` no ambiente do processo.

No XiaoHongShu, o Agent Reach nunca faz login por você nem lê cookies do
navegador. O OpenCLI usa apenas uma sessão do Chrome que você já abriu. Sem
sessão, use a exportação manual do Cookie-Editor com xiaohongshu-mcp.

> 🔒 Use uma **conta secundária** em plataformas acessadas por cookie ou sessão do navegador.

### 🌐 Proxy — ~US$ 1/mês, só em redes restritas

A maioria não precisa. Se sua rede bloqueia Reddit/Twitter, configure com
`agent-reach configure proxy` (entrada oculta).

---

## 🩺 Status num relance

```
$ agent-reach doctor

👁️  Agent Reach Status
========================================

✅ Ready to use:
  ✅ GitHub repos and code — public repos readable and searchable
  ✅ YouTube video subtitles — yt-dlp
  ✅ Bilibili search & video detail — bili-cli (subtitles via OpenCLI)
  ✅ RSS/Atom feeds — feedparser
  ✅ Web pages (any URL) — Jina Reader API
...
Status: 6/9 channels available
```

> A saída do CLI é em inglês; o agente explica o resultado para você em português.

---

## 🧠 Filosofia

**O Agent Reach é uma camada de capacidade, não mais uma ferramenta.** Ele cuida
de **seleção, instalação, diagnóstico e roteamento** — a leitura em si é feita
pelo agente chamando diretamente as ferramentas originais, sem wrapper.

Cada plataforma tem uma lista ordenada de backends (principal + alternativas):

```
channels/
├── web.py          → Jina Reader
├── twitter.py      → twitter-cli ▸ OpenCLI ▸ bird
├── youtube.py      → yt-dlp
├── github.py       → gh CLI
├── bilibili.py     → bili-cli ▸ OpenCLI ▸ search API (yt-dlp aposentado, bloqueio 412)
├── reddit.py       → OpenCLI ▸ rdt-cli (sem acesso anônimo, login obrigatório)
├── facebook.py     → OpenCLI (sessão do navegador no desktop)
├── instagram.py    → OpenCLI (sessão do navegador no desktop)
├── xiaohongshu.py  → OpenCLI ▸ xiaohongshu-mcp ▸ xhs-cli
├── linkedin.py     → linkedin-mcp ▸ Jina Reader
├── rss.py          → feedparser
├── exa_search.py   → Exa via mcporter
└── __init__.py     → registro dos canais (usado pelo doctor)
```

Cada canal **testa de verdade** seus backends em ordem; o primeiro que funciona
vira o backend ativo, e os quebrados vêm com instrução de conserto.

---

## 🔄 Atualizar

Peça ao agente: *"Atualize o Agent Reach."* Ou:

```bash
agent-reach check-update
pipx install --force https://github.com/Panniantong/agent-reach/archive/main.zip
```

Depois, reimporte a skill pt-BR se o instalador tiver sobrescrito a sua.

---

## Créditos

Projeto original: [Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach).

Ferramentas: [twitter-cli](https://github.com/public-clis/twitter-cli) · [rdt-cli](https://github.com/public-clis/rdt-cli) · [xhs-cli](https://github.com/jackwener/xiaohongshu-cli) · [bili-cli](https://github.com/public-clis/bilibili-cli) · [yt-dlp](https://github.com/yt-dlp/yt-dlp) · [Jina Reader](https://github.com/jina-ai/reader) · [Exa](https://exa.ai) · [mcporter](https://github.com/nicobailon/mcporter) · [feedparser](https://github.com/kurtmckee/feedparser) · [mcp-server-linkedin](https://github.com/stickerdaniel/linkedin-mcp-server)

> Agent Reach não tem token, criptomoeda ou produto de investimento oficial.
> Qualquer projeto cripto usando o nome não tem relação com este repositório.

## Licença

[MIT](LICENSE)
