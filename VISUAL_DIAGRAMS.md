# E-Konekt Visual Diagrams

## 1. Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    USERS ||--o{ BUSINESSES : owns
    USERS ||--o{ PRODUCTS : "sells (individual)"
    USERS ||--o{ ANNOUNCEMENTS : posts
    USERS ||--o{ APPLICATIONS : submits
    
    BUSINESSES ||--o{ PRODUCTS : "sells (business)"
    BUSINESSES ||--o{ JOBS : posts
    BUSINESSES ||--o{ ANNOUNCEMENTS : "posts (business)"
    
    JOBS ||--o{ APPLICATIONS : receives
    
    USERS {
        uuid id PK
        text name
        text email UK
        text role
        text barangay
        text city
        boolean barangay_admin
        timestamptz created_at
        timestamptz updated_at
    }
    
    PROFILES {
        uuid id PK
        text name
        text role
        text barangay
        text city
        timestamptz created_at
        timestamptz updated_at
    }
    
    BUSINESSES {
        bigint id PK
        uuid owner_id FK
        text name
        text description
        text address
        text contact_info
        text logo_url
        timestamptz created_at
        timestamptz updated_at
    }
    
    PRODUCTS {
        bigint id PK
        uuid owner_id FK
        bigint business_id FK
        text seller_type
        text name
        text description
        numeric price
        integer stock
        text image_url
        text location
        text category
        text owner_name
        timestamptz created_at
        timestamptz updated_at
    }
    
    JOBS {
        bigint id PK
        bigint business_id FK
        text title
        text description
        numeric salary
        text category
        text location
        text business_name
        text status
        timestamptz created_at
        timestamptz updated_at
    }
    
    APPLICATIONS {
        bigint id PK
        bigint job_id FK
        uuid user_id FK
        text user_name
        text user_email
        text status
        text cover_letter
        timestamptz applied_at
    }
    
    ANNOUNCEMENTS {
        uuid id PK
        uuid posted_by FK
        text title
        text content
        text type
        text location
        uuid location_id
        timestamptz created_at
        timestamptz updated_at
    }
```

## 2. User Flow - Sign Up & Onboarding

```mermaid
flowchart TD
    A[User Opens App] --> B{Has Account?}
    B -->|No| C[Click Sign Up]
    B -->|Yes| D[Login]
    
    C --> E[Enter Details]
    E --> F[Name]
    E --> G[Email]
    E --> H[Password]
    E --> I[Barangay]
    E --> J[City]
    E --> K[Role]
    
    F --> L[Submit Sign Up]
    G --> L
    H --> L
    I --> L
    J --> L
    K --> L
    
    L --> M{Validation OK?}
    M -->|No| N[Show Error]
    N --> E
    M -->|Yes| O[Create Auth Account]
    
    O --> P[Create User Profile]
    P --> Q[Redirect to Home]
    
    D --> R[Enter Credentials]
    R --> S{Valid?}
    S -->|No| T[Show Error]
    T --> R
    S -->|Yes| Q
    
    Q --> U[Home Screen]
```

## 3. User Flow - Selling Products

```mermaid
flowchart TD
    A[User on Home Screen] --> B{Want to Sell?}
    B -->|Yes| C[Navigate to Marketplace]
    C --> D[Click 'Sell an Item']
    
    D --> E{Has Business?}
    E -->|No| F[Sell as Individual]
    E -->|Yes| G{Choose Seller Type}
    
    G -->|Individual| F
    G -->|Business| H[Select Business]
    
    F --> I[Fill Product Form]
    H --> I
    
    I --> J[Product Name]
    I --> K[Description]
    I --> L[Price]
    I --> M[Stock]
    I --> N[Category]
    I --> O[Upload Image]
    
    J --> P[Submit Product]
    K --> P
    L --> P
    M --> P
    N --> P
    O --> P
    
    P --> Q{Validation OK?}
    Q -->|No| R[Show Error]
    R --> I
    
    Q -->|Yes| S{Seller Type?}
    S -->|Individual| T[Create Product<br/>seller_type: individual<br/>business_id: NULL]
    S -->|Business| U[Create Product<br/>seller_type: business<br/>business_id: SET]
    
    T --> V[Product Listed]
    U --> V
    V --> W[Visible to All Users]
```

## 4. User Flow - Creating Business & Posting Jobs

```mermaid
flowchart TD
    A[User Wants to Post Job] --> B{Has Business?}
    B -->|No| C[Navigate to 'My Business']
    B -->|Yes| J
    
    C --> D[Click 'Create Business']
    D --> E[Fill Business Form]
    
    E --> F[Business Name]
    E --> G[Description]
    E --> H[Address]
    E --> I[Contact Info]
    E --> K[Upload Logo]
    
    F --> L[Submit Business]
    G --> L
    H --> L
    I --> L
    K --> L
    
    L --> M{Validation OK?}
    M -->|No| N[Show Error]
    N --> E
    
    M -->|Yes| O[Create Business Profile]
    O --> P[Business Created]
    
    P --> J[Navigate to Jobs Tab]
    J --> Q[Click 'Post a Job']
    
    Q --> R[Fill Job Form]
    R --> S[Job Title]
    R --> T[Description]
    R --> U[Salary]
    R --> V[Category]
    
    S --> W[Submit Job]
    T --> W
    U --> W
    V --> W
    
    W --> X{Validation OK?}
    X -->|No| Y[Show Error]
    Y --> R
    
    X -->|Yes| Z[Create Job<br/>business_id: SET<br/>status: open]
    Z --> AA[Job Posted]
    AA --> AB[Visible to All Users]
```

## 5. User Flow - Job Application Process

```mermaid
flowchart TD
    A[User Browses Jobs] --> B[Click on Job]
    B --> C[View Job Details]
    
    C --> D{Already Applied?}
    D -->|Yes| E[Show 'Already Applied']
    D -->|No| F[Click 'Apply']
    
    F --> G[Application Form]
    G --> H[Optional: Add Cover Letter]
    
    H --> I[Submit Application]
    I --> J{Validation OK?}
    J -->|No| K[Show Error]
    K --> G
    
    J -->|Yes| L[Create Application<br/>status: pending]
    L --> M[Application Submitted]
    
    M --> N[Business Owner Notified]
    N --> O{Business Owner Reviews}
    
    O -->|Accept| P[Update status: accepted]
    O -->|Reject| Q[Update status: rejected]
    O -->|Pending| R[No Action Yet]
    
    P --> S[Applicant Notified]
    Q --> S
    R --> T[Waiting for Response]
```

## 6. System Architecture Diagram

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter App<br/>Android/iOS]
    end
    
    subgraph "State Management"
        B[Provider]
        C[AuthService]
        D[UserService]
        E[ProductService]
        F[BusinessService]
        G[JobService]
        H[AnnouncementService]
    end
    
    subgraph "Backend - Supabase"
        I[Supabase Auth]
        J[PostgreSQL Database]
        K[Realtime Subscriptions]
        L[Storage<br/>Images]
        M[Row Level Security]
    end
    
    A --> B
    B --> C
    B --> D
    B --> E
    B --> F
    B --> G
    B --> H
    
    C --> I
    D --> J
    E --> J
    F --> J
    G --> J
    H --> J
    
    J --> M
    K --> A
    L --> A
    
    style A fill:#4CAF50
    style I fill:#FF9800
    style J fill:#2196F3
    style M fill:#F44336
```

## 7. Data Flow - Product Creation (Dual Seller)

```mermaid
sequenceDiagram
    participant U as User
    participant UI as Flutter UI
    participant PS as ProductService
    participant DB as Supabase DB
    participant RLS as RLS Policies
    
    U->>UI: Click "Sell an Item"
    UI->>U: Show Seller Type Options
    
    alt Individual Seller
        U->>UI: Select "Sell as Individual"
        UI->>PS: createProduct(seller_type: 'individual')
        PS->>DB: INSERT INTO products<br/>(owner_id, seller_type, business_id: NULL)
        DB->>RLS: Check Policy
        RLS->>RLS: Verify auth.uid() = owner_id
        RLS->>DB: Policy Passed
        DB->>PS: Product Created
        PS->>UI: Success
        UI->>U: Show "Product Listed"
    else Business Seller
        U->>UI: Select "Sell as Business"
        UI->>U: Show Business Dropdown
        U->>UI: Select Business
        UI->>PS: createProduct(seller_type: 'business', business_id)
        PS->>DB: INSERT INTO products<br/>(owner_id, seller_type, business_id)
        DB->>RLS: Check Policy
        RLS->>RLS: Verify user owns business
        RLS->>DB: Policy Passed
        DB->>PS: Product Created
        PS->>UI: Success
        UI->>U: Show "Product Listed"
    end
```

## 8. Access Control Matrix

```mermaid
graph LR
    subgraph "User Roles & Permissions"
        A[Regular User] --> A1[✓ Browse All]
        A --> A2[✓ Sell Individual]
        A --> A3[✓ Apply for Jobs]
        A --> A4[✓ Post Announcements]
        A --> A5[✗ Post Jobs]
        
        B[Business Owner] --> B1[✓ All User Permissions]
        B --> B2[✓ Sell as Business]
        B --> B3[✓ Post Jobs]
        B --> B4[✓ Manage Applications]
        B --> B5[✓ Business Announcements]
        
        C[Barangay Admin] --> C1[✓ All User Permissions]
        C --> C2[✓ Official Announcements]
        C --> C3[✓ Moderate Content]
        
        D[System Admin] --> D1[✓ All Permissions]
        D --> D2[✓ Manage Users]
        D --> D3[✓ System Config]
    end
    
    style A fill:#90CAF9
    style B fill:#81C784
    style C fill:#FFB74D
    style D fill:#E57373
```

## 9. Product Seller Type Decision Tree

```mermaid
flowchart TD
    A[User Wants to Sell] --> B{Has Business Profile?}
    
    B -->|No| C[Can Only Sell as Individual]
    B -->|Yes| D[Can Choose Seller Type]
    
    C --> E[Product Created:<br/>seller_type: individual<br/>owner_id: user_id<br/>business_id: NULL]
    
    D --> F{Choose Type}
    F -->|Individual| E
    F -->|Business| G[Product Created:<br/>seller_type: business<br/>owner_id: user_id<br/>business_id: business_id]
    
    E --> H[Product Display:<br/>👤 Individual Seller<br/>Sold by: User Name]
    G --> I[Product Display:<br/>🏢 Business<br/>Sold by: Business Name]
    
    H --> J[Buyer Sees Product]
    I --> J
    
    style C fill:#FFE082
    style D fill:#81C784
    style E fill:#90CAF9
    style G fill:#A5D6A7
```

## 10. Announcement Types & Targeting

```mermaid
flowchart TD
    A[Create Announcement] --> B{Select Type}
    
    B -->|Barangay| C[Barangay Announcement]
    B -->|Business| D[Business Announcement]
    B -->|City| E[City Announcement]
    
    C --> F[Target: Specific Barangay]
    D --> G[Target: Business Customers]
    E --> H[Target: Entire City]
    
    F --> I[location: barangay<br/>location_id: NULL]
    G --> J[location: business<br/>location_id: business_id]
    H --> K[location: city<br/>location_id: NULL]
    
    I --> L[Visible to:<br/>Users in that Barangay]
    J --> M[Visible to:<br/>All Users<br/>Tagged with Business]
    K --> N[Visible to:<br/>Users in that City]
    
    style C fill:#81C784
    style D fill:#64B5F6
    style E fill:#FFB74D
```

## 11. Job Application State Machine

```mermaid
stateDiagram-v2
    [*] --> JobPosted: Business posts job<br/>(status: open)
    
    JobPosted --> ApplicationSubmitted: User applies
    
    ApplicationSubmitted --> Pending: Application created<br/>(status: pending)
    
    Pending --> Accepted: Business accepts
    Pending --> Rejected: Business rejects
    Pending --> Withdrawn: User withdraws
    
    Accepted --> [*]: Application successful
    Rejected --> [*]: Application unsuccessful
    Withdrawn --> [*]: User cancelled
    
    JobPosted --> JobClosed: Business closes job<br/>(status: closed)
    JobPosted --> JobFilled: Position filled<br/>(status: filled)
    
    JobClosed --> [*]
    JobFilled --> [*]
```

## 12. Database Trigger Flow

```mermaid
flowchart LR
    A[UPDATE users] --> B[Trigger:<br/>update_users_updated_at]
    B --> C[Function:<br/>update_updated_at_column]
    C --> D[SET updated_at = NOW]
    
    E[UPDATE products] --> F[Trigger:<br/>update_products_updated_at]
    F --> C
    
    G[UPDATE jobs] --> H[Trigger:<br/>update_jobs_updated_at]
    H --> C
    
    I[UPDATE businesses] --> J[Trigger:<br/>update_businesses_updated_at]
    J --> C
    
    K[UPDATE announcements] --> L[Trigger:<br/>update_announcements_updated_at]
    L --> C
    
    style C fill:#4CAF50
```

## 13. Complete System Lifecycle - Entity Relationships Across Platform

```mermaid
flowchart TD
    Start([Platform Start]) --> A[👤 User Signs Up]
    
    A --> B[User Profile Created]
    B --> C{User Activity Path}
    
    %% Path 1: Casual User
    C -->|Casual Seller| D1[Browse Marketplace]
    D1 --> D2[List Product<br/>as Individual]
    D2 --> D3[📦 Product Listed<br/>seller_type: individual]
    D3 --> D4[Other Users Browse]
    D4 --> D5[Product Sold]
    D5 --> D6[Transaction Complete]
    
    %% Path 2: Job Seeker
    C -->|Job Seeker| E1[Browse Jobs]
    E1 --> E2[Find Suitable Job]
    E2 --> E3[📝 Submit Application<br/>status: pending]
    E3 --> E4{Business Reviews}
    E4 -->|Accepted| E5[✅ Application Accepted]
    E4 -->|Rejected| E6[❌ Application Rejected]
    E5 --> E7[Job Filled]
    E6 --> E1
    
    %% Path 3: Business Owner
    C -->|Entrepreneur| F1[Create Business Profile]
    F1 --> F2[🏢 Business Created<br/>owner_id linked]
    
    F2 --> F3{Business Activities}
    
    %% Business Activity: Products
    F3 -->|Sell Products| G1[List Product<br/>as Business]
    G1 --> G2[📦 Product Listed<br/>seller_type: business<br/>business_id linked]
    G2 --> G3[Product Visible<br/>with Business Branding]
    G3 --> G4[Customer Purchases]
    G4 --> G5[Business Revenue]
    
    %% Business Activity: Jobs
    F3 -->|Hire Staff| H1[Post Job Opening]
    H1 --> H2[💼 Job Posted<br/>status: open<br/>business_id linked]
    H2 --> H3[Job Visible to Users]
    H3 --> H4[Users Apply]
    H4 --> H5[📋 Applications Received]
    H5 --> H6{Review Applications}
    H6 -->|Accept| H7[Update: accepted]
    H6 -->|Reject| H8[Update: rejected]
    H7 --> H9[Position Filled]
    H9 --> H10[Update Job<br/>status: filled]
    
    %% Business Activity: Announcements
    F3 -->|Promote Business| I1[Create Announcement]
    I1 --> I2[📢 Business Announcement<br/>type: business<br/>location_id: business_id]
    I2 --> I3[Announcement Visible<br/>to Community]
    I3 --> I4[Increased Visibility]
    
    %% Path 4: Community Engagement
    C -->|Community Member| J1[Post Announcement]
    J1 --> J2{Announcement Type}
    J2 -->|Barangay| J3[📢 Barangay Announcement<br/>type: barangay]
    J2 -->|City| J4[📢 City Announcement<br/>type: city]
    J3 --> J5[Community Informed]
    J4 --> J5
    
    %% Convergence Points
    D6 --> K[Platform Activity]
    E7 --> K
    G5 --> K
    H10 --> K
    I4 --> K
    J5 --> K
    
    K --> L{User Continues?}
    L -->|Yes| C
    L -->|No| M([User Inactive])
    
    %% Styling
    style A fill:#4CAF50,color:#fff
    style F2 fill:#2196F3,color:#fff
    style D3 fill:#FF9800,color:#fff
    style G2 fill:#FF9800,color:#fff
    style H2 fill:#9C27B0,color:#fff
    style E3 fill:#E91E63,color:#fff
    style I2 fill:#00BCD4,color:#fff
    style J3 fill:#00BCD4,color:#fff
    style J4 fill:#00BCD4,color:#fff
    style K fill:#FFC107,color:#000
    
    classDef userAction fill:#81C784,stroke:#4CAF50,stroke-width:2px
    classDef businessAction fill:#64B5F6,stroke:#2196F3,stroke-width:2px
    classDef productAction fill:#FFB74D,stroke:#FF9800,stroke-width:2px
    classDef jobAction fill:#BA68C8,stroke:#9C27B0,stroke-width:2px
    classDef announcementAction fill:#4DD0E1,stroke:#00BCD4,stroke-width:2px
```

## 14. Platform Ecosystem - Complete Entity Interaction Map

```mermaid
graph TB
    subgraph "User Layer"
        U1[👤 Regular User]
        U2[👤 Business Owner]
        U3[👤 Barangay Admin]
    end
    
    subgraph "Core Entities"
        B[🏢 Business Profile]
        P1[📦 Individual Product]
        P2[📦 Business Product]
        J[💼 Job Posting]
        A1[📢 Personal Announcement]
        A2[📢 Business Announcement]
        A3[📢 Official Announcement]
    end
    
    subgraph "Interaction Entities"
        APP[📝 Job Application]
        TRANS[💰 Transaction]
        VIEW[👁️ Views/Engagement]
    end
    
    subgraph "Platform Data"
        MARKET[🛒 Marketplace]
        JOBS[💼 Jobs Board]
        COMM[📣 Community Feed]
    end
    
    %% User to Core Entities
    U1 -->|creates| P1
    U1 -->|submits| APP
    U1 -->|posts| A1
    U1 -->|views| MARKET
    U1 -->|views| JOBS
    U1 -->|views| COMM
    
    U2 -->|owns| B
    U2 -->|creates| P1
    U2 -->|creates via| P2
    
    B -->|posts| J
    B -->|lists| P2
    B -->|publishes| A2
    
    U3 -->|publishes| A3
    
    %% Interactions
    J -->|receives| APP
    APP -->|status updates| U1
    APP -->|reviewed by| U2
    
    P1 -->|listed in| MARKET
    P2 -->|listed in| MARKET
    MARKET -->|generates| TRANS
    
    J -->|listed in| JOBS
    
    A1 -->|shown in| COMM
    A2 -->|shown in| COMM
    A3 -->|shown in| COMM
    
    MARKET -->|tracked| VIEW
    JOBS -->|tracked| VIEW
    COMM -->|tracked| VIEW
    
    %% Lifecycle connections
    U1 -.upgrade.-> U2
    P1 -.can become.-> P2
    J -.when filled.-> APP
    
    style U1 fill:#81C784
    style U2 fill:#64B5F6
    style U3 fill:#FFB74D
    style B fill:#42A5F5
    style P1 fill:#FFA726
    style P2 fill:#FF7043
    style J fill:#AB47BC
    style APP fill:#EC407A
    style MARKET fill:#26A69A
    style JOBS fill:#7E57C2
    style COMM fill:#29B6F6
```

## 15. Timeline View - User Journey Through Platform

```mermaid
gantt
    title E-Konekt User Journey Timeline
    dateFormat YYYY-MM-DD
    section User Onboarding
    Sign Up & Create Profile           :done, signup, 2025-01-01, 1d
    Browse Marketplace                 :done, browse1, after signup, 2d
    
    section Casual Selling
    List First Product (Individual)    :done, prod1, after browse1, 1d
    Product Sold                       :done, sold1, after prod1, 3d
    List More Products                 :done, prod2, after sold1, 2d
    
    section Job Seeking
    Browse Jobs                        :done, jobsearch, after prod2, 1d
    Submit Application                 :done, apply, after jobsearch, 1d
    Wait for Response                  :active, wait, after apply, 5d
    Application Accepted               :milestone, accepted, after wait, 0d
    
    section Business Growth
    Create Business Profile            :done, bizstart, after sold1, 1d
    List Products as Business          :done, bizprod, after bizstart, 2d
    Post First Job Opening             :done, postjob, after bizprod, 1d
    Receive Applications               :active, getapps, after postjob, 7d
    Hire Employee                      :milestone, hire, after getapps, 0d
    
    section Community Engagement
    Post Announcements                 :done, announce, after bizstart, 1d
    Engage with Community              :active, engage, after announce, 30d
    
    section Platform Maturity
    Established Business               :milestone, mature, after hire, 0d
    Ongoing Operations                 :active, ongoing, after mature, 60d
```

---

## How to View These Diagrams

### Option 1: GitHub/GitLab
- Push this file to GitHub/GitLab
- Mermaid diagrams render automatically

### Option 2: VS Code
- Install "Markdown Preview Mermaid Support" extension
- Open this file and preview

### Option 3: Online Viewers
- Copy diagram code to https://mermaid.live/
- Renders interactive diagrams

### Option 4: Export as Images
- Use mermaid-cli: `mmdc -i VISUAL_DIAGRAMS.md -o diagrams.pdf`
