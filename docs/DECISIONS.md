# TRiXX — Décisions techniques

Ce document trace les décisions techniques structurantes du projet, le contexte
qui les motive et les alternatives écartées, conformément à l'exigence N9 /
section 7.3 du cahier des charges. Toute décision qui affecte l'architecture,
le coût, la confidentialité ou le périmètre doit être ajoutée ici avant d'être
implémentée.

Format : `D0XX`, statut (`Adopté` / `En expérimentation` / `Rejeté`), date.

---

## D001 — Fournisseur du LLM cloud : Gemini par défaut, derrière une abstraction multi-provider

**Statut :** Adopté — 14 septembre 2026

**Contexte.** Les documents sources se contredisent : le cahier des charges
(`Trixx-1.pdf`, §3.2/3.4) spécifie l'API Claude (Anthropic), tandis que les cas
d'utilisation et diagrammes de séquence (`Trixx.pdf`) référencent
systématiquement l'« API LLM (Gemini) ». La section 15.1 de la documentation
produit signalait explicitement ce point à arbitrer.

**Décision.**
1. Le code ne doit jamais dépendre directement d'un SDK de fournisseur. Toute
   la couche `ai/` consomme une interface `LlmProvider` (méthodes : `complete`,
   `stream`, `functionCall`) définie dans `ai/llm/`.
2. Deux implémentations sont prévues derrière cette interface : `GeminiProvider`
   (API Gemini, streaming SSE) et `ClaudeProvider` (API Claude, streaming SSE).
3. **Le provider actif par défaut en Phase 1 est Gemini.** Raison pratique :
   projet personnel sans budget externe (§5.2 du cahier des charges) — le
   niveau gratuit de l'API Gemini est plus généreux pour un usage de
   développement/bêta fermée que l'offre Claude, et l'ensemble des diagrammes
   de séquence déjà produits (UC05, UC12, UC15–UC20) documente ce choix.
4. `ClaudeProvider` reste implémenté et testé (non branché par défaut) afin de
   permettre un changement de fournisseur ou un fallback sans réécriture, et
   pour réévaluer le choix quand un budget existera.

**Alternatives écartées.**
- *Claude uniquement* : rejeté car cela invaliderait l'ensemble des diagrammes
  de séquence déjà validés dans `Trixx.pdf`, qui nomment Gemini comme acteur
  secondaire.
- *Fallback automatique entre fournisseurs* : écarté pour la Phase 1 (complexité
  et coût de test superflus pour un seul utilisateur actif) ; à reconsidérer en
  Phase 2 si la disponibilité de l'API devient un problème réel.

**Conséquences.** Les clés API des deux fournisseurs suivent la règle N4/N5 :
jamais en dur, jamais loguées, chargées via variables d'environnement /
secure storage. Le prompt système, le function calling schema et le parsing de
réponse doivent rester indépendants du provider (pas de champ propre à l'API
Gemini fuité dans le domaine).

---

## D002 — IA locale : Gemma 2B via MediaPipe, avec seuils de bascule mesurés

**Statut :** Adopté — 14 septembre 2026

**Contexte.** Le routeur d'intentions (§9.2, §3.5) doit traiter localement
`CHITCHAT` et les intentions simples, et basculer vers le cloud pour
`GENERAL_ADVICE`. Le risque documenté (§6) est un modèle local trop lent sur
les appareils milieu de gamme.

**Décision.**
1. Gemma 2B (via MediaPipe LLM Inference API) est le modèle local retenu pour
   la classification d'intention et le `CHITCHAT`.
2. Un spike de la semaine 1–2 doit mesurer, sur l'appareil de test réel
   (Android 12+, §5.3) : latence de première réponse, pic mémoire, et taux de
   classification correct sur un jeu d'au moins 30 phrases représentatives des
   5 intentions.
3. Seuils de bascule automatique vers le cloud : latence locale > 1,5 s **ou**
   confiance de classification < 0,6 → la requête est traitée comme
   `GENERAL_ADVICE` et envoyée au provider cloud actif (D001).
4. Si le spike échoue à tenir ces seuils sur l'appareil de référence, Gemma 2B
   devient optionnel (activable manuellement) et le routeur envoie par défaut
   au cloud — conformément à la mitigation déjà prévue dans le tableau des
   risques (« Basculement automatique cloud, modèle local optionnel »).

**Alternatives écartées.** Un classifieur regex/mots-clés pur (sans LLM local)
a été envisagé pour réduire le risque de latence, mais rejeté : il ne couvrirait
pas correctement `CHITCHAT` en langage libre. Il reste toutefois utilisé comme
pré-filtre rapide devant Gemma 2B pour les intentions `QUERY_SCHEDULE` et
`SYSTEM_ACTION` qui sont déterministes (mots-clés + regex de date/heure), afin
d'éviter un appel LLM local inutile.

---

## D003 — Stockage : Isar pour les données structurées, sqlite-vec pour la mémoire sémantique

**Statut :** Adopté — 14 septembre 2026

**Contexte.** Le cahier des charges impose Isar (chiffrement natif, performance)
pour les tâches/sessions/profil, et sqlite-vec pour la recherche vectorielle
locale (§10.4, §15.1).

**Décision.**
1. Isar reste la base principale pour toutes les entités métier (`Task`,
   `Session`, `Profile`, `Routine`, `CalendarEvent`) — chiffrement AES-256 activé
   via la clé stockée dans Android Keystore (N4).
