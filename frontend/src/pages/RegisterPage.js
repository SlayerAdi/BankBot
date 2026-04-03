import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useAuth } from '../context/AuthContext';

export default function RegisterPage() {
  const { register } = useAuth();
  const navigate = useNavigate();

  const [form, setForm] = useState({
    full_name: '',
    account_number: '',
    email: '',
    password: '',
    confirm: '',
    department: '',
  });

  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [newAccNo, setNewAccNo] = useState('');

  const set = (f) => (e) => {
    setForm((p) => ({ ...p, [f]: e.target.value }));
    setErrors((p) => ({ ...p, [f]: '' }));
  };

  const validate = () => {
    const e = {};

    if (!form.full_name.trim() || form.full_name.trim().length < 2) {
      e.full_name = 'Name must be at least 2 characters';
    }

    if (!form.account_number.trim()) {
      e.account_number = 'Account number is required';
    } else if (!/^\d{8,20}$/.test(form.account_number.trim())) {
      e.account_number = 'Account number must be 8 to 20 digits only';
    }

    if (!form.email || !/\S+@\S+\.\S+/.test(form.email)) {
      e.email = 'Valid email required';
    }

    if (!form.password || form.password.length < 8) {
      e.password = 'Password must be at least 8 characters';
    }

    if (form.password !== form.confirm) {
      e.confirm = 'Passwords do not match';
    }

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
      const data = await register({
        full_name: form.full_name.trim(),
        account_number: form.account_number.trim(),
        email: form.email.trim(),
        password: form.password,
        department: form.department.trim() || null,
      });

      setNewAccNo(data.account_number || form.account_number.trim());
      toast.success('Account created successfully 🎉');
    } catch (err) {
      const detail = err.response?.data?.detail;

      if (Array.isArray(detail)) {
        toast.error(detail[0]?.msg || 'Validation error');
      } else {
        toast.error(detail || 'Registration failed');
      }
    } finally {
      setLoading(false);
    }
  };

  if (newAccNo) {
    return (
      <div className="simple-auth-wrap">
        <div className="simple-auth-box">
          <div className="simple-logo">🎉</div>
          <h1>Account Created</h1>
          <p className="auth-sub">Save your account number carefully</p>

          <div className="acc-hint">
            <h4>Your Account Number</h4>
            <code>{newAccNo}</code>
          </div>

          <div style={{ height: 20 }} />

          <button className="btn btn-primary" onClick={() => navigate('/chat')}>
            Go to Chat
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="simple-auth-wrap">
      <div className="simple-auth-box">
        <div className="simple-logo">🤖</div>
        <h1>Create Account</h1>
        <p className="auth-sub">Register to start using Aditya Bank Bot</p>

        <form onSubmit={submit}>
          <div className="field">
            <label>Full Name</label>
            <input
              type="text"
              value={form.full_name}
              onChange={set('full_name')}
              className={errors.full_name ? 'has-err' : ''}
              placeholder="Enter your full name"
            />
            {errors.full_name && <div className="field-err">⚠ {errors.full_name}</div>}
          </div>

          <div className="field">
            <label>Account Number</label>
            <input
              type="text"
              value={form.account_number}
              onChange={set('account_number')}
              className={errors.account_number ? 'has-err' : ''}
              placeholder="Enter your account number"
              maxLength={20}
            />
            {errors.account_number && (
              <div className="field-err">⚠ {errors.account_number}</div>
            )}
          </div>

          <div className="field">
            <label>Email</label>
            <input
              type="email"
              value={form.email}
              onChange={set('email')}
              className={errors.email ? 'has-err' : ''}
              placeholder="Enter your email"
            />
            {errors.email && <div className="field-err">⚠ {errors.email}</div>}
          </div>

          <div className="field">
            <label>Department</label>
            <input
              type="text"
              value={form.department}
              onChange={set('department')}
              placeholder="Optional"
            />
          </div>

          <div className="field">
            <label>Password</label>
            <input
              type="password"
              value={form.password}
              onChange={set('password')}
              className={errors.password ? 'has-err' : ''}
              placeholder="Enter password"
            />
            {errors.password && <div className="field-err">⚠ {errors.password}</div>}
          </div>

          <div className="field">
            <label>Confirm Password</label>
            <input
              type="password"
              value={form.confirm}
              onChange={set('confirm')}
              className={errors.confirm ? 'has-err' : ''}
              placeholder="Confirm password"
            />
            {errors.confirm && <div className="field-err">⚠ {errors.confirm}</div>}
          </div>

          <button className="btn btn-primary" type="submit" disabled={loading}>
            {loading ? 'Creating...' : 'Create Account'}
          </button>
        </form>

        <p className="auth-footer">
          Already have an account? <Link to="/login">Login</Link>
        </p>
      </div>
    </div>
  );
}