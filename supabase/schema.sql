-- Jalankan seluruh isi file ini di Supabase Dashboard > SQL Editor.
-- Aman dijalankan ulang (idempotent).

-- =========================================================
-- Tabel profiles
-- =========================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique,
  email text not null,
  created_at timestamptz not null default now(),
  -- Hanya huruf kecil, angka, dan underscore (3-20 karakter).
  constraint profiles_username_format check (username ~ '^[a-z0-9_]{3,20}$')
);

-- =========================================================
-- Row Level Security
-- =========================================================
alter table public.profiles enable row level security;

grant select, insert on table public.profiles to authenticated;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles
  for select
  to authenticated
  using (id = (select auth.uid()));

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles
  for insert
  to authenticated
  with check (id = (select auth.uid()));

-- =========================================================
-- Fungsi: ambil email berdasarkan username (untuk login via username)
-- =========================================================
create or replace function public.get_email_by_username(p_username text)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select p.email
  from public.profiles p
  where p.username = lower(trim(p_username))
  limit 1;
$$;

-- =========================================================
-- Fungsi: cek ketersediaan username
-- =========================================================
create or replace function public.is_username_available(p_username text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select not exists (
    select 1
    from public.profiles p
    where p.username = lower(trim(p_username))
  );
$$;

-- =========================================================
-- Hak akses fungsi
-- =========================================================
revoke execute on function public.get_email_by_username(text) from public;
revoke execute on function public.is_username_available(text) from public;

grant execute on function public.get_email_by_username(text) to anon, authenticated;
grant execute on function public.is_username_available(text) to anon, authenticated;
