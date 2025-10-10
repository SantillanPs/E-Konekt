-- E-Konekt Mock Data - SIMPLE VERSION
-- Uses your existing auth user to create all mock data
-- This avoids the foreign key constraint issue

-- ============================================
-- STEP 1: Find your user ID
-- ============================================
-- Run this first to get your user ID:
-- SELECT id, email FROM auth.users;
-- Then replace 'YOUR_USER_ID_HERE' below with your actual UUID

-- ============================================
-- QUICK SETUP: Replace this with your actual user ID
-- ============================================
-- Example: 'b5a01d65-8dce-42c4-b315-727e6172dded'

DO $$
DECLARE
  my_user_id UUID := 'YOUR_USER_ID_HERE'; -- REPLACE THIS!
  business1_id BIGINT;
  business2_id BIGINT;
  business3_id BIGINT;
  job1_id BIGINT;
  job2_id BIGINT;
  job3_id BIGINT;
BEGIN
  -- Check if user exists
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = my_user_id) THEN
    RAISE EXCEPTION 'User ID % not found in auth.users. Please update my_user_id variable.', my_user_id;
  END IF;

  RAISE NOTICE 'Creating mock data for user: %', my_user_id;

  -- ============================================
  -- 1. CREATE BUSINESSES
  -- ============================================
  
  INSERT INTO public.businesses (owner_id, name, description, address, contact_info, logo_url, created_at, updated_at)
  VALUES
    (my_user_id, 'Tan Sari-Sari Store', 'Your neighborhood convenience store with everything you need', '123 Main St, Barangay 1, Quezon City', '0917-123-4567', 'https://via.placeholder.com/150', NOW(), NOW())
  RETURNING id INTO business1_id;
  
  INSERT INTO public.businesses (owner_id, name, description, address, contact_info, logo_url, created_at, updated_at)
  VALUES
    (my_user_id, 'Linda''s Bakery', 'Fresh bread and pastries daily', '456 Bakery Ave, Barangay 2, Manila', '0918-234-5678', 'https://via.placeholder.com/150', NOW(), NOW())
  RETURNING id INTO business2_id;
  
  INSERT INTO public.businesses (owner_id, name, description, address, contact_info, logo_url, created_at, updated_at)
  VALUES
    (my_user_id, 'Mendoza Auto Repair', 'Professional car repair and maintenance services', '789 Mechanic St, Barangay 1, Quezon City', '0919-345-6789', 'https://via.placeholder.com/150', NOW(), NOW())
  RETURNING id INTO business3_id;

  RAISE NOTICE 'Created 3 businesses: %, %, %', business1_id, business2_id, business3_id;

  -- ============================================
  -- 2. CREATE INDIVIDUAL PRODUCTS
  -- ============================================
  
  INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
  VALUES
    (my_user_id, NULL, 'individual', 'Used Bicycle', 'Mountain bike in good condition, barely used', 5000.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Sports & Outdoors', 'Me', NOW(), NOW()),
    (my_user_id, NULL, 'individual', 'Gaming Console', 'PS4 with 5 games included', 12000.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Electronics', 'Me', NOW(), NOW()),
    (my_user_id, NULL, 'individual', 'Handmade Bags', 'Beautiful handcrafted bags, various colors', 800.00, 10, 'https://via.placeholder.com/300', 'Barangay 2, Quezon City', 'Fashion', 'Me', NOW(), NOW()),
    (my_user_id, NULL, 'individual', 'Study Table', 'Wooden study table with drawer', 2500.00, 1, 'https://via.placeholder.com/300', 'Barangay 2, Quezon City', 'Furniture', 'Me', NOW(), NOW()),
    (my_user_id, NULL, 'individual', 'Electric Fan', 'Standing fan, 3-speed settings', 1200.00, 2, 'https://via.placeholder.com/300', 'Barangay 1, Manila', 'Home Appliances', 'Me', NOW(), NOW()),
    (my_user_id, NULL, 'individual', 'Books Collection', 'Set of 20 novels, various genres', 1500.00, 1, 'https://via.placeholder.com/300', 'Barangay 1, Manila', 'Books', 'Me', NOW(), NOW());

  RAISE NOTICE 'Created 6 individual products';

  -- ============================================
  -- 3. CREATE BUSINESS PRODUCTS
  -- ============================================
  
  -- Tan Sari-Sari Store products
  INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
  VALUES
    (my_user_id, business1_id, 'business', 'Rice 25kg', 'Premium quality rice, 25kg sack', 1200.00, 50, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Food & Groceries', 'Tan Sari-Sari Store', NOW(), NOW()),
    (my_user_id, business1_id, 'business', 'Cooking Oil 1L', 'Pure vegetable cooking oil', 150.00, 100, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Food & Groceries', 'Tan Sari-Sari Store', NOW(), NOW()),
    (my_user_id, business1_id, 'business', 'Instant Noodles', 'Assorted flavors, pack of 10', 200.00, 200, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Food & Groceries', 'Tan Sari-Sari Store', NOW(), NOW());
  
  -- Linda's Bakery products
  INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
  VALUES
    (my_user_id, business2_id, 'business', 'Pandesal (10pcs)', 'Fresh pandesal, baked daily', 30.00, 500, 'https://via.placeholder.com/300', 'Barangay 2, Manila', 'Food & Groceries', 'Linda''s Bakery', NOW(), NOW()),
    (my_user_id, business2_id, 'business', 'Chocolate Cake', 'Delicious chocolate cake, 8-inch', 450.00, 20, 'https://via.placeholder.com/300', 'Barangay 2, Manila', 'Food & Groceries', 'Linda''s Bakery', NOW(), NOW()),
    (my_user_id, business2_id, 'business', 'Ensaymada (6pcs)', 'Buttery ensaymada with cheese', 120.00, 100, 'https://via.placeholder.com/300', 'Barangay 2, Manila', 'Food & Groceries', 'Linda''s Bakery', NOW(), NOW());
  
  -- Mendoza Auto Repair products
  INSERT INTO public.products (owner_id, business_id, seller_type, name, description, price, stock, image_url, location, category, owner_name, created_at, updated_at)
  VALUES
    (my_user_id, business3_id, 'business', 'Car Battery', 'Universal car battery, 12V', 3500.00, 15, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Automotive', 'Mendoza Auto Repair', NOW(), NOW()),
    (my_user_id, business3_id, 'business', 'Engine Oil', 'Synthetic engine oil, 4L', 1200.00, 30, 'https://via.placeholder.com/300', 'Barangay 1, Quezon City', 'Automotive', 'Mendoza Auto Repair', NOW(), NOW());

  RAISE NOTICE 'Created 14 business products';

  -- ============================================
  -- 4. CREATE JOBS
  -- ============================================
  
  INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
  VALUES
    (business1_id, 'Store Clerk', 'Looking for a friendly and reliable store clerk. Must be available 8am-5pm, Monday to Saturday.', 15000.00, 'Retail', 'Barangay 1, Quezon City', 'Tan Sari-Sari Store', 'open', NOW(), NOW())
  RETURNING id INTO job1_id;
  
  INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
  VALUES
    (business1_id, 'Delivery Driver', 'Need a driver with motorcycle for product deliveries. Must have valid license.', 18000.00, 'Logistics', 'Barangay 1, Quezon City', 'Tan Sari-Sari Store', 'open', NOW(), NOW());
  
  INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
  VALUES
    (business2_id, 'Baker Assistant', 'Assist head baker in daily operations. Early morning shift (3am-11am). Experience preferred.', 16000.00, 'Food Service', 'Barangay 2, Manila', 'Linda''s Bakery', 'open', NOW(), NOW())
  RETURNING id INTO job2_id;
  
  INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
  VALUES
    (business2_id, 'Cashier', 'Handle customer transactions and maintain cleanliness. Friendly personality required.', 14000.00, 'Retail', 'Barangay 2, Manila', 'Linda''s Bakery', 'open', NOW(), NOW());
  
  INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
  VALUES
    (business3_id, 'Automotive Mechanic', 'Experienced mechanic needed. Must know car diagnostics and repairs. 2+ years experience.', 25000.00, 'Automotive', 'Barangay 1, Quezon City', 'Mendoza Auto Repair', 'open', NOW(), NOW())
  RETURNING id INTO job3_id;
  
  INSERT INTO public.jobs (business_id, title, description, salary, category, location, business_name, status, created_at, updated_at)
  VALUES
    (business3_id, 'Service Advisor', 'Customer-facing role. Explain repairs to customers and manage appointments.', 20000.00, 'Customer Service', 'Barangay 1, Quezon City', 'Mendoza Auto Repair', 'filled', NOW(), NOW());

  RAISE NOTICE 'Created 6 jobs';

  -- ============================================
  -- 5. CREATE JOB APPLICATIONS (from your account)
  -- ============================================
  
  INSERT INTO public.applications (job_id, user_id, user_name, user_email, status, cover_letter, applied_at)
  VALUES
    (job1_id, my_user_id, 'Test Applicant', 'test@example.com', 'pending', 'I am very interested in this position.', NOW()),
    (job2_id, my_user_id, 'Test Applicant', 'test@example.com', 'pending', 'I have experience and would love to work here.', NOW()),
    (job3_id, my_user_id, 'Test Applicant', 'test@example.com', 'accepted', 'I have the required skills for this role.', NOW());

  RAISE NOTICE 'Created 3 job applications';

  -- ============================================
  -- 6. CREATE ANNOUNCEMENTS
  -- ============================================
  
  INSERT INTO public.announcements (posted_by, title, content, type, location, location_id, created_at, updated_at)
  VALUES
    (my_user_id, 'Community Clean-up Drive', 'Join us this Saturday, 7am at the barangay hall for our monthly clean-up drive. Snacks will be provided!', 'barangay', 'barangay', NULL, NOW(), NOW()),
    (my_user_id, 'Basketball Tournament', 'Annual barangay basketball tournament starts next week. Register your team at the barangay office.', 'barangay', 'barangay', NULL, NOW(), NOW()),
    (my_user_id, 'Grand Sale!', 'All items 20% off this weekend! Visit Tan Sari-Sari Store for great deals.', 'business', 'business', business1_id, NOW(), NOW()),
    (my_user_id, 'New Menu Items', 'Try our new ube pandesal and cheese bread! Available starting tomorrow.', 'business', 'business', business2_id, NOW(), NOW()),
    (my_user_id, 'Free Check-up Promo', 'Free basic car check-up for first-time customers. Book your appointment now!', 'business', 'business', business3_id, NOW(), NOW()),
    (my_user_id, 'Traffic Advisory', 'Road construction on Main Avenue. Expect delays. Use alternate routes.', 'city', 'city', NULL, NOW(), NOW()),
    (my_user_id, 'Lost Pet', 'Lost: Brown dog, answers to "Brownie". Last seen near the park. Please contact if found.', 'barangay', 'barangay', NULL, NOW(), NOW());

  RAISE NOTICE 'Created 7 announcements';

  -- ============================================
  -- SUMMARY
  -- ============================================
  
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Mock data created successfully!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '3 Businesses';
  RAISE NOTICE '6 Individual Products';
  RAISE NOTICE '8 Business Products';
  RAISE NOTICE '6 Jobs (5 open, 1 filled)';
  RAISE NOTICE '3 Applications';
  RAISE NOTICE '7 Announcements';
  RAISE NOTICE '========================================';
  
END $$;
