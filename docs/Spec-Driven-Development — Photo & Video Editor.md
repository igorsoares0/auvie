# Spec-Driven-Development
## Photo & Video Editor — Mobile

**Status:** Approved  
**Version:** 1.0  
**Platform:** iOS + Android  
**Primary Stack:** Flutter + Swift + Kotlin  
**Backend de usuários:** Não  
**Login:** Não  
**Cloud storage de usuários:** Não  
**Billing:** RevenueCat  
**Content Backend:** Sim, exclusivamente para conteúdo do aplicativo

---

# 1. Visão do Produto

O produto será um editor mobile de fotos e vídeos com foco em **estética, simplicidade e qualidade visual**, inspirado em aplicativos como Tezza, VSCO e editores de fotografia analógica.

O objetivo não é competir diretamente com editores generalistas como CapCut ou Canva.

O produto deverá proporcionar uma experiência:

> **Importar → escolher uma estética → ajustar → adicionar elementos → exportar.**

O aplicativo será **local-first**:

- não exige cadastro;
- não exige login;
- não possui perfil de usuário;
- não possui backend para projetos pessoais;
- fotos e vídeos do usuário permanecem no dispositivo;
- edição funciona offline;
- projetos são armazenados localmente;
- processamento de mídia ocorre no dispositivo.

A única infraestrutura online obrigatória será relacionada a:

1. assinaturas através do RevenueCat;
2. distribuição de conteúdo criado pelo proprietário do aplicativo.

---

# 2. Objetivos

## 2.1 Objetivos principais

- Criar um editor de fotos premium e simples.
- Criar um editor de vídeos com a mesma identidade visual.
- Utilizar o mesmo sistema de presets para foto e vídeo.
- Oferecer filtros com aparência profissional.
- Oferecer ferramentas de ajustes manuais.
- Permitir textos sobre fotos e vídeos.
- Permitir desenho/escrita através de Text Brush.
- Permitir stickers, overlays e outros assets.
- Manter edição rápida e responsiva.
- Funcionar offline.
- Monetizar através de assinatura Pro.
- Permitir lançamento contínuo de novos conteúdos sem precisar publicar uma nova versão do aplicativo.

## 2.2 Objetivos secundários

- Criar uma arquitetura preparada para novos tipos de elementos.
- Permitir criação rápida de novas coleções de presets.
- Permitir atualização remota de conteúdo.
- Permitir evolução futura do engine sem reescrever o editor Flutter.

---

# 3. Não Objetivos

A V1 não terá:

- login;
- criação de contas;
- sincronização de projetos;
- cloud backup;
- rede social;
- feed;
- comentários;
- colaboração;
- edição batch;
- IA;
- geração de imagens;
- geração de vídeos;
- edição profissional multicam;
- timeline profissional complexa;
- múltiplas tracks de vídeo;
- captions automáticas;
- remoção de fundo por IA;
- tracking automático de objetos;
- marketplace de criadores;
- versão web pública do editor.

O Admin Web não será um produto destinado aos usuários finais.

---

# 4. Princípios do Produto

## 4.1 Local-first

O projeto do usuário deve continuar funcional mesmo sem conexão com a internet.

## 4.2 Simplicidade

O usuário não deve precisar conhecer conceitos profissionais de edição.

## 4.3 Visual-first

A interface deve priorizar preview e manipulação direta da mídia.

## 4.4 Presets como diferencial

Presets e coleções estéticas serão uma parte fundamental da identidade do produto.

## 4.5 Foto e vídeo compartilham o mesmo sistema

Sempre que possível, os mesmos ajustes, presets e elementos deverão funcionar nos dois tipos de mídia.

## 4.6 Performance

Operações de preview e edição devem utilizar GPU/native rendering quando necessário.

## 4.7 Conteúdo desacoplado do aplicativo

Presets, stickers, overlays e outros conteúdos deverão poder ser atualizados sem uma nova versão do aplicativo.

---

