-- DEV ONLY: sample tasks and events so the Home screen can be tested before
-- the Tasks and Events screens exist. Do not run against production.
--
-- 1. Change the email below to an account you registered in the app.
-- 2. Run the whole script in the Supabase SQL Editor.
-- Running it again adds another copy of the sample rows.

do $$
declare
  demo_email text := 'you@example.com';  -- <-- change me
  uid uuid;
  today date := (now() at time zone 'Asia/Colombo')::date;
begin
  select id into uid from auth.users where email = demo_email;
  if uid is null then
    raise exception 'No user with email %. Register in the app first.', demo_email;
  end if;

  insert into public.tasks (user_id, title, deadline, priority, duration_min)
  values
    (uid, 'Finish SE lab report',
       (today + time '23:59') at time zone 'Asia/Colombo', 'high', 90),
    (uid, 'Read chapter 5 – Databases',
       (today + 1 + time '09:00') at time zone 'Asia/Colombo', 'medium', 45),
    (uid, 'Reply to project group',
       now() + interval '3 hours', 'low', 10),
    (uid, 'Prepare presentation slides',
       (today + 3 + time '17:00') at time zone 'Asia/Colombo', 'high', 120),
    (uid, 'Buy stationery', null, 'low', 20);

  insert into public.events
    (user_id, title, start_time, end_time, location_name, lat, lng,
     consider_travel, reminder_min)
  values
    (uid, 'Lecture – Mobile App Development',
       now() + interval '2 hours', now() + interval '4 hours',
       'Faculty of Science, University of Ruhuna', 5.9381, 80.5765, true, 15),
    (uid, 'Group meeting',
       now() + interval '6 hours', now() + interval '7 hours',
       'Library', null, null, false, 10);
end $$;
