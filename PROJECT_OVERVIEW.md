# E-Konekt - Complete Project Overview

## Project Summary

**E-Konekt** is a Flutter-based community marketplace and job platform designed for barangay (neighborhood) communities in the Philippines. It connects local residents, businesses, and job seekers within specific geographic areas.

## Tech Stack

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Platform**: Android, iOS (cross-platform)

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Real-time**: Supabase Realtime subscriptions
- **Storage**: Supabase Storage (for images)

### Environment
- **Config**: flutter_dotenv for environment variables
- **Location**: Barangay and City-based (Philippines)

## Core Features

### 1. **Marketplace** 🛒
- Users can buy and sell products
- Two seller types:
  - **Individual Sellers**: Casual users selling random items (no business needed)
  - **Business Sellers**: Users with business profiles selling professionally
- Products include: name, description, price, stock, images, category, location

### 2. **Jobs Board** 💼
- **Business owners only** can post job openings
- Users can browse and apply for jobs
- Job applications tracked with status (pending, accepted, rejected)
- Requires business profile to post jobs

### 3. **Announcements** 📢
- Community-wide announcements
- Three types:
  - **Barangay**: Local neighborhood announcements
  - **Business**: Business-specific announcements
  - **City**: City-wide announcements
- Posted by users or barangay admins

### 4. **Business Profiles** 🏢
- Users can create business profiles
- Business includes: name, description, address, contact info, logo
- Enables posting jobs and business products
- One user can own multiple businesses (future support)

### 5. **User Authentication** 🔐
- Sign up with email/password
- Login/Logout
- User roles: user, business, business_owner, admin, barangay_admin
- Profile includes: name, email, barangay, city

## Database Schema

### Tables

#### **users**
```sql
- id (UUID, PK) → references auth.users
- name (TEXT)
- email (TEXT, UNIQUE)
- role (TEXT) → 'user', 'business', 'business_owner', 'admin', 'barangay_admin'
- barangay (TEXT) → neighborhood/district
- city (TEXT)
- barangay_admin (BOOLEAN) → admin flag
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

#### **profiles**
```sql
- id (UUID, PK) → references auth.users
- name (TEXT)
- role (TEXT)
- barangay (TEXT)
- city (TEXT)
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

#### **businesses**
```sql
- id (BIGINT, PK)
- owner_id (UUID, FK → users.id)
- name (TEXT)
- description (TEXT)
- address (TEXT)
- contact_info (TEXT)
- logo_url (TEXT)
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

#### **products**
```sql
- id (BIGINT, PK)
- owner_id (UUID, FK → users.id) → always set
- business_id (BIGINT, FK → businesses.id) → only for business products
- seller_type (TEXT) → 'individual' or 'business'
- name (TEXT)
- description (TEXT)
- price (NUMERIC)
- stock (INTEGER)
- image_url (TEXT)
- location (TEXT)
- category (TEXT)
- owner_name (TEXT) → denormalized for display
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

#### **jobs**
```sql
- id (BIGINT, PK)
- business_id (BIGINT, FK → businesses.id)
- title (TEXT)
- description (TEXT)
- salary (NUMERIC)
- category (TEXT)
- location (TEXT)
- business_name (TEXT) → denormalized
- status (TEXT) → 'open', 'closed', 'filled'
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

#### **applications**
```sql
- id (BIGINT, PK)
- job_id (BIGINT, FK → jobs.id)
- user_id (UUID, FK → users.id)
- user_name (TEXT) → denormalized
- user_email (TEXT) → denormalized
- status (TEXT) → 'pending', 'accepted', 'rejected'
- cover_letter (TEXT)
- applied_at (TIMESTAMPTZ)
- UNIQUE(job_id, user_id) → prevent duplicate applications
```

#### **announcements**
```sql
- id (UUID, PK)
- posted_by (UUID, FK → users.id)
- title (TEXT)
- content (TEXT)
- type (TEXT) → 'barangay', 'business', 'city'
- location (TEXT) → location type
- location_id (UUID) → references businesses.id if type='business'
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

### Relationships

```
users (1) ──owns──> (many) businesses
users (1) ──posts──> (many) announcements
users (1) ──sells──> (many) products (as individual)
users (1) ──submits──> (many) applications

businesses (1) ──sells──> (many) products (as business)
businesses (1) ──posts──> (many) jobs
businesses (1) ──posts──> (many) announcements (business-specific)

jobs (1) ──receives──> (many) applications
```