# 5. Arquitetura Geral

```text
┌──────────────────────────────────────────┐
│              ADMIN WEB                   │
│                                          │
│ Presets / Collections / Assets / Fonts   │
└────────────────────┬─────────────────────┘
                     │
                     ▼
              Content API
                     │
          ┌──────────┴──────────┐
          │                     │
       Database                R2
          │                     │
          └──────────┬──────────┘
                     │
                  Internet
                     │
                     ▼
┌──────────────────────────────────────────┐
│              MOBILE APP                  │
│                                          │
│ Flutter UI                               │
│                                          │
│ ┌──────────────────────────────────────┐ │
│ │ Editor                               │ │
│ │                                      │ │
│ │ Photo / Video / Text / Brush / etc. │ │
│ └────────────────┬─────────────────────┘ │
│                  │                       │
│             Native Bridge               │
│                  │                       │
│       ┌──────────┴──────────┐            │
│       │                     │            │
│    Android                iOS            │
│    Kotlin                Swift           │
│       │                     │            │
│       └──────────┬──────────┘            │
│                  │                       │
│             Media Engine                │
│                  │                       │
│             GPU Rendering               │
│                                          │
│ Local Database + Local Files             │
└──────────────────────────────────────────┘

                 RevenueCat
                     │
          Apple App Store / Google Play
```

---

# 6. Mobile Application

## 6.1 Stack

### Flutter

Responsável por:

- UI;
- navegação;
- estado;
- editor;
- controles;
- timeline;
- presets;
- biblioteca;
- projetos;
- configurações;
- paywall;
- integração RevenueCat;
- comunicação com native engine.

### Android

- Kotlin;
- APIs nativas de mídia;
- GPU rendering;
- codecs;
- acesso à galeria;
- exportação.

### iOS

- Swift;
- APIs nativas de mídia;
- GPU rendering;
- codecs;
- Photos framework;
- exportação.

---

# 7. Arquitetura Flutter

A aplicação deverá ser organizada por features.

```text
lib/
├── app/
│   ├── router/
│   ├── theme/
│   └── app.dart
│
├── core/
│   ├── models/
│   ├── storage/
│   ├── native/
│   ├── networking/
│   └── utils/
│
├── features/
│   ├── home/
│   ├── projects/
│   ├── editor/
│   │   ├── photo/
│   │   ├── video/
│   │   ├── adjustments/
│   │   ├── presets/
│   │   ├── text/
│   │   ├── brush/
│   │   ├── stickers/
│   │   └── overlays/
│   │
│   ├── export/
│   ├── subscription/
│   └── settings/
│
└── main.dart
```

---

# 8. Editor

O editor será dividido conceitualmente em:

```text
Editor
├── Media
├── Adjustments
├── Presets
├── Elements
│   ├── Text
│   ├── Brush
│   ├── Sticker
│   ├── Overlay
│   └── Frame
└── Export
```

O usuário deverá conseguir alternar entre ferramentas sem perder o estado atual da edição.

---

# 9. Sistema de Projeto

Cada edição será representada por um projeto local.

Exemplo:

```text
Project
├── id
├── media
├── mediaType
├── editSettings
├── elements
├── preset
├── metadata
├── createdAt
└── updatedAt
```

O projeto não armazenará necessariamente uma nova cópia completa da mídia original.

O projeto deverá armazenar principalmente:

- referência para mídia;
- parâmetros de edição;
- elementos;
- posições;
- transformações;
- informações necessárias para reconstrução da edição.

Isso permite edição não destrutiva.

---

# 10. Edição Não Destrutiva

Sempre que possível:

```text
Original
   +
Edit Settings
   +
Elements
   ↓
Rendered Result
```

O arquivo original não deverá ser alterado.

O usuário poderá retornar ao projeto e modificar os parâmetros.

---

# 11. Sistema de Ajustes

A V1 deverá oferecer:

- Exposure
- Brightness
- Contrast
- Highlights
- Shadows
- Saturation
- Temperature
- Tint
- Sharpen
- Grain
- Fade
- Vignette
- Curves

Os valores deverão possuir uma representação normalizada internamente.

Exemplo:

```text
exposure: -1.0 → +1.0
contrast: -1.0 → +1.0
saturation: -1.0 → +1.0
```

A UI poderá utilizar valores diferentes, desde que o engine possua uma representação consistente.

---

# 12. Presets

Presets são conjuntos de parâmetros de edição.

Exemplo:

```json
{
  "id": "film_35",
  "name": "35mm",
  "version": 1,
  "settings": {
    "exposure": 0.05,
    "contrast": -0.08,
    "highlights": -0.18,
    "shadows": 0.12,
    "saturation": -0.05,
    "temperature": 0.08,
    "grain": 0.25,
    "fade": 0.08,
    "vignette": 0.12
  }
}
```

Um preset deverá funcionar tanto em:

- foto;
- vídeo.

---

# 13. Intensidade do Preset

O usuário poderá controlar a intensidade.

```text
Preset
──────────●──────
          72%
```

Internamente:

```text
finalValue =
    originalValue +
    presetDelta * intensity
```

A implementação exata poderá variar por parâmetro.

---

# 14. Coleções

Presets deverão ser agrupados em coleções.

Exemplos:

```text
Film
Vintage
Moody
Clean
Summer
Travel
Night
```

Cada coleção poderá conter:

- presets;
- stickers;
- overlays;
- frames;
- outros assets.

---

# 15. Editor de Foto

A V1 deverá oferecer:

### Transformações

- Crop
- Rotate
- Flip
- Aspect Ratio

Aspect ratios:

- Original
- 1:1
- 4:5
- 3:4
- 9:16
- 16:9

### Ajustes

- Exposure
- Brightness
- Contrast
- Highlights
- Shadows
- Saturation
- Temperature
- Tint
- Sharpen
- Grain
- Fade
- Vignette
- Curves

### Conteúdo

- Presets
- Text
- Text Brush
- Stickers
- Overlays
- Frames

---

# 16. Editor de Vídeo

A V1 deverá oferecer:

- seleção de vídeo;
- preview;
- trim;
- crop;
- rotate;
- aspect ratio;
- ajustes;
- presets;
- grain;
- fade;
- vignette;
- texto;
- Text Brush;
- stickers;
- overlays;
- áudio/mute;
- exportação.

Não haverá timeline profissional multicamada na V1.

---

# 17. Timeline de Vídeo

A timeline deverá permanecer simples.

```text
┌─────────────────────────────────┐
│ Video                           │
│ ███████████████████████████████ │
└─────────────────────────────────┘
      0s       5s       10s
```

Ela será utilizada principalmente para:

- trim;
- seleção de duração;
- posicionamento temporal de elementos;
- preview.

---

# 18. Sistema de Elements

O editor utilizará um sistema genérico de elementos.

```text
Element
├── id
├── type
├── position
├── scale
├── rotation
├── opacity
├── startTime
├── endTime
└── properties
```

Tipos:

```text
text
brush
sticker
overlay
frame
```

Isso permitirá expansão futura.

---

# 19. Texto

O usuário poderá adicionar múltiplos elementos de texto.

Recursos:

- adicionar;
- editar;
- mover;
- redimensionar;
- rotacionar;
- excluir;
- duplicar;
- alterar fonte;
- tamanho;
- peso;
- alinhamento;
- cor;
- opacidade;
- letter spacing;
- line height;
- sombra;
- outline;
- background.

---

# 20. Text Presets

O produto poderá oferecer estilos de texto prontos.

Exemplos:

```text
Editorial
Minimal
Film
Handwritten
Bold
Typewriter
Classic
```

Um text preset poderá definir:

```text
font
size
color
letterSpacing
lineHeight
shadow
outline
background
```

---

# 21. Text Brush

Text Brush será uma ferramenta de desenho manual sobre a mídia.

