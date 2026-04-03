import React, { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';

const AuthCtx = createContext(null);

// ─────────────────────────────────────────────────────────────────────────────
// API BASE URL
// Set REACT_APP_API_URL in your environment to point to the FastAPI backend.
//
// How to configure per environment:
//
//   Development  — create a file called  frontend/.env.local  and add:
//     REACT_APP_API_URL=http://localhost:8000
//
//   Production   — set the variable in your hosting platform (Vercel, Netlify,
//     Docker, etc.) or in frontend/.env.production:
//     REACT_APP_API_URL=https://your-api-domain.com
//
// If the variable is not set, the app falls back to the React dev-server proxy
// (configured via "proxy" in package.json), which already points to :8000.
// ─────────────────────────────────────────────────────────────────────────────
if (process.env.REACT_APP_API_URL) {
  axios.defaults.baseURL = process.env.REACT_APP_API_URL;
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem('infybot_token');

    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

      axios
        .get('/api/auth/me')
        .then((r) => setUser(r.data.user))
        .catch(() => {
          localStorage.removeItem('infybot_token');
          delete axios.defaults.headers.common['Authorization'];
        })
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (account_number, password) => {
  const { data } = await axios.post('/api/auth/login', {
    account_number,
    password
  });

  const token = data.access_token || data.token;

  if (!token) {
    throw new Error('No token returned from login API');
  }

  localStorage.setItem('infybot_token', token);
  axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

  // ✅ ALWAYS GET FRESH USER
  const me = await axios.get('/api/auth/me');

  setUser(me.data.user);

  return me.data.user;
  };

  const register = async (payload) => {
    const { data } = await axios.post('/api/auth/register', payload);

    const token = data.access_token || data.token;

    if (!token) {
      throw new Error('No token returned from register API');
    }

    localStorage.setItem('infybot_token', token);
    axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

    setUser(data.user);
    return data;
  };

  const logout = () => {
    localStorage.removeItem('infybot_token');
    delete axios.defaults.headers.common['Authorization'];
    setUser(null);
  };

  const isAdmin = (u = user) => u?.role === 'admin';

  const canViewDash = (u = user) =>
    u?.role === 'admin' || ['view', 'edit'].includes((u?.dashboard_access || '').toLowerCase());

  const canEditDash = (u = user) =>
    u?.role === 'admin' || (u?.dashboard_access || '').toLowerCase() === 'edit';

  return (
    <AuthCtx.Provider
      value={{
        user,
        setUser,
        login,
        register,
        logout,
        loading,
        isAdmin,
        canViewDash,
        canEditDash
      }}
    >
      {children}
    </AuthCtx.Provider>
  );
}

export const useAuth = () => useContext(AuthCtx);