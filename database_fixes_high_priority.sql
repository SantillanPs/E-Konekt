-- E-Konekt Database Fixes - High Priority
-- This script addresses critical database design issues
-- SUPPORTS: Both casual sellers (individual users) AND business accounts

-- ============================================
-- 1. UPDATE PRODUCTS TABLE - Support Both Individual & Business Sellers
-- ============================================

-- Step 1: Add new business_id column (nullable - for business products only)
-- First, check what type businesses.id actually is
DO $$ 
DECLARE
  business_id_type TEXT;
BEGIN
  -- Get the data type of businesses.id
  SELECT data_type INTO business_id_type
  FROM information_schema.columns
  WHERE table_schema = 'public' 
  AND table_name = 'businesses' 
  AND column_name = 'id';
  
  -- Add business_id column with matching type
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'products' 
    AND column_name = 'business_id'
  ) THEN
    IF business_id_type = 'uuid' THEN
      ALTER TABLE public.products ADD COLUMN business_id UUID;
    ELSIF business_id_type = 'bigint' THEN
      ALTER TABLE public.products ADD COLUMN business_id BIGINT;
    ELSE
      -- Default to the same type as businesses.id
      EXECUTE format('ALTER TABLE public.products ADD COLUMN business_id %s', business_id_type);
    END IF;
  END IF;
END $$;

-- Step 2: Add seller_type column to distinguish between individual and business sellers
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'products' 
    AND column_name = 'seller_type'
  ) THEN
    ALTER TABLE public.products ADD COLUMN seller_type TEXT DEFAULT 'individual';
  END IF;
END $$;

-- Step 3: Migrate existing data
-- Products with owner_id that matches a business owner -> link to business
-- Products with owner_id that doesn't match -> keep as individual seller
UPDATE public.products
SET business_id = (
  SELECT id FROM public.businesses 
  WHERE businesses.owner_id = products.owner_id 
  LIMIT 1
),
seller_type = CASE 
  WHEN EXISTS (
    SELECT 1 FROM public.businesses 
    WHERE businesses.owner_id = products.owner_id
  ) THEN 'business'
  ELSE 'individual'
END
WHERE seller_type IS NULL OR business_id IS NULL;

-- Step 4: Add foreign key constraint (nullable - only for business products)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'products_business_id_fkey'
  ) THEN
    ALTER TABLE public.products 
    ADD CONSTRAINT products_business_id_fkey 
    FOREIGN KEY (business_id) 
    REFERENCES public.businesses(id) 
    ON DELETE CASCADE;
  END IF;
END $$;

-- Step 5: Add CHECK constraint for seller_type
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'products_seller_type_check'
  ) THEN
    ALTER TABLE public.products 
    ADD CONSTRAINT products_seller_type_check 
    CHECK (seller_type IN ('individual', 'business'));
  END IF;
END $$;

-- Step 6: Add CHECK constraint to ensure data integrity
-- If seller_type = 'business', business_id must be set
-- If seller_type = 'individual', business_id must be NULL
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'products_seller_integrity_check'
  ) THEN
    ALTER TABLE public.products 
    ADD CONSTRAINT products_seller_integrity_check 
    CHECK (
      (seller_type = 'business' AND business_id IS NOT NULL) OR
      (seller_type = 'individual' AND business_id IS NULL)
    );
  END IF;
END $$;

-- Step 7: Keep owner_id for individual sellers (DO NOT DROP)
-- owner_id is now used for:
-- - Individual sellers: direct owner
-- - Business sellers: still tracked for audit purposes

-- ============================================
-- 2. ADD CHECK CONSTRAINTS FOR ENUM FIELDS
-- ============================================

-- First, check what roles currently exist and fix any invalid ones
DO $$
BEGIN
  -- Show current roles (for debugging)
  RAISE NOTICE 'Current roles in users table:';
  PERFORM role, COUNT(*) FROM public.users GROUP BY role;
  
  -- Normalize 'business' to 'business_owner' for consistency
  UPDATE public.users
  SET role = 'business_owner'
  WHERE role = 'business';
  
  -- Update any other invalid roles to 'user' (default)
  UPDATE public.users
  SET role = 'user'
  WHERE role NOT IN ('user', 'business', 'business_owner', 'admin', 'barangay_admin')
     OR role IS NULL;
