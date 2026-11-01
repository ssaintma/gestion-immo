-- Calendrier de paiement des charges : mensuel (par douzièmes), trimestriel ou annuel, à partir d'un mois donné.
alter table public.charges
  add column periodicite text not null default 'mensuel' check (periodicite in ('mensuel', 'trimestriel', 'annuel')),
  add column mois int not null default 1 check (mois between 1 and 12);