O usuário poderá desenhar usando o dedo.

Tipos iniciais:

- Pen
- Marker
- Pencil
- Chalk
- Paint
- Highlighter

Configurações:

- tamanho;
- opacidade;
- cor;
- suavidade;
- brush type.

---

# 22. Representação do Brush

Um brush deverá ser armazenado como uma coleção de strokes.

```text
BrushElement
├── brushType
├── size
├── color
├── opacity
└── strokes
    ├── stroke
    │   ├── points
    │   └── pressure
    └── stroke
```

Quando disponível, pressure deverá ser capturado.

O sistema deverá funcionar mesmo em dispositivos sem suporte a pressure.

---

# 23. Text Brush em Vídeo

O Text Brush poderá ser aplicado sobre vídeos.

Na V1, não será necessário:

- object tracking;
- motion tracking automático;
- reconhecimento de objetos.

O brush poderá possuir:

```text
startTime
endTime
```

e permanecer visível durante aquele intervalo.

---

# 24. Stickers

Stickers serão assets remotos distribuídos pelo Content Backend.

Formatos possíveis:

- PNG;
- WebP;
- SVG quando suportado pelo pipeline;
- outros formatos internos conforme necessidade.

O usuário poderá:

- adicionar;
- mover;
- redimensionar;
- rotacionar;
- ajustar opacidade;
- excluir.

---

# 25. Overlays

Overlays poderão ser utilizados para:

- light leaks;
- dust;
- film burns;
- scratches;
- textures;
- efeitos analógicos.

Eles deverão funcionar em:

- foto;
- vídeo.

---

# 26. Frames

A arquitetura deverá suportar frames.

Frames poderão definir:

- proporção;
- bordas;
- cor;
- textura;
- margem;
- estilo.

Frames não precisam ter dezenas de opções na primeira versão.

---

# 27. Before / After

O editor deverá permitir comparar:

```text
Original
vs.
Edited
```

O gesto principal será pressionar e segurar o preview para visualizar a mídia original.

---

# 28. Undo / Redo

O editor deverá suportar:

- Undo;
- Redo.

As operações deverão ser baseadas no estado da edição sempre que possível, evitando armazenar cópias completas da mídia para cada etapa.

---

# 29. Copy / Paste Edits

O usuário poderá:

```text
Copy Edits
```

e posteriormente:

```text
Paste Edits
```

em outra mídia.

O sistema deverá copiar:

- adjustments;
- preset;
- preset intensity.

Elementos como texto/stickers poderão ser tratados separadamente.

---

# 30. Favoritos

O usuário poderá favoritar:

- presets;
- coleções;
- stickers.

Favoritos serão armazenados localmente.

---

# 31. Native Media Engine

Flutter não será responsável sozinho pelo processamento pesado.

O engine nativo será responsável por:

- decoding;
- rendering;
- GPU processing;
- encoding;
- exportação;
- operações de imagem;
- operações de vídeo.

---

# 32. Native Bridge

Flutter deverá possuir uma camada de abstração.

```text
Flutter
   ↓
MediaEngine interface
   ↓
Native Bridge
   ├── Android/Kotlin
   └── iOS/Swift
```

A UI não deverá depender diretamente de APIs específicas do Android/iOS.

---

# 33. GPU Rendering

Preview deverá utilizar GPU sempre que necessário para obter uma experiência fluida.

Pipeline conceitual:

```text
Media
  ↓
Decoder
  ↓
GPU Texture
  ↓
Adjustments
  ↓
Preset
  ↓
Elements
  ↓
Preview
```

Para vídeo:

```text
Video Decoder
      ↓
GPU Texture
      ↓
Frame Processing
      ↓
Effects
      ↓
Elements
      ↓
Display
```

---

# 34. Exportação

O usuário deverá escolher opções compatíveis com a mídia.

Para foto:

- JPEG;
- PNG quando aplicável;
- qualidade;
- resolução.

Para vídeo:

- resolução;
- frame rate quando aplicável;
- qualidade;
- áudio ligado/desligado.

O export deverá ocorrer no dispositivo.

---

# 35. Exportação em Background

Exportações longas deverão poder continuar fora do fluxo imediato da UI, utilizando mecanismos nativos apropriados.

O usuário deverá receber:

- progresso;
- sucesso;
- erro;
- possibilidade de cancelar quando suportado.

---

# 36. Armazenamento Local

O aplicativo não terá cloud storage de usuários.

Arquivos serão armazenados no dispositivo.

Estrutura conceitual:

```text
App Storage
├── projects/
├── previews/
├── cache/
├── downloaded_content/
└── exports/
```

A implementação poderá utilizar diretórios apropriados de cada plataforma.

---

# 37. Banco Local

O banco local armazenará metadados.

Exemplo:

```text
projects
├── id
├── mediaPath
├── mediaType
├── projectData
├── createdAt
└── updatedAt
```

`projectData` poderá armazenar uma representação serializada da edição.

A tecnologia específica de persistência poderá ser escolhida durante implementação, priorizando simplicidade e confiabilidade.

---

# 38. Cache

O conteúdo remoto deverá ser cacheado localmente.

Exemplo:

```text
Content
├── catalog
├── presets
├── stickers
├── overlays
├── fonts
└── thumbnails
```

O app não deverá baixar repetidamente assets já disponíveis localmente.

---

# 39. Offline

Depois de baixados, conteúdos deverão continuar utilizáveis offline.

O aplicativo deverá funcionar offline para:

- abrir projetos;
- editar;
- aplicar presets disponíveis;
- utilizar assets baixados;
- exportar.

Internet será necessária apenas para funcionalidades que dependem de serviços externos, como:

- primeira sincronização de conteúdo;
- novos downloads;
- verificação de entitlement quando necessário;
- billing.

---

# 40. Content Backend

O backend não será responsável pelos projetos pessoais dos usuários.

Sua única função será distribuir conteúdo do aplicativo.

```text
Content Backend
├── Presets
├── Collections
├── Stickers
├── Overlays
├── Fonts
├── Frames
└── Metadata
```

---

# 41. Content Admin

Será criado um Admin Web privado.

Stack recomendada:

- Next.js;
- PostgreSQL/Neon;
- R2;
- API integrada ao próprio Next.js.

O Admin não será acessível aos usuários comuns.

---

# 42. Admin — Presets

O administrador poderá:

- criar preset;
- editar preset;
- duplicar preset;
- visualizar preset;
- definir nome;
- definir descrição;
- selecionar coleção;
- alterar parâmetros;
- publicar;
- despublicar;
- versionar.

Exemplo:

```text
Preset
├── id
├── name
├── description
├── collectionId
├── version
├── settings
├── thumbnail
├── isPremium
├── status
├── createdAt
└── updatedAt
```

---

# 43. Admin — Collections

O administrador poderá criar:

```text
Film
Vintage
Moody
Clean
Summer
Travel
```

Cada coleção poderá possuir:

- nome;
- descrição;
- thumbnail;
- ordem;
- status;
- conteúdo;
- acesso free/pro.

---

# 44. Admin — Assets

O administrador poderá fazer upload de:

- stickers;
- overlays;
- frames;
- thumbnails;
- outros assets.

Cada asset deverá possuir:

```text
Asset
├── id
├── type
├── name
├── collectionId
├── file
├── thumbnail
├── metadata
├── isPremium
├── version
├── status
└── createdAt
```

---

# 45. R2

Cloudflare R2 será utilizado para assets.

Exemplo:

```text
R2
├── presets/
├── stickers/
├── overlays/
├── frames/
├── fonts/
└── thumbnails/
```

O banco não armazenará os arquivos binários.

O banco armazenará metadados e referências.

---

# 46. Content API

O aplicativo deverá consumir uma API simples.

Exemplo:

```text
GET /content/catalog
```

