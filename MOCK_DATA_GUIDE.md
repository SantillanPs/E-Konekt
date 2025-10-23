# Mock Data Setup Guide

## Overview
This guide explains how to populate your E-Konekt app with realistic test data.

## Prerequisites
✅ Database trigger for user creation is installed  
✅ RLS policies are applied  
✅ At least one user account created via the app

## Method 1: Using SQL Script (Recommended)

### Step 1: Get Your Auth User ID
1. Open **Supabase Dashboard** → **SQL Editor**
2. Run this query:
```sql
SELECT id, email FROM auth.users ORDER BY created_at DESC LIMIT 1;
```
3. Copy the UUID (e.g., `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)

### Step 2: Update the SQL Script
1. Open `create_mock_data.sql`
2. Find all instances of `'YOUR-AUTH-USER-ID'` (there are many)
3. Replace with your actual UUID
4. Also replace `'your-email@example.com'` and `'Your Name'` with your actual details

### Step 3: Run the Script
1. Go to **Supabase Dashboard** → **SQL Editor**
2. Copy the entire contents of `create_mock_data.sql`
3. Paste and click **Run**
4. Check for any errors in the output

### Step 4: Verify Data
Run these verification queries:
```sql
-- Check businesses (should show 3)
SELECT id, name, owner_id FROM public.businesses;

-- Check products (should show 8)
SELECT id, name, seller_type, business_id FROM public.products;

-- Check jobs (should show 4)
SELECT id, title, business_name, status FROM public.jobs;

-- Check announcements (should show 5)
SELECT id, title, type FROM public.announcements;
```

## Method 2: Using the App (Manual)

If you prefer to create data through the app interface:

### Create Businesses
1. Open the app
2. Navigate to **Business** section
3. Click **Create Business**
4. Fill in:
   - Name: "Sari-Sari Store ni Aling Nena"
   - Description: "Local convenience store"
   - Address: "123 Main St, Barangay 1"
   - Contact: "0917-123-4567"
5. Repeat for other businesses

### Create Products
1. Navigate to **Marketplace**
2. Click **Sell an Item**
3. For individual products:
   - Select "Individual Seller"
   - Fill in product details
4. For business products:
   - Select "Business Seller"
   - Choose your business
   - Fill in product details

### Create Jobs
1. Navigate to **Jobs**
2. Click **Post a Job**
3. Select your business
4. Fill in job details
5. Submit

### Create Announcements
1. Navigate to **Announcements**
2. Click **Create Announcement**
3. Fill in details
4. Select type (barangay/business/city)
5. Submit

## What Mock Data Includes

### 3 Businesses
- **Sari-Sari Store ni Aling Nena** - Convenience store
- **Mang Tomas Carinderia** - Filipino restaurant
- **QuickFix Repair Shop** - Electronics repair

### 8 Products
**Individual Products (3):**
- Used Laptop - ₱15,000
- Mountain Bike - ₱8,000
- Study Table - ₱2,500

**Business Products (5):**
- Rice 25kg - ₱1,200 (Sari-Sari Store)
- Cooking Oil 1L - ₱150 (Sari-Sari Store)
- Adobo Meal - ₱80 (Carinderia)
- Phone Screen Repair - ₱800 (Repair Shop)

### 4 Jobs
- Store Clerk - ₱12,000/month
- Cook/Kitchen Helper - ₱15,000/month
- Electronics Technician - ₱18,000/month
- Delivery Rider - ₱500/day (part-time)

### 5 Announcements
**Barangay Announcements (3):**
- Community Clean-Up Drive
- Basketball Tournament
- Free Medical Check-up

**Business Announcements (2):**
- Grand Opening Sale (Sari-Sari Store)
- New Menu Items (Carinderia)

## Testing Scenarios

### Test Marketplace
1. Browse products
2. Filter by category
3. View individual vs business products
4. Check product details

### Test Jobs
1. Browse job listings
2. Apply for a job
3. Check application status
4. (As business owner) View applications

### Test Announcements
1. View all announcements
2. Filter by type
3. Create new announcement
4. Edit/delete your announcements

### Test Business Features
1. View business profile
2. Edit business details
3. Add products to business
4. Post jobs for business

## Troubleshooting

### "Permission denied" errors
- Check that RLS policies are applied
- Verify you're using the correct user ID
- Make sure the user owns the data they're trying to modify

### "Foreign key violation" errors
- Ensure businesses are created before business products
- Verify business IDs exist before creating jobs
- Check that user ID exists in auth.users

### No data showing in app
- Verify data exists in Supabase Table Editor
- Check RLS policies allow SELECT for all users
- Refresh the app or restart it

### Business ID not found
After creating businesses, get their IDs:
```sql
SELECT id, name FROM public.businesses ORDER BY created_at DESC;
```

## Cleanup

To remove all mock data:
```sql
-- Delete in order (respects foreign keys)
DELETE FROM public.applications;
DELETE FROM public.jobs;
DELETE FROM public.products;
DELETE FROM public.announcements;
DELETE FROM public.businesses;
-- Don't delete users unless you want to remove your account
```

## Next Steps

After adding mock data:
1. ✅ Test all app features
2. ✅ Verify data displays correctly
3. ✅ Test CRUD operations
4. ✅ Check RLS policies work as expected
5. ✅ Test as different user roles

## Tips

- **Use realistic data** - Makes testing more meaningful
- **Test edge cases** - Try empty fields, long text, special characters
- **Create multiple users** - Test multi-user scenarios (requires creating more auth users)
- **Vary locations** - Test location-based filtering
- **Mix data types** - Individual + business products, different job categories

---

**Need more data?** Duplicate the INSERT statements in `create_mock_data.sql` and modify the values.
