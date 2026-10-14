# Publicar o Auvie na Play Store

## 1. Chave de upload (uma vez)

A chave assina cada versão que você envia. Guarde o arquivo e as senhas num lugar seguro (gerenciador de senhas + backup): sem eles você não consegue mais atualizar o app (dá para recuperar com o suporte do Google, mas demora).

```powershell
cd C:\allsaas\auvie\android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Crie `android/key.properties` (já ignorado pelo git, como o `.jks`):

```properties
storeFile=upload-keystore.jks
storePassword=SUA_SENHA
keyAlias=upload
keyPassword=SUA_SENHA
```

Sem esse arquivo, o build de release para com uma mensagem, em vez de sair assinado com a chave de debug. Para só testar um release no celular, sem a chave: `$env:AUVIE_DEBUG_SIGNING='true'` antes do `flutter build apk --release`.

## 2. Versão

Em `pubspec.yaml`, `version: 1.0.0+1`. O número depois do `+` (versionCode) sobe a cada envio à Play Store: `1.0.1+2`, `1.1.0+3`…

## 3. Gerar o App Bundle

```powershell
cd C:\allsaas\auvie
flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_KEY=goog_...
```

Arquivo: `build\app\outputs\bundle\release\app-release.aab`. Sem a chave do RevenueCat, o app sai com "Pro isn't available yet" (ver `docs/REVENUECAT-SETUP.md`).

Precisa de uns 10 GB livres no disco C: durante o build.

## 4. Play Console

1. Criar o app (`app.auvie`), idioma padrão inglês, gratuito com compras no app.
2. **Play App Signing:** aceite. O Google guarda a chave de assinatura final; a sua é só de upload.
3. **Teste interno:** envie o `.aab`, adicione testadores, instale pelo link e faça o roteiro abaixo.
4. Preencha a ficha (`docs/STORE-LISTING.md`): textos, arte, Data Safety, classificação, público-alvo, política de privacidade (URL pública de `docs/legal/privacy.html`).
5. Crie a assinatura e os produtos (`docs/REVENUECAT-SETUP.md`).
6. **Contas pessoais novas:** o Google exige um **teste fechado com pelo menos 12 testadores por 14 dias** antes de liberar a produção. Planeje isso.
7. Produção: promova o build do teste, lançamento gradual (ex.: 20%), acompanhe o Android vitals (crashes e ANRs) e suba para 100%.

## 5. Roteiro antes de cada lançamento

- [ ] `flutter analyze` limpo; `flutter test` verde; `gradlew :app:testDebugUnitTest`.
- [ ] Testes instrumentados no aparelho (em grupos, por causa do MIUI).
- [ ] Release no aparelho, instalado pela Play (teste interno):
  - foto: filme + ajuste + texto + export JPEG e PNG;
  - vídeo: trim + texto + export 1080p em segundo plano, notificação e CANCEL;
  - Archive → foto com um filme;
  - Pro: compra de teste, restaurar, export com conteúdo Pro;
  - Settings: CLEAR, licenças, termos e privacidade abrem;
  - apagar um projeto; abrir um projeto cuja foto foi apagada.
- [ ] URLs de termos e privacidade em `lib/core/platform/link_opener.dart` apontando para as páginas publicadas.
- [ ] `version` do `pubspec.yaml` aumentada.
