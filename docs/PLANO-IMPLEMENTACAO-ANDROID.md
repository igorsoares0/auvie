# Plano de Implementação — Auvie (Android first)

**Base:** `docs/Spec-Driven-Development — Photo & Video Editor.md` (spec v1.0) + `docs/design_handoff_epreuve/README.md` (22 telas)
**Nome do produto:** **Auvie**. O handoff usa "Épreuve" como nome provisório; wordmark, textos e "ÉPREUVE PRO" passam a ser "AUVIE" / "Auvie" / "AUVIE PRO".
**Versionamento:** feito manualmente pelo dono do projeto. Nenhuma tarefa deste plano executa comandos git.
**Escopo deste plano:** app Android. iOS fica fora por ora, mas a arquitetura mantém o ponto de extensão (interface `MediaEngine` em Dart).
**Versões verificadas em:** 2026-10-08 (pub.dev, Google Maven, Maven Central, releases do Flutter)

---

## 1. Ponto de partida

| Item | Estado atual | Ação |
|---|---|---|
| Código | Template contador do Flutter (`lib/main.dart`) | Substituir na M0 |
| Flutter local | 3.44.7 / Dart 3.12.2 | **Atualizar para 3.47.6 / Dart 3.13.5** — `freezed 4`, `riverpod_lint 3` e `very_good_analysis 11` exigem Dart ≥ 3.13 |
| Flutter no WSL | SDK instalado no Windows (`/mnt/c/flutter`), falha no bash por CRLF | Rodar `flutter` pelo PowerShell **ou** instalar um SDK Linux dentro do WSL (recomendado: emulador/adb continuam no Windows) |
| Android | AGP 9.0.1, Kotlin 2.3.20, Gradle 9.1.0 | Subir para AGP 9.4.1 / Kotlin 2.4.21 (validar com `flutter build apk`; se o Flutter 3.47 reclamar, usar a versão que o template do 3.47 gera) |
| `applicationId` | `com.example.auvie` | Definir o definitivo (ex.: `app.auvie`) antes de qualquer upload no Play Console (não pode mudar depois) |
| Git | Pasta não é um repositório | Responsabilidade do dono do projeto (manual) |
| Plataformas | android, ios, linux, macos, windows, web | Manter `android` e `ios`; remover as demais reduz ruído (opcional) |

---

## 2. Decisões de arquitetura (Android)

### 2.1 Divisão Flutter × Kotlin

```text
Flutter (Dart)                                   Kotlin (Android)
───────────────────────────────────────────      ─────────────────────────────────────────
UI, navegação, estado, undo/redo                 Photo Picker + permissões de URI
Modelo do projeto (JSON) + Drift                 Decode / thumbnails / probe de mídia
Catálogo de presets (bundled → remoto)           Shader "develop" (GLSL, OpenGL ES 3)
Elementos: texto, Text Brush, stickers           Preview foto: EGL → SurfaceProducer
  → desenhados como widgets no preview           Preview vídeo: ExoPlayer + GlEffect
  → rasterizados em PNG no export                Export foto: FBO full-res + encoder
RevenueCat / paywall / gating                    Export vídeo: Media3 Transformer
MediaEngine (interface)  ──── Pigeon ────►       WorkManager (export em background)
                                                 MediaStore (salvar na galeria)
```

### 2.2 Decisões-chave

1. **Bridge com Pigeon** (type-safe, gera Dart + Kotlin). A UI só conhece `abstract class MediaEngine`; `AndroidMediaEngine` usa Pigeon; `FakeMediaEngine` é usado em testes de widget.
2. **Um único shader "develop"** em GLSL, reutilizado em quatro lugares: preview de foto, export de foto, preview de vídeo (`ExoPlayer.setVideoEffects`) e export de vídeo (`Transformer`). Garante que o preset fica idêntico em foto e vídeo (spec §4.5).
   - Uniforms: exposure, brightness, contrast, highlights, shadows, saturation, temperature, tint, sharpen, fade, vignette, grain (+ seed/tempo).
   - Curves: LUT 256×1 RGBA gerada em Dart a partir dos pontos da curva e enviada como textura.
   - Overlays (light leak, poeira, film burn): segunda textura com blend mode (screen/multiply/overlay) no próprio shader.
