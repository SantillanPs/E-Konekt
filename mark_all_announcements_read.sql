-- Function to mark all announcements as read for a specific user
create or replace function mark_all_announcements_read(target_user_id uuid)
returns void as $$
begin
  insert into public.announcement_reads (user_id, announcement_id)
  select target_user_id, id
  from public.announcements
  on conflict (user_id, announcement_id) do nothing;
end;
$$ language plpgsql security definer;
