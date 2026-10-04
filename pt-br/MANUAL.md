# Manual do Agent Reach (edição pt-BR)

O **Agent Reach** dá ao seu agente de IA (Claude Code, Claude.ai, OpenClaw,
Cursor, Windsurf…) acesso de leitura e busca a mais de 15 plataformas da
internet: web, YouTube, GitHub, Twitter/X, Reddit, Facebook, Instagram,
LinkedIn, RSS, Bilibili, XiaoHongShu e outras.

Esta edição foi organizada assim:

- **A skill fala com o agente em inglês** — as instruções técnicas ficam no
  idioma em que os modelos seguem regras com mais precisão.
- **Tudo o que você vê sai em português** — avisos, perguntas, pedidos de
  autorização, passo a passo e relatórios finais.
- Comandos, nomes de arquivos e códigos de erro continuam no original (assim
  você pode copiar e colar sem erro).

---

## 1. O que tem nesta pasta

```
pt-br/
├── MANUAL.md                      ← este manual (em português)
├── README.md                      ← índice rápido
├── agent-reach-skill-pt-br.zip    ← pacote pronto para importar
├── build-zip.sh                   ← regenera o zip após editar a skill
└── skill/
    └── agent-reach/               ← a skill (conteúdo do zip)
        ├── SKILL.md               ← instruções do agente (inglês) + regra de idioma
        └── references/
            ├── search.md          ← busca na web (Exa)
            ├── social.md          ← Twitter, Reddit, Facebook, Instagram, XiaoHongShu, Bilibili, V2EX
            ├── career.md          ← LinkedIn, Boss直聘
            ├── dev.md             ← GitHub (gh CLI)
            ├── web.md             ← páginas web, RSS
            ├── video.md           ← YouTube, Bilibili, podcasts
            ├── finance.md         ← cotações (Xueqiu)
            ├── setup.md           ← instalação, atualização, cookies, proxy
            └── user-messages-pt-br.md ← modelos de mensagens em português para o usuário
```

A pasta `skill/agent-reach/` é **autossuficiente**: tudo o que o agente precisa
está dentro dela. O restante do repositório (`agent_reach/`, `tests/`, `docs/`)
é o código original do CLI em Python, que não foi alterado.

---

## 2. Como funciona (em 30 segundos)

O Agent Reach tem duas partes:

1. **A skill** (`SKILL.md` + `references/`): ensina o agente qual ferramenta usar
   para cada plataforma, em que ordem tentar alternativas e quais limites de
   segurança respeitar.
2. **O CLI `agent-reach`**: instala as ferramentas de cada plataforma
   (yt-dlp, gh, twitter-cli, OpenCLI…), guarda configurações e roda o
   diagnóstico (`agent-reach doctor`).

Depois de instalado, o agente chama as ferramentas originais diretamente. O
Agent Reach só escolhe, instala, diagnostica e roteia — não é um "wrapper".

---

## 3. Importar a skill

### Opção A — Claude.ai / Claude Desktop (upload de zip)

1. Baixe `pt-br/agent-reach-skill-pt-br.zip`.
2. No Claude, abra **Configurações → Capacidades → Skills** (ou equivalente na
   sua versão) e escolha **Enviar skill**.
3. Selecione o zip. A skill aparece como **agent-reach**.

> A skill no Claude.ai só funciona plenamente se o ambiente puder executar
> comandos de terminal (ex.: Claude Code, ou execução de código habilitada).

### Opção B — Claude Code (pasta de skills)

```bash
# skill para o seu usuário (vale em todos os projetos)
mkdir -p ~/.claude/skills
unzip pt-br/agent-reach-skill-pt-br.zip -d ~/.claude/skills/

# ou só para um projeto
mkdir -p .claude/skills
unzip pt-br/agent-reach-skill-pt-br.zip -d .claude/skills/
```

O resultado deve ser `~/.claude/skills/agent-reach/SKILL.md`.

### Opção C — OpenClaw e outros agentes

Copie a pasta `skill/agent-reach/` para o diretório de skills do agente, por
exemplo `~/.openclaw/skills/agent-reach/`.

> ⚠️ **Atenção:** o comando `agent-reach skill --install` (e o
> `agent-reach install --system`) do CLI original **sobrescreve** a skill
> instalada pela versão chinesa/inglesa do pacote. Se você usar esses comandos,
> repita a cópia da Opção B/C depois.

---

## 4. Instalar o CLI `agent-reach`

O jeito mais simples é pedir ao próprio agente (com a skill já importada):

```
Instale o Agent Reach com segurança, primeiro só verificando o que falta.
```

Ou manualmente:

