import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useAuth } from '../context/AuthContext';

export default function LoginPage() {
  const { login, canViewDash } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({ account_number: '', password: '' });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const set = (f) => (e) => {
    setForm((p) => ({ ...p, [f]: e.target.value }));
    setErrors((p) => ({ ...p, [f]: '' }));
  };

  const validate = () => {
    const e = {};
    if (!form.account_number.trim()) e.account_number = 'Account number is required';
    if (!form.password) e.password = 'Password is required';
    return e;
  };

  const submit = async (ev) => {
    ev.preventDefault();
    const e = validate();

    if (Object.keys(e).length) {
      setErrors(e);
      return;
    }

    setLoading(true);

    try {
      const u = await login(form.account_number.trim(), form.password);
      toast.success(`Welcome, ${u.full_name}! 👋`);

      // ✅ Correct redirect logic
      navigate(canViewDash(u) ? '/dashboard' : '/chat');
    } catch (err) {
      toast.error(err.response?.data?.detail || 'Invalid credentials');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="simple-auth-wrap">
      <div className="simple-auth-box">
        <div className="simple-logo">🤖</div>
        <h1>Aditya Bank Login</h1>
        <p className="auth-sub">Sign in with your account number</p>

        <form onSubmit={submit}>
          <div className="field">
            <label>Account Number</label>
            <input
              type="text"
              value={form.account_number}
              onChange={set('account_number')}
              className={errors.account_number ? 'has-err' : ''}
              placeholder="Enter account number"
              autoComplete="username"
            />
            {errors.account_number && (
              <div className="field-err">⚠ {errors.account_number}</div>
            )}
          </div>

          <div className="field">
            <label>Password</label>
            <input
              type="password"
              value={form.password}
              onChange={set('password')}
              className={errors.password ? 'has-err' : ''}
              placeholder="Enter password"
              autoComplete="current-password"
            />
            {errors.password && (
              <div className="field-err">⚠ {errors.password}</div>
            )}
          </div>

          <button className="btn btn-primary" type="submit" disabled={loading}>
            {loading ? 'Signing in...' : 'Login'}
          </button>
        </form>

        <p className="auth-footer">
          Don’t have an account? <Link to="/register">Create one</Link>
        </p>
      </div>
    </div>
  );
}