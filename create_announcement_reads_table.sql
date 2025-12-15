-- Create table to track read announcements
create table public.announcement_reads (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  announcement_id uuid references public.announcements(id) on delete cascade not null,
  read_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, announcement_id)
);

-- Enable RLS
alter table public.announcement_reads enable row level security;

-- Policies
create policy "Users can insert their own reads"
  on public.announcement_reads for insert
  with check (auth.uid() = user_id);

create policy "Users can view their own reads"
  on public.announcement_reads for select
  using (auth.uid() = user_id);
