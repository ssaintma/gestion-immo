-- IS de chaque exercice, saisi à la main (remplace l'estimation de la page pour cette année).
create table public.impots (
  id      uuid primary key default gen_random_uuid(),
  annee   int,
  montant numeric not null default 0,
  libelle text
);

alter table public.impots enable row level security;
create policy "lecture membres" on public.impots for select to authenticated using (public.mon_role() is not null);
create policy "ecriture editeurs" on public.impots for all to authenticated
  using (public.mon_role() = 'editeur') with check (public.mon_role() = 'editeur');

alter publication supabase_realtime add table public.impots;