Retornará:

- collections;
- presets;
- assets;
- versões;
- URLs;
- metadados;
- entitlement requirements.

---

# 47. Versionamento de Conteúdo

O catálogo deverá possuir uma versão.

Exemplo:

```json
{
  "catalogVersion": 12
}
```

O aplicativo poderá enviar sua versão atual:

```text
GET /content/catalog?version=12
```

Se não houver mudanças:

```text
304 / no update
```

Caso existam:

```text
new catalog
```

O mecanismo exato poderá variar.

---

# 48. Download Incremental

O aplicativo não deverá baixar todo o conteúdo novamente quando houver uma atualização.

Exemplo:

```text
Catalog v10
     ↓
Catalog v11
     ↓
Download only new assets
```

Assets antigos deverão permanecer no cache enquanto ainda forem utilizados.

---

# 49. RevenueCat

RevenueCat será responsável pela monetização.

O app terá um entitlement principal:

```text
pro
```

Produtos:

```text
monthly
yearly
lifetime
```

A disponibilidade exata dos produtos poderá variar por plataforma.

---

# 50. Conteúdo Free vs Pro

Cada preset/asset poderá definir:

```text
isPremium
```

Exemplo:

```text
Film
├── 3 free presets
└── 17 Pro presets
```

O app verificará o entitlement antes de permitir recursos premium.

---

# 51. Paywall

O paywall deverá ser simples e visual.

Deverá comunicar:

- quantidade de presets;
- coleções;
- stickers;
- overlays;
- recursos Pro;
- preço;
- período;
- restauração de compras.

Não deverá interromper a experiência excessivamente.

---

# 52. Home

A home deverá apresentar:

```text
Recent Projects

[ project ]
[ project ]
[ project ]

Create
[ Photo ]
[ Video ]

Collections / Discover
```

O design deverá ser minimalista e premium.

---

# 53. Media Picker

O usuário deverá conseguir escolher:

- uma foto;
- um vídeo.

A experiência deverá respeitar os padrões nativos de cada plataforma.

---

# 54. Editor UX

O preview deverá ocupar a maior parte da tela.

Estrutura conceitual:

```text
┌──────────────────────────────┐
│          Preview             │
│                              │
│                              │
│                              │
├──────────────────────────────┤
│ Adjust  Presets  Text Brush  │
├──────────────────────────────┤
│          Controls            │
└──────────────────────────────┘
```

Para vídeo:

```text
┌──────────────────────────────┐
│          Preview             │
├──────────────────────────────┤
│ Timeline                     │
├──────────────────────────────┤
│ Tools                        │
└──────────────────────────────┘
```

---

# 55. Design System

O aplicativo deverá ter identidade própria.

Não deverá parecer:

- template genérico de Flutter;
- clone de CapCut;
- dashboard SaaS;
- aplicativo gerado por IA.

A interface deverá priorizar:

- tipografia forte;
- espaços generosos;
- preview grande;
- controles discretos;
- animações suaves;
- hierarquia visual clara;
- poucos elementos simultaneamente na tela.

---

# 56. Performance

Metas iniciais:

- sliders devem responder sem sensação perceptível de atraso;
- preview de foto deve atualizar rapidamente;
- preview de vídeo deve permanecer fluido quando possível;
- UI Flutter não deverá bloquear durante processamento;
- exportação não deverá congelar a interface.

Operações pesadas deverão ser delegadas ao native engine.

---

# 57. Memória

O aplicativo deverá evitar carregar simultaneamente múltiplas imagens em resolução máxima.

Deverá utilizar:

- thumbnails;
- previews;
- resolução adaptativa;
- GPU textures;
- caching;
- processamento por etapas.

---

# 58. Segurança

Como não haverá dados de usuário no backend:

- nenhuma senha será armazenada;
- nenhum perfil será armazenado;
- nenhuma foto pessoal será enviada;
- nenhum projeto pessoal será enviado.

