# Dual Seller System - Individual & Business Sellers

## Overview

The E-Konekt marketplace now supports **two types of sellers**:

1. **Individual Sellers** - Regular users who want to sell random items casually
2. **Business Sellers** - Users who create a business profile for professional selling

## Database Schema

### Products Table Structure

```sql
products:
  - id (UUID)
  - owner_id (UUID) → Always set, references the user
  - business_id (UUID) → Only set for business products, NULL for individual
  - seller_type (TEXT) → 'individual' or 'business'
  - name, description, price, stock, etc.
  - created_at, updated_at
```

### Key Constraints

```sql
-- Seller type must be valid
CHECK (seller_type IN ('individual', 'business'))

-- Data integrity: seller_type must match the data
CHECK (
  (seller_type = 'business' AND business_id IS NOT NULL) OR
  (seller_type = 'individual' AND business_id IS NULL)
)
```

## How It Works

### Individual Sellers (Casual Selling)

**Who**: Any registered user  
**What**: Can list items directly without creating a business  
**Use Case**: Selling used items, personal belongings, one-off sales

**Example**:
```dart
// User creates a product as individual seller
{
  "owner_id": "user-123",
  "business_id": null,
  "seller_type": "individual",
  "name": "Used Bicycle",
  "price": 5000
}
```

**Benefits**:
- ✅ No business setup required
- ✅ Quick and easy listing
- ✅ Perfect for one-time sales
- ✅ Lower barrier to entry

### Business Sellers (Professional Selling)

**Who**: Users who create a business profile  
**What**: Products are listed under their business name  
**Use Case**: Stores, restaurants, service providers, regular sellers

**Example**:
```dart
// User creates a business first
{
  "id": "business-456",
  "owner_id": "user-123",
  "name": "Juan's Bike Shop"
}

// Then creates products under the business
{
  "owner_id": "user-123",
  "business_id": "business-456",
  "seller_type": "business",
  "name": "Mountain Bike Pro",
  "price": 25000
}
```

**Benefits**:
- ✅ Professional branding
- ✅ Business profile with logo, description
- ✅ Can post jobs
- ✅ Multiple products under one brand
- ✅ Business-specific announcements

## User Flows

### Flow 1: Individual Seller (Casual)

```
User logs in
  → Goes to Marketplace
  → Clicks "Sell an Item"
  → Fills product form (seller_type = 'individual')
  → Product listed immediately
```

### Flow 2: Business Seller (Professional)

```
User logs in
  → Goes to "My Business" (or Profile)
  → Clicks "Create Business Profile"
  → Fills business details (name, description, logo)
  → Business created
  → Now can:
     - Post products (seller_type = 'business')
     - Post jobs
     - Create business announcements
```

### Flow 3: Upgrade from Individual to Business

```
User has been selling individually
  → Decides to create a business
  → Creates business profile
  → Can now:
     - Keep old individual listings (seller_type = 'individual')
     - Create new business listings (seller_type = 'business')
     - Both types visible in "My Products"
```

## Security (RLS Policies)

### Create Products
```sql
-- Users can create as individual OR business seller
(seller_type = 'individual' AND auth.uid() = owner_id AND business_id IS NULL)
OR
(seller_type = 'business' AND business_id IS NOT NULL AND user_owns_business)
```

### Update/Delete Products
```sql
-- Individual: user owns the product directly
(seller_type = 'individual' AND auth.uid() = owner_id)
OR
-- Business: user owns the business
(seller_type = 'business' AND user_owns_business)
```

## Helper Functions

### Get Individual Products
```sql
SELECT * FROM get_user_products('user-id');
-- Returns only products where seller_type = 'individual'
```

### Get Business Products
```sql
SELECT * FROM get_business_products('business-id');
-- Returns only products where seller_type = 'business'
```

### Get All User Products
```sql
SELECT * FROM get_all_user_products('user-id');
-- Returns both individual AND business products for a user
```

## UI/UX Considerations

### Product Listing Display

**Individual Product**:
```
[Product Image]
Used Bicycle - ₱5,000
Sold by: Juan Dela Cruz (Individual Seller)
Location: Barangay 1, Quezon City
```

**Business Product**:
```
[Product Image]
Mountain Bike Pro - ₱25,000
Sold by: Juan's Bike Shop (Business)
Location: Barangay 1, Quezon City
```

### Seller Badge/Icon
- Individual: 👤 "Individual Seller"
- Business: 🏢 "Business" (with verified badge if applicable)

### "Sell" Button Logic

```dart
// When user clicks "Sell an Item"
if (user.hasBusiness) {
  // Show option to choose:
  // - Sell as Individual
  // - Sell as Business (dropdown to select which business)
} else {
  // Show option to:
  // - Sell as Individual (default)
  // - Create Business Profile (link/button)
}
```

## Migration Notes

### Existing Data
- All existing products will be analyzed:
  - If `owner_id` matches a business owner → `seller_type = 'business'`
  - Otherwise → `seller_type = 'individual'`

### No Data Loss
- `owner_id` is kept for all products
- Individual products: `owner_id` is the seller
- Business products: `owner_id` is tracked for audit (who created it)

## Advantages of This System

1. **Flexibility**: Users can sell casually OR professionally
2. **Low Barrier**: No business setup required for simple sales
3. **Scalability**: Users can upgrade to business when ready
4. **Clear Attribution**: Products clearly show seller type
5. **Better Organization**: Business products grouped under brand
6. **Professional Growth**: Supports users growing from casual to business sellers

## Example Scenarios

### Scenario 1: Student Selling Old Textbooks
- Creates account
- Lists textbooks as **individual seller**
- No business needed
- Quick and simple

### Scenario 2: Local Store Owner
- Creates account
- Creates **business profile** for "Sari-Sari Store"
- Lists products under business
- Posts job openings
- Professional presence

### Scenario 3: Freelancer Turned Entrepreneur
- Starts selling services individually
- Business grows
- Creates **business profile**
- Keeps old individual listings
- New listings under business brand
- Can manage both simultaneously
