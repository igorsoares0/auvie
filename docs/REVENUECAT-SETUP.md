# Ligar o Pro de verdade: Play Console + RevenueCat

Hoje o app roda com uma **assinatura simulada** (debug/profile sem chave): a compra só liga o Pro no aparelho. Para cobrar de verdade, faça os passos abaixo uma vez. O código já está pronto (`lib/core/subscription/revenuecat_entitlement_service.dart`): basta a chave.

## 1. Play Console

1. **Conta de desenvolvedor** em play.google.com/console (taxa única) e o perfil de pagamentos (Configurações → Perfil de pagamentos), necessário para vender.
2. **Criar o app** com o package `app.auvie`.
3. **Subir um build para teste interno.** O Google só libera produtos e compras de teste depois que o app tem um build numa faixa:
   ```bash
   flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_KEY=goog_...
   ```
   Envie o `.aab` em Testar → Teste interno, e adicione o seu e-mail como testador.
4. **Criar a assinatura** (Monetizar → Produtos → Assinaturas):
   - ID do produto: `auvie_pro`;
   - **base plan `yearly`**: renovação anual, preço (o design usa US$ 39,99);
   - **base plan `monthly`**: renovação mensal (US$ 5,99 no design);
   - no base plan anual, uma **oferta** de teste grátis de 7 dias (elegibilidade: novos clientes). O app mostra o teste e o botão START FREE TRIAL sozinho quando a oferta existe.
   - Ative os base plans e a oferta.
5. **Testadores de licença** (Configurações → Teste de licença): adicione o seu e-mail. Compras dessas contas não são cobradas, e as renovações são aceleradas (um ano vira cerca de 30 minutos).
6. **Conta de serviço para o RevenueCat**: siga o guia do RevenueCat "Google Play service credentials". Ele cria uma conta de serviço no Google Cloud com acesso ao app e gera um JSON. Pode levar até 36 h para o Google liberar as credenciais.

## 2. RevenueCat

1. Crie a conta em app.revenuecat.com e um **projeto** "Auvie".
2. **App Android**: package `app.auvie` e o JSON da conta de serviço.
3. **Produtos**: importe `auvie_pro:yearly` e `auvie_pro:monthly`.
4. **Entitlement** com o identificador **`pro`** (o app procura exatamente esse nome), com os dois produtos anexados.
5. **Offering** `default`, marcada como *current*, com dois pacotes:
   - `$rc_annual` → `auvie_pro:yearly`;
   - `$rc_monthly` → `auvie_pro:monthly`.
6. **Chave pública** do app Android (Project settings → API keys): começa com `goog_`. É pública (pode ir no app) e não é segredo.

## 3. Rodar com a chave

```bash
flutter run --profile --dart-define=REVENUECAT_ANDROID_KEY=goog_...
```

Sem a chave:
- **debug/profile**: assinatura simulada (na tela Pro, "BACK TO FREE · SIMULATED" volta para free);
- **release**: o paywall diz "Pro isn't available yet" e o resto do app funciona normalmente.

## 4. Roteiro de teste com testador de licença

1. Instale pelo link do teste interno (compras só funcionam no app instalado pela Play).
2. Use Nocturne num projeto → Export → aviso → SAVE TO PHOTOS → paywall → START FREE TRIAL → aceite a compra de teste → o export roda.
3. Archive: os filmes Pro passam a OWNED; a Home mostra PRO ✓; a tela Pro mostra "You have Pro · YEARLY".
4. Cancele em Play Store → Assinaturas; depois da expiração acelerada, o app volta a free.
5. Desinstale e reinstale → onboarding → I ALREADY HAVE PRO → "Pro restored.".