3. **Elementos renderizados uma única vez, em Flutter.** Texto, Text Brush e stickers são widgets/`CustomPainter` no preview; no export, o Flutter rasteriza cada elemento (`PictureRecorder` → PNG na resolução final) e o nativo compõe:
   - foto: composição direta sobre o FBO;
   - vídeo: `OverlayEffect` + `BitmapOverlay` com visibilidade por `startTime/endTime`.

   Isso evita duas implementações de tipografia (Flutter e Kotlin) e garante WYSIWYG. Atende ao §70 ("Text: Flutter + Native rendering quando necessário").
4. **Preview em resolução de tela**, full-res só no export (spec §57). Decode com `inSampleSize`; fotos maiores que `GL_MAX_TEXTURE_SIZE` são exportadas em tiles.
5. **Slider a 60 Hz:** o Dart envia `updateEdit(params)` a cada frame; o nativo guarda só o último valor e renderiza no thread GL no próximo vsync (coalescing). A UI nunca espera o render.
6. **Picker:** Android Photo Picker (`PickVisualMedia`) chamado pelo Kotlin — **não exige permissão de galeria**. O projeto guarda a URI com `takePersistableUriPermission`. Consequência no design: as telas O4 (acesso) e S2 (sem acesso) viram uma tela explicativa simples no Android.
7. **Salvar na galeria via MediaStore** (`IS_PENDING`), sem permissão de escrita → **minSdk 29 (Android 10)**. Também simplifica codecs e GL ES 3.
8. **Export em background:** `WorkManager` com foreground service (`mediaProcessing` no Android 15+, `dataSync` antes), notificação de progresso, cancelamento. Progresso chega ao Flutter por `@EventChannelApi` do Pigeon.
9. **Edição não destrutiva + undo/redo por estado:** `EditState` imutável (freezed); o histórico guarda estados (só parâmetros — poucos KB). Arrastar slider gera **um** passo de histórico (commit no fim do gesto).
10. **Autosave** com debounce (~500 ms) no Drift; o JSON do projeto tem `schemaVersion` e migrações.
11. **Conteúdo V1 empacotado** (`assets/content/catalog.json` + PNGs). `CatalogRepository` tem duas fontes: `BundledCatalogSource` agora, `RemoteCatalogSource` na M8 — a UI não muda.
12. **Gating Pro só no export** (design): presets/fontes Pro fazem preview livre; o paywall aparece ao exportar. **Não há marca d'água** em nenhum plano.
13. **Fontes empacotadas** (Newsreader, Jost, Geist, IBM Plex Mono, Caveat — OFL), nunca baixadas em runtime: o app tem de funcionar offline.

### 2.3 Estrutura de pastas

Segue a spec §7, com o detalhe da bridge:

```text
lib/
├── app/            app.dart, router/ (go_router), theme/ (tokens paper/darkroom, tipografia)
├── core/
│   ├── models/     Project, EditState, Adjustments, PresetRef, Transform, Element (+subtipos)
│   ├── storage/    Drift DB, ProjectRepository, AppPaths (projects/ previews/ cache/ exports/)
│   ├── native/     MediaEngine (interface), AndroidMediaEngine, pigeon gerado
│   ├── content/    CatalogRepository, BundledCatalogSource, (RemoteCatalogSource)
│   └── utils/
├── features/
│   ├── onboarding/ home/ projects/ archive/
│   ├── editor/     shell/, photo/, video/, adjustments/, presets/, crop/,
│   │               text/, brush/, stickers/, overlays/, frames/, history/
│   ├── export/  subscription/  settings/
└── main.dart
pigeons/media_api.dart                       # definição da bridge
android/app/src/main/kotlin/.../engine/       # gl/, photo/, video/, export/, picker/, store/
android/app/src/main/assets/shaders/develop.frag
test_fixtures/                                # vetores compartilhados Dart ⇄ Kotlin
```

### 2.4 Esboço da bridge (Pigeon)

