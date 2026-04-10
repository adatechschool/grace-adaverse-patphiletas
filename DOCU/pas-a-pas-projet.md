# Pas à pas pour boucler le projet Adaverse

Ce document sert de feuille de route simple, concrète et rassurante.
L'objectif n'est pas seulement de "faire marcher le projet", mais de comprendre ce que tu fais à chaque étape.

## 1. Ce que le projet attend vraiment

Tu dois construire une application fullstack avec :

- `Next.js`
- `TailwindCSS`
- `TypeScript`
- `Drizzle ORM`
- `Neon` pour la base Postgres

L'application doit permettre :

- de proposer un projet via un formulaire
- d'enregistrer ce projet en base
- de ne montrer sur la page d'accueil que les projets publiés
- d'avoir une page détail par projet

Important :

- pas de système de connexion
- pas d'upload d'image
- pas de dashboard admin obligatoire

En pratique, ton MVP obligatoire est :

1. une base de données correcte
2. des données de seed
3. une page d'accueil qui liste les projets publiés
4. un formulaire pour proposer un projet
5. une page détail pour un projet

## 2. L'ordre conseillé pour ne pas te perdre

Ne fais pas tout en même temps.
L'ordre le plus sûr est :

1. nettoyer le starter Next
2. préparer la base de données
3. écrire le schéma Drizzle
4. générer et exécuter la migration
5. écrire les seeds SQL
6. connecter l'app à la base
7. afficher les projets publiés sur `/`
8. créer la page détail
9. créer le formulaire de proposition
10. valider les cas d'erreur
11. faire une passe de style et de nettoyage

Si tu suis cet ordre, tu réduis énormément les bugs "je ne sais plus d'où vient le problème".

## 3. Étape 1 : nettoyer le projet actuel

Le repo est encore très proche du starter Next.
Avant de construire ton app, enlève ce qui n'a rien à voir avec le sujet.

À faire :

- remplacer le contenu de `src/app/page.js`
- remplacer le contenu de `src/app/layout.js`
- supprimer le code d'exemple dans `src/index.ts`
- remplacer la table `users` dans `src/db/schema.ts`

Question qu'on n'ose pas poser :

`src/index.ts`, c'est important ?

Réponse :
Pas forcément pour ton app Next.
Là, il sert surtout d'exemple Drizzle.
Tu peux soit le supprimer plus tard, soit le transformer en script utile.
Par exemple :

- un script de test de connexion à la base
- un script de seed

## 4. Étape 2 : préparer l'environnement

Tu dois avoir :

- une base Neon créée
- une variable `DATABASE_URL` dans `.env`

Exemple générique :

```env
DATABASE_URL=postgresql://user:password@host/dbname?sslmode=require
```

Question qu'on n'ose pas poser :

Pourquoi on met ça dans `.env` et pas directement dans le code ?

Réponse :
Parce qu'un mot de passe ou une URL de base de données ne doit pas être écrit en dur dans les fichiers du projet.
Sinon tu risques de l'envoyer sur GitHub.

Question qu'on n'ose pas poser :

Comment savoir si ma variable est bien lue ?

Réponse :
Si Drizzle ou Next se connecte bien, c'est bon.
Si tu as une erreur du type `process.env.DATABASE_URL` est `undefined`, c'est souvent :

- mauvais nom de variable
- mauvais fichier `.env`
- serveur à relancer

## 5. Étape 3 : faire le schéma de base de données

Tu as besoin de 3 tables minimales.

### Table `ada_projects`

Elle contient les projets officiels Ada.

Exemples :

- `Ada Quiz`
- `Adaopte`
- `Ada Check Events`

Champs minimum :

- `id`
- `name`

### Table `promotions`

Elle contient les promotions.

Exemples :

- `Frida`
- `Lovelace`

Champs minimum :

- `id`
- `name`
- `startDate`

### Table `student_projects`

Elle contient les projets soumis sur la plateforme.

Champs minimum :

- `id`
- `title`
- `slug`
- `githubUrl`
- `demoUrl`
- `createdAt`
- `publishedAt`
- `promotionId`
- `adaProjectId`

Champ pratique en plus :

- `imageUrl`

Question qu'on n'ose pas poser :

C'est quoi une clé étrangère ?

Réponse :
C'est un champ qui pointe vers l'id d'une autre table.
Exemple :

