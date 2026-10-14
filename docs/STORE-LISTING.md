# Ficha da Play Store

Textos em inglês (D16). Arte em `docs/store/` (gerada por `test/tool/brand_render_test.dart`).

## Textos

**Nome do app** (até 30): `Auvie — Film photo & video`

**Descrição curta** (até 80):
> A darkroom for your phone: film looks, type and video, all on your device.

**Descrição completa** (até 4000):

> Auvie is a darkroom for the photographs and films on your phone.
>
> **Develop with real emulsions, not filters.** Every film is modelled on a stock: warm colour negatives, ashen monochromes, tungsten nights. Try any of them on your own photo, at any strength, before you decide.
>
> **Adjust like a printer.** Exposure, contrast, highlights and shadows, white balance, curves, grain, fade and vignette, plus crop, rotate and straighten.
>
> **Write on it.** Set type in editorial styles, or draw a line with your finger and let the words follow it. Add a brush stroke, a sticker, a light leak, a film burn or a 35 mm frame.
>
> **Films too.** Trim your videos, grade them with the same films, place text and drawings exactly when you want them, mute the sound, and export in 720p, 1080p or the original size, in the background.
>
> **Private by design.** Your photos and videos never leave your phone. No account, no ads, no tracking.
>
> **Auvie Pro** unlocks every collection and the full darkroom kit. Everything else is free, without watermarks.

**Categoria:** Fotografia. **Tags:** photo editor, film, video editor.

**E-mail de contato:** *(o seu)*. **Site:** *(onde hospedar `docs/legal/`)*. **Política de privacidade:** URL pública de `docs/legal/privacy.html`.

## Arte

| Item | Arquivo | Tamanho |
|---|---|---|
| Ícone | `docs/store/icon-512.png` | 512 × 512 |
| Gráfico de destaque | `docs/store/feature-graphic.png` | 1024 × 500 |
| Screenshots | tirar no aparelho | de 2 a 8, em retrato |

**Roteiro dos screenshots** (fotos suas, tela limpa, modo claro e escuro como o app mostra):
1. Home com projetos recentes.
2. Editor, FILM com um filme aplicado numa foto bonita.
3. ADJUST com a régua (ex.: EXPOSURE) e a curva.
4. TYPE → Text Brush escrevendo ao longo de uma curva.
5. Vídeo em TRIM com elementos nas faixas.
6. Archive.
7. Export com a prévia.

## Data Safety (Segurança dos dados)

| Pergunta | Resposta |
|---|---|
| O app coleta ou compartilha dados do usuário? | **Sim**, só para compras (via RevenueCat). |
| Os dados são criptografados em trânsito? | Sim. |
| O usuário pode pedir a exclusão? | Sim (pelo e-mail de contato). |

**Tipos de dado coletados:**
- **Compras → Histórico de compras:** coletado, não compartilhado; finalidade *funcionalidade do app* (saber se a pessoa tem Pro); obrigatório.
- **IDs do app → ID do usuário:** o ID anônimo do RevenueCat; coletado, não compartilhado; finalidade *funcionalidade do app*; obrigatório.

**Não coletados:** fotos e vídeos, arquivos, localização, contatos, informações pessoais, mensagens, atividade no app, dados de navegação. As fotos são processadas só no aparelho.

**Relatórios de falhas:** os do Android vitals são coletados pelo Google Play, não pelo app; não entram aqui. Se um dia entrar o PostHog, acrescentar *Atividade no app* e *Diagnóstico*.

## Outras perguntas do Play Console

- **Classificação de conteúdo:** questionário IARC, sem violência, sem conteúdo gerado compartilhado, sem compras de itens aleatórios → *Livre*.
- **Público-alvo:** 13+ (não direcionado a crianças).
- **Anúncios:** não contém.
- **Acesso ao app:** todo o app funciona sem login.
- **Permissões sensíveis:** nenhuma (o seletor de fotos não exige permissão de galeria). Serviço em primeiro plano `mediaProcessing`/`dataSync`: justificar como "exportação de vídeo iniciada pelo usuário, com notificação de progresso".