```dart
@HostApi()
abstract class MediaHostApi {
  @async PickedMedia? pickMedia(MediaKind kind);
  @async MediaInfo probe(String uri);                        // dimensões, duração, rotação, áudio
  @async Uint8List thumbnail(String uri, int maxPx, int? atMs);
  @async int createPreview(PreviewRequest req);              // retorna textureId
  void updateEdit(int textureId, EditParams params);         // caminho rápido, coalescido
  void setShowOriginal(int textureId, bool original);        // segurar = before/after
  void play(int textureId); void pause(int textureId); void seek(int textureId, int ms);
  void disposePreview(int textureId);
  @async String startExport(ExportRequest req);              // retorna jobId
  void cancelExport(String jobId);
  int availableBytes();                                      // checagem de espaço (§65)
}

@EventChannelApi()
abstract class MediaEvents {
  ExportEvent exportEvents();   // progress | done(uri) | error(code)
}
```

---

## 3. Bibliotecas (versões atuais em 2026-10-08)

### 3.1 Flutter / Dart

| Pacote | Versão | Uso |
|---|---|---|
| Flutter SDK | **3.47.6** (Dart 3.13.5) | `environment.sdk: ^3.13.0` |
| `flutter_riverpod` | 3.4.3 | Estado / DI |
| `riverpod_annotation` | 4.0.7 | Providers gerados |
| `go_router` | 18.0.2 | Navegação em pilha (sem tab bar) |
| `freezed_annotation` | 3.1.0 | Modelos imutáveis |
| `json_annotation` | 4.12.0 | Serialização |
| `drift` | 2.35.2 | Banco local |
| `drift_flutter` | 0.3.1 | Abertura do banco no Flutter |
| `path_provider` | 2.1.6 | Diretórios do app |
| `path` | 1.9.1 | |
| `shared_preferences` | 2.5.6 | Flags simples (onboarding visto, último preset) |
| `purchases_flutter` | 10.15.2 | RevenueCat (M7) |
| `flutter_svg` | 2.3.0 | Ícones do handoff (`icons/*.svg`) |
| `share_plus` | 13.3.1 | Compartilhar export |
| `uuid` | 4.6.0 | IDs de projeto/elemento |
| `collection` | 1.19.1 | |
| `dio` | 5.11.1 | **Só na M8** (catálogo remoto, download com progresso) |

**dev_dependencies**

| Pacote | Versão | Uso |
|---|---|---|
| `build_runner` | 2.16.2 | Codegen |
| `freezed` | 4.0.2 | |
| `json_serializable` | 6.14.1 | |
| `riverpod_generator` | 4.0.9 | |
| `riverpod_lint` | 3.1.9 | Agora usa `analysis_server_plugin` (não precisa mais de `custom_lint`) |
| `drift_dev` | 2.35.1 | |
| `pigeon` | 29.0.7 | Gera a bridge |
| `very_good_analysis` | 11.0.0 | Lints (substitui `flutter_lints`; desligar `public_member_api_docs`) |
| `mocktail` | 1.0.5 | Mocks |
| `patrol` | 4.10.0 | Testes E2E (interage com o Photo Picker do sistema) |
| `flutter_test`, `integration_test` | SDK | |

CLI global: `patrol_cli` 4.8.0.

**Não usar:**
- `sqlite3_flutter_libs` está **EOL** (0.6.0+eol); o `sqlite3` 3.x já empacota o nativo via build hooks.
- `image_picker` copia o arquivo para o cache e devolve um path; queremos URI persistível (decisão 2.2-6).
- `google_fonts` baixa fontes em runtime e quebra o offline.

### 3.2 Android (Kotlin) — usar version catalog `gradle/libs.versions.toml`

| Artefato | Versão |
|---|---|
| Android Gradle Plugin | 9.4.1 |
| Kotlin | 2.4.21 |
| `androidx.media3:media3-exoplayer` / `-transformer` / `-effect` / `-common` | 1.11.1 |
| `androidx.work:work-runtime-ktx` | 2.12.0 |
| `org.jetbrains.kotlinx:kotlinx-coroutines-android` | 1.11.0 |
| `androidx.exifinterface:exifinterface` | 1.4.2 |
| `androidx.activity:activity-ktx` | 1.13.0 |
| **Testes:** `junit` 4.13.2, `org.robolectric:robolectric` 4.17, `com.google.truth:truth` 1.4.5, `androidx.test.ext:junit` 1.3.0, `androidx.test:runner` 1.7.0, `androidx.media3:media3-test-utils` 1.11.1 | |

