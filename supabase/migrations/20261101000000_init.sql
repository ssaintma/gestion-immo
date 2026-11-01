-- Vente du local : schéma initial.
-- À exécuter une fois dans Supabase (SQL Editor) ou avec `supabase db push`.

-- Qui a accès : une ligne par associé, repérée par son e-mail (en minuscules).
create table public.membres (
  email text primary key check (email = lower(email)),
  role  text not null default 'lecteur' check (role in ('lecteur', 'editeur'))
);

-- Rôle de la personne connectée, ou null si elle n'est pas dans la liste.
-- security definer : la fonction lit `membres` sans dépendre des règles de cette table.
create function public.mon_role() returns text
language sql stable security definer set search_path = public as $$
  select role from public.membres where email = lower(auth.jwt() ->> 'email')
$$;

alter table public.membres enable row level security;
create policy "chacun voit sa ligne" on public.membres
  for select to authenticated using (email = lower(auth.jwt() ->> 'email'));
-- Aucune règle d'écriture : on ajoute les associés depuis le SQL Editor.

-- Hypothèses : une seule ligne, tous les paramètres dans `data`.
create table public.hypotheses (
  id   int primary key default 1 check (id = 1),
  data jsonb not null default '{}'
);

create table public.travaux (
  id         uuid primary key default gen_random_uuid(),
  date       date,
  libelle    text,
  montant    numeric not null default 0,
  traitement text not null default 'immobilise' check (traitement in ('immobilise', 'charge'))
);

create table public.charges (
  id        uuid primary key default gen_random_uuid(),
  debut     date,
  fin       date,
  libelle   text,
  categorie text not null default 'copro' check (categorie in ('copro', 'comptable', 'taxe_fonciere', 'autre')),
  montant   numeric not null default 0
);

create table public.loyers (
  id      uuid primary key default gen_random_uuid(),
  annee   int,
  montant numeric not null default 0,
  libelle text
);

create table public.projection (
  id      uuid primary key default gen_random_uuid(),
  debut   date,
  mensuel numeric not null default 0,
  libelle text
);

create table public.versements (
  id      uuid primary key default gen_random_uuid(),
  date    date,
  libelle text,
  nature  text not null default 'compte_courant' check (nature in ('compte_courant', 'capital')),
  montant numeric not null default 0
);

-- Échéancier du prêt (données bancaires : derrière la connexion, pas dans le code publié).
create table public.echeancier (
  n          int primary key,
  date       date not null,
  echeance   numeric not null,
  assurance  numeric not null default 0,
  interets   numeric not null default 0,
  amortissement numeric not null,
  crd        numeric not null
);

-- Règles d'accès : les membres lisent, les éditeurs écrivent.
do $$
declare t text;
begin
  foreach t in array array['hypotheses', 'travaux', 'charges', 'loyers', 'projection', 'versements', 'echeancier'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('create policy "lecture membres" on public.%I for select to authenticated using (public.mon_role() is not null)', t);
    execute format('create policy "ecriture editeurs" on public.%I for all to authenticated using (public.mon_role() = ''editeur'') with check (public.mon_role() = ''editeur'')', t);
  end loop;
end $$;

-- Temps réel : les modifications d'un associé apparaissent chez les autres.
alter publication supabase_realtime add table
  public.hypotheses, public.travaux, public.charges, public.loyers, public.projection, public.versements;
