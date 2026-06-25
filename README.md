# 📸 Lens & Frame — Photography & Videography Booking App

A full-stack booking platform with **Supabase** (auth + database), **Stripe** payments, user booking history, and an admin dashboard. Ready to deploy on **GitHub Pages** (frontend) + **Supabase** (backend).

---

## ✨ Features

| Feature | Details |
|---|---|
| 🔐 Authentication | Email/password login & registration via Supabase Auth |
| 📅 Booking flow | 3-step wizard: service → details → payment |
| 💳 Stripe payments | 30% deposit collected securely at booking |
| 📋 My Bookings | Users view and cancel their own sessions |
| 🛡️ Admin dashboard | Confirm/cancel bookings, view all clients & revenue |
| 🔒 Row Level Security | Users only see their own data; admins see all |

---

## 🚀 Setup Guide

### Step 1 — Fork & clone

```bash
git clone https://github.com/YOUR_USERNAME/lensframe.git
cd lensframe
```

---

### Step 2 — Set up Supabase

1. Go to [supabase.com](https://supabase.com) → **New project**
2. Name it `lensframe`, choose a region close to you
3. Once created, go to **SQL Editor** → paste the contents of `supabase-schema.sql` → **Run**
4. Copy your keys from **Project Settings → API**:
   - **Project URL** → `SUPABASE_URL`
   - **anon / public** key → `SUPABASE_ANON_KEY`

---

### Step 3 — Set up Stripe

1. Go to [stripe.com](https://stripe.com) → create an account
2. Go to **Developers → API Keys**
3. Copy your **Publishable key** → paste into `js/stripe-config.js`
4. Copy your **Secret key** — you'll use it in Step 5

---

### Step 4 — Add your keys to the app

Edit **`js/supabase.js`**:
```js
const SUPABASE_URL = 'https://xxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGci...';
```

Edit **`js/stripe-config.js`**:
```js
const STRIPE_PUBLISHABLE_KEY = 'pk_test_...';
```

---

### Step 5 — Deploy the Stripe Edge Function

Install the [Supabase CLI](https://supabase.com/docs/guides/cli) then:

```bash
# Login
supabase login

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Set your Stripe secret key
supabase secrets set STRIPE_SECRET_KEY=sk_test_YOUR_SECRET_KEY

# Deploy the edge function
supabase functions deploy create-payment-intent
```

---

### Step 6 — Deploy to GitHub Pages

1. Push your code to GitHub
2. Go to **Settings → Pages**
3. Set Source: **Deploy from branch → main → / (root)**
4. Your app will be live at: `https://YOUR_USERNAME.github.io/lensframe`

> ⚠️ **Important:** Update your Supabase project's **Site URL** (Authentication → URL Configuration) to match your GitHub Pages URL.

---

### Step 7 — Make yourself an admin

After creating your account in the app, run this in **Supabase → SQL Editor**:

```sql
UPDATE public.profiles
SET role = 'admin'
WHERE id = 'YOUR_USER_UUID';
```

Find your UUID under **Authentication → Users** in Supabase.

---

## 📁 Project structure

```
lensframe/
├── index.html                    # Homepage
├── css/
│   └── styles.css                # Shared design system
├── js/
│   ├── supabase.js               # ⚙️ Supabase client (add your keys here)
│   ├── stripe-config.js          # ⚙️ Stripe publishable key
│   └── utils.js                  # Shared helpers (auth, toast, formatting)
├── pages/
│   ├── login.html                # Sign in
│   ├── register.html             # Create account
│   ├── book.html                 # Booking wizard
│   └── bookings.html             # User booking history
├── admin/
│   └── dashboard.html            # Admin panel
├── supabase/
│   └── functions/
│       └── create-payment-intent/
│           └── index.ts          # Stripe Edge Function (Deno)
└── supabase-schema.sql           # Database schema + RLS policies
```

---

## 🔧 Customisation

### Change services & prices
Edit the `SERVICES` array in `pages/book.html`:
```js
const SERVICES = [
  { id: 'wedding', icon: '💍', name: 'Wedding Photography', price: 120000 }, // price in cents
  ...
];
```

### Change brand name
Search & replace `Lens & Frame` and `Lens<em>&</em>Frame` across all HTML files.

### Add email notifications
In the Edge Function, add [Resend](https://resend.com) or Supabase's built-in email to send booking confirmations.

---

## 🛠 Tech stack

- **Frontend:** Vanilla HTML/CSS/JS (no build step needed)
- **Auth & Database:** [Supabase](https://supabase.com) (PostgreSQL + RLS)
- **Payments:** [Stripe](https://stripe.com) (Payment Intents API)
- **Hosting:** GitHub Pages
- **Serverless:** Supabase Edge Functions (Deno)

---

## 📝 License

MIT — free to use and modify.
