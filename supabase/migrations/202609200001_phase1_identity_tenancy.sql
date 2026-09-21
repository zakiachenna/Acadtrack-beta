-- AcadTrack Pilot
-- Phase 1 migration: Identity & tenancy

create type public.app_role as enum (
  'student',
  'teacher',
  'dept_admin',
  'platform_admin'
);
create table public.universities (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  country text,
  locale_default text,
  logo_url text,
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
); 
create table public.academic_years (
  id uuid primary key default gen_random_uuid(),
  university_id uuid not null references public.universities(id) on delete cascade,
  label text not null,
  starts_on date not null,
  ends_on date not null,
  is_current boolean not null default false
);
create table public.semesters (
  id uuid primary key default gen_random_uuid(),
  academic_year_id uuid not null references public.academic_years(id) on delete cascade,
  index smallint not null check (index in (1, 2)),
  starts_on date not null,
  ends_on date not null
);
create table public.departments (
  id uuid primary key default gen_random_uuid(),
  university_id uuid not null references public.universities(id) on delete cascade,
  name text not null,
  code text not null,
  head_user_id uuid references auth.users(id)
);
create table public.specialties (
  id uuid primary key default gen_random_uuid(),
  department_id uuid not null references public.departments(id) on delete cascade,
  name text not null,
  level text not null check (level in ('L1', 'L2', 'L3', 'M1', 'M2', 'PhD')),
  code text not null
);
create table public.groups (
  id uuid primary key default gen_random_uuid(),
  specialty_id uuid not null references public.specialties(id) on delete cascade,
  semester_id uuid not null references public.semesters(id) on delete cascade,
  name text not null,
  capacity integer check (capacity is null or capacity > 0)
);
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  university_id uuid not null references public.universities(id) on delete cascade,
  full_name text not null,
  email text not null,
  phone text,
  avatar_url text,
  locale text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  university_id uuid not null references public.universities(id) on delete cascade,
  role public.app_role not null,
  department_id uuid references public.departments(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, university_id, role, department_id)
);
create table public.students (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  student_number text not null,
  group_id uuid references public.groups(id) on delete set null,
  enrolled_at date,
  status text not null default 'active'
);
create table public.teachers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  employee_number text,
  department_id uuid references public.departments(id) on delete set null,
  title text,
  status text not null default 'active'
);
create or replace function public.has_role(_role public.app_role)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_roles
    where user_id = auth.uid()
      and role = _role
  );
$$;
revoke all on function public.has_role(public.app_role) from public;
grant execute on function public.has_role(public.app_role) to authenticated;
alter table public.universities enable row level security;
alter table public.academic_years enable row level security;
alter table public.semesters enable row level security;
alter table public.departments enable row level security;
alter table public.specialties enable row level security;
alter table public.groups enable row level security;
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.students enable row level security;
alter table public.teachers enable row level security;