`minSdk 29`, `targetSdk`/`compileSdk` = os do Flutter 3.47 (`flutter.targetSdkVersion`).

---

## 4. Marcos (milestones)

Cada marco termina com app rodando, testes verdes e critérios da spec §69 marcados.
Tamanho relativo: **P** pequeno · **M** médio · **G** grande.

### M0 — Fundação (P)
- Upgrade Flutter 3.47.6; dependências da seção 3; `very_good_analysis`; `build_runner` configurado.
- `applicationId`, nome do app ("Auvie"), ícone provisório; `minSdk 29`; version catalog no Gradle.
- Tema: tokens do handoff (`paper`, `ink`, `darkroom`, `bone`, `safelight`…), tipografia (Newsreader/Jost/Geist), raio 0, hairlines; tema claro/escuro do editor segue o sistema.
- `go_router` com rotas: onboarding, home, editor/photo, editor/video, export, archive, pro, settings.
- Ícones SVG do handoff em `assets/icons/`.
- Script local `tool/ci.sh`: codegen → analyze → testes Dart → testes JVM Kotlin. (Um workflow de CI pode ser adicionado quando o repositório existir.)

**Testes:** smoke test do app (substitui o `widget_test.dart` do contador); teste de contraste dos tokens (≥ 4.5:1, como o handoff exige).

### M1 — Domínio e persistência (M) — *Dart puro, sem UI*
- Modelos freezed: `Project`, `EditState`, `Adjustments` (13 parâmetros normalizados −1…+1, §11), `Curves`, `PresetRef {id, intensity}`, `CropTransform {rect, rotation, flipH, flipV, aspect}`, `Element` (sealed: `TextElement`, `TextPathElement`, `BrushElement`, `StickerElement`, `OverlayElement`, `FrameElement`), `VideoTimeline {trimStart, trimEnd, muted}`.
- `Preset` + interpolação de intensidade (`final = base + delta × intensity`, com clamp por parâmetro, §13).
- `EditHistory` (undo/redo; limite de passos; coalescing).
- Copy/Paste edits (§29: adjustments + preset + intensidade).
- Drift: tabela `projects` (§37) + `favorites`; `ProjectRepository`; `AppPaths`; `schemaVersion` + migração.
- `CatalogRepository` + `BundledCatalogSource` + `catalog.json` inicial (6 presets do handoff: Ektar 02, Portra 04, Cendre 11, Nocturne 19, Vitrine, Portra Fade).

**Testes (spec §61):** models, preset interpolation, project serialization (round-trip + migração v1→v2), undo/redo, copy/paste, catalog parsing, editor state. Banco Drift em memória (`NativeDatabase.memory()`). Meta: **≥ 90% de cobertura** em `core/`.

### M2 — Bridge e photo engine (G) — *maior risco técnico, começar cedo*
- `pigeons/media_api.dart` + geração Dart/Kotlin; `MediaEngine`, `AndroidMediaEngine`, `FakeMediaEngine`.
- Kotlin: Photo Picker + URI persistível; `probe`; thumbnails (`ImageDecoder` / `MediaMetadataRetriever`); orientação EXIF.
- GL: contexto EGL próprio, `develop.frag`, LUT de curvas, grain procedural, render para `TextureRegistry.SurfaceProducer`; tratar `onSurfaceCleanup`/`onSurfaceAvailable` (app em background).
- `updateEdit` coalescido; `setShowOriginal`.
- `test_fixtures/edit_vectors.json`: os mesmos casos (params → pixel esperado) usados pelos testes Dart e Kotlin.

**Testes:**
- JVM/Robolectric: mapeamento `EditParams` → uniforms, geração de LUT, coalescer, parsing de vetores.
- Instrumentado (`androidTest`, emulador com GPU `swiftshader_indirect` ou aparelho real): renderiza imagem de referência 64×64 com cada vetor e compara pixels com tolerância (Δ ≤ 2/255 por canal); identidade = imagem original; golden de cada preset bundled.

