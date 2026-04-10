# 🌐 Adaverse — Guide pas à pas

> Stack : Next.js + TypeScript + TailwindCSS + Drizzle ORM + Neon (PostgreSQL)
> Durée : 2 semaines. Ce guide suit l'ordre logique pour ne pas se planter.

---

## Avant de commencer — Ce que tu dois avoir en tête

**C'est quoi Next.js exactement ?**
Next.js est un framework React qui gère à la fois le frontend ET le backend dans le même projet. Tu n'as pas un dossier `client/` et un dossier `server/` séparés comme avec Express. Tout cohabite. Une page peut être un composant React, et une route API aussi — dans le même repo.

**C'est quoi Drizzle ORM ?**
Un ORM, c'est une couche de code qui te permet d'écrire tes requêtes SQL en JavaScript plutôt qu'en SQL brut. Au lieu de `SELECT * FROM projects WHERE id = 1`, tu écris quelque chose comme `db.select().from(projects).where(eq(projects.id, 1))`. Drizzle est particulièrement léger et proche du SQL — tu ne perds pas le fil de ce qui se passe réellement.

**C'est quoi Neon ?**
Une base de données PostgreSQL hébergée dans le cloud. Gratuit pour un projet perso/école. Tu n'installes rien en local pour la BDD — elle est accessible via une URL de connexion.

**Question bête n°1 : pourquoi TypeScript et pas JavaScript ?**
TypeScript = JavaScript avec des types. Tu déclares ce que contient chaque variable (un string, un nombre, un objet avec tel champ…). Ça paraît contraignant, mais ça t'évite des bugs silencieux. Dans ce projet, tu vas le croiser partout mais tu n'as pas besoin de le maîtriser à fond — suis les patterns.

---

## PHASE 1 — Mise en place du projet

### Étape 1.1 — Créer le projet Next.js

Dans ton terminal, à l'endroit où tu veux créer le dossier :

```bash
npx create-next-app@latest adaverse-[ton-github]
```

