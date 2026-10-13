-- Privileged one-off: promote an existing Auth user to trainer.
-- Run as a database owner / service role (Dashboard SQL editor or
-- `psql` as postgres). Do not run this from the app as an authenticated user.
--
-- Clients cannot change profiles.role. That column is not granted to
-- `authenticated`, and a trigger rejects role updates under that role.
--
-- 1. Replace the email with the trainer Auth email.
-- 2. Run the statement once.

update public.profiles as p
set role = 'trainer'
from auth.users as u
where p.id = u.id
  and u.email = 'REPLACE_WITH_TRAINER_EMAIL';
