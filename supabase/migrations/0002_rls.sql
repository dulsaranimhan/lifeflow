-- Row Level Security: every user can only see and change their own rows.

alter table public.profiles        enable row level security;
alter table public.tasks           enable row level security;
alter table public.events          enable row level security;
alter table public.recommendations enable row level security;

create policy "own rows" on public.profiles
  for all to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "own rows" on public.tasks
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own rows" on public.events
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own rows" on public.recommendations
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
