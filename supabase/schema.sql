
-- Cyber Prank Control 2.0
-- Supabase database schema

create extension if not exists pgcrypto;

create table if not exists public.scenarios (
    id uuid primary key default gen_random_uuid(),

    owner_id uuid references auth.users(id)
        on delete cascade,

    title text not null
        check (char_length(title) <= 100),

    scenario_data jsonb not null,

    is_active boolean not null default true,

    created_at timestamptz not null default now(),

    expires_at timestamptz,

    disabled_at timestamptz
);

create index if not exists scenarios_owner_idx
on public.scenarios(owner_id);

create index if not exists scenarios_active_idx
on public.scenarios(is_active);

alter table public.scenarios
enable row level security;

-- Владелец может просматривать свои сценарии.
create policy "Owners can view scenarios"
on public.scenarios
for select
to authenticated
using (auth.uid() = owner_id);

-- Авторизованный пользователь может создавать сценарии.
create policy "Owners can create scenarios"
on public.scenarios
for insert
to authenticated
with check (auth.uid() = owner_id);

-- Владелец может изменять свои сценарии.
create policy "Owners can update scenarios"
on public.scenarios
for update
to authenticated
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

-- Владелец может удалять свои сценарии.
create policy "Owners can delete scenarios"
on public.scenarios
for delete
to authenticated
using (auth.uid() = owner_id);

-- Публичный доступ к таблице не предоставляем.
revoke all on public.scenarios from anon;
revoke all on public.scenarios from authenticated;

grant select, insert, update, delete
on public.scenarios to authenticated;

grant usage on schema public to authenticated;