O Content Backend deverá possuir autenticação própria para o Admin.

---

# 59. Privacidade

Princípio:

> **User media stays on the user's device.**

O aplicativo não deverá enviar fotos ou vídeos do usuário para servidores próprios.

O Privacy Policy deverá deixar isso explícito.

---

# 60. Analytics

Analytics não deverá exigir criação de conta.

Eventos anônimos poderão ser utilizados futuramente para compreender:

- presets utilizados;
- ferramentas utilizadas;
- exportações;
- conversões para Pro;
- falhas de exportação;
- crashes.

Nenhuma mídia pessoal deverá ser enviada como parte dos eventos.

A implementação de analytics deverá ser avaliada separadamente.

---

# 61. Testes Flutter

Deverão existir testes para:

- models;
- preset interpolation;
- project serialization;
- undo/redo;
- copy/paste edits;
- entitlement logic;
- content catalog parsing;
- cache;
- editor state.

---

# 62. Testes Native

Deverão existir testes para:

- rendering;
- filters;
- preset application;
- image export;
- video export;
- decoding;
- encoding;
- brush rendering;
- text rendering;
- GPU pipeline.

---

# 63. Testes de Integração

Fluxos principais:

### Foto

```text
Import photo
→ Apply preset
→ Adjust
→ Add text
→ Add brush
→ Export
```

### Vídeo

```text
Import video
→ Trim
→ Apply preset
→ Add text
→ Add brush
→ Export
```

### Conteúdo

```text
Publish preset in Admin
→ App sync
→ Download
→ Cache
→ Use offline
```

### Monetização

```text
Free user
→ Select Pro content
→ Paywall
→ Purchase
→ Entitlement
→ Content unlocked
```

---

# 64. Crash / Error Handling

Erros de processamento deverão ser tratados de forma amigável.

Exemplos:

```text
Unable to export video.
Try again.
```

ou:

```text
Not enough storage available.
```

O aplicativo não deverá simplesmente encerrar.

---

# 65. Armazenamento Insuficiente

Antes de exportações grandes, o aplicativo deverá detectar possíveis problemas de armazenamento quando possível.

Deverá informar o usuário caso não haja espaço suficiente.

---

# 66. Compatibilidade

O aplicativo deverá suportar versões recentes de:

- Android;
- iOS.

A matriz exata de versões mínimas deverá ser definida durante implementação conforme APIs de GPU/media utilizadas.

---

# 67. Roadmap

## Fase 1 — Core

- Flutter setup;
- navegação;
- projeto local;
- media picker;
- editor básico;
- armazenamento local.

## Fase 2 — Photo Engine

- adjustments;
- presets;
- crop;
- GPU rendering;
- exportação.

## Fase 3 — Video Engine

- decoder;
- preview;
- trim;
- adjustments;
- presets;
- exportação.

## Fase 4 — Elements

- text;
- Text Brush;
- stickers;
- overlays;
- frames.

## Fase 5 — UX

- before/after;
- undo/redo;
- copy/paste edits;
- favorites;
- collections.

## Fase 6 — Monetização

- RevenueCat;
- Pro entitlement;
- paywall;
- free/pro content.

## Fase 7 — Content Platform

- Admin Web;
- Content API;
- Neon/Postgres;
- R2;
- catalog versioning;
- content sync;
- remote assets.

## Fase 8 — Polish

- performance;
- animations;
- crash handling;
- export reliability;
- App Store;
- Google Play.

---

# 68. MVP Definition

O MVP funcional estará completo quando o usuário puder:

1. abrir o aplicativo;
2. selecionar uma foto;
3. editar a foto;
4. aplicar um preset;
5. ajustar parâmetros;
6. adicionar texto;
7. desenhar usando Text Brush;
8. adicionar sticker;
9. exportar a foto;

e também:

10. selecionar um vídeo;
11. cortar o vídeo;
12. aplicar um preset;
13. ajustar parâmetros;
14. adicionar texto;
15. adicionar Text Brush;
16. adicionar sticker;
17. exportar o vídeo.

