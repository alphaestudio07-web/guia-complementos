-- Ejecuta esto en Supabase: panel del proyecto -> SQL Editor -> New query -> pega y "Run"

-- 1) Tabla principal
create table if not exists items (
  id uuid primary key default gen_random_uuid(),
  title text not null default '',
  description text default '',
  final_url text,
  final_path text,
  guide_url text,
  guide_path text,
  extras jsonb not null default '[]'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table items enable row level security;

-- Lectura: cualquiera (incluida gente sin cuenta) puede ver los elementos
create policy "items_public_read"
  on items for select
  to anon, authenticated
  using (true);

-- Escritura: solo usuarios autenticados (tu cuenta de editor)
create policy "items_authenticated_write"
  on items for all
  to authenticated
  using (true)
  with check (true);

-- 2) Bucket de Storage para las fotos
insert into storage.buckets (id, name, public)
values ('fotos', 'fotos', true)
on conflict (id) do nothing;

-- Lectura pública de las fotos
create policy "fotos_public_read"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'fotos');

-- Solo usuarios autenticados pueden subir/editar/borrar fotos
create policy "fotos_authenticated_write"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'fotos');

create policy "fotos_authenticated_update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'fotos');

create policy "fotos_authenticated_delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'fotos');
