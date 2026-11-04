-- Tabel data personal: resep tersimpan, catatan, dan rating.
-- Katalog resep tetap dari TheMealDB (API), bukan dari tabel ini.
create table if not exists public.saved_recipes (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid()
              references auth.users (id) on delete cascade,
  meal_id     text not null,
  meal_name   text not null,
  meal_thumb  text,
  note        text not null default '',
  rating      int check (rating between 1 and 5),
  created_at  timestamptz not null default now(),
  unique (user_id, meal_id)
);

-- Row Level Security: setiap pengguna hanya bisa mengakses barisnya sendiri.
alter table public.saved_recipes enable row level security;

create policy "saved_recipes_select_own"
  on public.saved_recipes for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "saved_recipes_insert_own"
  on public.saved_recipes for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "saved_recipes_update_own"
  on public.saved_recipes for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "saved_recipes_delete_own"
  on public.saved_recipes for delete
  to authenticated
  using ((select auth.uid()) = user_id);

grant usage on schema public to authenticated;

grant select, insert, update, delete
  on public.saved_recipes to authenticated;