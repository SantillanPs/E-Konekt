-- ============================================
-- MOCK DATA FOR E-KONEKT APPLICATION
-- ============================================
-- This script creates realistic test data for all tables
-- Run this AFTER you have created at least one auth user
-- ============================================

-- ============================================
-- STEP 1: GET YOUR AUTH USER ID
-- ============================================
-- First, run this to get your auth user ID:
-- SELECT id, email FROM auth.users ORDER BY created_at DESC LIMIT 1;
-- Copy the UUID and replace 'YOUR-AUTH-USER-ID' below

-- ============================================
-- STEP 2: CREATE MOCK USERS
-- ============================================
-- Note: These users need corresponding auth.users entries
-- For testing, we'll use your existing auth user and create profiles for others

-- Insert your main user (replace with your actual auth user ID)
INSERT INTO public.users (id, email, name, role, barangay, city, barangay_admin, created_at, updated_at)
VALUES 
  -- Replace this UUID with your actual auth user ID
  ('YOUR-AUTH-USER-ID', 'your-email@example.com', 'Your Name', 'user', 'Barangay 1', 'Quezon City', false, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  role = EXCLUDED.role,
  barangay = EXCLUDED.barangay,
  city = EXCLUDED.city,
  updated_at = NOW();

-- ============================================
-- STEP 3: CREATE MOCK BUSINESSES
-- ============================================
-- These will be owned by your user
INSERT INTO public.businesses (owner_id, name, description, address, contact_info, logo_url, created_at, updated_at)
VALUES 
  ('YOUR-AUTH-USER-ID', 'Sari-Sari Store ni Aling Nena', 'Local convenience store selling everyday essentials', '123 Main St, Barangay 1, Quezon City', '0917-123-4567', 'https://via.placeholder.com/150', NOW(), NOW()),
  ('YOUR-AUTH-USER-ID', 'Mang Tomas Carinderia', 'Affordable Filipino home-cooked meals', '456 Market Ave, Barangay 1, Quezon City', '0918-234-5678', 'https://via.placeholder.com/150', NOW(), NOW()),
  ('YOUR-AUTH-USER-ID', 'QuickFix Repair Shop', 'Electronics and appliance repair services', '789 Tech St, Barangay 2, Quezon City', '0919-345-6789', 'https://via.placeholder.com/150', NOW(), NOW());

-- ============================================
-- STEP 4: CREATE MOCK PRODUCTS
-- ============================================
-- Mix of individual and business products

-- Individual products (no business_id)
INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
VALUES 
  ('YOUR-AUTH-USER-ID', NULL, 'individual', 'Used Laptop - Dell Inspiron', 'Gently used laptop, 8GB RAM, 256GB SSD, good condition', 15000.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Electronics', 'Your Name', NOW(), NOW()),
  ('YOUR-AUTH-USER-ID', NULL, 'individual', 'Mountain Bike', 'Second-hand mountain bike, well-maintained', 8000.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Sports', 'Your Name', NOW(), NOW()),
  ('YOUR-AUTH-USER-ID', NULL, 'individual', 'Study Table', 'Wooden study table with drawer, like new', 2500.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Furniture', 'Your Name', NOW(), NOW());

-- Business products (with business_id)
-- Note: Replace business_id with actual IDs after businesses are created
-- You can get business IDs with: SELECT id, name FROM public.businesses;

INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
SELECT 
  'YOUR-AUTH-USER-ID',
  b.id,
  'business',
  'Rice - 25kg Sack',
  'Premium quality rice, locally sourced',
  1200.00,
  50,
  'https://via.placeholder.com/300',
  'Barangay 1, Quezon City',
  'Food',
  'Your Name',
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'Sari-Sari Store ni Aling Nena' LIMIT 1;

INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
SELECT 
  'YOUR-AUTH-USER-ID',
  b.id,
  'business',
  'Cooking Oil - 1L',
  'Vegetable cooking oil',
  150.00,
  100,
  'https://via.placeholder.com/300',
  'Barangay 1, Quezon City',
  'Food',
  'Your Name',
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'Sari-Sari Store ni Aling Nena' LIMIT 1;

INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
SELECT 
  'YOUR-AUTH-USER-ID',
  b.id,
  'business',
  'Adobo Meal',
  'Chicken adobo with rice and side dish',
  80.00,
  30,
  'https://via.placeholder.com/300',
  'Barangay 1, Quezon City',
  'Food',
  'Your Name',
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'Mang Tomas Carinderia' LIMIT 1;

INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
SELECT 
  'YOUR-AUTH-USER-ID',
  b.id,
  'business',
  'Phone Screen Repair',
  'Professional phone screen replacement service',
  800.00,
  999,
  'https://via.placeholder.com/300',
  'Barangay 2, Quezon City',
  'Services',
  'Your Name',
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'QuickFix Repair Shop' LIMIT 1;

-- ============================================
-- STEP 5: CREATE MOCK JOBS
-- ============================================
-- Jobs are posted by businesses

INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
SELECT 
  b.id,
  'Store Clerk',
  'Looking for a friendly and reliable store clerk. Responsibilities include customer service, inventory management, and cashier duties.',
  12000.00,
  'Retail',
  'Barangay 1, Quezon City',
  b.name,
  'open',
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'Sari-Sari Store ni Aling Nena' LIMIT 1;

INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
SELECT 
  b.id,
  'Cook/Kitchen Helper',
  'Experienced cook needed for carinderia. Must know Filipino dishes. Flexible hours.',
  15000.00,
  'Food Service',
  'Barangay 1, Quezon City',
  b.name,
  'open',
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'Mang Tomas Carinderia' LIMIT 1;

INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
SELECT 
  b.id,
  'Electronics Technician',
  'Seeking skilled technician for phone and laptop repairs. Experience with soldering and diagnostics required.',
  18000.00,
  'Technical',
  'Barangay 2, Quezon City',
  b.name,
  'open',
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'QuickFix Repair Shop' LIMIT 1;

INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
SELECT 
  b.id,
  'Delivery Rider',
  'Part-time delivery rider for food orders. Must have own motorcycle. Flexible schedule.',
  500.00,
  'Delivery',
  'Barangay 1, Quezon City',
  b.name,
  'open',
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'Mang Tomas Carinderia' LIMIT 1;

-- ============================================
-- STEP 6: CREATE MOCK ANNOUNCEMENTS
-- ============================================

INSERT INTO public.announcements (posted_by, title, content, type, location, location_id, created_at, updated_at)
VALUES 
  ('YOUR-AUTH-USER-ID', 'Community Clean-Up Drive', 'Join us this Saturday for our monthly barangay clean-up! Meet at the barangay hall at 7 AM. Bring gloves and garbage bags.', 'barangay', 'barangay', NULL, NOW(), NOW()),
  ('YOUR-AUTH-USER-ID', 'Basketball Tournament', 'Annual inter-barangay basketball tournament registration is now open! Sign up at the barangay hall. Tournament starts next month.', 'barangay', 'barangay', NULL, NOW(), NOW()),
  ('YOUR-AUTH-USER-ID', 'Free Medical Check-up', 'Free medical and dental check-up this Friday at the barangay health center. First come, first served. Bring your health card.', 'barangay', 'barangay', NULL, NOW(), NOW());

-- Business announcements
INSERT INTO public.announcements (posted_by, title, content, type, location, location_id, created_at, updated_at)
SELECT 
  'YOUR-AUTH-USER-ID',
  'Grand Opening Sale!',
  'Celebrate our store anniversary with 20% off on all items! Valid this week only. Thank you for your continued support!',
  'business',
  'business',
  b.id::text::uuid,
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'Sari-Sari Store ni Aling Nena' LIMIT 1;

INSERT INTO public.announcements (posted_by, title, content, type, location, location_id, created_at, updated_at)
SELECT 
  'YOUR-AUTH-USER-ID',
  'New Menu Items!',
  'Try our new dishes: Kare-kare and Lechon Kawali! Available starting today. Come and taste the goodness!',
  'business',
  'business',
  b.id::text::uuid,
  NOW(),
  NOW()
FROM public.businesses b WHERE b.name = 'Mang Tomas Carinderia' LIMIT 1;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify data was created successfully:

-- Check businesses
-- SELECT id, name, owner_id FROM public.businesses;

-- Check products
-- SELECT id, name, seller_type, business_id FROM public.products;

-- Check jobs
-- SELECT id, title, business_name, status FROM public.jobs;

-- Check announcements
-- SELECT id, title, type FROM public.announcements;

-- ============================================
-- CLEANUP (if needed)
-- ============================================
-- To remove all mock data:
-- DELETE FROM public.applications;
-- DELETE FROM public.jobs;
-- DELETE FROM public.products;
-- DELETE FROM public.announcements;
-- DELETE FROM public.businesses;
-- ============================================