- `promotionId` pointe vers une ligne de `promotions`
- `adaProjectId` pointe vers une ligne de `ada_projects`

Ça veut dire qu'un projet étudiant "appartient" à une promo et à un projet Ada.

Question qu'on n'ose pas poser :

Pourquoi `publishedAt` peut être vide ?

Réponse :
Parce que l'énoncé dit qu'un projet peut être proposé sans être publié immédiatement.
Donc :

- projet proposé = `publishedAt` vaut `null`
- projet validé = `publishedAt` contient une date

## 6. Étape 4 : générer la migration

Une fois le schéma écrit, tu dois demander à Drizzle de produire le SQL correspondant.

L'idée :

- ton fichier `schema.ts` décrit ta base
- Drizzle génère un fichier SQL de migration
- tu exécutes cette migration sur la base

Exemples de commandes usuelles :

```bash
npx drizzle-kit generate
```

Puis selon ton setup :

```bash
npx drizzle-kit migrate
```

Question qu'on n'ose pas poser :

C'est quoi une migration ?

Réponse :
C'est l'historique des changements de structure de ta base.
Exemple :

- aujourd'hui tu crées `student_projects`
- demain tu ajoutes une colonne `description`

Au lieu de modifier la base à la main, tu gardes une trace de ces changements.

Question qu'on n'ose pas poser :

Je dois supprimer les anciens fichiers `users` ?

Réponse :
Oui, si tu ne veux plus cette table.
Sinon tu risques d'avoir un schéma incohérent avec le projet demandé.

## 7. Étape 5 : créer les seeds SQL

L'énoncé demande explicitement des scripts `.sql`.

Tu dois préparer au moins :

- un fichier pour insérer les promos
- un fichier pour insérer les projets Ada
- un fichier pour publier un projet

Exemple générique pour les promotions :

```sql
INSERT INTO promotions (name, start_date)
VALUES
  ('Frida', '2024-09-01'),
  ('Lovelace', '2025-01-06');
```

Exemple générique pour les projets Ada :

```sql
INSERT INTO ada_projects (name)
VALUES
  ('Ada Quiz'),
  ('Adaopte'),
  ('Ada Check Events');
```

Exemple générique pour publier un projet :

```sql
UPDATE student_projects
SET published_at = NOW()
WHERE id = 1;
```

Question qu'on n'ose pas poser :

Pourquoi l'énoncé demande du SQL alors qu'on utilise Drizzle ?

Réponse :
Parce qu'on veut vérifier que tu comprends aussi un minimum la base de données, pas seulement l'ORM.
Drizzle t'aide, mais SQL reste important.

## 8. Étape 6 : créer le fichier de connexion à la base

Tu vas probablement avoir un fichier du style `src/db/index.ts` ou `src/lib/db.ts`.

Son rôle :

- initialiser Drizzle
- exporter un objet `db`

Exemple générique :

```ts
import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export const db = drizzle(pool);
```

Question qu'on n'ose pas poser :

Pourquoi faire un fichier séparé ?

Réponse :
Pour éviter de répéter la connexion partout.
Tu centralises la config une fois, puis tu importes `db` là où tu en as besoin.

## 9. Étape 7 : afficher les projets publiés sur la page d'accueil

La homepage `/` doit montrer uniquement les projets publiés.

La logique métier est :

- récupérer les projets avec `publishedAt` non nul
- joindre les tables `promotions` et `ada_projects`
- trier par date de publication décroissante
- regrouper visuellement par projet Ada

Question qu'on n'ose pas poser :

Pourquoi on parle de "joindre" les tables ?

Réponse :
Parce que `student_projects` contient juste des ids.
Pour afficher le nom de la promo ou du projet Ada, il faut relier les tables entre elles.

Exemple de résultat attendu côté interface :

- section `Ada Quiz`
- à l'intérieur, plusieurs cartes de projets
- section `Adaopte`
- à l'intérieur, plusieurs cartes de projets

Chaque carte affiche :

- titre
- date de publication
- promotion
- image

## 10. Étape 8 : gérer l'image du projet

L'énoncé dit :

- essayer de récupérer `thumbnail.png` depuis le repo GitHub
- sinon utiliser une image par défaut

La logique générique :

1. tu stockes `githubUrl`
2. tu extrais le `owner` et le `repo`
3. tu construis une URL du type :

