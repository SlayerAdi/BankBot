import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './context/AuthContext';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ChatPage from './pages/ChatPage';
import DashboardPage from './pages/DashboardPage';
import './App.css';

function Spinner() {
  return (
    <div className="fullscreen-loader">
      <div className="loader-orbit">
        <div className="orbit-ring" />
        <div className="orbit-dot" />
      </div>
      <p>Loading InfyBot…</p>
    </div>
  );
}

function SmartPublicRoute({ children }) {
  const { user, loading, canViewDash } = useAuth();

  if (loading) return <Spinner />;

  if (user) {
    return <Navigate to={canViewDash(user) ? '/dashboard' : '/chat'} replace />;
  }

  return children;
}

function PrivateRoute({ children }) {
  const { user, loading } = useAuth();

  if (loading) return <Spinner />;
  if (!user) return <Navigate to="/login" replace />;

  return children;
}

function DashboardRoute({ children }) {
  const { user, loading, canViewDash } = useAuth();

  if (loading) return <Spinner />;
  if (!user) return <Navigate to="/login" replace />;

  if (!canViewDash(user)) return <Navigate to="/chat" replace />;

  return children;
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/login" replace />} />

      <Route
        path="/login"
        element={
          <SmartPublicRoute>
            <LoginPage />
          </SmartPublicRoute>
        }
      />

      <Route
        path="/register"
        element={
          <SmartPublicRoute>
            <RegisterPage />
          </SmartPublicRoute>
        }
      />

      <Route
        path="/chat"
        element={
          <PrivateRoute>
            <ChatPage />
          </PrivateRoute>
        }
      />

      <Route
        path="/dashboard"
        element={
          <DashboardRoute>
            <DashboardPage />
          </DashboardRoute>
        }
      />

      <Route path="*" element={<Navigate to="/chat" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AppRoutes />
        <Toaster
          position="top-right"
          toastOptions={{
            duration: 3500,
            style: {
              fontFamily: "'DM Sans', sans-serif",
              background: '#1e2535',
              color: '#e8edf5',
              border: '1px solid rgba(255,255,255,0.1)',
              borderRadius: '14px',
              fontSize: '14px',
              padding: '12px 18px',
              boxShadow: '0 8px 32px rgba(0,0,0,0.3)',
            },
          }}
        />
      </BrowserRouter>
    </AuthProvider>
  );
}