```bash
# recomendado
pipx install https://github.com/Panniantong/agent-reach/archive/main.zip

# verificação somente leitura (não altera nada)
agent-reach install --env=auto

# instalação de verdade (só depois de você aprovar alterações no sistema)
agent-reach install --env=auto --system
```

Se aparecer `externally-managed-environment` (Python do Homebrew), use um venv:

```bash
python3 -m venv ~/.agent-reach-venv
source ~/.agent-reach-venv/bin/activate
pip install https://github.com/Panniantong/agent-reach/archive/main.zip
```

No Windows, use `py -3` no lugar de `python3` (o `python3` costuma ser só um
atalho para a Microsoft Store).

### Modos de instalação

| Comando | O que faz |
|---|---|
| `agent-reach install --env=auto` | Só verifica (padrão seguro) |
| `agent-reach install --env=auto --dry-run` | Mostra o que seria feito |
| `agent-reach install --env=auto --system` | Instala/configura de fato |
| `agent-reach install --env=auto --system --channels=twitter,reddit` | Instala canais opcionais |
| `agent-reach install --env=auto --system --channels=all` | Instala tudo |

Canais opcionais: `opencli`, `twitter`, `xiaoyuzhou`, `xueqiu`, `xiaohongshu`,
`reddit`, `facebook`, `instagram`, `bilibili`, `linkedin`, `boss`, `all`.

---

## 5. Plataformas suportadas

| Plataforma | O que dá para fazer | Configuração |
|---|---|---|
| 🌐 Web | Ler qualquer URL como Markdown | Nenhuma |
| 🔍 Busca na web (Exa) | Busca semântica | Automática na instalação |
| 📦 GitHub | Ler e buscar repositórios/código | Nenhuma (`gh auth login` libera mais) |
| 📺 YouTube | Legendas, busca, comentários | Nenhuma |
| 📡 RSS | Ler feeds RSS/Atom | Nenhuma |
| 💻 V2EX | Tópicos, respostas, usuários | Nenhuma |
| 📺 Bilibili | Busca, detalhes; legendas via OpenCLI | Nenhuma (legendas: OpenCLI) |
| 🐦 Twitter/X | Busca, timeline, tweets, artigos | Cookie |
| 📖 Reddit | Busca e leitura | Login obrigatório (OpenCLI ou rdt-cli) |
| 📘 Facebook | Busca, perfis, feed, lista de grupos | OpenCLI (desktop) |
| 📷 Instagram | Busca de usuários, perfis, posts recentes | OpenCLI (desktop) |
| 💼 LinkedIn | Perfis, empresas, vagas | mcp-server-linkedin (ou Jina para páginas públicas) |
| 📕 XiaoHongShu (小红书) | Busca, notas, comentários | OpenCLI ou cookie |
| 📈 Xueqiu (雪球) | Cotações, ações em alta | Cookie |
| 🎙️ Xiaoyuzhou (小宇宙) | Transcrição de podcast | Chave Groq gratuita |
| 🎯 Boss直聘 | Vagas e descrições | Chrome dedicado + login manual |

---

## 6. Uso no dia a dia

Basta pedir em português. Exemplos:

- "Pesquise o que estão falando sobre o novo framework X no Reddit e no Twitter."
- "Leia este link e me resuma: https://…"
- "Do que fala este vídeo? https://youtube.com/…"
- "Busque no GitHub os repositórios mais populares de agentes de IA."
- "Assine este RSS e me mostre os 5 últimos posts."
- "Faça uma pesquisa completa sobre X." (o agente combina várias plataformas)

O agente sempre avisa qual plataforma/backend está usando, por exemplo:
*"Usando o agent-reach: plataforma Reddit via OpenCLI."*

Conteúdo em outro idioma (inglês, chinês) é resumido em português, com a
indicação "(tradução livre)".

---

## 7. Diagnóstico

```bash
agent-reach doctor          # relatório legível
agent-reach doctor --json   # para o agente (mostra o backend ativo de cada plataforma)
agent-reach check-update    # verifica se há nova versão
```

- ✅ pronto · ⚠️ funciona com ressalvas · ⬜/❌ precisa configurar.
- `active_backend: null` **não** significa "quebrado": o diagnóstico apenas
  evitou um teste ao vivo que leria cookies do navegador.

---

## 8. Configurar plataformas que exigem login

> 🔒 **Recomendação:** use uma **conta secundária** em plataformas acessadas por
> cookie ou sessão do navegador. A plataforma pode restringir contas com acesso
> automatizado, e o cookie dá acesso total à conta.

### Exportar cookies com o Cookie-Editor

