# Arquitetura e Plano de Implementação - Google Mobile Ads Async

## 1. Visão Geral

Este documento descreve a arquitetura e as etapas para a criação do pacote `google_mobile_ads_async`. O objetivo principal é criar um wrapper abrangente em torno do pacote `google_mobile_ads`, transformando sua API baseada em callbacks em uma API moderna e assíncrona (`Future`-based) para todos os formatos de anúncio.

Além da simplificação do carregamento, o pacote introduzirá um **gerenciador de pré-carregamento (cache)**, permitindo que os anúncios sejam carregados em segundo plano e exibidos instantaneamente quando necessário, melhorando a experiência do usuário e a performance do aplicativo.

**Formatos de Anúncio Suportados:**
- Banner
- Interstitial
- Rewarded (Recompensado)
- Rewarded Interstitial (Recompensado Intersticial)
- Native (Nativo)
- App Open (Abertura de App)

**O Problema:** A API oficial exige o gerenciamento de múltiplos callbacks para cada tipo de anúncio, tornando o código verboso e complexo. Além disso, não há uma solução integrada para o gerenciamento de cache de anúncios ou para a exibição de anúncios na árvore de widgets de forma declarativa.

**A Solução:**
1.  Abstrair a complexidade do carregamento em chamadas de método assíncronas e intuitivas (`await GoogleMobileAdsAsync.loadBannerAd(...)`).
2.  Fornecer um `AdCacheManager` para pré-carregar, armazenar e recuperar anúncios de forma eficiente.
3.  Oferecer **widgets de UI (wrappers)** para os formatos `Banner` e `Native`, que gerenciam automaticamente o ciclo de vida do carregamento (exibindo estados de `loading` e `error`) e simplificam a integração visual.

---

## 2. Princípios Fundamentais

- **Simplicidade (Simplicity):** A API pública deve ser mínima e intuitiva.
- **Segurança de Tipos (Type Safety):** Utilizar tipos genéricos e específicos do Dart (`Future<BannerAd>`, `Future<InterstitialAd>`) para garantir clareza e segurança.
- **Gerenciamento de Erros (Robust Error Handling):** Encapsular falhas de carregamento em exceções claras (`AdLoadException`).
- **Eficiência (Efficiency):** Permitir o pré-carregamento de anúncios para minimizar a latência de exibição.
- **Não Invasivo (Non-Intrusive):** Após o carregamento, o desenvolvedor terá acesso total ao objeto de anúncio original do `google_mobile_ads`.

---

## 3. Arquitetura de Componentes

A arquitetura será composta por três componentes principais: o `AsyncAdLoader`, o `AdCacheManager` e os `Ad Wrappers`.

### Componente 1: `AsyncAdLoader`

A camada base que converte os callbacks do `google_mobile_ads` em `Future`s.

- **Responsabilidade:** Orquestrar o processo de carregamento para cada tipo de anúncio.
- **Métodos Principais:**
  ```dart
  // Um método para cada tipo de anúncio
  Future<BannerAd> loadBannerAd(...)
  Future<InterstitialAd> loadInterstitialAd(...)
  Future<RewardedAd> loadRewardedAd(...)
  Future<RewardedInterstitialAd> loadRewardedInterstitialAd(...)
  Future<NativeAd> loadNativeAd(...)
  Future<AppOpenAd> loadAppOpenAd(...)
  ```
- **Lógica Interna:** Cada método usará um `Completer` para encapsular a lógica de `onAdLoaded` e `onAdFailedToLoad`, retornando um `Future` que resolve com o anúncio ou lança uma `AdLoadException`.

### Componente 2: `AdCacheManager`

Uma camada de alto nível para gerenciar o ciclo de vida dos anúncios.

- **Responsabilidade:** Pré-carregar, armazenar e fornecer anúncios.
- **Métodos Principais:**
  ```dart
  // Inicia o carregamento de um anúncio e o armazena no cache
  Future<void> preloadAd(String adUnitId, AdType type, {AdRequest? request});

  // Recupera um anúncio pré-carregado do cache
  T? getAd<T extends Ad>(String adUnitId);

  // Remove um anúncio do cache
  void disposeAd(String adUnitId);
  ```
- **Lógica Interna:** Utilizará um `Map<String, Ad>` para armazenar os anúncios carregados, usando o `adUnitId` como chave. Ele chamará os métodos do `AsyncAdLoader` para realizar o carregamento.

### Componente 3: Widgets de Exibição (Ad Wrappers)

Para simplificar a integração dos anúncios diretamente na árvore de widgets do Flutter, o pacote fornecerá uma camada de UI.

- **Responsabilidade:** Gerenciar o estado de carregamento de um anúncio (Banner ou Native) e renderizar a UI correspondente para cada estado: carregando, erro ou sucesso.
- **Componentes Principais:**
    - **`AdWidgetWrapper` (Abstrato):** Um `StatefulWidget` base que contém a lógica comum para carregar um anúncio, gerenciar o estado (`loading`, `loaded`, `error`) e lidar com o `dispose`.
    - **`BannerAdWidget`:** Um wrapper para anúncios de banner. Ele gerencia o carregamento e o dimensionamento do `BannerAd`, permitindo que o desenvolvedor forneça builders customizados para os estados de `loading` e `error`.
    - **`NativeAdWidget`:** Um wrapper para anúncios nativos. Ele permite que o desenvolvedor forneça um `nativeAdBuilder` para construir uma UI completamente customizada a partir do objeto `NativeAd` carregado.