**Estado (2026-10-08):** concluída e validada num Redmi Note 10 (Adreno 612). O preview renderiza no tamanho em que aparece na tela (`lib/core/native/preview_size.dart`). Testes no aparelho: rodar com `adb install` + `adb shell am instrument -w -r app.auvie.test/androidx.test.runner.AndroidJUnitRunner`, porque o `connectedDebugAndroidTest` não termina pela ponte WSL/PowerShell.
**Pendente (calibragem):** valores dos 6 presets em `assets/content/catalog.json` e intensidade de `GRAIN_AMOUNT` / `SHARPEN_AMOUNT` em `develop.frag` (hoje fracos). Fazer no laboratório `/dev/engine`, em build profile.

### M3 — Shell e editor de foto (M)
- Onboarding O1–O3 + tela de acesso adaptada ao Android (sem pedido de permissão).
- Home: tiles Photo/Video, recentes (3 colunas), estado vazio S1, rodapé de coleção.
- Editor: header (CLOSE / título / EXPORT), preview `Texture`, legenda de estado ("Ektar, at 72%"), undo/redo, segurar para comparar.
- Ferramenta **FILM**: categorias, cards com preview da própria foto (thumbnails renderizados pelo engine em baixa resolução), tag ATELIER, slider de intensidade.
- Ferramenta **ADJUST**: um parâmetro por vez, régua estilo lente, swipe troca parâmetro, double-tap reseta, haptics em 0 e nos ticks maiores; 5 famílias.
- Cross-fade de 180 ms entre ferramentas; a foto nunca se move.
- Autosave.

**Testes:** widget tests com `FakeMediaEngine` (troca de ferramenta mantém estado, double-tap reseta, undo/redo pela UI, segurar → `setShowOriginal(true)`); **goldens** das telas Home, Presets e Adjust nos temas claro/escuro (fontes reais carregadas no teste; goldens gerados só no CI Linux).

**Estado (2026-10-08):** concluída. Goldens em `test/goldens/screens/`, gerados no Windows (regenerar com `flutter test --update-goldens --tags golden` se a plataforma de referência mudar).
**Provisório:** as fotos do handoff (Unsplash) foram trocadas por arte gerada a partir das faixas de tom (`lib/app/widgets/film_art.dart`) até haver imagens licenciadas; CROP fica desabilitado até a M4; TYPE/BRUSH/ADD até a M5.

### M4 — Crop/transform e export de foto (M) — *fecha o MVP de foto sem elementos*
- Crop: aspect ratios (Original, 1:1, 4:5, 3:4, 9:16, 16:9), rotate 90°, straighten, flip.
- Tela Export: formato (JPEG / PNG — HEIF foi removido do produto), tamanho (Original / Large / Web), toggle de metadados (desligado por padrão → EXIF removido, exceto orientação).
- Pipeline: decode full-res → shader → (elementos, na M5) → encoder → `exports/` → MediaStore → share.
- Checagem de espaço antes (§65); estados S3 (revelando), S4 (concluído), S5 (erro: storage cheio, tentar menor).

**Testes:** instrumentado (dimensões por opção de tamanho, formato, EXIF removido/mantido, arquivo visível no MediaStore, imagem 48 MP não estoura memória); unit do cálculo de crop/aspect; widget tests dos estados S3–S5 com engine fake emitindo progresso/erro.

**Estado (2026-10-09):** concluída; testes no aparelho verdes no Redmi Note 10. A geometria (recorte, giros, flip, endireitar) é calculada em Dart (`lib/core/models/crop_geometry.dart`) e aplicada pelo shader, igual no preview e no export. Export em blocos de 2048 px, teto de 32 MP, salvo em `Pictures/Auvie`.
**Fora por ora:** STORY no S4 (exige App ID da Meta); a faixa de aviso Pro na tela Export entra na M7.

### M5 — Elements (G)
- Sistema genérico de elementos (§18): seleção, mover/escalar/rotacionar (gestos), duplicar, excluir, opacidade, z-order.
- **Texto** (§19): fonte, tamanho, peso, alinhamento, cor, letter spacing, line height, sombra, outline, fundo; text presets (§20).
- **Text Brush (texto no traço)**: o traço desenhado vira a baseline do texto (design); layout de glifos ao longo do path com `PathMetrics`.
- **Brush (desenho livre)** (§21–22): Pen, Marker, Pencil, Chalk, Paint, Highlighter; suavização (Catmull-Rom/one-euro), pressão quando houver.
- **Stickers** e **Overlays** bundled; **Frames** básicos (2–3 estilos).
- Rasterização dos elementos no export (decisão 2.2-3).

