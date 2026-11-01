-- Autorise le paiement ponctuel (dépense unique) dans les charges.
alter table public.charges drop constraint charges_periodicite_check;
alter table public.charges add constraint charges_periodicite_check
  check (periodicite in ('mensuel', 'trimestriel', 'annuel', 'ponctuel'));