### Diagrama de Fluxo (Pré-carregamento)

```
Developer App      AdCacheManager        AsyncAdLoader         google_mobile_ads
      |                  |                     |                       |
      |-- preloadAd() -->|                     |                       |
      |                  |-- load<AdType>() -->|                       |
      |                  |                     |-- <AdType>.load() --->| (com callbacks)
      |                  |                     |                       |
      |                  |                     |<-- onAdLoaded(ad) ----|
      |                  |<-- Future<Ad> ------|                       |
      |                  |-- (Armazena 'ad' no Map)
      |                  |
      | (mais tarde)     |
      |                  |
      |-- getAd() ------>|
      |<-- (Retorna 'ad' do Map)
      |
```

---

## 4. Etapas de Implementação

A implementação será dividida nas seguintes etapas:

- [x] **Etapa 1: Configuração do Projeto**
  - Garantir que a dependência do `google_mobile_ads` está atualizada.

- [x] **Etapa 2: Generalizar a Exceção**
  - Manter a `AdLoadException` genérica para ser usada por todos os tipos de carregamento.

- [x] **Etapa 3: Implementar o `AsyncAdLoader`**
  - Criar métodos de carregamento assíncronos para cada tipo de anúncio: `loadBannerAd`, `loadInterstitialAd`, `loadRewardedAd`, `loadRewardedInterstitialAd`, `loadNativeAd` e `loadAppOpenAd`.

- [x] **Etapa 4: Implementar o `AdCacheManager`**
  - Criar a classe `AdCacheManager` com a lógica para pré-carregar, armazenar em um `Map` e recuperar anúncios.
  - Garantir o descarte (`dispose`) correto dos anúncios para evitar vazamentos de memória.

- [X] **Etapa 5: Desenvolver Widgets de Exibição (Wrappers)**
  - Criar a classe base abstrata `AdWidgetWrapper` para gerenciar o estado do ciclo de vida do anúncio.
  - Implementar o `BannerAdWidget` para exibir anúncios de banner com builders de `loading`/`error`.
  - Implementar o `NativeAdWidget` com um `nativeAdBuilder` para renderização customizada.
  - Refatorar o `NativeAdCard` existente para que utilize o `NativeAdWidget` internamente.

- [X] **Etapa 6: Documentação da API**
  - Atualizar todos os comentários de documentação (`///`) para cobrir a nova API expandida, incluindo os **Ad Wrappers**, o `AdCacheManager` e todos os novos métodos de carregamento.

- [X] **Etapa 7: Criar um Exemplo de Uso Abrangente**
  - Atualizar o aplicativo na pasta `example/` para demonstrar o carregamento simples, o pré-carregamento e o **uso dos novos `BannerAdWidget` e `NativeAdWidget`**.

- [X] **Etapa 8: Escrever Testes**
  - Expandir os testes de unidade para cobrir a lógica do `AsyncAdLoader` para todos os tipos de anúncio.
  - Criar testes específicos para o `AdCacheManager` usando `mocktail`.

---

## 5. Exemplo de Uso (Resultado Final)

O objetivo é permitir fluxos de trabalho simples e avançados.

**Cenário 1: Carregamento Simples (Sem Cache)**
```dart
Future<void> showInterstitialAd() async {
  try {
    final ad = await GoogleMobileAdsAsync.loadInterstitialAd(
      adUnitId: 'your_ad_unit_id',
    );
    ad.show();
  } on AdLoadException catch (e) {
    print('Falha ao carregar anúncio intersticial: $e');
  }
}
```

**Cenário 2: Pré-carregamento com `AdCacheManager`**
```dart
// Na inicialização do app ou da tela
void preLoadAds() {
  AdCacheManager.instance.preloadAd('rewarded_ad_unit', AdType.rewarded);
}

// Quando o usuário for executar a ação para ver o anúncio
void showRewardedAd() {
  final ad = AdCacheManager.instance.getAd<RewardedAd>('rewarded_ad_unit');
  if (ad != null) {
    ad.show(onUserEarnedReward: (ad, reward) {
      print('Recompensa ganha: ${reward.amount} ${reward.type}');
    });
  } else {
    // Opcional: Tentar carregar o anúncio agora ou mostrar mensagem
    print('Anúncio recompensado não estava pronto.');
  }
}
```

**Cenário 3: Integração de UI com Ad Wrappers**
```dart
// Em um método build() de um widget
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Conteúdo do App'),
      BannerAdWidget(
        adUnitId: 'your_banner_ad_unit_id',
        size: AdSize.banner,
        loadingBuilder: (context) => CircularProgressIndicator(),
        errorBuilder: (context, error) => Text('Erro: $error'),
      ),
      NativeAdWidget(
        adUnitId: 'your_native_ad_unit_id',
        nativeAdBuilder: (context, ad) => MyCustomNativeAdView(ad: ad),
        loadingBuilder: (context) => Text('Carregando anúncio nativo...'),
      ),
    ],
  );
}
```