**Testes:** layout de texto no path (posições/ângulos dos glifos), suavização de traço (determinística), hit-testing e transformações, serialização de cada tipo, goldens de cada tipo de brush/text preset; instrumentado: export de foto com elementos bate com o preview rasterizado (tolerância).

> ✅ Ao fim da M5: MVP de foto completo (spec §68, itens 1–9).

### M6 — Video engine (G)
- Picker de vídeo, `probe` (duração, fps, rotação, faixa de áudio).
- Preview: ExoPlayer → `SurfaceProducer` com `setVideoEffects(DevelopGlEffect, crop, overlays)`; play/pause/seek; timecode.
- Timeline (design): FILM (frames por `MediaMetadataRetriever`), trim com véu, lanes TYPE/BRUSH por intervalo de tempo, SOUND (waveform simplificada + mute), playhead.
- Elementos com `startTime/endTime` (§23).
- Export: Transformer (H.264/AAC MP4; resolução 720p/1080p/original; áudio on/off) dentro do WorkManager + notificação + cancelamento.

**Testes:** unit Dart (matemática da timeline: px↔ms, limites de trim, sobreposição de clipes); instrumentado: export de vídeo de 3 s com trim → duração esperada ±1 frame, sem faixa de áudio quando mudo, resolução correta, overlay visível só no intervalo (amostrar frames); cancelamento limpa arquivos parciais.

> ✅ Ao fim da M6: MVP de vídeo (spec §68, itens 10–17).