2. sqlite-vec est isolé dans son propre module (`ai/memory/`) et ne stocke que
   les embeddings + un identifiant de référence vers le document Isar
   correspondant (`Memory.sourceSession`, `Memory.id`). Aucune donnée
   personnelle brute n'est dupliquée dans la base vectorielle.
3. Le fournisseur d'embeddings suit la même règle d'abstraction que D001 (interface
   `EmbeddingProvider`) ; le cahier des charges cite l'API OpenAI
   `text-embedding-3-small` — retenue par défaut pour la Phase 1, avec mise en
   cache locale agressive obligatoire (contrainte déjà actée en §3.4/§30).

**Alternatives écartées.** Un unique moteur (tout dans Isar avec une recherche
par similarité approximée en Dart pur) a été écarté : au-delà de quelques
centaines de souvenirs, la recherche devient trop lente sans index vectoriel
dédié, et le cahier des charges impose déjà sqlite-vec explicitement.

---

## D004 — Exécution en arrière-plan : WorkManager avec dégradation assumée par constructeur

**Statut :** Adopté — 14 septembre 2026

**Contexte.** N3 exige que les rappels fonctionnent à 99 % hors réseau, et le
risque le plus probable/élevé du projet (§6, §31) est que certains
constructeurs (Xiaomi, Huawei) tuent les tâches en arrière-plan malgré
WorkManager.

**Décision.**
1. WorkManager reste le mécanisme retenu (imposé par le cahier des charges),
   combiné à `AlarmManager` en secours natif pour les rappels à heure exacte
   critiques (déclenchement même si WorkManager est retardé par Doze).
2. L'application doit détecter, au premier lancement, le fabricant de
   l'appareil (`android.os.Build.MANUFACTURER`) et afficher une invite
   contextuelle demandant à l'utilisateur de désactiver l'optimisation de
   batterie pour Trixx sur les constructeurs connus pour être agressifs
   (liste initiale : Xiaomi/MIUI, Huawei/EMUI, Oppo/ColorOS, Vivo).
3. Le critère d'acceptation CA2 (rappel sur 3 appareils Android différents,
   app fermée) doit inclure au moins un appareil d'un de ces constructeurs.

**Alternatives écartées.** S'appuyer uniquement sur `AlarmManager` sans
WorkManager a été écarté : WorkManager reste nécessaire pour les tâches
différables non critiques en temps (sync agenda, génération de résumé de
session) et est explicitement demandé par le cahier des charges.

---

## D005 — Frontière de données : ce qui peut quitter l'appareil, et quand

**Statut :** Adopté — 14 septembre 2026

**Contexte.** N5 interdit l'envoi de données personnelles brutes au cloud ; le
mode Privacy Strict doit désactiver tout appel externe (§16.3).

**Décision — matrice explicite des flux sortants :**

| Donnée | Destination | Condition | Anonymisation |
|---|---|---|---|
| Texte du message chat (`GENERAL_ADVICE`, `CREATE_TASK` via function calling) | Provider LLM cloud actif (D001) | Toujours, sauf Privacy Strict = ON | Aucun identifiant utilisateur transmis ; le prénom/personnalité restent dans le prompt système uniquement si l'utilisateur a activé la personnalisation |
| Résumé de session (20 derniers échanges) | Provider LLM cloud actif | Fin de session, ≥ 3 échanges significatifs | Horodatages relatifs uniquement, pas d'e-mail/mot de passe |
| Texte des 5 souvenirs long terme réinjectés | Provider LLM cloud actif | À chaque appel nécessitant du contexte | Aucun |
| Embeddings de mémoire | Provider d'embeddings (D003) | Création/mise à jour d'un souvenir | Aucun texte brut supplémentaire au-delà du contenu du souvenir lui-même |
| Requête météo (ville/coords approximatives) | OpenWeatherMap | Affichage dashboard | Coordonnées arrondies à ~1 km, pas de compte utilisateur lié |
| Événements Google Agenda | Google (OAuth déjà autorisé par l'utilisateur) | Synchronisation demandée | N/A — lecture seule, pas de ré-émission |
| Flux RSS + contenu à résumer | Provider LLM cloud actif | Affichage actualités | Contenu public, pas de donnée utilisateur associée |

**Mode Privacy Strict = ON.** Coupe tous les flux du tableau ci-dessus vers un
tiers, à l'exception de la synchronisation Google Agenda déjà autorisée
explicitement (celle-ci est coupée séparément si l'utilisateur désactive la
synchronisation elle-même). Le chat bascule alors entièrement sur Gemma 2B
local ; toute requête `GENERAL_ADVICE` reçoit une réponse indiquant que la
fonctionnalité nécessite de désactiver Privacy Strict.

**Alternatives écartées.** Anonymisation par LLM local avant envoi au cloud
(pseudonymisation automatique du texte) a été envisagée mais écartée pour la
Phase 1 : complexité et risque de faux négatifs trop élevés pour un projet
solo ; le choix retenu est un contrôle binaire (Privacy Strict) plutôt qu'un
filtrage partiel non fiable.

---

## Décisions restant ouvertes (à trancher avant la fin de la Phase 1)

- **D006 — Choix définitif du device de test « constructeur agressif »**
  (Xiaomi vs Huawei) pour valider D004 : dépend du matériel réellement
  disponible listé en §5.3 (un seul appareil Android physique) ; à compléter
  dès qu'un deuxième appareil de test est identifié.
- **D007 — Politique de rétention des embeddings** au-delà des 5 souvenirs
  réinjectés par session (purge automatique ? conservation illimitée
  chiffrée ?) : non tranché, à documenter avant l'implémentation de F18.
