begin;

create extension if not exists pgtap with schema extensions;

select plan(31);

create or replace function pg_temp.set_auth(p_id uuid)
returns void
language plpgsql
as $$
begin
  execute 'set local role authenticated';
  perform set_config('request.jwt.claim.sub', p_id::text, true);
  perform set_config('request.jwt.claim.role', 'authenticated', true);
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', p_id, 'role', 'authenticated')::text,
    true
  );
end;
$$;

create or replace function pg_temp.clear_auth()
returns void
language plpgsql
as $$
begin
  perform set_config('request.jwt.claim.sub', '', true);
  perform set_config('request.jwt.claim.role', '', true);
  perform set_config('request.jwt.claims', '{}', true);
  execute 'set local role postgres';
end;
$$;

create or replace function pg_temp.make_user(p_id uuid, p_email text)
returns void
language plpgsql
security definer
set search_path = pg_catalog, auth, public, extensions
as $$
begin
  insert into auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
  ) values (
    '00000000-0000-0000-0000-000000000000',
    p_id,
    'authenticated',
    'authenticated',
    p_email,
    extensions.crypt('test-password', extensions.gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  );
end;
$$;

-- Existing Auth user is backfilled as client, then promoted (privileged).
select pg_temp.make_user(
  '00000000-0000-0000-0000-000000000001',
  'trainer@test.local'
);
select pg_temp.make_user(
  '00000000-0000-0000-0000-0000000000a1',
  'client-a@test.local'
);
select pg_temp.make_user(
  '00000000-0000-0000-0000-0000000000b2',
  'client-b@test.local'
);

select is(
  (select role from public.profiles where id = '00000000-0000-0000-0000-000000000001'),
  'client',
  'new Auth users receive role client'
);

-- Privileged promotion (postgres / service role), not via authenticated RLS.
update public.profiles
set role = 'trainer'
where id = '00000000-0000-0000-0000-000000000001';

select is(
  (select role from public.profiles where id = '00000000-0000-0000-0000-000000000001'),
  'trainer',
  'privileged update can set trainer'
);

select is(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  true,
  'RLS enabled on profiles'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.dogs'::regclass),
  true,
  'RLS enabled on dogs'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.programmes'::regclass),
  true,
  'RLS enabled on programmes'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.entries'::regclass),
  true,
  'RLS enabled on entries'
);
select is(
  (select relrowsecurity from pg_class where oid = 'public.sessions'::regclass),
  true,
  'RLS enabled on sessions'
);

-- Trainer creates dog + programme for each client (same workflow, no
-- existing programme required to insert the dog).
select pg_temp.set_auth('00000000-0000-0000-0000-000000000001');

select lives_ok(
  $$insert into public.dogs (id, owner_id, name)
    values (
      '10000000-0000-0000-0000-0000000000a1',
      '00000000-0000-0000-0000-0000000000a1',
      'Hunden A'
    )$$,
  'trainer can insert a dog without an existing programme'
);

select lives_ok(
  $$insert into public.programmes (
      id, dog_id, client_id, trainer_id, status, title, current_focus
    ) values (
      '20000000-0000-0000-0000-0000000000a1',
      '10000000-0000-0000-0000-0000000000a1',
      '00000000-0000-0000-0000-0000000000a1',
      '00000000-0000-0000-0000-000000000001',
      'active',
      'Forloeb A',
      'Ro'
    )$$,
  'trainer can create programme A for client A'
);

select lives_ok(
  $$insert into public.dogs (id, owner_id, name)
    values (
      '10000000-0000-0000-0000-0000000000b2',
      '00000000-0000-0000-0000-0000000000b2',
      'Hunden B'
    )$$,
  'trainer can insert dog B'
);

select lives_ok(
  $$insert into public.programmes (
      id, dog_id, client_id, trainer_id, status, title
    ) values (
      '20000000-0000-0000-0000-0000000000b2',
      '10000000-0000-0000-0000-0000000000b2',
      '00000000-0000-0000-0000-0000000000b2',
      '00000000-0000-0000-0000-000000000001',
      'active',
      'Forloeb B'
    )$$,
  'trainer can create programme B for client B'
);

select throws_ok(
  $$insert into public.programmes (
      dog_id, client_id, trainer_id, title
    ) values (
      '10000000-0000-0000-0000-0000000000a1',
      '00000000-0000-0000-0000-0000000000b2',
      '00000000-0000-0000-0000-000000000001',
      'Forkert klient'
    )$$,
  '23514',
  'programmes.client_id must equal dogs.owner_id',
  'database rejects client/owner mismatch'
);

select lives_ok(
  $$insert into public.entries (programme_id, kind, body)
    values (
      '20000000-0000-0000-0000-0000000000a1',
      'focus',
      'Fokus fra traener'
    )$$,
  'trainer can insert focus on own programme'
);

select lives_ok(
  $$insert into public.sessions (programme_id, starts_at, location)
    values (
      '20000000-0000-0000-0000-0000000000a1',
      '2026-10-20T10:00:00+02',
      'Risskov'
    )$$,
  'trainer can insert a session on own programme'
);

-- Client A: allowed and denied operations
select pg_temp.set_auth('00000000-0000-0000-0000-0000000000a1');

select results_eq(
  $$select count(*)::integer from public.programmes$$,
  $$values (1)$$,
  'client A sees only their programme'
);

select lives_ok(
  $$insert into public.entries (programme_id, kind, body)
    values (
      '20000000-0000-0000-0000-0000000000a1',
      'observation',
      'Det gik godt i dag'
    )$$,
  'client A can insert an observation on their programme'
);

select throws_ok(
  $$insert into public.entries (programme_id, kind, body)
    values (
      '20000000-0000-0000-0000-0000000000a1',
      'feedback',
      'Ulovlig feedback'
    )$$,
  '42501',
  'new row violates row-level security policy for table "entries"',
  'client cannot insert feedback'
);

select throws_ok(
  $$insert into public.entries (programme_id, kind, body)
    values (
      '20000000-0000-0000-0000-0000000000b2',
      'observation',
      'Indbrud'
    )$$,
  '42501',
  'new row violates row-level security policy for table "entries"',
  'client A cannot insert on client B programme'
);

select is_empty(
  $$select id from public.programmes
    where id = '20000000-0000-0000-0000-0000000000b2'$$,
  'client A cannot read client B programme'
);

select is_empty(
  $$select id from public.dogs
    where id = '10000000-0000-0000-0000-0000000000b2'$$,
  'client A cannot read client B dog'
);

select throws_ok(
  $$update public.profiles set role = 'trainer'
    where id = '00000000-0000-0000-0000-0000000000a1'$$,
  '42501',
  'permission denied for table profiles',
  'client cannot change their own role'
);

select throws_ok(
  $$insert into public.dogs (owner_id, name)
    values ('00000000-0000-0000-0000-0000000000a1', 'Ulovlig hund')$$,
  '42501',
  'new row violates row-level security policy for table "dogs"',
  'client cannot insert a dog'
);

select lives_ok(
  $$update public.entries set body = 'Opdateret note'
    where programme_id = '20000000-0000-0000-0000-0000000000a1'
      and kind = 'observation'$$,
  'client A can update their own observation body'
);

select throws_ok(
  $$update public.entries
    set programme_id = '20000000-0000-0000-0000-0000000000b2'
    where programme_id = '20000000-0000-0000-0000-0000000000a1'$$,
  '42501',
  'permission denied for table entries',
  'client cannot move an entry to another programme'
);

-- Client B cannot read or change A's data
select pg_temp.set_auth('00000000-0000-0000-0000-0000000000b2');

select is_empty(
  $$select id from public.entries
    where programme_id = '20000000-0000-0000-0000-0000000000a1'$$,
  'client B cannot read client A entries'
);

select results_eq(
  $$update public.entries set body = 'Hacked'
    where programme_id = '20000000-0000-0000-0000-0000000000a1'
    returning 1$$,
  $$select 1 where false$$,
  'client B cannot update client A entries'
);

-- History remains readable after pause/end
select pg_temp.set_auth('00000000-0000-0000-0000-000000000001');

select lives_ok(
  $$update public.programmes
    set status = 'paused'
    where id = '20000000-0000-0000-0000-0000000000a1'$$,
  'trainer can pause their programme'
);

select lives_ok(
  $$update public.programmes
    set status = 'ended'
    where id = '20000000-0000-0000-0000-0000000000b2'$$,
  'trainer can end their programme'
);

select pg_temp.set_auth('00000000-0000-0000-0000-0000000000a1');

select results_eq(
  $$select count(*)::integer from public.entries
    where programme_id = '20000000-0000-0000-0000-0000000000a1'$$,
  $$values (2)$$,
  'client A can still read history on a paused programme'
);

select pg_temp.set_auth('00000000-0000-0000-0000-0000000000b2');

select results_eq(
  $$select status from public.programmes
    where id = '20000000-0000-0000-0000-0000000000b2'$$,
  $$values ('ended'::text)$$,
  'client B can still read an ended programme'
);

-- Anon: no table privilege
select pg_temp.clear_auth();
select set_config('role', 'anon', true);

select throws_ok(
  $$select * from public.profiles$$,
  '42501',
  'permission denied for table profiles',
  'anonymous users cannot read profiles'
);

select * from finish();
rollback;