```txt
https://github.com/<user>/<repo>/blob/main/thumbnail.png?raw=true
```

4. si ça ne marche pas, tu affiches une image locale par défaut

Question qu'on n'ose pas poser :

Comment "savoir" si l'image existe ?

Réponse :
Au niveau simple du projet, tu peux juste tenter d'afficher cette URL.
Si elle casse côté UI, tu remplaces visuellement par une image par défaut.
Tu n'es pas obligée de construire une logique ultra sophistiquée.

## 11. Étape 9 : créer la page détail d'un projet

Tu dois créer une route dynamique.

Exemple classique :

- `src/app/projects/[slug]/page.tsx`

Pourquoi `[slug]` ?

Parce que le slug sert à construire une URL lisible :

- `/projects/mon-super-projet`

Sur cette page, tu affiches :

- titre
- promotion
- image
- date de publication
- projet Ada
- lien vers GitHub
- lien vers la démo

Question qu'on n'ose pas poser :

Pourquoi utiliser un `slug` et pas l'id ?

Réponse :
L'id marche aussi techniquement.
Mais le slug est plus joli, plus lisible, et l'énoncé le demande explicitement.

## 12. Étape 10 : créer le formulaire de proposition

Sur `/`, il faut un bouton `Proposer un projet` dans le header.
Ce bouton ouvre une popup ou dialog.

Le formulaire doit contenir :

- `title`
- `githubUrl`
- `demoUrl`
- `promotionId`
- `adaProjectId`

Le projet créé doit avoir :

- `createdAt` rempli automatiquement
- `publishedAt` à `null`

Question qu'on n'ose pas poser :

Popup, modal, dialog, c'est pareil ?

Réponse :
Dans ce projet, oui, on parle globalement de la même idée :
une fenêtre qui s'ouvre au-dessus de la page.

Question qu'on n'ose pas poser :

Je dois faire un formulaire client ou serveur ?

Réponse :
Avec Next App Router, tu peux faire plusieurs approches.
La plus simple à comprendre pour ce projet est :

- un composant client pour ouvrir/fermer la modal
- un appel à une route API ou une server action pour enregistrer le projet

Si tu veux limiter la complexité, une route API est souvent plus simple à déboguer quand on débute.

## 13. Étape 11 : valider les données

L'énoncé impose au minimum :

- pas de création si le titre est vide
- pas de création si les liens sont vides

Tu dois donc valider :

- côté front pour afficher une erreur rapide
- côté back pour empêcher l'insertion invalide

Question qu'on n'ose pas poser :

Pourquoi valider à deux endroits ?

Réponse :

- front : meilleure expérience utilisateur
- back : vraie sécurité métier

Si tu valides seulement côté front, quelqu'un pourrait contourner la règle.

Exemples de règles minimales :

- `title.trim()` ne doit pas être vide
- `githubUrl.trim()` ne doit pas être vide
- `demoUrl.trim()` ne doit pas être vide

Bonus intelligent :

- vérifier que `githubUrl` ressemble à une URL GitHub
- vérifier que `demoUrl` ressemble à une vraie URL

## 14. Étape 12 : créer les routes utiles

Selon ton organisation, tu auras sûrement :

- une page `/`
- une page `/projects/[slug]`
- une route API pour créer un projet

Exemple générique :

- `src/app/api/projects/route.ts`

Cette route reçoit les données du formulaire et insère en base.

Question qu'on n'ose pas poser :

C'est quoi la différence entre une page et une route API ?

Réponse :

- une page renvoie de l'interface
- une route API renvoie des données ou traite une action

## 15. Étape 13 : penser les composants utiles

Pour ne pas avoir un seul fichier énorme, découpe ton interface.

Exemples de composants possibles :

- `Header`
- `ProjectCard`
- `ProjectSection`
- `ProjectDialog`
- `ProjectForm`

Question qu'on n'ose pas poser :

Comment savoir quand créer un composant séparé ?

Réponse :
Si un bloc :

- a une responsabilité claire
- devient long
- ou doit être réutilisé

alors le sortir dans un composant est une bonne idée.

## 16. Étape 14 : passer le projet en TypeScript

Ton énoncé demande TypeScript, mais tes fichiers `layout.js` et `page.js` sont encore en JavaScript.

Donc pense à migrer progressivement vers :

- `.ts`
- `.tsx`

Minimum conseillé :

