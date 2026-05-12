create extension if not exists pgcrypto;

create table if not exists apology_interactions (
  id uuid primary key default gen_random_uuid(),
  site_label text not null,
  visitor_id text not null,
  event_name text not null,
  event_detail text,
  page_url text,
  user_agent text,
  country text,
  region text,
  city text,
  created_at timestamptz not null default now()
);

-- If the table already exists from a previous run, add the new columns.
alter table apology_interactions add column if not exists country text;
alter table apology_interactions add column if not exists region text;
alter table apology_interactions add column if not exists city text;

alter table apology_interactions enable row level security;

drop policy if exists "Public can insert apology interactions" on apology_interactions;
create policy "Public can insert apology interactions"
  on apology_interactions
  for insert
  to anon, authenticated
  with check (true);

drop policy if exists "No public reads on apology interactions" on apology_interactions;
create policy "No public reads on apology interactions"
  on apology_interactions
  for select
  to anon, authenticated
  using (false);

create index if not exists apology_interactions_created_at_idx
  on apology_interactions (created_at desc);

create index if not exists apology_interactions_site_label_idx
  on apology_interactions (site_label, created_at desc);

-- ------------------------------------------------------------------
-- Passphrase-gated read access for the hidden admin page.
-- Set the passphrase ONCE by replacing 'CHANGE_ME' below and running it.
-- Anyone (with the anon key) can call this function, but they must pass
-- the correct passphrase to receive rows.
-- ------------------------------------------------------------------

create or replace function read_apology_interactions(p_passphrase text, p_site_label text default null, p_limit int default 200)
returns setof apology_interactions
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_passphrase is null or p_passphrase <> 'pooc1234' then
    raise exception 'unauthorised';
  end if;

  return query
    select *
    from apology_interactions
    where (p_site_label is null or site_label = p_site_label)
    order by created_at desc
    limit greatest(p_limit, 1);
end;
$$;

grant execute on function read_apology_interactions(text, text, int) to anon, authenticated;