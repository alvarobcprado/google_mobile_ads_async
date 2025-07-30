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

**O Problema:** A API oficial exige o gerenciamento de múltiplos callbacks para cada tipo de anúncio, tornando o código verboso e complexo. Além disso, não há uma solução integrada para o gerenciamento de cache de anúncios.

**A Solução:**
1.  Abstrair a complexidade do carregamento em chamadas de método assíncronas e intuitivas (`await GoogleMobileAdsAsync.loadBannerAd(...)`).
2.  Fornecer um `AdCacheManager` para pré-carregar, armazenar e recuperar anúncios de forma eficiente, desacoplando a lógica de carregamento da lógica de exibição.

---

## 2. Princípios Fundamentais

- **Simplicidade (Simplicity):** A API pública deve ser mínima e intuitiva.
- **Segurança de Tipos (Type Safety):** Utilizar tipos genéricos e específicos do Dart (`Future<BannerAd>`, `Future<InterstitialAd>`) para garantir clareza e segurança.
- **Gerenciamento de Erros (Robust Error Handling):** Encapsular falhas de carregamento em exceções claras (`AdLoadException`).
- **Eficiência (Efficiency):** Permitir o pré-carregamento de anúncios para minimizar a latência de exibição.
- **Não Invasivo (Non-Intrusive):** Após o carregamento, o desenvolvedor terá acesso total ao objeto de anúncio original do `google_mobile_ads`.

---

## 3. Arquitetura de Componentes

A arquitetura será composta por dois componentes principais: o `AsyncAdLoader` e o `AdCacheManager`.

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

- [x] **Etapa 5: Desenvolver Widgets de Exibição (Opcional)**
  - Manter o `NativeAdCard` e, se necessário, criar outros widgets auxiliares para diferentes tipos de anúncios.

- [x] **Etapa 6: Documentação da API**
  - Atualizar todos os comentários de documentação (`///`) para cobrir a nova API expandida, incluindo o `AdCacheManager` e todos os novos métodos de carregamento.

- [x] **Etapa 7: Criar um Exemplo de Uso Abrangente**
  - Atualizar o aplicativo na pasta `example/` para demonstrar o carregamento simples e o pré-carregamento de múltiplos formatos de anúncio (ex: um banner e um intersticial pré-carregado).

- [x] **Etapa 8: Escrever Testes**
  - Expandir os testes de unidade para cobrir a lógica do `AsyncAdLoader` para todos os tipos de anúncio.
  - Criar testes específicos para o `AdCacheManager`, mockando o `AsyncAdLoader` para testar a lógica de cache (armazenamento, recuperação e descarte).

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