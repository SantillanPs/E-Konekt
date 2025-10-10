-- E-Konekt Mock Data
-- Quick database population for testing
-- Run this in Supabase SQL Editor after running database migrations

-- ============================================
-- IMPORTANT: USER SETUP
-- ============================================
-- The users table has a foreign key to auth.users
-- You have 2 options:

-- OPTION 1 (RECOMMENDED): Use your existing auth users
-- Replace the UUIDs below with actual user IDs from your auth.users table
-- Run this query first to see your existing users:
-- SELECT id, email FROM auth.users;

-- OPTION 2: Create mock auth users (requires admin privileges)
-- Uncomment the section below to create auth users first

/*
-- Create mock auth users (ADMIN ONLY - requires service_role key)
INSERT INTO auth.users (
  id, 
  instance_id, 
  email, 
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role
)
VALUES
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'juan@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'maria@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('33333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'pedro@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('44444444-4444-4444-4444-444444444444', '00000000-0000-0000-0000-000000000000', 'ana@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('55555555-5555-5555-5555-555555555555', '00000000-0000-0000-0000-000000000000', 'roberto@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('66666666-6666-6666-6666-666666666666', '00000000-0000-0000-0000-000000000000', 'linda@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('77777777-7777-7777-7777-777777777777', '00000000-0000-0000-0000-000000000000', 'carlos@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated'),
  ('88888888-8888-8888-8888-888888888888', '00000000-0000-0000-0000-000000000000', 'captain@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, 'authenticated')
ON CONFLICT (id) DO NOTHING;
*/

-- OPTION 3 (EASIEST): Use existing logged-in user for all mock data
-- This creates all data under your current user account
-- Uncomment the DO block below and comment out the specific user inserts

/*
DO $$
DECLARE
  current_user_id UUID;
BEGIN
  -- Get the first user from auth.users (or use auth.uid() if running as authenticated user)
  SELECT id INTO current_user_id FROM auth.users LIMIT 1;
  
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'No users found in auth.users. Please create a user first via the app.';
  END IF;
  
  RAISE NOTICE 'Using user ID: %', current_user_id;
  
  -- All mock data will use this user ID
  -- You can modify the script below to use current_user_id variable
END $$;
*/

-- ============================================
-- 1. MOCK USERS
-- ============================================