## Security (Row Level Security)

### RLS Policies

**Read (SELECT)**:
- ✅ Anyone can view: products, jobs, businesses, announcements, user profiles
- ✅ Users can view their own applications
- ✅ Business owners can view applications for their jobs

**Create (INSERT)**:
- ✅ Authenticated users can create their own data
- ✅ Business owners can create products/jobs for their business
- ✅ Users can create individual products without a business

**Update/Delete**:
- ✅ Users can only modify their own data
- ✅ Business owners can modify their business data
- ✅ Business owners can update application status

## Project Structure

```
e_konekt/
├── lib/
│   ├── models/              # Data models
│   │   ├── announcement_model.dart
│   │   ├── application_model.dart
│   │   ├── business_model.dart
│   │   ├── job_model.dart
│   │   ├── product_model.dart
│   │   └── user_model.dart
│   │
│   ├── screens/             # UI screens
│   │   ├── announcements/
│   │   │   ├── announcements_screen.dart
│   │   │   ├── add_announcement_screen.dart
│   │   │   └── announcement_detail_screen.dart
│   │   ├── business/
│   │   │   └── create_business_screen.dart
│   │   ├── jobs/
│   │   │   ├── jobs_screen.dart
│   │   │   └── [job-related screens]
│   │   ├── marketplace/
│   │   │   └── marketplace_screen.dart
│   │   ├── profile/
│   │   │   └── [profile screens]
│   │   └── home_screen.dart
│   │
│   ├── services/            # Business logic & API calls
│   │   ├── announcement_service.dart
│   │   ├── auth_service.dart
│   │   ├── business_service.dart
│   │   ├── job_service.dart
│   │   ├── product_service.dart
│   │   └── user_service.dart
│   │
│   ├── widgets/             # Reusable widgets
│   │   ├── custom_textfield.dart
│   │   └── primary_button.dart
│   │
│   ├── app.dart             # App widget
│   └── main.dart            # Entry point
│
├── android/                 # Android-specific files
├── ios/                     # iOS-specific files
├── .env                     # Environment variables (SUPABASE_URL, SUPABASE_ANON_KEY)
├── pubspec.yaml             # Dependencies
└── [database files]         # SQL migration scripts
```

## Key User Flows

### 1. **Sign Up & Login**
```
User opens app
  → Sign up with email/password
  → Provide: name, barangay, city, role
  → Account created in Supabase Auth
  → User profile created in users/profiles table
  → Redirect to Home screen
```

### 2. **Sell as Individual (Casual Seller)**
```
User logs in
  → Navigate to Marketplace
  → Click "Sell an Item"
  → Fill product form:
     - seller_type: 'individual'
     - owner_id: user's ID
     - business_id: NULL
  → Product listed immediately
  → Visible to all users
```

### 3. **Create Business & Sell Professionally**
```
User logs in
  → Navigate to "My Business" or Profile
  → Click "Create Business Profile"
  → Fill business details:
     - name, description, address, contact, logo
  → Business created (owner_id = user's ID)
  → Now can:
     - Post products (seller_type: 'business')
     - Post jobs
     - Create business announcements
```

### 4. **Post a Job (Business Owners Only)**
```
Business owner logs in
  → Navigate to Jobs tab
  → Click "Post a Job"
  → Fill job details:
     - title, description, salary, category
     - business_id: their business ID
  → Job posted
  → Visible to all users
  → Users can apply
```

### 5. **Apply for a Job**
```
User browses jobs
  → Clicks on a job
  → Views job details
  → Clicks "Apply"
  → Optionally adds cover letter
  → Application submitted:
     - job_id, user_id, status: 'pending'
  → Business owner can view application
  → Business owner can accept/reject
```

### 6. **Post Announcement**
```
User/Admin logs in
  → Navigate to Announcements
  → Click "Create Announcement"
  → Fill details:
     - title, content
     - type: barangay/business/city
     - location_id: (if business announcement)
  → Announcement posted
  → Visible to all users
```

## Current Issues & Fixes

### Known Issues
1. **setState() after dispose()**: Multiple screens calling setState after widget is unmounted
   - Affects: JobsScreen, AnnouncementsScreen, MarketplaceScreen
   - Need to check `mounted` before calling setState

