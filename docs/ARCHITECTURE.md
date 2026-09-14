# TRiXX — Architecture

Référence technique de l'architecture applicative, complétant le cahier des
charges (§3.3, §15) et les décisions actées dans `docs/DECISIONS.md`.

## Couches

```text
lib/
├── ui/           Widgets Flutter uniquement. Aucune logique métier.
├── domain/       Services Dart purs : orchestration IA, planification, mémoire.
├── data/         Repositories abstraits (Isar, cache, API).
├── system/       Modules Kotlin natifs exposés via MethodChannel.
└── ai/
    ├── router/   Classification d'intention (local, avant tout appel LLM cloud).
    ├── llm/       Interface LlmProvider + implémentations (Gemini, Claude).
    └── memory/    Mémoire court/long terme, embeddings, sqlite-vec.
```

Règle stricte : une couche ne dépend que des couches en dessous d'elle dans
cette liste (`ui` → `domain` → `data`/`ai`/`system`). `ui` ne doit jamais
importer un repository ou un provider directement — toujours via un service
`domain`.

## Couche IA — détail (suite à D001, D002, D003)

```text
                    Message utilisateur
                           │
                           ▼
              ┌─────────────────────────┐
              │   IntentRouter (local)   │  ← regex/mots-clés d'abord,
              └────────────┬─────────────┘     Gemma 2B ensuite (D002)
                           │
     ┌──────────┬──────────┼──────────┬──────────────┐
     ▼          ▼          ▼          ▼              ▼
CREATE_TASK QUERY_SCHEDULE SYSTEM_ACTION CHITCHAT  GENERAL_ADVICE
     │          │          │            │              │
     ▼          ▼          ▼            ▼              ▼
  Domain      Isar      MethodChannel  Gemma 2B    LlmProvider (D001)
  Service    direct        (Kotlin)     local      .stream() SSE
                                                   ┌──────┴──────┐
                                                   ▼             ▼
                                            GeminiProvider  ClaudeProvider
                                             (actif Phase 1)  (en réserve)
```

`LlmProvider` est la seule interface que `domain/` connaît :

```dart
abstract class LlmProvider {
  Stream<String> stream(ChatContext context);
  Future<FunctionCallResult> functionCall(ChatContext context, List<FunctionSchema> tools);
}
```

Aucun type spécifique à un SDK (Gemini, Claude) ne doit apparaître en dehors de
`ai/llm/providers/`. Le prompt système, l'injection de contexte (mémoire,
personnalité) et le schéma de function calling sont construits dans
`ai/llm/` de façon agnostique, puis adaptés au format de chaque provider
uniquement dans sa classe d'implémentation.

`ai/memory/` suit le même principe avec `EmbeddingProvider` (D003) : le
domaine manipule des `Memory` (contenu + embedding + importance), jamais des
vecteurs bruts d'un fournisseur particulier.

## Frontière de confidentialité (D005)

Un unique point de passage — `PrivacyGate` dans `domain/` — décide si un appel
sortant (LLM cloud, embeddings, météo, RSS) est autorisé. Toute méthode de
`data/` ou `ai/` qui effectue un appel réseau vers un tiers doit passer par
`PrivacyGate.check(DataFlow flow)` avant l'envoi. Quand Privacy Strict = ON,
`PrivacyGate` bloque tout sauf la synchronisation agenda déjà autorisée
explicitement (voir la matrice complète dans D005).

## Arrière-plan et rappels (D004)

```text
Task (date définie)
       │
       ▼
ReminderScheduler (domain/)
       │
   ┌───┴────┐
   ▼        ▼
WorkManager  AlarmManager (secours natif, Kotlin, via system/)
   │
   ▼
NotificationService → flutter_local_notifications
```

`ReminderScheduler` planifie systématiquement les deux : WorkManager pour la
fiabilité générale, et une alarme exacte native (`system/android/kotlin/`) pour
les rappels dont l'heure est critique, en secours si WorkManager est retardé
par les optimisations batterie du constructeur.

## Structure du dépôt

```text
trixx/
├── docs/
│   ├── ARCHITECTURE.md      (ce document)
│   ├── DECISIONS.md
│   ├── cahier_des_charges.pdf
│   └── cas_utilisation.pdf
├── lib/
│   ├── ui/
│   ├── domain/
│   ├── data/
│   └── ai/
│       ├── router/
│       ├── llm/
│       │   └── providers/   (gemini_provider.dart, claude_provider.dart)
│       └── memory/
├── test/
├── native/
│   └── android/kotlin/
├── scripts/
└── ci/
```

## Références

- Exigences fonctionnelles et non fonctionnelles : `Trixx-1.pdf` (cahier des charges)
- Cas d'utilisation et séquences détaillées : `Trixx.pdf`
- Décisions et alternatives écartées : `docs/DECISIONS.md`
- Design system (couleurs, typographie, composants) : voir la charte graphique
  orange dans `TRiXX_Project_Documentation_v2.md`
