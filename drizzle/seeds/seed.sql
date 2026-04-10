-- ============================================================
-- ADAVERSE — SEED COMPLET
-- À exécuter dans Neon > SQL Editor, dans cet ordre
-- ============================================================


-- ------------------------------------------------------------
-- 1. PROMOTIONS
-- ------------------------------------------------------------

INSERT INTO promotions (name, start_date) VALUES
  ('Frida', '2023-09-01'),
  ('Grace', '2024-02-01');


-- ------------------------------------------------------------
-- 2. PROJETS ADA (types officiels)
-- ------------------------------------------------------------

INSERT INTO ada_projects (name) VALUES
  ('Ada Quiz'),
  ('Adapage'),
  ('Adataviz'),
  ('Adashboard'),
  ('Adalgo'),
  ('Adaverse'),
  ('Ada Check Event'),
  ('Adaopte'),
  ('Adaction'),
  ('Adaskill'),
  ('Adatabase'),
  ('AdaPatisserie'),
  ('Projet fil rouge');


-- ------------------------------------------------------------
-- 3. PROJETS ÉTUDIANTS — Promotion Grace
-- (tous non publiés par défaut : published_at = NULL)
-- ------------------------------------------------------------

-- Sammyhein — démos connues
INSERT INTO student_projects (title, slug, github_url, demo_url, promotion_id, ada_project_id) VALUES
  ('AdaSkill',     'adaskill-sammyhein',     'https://github.com/Sammyhein/AdaSkill',      'https://ada-skill.vercel.app/',         (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adaskill')),
  ('WakfuGoultard','wakfugoultard-sammyhein','https://github.com/Sammyhein/WakfuGoultard', 'https://wakfu-goultard.vercel.app/',    (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adapage')),
  ('ParisEvents',  'parisevents-sammyhein',  'https://github.com/Sammyhein/ParisEvents',   'https://paris-events-delta.vercel.app/',(SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adataviz'));

-- patphiletas — démos connues
INSERT INTO student_projects (title, slug, github_url, demo_url, promotion_id, ada_project_id) VALUES
  ('AdaRealBook',          'adarealbook-patphiletas',         'https://github.com/patphiletas/AdaRealBook',                 'https://real-book-patphiletas-projects.vercel.app', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Projet fil rouge')),
  ('Adapage Harry Potter', 'adapage-harry-potter-patphiletas','https://github.com/patphiletas/Adapage-Harry-Potter',        'https://adapage-harry-potter.vercel.app',           (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adapage')),
  ('Quiz Project',         'quiz-project-patphiletas',        'https://github.com/patphiletas/quiz-project',                'https://quiz-patphiletas.vercel.app',               (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Ada Quiz')),
  ('Skills',               'skills-patphiletas',              'https://github.com/patphiletas/skills',                      'https://skills-patphiletas.vercel.app',             (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adaskill')),
  ('Adataviz',             'adataviz-patphiletas',            'https://github.com/adatechschool/grace-adataviz-patphiletas','https://adataviz-patphiletas.vercel.app',           (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adataviz'));

-- sannehrobinm-rgb — pas de démo
INSERT INTO student_projects (title, slug, github_url, demo_url, promotion_id, ada_project_id) VALUES
  ('Pokedex',    'pokedex-sannehrobinm',    'https://github.com/sannehrobinm-rgb/01_pokedex_nouveau','', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adatabase')),
  ('CITIZEN13',  'citizen13-sannehrobinm',  'https://github.com/sannehrobinm-rgb/CITIZEN13',          '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Projet fil rouge')),
  ('GlobeDelice','globedelice-sannehrobinm','https://github.com/sannehrobinm-rgb/GlobeD-lice',        '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'AdaPatisserie'));

-- egainon — pas de démo
INSERT INTO student_projects (title, slug, github_url, demo_url, promotion_id, ada_project_id) VALUES
  ('Adataviz Emilie','adataviz-egainon','https://github.com/egainon/Adataviz-emilie','', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adataviz')),
  ('Adatabase',      'adatabase-egainon','https://github.com/egainon/Adatabase-Em',  '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adatabase')),
  ('Pokedex Explorer','pokedex-egainon','https://github.com/egainon/Pokedex_Explorer','', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Projet fil rouge'));

-- Hgo92 — démos connues sauf Ada Quiz
INSERT INTO student_projects (title, slug, github_url, demo_url, promotion_id, ada_project_id) VALUES
  ('Adapage Zineb Hugo','adapage-zineb-hugo', 'https://github.com/adatechschool/grace-adapage-zineb-hugo','https://adapage-zineb-hugo.vercel.app/',    (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adapage')),
  ('Adataviz',          'adataviz-hgo92',     'https://github.com/adatechschool/grace-adataviz-Hgo92',    'https://grace-adataviz-hgo92.vercel.app/',  (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adataviz')),
  ('Ada Quiz',          'adaquiz-hgo92',      'https://github.com/Hgo92/projet_quiz',                     '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Ada Quiz')),
  ('Adashboard',        'adashboard-hgo92',   'https://github.com/adatechschool/grace-adashboard-Hgo92',  'https://grace-adashboard-hgo92.vercel.app/',(SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adashboard')),
  ('Learn With Me',     'learn-with-me-hgo92','https://github.com/Hgo92/learn-with-me-hgo92',              'https://learn-with-me-hgo92.vercel.app/',   (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Projet fil rouge'));

-- gab-hono — pas de démo
INSERT INTO student_projects (title, slug, github_url, demo_url, promotion_id, ada_project_id) VALUES
  ('Quiz Ghibli',     'quiz-ghibli-gabhono',    'https://github.com/gab-hono/Quiz-Ghibli',          '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Ada Quiz')),
  ('Pokedex',         'pokedex-gabhono',         'https://github.com/gab-hono/Pokedex',              '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adatabase')),
  ('Piscines Paris',  'piscines-paris-gabhono',  'https://github.com/gab-hono/PiscinesParis-Frontend','', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adataviz')),
  ('Delicious Review','delicious-review-gabhono','https://github.com/gab-hono/deliciousReview',      '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'AdaPatisserie')),
  ('Adapage',         'adapage-gabriel-emilie',  'https://github.com/adatechschool/grace-adapage-gabriel-emilie','', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adapage'));


-- ------------------------------------------------------------
-- 4. PROJETS OFFICIELS — Grace (PDF, sans démo connue)
-- ------------------------------------------------------------

INSERT INTO student_projects (title, slug, github_url, demo_url, promotion_id, ada_project_id) VALUES
  ('Adaverse Gab-Hono',   'adaverse-gab-hono',   'https://github.com/adatechschool/grace-adaverse-gab-hono',    '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adaverse')),
  ('Adataviz Candichou',  'adataviz-candichou',   'https://github.com/adatechschool/grace-adataviz-Candichou',   '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adataviz')),
  ('Adalgo Egainon',      'adalgo-egainon',        'https://github.com/adatechschool/grace-adalgo-egainon',       '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adalgo')),
  ('Adalgo Gkhosty',      'adalgo-gkhosty',        'https://github.com/adatechschool/grace-adalgo-Gkhosty',       '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adalgo')),
  ('Adalgo Gab-Hono',     'adalgo-gab-hono',       'https://github.com/adatechschool/grace-adalgo-gab-hono',      '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adalgo')),
  ('Adashboard Gab-Hono', 'adashboard-gab-hono',   'https://github.com/adatechschool/grace-adashboard-gab-hono',  '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adashboard')),
  ('Adashboard Egainon',  'adashboard-egainon',    'https://github.com/adatechschool/grace-adashboard-egainon',   '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adashboard')),
  ('Adashboard Zineb712', 'adashboard-zineb712',   'https://github.com/adatechschool/grace-adashboard-zineb712',  '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adashboard')),
  ('Adashboard Candichou','adashboard-candichou',  'https://github.com/adatechschool/grace-adashboard-Candichou', '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adashboard')),
  ('Adashboard Teizred',  'adashboard-teizred',    'https://github.com/adatechschool/grace-adashboard-teizred',   '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adashboard')),
  ('Adashboard Ocette',   'adashboard-ocette',     'https://github.com/adatechschool/grace-adashboard-ocette',    '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adashboard')),
  ('Adashboard Hc491',    'adashboard-hc491',      'https://github.com/adatechschool/grace-adashboard-hc491',     '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adashboard')),
  ('Adapage Chapat',      'adapage-chapat',         'https://github.com/adatechschool/grace-adapage-chapat',       '', (SELECT id FROM promotions WHERE name = 'Grace'), (SELECT id FROM ada_projects WHERE name = 'Adapage'));


-- ------------------------------------------------------------
-- 5. PUBLIER LES PROJETS AVEC UNE VRAIE DÉMO
-- Seuls les projets avec une demo_url réelle sont publiés
-- ------------------------------------------------------------

UPDATE student_projects SET published_at = NOW()
WHERE slug IN (
  -- Sammyhein
  'adaskill-sammyhein',
  'wakfugoultard-sammyhein',
  'parisevents-sammyhein',
  -- patphiletas
  'adarealbook-patphiletas',
  'adapage-harry-potter-patphiletas',
  'quiz-project-patphiletas',
  'skills-patphiletas',
  'adataviz-patphiletas',
  -- Hgo92
  'adapage-zineb-hugo',
  'adataviz-hgo92',
  'adashboard-hgo92',
  'learn-with-me-hgo92'
);