END $$;

-- Add constraint for users.role (include 'business' for backward compatibility)
DO $$
BEGIN
  -- Drop existing constraint if it exists
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'users_role_check'
  ) THEN
    ALTER TABLE public.users DROP CONSTRAINT users_role_check;
  END IF;
  
  -- Add updated constraint
  ALTER TABLE public.users 
  ADD CONSTRAINT users_role_check 
  CHECK (role IN ('user', 'business', 'business_owner', 'admin', 'barangay_admin'));
END $$;

-- Add constraint for profiles.role (if it exists)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'profiles' 
    AND column_name = 'role'
  ) THEN
    -- Normalize 'business' to 'business_owner' in profiles
    UPDATE public.profiles
    SET role = 'business_owner'
    WHERE role = 'business';
    
    -- First, fix any other invalid roles in profiles
    UPDATE public.profiles
    SET role = 'user'
    WHERE role NOT IN ('user', 'business', 'business_owner', 'admin', 'barangay_admin')
       OR role IS NULL;
    
    -- Drop existing constraint if it exists
    IF EXISTS (
      SELECT 1 FROM information_schema.table_constraints 
      WHERE constraint_name = 'profiles_role_check'
    ) THEN
      ALTER TABLE public.profiles DROP CONSTRAINT profiles_role_check;
    END IF;
    
    -- Then add the updated constraint
    ALTER TABLE public.profiles 
    ADD CONSTRAINT profiles_role_check 
    CHECK (role IN ('user', 'business', 'business_owner', 'admin', 'barangay_admin'));
  END IF;
END $$;

-- Verify announcements.type constraint exists (should already be there)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'announcements_type_check'
  ) THEN
    ALTER TABLE public.announcements 
    ADD CONSTRAINT announcements_type_check 
    CHECK (type IN ('barangay', 'business', 'city'));
  END IF;
END $$;

-- ============================================
-- 3. ADD STATUS FIELD TO JOBS TABLE
-- ============================================

-- Add status column
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'jobs' 
    AND column_name = 'status'
  ) THEN
    ALTER TABLE public.jobs ADD COLUMN status TEXT DEFAULT 'open';
  END IF;
END $$;

-- Add check constraint for job status
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'jobs_status_check'
  ) THEN
    ALTER TABLE public.jobs 
    ADD CONSTRAINT jobs_status_check 
    CHECK (status IN ('open', 'closed', 'filled'));
  END IF;
END $$;

-- Set existing jobs to 'open' status
UPDATE public.jobs SET status = 'open' WHERE status IS NULL;

-- ============================================
-- 4. UPDATE PRODUCTS RLS POLICIES - Support Both Seller Types
-- ============================================

-- Drop old product policies
DROP POLICY IF EXISTS "Product owners can create products" ON public.products;
DROP POLICY IF EXISTS "Product owners can update their products" ON public.products;
DROP POLICY IF EXISTS "Product owners can delete their products" ON public.products;
DROP POLICY IF EXISTS "Business owners can create products for their business" ON public.products;
DROP POLICY IF EXISTS "Business owners can update their business products" ON public.products;
DROP POLICY IF EXISTS "Business owners can delete their business products" ON public.products;

-- Create unified policies that support both individual and business sellers
CREATE POLICY "Users can create products as individual or business seller"
  ON public.products
  FOR INSERT
  WITH CHECK (
    -- Individual seller: user owns the product directly
    (seller_type = 'individual' AND auth.uid() = owner_id AND business_id IS NULL)
    OR
    -- Business seller: user owns the business
    (seller_type = 'business' AND business_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = business_id
      AND businesses.owner_id = auth.uid()
    ))
  );

CREATE POLICY "Users can update their own products"
  ON public.products
  FOR UPDATE
  USING (
    -- Individual seller: user owns the product directly
    (seller_type = 'individual' AND auth.uid() = owner_id)
    OR
    -- Business seller: user owns the business
    (seller_type = 'business' AND EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = business_id
      AND businesses.owner_id = auth.uid()
    ))
  );