2. **Multiple heroes with same tag**: Hero widget tag conflicts

### Recent Database Updates
1. ✅ Added dual-seller system (individual + business)
2. ✅ Added `seller_type` and `business_id` to products
3. ✅ Added `status` field to jobs
4. ✅ Added role constraints (including 'business' role)
5. ✅ Added `location` and `location_id` to announcements
6. ✅ Updated RLS policies for dual-seller support

## Environment Variables

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^latest
  provider: ^latest
  flutter_dotenv: ^latest
  # ... other dependencies
```

## Design Patterns

### State Management
- **Provider**: Used for dependency injection and state management
- Services (AuthService, UserService, etc.) provided at app root
- Screens consume services via `Provider.of<T>(context)`

### Architecture
- **Service Layer**: Business logic separated from UI
- **Models**: Data classes with fromJson/toJson serialization
- **Screens**: UI components that consume services
- **Widgets**: Reusable UI components

## Business Rules

### Products
- ✅ Anyone can sell as individual (no business needed)
- ✅ Business owners can sell under their business
- ✅ Same user can have both individual and business products
- ✅ Products show seller type (individual vs business)

### Jobs
- ❌ Individual users CANNOT post jobs
- ✅ Only business owners can post jobs
- ✅ Jobs must be linked to a business
- ✅ Anyone can apply for jobs
- ✅ One application per user per job

### Announcements
- ✅ Any authenticated user can post announcements
- ✅ Barangay admins can post official announcements
- ✅ Business owners can post business-specific announcements
- ✅ Announcements can be targeted (barangay/business/city)

### Businesses
- ✅ Any user can create a business profile
- ✅ Business owner manages their business
- ✅ Business enables job posting and professional selling
- ✅ Business has profile (name, logo, description, contact)

## Geographic Context

### Philippine Administrative Divisions
- **City**: Municipality or city (e.g., "Quezon City", "Manila")
- **Barangay**: Smallest administrative division, neighborhood/village
- Each city has multiple barangays
- Users are associated with a specific barangay and city

### Location-Based Features
- Products can be filtered by location
- Announcements can be barangay-specific
- Jobs show business location
- Community-focused marketplace

## Future Enhancements (Potential)

1. **Chat/Messaging**: Direct messaging between buyers and sellers
2. **Reviews/Ratings**: Rate businesses and products
3. **Search & Filters**: Advanced search by category, price, location
4. **Notifications**: Push notifications for applications, messages
5. **Image Upload**: Direct image upload to Supabase Storage
6. **Business Verification**: Verified business badges
7. **Job Expiration**: Auto-close jobs after expiration date
8. **Announcement Pinning**: Pin important announcements
9. **Multiple Business Support**: One user owning multiple businesses
10. **Analytics**: Business dashboard with sales/application metrics

## Development Notes

### Testing Accounts
- Regular user: Can browse, buy, sell individually
- Business owner: Has business profile, can post jobs
- Admin: Can manage announcements, users

### Common Operations

**Get all products**:
```dart
final products = await productService.getAllProducts();
```

**Get user's individual products**:
```sql
SELECT * FROM get_user_products('user-id');
```

**Get business products**:
```sql
SELECT * FROM get_business_products('business-id');
```

**Get active jobs**:
```sql
SELECT * FROM get_active_jobs();
```

**Check if user owns business**:
```sql
SELECT user_owns_business('user-id', 'business-id');
```

## Error Handling

### Common Errors
1. **PostgrestException**: Database/RLS policy errors
2. **AuthException**: Authentication errors
3. **Network errors**: Connection issues
4. **Validation errors**: Form validation failures

### Best Practices
- Always check `mounted` before `setState()`
- Handle async errors with try-catch
- Show user-friendly error messages
- Log errors for debugging

## Summary

E-Konekt is a **community-focused marketplace and job platform** that:
- Connects local residents within barangays
- Supports both casual and professional selling
- Enables businesses to post jobs and products
- Facilitates community announcements
- Uses Supabase for backend and Flutter for cross-platform mobile app
- Implements proper security with RLS policies
- Designed specifically for Philippine barangay communities

The app bridges the gap between casual peer-to-peer selling and professional business operations, all within a localized community context.
