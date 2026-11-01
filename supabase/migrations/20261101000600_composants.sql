-- Composants de l'immeuble tels qu'ils figurent au tableau des immobilisations de la compta :
-- une valeur d'origine, une durée d'amortissement en mois (0 : terrain, non amortissable) et une date de mise en service.
create table public.composants (
  id         uuid primary key default gen_random_uuid(),
  libelle    text,
  valeur     numeric not null default 0,
  duree_mois int not null default 0 check (duree_mois >= 0),
  debut      date
);

alter table public.composants enable row level security;
create policy "lecture membres" on public.composants for select to authenticated using (public.mon_role() is not null);
create policy "ecriture editeurs" on public.composants for all to authenticated
  using (public.mon_role() = 'editeur') with check (public.mon_role() = 'editeur');

alter publication supabase_realtime add table public.composants;
