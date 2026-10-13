-- OWDT v2 initial schema: profiles, dogs, programmes, entries, sessions.
-- RLS helpers are SECURITY DEFINER with a fixed search_path to avoid
-- policy recursion between profiles and programmes.

create schema if not exists private;

revoke all on schema private from public;
grant usage on schema private to authenticated;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null default 'client' check (role in ('trainer', 'client')),
  display_name text not null,
  created_at timestamptz not null default now()
);

create table public.dogs (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete restrict,
  name text not null check (char_length(trim(name)) > 0),
  notes text,
  created_at timestamptz not null default now()
);

create table public.programmes (
  id uuid primary key default gen_random_uuid(),
  dog_id uuid not null references public.dogs (id) on delete restrict,
  client_id uuid not null references public.profiles (id) on delete restrict,
  trainer_id uuid not null references public.profiles (id) on delete restrict,
  status text not null default 'active' check (status in ('active', 'paused', 'ended')),
  title text not null check (char_length(trim(title)) > 0),
  current_focus text,
  created_at timestamptz not null default now()
);

create table public.entries (
  id uuid primary key default gen_random_uuid(),
  programme_id uuid not null references public.programmes (id) on delete cascade,
  author_id uuid not null references public.profiles (id) on delete restrict,
  kind text not null check (kind in ('focus', 'exercise', 'observation', 'feedback')),
  body text not null check (char_length(trim(body)) > 0),
  created_at timestamptz not null default now()
);

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  programme_id uuid not null references public.programmes (id) on delete cascade,
  starts_at timestamptz not null,
  location text,
  notes text,
  created_at timestamptz not null default now()
);

create index dogs_owner_id_idx on public.dogs (owner_id);
create index programmes_dog_id_idx on public.programmes (dog_id);
create index programmes_client_id_idx on public.programmes (client_id);
create index programmes_trainer_id_idx on public.programmes (trainer_id);
create index programmes_status_idx on public.programmes (status);
create index entries_programme_id_created_at_idx on public.entries (programme_id, created_at desc);
create index sessions_programme_id_starts_at_idx on public.sessions (programme_id, starts_at);

-- ---------------------------------------------------------------------------
-- Helpers (SECURITY DEFINER, bypass RLS, no recursion)
-- ---------------------------------------------------------------------------

create or replace function private.is_trainer()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'trainer'
  );
$$;

create or replace function private.is_client_profile(p_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.profiles
    where id = p_id
      and role = 'client'
  );
$$;

create or replace function private.can_access_programme(p_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.programmes
    where id = p_id
      and (trainer_id = auth.uid() or client_id = auth.uid())
  );
$$;

create or replace function private.shares_programme_with(p_other uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.programmes
    where (trainer_id = auth.uid() and client_id = p_other)
       or (client_id = auth.uid() and trainer_id = p_other)
  );
$$;

create or replace function private.can_select_dog(p_dog_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.dogs
    where id = p_dog_id
      and owner_id = auth.uid()
  )
  or exists (
    select 1
    from public.programmes
    where dog_id = p_dog_id
      and trainer_id = auth.uid()
  )
  or (
    private.is_trainer()
    and not exists (
      select 1
      from public.programmes
      where dog_id = p_dog_id
    )
  );
$$;

create or replace function private.is_dog_trainer(p_dog_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.programmes
    where dog_id = p_dog_id
      and trainer_id = auth.uid()
  );
$$;

create or replace function private.is_programme_trainer(p_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.programmes
    where id = p_id
      and trainer_id = auth.uid()
  );
$$;

create or replace function private.is_programme_client(p_id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.programmes
    where id = p_id
      and client_id = auth.uid()
  );
$$;

