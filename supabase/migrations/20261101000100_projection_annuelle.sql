-- Loyers prévus : passage d'une saisie mensuelle (debut, mensuel) à une saisie annuelle (annee, annuel).
-- Les lignes existantes sont converties : année du mois de début, loyer mensuel x 12.
alter table public.projection add column annee int, add column annuel numeric not null default 0;
update public.projection set annee = extract(year from debut)::int, annuel = mensuel * 12;
alter table public.projection drop column debut, drop column mensuel;
