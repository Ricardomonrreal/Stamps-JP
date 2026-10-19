-- Ejecutar en Supabase > SQL Editor.

create table public.stamps (
  id bigint generated always as identity primary key,
  name text not null check (length(name) between 2 and 120),
  kind text not null default 'station' check (kind in ('station', 'place')),
  prefecture text not null default 'Osaka',
  city text not null default 'Osaka',
  -- caja aproximada de Japón: rechaza coordenadas fuera del país
  lat double precision not null check (lat between 20 and 46),
  lng double precision not null check (lng between 122 and 154),
  description text check (length(description) <= 500),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_by uuid default auth.uid() references auth.users on delete set null,
  created_at timestamptz not null default now()
);
create index on public.stamps (status, prefecture, city);

alter table public.stamps enable row level security;

-- Todos ven las aprobadas; cada usuario ve además sus propuestas.
create policy "read approved or own" on public.stamps for select
  using (status = 'approved' or created_by = auth.uid());

-- Usuarios con sesión proponen; siempre entra como pendiente.
-- Aprobar: update public.stamps set status = 'approved' where id = ...;
create policy "propose" on public.stamps for insert to authenticated
  with check (status = 'pending' and created_by = auth.uid());

create table public.collections (
  user_id uuid not null default auth.uid() references auth.users on delete cascade,
  stamp_id bigint not null references public.stamps on delete cascade,
  collected_at timestamptz not null default now(),
  primary key (user_id, stamp_id)
);

alter table public.collections enable row level security;

create policy "own collection" on public.collections for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Datos iniciales (coordenadas aproximadas, verificar ubicación exacta de cada estampa)
insert into public.stamps (name, kind, lat, lng, description, status, created_by) values
  ('JR Osaka', 'station', 34.7025, 135.4959, 'Estampa en la oficina de la estación JR', 'approved', null),
  ('JR Shin-Osaka', 'station', 34.7334, 135.5002, null, 'approved', null),
  ('JR Tennoji', 'station', 34.6466, 135.5133, null, 'approved', null),
  ('Nankai Namba', 'station', 34.6627, 135.5013, null, 'approved', null),
  ('Castillo de Osaka', 'place', 34.6873, 135.5262, 'Torre principal', 'approved', null),
  ('Tsutenkaku', 'place', 34.6525, 135.5063, null, 'approved', null);
