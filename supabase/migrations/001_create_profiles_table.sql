-- Create a table for public user profiles
create table profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  stripe_customer_id text,
  subscription_status text,
  subscription_expires_at timestamp with time zone,
  subscription_price_id text,
  daily_conversions integer default 0,
  monthly_conversions integer default 0,
  last_conversion_date date,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Set up Row Level Security (RLS)
alter table profiles enable row level security;

-- Create policies
create policy "Public profiles are viewable by everyone." 
  on profiles for select 
  using (true);

create policy "Users can insert their own profile." 
  on profiles for insert 
  with check (auth.uid() = id);

create policy "Users can update own profile." 
  on profiles for update 
  using (auth.uid() = id);

-- Create function to handle new user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, updated_at)
  values (new.id, now());
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger to automatically create profile on signup
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Create indexes for better performance
create index profiles_stripe_customer_id_idx on profiles(stripe_customer_id);
create index profiles_subscription_status_idx on profiles(subscription_status);
create index profiles_subscription_expires_at_idx on profiles(subscription_expires_at);

-- Create function to update conversion counts
create or replace function public.increment_conversion_count(user_id uuid)
returns void as $$
declare
  today_date date := current_date;
  current_month date := date_trunc('month', current_date)::date;
begin
  -- Update daily and monthly conversion counts
  update profiles 
  set 
    daily_conversions = case 
      when last_conversion_date = today_date then daily_conversions + 1
      else 1
    end,
    monthly_conversions = case 
      when date_trunc('month', last_conversion_date)::date = current_month then monthly_conversions + 1
      else 1
    end,
    last_conversion_date = today_date,
    updated_at = now()
  where id = user_id;
end;
$$ language plpgsql security definer;

-- Create function to reset daily counts (to be called by a cron job)
create or replace function public.reset_daily_conversions()
returns void as $$
begin
  update profiles 
  set daily_conversions = 0
  where last_conversion_date < current_date;
end;
$$ language plpgsql security definer;
