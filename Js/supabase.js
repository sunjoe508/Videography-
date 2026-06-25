// ============================================================
// SUPABASE CONFIGURATION
// Replace these values with your own from supabase.com
// Project Settings → API → Project URL & anon/public key
// ============================================================
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';

const { createClient } = supabase;
const sb = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

export default sb;
