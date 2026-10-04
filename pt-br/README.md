# Agent Reach — edição pt-BR

Pacote da skill **agent-reach** com instruções ao agente em **inglês** e toda a
interação com o usuário em **português do Brasil**.

| Arquivo | Para quê |
|---|---|
| [`MANUAL.md`](MANUAL.md) | Manual completo em português (instalação, uso, configuração, problemas) |
| [`agent-reach-skill-pt-br.zip`](agent-reach-skill-pt-br.zip) | Skill pronta para importar (contém `agent-reach/SKILL.md` + `references/`) |
| [`skill/agent-reach/`](skill/agent-reach/) | Fonte da skill (o que vai dentro do zip) |
| [`build-zip.sh`](build-zip.sh) | Regenera o zip depois de editar a skill |

Importação rápida no Claude Code:

```bash
unzip pt-br/agent-reach-skill-pt-br.zip -d ~/.claude/skills/
```

No Claude.ai/Desktop: **Configurações → Capacidades → Skills → Enviar skill** e
selecione o zip. Detalhes no [manual](MANUAL.md#3-importar-a-skill).
