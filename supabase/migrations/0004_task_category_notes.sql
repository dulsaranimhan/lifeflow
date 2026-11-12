-- Category and notes for tasks, notes for events (Add Task / Add Event designs).

alter table public.tasks
  add column if not exists category text not null default 'personal'
    check (category in ('work', 'personal', 'health', 'learning')),
  add column if not exists notes text
    check (notes is null or char_length(notes) <= 500);

alter table public.events
  add column if not exists notes text
    check (notes is null or char_length(notes) <= 500);
