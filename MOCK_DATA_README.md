# Mock Data Population Script

This script helps you populate your Supabase database with sample users and products for testing your E-Konekt app.

## Prerequisites

1. Make sure your `.env` file has the correct Supabase credentials including the service role key
2. The `users` and `products` tables should exist in your Supabase database

## How to Run

### Option 1: Using Dart Script (Recommended)

```bash
# Make sure you're in the project root directory
cd c:\Users\admin\Documents\Programming\e_konekt

# Run the population script
dart run populate_mock_data.dart
```

### Option 2: Using Flutter Command

```bash
# If the above doesn't work, try:
flutter pub run dart run populate_mock_data.dart
```

## What Gets Created

### Sample Users (3 users):
- **Juan Dela Cruz** - Barangay 1, Manila
- **Maria Santos** - Barangay 2, Quezon City
- **Pedro Reyes** - Barangay 3, Makati

### Sample Products (5 products):
1. **iPhone 14 Pro** (Electronics) - ₱50,000
2. **Wooden Dining Table** (Furniture) - ₱15,000
3. **Fresh Organic Vegetables** (Food) - ₱500
4. **Vintage Leather Jacket** (Clothing) - ₱2,500
5. **Home Cleaning Service** (Services) - ₱2,000

## Alternative: Manual SQL Approach

If you prefer to add data manually through Supabase Dashboard:

1. Go to **Table Editor** in your Supabase dashboard
2. Select the `users` table and insert the sample data
3. Select the `products` table and insert the sample products

## Notes

- The script uses your service role key for admin operations
- Make sure your database tables have the correct structure
- The mock user IDs follow the pattern `user_X_mock_id` for easy identification
- You can modify the script to add more or different data as needed

## Troubleshooting

If you get permission errors:
1. Make sure your service role key is correct in the `.env` file
2. Ensure Row Level Security (RLS) policies allow the service role to insert data
3. Check that the table structures match what the script expects