revoke all on function private.is_trainer() from public;
revoke all on function private.is_client_profile(uuid) from public;
revoke all on function private.can_access_programme(uuid) from public;
revoke all on function private.shares_programme_with(uuid) from public;
revoke all on function private.can_select_dog(uuid) from public;
revoke all on function private.is_dog_trainer(uuid) from public;
revoke all on function private.is_programme_trainer(uuid) from public;
revoke all on function private.is_programme_client(uuid) from public;

grant execute on function private.is_trainer() to authenticated;
grant execute on function private.is_client_profile(uuid) to authenticated;
grant execute on function private.can_access_programme(uuid) to authenticated;
grant execute on function private.shares_programme_with(uuid) to authenticated;
grant execute on function private.can_select_dog(uuid) to authenticated;
grant execute on function private.is_dog_trainer(uuid) to authenticated;
grant execute on function private.is_programme_trainer(uuid) to authenticated;
grant execute on function private.is_programme_client(uuid) to authenticated;

-- Names from AGENTS.md, thin wrappers.
create or replace function public.is_trainer()
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, private
as $$
  select private.is_trainer();
$$;

create or replace function public.can_access_programme(id uuid)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, private
as $$
  select private.can_access_programme(id);
$$;

revoke all on function public.is_trainer() from public;
revoke all on function public.can_access_programme(uuid) from public;
grant execute on function public.is_trainer() to authenticated;
grant execute on function public.can_access_programme(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  insert into public.profiles (id, role, display_name)
  values (
    new.id,
    'client',
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''),
      nullif(split_part(new.email, '@', 1), ''),
      'Bruger'
    )
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function private.handle_new_user();

create or replace function private.prevent_profile_role_change()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if new.role is distinct from old.role
     and current_setting('role', true) in ('authenticated', 'anon') then
    raise exception 'profiles.role cannot be changed by this role'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger profiles_role_immutable
  before update of role on public.profiles
  for each row
  execute function private.prevent_profile_role_change();

create or replace function private.prevent_dog_owner_change()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if new.owner_id is distinct from old.owner_id then
    raise exception 'dogs.owner_id cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger dogs_owner_immutable
  before update of owner_id on public.dogs
  for each row
  execute function private.prevent_dog_owner_change();

create or replace function private.enforce_programme_client_is_dog_owner()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_owner uuid;
begin
  select owner_id into v_owner
  from public.dogs
  where id = new.dog_id;

  if v_owner is null then
    raise exception 'dog not found'
      using errcode = '23503';
  end if;

  if new.client_id is distinct from v_owner then
    raise exception 'programmes.client_id must equal dogs.owner_id'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

create trigger programmes_client_matches_dog_owner
  before insert or update of dog_id, client_id on public.programmes
  for each row
  execute function private.enforce_programme_client_is_dog_owner();

create or replace function private.prevent_programme_membership_change()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if new.trainer_id is distinct from old.trainer_id
     or new.client_id is distinct from old.client_id
     or new.dog_id is distinct from old.dog_id then
    raise exception 'programme membership cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger programmes_membership_immutable
  before update of trainer_id, client_id, dog_id on public.programmes
  for each row
  execute function private.prevent_programme_membership_change();

create or replace function private.entries_force_author()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if auth.uid() is null then
    raise exception 'entries.author_id requires an authenticated user'
      using errcode = '42501';
  end if;
  new.author_id := auth.uid();
  return new;
end;
$$;

create trigger entries_set_author
  before insert on public.entries
  for each row
  execute function private.entries_force_author();

create or replace function private.prevent_entry_identity_change()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if new.author_id is distinct from old.author_id
     or new.programme_id is distinct from old.programme_id
     or new.kind is distinct from old.kind then
    raise exception 'entries author_id, programme_id and kind cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger entries_identity_immutable
  before update of author_id, programme_id, kind on public.entries
  for each row
  execute function private.prevent_entry_identity_change();

create or replace function private.prevent_session_programme_change()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if new.programme_id is distinct from old.programme_id then
    raise exception 'sessions.programme_id cannot be changed'
      using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger sessions_programme_immutable
  before update of programme_id on public.sessions
  for each row
  execute function private.prevent_session_programme_change();