1. Entre no site (ex.: x.com) no seu navegador.
2. Instale a extensão [Cookie-Editor](https://chromewebstore.google.com/detail/cookie-editor/hlkenndednhfkekhgcdicdfddnkalmdm).
3. Clique na extensão → **Export** → **Header String**.
4. Cole o texto para o agente. Ele roda o comando de configuração com entrada
   oculta — o valor não aparece em logs.

Sem extensão: F12 → aba **Network** → recarregue a página → clique em qualquer
requisição → em *Request Headers*, copie o valor depois de `Cookie: `.

### Twitter/X

```bash
agent-reach configure twitter-cookies
```

Os cookies salvos servem só para o diagnóstico. Para usar o `twitter` de fato,
o agente define `TWITTER_AUTH_TOKEN` e `TWITTER_CT0` no ambiente do comando.

### Reddit, Facebook, Instagram, XiaoHongShu (via OpenCLI — desktop)

```bash
agent-reach install --system --channels opencli
```

Depois, **um passo manual seu**: instale a extensão
[OpenCLI](https://chromewebstore.google.com/detail/opencli/ildkmabpimmkaediidaifkhjpohdnifk)
no Chrome e entre nos sites que quer usar. O agente confirma com `opencli doctor`.
O Agent Reach **nunca** faz login por você nem lê cookies do navegador por conta própria.

### Xueqiu (雪球)

Entre em xueqiu.com no Chrome e rode:

```bash
agent-reach configure --from-browser chrome --platform xueqiu
```

### Transcrição de áudio (Groq, gratuito)

1. Acesse https://console.groq.com e entre com Google/GitHub.
2. **API Keys → Create API Key** (começa com `gsk_`).
3. `agent-reach configure groq-key` e cole a chave.

Serve para podcasts Xiaoyuzhou e para vídeos sem legenda
(`agent-reach transcribe URL`).

### LinkedIn

```bash
mcporter config add linkedin --command uvx --arg mcp-server-linkedin@latest --env UV_HTTP_TIMEOUT=300 --scope home
uvx mcp-server-linkedin@latest --login   # abre o navegador para você entrar
```

### Boss直聘

Peça ao agente: *"Configura o Boss直聘 para mim."* Ele instala a ferramenta,
abre uma janela do Chrome dedicada e **pausa** para você confirmar que está
logado (avatar no canto superior direito). Login, QR code e sliders são sempre
feitos por você.

### Proxy (redes restritas)

A maioria das pessoas não precisa. Se sua rede bloqueia algum site:

```bash
agent-reach configure proxy
```

---

## 9. Solução de problemas

| Sintoma | O que fazer |
|---|---|
| `twitter search` falha | O agente tenta de novo, atualiza o twitter-cli, cai para OpenCLI e, por último, usa `twitter feed`/`user-posts`. Verifique os cookies e o proxy. |
| Xueqiu retorna HTTP 400 | Cookie ausente/expirado: entre de novo em xueqiu.com e repita `configure --from-browser`. |
| YouTube sem legenda | O agente tenta OpenCLI (até 3 vezes) e depois transcreve o áudio. |
| Bilibili com erro 412 | Normal com yt-dlp — a skill usa bili-cli/OpenCLI. |
| Reddit 403 | Não existe acesso anônimo: é preciso login (OpenCLI ou `rdt login`). |
| CAPTCHA / 429 | Limite da plataforma; o agente espera e reduz o ritmo. |
| Boss直聘 `AUTH_EXPIRED` | O Chrome dedicado não está logado: entre nele e avise o agente. |
| Boss直聘 `ENVIRONMENT_RISK` | O agente para imediatamente; resolva direto no site. |

---

## 10. Atualizar

Peça ao agente: *"Atualize o Agent Reach."* Ou:

```bash
agent-reach check-update
pipx install --force https://github.com/Panniantong/agent-reach/archive/main.zip
agent-reach doctor
```

Depois de atualizar o CLI, reimporte a skill pt-BR (Seção 3), caso o
instalador tenha sobrescrito a sua.

---

## 11. Personalizar a skill

1. Edite os arquivos em `pt-br/skill/agent-reach/`.
   - Regras e instruções para o agente: **em inglês**.
   - Frases que o usuário vai ler: em `references/user-messages-pt-br.md`.
2. Regere o zip:
   ```bash
   bash pt-br/build-zip.sh
   ```
3. Reimporte o zip.

---

## 12. Privacidade e segurança

- Cookies, chaves e tokens ficam só na sua máquina (`~/.agent-reach/`).
- O agente nunca imprime segredos e nunca faz login no seu lugar.
- Operações de escrita (postar, curtir, comentar) não são feitas sem pedido
  explícito.
- Arquivos temporários vão para `/tmp/`; nada é criado na pasta do seu projeto.

---

Projeto original: https://github.com/Panniantong/Agent-Reach (licença MIT).
