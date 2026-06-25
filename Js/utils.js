import sb from './supabase.js';

// ── Toast notifications ───────────────────────────────────
export function toast(msg, type = 'default') {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    document.body.appendChild(container);
  }
  const el = document.createElement('div');
  el.className = `toast ${type}`;
  el.textContent = msg;
  container.appendChild(el);
  setTimeout(() => el.remove(), 3600);
}

// ── Auth helpers ──────────────────────────────────────────
export async function getUser() {
  const { data: { user } } = await sb.auth.getUser();
  return user;
}

export async function requireAuth(redirectTo = '/pages/login.html') {
  const user = await getUser();
  if (!user) { window.location.href = redirectTo; return null; }
  return user;
}

export async function requireAdmin(redirectTo = '/index.html') {
  const user = await requireAuth();
  if (!user) return null;
  const { data } = await sb.from('profiles').select('role').eq('id', user.id).single();
  if (!data || data.role !== 'admin') { window.location.href = redirectTo; return null; }
  return user;
}

export async function signOut() {
  await sb.auth.signOut();
  window.location.href = '/index.html';
}

// ── Render nav user state ─────────────────────────────────
export async function renderNav() {
  const user = await getUser();
  const navRight = document.getElementById('nav-right');
  if (!navRight) return;

  if (user) {
    const { data: profile } = await sb.from('profiles').select('full_name, role').eq('id', user.id).single();
    const name = profile?.full_name?.split(' ')[0] || 'Account';
    const isAdmin = profile?.role === 'admin';
    navRight.innerHTML = `
      ${isAdmin ? `<a href="/admin/dashboard.html" class="btn btn-ghost btn-sm">Admin</a>` : ''}
      <a href="/pages/bookings.html" class="btn btn-ghost btn-sm hide-mobile">My Bookings</a>
      <span style="font-size:.85rem;color:var(--ink-muted);padding:0 4px" class="hide-mobile">Hi, ${name}</span>
      <button onclick="window.__signOut()" class="btn btn-outline btn-sm">Sign out</button>
    `;
  } else {
    navRight.innerHTML = `
      <a href="/pages/login.html" class="btn btn-ghost btn-sm">Sign in</a>
      <a href="/pages/register.html" class="btn btn-primary btn-sm">Get started</a>
    `;
  }
  window.__signOut = signOut;
}

// ── Format currency ───────────────────────────────────────
export function formatCurrency(amount) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount / 100);
}

// ── Format date ───────────────────────────────────────────
export function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('en-US', { weekday:'short', year:'numeric', month:'short', day:'numeric' });
}