-- Regular Users
INSERT INTO public.users (id, name, email, role, barangay, city, barangay_admin, created_at, updated_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'Juan Dela Cruz', 'juan@example.com', 'user', 'Barangay 1', 'Quezon City', false, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', 'Maria Santos', 'maria@example.com', 'user', 'Barangay 2', 'Quezon City', false, NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333333', 'Pedro Reyes', 'pedro@example.com', 'user', 'Barangay 1', 'Manila', false, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444444', 'Ana Garcia', 'ana@example.com', 'user', 'Barangay 3', 'Quezon City', false, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Business Owners
INSERT INTO public.users (id, name, email, role, barangay, city, barangay_admin, created_at, updated_at)
VALUES
  ('55555555-5555-5555-5555-555555555555', 'Roberto Tan', 'roberto@example.com', 'business_owner', 'Barangay 1', 'Quezon City', false, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666666', 'Linda Cruz', 'linda@example.com', 'business_owner', 'Barangay 2', 'Manila', false, NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777777', 'Carlos Mendoza', 'carlos@example.com', 'business_owner', 'Barangay 1', 'Quezon City', false, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Barangay Admin
INSERT INTO public.users (id, name, email, role, barangay, city, barangay_admin, created_at, updated_at)
VALUES
  ('88888888-8888-8888-8888-888888888888', 'Captain Jose Rizal', 'captain@example.com', 'barangay_admin', 'Barangay 1', 'Quezon City', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. MOCK BUSINESSES
-- ============================================

INSERT INTO public.businesses (owner_id, name, description, address, contact_info, logo_url, created_at, updated_at)
VALUES
  ('55555555-5555-5555-5555-555555555555', 'Tan Sari-Sari Store', 'Your neighborhood convenience store with everything you need', '123 Main St, Barangay 1, Quezon City', '0917-123-4567', 'https://via.placeholder.com/150', NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666666', 'Linda''s Bakery', 'Fresh bread and pastries daily', '456 Bakery Ave, Barangay 2, Manila', '0918-234-5678', 'https://via.placeholder.com/150', NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777777', 'Mendoza Auto Repair', 'Professional car repair and maintenance services', '789 Mechanic St, Barangay 1, Quezon City', '0919-345-6789', 'https://via.placeholder.com/150', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. MOCK PRODUCTS (Individual Sellers)
-- ============================================

INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
VALUES
  -- Juan's individual products
  ('11111111-1111-1111-1111-111111111111', NULL, 'individual', 'Used Bicycle', 'Mountain bike in good condition, barely used', 5000.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Sports & Outdoors', 'Juan Dela Cruz', NOW(), NOW()),
  ('11111111-1111-1111-1111-111111111111', NULL, 'individual', 'Gaming Console', 'PS4 with 5 games included', 12000.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Electronics', 'Juan Dela Cruz', NOW(), NOW()),
  
  -- Maria's individual products
  ('22222222-2222-2222-2222-222222222222', NULL, 'individual', 'Handmade Bags', 'Beautiful handcrafted bags, various colors', 800.00, 10, 'https://via.placeholder.com/300', 'Barangay 2, Quezon City', 'Fashion', 'Maria Santos', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', NULL, 'individual', 'Study Table', 'Wooden study table with drawer', 2500.00, 1, 'https://via.placeholder.com/300', 'Barangay 2, Quezon City', 'Furniture', 'Maria Santos', NOW(), NOW()),
  
  -- Pedro's individual products
  ('33333333-3333-3333-3333-333333333333', NULL, 'individual', 'Electric Fan', 'Standing fan, 3-speed settings', 1200.00, 2, 'https://via.placeholder.com/300', 'Barangay 1, Manila', 'Home Appliances', 'Pedro Reyes', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333333', NULL, 'individual', 'Books Collection', 'Set of 20 novels, various genres', 1500.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Manila', 'Books', 'Pedro Reyes', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 4. MOCK PRODUCTS (Business Sellers)
-- ============================================

-- Get business IDs first (assuming sequential IDs 1, 2, 3)
INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
VALUES
  -- Tan Sari-Sari Store products
  ('55555555-5555-5555-5555-555555555555', 1, 'business', 'Rice 25kg', 'Premium quality rice, 25kg sack', 1200.00, 50, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Food & Groceries', 'Tan Sari-Sari Store', NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555555', 1, 'business', 'Cooking Oil 1L', 'Pure vegetable cooking oil', 150.00, 100, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Food & Groceries', 'Tan Sari-Sari Store', NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555555', 1, 'business', 'Instant Noodles', 'Assorted flavors, pack of 10', 200.00, 200, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Food & Groceries', 'Tan Sari-Sari Store', NOW(), NOW()),
  
  -- Linda's Bakery products
  ('66666666-6666-6666-6666-666666666666', 2, 'business', 'Pandesal (10pcs)', 'Fresh pandesal, baked daily', 30.00, 500, 'https://via.placeholder.com/300', 'Barangay 2, Manila', 'Food & Groceries', 'Linda''s Bakery', NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666666', 2, 'business', 'Chocolate Cake', 'Delicious chocolate cake, 8-inch', 450.00, 20, 'https://via.placeholder.com/300', 'Barangay 2, Manila', 'Food & Groceries', 'Linda''s Bakery', NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666666', 2, 'business', 'Ensaymada (6pcs)', 'Buttery ensaymada with cheese', 120.00, 100, 'https://via.placeholder.com/300', 'Barangay 2, Manila', 'Food & Groceries', 'Linda''s Bakery', NOW(), NOW()),
  
  -- Mendoza Auto Repair products (spare parts)
  ('77777777-7777-7777-7777-777777777777', 3, 'business', 'Car Battery', 'Universal car battery, 12V', 3500.00, 15, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Automotive', 'Mendoza Auto Repair', NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777777', 3, 'business', 'Engine Oil', 'Synthetic engine oil, 4L', 1200.00, 30, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Automotive', 'Mendoza Auto Repair', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 5. MOCK JOBS
-- ============================================

INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
VALUES
  -- Tan Sari-Sari Store jobs
  (1, 'Store Clerk', 'Looking for a friendly and reliable store clerk. Must be available 8am-5pm, Monday to Saturday.', 15000.00, 'Retail', 'Barangay 1, Quezon City', 'Tan Sari-Sari Store', 'open', NOW(), NOW()),
  (1, 'Delivery Driver', 'Need a driver with motorcycle for product deliveries. Must have valid license.', 18000.00, 'Logistics', 'Barangay 1, Quezon City', 'Tan Sari-Sari Store', 'open', NOW(), NOW()),
  
  -- Linda's Bakery jobs
  (2, 'Baker Assistant', 'Assist head baker in daily operations. Early morning shift (3am-11am). Experience preferred.', 16000.00, 'Food Service', 'Barangay 2, Manila', 'Linda''s Bakery', 'open', NOW(), NOW()),
  (2, 'Cashier', 'Handle customer transactions and maintain cleanliness. Friendly personality required.', 14000.00, 'Retail', 'Barangay 2, Manila', 'Linda''s Bakery', 'open', NOW(), NOW()),
  
  -- Mendoza Auto Repair jobs
  (3, 'Automotive Mechanic', 'Experienced mechanic needed. Must know car diagnostics and repairs. 2+ years experience.', 25000.00, 'Automotive', 'Barangay 1, Quezon City', 'Mendoza Auto Repair', 'open', NOW(), NOW()),
  (3, 'Service Advisor', 'Customer-facing role. Explain repairs to customers and manage appointments.', 20000.00, 'Customer Service', 'Barangay 1, Quezon City', 'Mendoza Auto Repair', 'filled', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 6. MOCK JOB APPLICATIONS
-- ============================================

INSERT INTO public.applications (job_id, user_id, user_name, user_email, status, cover_letter, applied_at)
VALUES
  -- Applications for Store Clerk position
  (1, '11111111-1111-1111-1111-111111111111', 'Juan Dela Cruz', 'juan@example.com', 'pending', 'I am very interested in this position. I have 2 years of retail experience.', NOW()),
  (1, '22222222-2222-2222-2222-222222222222', 'Maria Santos', 'maria@example.com', 'pending', 'I am a hardworking person and would love to work at your store.', NOW()),
  
  -- Applications for Baker Assistant
  (3, '33333333-3333-3333-3333-333333333333', 'Pedro Reyes', 'pedro@example.com', 'accepted', 'I have experience working in a bakery and I love baking!', NOW()),
  (3, '44444444-4444-4444-4444-444444444444', 'Ana Garcia', 'ana@example.com', 'rejected', 'I am willing to learn and work early morning shifts.', NOW()),
  
  -- Application for Automotive Mechanic
  (5, '11111111-1111-1111-1111-111111111111', 'Juan Dela Cruz', 'juan@example.com', 'pending', 'I have 3 years of experience as a mechanic. I can start immediately.', NOW()),
  
  -- Application for Service Advisor (filled position)
  (6, '22222222-2222-2222-2222-222222222222', 'Maria Santos', 'maria@example.com', 'accepted', 'I have excellent communication skills and customer service experience.', NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 7. MOCK ANNOUNCEMENTS
-- ============================================

INSERT INTO public.announcements (posted_by, title, content, type, location, location_id, created_at, updated_at)
VALUES
  -- Barangay announcements
  ('88888888-8888-8888-8888-888888888888', 'Community Clean-up Drive', 'Join us this Saturday, 7am at the barangay hall for our monthly clean-up drive. Snacks will be provided!', 'barangay', 'barangay', NULL, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888888', 'Basketball Tournament', 'Annual barangay basketball tournament starts next week. Register your team at the barangay office.', 'barangay', 'barangay', NULL, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888888', 'Vaccination Schedule', 'Free COVID-19 booster shots available at the health center. Monday to Friday, 9am-3pm.', 'barangay', 'barangay', NULL, NOW(), NOW()),
  
  -- Business announcements
  ('55555555-5555-5555-5555-555555555555', 'Grand Sale!', 'All items 20% off this weekend! Visit Tan Sari-Sari Store for great deals.', 'business', 'business', 1, NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666666', 'New Menu Items', 'Try our new ube pandesal and cheese bread! Available starting tomorrow.', 'business', 'business', 2, NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777777', 'Free Check-up Promo', 'Free basic car check-up for first-time customers. Book your appointment now!', 'business', 'business', 3, NOW(), NOW()),
  
  -- City announcements
  ('88888888-8888-8888-8888-888888888888', 'Traffic Advisory', 'Road construction on Main Avenue. Expect delays. Use alternate routes.', 'city', 'city', NULL, NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888888', 'City-wide Festival', 'Annual city festival next month! Food stalls, concerts, and activities for the whole family.', 'city', 'city', NULL, NOW(), NOW()),
  
  -- Personal announcements
  ('11111111-1111-1111-1111-111111111111', 'Lost Pet', 'Lost: Brown dog, answers to "Brownie". Last seen near the park. Please contact if found.', 'barangay', 'barangay', NULL, NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', 'Garage Sale', 'Moving out sale! Furniture, appliances, and household items. Saturday 8am-5pm.', 'barangay', 'barangay', NULL, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check inserted data
-- SELECT COUNT(*) as total_users FROM public.users;
-- SELECT COUNT(*) as total_businesses FROM public.businesses;
-- SELECT COUNT(*) as total_products FROM public.products;
-- SELECT COUNT(*) as total_jobs FROM public.jobs;
-- SELECT COUNT(*) as total_applications FROM public.applications;
-- SELECT COUNT(*) as total_announcements FROM public.announcements;

-- View products by seller type
-- SELECT seller_type, COUNT(*) FROM public.products GROUP BY seller_type;

-- View job application status
-- SELECT status, COUNT(*) FROM public.applications GROUP BY status;

-- View announcement types
-- SELECT type, COUNT(*) FROM public.announcements GROUP BY type;