- `src/app/page.tsx`
- `src/app/layout.tsx`
- tes composants en `.tsx`

Question qu'on n'ose pas poser :

Je suis obligée de tout typer parfaitement ?

Réponse :
Non.
Le but est surtout :

- des props claires
- des données de formulaire compréhensibles
- des retours de base de données un peu cadrés

Tu n'as pas besoin d'un typage "niveau NASA" pour réussir ce projet.

## 17. Étape 15 : faire une interface simple mais propre

Ne bloque pas trois jours sur le design au début.
Fais d'abord quelque chose de lisible.

Priorités UI :

- header clair
- bouton `Proposer un projet`
- sections par projet Ada
- cartes lisibles
- page détail propre
- messages d'erreur visibles

Checklist visuelle minimale :

- bons espacements
- titres lisibles
- boutons cliquables
- mobile acceptable

## 18. Étape 16 : cas à tester absolument

Avant de considérer le projet "fini", teste au moins ça :

- un projet avec `publishedAt = null` n'apparaît pas sur `/`
- un projet publié apparaît bien sur `/`
- les projets sont triés du plus récent au plus ancien
- le clic sur une carte ouvre la bonne page détail
- le formulaire refuse un titre vide
- le formulaire refuse un lien GitHub vide
- le formulaire refuse un lien démo vide
- un projet soumis est bien créé avec `publishedAt = null`
- le logo renvoie bien à l'accueil

Question qu'on n'ose pas poser :

Tester "à la main", ça compte ?

Réponse :
Oui, complètement.
Des tests automatisés seraient bien, mais pour ce projet, des vérifications manuelles sérieuses sont déjà très utiles.

## 19. Étape 17 : quoi montrer en soutenance

Prépare une démo simple et fluide.
Tu n'as pas besoin de tout raconter.

Démo conseillée :

1. montrer la page d'accueil
2. expliquer que seuls les projets publiés apparaissent
3. ouvrir une page détail
4. revenir à l'accueil avec le logo
5. ouvrir le formulaire
6. proposer un projet
7. expliquer qu'il n'est pas publié automatiquement
8. montrer le schéma Drizzle
9. montrer une migration ou un seed SQL

## 20. Questions très fréquentes

### "Je fais d'abord le front ou le back ?"

Fais d'abord la base, puis le minimum d'affichage, puis le formulaire.
Le front sans données réelles donne souvent une fausse impression d'avancement.

### "Est-ce grave si je fais simple ?"

Non.
Un projet simple, propre et complet vaut mieux qu'un projet ambitieux mais cassé.

### "Je dois faire toutes les bonus ?"

Non.
Il vaut mieux finir parfaitement l'obligatoire.

### "Si je n'ai pas le temps pour le design ?"

Ce n'est pas dramatique si :

- l'application fonctionne
- les pages sont claires
- les consignes sont respectées

### "Comment savoir si je suis en retard ?"

Tu es en retard si tu restes trop longtemps sans flux complet.
Le premier objectif important est :

- voir des vraies données sortir de la base dans la homepage

Tant que ça, ce n'est pas fait, il faut éviter de te disperser.

## 21. Roadmap ultra concrète sur 2 jours

Si tu veux avancer vite, fais ça.

### Jour 1

- finaliser `schema.ts`
- générer la migration
- lancer la base
- créer les seeds SQL
- créer la connexion `db`
- afficher les projets publiés sur `/`

### Jour 2

- créer la page détail
- créer la modal et le formulaire
- créer la route d'insertion
- gérer les erreurs
- améliorer le style
- tester tout le parcours

## 22. Définition de "projet terminé"

Tu peux considérer le projet bouclé si :

- le schéma correspond à l'énoncé
- la migration fonctionne
- les seeds existent
- la page d'accueil affiche les projets publiés
- la page détail fonctionne
- le formulaire crée un projet non publié
- les erreurs minimales sont gérées
- le projet est déployé

## 23. Ton prochain meilleur pas

Si tu veux avancer sans réfléchir trop longtemps, fais exactement ça maintenant :

1. terminer `src/db/schema.ts`
2. supprimer la logique `users`
3. générer une migration propre
4. créer les seeds SQL
5. faire un fichier `db.ts`
6. afficher les vrais projets sur la homepage

C'est le chemin le plus direct vers un projet qui commence vraiment à exister.
