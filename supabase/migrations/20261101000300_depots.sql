-- Dépôts de garantie reçus des locataires (montant négatif : restitution).
-- Ils augmentent le solde bancaire mais ne sont ni un revenu ni un résultat : ils sont à rendre.
create table public.depots (
  id      uuid primary key default gen_random_uuid(),
  date    date,
  libelle text,
  montant numeric not null default 0
);

alter table public.depots enable row level security;
create policy "lecture membres" on public.depots for select to authenticated using (public.mon_role() is not null);
create policy "ecriture editeurs" on public.depots for all to authenticated
  using (public.mon_role() = 'editeur') with check (public.mon_role() = 'editeur');

alter publication supabase_realtime add table public.depots;