CREATE POLICY "Users can delete their own products"
  ON public.products
  FOR DELETE
  USING (
    -- Individual seller: user owns the product directly
    (seller_type = 'individual' AND auth.uid() = owner_id)
    OR
    -- Business seller: user owns the business
    (seller_type = 'business' AND EXISTS (
      SELECT 1 FROM public.businesses
      WHERE businesses.id = business_id
      AND businesses.owner_id = auth.uid()
    ))
  );

-- ============================================
-- 5. UPDATE INDEXES
-- ============================================

-- Keep owner_id index (used for individual sellers)
CREATE INDEX IF NOT EXISTS idx_products_owner_id ON public.products(owner_id);

-- Create new index on business_id (used for business sellers)
CREATE INDEX IF NOT EXISTS idx_products_business_id ON public.products(business_id);

-- Add index on seller_type for filtering
CREATE INDEX IF NOT EXISTS idx_products_seller_type ON public.products(seller_type);

-- Add composite index for efficient queries
CREATE INDEX IF NOT EXISTS idx_products_seller_type_owner ON public.products(seller_type, owner_id);

-- Add index on job status for filtering
CREATE INDEX IF NOT EXISTS idx_jobs_status ON public.jobs(status);

-- ============================================
-- 6. UPDATE HELPER FUNCTIONS
-- ============================================

-- Function to get products by business
CREATE OR REPLACE FUNCTION get_business_products(business_uuid UUID)
RETURNS SETOF public.products AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM public.products
  WHERE seller_type = 'business' AND business_id = business_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get products by individual user
CREATE OR REPLACE FUNCTION get_user_products(user_uuid UUID)
RETURNS SETOF public.products AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM public.products
  WHERE seller_type = 'individual' AND owner_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get all products by user (both individual and business)
CREATE OR REPLACE FUNCTION get_all_user_products(user_uuid UUID)
RETURNS SETOF public.products AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM public.products
  WHERE 
    (seller_type = 'individual' AND owner_id = user_uuid)
    OR
    (seller_type = 'business' AND business_id IN (
      SELECT id FROM public.businesses WHERE owner_id = user_uuid
    ))
  ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user owns a business
CREATE OR REPLACE FUNCTION user_owns_business(user_uuid UUID, business_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.businesses
    WHERE id = business_uuid
    AND owner_id = user_uuid
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get active jobs (open status)
CREATE OR REPLACE FUNCTION get_active_jobs()
RETURNS SETOF public.jobs AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM public.jobs
  WHERE status = 'open'
  ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user can sell (either as individual or has a business)
CREATE OR REPLACE FUNCTION user_can_sell(user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users WHERE id = user_uuid
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Run these queries after migration to verify everything worked:

-- 1. Check product seller types distribution
-- SELECT seller_type, COUNT(*) 
-- FROM public.products 
-- GROUP BY seller_type;

-- 2. Check individual products (should have owner_id, no business_id)
-- SELECT id, name, owner_id, business_id, seller_type
-- FROM public.products 
-- WHERE seller_type = 'individual'
-- LIMIT 10;

-- 3. Check business products (should have both owner_id and business_id)
-- SELECT p.id, p.name, p.owner_id, p.business_id, b.name as business_name, seller_type
-- FROM public.products p
-- JOIN public.businesses b ON b.id = p.business_id
-- WHERE seller_type = 'business'
-- LIMIT 10;

-- 4. Check all jobs have valid status
-- SELECT status, COUNT(*) 
-- FROM public.jobs 
-- GROUP BY status;

-- 5. Check all users have valid roles
-- SELECT role, COUNT(*) 
-- FROM public.users 
-- GROUP BY role;

-- 6. Test helper functions
-- SELECT * FROM get_user_products('YOUR_USER_ID_HERE');
-- SELECT * FROM get_business_products('YOUR_BUSINESS_ID_HERE');
-- SELECT * FROM get_all_user_products('YOUR_USER_ID_HERE');
-- SELECT * FROM get_active_jobs();