Além disso:

18. projetos deverão ser salvos localmente;
19. edição deverá funcionar offline;
20. RevenueCat deverá controlar o acesso Pro.

O Content Backend poderá ser inicialmente adicionado após o editor principal estar funcional.

---

# 69. Critérios de Aceitação

## Editor

- [ ] Foto pode ser importada.
- [ ] Vídeo pode ser importado.
- [ ] Foto pode ser editada.
- [ ] Vídeo pode ser editado.
- [ ] Presets funcionam nos dois formatos.
- [ ] Ajustes funcionam em tempo real.
- [ ] Texto funciona em foto.
- [ ] Texto funciona em vídeo.
- [ ] Text Brush funciona em foto.
- [ ] Text Brush funciona em vídeo.
- [ ] Stickers funcionam.
- [ ] Overlays funcionam.
- [ ] Undo/redo funciona.
- [ ] Before/after funciona.
- [ ] Exportação funciona.

## Offline

- [ ] Projetos podem ser abertos offline.
- [ ] Edições podem ser realizadas offline.
- [ ] Assets previamente baixados continuam disponíveis offline.
- [ ] Exportação funciona offline.

## Monetização

- [ ] RevenueCat está integrado.
- [ ] Entitlement Pro funciona.
- [ ] Conteúdo premium é protegido.
- [ ] Restore purchases funciona.

## Content Platform

- [ ] Admin pode criar preset.
- [ ] Admin pode editar preset.
- [ ] Admin pode publicar preset.
- [ ] Admin pode criar coleção.
- [ ] Admin pode subir sticker.
- [ ] Admin pode subir overlay.
- [ ] Assets são armazenados no R2.
- [ ] Metadados são armazenados no PostgreSQL.
- [ ] App sincroniza catálogo.
- [ ] App faz cache local.
- [ ] Atualizações são incrementais.

---

# 70. Decisões Arquiteturais Finais

| Área | Decisão |
|---|---|
| Mobile | Flutter |
| Android Native | Kotlin |
| iOS Native | Swift |
| Rendering | Native/GPU |
| Photo Editing | Native Engine + Flutter UI |
| Video Editing | Native Engine + Flutter UI |
| Text | Flutter + Native Rendering quando necessário |
| Text Brush | Flutter input + Native rendering/export |
| Projects | Local |
| Database | Local |
| User Backend | Não |
| Login | Não |
| Cloud User Storage | Não |
| Billing | RevenueCat |
| Admin | Next.js |
| Content API | Next.js |
| Content Database | PostgreSQL / Neon |
| Asset Storage | Cloudflare R2 |
| Presets | Declarativos |
| Presets Photo + Video | Sistema compartilhado |
| Stickers | Remote Content |
| Overlays | Remote Content |
| Offline Editing | Sim |
| Batch Editing | Não |
| AI | Não na V1 |

---

# 71. Princípio Final

O produto deverá seguir uma filosofia simples:

> **Powerful editing without feeling like a professional editor.**

Para o usuário, o aplicativo deve parecer extremamente simples.

Por baixo, entretanto, deverá possuir uma arquitetura capaz de lidar com:

- GPU rendering;
- foto;
- vídeo;
- presets;
- filtros;
- layers;
- texto;
- Text Brush;
- stickers;
- overlays;
- conteúdo remoto;
- monetização;
- edição não destrutiva.

A infraestrutura online deve existir **somente onde agrega valor**.

O usuário não precisa de uma conta.

O usuário não precisa enviar sua mídia para a nuvem.

O usuário não precisa de um projeto salvo em servidor.

O backend existe para o **produto**, não para armazenar a vida do usuário.

Isso mantém o aplicativo barato, privado, rápido e simples, enquanto permite que o proprietário continue lançando novos presets, coleções e assets ao longo do tempo sem precisar atualizar o aplicativo a cada novo conteúdo.