### M7 — UX restante + Monetização (M)
- Archive (catálogo), favoritos (presets/coleções/stickers), coleção em destaque.
- RevenueCat: `Purchases.configure`, entitlement `pro`, produtos `monthly`/`yearly`(/`lifetime`, ver Q6); paywall custom do design (trial, restore, termos); "I already have Pro" → restore.
- Gating no export: conteúdo Pro usado → linha de aviso + SEE PRO. Usuário free exporta normalmente (sem marca d'água) quando só usa conteúdo free.
- `EntitlementService` (interface) com cache offline do último estado.

**Testes:** unit de gating (combinações free/pro × conteúdo premium × offline), widget do paywall com `FakeEntitlementService`; teste manual no Play Console com license testers (compra, cancelamento, restore, trial). E2E patrol do fluxo "Free → Pro content → Paywall" com a compra fake.

> ✅ Ao fim da M7: spec §68 item 20 + critérios de Monetização da §69.

### M8 — Content platform: lado do app (M)
- Admin Web (Next.js + Neon + R2) é **projeto separado** — planejar à parte.
- No app: `RemoteCatalogSource` (`GET /content/catalog?version=N` → 304/novo), diff de assets, download incremental com `dio`, cache em `downloaded_content/`, assets antigos mantidos enquanto usados por algum projeto; fontes remotas registradas via `FontLoader`.

**Testes:** parsing do catálogo remoto, diff v10→v11 (só baixa novos), cache hit sem rede, asset referenciado não é apagado, catálogo corrompido → mantém o anterior.

### M9 — Polish e release (M)
- Performance: profile mode em aparelho médio (alvo: slider sem jank, 60 fps no preview de foto); memória com fotos de 48–200 MP; ANR watchdog.
- Tratamento de erros amigável (§64); crash reporting (decidir ferramenta, ver §60).
- Release: assinatura, R8/minify (regras para Media3/Pigeon/RevenueCat), App Bundle, Data Safety ("nenhuma mídia sai do aparelho"), política de privacidade, ficha na Play Store.

---

## 5. Estratégia de testes

| Camada | Ferramenta | Onde | Roda em |
|---|---|---|---|
| Unit Dart (modelos, histórico, interpolação, catálogo, gating) | `flutter_test` + `mocktail` | `test/core/**` | CI, cada push |
| Banco | Drift `NativeDatabase.memory()` | `test/core/storage/**` | CI |
| Widget | `flutter_test` + `FakeMediaEngine` + `ProviderScope` overrides | `test/features/**` | CI |
| Golden | `matchesGoldenFile` (fontes reais carregadas) | `test/goldens/**`, tag `golden` | CI Linux (referência única) |
| Kotlin JVM | JUnit4 + Robolectric + Truth | `android/app/src/test/**` | CI |
| Kotlin instrumentado (GL, Media3, MediaStore) | AndroidX Test + `media3-test-utils` | `android/app/src/androidTest/**` | CI com emulador (`reactivecircus/android-emulator-runner`, API 34, GPU swiftshader) + aparelho real antes de release |
| E2E (fluxos da spec §63) | `patrol` | `integration_test/**` | Emulador; nightly |

**Regras práticas**
- Cada bug corrigido ganha um teste de regressão.
- Os vetores em `test_fixtures/` são a fonte de verdade entre Dart e Kotlin: se o mapeamento de um parâmetro muda, os dois lados quebram juntos.
- E2E patrol cobre os quatro fluxos da §63. Conteúdo (Admin → app) entra na M8 com servidor fake.
- Comandos (via script `tool/ci.sh`):
  ```bash
  dart run build_runner build -d
  flutter analyze
  flutter test --coverage
  (cd android && ./gradlew :app:testDebugUnitTest)
  (cd android && ./gradlew :app:connectedDebugAndroidTest)   # precisa de emulador
  patrol test -t integration_test/photo_flow_test.dart          # precisa de emulador
  ```

---

## 6. Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| `SurfaceProducer` + EGL próprio (surface destruída em background, troca de Impeller/Vulkan) | Preview preto / crash | Spike logo no início da M2; tratar `onSurfaceCleanup`; testar em 3+ GPUs (Adreno, Mali, PowerVR) |
| Variação de codecs entre fabricantes (Transformer) | Export de vídeo falha em alguns aparelhos | Fallback de resolução/encoder; mapear erros do Transformer para mensagens da §64; matriz de aparelhos |
| Fotos enormes (100–200 MP) | OOM no export | Tiles + `inSampleSize`; teste instrumentado com imagem grande |
| Diferença preview × export | "Ficou diferente quando salvei" | Mesmo shader e mesma rasterização de elementos; teste instrumentado de comparação |
| URI persistível perdida (foto apagada da galeria) | Projeto sem mídia | Estado "mídia indisponível" no projeto (ver Q5) |
| Codegen pesado (freezed + riverpod + drift + pigeon) | Builds lentos | `build.yaml` restringindo `generate_for` por builder |

---

## 7. Decisões tomadas

| # | Questão | Decisão |
|---|---|---|
| D1 | Nome do app | **Auvie** (substitui "Épreuve" do handoff) |
| D2 | "Text Brush": spec §21 = desenho livre; design = texto que segue um traço | **Os dois**: **TYPE → Text Brush** (texto no traço) e **BRUSH** (desenho livre), como no toolbar do design |
| D3 | Marca d'água no export free | **Não** (o benefício "watermark-free" sai do paywall) |
| D4 | HEIF no export | **Removido** do produto: só JPEG e PNG |
| D5 | Versionamento | Manual, pelo dono do projeto |
| D6 | Referência à mídia (era Q5) | URI do Photo Picker com acesso persistido (`takePersistableUriPermission`); se o provedor recusar, o arquivo é copiado para `files/projects/media/` (M2) |

## 8. Questões em aberto (decidir antes da fase indicada)

| # | Questão | Recomendação | Até |
|---|---|---|---|
| Q1 | `applicationId` definitivo | Ex.: `app.auvie` (precisa de um domínio que você controle) | M0 |
| Q6 | Produto `lifetime` (spec §49) entra no lançamento? | Lançar com monthly + yearly | M7 |
| Q7 | Preços e textos marcados como *placeholder* no handoff | Produto define | M7 |
| Q8 | Crash reporting/analytics sem conta (§60) | Avaliar em separado; manter interface `Telemetry` no-op | M9 |

---

## 9. Ordem sugerida das primeiras tarefas

1. Upgrade do Flutter para 3.47.6 + resolver o problema do SDK no WSL.
2. M0 completo (dependências, lints, tema, rotas, CI).
3. **Spike de M2 em paralelo com M1:** Photo Picker → textura GL com um uniform (exposure) controlado por um slider Flutter. Valida o risco técnico principal antes de construir a UI em cima.
4. M1 (domínio + testes) → M2 completo → M3 → M4.