Pendant la config interactive, réponds :
- TypeScript → **Yes**
- ESLint → Yes
- Tailwind CSS → **Yes**
- `src/` directory → No (garde la structure par défaut)
- App Router → **Yes** (c'est le système de routing moderne de Next.js)
- Import alias → No

**Question bête n°2 : c'est quoi l'App Router ?**
Next.js a deux systèmes de routing. L'ancien (`pages/`) et le nouveau (`app/`). Avec l'App Router, tu crées un dossier `app/` et chaque sous-dossier = une route. `app/projets/page.tsx` = la page accessible à `/projets`. C'est ça la logique.

```
adaverse/
├── app/
│   ├── page.tsx          ← route "/"
│   ├── layout.tsx        ← layout global (header, footer)
│   └── [slug]/
│       └── page.tsx      ← route "/n-importe-quel-slug"
├── components/           ← tes composants réutilisables
├── lib/                  ← connexion BDD, utilitaires
└── drizzle/              ← schéma + migrations
```

### Étape 1.2 — Créer le compte Neon et récupérer la connection string

1. Va sur [neon.com](https://neon.com)
2. Crée un compte → New Project → donne-lui un nom
3. Une fois créé, copie la **connection string** (format `postgresql://user:password@host/dbname`)
4. Dans ton projet, crée un fichier `.env` à la racine :

```env
DATABASE_URL="postgresql://user:password@host/dbname?sslmode=require"
```

> ⚠️ Ajoute `.env` dans ton `.gitignore` si ce n'est pas déjà fait. Ne pousse jamais tes secrets sur GitHub.

**Question bête n°3 : pourquoi `?sslmode=require` ?**
Neon exige une connexion chiffrée. Sans ça, la connexion est refusée.

### Étape 1.3 — Installer et configurer Drizzle

```bash
npm install drizzle-orm @neondatabase/serverless
npm install -D drizzle-kit
```

Crée le fichier `drizzle.config.ts` à la racine :

```ts
import type { Config } from "drizzle-kit";

export default {
  schema: "./drizzle/schema.ts",
  out: "./drizzle/migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
} satisfies Config;
```

Crée le fichier de connexion `lib/db.ts` :

```ts
import { neon } from "@neondatabase/serverless";
import { drizzle } from "drizzle-orm/neon-http";

const sql = neon(process.env.DATABASE_URL!);
export const db = drizzle(sql);
```

**Question bête n°4 : le `!` après `process.env.DATABASE_URL`, c'est quoi ?**
C'est du TypeScript. `process.env.DATABASE_URL` peut théoriquement être `undefined` (si tu oublies de la définir). Le `!` dit à TypeScript "fais-moi confiance, cette valeur existe". C'est un raccourci — en prod tu ferais une vraie vérification.

---

## PHASE 2 — Schéma de base de données

### Étape 2.1 — Créer le schéma Drizzle

Crée le fichier `drizzle/schema.ts` :

```ts
import { pgTable, serial, text, timestamp } from "drizzle-orm/pg-core";

// Table des projets Ada (les "types" de projets : Ada Quiz, Adaopte, etc.)
export const adaProjects = pgTable("ada_projects", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

// Table des promotions
export const promotions = pgTable("promotions", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  startDate: timestamp("start_date").notNull(),
});

// Table des projets étudiants
export const studentProjects = pgTable("student_projects", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  slug: text("slug").notNull().unique(),
  githubUrl: text("github_url").notNull(),
  demoUrl: text("demo_url").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  publishedAt: timestamp("published_at"), // NULL = non publié
  promotionId: serial("promotion_id").references(() => promotions.id),
  adaProjectId: serial("ada_project_id").references(() => adaProjects.id),
});
```

**Question bête n°5 : c'est quoi `serial` ?**
C'est un type PostgreSQL qui auto-incrémente. Tu n'as pas à gérer les IDs toi-même — la base crée 1, 2, 3… automatiquement à chaque insertion.

**Question bête n°6 : c'est quoi `.references()` ?**
C'est la clé étrangère (foreign key). `promotionId` dans `studentProjects` pointe vers `id` dans `promotions`. C'est ce qui lie les tables entre elles — l'équivalent d'un `JOIN` en SQL.

**Question bête n°7 : pourquoi `publishedAt` n'a pas `.notNull()` ?**
Parce qu'un projet soumis mais pas encore validé n'a pas de date de publication. La valeur sera `NULL` en base. C'est intentionnel — c'est comme ça qu'on distingue les projets publiés des autres.

### Étape 2.2 — Générer et appliquer la migration

```bash
npx drizzle-kit generate
npx drizzle-kit migrate
```

La première commande génère un fichier SQL dans `drizzle/migrations/`. La seconde l'exécute sur ta base Neon.

**Vérifie dans Neon** : va dans l'interface Neon → Tables — tu dois voir tes 3 tables apparaître.

---

## PHASE 3 — Seed de données

### Étape 3.1 — Script SQL pour les promotions

Crée `drizzle/seeds/promotions.sql` :

```sql
INSERT INTO promotions (name, start_date) VALUES
  ('Frida', '2023-09-01'),
  ('Grace', '2024-02-01'),
  ('Ada', '2024-09-01');
```

### Étape 3.2 — Script SQL pour les projets Ada

Crée `drizzle/seeds/ada_projects.sql` :

```sql
INSERT INTO ada_projects (name) VALUES
  ('Ada Quiz'),
  ('Adaopte'),
  ('Ada Check Events'),
  ('Adaverse');
```

### Étape 3.3 — Script pour publier un projet

Crée `drizzle/seeds/publish_project.sql` :

```sql
-- Remplace l'id par celui du projet à publier
UPDATE student_projects
SET published_at = NOW()
WHERE id = 1;
```

**Pour exécuter ces scripts** : dans l'interface Neon, onglet "SQL Editor", colle et exécute.

---

## PHASE 4 — Routes API (le backend)

**Question bête n°8 : une route API dans Next.js, c'est quoi exactement ?**
Dans le dossier `app/`, si tu crées un fichier `route.ts` (et non `page.tsx`), Next.js va l'exposer comme un endpoint HTTP. `app/api/projects/route.ts` sera accessible à `GET /api/projects`. Ton frontend peut ensuite faire un `fetch("/api/projects")` pour récupérer les données.

### Étape 4.1 — Route GET pour récupérer les projets publiés

Crée `app/api/projects/route.ts` :

```ts
import { db } from "@/lib/db";
import { studentProjects, promotions, adaProjects } from "@/drizzle/schema";
import { isNotNull } from "drizzle-orm";
import { NextResponse } from "next/server";

export async function GET() {
  const projects = await db
    .select()
    .from(studentProjects)
    .where(isNotNull(studentProjects.publishedAt))
    .orderBy(studentProjects.publishedAt);

  return NextResponse.json(projects);
}
```

**Question bête n°9 : c'est quoi `isNotNull` ?**
C'est la traduction Drizzle de `WHERE published_at IS NOT NULL` en SQL. On veut seulement les projets qui ont une date de publication.

### Étape 4.2 — Route POST pour soumettre un projet

Dans le même fichier `app/api/projects/route.ts`, ajoute :

```ts
export async function POST(request: Request) {
  const body = await request.json();
  const { title, githubUrl, demoUrl, promotionId, adaProjectId } = body;

  // Validation basique
  if (!title || !githubUrl || !demoUrl) {
    return NextResponse.json(
      { error: "Titre et liens obligatoires" },
      { status: 400 }
    );
  }

  // Générer un slug depuis le titre
  const slug = title
    .toLowerCase()
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9-]/g, "");

  const newProject = await db
    .insert(studentProjects)
    .values({
      title,
      slug,
      githubUrl,
      demoUrl,
      promotionId,
      adaProjectId,
    })
    .returning();

  return NextResponse.json(newProject[0], { status: 201 });
}
```

**Question bête n°10 : c'est quoi `.returning()` ?**
Par défaut, un `INSERT` ne retourne rien. `.returning()` dit à PostgreSQL de renvoyer la ligne insérée — utile pour confirmer ce qui a été créé.

**Question bête n°11 : le status 400 et 201, c'est quoi ?**
Ce sont les codes HTTP. 200 = OK. 201 = Créé avec succès. 400 = Bad Request (le client a envoyé des données invalides). Tu les mets pour que le frontend sache ce qui s'est passé.

### Étape 4.3 — Route GET pour un projet par slug

Crée `app/api/projects/[slug]/route.ts` :

```ts
import { db } from "@/lib/db";
import { studentProjects } from "@/drizzle/schema";
import { eq } from "drizzle-orm";
import { NextResponse } from "next/server";

export async function GET(
  request: Request,
  { params }: { params: { slug: string } }
) {
  const project = await db
    .select()
    .from(studentProjects)
    .where(eq(studentProjects.slug, params.slug))
    .limit(1);

  if (!project[0]) {
    return NextResponse.json({ error: "Projet introuvable" }, { status: 404 });
  }

  return NextResponse.json(project[0]);
}
```

**Question bête n°12 : le dossier s'appelle `[slug]` avec des crochets, c'est normal ?**
Oui. C'est la syntaxe Next.js pour les routes dynamiques. `[slug]` veut dire "n'importe quelle valeur". La requête vers `/api/projects/mon-projet` sera capturée par ce fichier, et `params.slug` vaudra `"mon-projet"`.

### Étape 4.4 — Route GET pour promotions et projets Ada (pour les menus déroulants)

Crée `app/api/promotions/route.ts` :

```ts
import { db } from "@/lib/db";
import { promotions } from "@/drizzle/schema";
import { NextResponse } from "next/server";

export async function GET() {
  const data = await db.select().from(promotions);
  return NextResponse.json(data);
}
```

Même chose pour `app/api/ada-projects/route.ts` avec `adaProjects`.

---

## PHASE 5 — Pages frontend

**Question bête n°13 : la différence entre `page.tsx` et `route.ts` dans l'App Router ?**
`page.tsx` = ce que l'utilisateur voit dans son navigateur (un composant React).
`route.ts` = un endpoint API (pas de HTML, juste des données JSON).
Les deux cohabitent dans `app/` mais servent à des choses différentes.

**Question bête n°14 : c'est quoi `"use client"` ?**
Par défaut dans l'App Router, tous les composants sont des **Server Components** — ils s'exécutent côté serveur et ne peuvent pas utiliser `useState`, `useEffect`, ou les événements (`onClick`). Si tu as besoin d'interactivité, tu ajoutes `"use client"` en première ligne du fichier. Ça dit à Next.js : "ce composant tourne dans le navigateur".

Règle simple : commence sans `"use client"`. Si Next.js se plaint que tu utilises un hook ou un event handler, ajoute-le.

### Étape 5.1 — Page d'accueil

Crée `app/page.tsx` :

```tsx
import { db } from "@/lib/db";
import { studentProjects, adaProjects } from "@/drizzle/schema";
import { isNotNull } from "drizzle-orm";
import ProjectCard from "@/components/ProjectCard";
import ProposalButton from "@/components/ProposalButton";

export default async function HomePage() {
  // Ce composant est un Server Component → il peut accéder à la BDD directement
  const projects = await db
    .select()
    .from(studentProjects)
    .where(isNotNull(studentProjects.publishedAt));

  return (
    <main className="max-w-4xl mx-auto p-8">
      <header className="flex justify-between items-center mb-8">
        <h1 className="text-2xl font-bold">Adaverse</h1>
        <ProposalButton />
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {projects.map((project) => (
          <ProjectCard key={project.id} project={project} />
        ))}
      </div>
    </main>
  );
}
```

**Question bête n°15 : `async` sur un composant React, c'est possible ?**
Seulement dans les Server Components de Next.js (App Router). C'est une des nouveautés : tu peux `await` directement dans le composant. Pas besoin de `useEffect` + `fetch` pour les données initiales.

### Étape 5.2 — Composant ProjectCard

Crée `components/ProjectCard.tsx` :

```tsx
import Link from "next/link";
import Image from "next/image";

type Project = {
  id: number;
  title: string;
  slug: string;
  githubUrl: string;
  publishedAt: Date | null;
};

export default function ProjectCard({ project }: { project: Project }) {
  const thumbnailUrl = `${project.githubUrl.replace("github.com", "raw.githubusercontent.com")}/main/thumbnail.png`;

  return (
    <Link href={`/${project.slug}`}>
      <div className="border rounded-lg overflow-hidden hover:shadow-md transition-shadow">
        <div className="relative h-48 bg-gray-100">
          <Image
            src={thumbnailUrl}
            alt={project.title}
            fill
            className="object-cover"
            onError={() => {}} // géré via fallback CSS
          />
        </div>
        <div className="p-4">
          <h2 className="font-semibold text-lg">{project.title}</h2>
          {project.publishedAt && (
            <p className="text-sm text-gray-500">
              {new Date(project.publishedAt).toLocaleDateString("fr-FR")}
            </p>
          )}
        </div>
      </div>
    </Link>
  );
}
```

### Étape 5.3 — Bouton "Proposer un projet" avec popup

Ce composant a besoin d'interactivité → `"use client"`.

Crée `components/ProposalButton.tsx` :

```tsx
"use client";

import { useState } from "react";
import ProposalDialog from "./ProposalDialog";

export default function ProposalButton() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="bg-black text-white px-4 py-2 rounded-lg hover:bg-gray-800"
      >
        Proposer un projet
      </button>

      {isOpen && <ProposalDialog onClose={() => setIsOpen(false)} />}
    </>
  );
}
```

### Étape 5.4 — Le formulaire (dialog)

Crée `components/ProposalDialog.tsx` :

```tsx
"use client";

import { useState, useEffect } from "react";

type Props = {
  onClose: () => void;
};

export default function ProposalDialog({ onClose }: Props) {
  const [title, setTitle] = useState("");
  const [githubUrl, setGithubUrl] = useState("");
  const [demoUrl, setDemoUrl] = useState("");
  const [promotionId, setPromotionId] = useState("");
  const [adaProjectId, setAdaProjectId] = useState("");
  const [promotions, setPromotions] = useState([]);
  const [adaProjects, setAdaProjects] = useState([]);
  const [error, setError] = useState("");

  // Charger les options des menus déroulants
  useEffect(() => {
    fetch("/api/promotions").then((r) => r.json()).then(setPromotions);
    fetch("/api/ada-projects").then((r) => r.json()).then(setAdaProjects);
  }, []);

  async function handleSubmit() {
    setError("");

    if (!title || !githubUrl || !demoUrl) {
      setError("Tous les champs obligatoires doivent être remplis.");
      return;
    }

    const res = await fetch("/api/projects", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title, githubUrl, demoUrl, promotionId, adaProjectId }),
    });

    if (res.ok) {
      onClose();
    } else {
      const data = await res.json();
      setError(data.error || "Une erreur est survenue.");
    }
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl p-6 w-full max-w-md">
        <h2 className="text-xl font-bold mb-4">Proposer un projet</h2>

        {error && <p className="text-red-500 text-sm mb-4">{error}</p>}

        <div className="space-y-3">
          <input
            placeholder="Titre du projet *"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full border rounded px-3 py-2"
          />
          <input
            placeholder="Lien GitHub *"
            value={githubUrl}
            onChange={(e) => setGithubUrl(e.target.value)}
            className="w-full border rounded px-3 py-2"
          />
          <input
            placeholder="Lien démo *"
            value={demoUrl}
            onChange={(e) => setDemoUrl(e.target.value)}
            className="w-full border rounded px-3 py-2"
          />

          <select
            value={promotionId}
            onChange={(e) => setPromotionId(e.target.value)}
            className="w-full border rounded px-3 py-2"
          >
            <option value="">Choisir une promotion</option>
            {promotions.map((p: any) => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>

          <select
            value={adaProjectId}
            onChange={(e) => setAdaProjectId(e.target.value)}
            className="w-full border rounded px-3 py-2"
          >
            <option value="">Choisir un projet Ada</option>
            {adaProjects.map((p: any) => (
              <option key={p.id} value={p.id}>{p.name}</option>
            ))}
          </select>
        </div>

        <div className="flex gap-3 mt-6">
          <button
            onClick={onClose}
            className="flex-1 border rounded px-4 py-2 hover:bg-gray-50"
          >
            Annuler
          </button>
          <button
            onClick={handleSubmit}
            className="flex-1 bg-black text-white rounded px-4 py-2 hover:bg-gray-800"
          >
            Soumettre
          </button>
        </div>
      </div>
    </div>
  );
}
```

**Question bête n°16 : pourquoi `useEffect` avec un tableau vide `[]` ?**
`useEffect(() => { ... }, [])` s'exécute une seule fois, au montage du composant. C'est l'équivalent de "au chargement, va chercher les données". Sans le `[]`, ça tournerait en boucle infinie.

### Étape 5.5 — Page de détail d'un projet

Crée `app/[slug]/page.tsx` :

```tsx
import { db } from "@/lib/db";
import { studentProjects } from "@/drizzle/schema";
import { eq } from "drizzle-orm";
import Link from "next/link";
import { notFound } from "next/navigation";

export default async function ProjectPage({
  params,
}: {
  params: { slug: string };
}) {
  const result = await db
    .select()
    .from(studentProjects)
    .where(eq(studentProjects.slug, params.slug))
    .limit(1);

  const project = result[0];
  if (!project) notFound();

  return (
    <main className="max-w-2xl mx-auto p-8">
      <Link href="/" className="text-sm text-gray-500 hover:underline mb-6 block">
        ← Retour à l'accueil
      </Link>

      <h1 className="text-3xl font-bold mb-2">{project.title}</h1>

      {project.publishedAt && (
        <p className="text-sm text-gray-500 mb-6">
          Publié le {new Date(project.publishedAt).toLocaleDateString("fr-FR")}
        </p>
      )}

      <div className="flex gap-4">
        <a
          href={project.githubUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="bg-black text-white px-4 py-2 rounded hover:bg-gray-800"
        >
          Voir sur GitHub
        </a>
        <a
          href={project.demoUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="border px-4 py-2 rounded hover:bg-gray-50"
        >
          Voir la démo
        </a>
      </div>
    </main>
  );
}
```

**Question bête n°17 : `notFound()`, c'est quoi ?**
C'est une fonction de Next.js qui renvoie automatiquement une page 404. Plus propre que de renvoyer du HTML vide ou de gérer ça à la main.

---

## PHASE 6 — Déploiement sur Vercel

### Étape 6.1 — Pousser sur GitHub

```bash
git add .
git commit -m "feat: projet Adaverse fonctionnel"
git push origin main
```

### Étape 6.2 — Créer les branches de rendu

```bash
git checkout -b stable
git push origin stable

git checkout -b bonus
git push origin bonus
```

### Étape 6.3 — Déployer sur Vercel

1. Va sur [vercel.com](https://vercel.com) → New Project
2. Importe ton repo GitHub
3. Dans les settings du projet → **Environment Variables** → ajoute :
   - Key : `DATABASE_URL`
   - Value : ta connection string Neon
4. Clique Deploy

> ⚠️ Déploie tôt, même avec une version basique. Ça évite les mauvaises surprises la veille de la soutenance.

---

## Checklist finale avant soutenance

### Backend / BDD
- [ ] Schéma Drizzle créé (3 tables)
- [ ] Migration appliquée sur Neon
- [ ] Seed : promotions + projets Ada insérés
- [ ] Route GET `/api/projects` (projets publiés)
- [ ] Route POST `/api/projects` (soumission avec validation)
- [ ] Route GET `/api/projects/[slug]`
- [ ] Route GET `/api/promotions`
- [ ] Route GET `/api/ada-projects`

### Frontend
- [ ] Page `/` avec liste des projets publiés
- [ ] Bouton "Proposer un projet" dans le header
- [ ] Dialog avec formulaire fonctionnel
- [ ] Validation et affichage des erreurs dans le formulaire
- [ ] Page `/[slug]` avec détail du projet
- [ ] Lien retour vers l'accueil (logo ou lien)
- [ ] Liens GitHub et démo dans la page de détail

### Déploiement
- [ ] Variable d'environnement sur Vercel
- [ ] App déployée et fonctionnelle
- [ ] Branche `stable` à jour
- [ ] Dernier commit avant minuit la veille

---

## Ce que tu dois savoir expliquer à l'oral

- **Pourquoi Drizzle plutôt que du SQL brut ?** → Typage TypeScript, refactoring plus sûr, migrations automatiques.
- **C'est quoi un Server Component ?** → S'exécute côté serveur, peut accéder à la BDD directement, pas de `useState`.
- **Pourquoi `publishedAt` peut être NULL ?** → Pour distinguer les projets soumis (en attente) des projets validés (publiés).
- **Comment fonctionne le routing dynamique ?** → `[slug]` capture n'importe quelle valeur dans l'URL, accessible via `params.slug`.
- **Qu'est-ce qu'une foreign key ?** → Un champ qui référence l'ID d'une autre table, pour lier les données entre elles.

---

*Guide généré pour le projet Adaverse — Ada Tech School*
