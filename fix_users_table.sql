-- Ensure phone_number column exists in public.users table
do $$
begin
  if not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'users' and column_name = 'phone_number') then
    alter table public.users add column phone_number text;
  end if;
end
$$;
