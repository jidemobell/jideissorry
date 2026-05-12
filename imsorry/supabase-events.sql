create extension if not exists pgcrypto;

create table if not exists apology_interactions (
  id uuid primary key default gen_random_uuid(),
  site_label text not null,
  visitor_id text not null,
  event_name text not null,
  event_detail text,
  page_url text,
  user_agent text,
  created_at timestamptz not null default now()
);

alter table apology_interactions enable row level security;

create policy "Public can insert apology interactions"
  on apology_interactions
  for insert
  to anon, authenticated
  with check (true);

create policy "No public reads on apology interactions"
  on apology_interactions
  for select
  to anon, authenticated
  using (false);

create index if not exists apology_interactions_created_at_idx
  on apology_interactions (created_at desc);

create index if not exists apology_interactions_site_label_idx
  on apology_interactions (site_label, created_at desc);