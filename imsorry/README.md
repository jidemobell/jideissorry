# Apology Room

This is a static site with optional Supabase logging for live interaction checks.

## Make the live checker work

1. Create a Supabase project.
2. Run the SQL in [supabase-events.sql](./supabase-events.sql) in the Supabase SQL editor.
3. Open [supabase-config.js](./supabase-config.js) and set:
   - `url` to your Supabase project URL
   - `anonKey` to your Supabase anon key
   - `siteLabel` to any label you want for this deployed site
4. Deploy the folder.

## How to check interactions when the site is live

Open your Supabase dashboard and inspect the `apology_interactions` table.

Useful query in the SQL editor:

```sql
select created_at, site_label, visitor_id, event_name, event_detail, page_url
from apology_interactions
order by created_at desc;
```

To filter one site:

```sql
select created_at, visitor_id, event_name, event_detail
from apology_interactions
where site_label = 'apology-room'
order by created_at desc;
```