# Vente du local

Tableau de bord pour décider de la vente d'un local commercial détenu par une SCI à l'IS : plus-value, impôts, remboursement anticipé du prêt, travaux, charges, loyers et versements des associés.

Page statique (HTML + JavaScript, sans étape de build). Les données sont dans Supabase, derrière une connexion par lien e-mail.

```
site/index.html     la page (calculs, graphiques, tableaux de saisie)
site/config.js      URL du projet Supabase et clé « anon »
supabase/migrations schéma de la base et règles d'accès
private/            données de départ (ignoré par git, ne pas publier)
```

## 1. Créer le projet Supabase
1. Sur supabase.com : New project, région **Europe** (Paris ou Francfort), mot de passe de base à conserver.
2. **SQL Editor** : colle et exécute `supabase/migrations/20261101000000_init.sql`.
3. **SQL Editor** : colle et exécute `private/seed.sql` (hypothèses, charges, échéancier du prêt), puis ajoute les associés :
   ```sql
   insert into public.membres (email, role) values
     ('toi@exemple.fr', 'editeur'),
     ('associe@exemple.fr', 'lecteur');
   ```
   Les e-mails sont en minuscules. Un `editeur` saisit, un `lecteur` consulte.
4. **Authentication > Sign In / Providers > Email** : laisse « Confirm email » actif. Pour que seuls les associés puissent créer un compte, désactive « Allow new users to sign up » puis invite chaque associé (Authentication > Users > Invite). Même sans cela, la table `membres` empêche toute lecture par un inconnu.
5. **Authentication > URL Configuration** : mets l'adresse du site publié dans « Site URL » et ajoute-la aussi dans « Redirect URLs » (et `http://localhost:8000` pour le test local).
6. **Project Settings > API** : copie « Project URL » et la clé **anon public** dans `site/config.js`. N'utilise jamais la clé `service_role`.

## 2. Tester en local
```bash
cd site && python3 -m http.server 8000
```
Ouvre http://localhost:8000, entre ton e-mail, clique sur le lien reçu.

## 3. GitHub
```bash
git init && git add . && git commit -m "Version initiale"
gh repo create gestion-immo --private --source=. --push
```
Vérifie avec `git status` que `private/` n'est pas suivi.

## 4. Publier
`.github/workflows/pages.yml` publie le dossier `site/` sur GitHub Pages à chaque envoi sur `main`. Dans le dépôt : Settings > Pages > Source : **GitHub Actions**.

Attention : GitHub Pages sur un dépôt privé demande un abonnement payant, et le site publié est public même si le dépôt est privé. Le code l'est donc aussi, mais pas les données : elles ne sortent de Supabase qu'après connexion d'un membre. Pour héberger gratuitement depuis un dépôt privé, Cloudflare Pages, Netlify ou Vercel (dossier à publier : `site`) conviennent aussi.

## Ce qui est où
| Donnée | Table |
|---|---|
| Paramètres (achat, prêt, vente, fiscalité) | `hypotheses` (une ligne) |
| Travaux, charges, loyers perçus, loyer prévu, versements | `travaux`, `charges`, `loyers`, `projection`, `versements` |
| Échéancier du prêt | `echeancier` |
| Accès des associés | `membres` |

Le code ne contient aucune donnée personnelle : les valeurs par défaut sont neutres.
