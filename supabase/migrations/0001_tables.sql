-- LifeFlow core tables.
-- Run in the Supabase SQL editor (or with `supabase db push`) before 0002 and 0003.

create table if not exists public.profiles (
  id                uuid primary key references auth.users (id) on delete cascade,
  name              text not null default '',
  travel_buffer_min integer not null default 10 check (travel_buffer_min >= 0),
  reminder_lead_min integer not null default 15 check (reminder_lead_min >= 0),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create table if not exists public.tasks (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title        text not null check (char_length(title) > 0),
  deadline     timestamptz,
  priority     text not null default 'medium' check (priority in ('high', 'medium', 'low')),
  duration_min integer not null default 30 check (duration_min > 0),
  status       text not null default 'pending' check (status in ('pending', 'done')),
  reminder_on  boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create table if not exists public.events (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title           text not null check (char_length(title) > 0),
  start_time      timestamptz not null,
  end_time        timestamptz not null,
  location_name   text,
  lat             double precision check (lat between -90 and 90),
  lng             double precision check (lng between -180 and 180),
  consider_travel boolean not null default false,
  reminder_min    integer not null default 15 check (reminder_min >= 0),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint events_time_order check (end_time > start_time)
);

create table if not exists public.recommendations (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  task_id      uuid references public.tasks (id) on delete set null,
  window_start timestamptz not null,
  leave_time   timestamptz,
  reason       text not null default '',
  response     text check (response in ('start', 'postpone', 'done')),
  created_at   timestamptz not null default now()
);

create index if not exists tasks_user_deadline_idx on public.tasks (user_id, deadline);
create index if not exists events_user_start_idx on public.events (user_id, start_time);
create index if not exists recommendations_user_created_idx
  on public.recommendations (user_id, created_at desc);
