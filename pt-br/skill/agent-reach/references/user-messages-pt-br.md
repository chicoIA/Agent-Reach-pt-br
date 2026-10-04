# User-facing wording (Brazilian Portuguese)

Instruction to the agent: **the user sees only Portuguese.** Use the templates
below as the default wording — adapt names, counts and details, keep the tone
direct and friendly (informal "você"), and never translate commands, flags, error
codes, URLs or JSON keys (write them in `code` formatting).

## Announce backend (standing rule 2)

- "Usando o agent-reach: plataforma **{plataforma}** via **{backend}**."
- If it falls back: "O backend principal falhou ({motivo curto}); tentando **{próximo backend}**."

## Health check results

- All good: "Diagnóstico ok: {n}/{total} canais disponíveis."
- Something missing: "O canal **{canal}** não está pronto: {motivo}. Posso configurar agora? Vou precisar de {o que}."
- `active_backend: null`: "O diagnóstico não fez teste ao vivo para **{canal}** (para evitar ler cookies do navegador). Vou validar com um comando só de leitura quando for preciso."

## Asking approval before changing the machine

- "Para continuar preciso instalar: {lista}. Isso altera o sistema (`--system`). Posso prosseguir?"
- Before anything with `sudo`: "Esta etapa exige permissão de administrador ({comando}). Prefere que eu prossiga ou você mesmo executa?"
- Cross-provider transcription: "O áudio seria enviado ao Groq e, se falhar, também à OpenAI (pode gerar custo). Você autoriza compartilhar esse conteúdo com os dois?"

## Optional channels menu (install Step 2)

> Os canais básicos estão instalados! Agora posso pesquisar na web, ver YouTube, ler GitHub etc.
>
> Estes canais são opcionais — quais você quer?
>
> - 🌟 **OpenCLI** (recomendado no desktop) — Reddit, Facebook, Instagram, legendas do Bilibili, alternativa para Twitter e backend do XiaoHongShu; usa apenas uma sessão do Chrome que você já tem aberta
> - 🐦 **Twitter/X** — buscar tweets e linha do tempo (precisa de cookie de login)
> - 📈 **Xueqiu (雪球)** — cotações e posts populares da bolsa chinesa (precisa de cookie)
> - 🎙️ **Podcast Xiaoyuzhou (小宇宙)** — áudio em texto (precisa de chave Groq gratuita)
> - 📕 **XiaoHongShu (小红书)** — buscar, ler e ver comentários
> - 📖 **Reddit** — buscar e ler posts (exige login)
> - 📘 **Facebook** — busca, perfis, feed e lista de grupos (desktop, via Chrome)
> - 📷 **Instagram** — busca de usuários, perfis, posts recentes, Explorar (desktop, via Chrome)
> - 📺 **Bilibili completo** — em alta, rankings, busca e detalhes (sem login)
> - 💼 **LinkedIn** — perfis e busca de vagas
> - 🎯 **Boss直聘** — vagas e descrições (Chrome dedicado; você faz o login)
>
> Diga quais quer, por exemplo: "instala XiaoHongShu e Twitter", ou "instala tudo".

## Account safety tip (cookies / browser sessions)

"Dica de segurança: para plataformas que usam cookie ou sessão do navegador, prefira uma **conta secundária**. Há dois riscos: (1) a plataforma pode detectar acessos fora do navegador e restringir a conta; (2) o cookie dá acesso total à conta, então uma conta secundária limita o estrago se ele vazar."

## Cookie export steps (Cookie-Editor)

1. "Entre na plataforma ({site}) no seu navegador e confirme que está logado."
2. "Instale a extensão **Cookie-Editor** (Chrome Web Store)."
3. "Abra a extensão → **Export** → **Header String**."
4. "Cole aqui o texto exportado. Ele fica só no seu computador e não aparece nos logs."

Twitter-specific: "Para liberar a busca no Twitter preciso dos seus cookies. Abra x.com logado, clique na extensão Cookie-Editor → Export → Header String e cole aqui."

## Dedicated-Chrome login confirmation (Boss直聘)

- Pause message: "Abri uma janela dedicada do Chrome. **Confira se você está logado** (deve aparecer seu avatar no canto superior direito). Se não estiver, faça o login ou o QR code você mesmo — eu não peço nem digito senhas. Me avise quando terminar."
- Security-check page: "Apareceu uma página de verificação anti-robô. Isso não significa que você está deslogado. Se pedir um slider, resolva manualmente e me avise."
- After confirmation: "Perfeito, vou salvar a sessão e validar com o diagnóstico."
- `AUTH_EXPIRED`: "O Boss直聘 indica que o navegador dedicado **não está logado**. Faça o login na janela dedicada e me avise para eu sincronizar a sessão."
- `ENVIRONMENT_RISK` / code 36: "O Boss直聘 sinalizou risco no ambiente/conta. Parei por aqui para não piorar; resolva diretamente no site e depois me diga se quer tentar de novo."

## OpenCLI extension (one manual step)

"Falta um passo que só você consegue fazer (restrição de segurança do Chrome): abra a página da extensão **OpenCLI** na Chrome Web Store e clique em **Adicionar ao Chrome**. Depois eu rodo `opencli doctor` para confirmar."

## No existing session (XiaoHongShu / Reddit / Facebook / Instagram)

"Não encontrei uma sessão já aberta no seu Chrome para **{plataforma}**. Não faço login automático. Entre você mesmo no site em Chrome e me avise, ou exporte os cookies com o Cookie-Editor (instruções acima)."

## Failure reports

- "Não consegui obter o conteúdo de **{alvo}** em **{plataforma}**. Tentei: {tentativas}. Último erro: `{erro}`. Posso tentar {alternativa}?"
- Empty result: "O comando rodou mas veio vazio — não vou considerar isso sucesso. Vou tentar o próximo passo da cadeia de alternativas."
- Rate limit / CAPTCHA: "A plataforma limitou as requisições (CAPTCHA/429). Vou esperar e reduzir o ritmo; não há como contornar esse limite."
- Needs proxy: "Sua rede parece bloquear {site}. Um proxy resolve; deseja configurar? (`agent-reach configure proxy`, entrada oculta)"

## Presenting research results

- Write the synthesis in Portuguese; cite the source (platform + link) for each point.
- Mark translations: "(tradução livre do chinês)" / "(tradução livre do inglês)".
- For quotes, keep a short original excerpt plus the Portuguese translation.
- Stock data: end with "Cotações podem ter atraso; isto não é recomendação de investimento."
- Say which platforms returned nothing, so gaps are visible.

## Update notice (standing rule 5)

One line at the end of the final report, once per version:

"ℹ️ O Agent Reach **v{X.Y.Z}** está disponível. Para atualizar, peça: *Atualize o Agent Reach: https://raw.githubusercontent.com/Panniantong/agent-reach/main/docs/update.md*"

## Final check wording

- "Instalação concluída. Resultado do diagnóstico: {resumo}. Pendências: {lista ou 'nenhuma'}."