-- ---------------------------------------------------------------------------
-- Privileges: no anon access; authenticated only gets needed columns
-- ---------------------------------------------------------------------------

revoke all on schema public from anon;
revoke all on all tables in schema public from anon, authenticated, public;

grant usage on schema public to authenticated;

grant select on table public.profiles to authenticated;
grant update (display_name) on table public.profiles to authenticated;

grant select, insert on table public.dogs to authenticated;
grant update (name, notes) on table public.dogs to authenticated;

grant select, insert on table public.programmes to authenticated;
grant update (status, title, current_focus) on table public.programmes to authenticated;

grant select, insert (programme_id, kind, body) on table public.entries to authenticated;
grant update (body) on table public.entries to authenticated;

grant select, insert on table public.sessions to authenticated;
grant update (starts_at, location, notes) on table public.sessions to authenticated;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.dogs enable row level security;
alter table public.programmes enable row level security;
alter table public.entries enable row level security;
alter table public.sessions enable row level security;

alter table public.profiles force row level security;
alter table public.dogs force row level security;
alter table public.programmes force row level security;
alter table public.entries force row level security;
alter table public.sessions force row level security;

create policy profiles_select
  on public.profiles
  for select
  to authenticated
  using (
    id = auth.uid()
    or private.shares_programme_with(id)
  );

create policy profiles_update_own_name
  on public.profiles
  for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- INSERT: trainer creating a dog for a client. No existing programme required.
create policy dogs_select
  on public.dogs
  for select
  to authenticated
  using (private.can_select_dog(id));

create policy dogs_insert
  on public.dogs
  for insert
  to authenticated
  with check (
    private.is_trainer()
    and private.is_client_profile(owner_id)
  );

create policy dogs_update
  on public.dogs
  for update
  to authenticated
  using (
    owner_id = auth.uid()
    or private.is_dog_trainer(id)
  )
  with check (
    owner_id = auth.uid()
    or private.is_dog_trainer(id)
  );

create policy programmes_select
  on public.programmes
  for select
  to authenticated
  using (private.can_access_programme(id));

create policy programmes_insert
  on public.programmes
  for insert
  to authenticated
  with check (
    private.is_trainer()
    and trainer_id = auth.uid()
    and private.is_client_profile(client_id)
  );

create policy programmes_update
  on public.programmes
  for update
  to authenticated
  using (private.is_programme_trainer(id))
  with check (private.is_programme_trainer(id));

create policy entries_select
  on public.entries
  for select
  to authenticated
  using (private.can_access_programme(programme_id));

create policy entries_insert
  on public.entries
  for insert
  to authenticated
  with check (
    (
      kind = 'observation'
      and private.is_programme_client(programme_id)
    )
    or (
      private.is_programme_trainer(programme_id)
    )
  );

create policy entries_update_own
  on public.entries
  for update
  to authenticated
  using (author_id = auth.uid())
  with check (author_id = auth.uid());

create policy sessions_select
  on public.sessions
  for select
  to authenticated
  using (private.can_access_programme(programme_id));

create policy sessions_insert
  on public.sessions
  for insert
  to authenticated
  with check (private.is_programme_trainer(programme_id));

create policy sessions_update
  on public.sessions
  for update
  to authenticated
  using (private.is_programme_trainer(programme_id))
  with check (private.is_programme_trainer(programme_id));

-- ---------------------------------------------------------------------------
-- Backfill profiles for Auth users created before this migration
-- ---------------------------------------------------------------------------

insert into public.profiles (id, role, display_name)
select
  u.id,
  'client',
  coalesce(
    nullif(trim(u.raw_user_meta_data ->> 'display_name'), ''),
    nullif(split_part(u.email, '@', 1), ''),
    'Bruger'
  )
from auth.users u
where not exists (
  select 1 from public.profiles p where p.id = u.id
);
