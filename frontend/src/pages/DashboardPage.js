import React, { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import toast from 'react-hot-toast';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts';
import { useAuth } from '../context/AuthContext';

function StatCard({ icon, label, value, sub }) {
  return (
    <div className="admin-stat-card">
      <div className="admin-stat-icon">{icon}</div>
      <div className="admin-stat-value">{value ?? '—'}</div>
      <div className="admin-stat-label">{label}</div>
      {sub && <div className="admin-stat-sub">{sub}</div>}
    </div>
  );
}

function Badge({ children, type = 'default' }) {
  return <span className={`admin-badge ${type}`}>{children}</span>;
}

export default function DashboardPage() {
  const { user, logout, isAdmin, canViewDash, canEditDash } = useAuth();
  const navigate = useNavigate();

  const adminUser = isAdmin(user);
  const hasDashAccess = canViewDash(user);
  const canEdit = canEditDash(user);

  const TABS = useMemo(() => {
    const tabs = [
      { key: 'overview', label: 'Overview', icon: '📊' },
      { key: 'logs', label: 'Logs', icon: '📋' },
      { key: 'access', label: 'Access', icon: '🔑' },
      { key: 'intent_manager', label: 'Intent Manager', icon: '🛠️' }
    ];

    if (adminUser) {
      tabs.splice(2, 0, { key: 'users', label: 'Users', icon: '👥' });
    }

    return tabs;
  }, [adminUser]);

  const [tab, setTab] = useState('overview');
  const [dash, setDash] = useState(null);

  const [users, setUsers] = useState([]);
  const [userTotal, setUserTotal] = useState(0);
  const [userPage, setUserPage] = useState(1);
  const [userSearch, setUserSearch] = useState('');

  const [logs, setLogs] = useState([]);
  const [logTotal, setLogTotal] = useState(0);
  const [logPage, setLogPage] = useState(1);
  const [logFilters, setLogFilters] = useState({
    intent: '',
    start_date: '',
    end_date: ''
  });

  const [accessLog, setAccessLog] = useState([]);
  const [intentList, setIntentList] = useState([]);

  const [newIntent, setNewIntent] = useState('');
  const [examples, setExamples] = useState('');
  const [responseText, setResponseText] = useState('');
  const [editingIntent, setEditingIntent] = useState(null);

  const [saving, setSaving] = useState({});
  const [exporting, setExporting] = useState(false);

  useEffect(() => {
    if (!hasDashAccess) {
      navigate('/chat');
      return;
    }

    if (!TABS.some((t) => t.key === tab)) {
      setTab('overview');
      return;
    }

    if (tab === 'overview') loadDash();
    if (tab === 'logs') loadLogs();
    if (adminUser && tab === 'users') loadUsers();
    if (tab === 'intent_manager') loadIntentManager();
    if (tab === 'access') loadAccessLog();
  }, [
    tab,
    userPage,
    userSearch,
    logPage,
    logFilters.intent,
    logFilters.start_date,
    logFilters.end_date,
    adminUser,
    hasDashAccess,
    navigate,
    TABS
  ]);

  const loadDash = async () => {
    try {
      const { data } = await axios.get('/api/admin/dashboard');
      setDash(data);
    } catch (e) {
      toast.error(e.response?.data?.detail || 'Dashboard load failed');
    }
  };

  const loadUsers = async () => {
    try {
      const { data } = await axios.get('/api/admin/users', {
        params: { search: userSearch, page: userPage, limit: 15 }
      });
      setUsers(data.users || []);
      setUserTotal(data.total || 0);
    } catch {
      toast.error('Failed to load users');
    }
  };

  const loadLogs = async () => {
    try {
      const params = {
        page: logPage,
        limit: 30
      };

      if (logFilters.intent?.trim()) params.intent = logFilters.intent.trim();
      if (logFilters.start_date) params.start_date = logFilters.start_date;
      if (logFilters.end_date) params.end_date = logFilters.end_date;

      const { data } = await axios.get('/api/admin/logs', { params });
      setLogs(data.logs || []);
      setLogTotal(data.total || 0);
    } catch (e) {
      toast.error(e.response?.data?.detail || 'Failed to load logs');
    }
  };

  const loadAccessLog = async () => {
    try {
      const { data } = await axios.get('/api/admin/access-log');
      setAccessLog(data.log || []);
    } catch {
      toast.error('Failed to load access log');
    }
  };

  const loadIntentManager = async () => {
    try {
      const { data } = await axios.get('/api/rasa/intents');
      setIntentList(data.intents || []);
    } catch {
      toast.error('Failed to load intents');
    }
  };

  const resetIntentForm = () => {
    setEditingIntent(null);
    setNewIntent('');
    setExamples('');
    setResponseText('');
  };

  const addIntent = async () => {
  if (!canEdit) return toast.error('Edit access required');
  if (!newIntent.trim()) return toast.error('Intent name required');
  if (!examples.trim()) return toast.error('Examples required');

  const cleanedIntent = newIntent.trim().toLowerCase().replace(/\s+/g, '_');

  if (
    cleanedIntent === 'loan_eligibility' ||
    cleanedIntent === 'balance_check' ||
    cleanedIntent === 'card_block'
  ) {
    toast.error('Use existing banking intent names. Edit the existing intent instead of creating duplicate variants.');
    return;
  }

  try {
    await axios.post('/api/rasa/intents', {
      intent: cleanedIntent,
      examples: examples
        .split('\n')
        .map((e) => e.trim())
        .filter(Boolean),
      response: responseText.trim()
    });

    toast.success('Intent saved');
    resetIntentForm();
    loadIntentManager();
  } catch (e) {
    toast.error(e.response?.data?.detail || 'Failed to save intent');
  }
};

  const updateIntent = async () => {
    if (!canEdit) return toast.error('Edit access required');
    if (!editingIntent) return;
    if (!newIntent.trim()) return toast.error('Intent name required');
    if (!examples.trim()) return toast.error('Examples required');

    try {
      await axios.put(`/api/rasa/intents/${editingIntent}`, {
        intent: newIntent.trim(),
        examples: examples
          .split('\n')
          .map((e) => e.trim())
          .filter(Boolean),
        response: responseText.trim()
      });

      toast.success('Intent updated');
      resetIntentForm();
      loadIntentManager();
    } catch (e) {
      toast.error(e.response?.data?.detail || 'Failed to update intent');
    }
  };

  const deleteIntent = async (intentName) => {
    if (!canEdit) return toast.error('Edit access required');
    if (!window.confirm(`Delete intent "${intentName}"?\n\nThis will remove it from NLU, domain, rules and stories.`)) return;

    try {
      await axios.delete(`/api/rasa/intents/${intentName}`);
      toast.success('Intent deleted');
      loadIntentManager();
    } catch (e) {
      toast.error(e.response?.data?.detail || 'Failed to delete intent');
    }
  };

  const trainModel = async () => {
  if (!canEdit) return toast.error('Edit access required');

  try {
    toast.loading('Training Rasa model...', { id: 'train' });

    const res = await axios.post('/api/rasa/train');

    if (res.data.warning) {
      toast.success(`Rasa trained successfully. ${res.data.warning}`, { id: 'train' });
    } else {
      toast.success('Rasa trained successfully and latest model loaded.', { id: 'train' });
    }
  } catch (e) {
    console.error("TRAIN ERROR:", e.response?.data || e);
    toast.error(
      e.response?.data?.detail?.slice(0, 500) || 'Training failed',
      { id: 'train' }
    );
  }
  };

  const startEditIntent = (item) => {
    if (!canEdit) return;

    setEditingIntent(item.intent);
    setNewIntent(item.intent);
    setExamples(
      (item.examples || '')
        .split('\n')
        .map((line) => line.replace(/^\s*-\s*/, '').trim())
        .filter(Boolean)
        .join('\n')
    );
    setResponseText(item.response || '');
  };

  const setAccess = async (uid, level) => {
    setSaving((p) => ({ ...p, [uid + '_acc']: true }));
    try {
      await axios.patch(`/api/admin/users/${uid}/access`, {
        access_level: level
      });
      toast.success(`Access → "${level}"`);
      loadUsers();
    } catch (e) {
      toast.error(e.response?.data?.detail || 'Failed');
    } finally {
      setSaving((p) => ({ ...p, [uid + '_acc']: false }));
    }
  };

  const setRole = async (uid, role) => {
    setSaving((p) => ({ ...p, [uid + '_role']: true }));
    try {
      await axios.patch(`/api/admin/users/${uid}/role`, { role });
      toast.success(`Role → "${role}"`);
      loadUsers();
    } catch (e) {
      toast.error(e.response?.data?.detail || 'Failed');
    } finally {
      setSaving((p) => ({ ...p, [uid + '_role']: false }));
    }
  };

  const toggleUser = async (uid) => {
    try {
      await axios.patch(`/api/admin/users/${uid}/toggle`);
      toast.success('User status updated');
      loadUsers();
    } catch (e) {
      toast.error(e.response?.data?.detail || 'Failed');
    }
  };

  const flagMsg = async (id) => {
    if (!canEdit) return toast.error('Edit access required');

    try {
      await axios.patch(`/api/admin/messages/${id}/flag`);
      toast.success('Flag toggled');
      loadLogs();
    } catch {
      toast.error('Failed to flag');
    }
  };

  const exportCSV = async (type) => {
    setExporting(true);
    try {
      const params = type === 'messages' ? logFilters : {};
      const resp = await axios.get(`/api/admin/export/${type}`, {
        params,
        responseType: 'blob'
      });

      const url = window.URL.createObjectURL(new Blob([resp.data]));
      const a = document.createElement('a');
      a.href = url;
      a.download = `${type}_export_${new Date().toISOString().slice(0, 10)}.csv`;
      a.click();
      window.URL.revokeObjectURL(url);
      toast.success('CSV exported!');
    } catch {
      toast.error('Export failed');
    } finally {
      setExporting(false);
    }
  };

  const doLogout = () => {
    logout();
    navigate('/login');
  };

  const kpi = dash?.kpi || {};

  const initials =
    user?.full_name
      ?.split(' ')
      .map((w) => w[0])
      .join('')
      .slice(0, 2)
      .toUpperCase() || '?';

  return (
    <div className="admin-page">
      <div className="admin-topbar">
        <div className="admin-top-left">
          <div className="admin-logo">⚙️</div>
          <div>
            <div className="admin-title">
              {adminUser ? 'Aditya Bank Admin' : 'Aditya Bank Dashboard'}
            </div>
            <div className="admin-subtitle">
              {adminUser
                ? 'Manage analytics, users, logs and intents'
                : `Dashboard access: ${canEdit ? 'Edit' : 'View'}`}
            </div>
          </div>
        </div>

        <div className="admin-top-right">
          <button className="btn btn-secondary btn-sm" onClick={() => navigate('/chat')}>
            Go to Chat
          </button>
          <div className="user-pill" onClick={doLogout} title="Sign out">
            <div className="user-avatar">{initials}</div>
            <div>
              <div className="user-name">{user?.full_name}</div>
              <div className="user-meta">{user?.account_number}</div>
            </div>
          </div>
        </div>
      </div>

      <div className="admin-tabbar-wrap">
        <div className="admin-tabbar">
          {TABS.map((item) => (
            <button
              key={item.key}
              className={`admin-tab ${tab === item.key ? 'active' : ''}`}
              onClick={() => setTab(item.key)}
            >
              <span>{item.icon}</span> {item.label}
            </button>
          ))}
        </div>
      </div>

      <div className="admin-content">
        {tab === 'overview' && (
          <>
            {!dash ? (
              <div className="admin-card admin-center">Loading dashboard…</div>
            ) : (
              <>
                <div className="admin-stat-grid">
                  <StatCard icon="👥" label="Total Users" value={kpi.total_users?.toLocaleString()} sub={`+${kpi.new_today || 0} today`} />
                  <StatCard icon="💬" label="Total Messages" value={kpi.total_messages?.toLocaleString()} sub={`+${kpi.msg_today || 0} today`} />
                  <StatCard icon="🔑" label="Users w/ Access" value={kpi.users_with_access} />
                </div>

                <div className="admin-chart-grid">
                  <div className="admin-card">
                    <div className="admin-card-title">📈 Messages — Last 30 Days</div>
                    <ResponsiveContainer width="100%" height={260}>
                      <LineChart data={dash.daily || []}>
                        <CartesianGrid strokeDasharray="3 3" stroke="#f1f3f4" />
                        <XAxis dataKey="dt" tick={{ fontSize: 10 }} tickFormatter={(d) => d?.slice(5)} />
                        <YAxis tick={{ fontSize: 10 }} />
                        <Tooltip />
                        <Line type="monotone" dataKey="cnt" name="Messages" stroke="#1a73e8" strokeWidth={2.5} dot={false} />
                      </LineChart>
                    </ResponsiveContainer>
                  </div>

                  <div className="admin-card">
                    <div className="admin-card-title">🕐 Today's Hourly Traffic</div>
                    <ResponsiveContainer width="100%" height={260}>
                      <BarChart data={dash.hourly || []}>
                        <CartesianGrid strokeDasharray="3 3" stroke="#f1f3f4" />
                        <XAxis dataKey="hr" tickFormatter={(h) => `${h}h`} tick={{ fontSize: 10 }} />
                        <YAxis tick={{ fontSize: 10 }} />
                        <Tooltip labelFormatter={(h) => `${h}:00 hrs`} />
                        <Bar dataKey="cnt" name="Messages" fill="#12a594" radius={[6, 6, 0, 0]} />
                      </BarChart>
                    </ResponsiveContainer>
                  </div>

                  <div className="admin-card">
                    <div className="admin-card-title">🧠 Top Intents</div>
                    <ResponsiveContainer width="100%" height={260}>
                      <BarChart data={(dash.top_intents || []).slice(0, 8)} layout="vertical">
                        <CartesianGrid strokeDasharray="3 3" stroke="#f1f3f4" />
                        <XAxis type="number" tick={{ fontSize: 10 }} />
                        <YAxis type="category" dataKey="intent" tick={{ fontSize: 10 }} width={130} />
                        <Tooltip />
                        <Bar dataKey="cnt" name="Count" fill="#8b5cf6" radius={[0, 6, 6, 0]} />
                      </BarChart>
                    </ResponsiveContainer>
                  </div>
                </div>
              </>
            )}
          </>
        )}

        {tab === 'logs' && (
          <>
            <div className="admin-card">
              <div className="admin-toolbar">
                <input
                  type="date"
                  value={logFilters.start_date}
                  onChange={(e) => {
                    setLogFilters((p) => ({ ...p, start_date: e.target.value }));
                    setLogPage(1);
                  }}
                />
                <input
                  type="date"
                  value={logFilters.end_date}
                  onChange={(e) => {
                    setLogFilters((p) => ({ ...p, end_date: e.target.value }));
                    setLogPage(1);
                  }}
                />
                <input
                  placeholder="Filter by intent…"
                  value={logFilters.intent}
                  onChange={(e) => {
                    setLogFilters((p) => ({ ...p, intent: e.target.value }));
                    setLogPage(1);
                  }}
                />
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => {
                    setLogFilters({ intent: '', start_date: '', end_date: '' });
                    setLogPage(1);
                  }}
                >
                  Clear
                </button>
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => exportCSV('messages')}
                  disabled={exporting}
                >
                  {exporting ? 'Exporting...' : 'Export CSV'}
                </button>
              </div>
            </div>

            <div className="admin-card">
              <div className="admin-card-title">Message Logs ({logTotal.toLocaleString()} total)</div>
              <div className="admin-table-wrap">
                <table className="admin-table">
                  <thead>
                    <tr>
                      <th>User</th>
                      <th>Acct No.</th>
                      <th>Sender</th>
                      <th>Message</th>
                      <th>Intent</th>
                      <th>Conf.</th>
                      <th>Time</th>
                      <th>Flag</th>
                    </tr>
                  </thead>
                  <tbody>
                    {logs.length === 0 ? (
                      <tr>
                        <td colSpan="8" className="admin-empty-cell">No logs found</td>
                      </tr>
                    ) : (
                      logs.map((row) => (
                        <tr key={row.id}>
                          <td>{row.full_name || '—'}</td>
                          <td>{row.account_number || '—'}</td>
                          <td>
                            <Badge type={row.sender === 'user' ? 'blue' : 'green'}>
                              {row.sender}
                            </Badge>
                          </td>
                          <td className="admin-td-wrap">{row.message_text || '—'}</td>
                          <td>{row.intent || '—'}</td>
                          <td>{row.confidence != null ? Number(row.confidence).toFixed(2) : '—'}</td>
                          <td>{row.created_at ? new Date(row.created_at).toLocaleString() : '—'}</td>
                          <td>
                            <button
                              className="btn btn-secondary btn-sm"
                              onClick={() => flagMsg(row.id)}
                              disabled={!canEdit}
                              title={!canEdit ? 'View-only access' : 'Toggle flag'}
                            >
                              🚩
                            </button>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}

        {adminUser && tab === 'users' && (
          <>
            <div className="admin-card">
              <div className="admin-toolbar">
                <input
                  placeholder="Search users…"
                  value={userSearch}
                  onChange={(e) => {
                    setUserSearch(e.target.value);
                    setUserPage(1);
                  }}
                />
                <button
                  className="btn btn-secondary btn-sm"
                  onClick={() => exportCSV('users')}
                  disabled={exporting}
                >
                  {exporting ? 'Exporting...' : 'Export Users'}
                </button>
              </div>
            </div>

            <div className="admin-card">
              <div className="admin-card-title">User Management ({userTotal.toLocaleString()} total)</div>
              <div className="admin-table-wrap">
                <table className="admin-table">
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Email</th>
                      <th>Account No.</th>
                      <th>Role</th>
                      <th>Access</th>
                      <th>Status</th>
                      <th>Change Role</th>
                      <th>Change Access</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.length === 0 ? (
                      <tr>
                        <td colSpan="9" className="admin-empty-cell">No users found</td>
                      </tr>
                    ) : (
                      users.map((u) => (
                        <tr key={u.id}>
                          <td>{u.full_name}</td>
                          <td>{u.email}</td>
                          <td>{u.account_number}</td>
                          <td>
                            <Badge
                              type={
                                u.role === 'admin'
                                  ? 'blue'
                                  : u.role === 'staff'
                                  ? 'green'
                                  : 'purple'
                              }
                            >
                              {u.role}
                            </Badge>
                          </td>
                          <td>
                            <Badge type="green">{u.dashboard_access || 'none'}</Badge>
                          </td>
                          <td>
                            <Badge type={u.is_active ? 'green' : 'red'}>
                              {u.is_active ? 'Active' : 'Disabled'}
                            </Badge>
                          </td>
                          <td>
                            <select
                              defaultValue={u.role}
                              onChange={(e) => setRole(u.id, e.target.value)}
                              disabled={saving[u.id + '_role']}
                            >
                              <option value="admin">Admin</option>
                              <option value="customer">Customer</option>
                              <option value="staff">Staff</option>
                            </select>
                          </td>
                          <td>
                            <select
                              defaultValue={u.dashboard_access || 'none'}
                              onChange={(e) => setAccess(u.id, e.target.value)}
                              disabled={saving[u.id + '_acc']}
                            >
                              <option value="none">none</option>
                              <option value="view">view</option>
                              <option value="edit">edit</option>
                            </select>
                          </td>
                          <td>
                            <button className="btn btn-secondary btn-sm" onClick={() => toggleUser(u.id)}>
                              {u.is_active ? 'Disable' : 'Enable'}
                            </button>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}

        {tab === 'access' && (
          <div className="admin-card">
            <div className="admin-card-title">Access Control Log</div>
            <div className="admin-table-wrap">
              <table className="admin-table">
                <thead>
                  <tr>
                    <th>User</th>
                    <th>Admin</th>
                    <th>Access</th>
                    <th>Granted At</th>
                  </tr>
                </thead>
                <tbody>
                  {accessLog.length === 0 ? (
                    <tr>
                      <td colSpan="4" className="admin-empty-cell">No access log found</td>
                    </tr>
                  ) : (
                    accessLog.map((row, idx) => (
                      <tr key={idx}>
                        <td>{row.user_name || '—'}</td>
                        <td>{row.admin_name || '—'}</td>
                        <td>{row.access_level || '—'}</td>
                        <td>{row.granted_at ? new Date(row.granted_at).toLocaleString() : '—'}</td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {tab === 'intent_manager' && (
          <>
            <div className="admin-card">
              <div className="admin-card-title">
                {editingIntent ? 'Edit Intent' : 'Create New Intent'}
                {!canEdit && <span style={{ marginLeft: 12, fontSize: 13, color: '#888' }}>(View only)</span>}
              </div>

              <div className="admin-form-grid">
                <input
                  placeholder="Intent name"
                  value={newIntent}
                  onChange={(e) => setNewIntent(e.target.value)}
                  disabled={!canEdit}
                />
                <textarea
                  rows="8"
                  placeholder="Examples (one per line)"
                  value={examples}
                  onChange={(e) => setExamples(e.target.value)}
                  disabled={!canEdit}
                />
                <textarea
                  rows="5"
                  placeholder="Bot response (optional)"
                  value={responseText}
                  onChange={(e) => setResponseText(e.target.value)}
                  disabled={!canEdit}
                />
              </div>

              <div className="admin-actions-row">
                {editingIntent ? (
                  <>
                    <button className="btn btn-primary btn-sm" onClick={updateIntent} disabled={!canEdit}>
                      Update Intent
                    </button>
                    <button
                      className="btn btn-secondary btn-sm"
                      onClick={resetIntentForm}
                    >
                      Cancel
                    </button>
                  </>
                ) : (
                  <button className="btn btn-primary btn-sm" onClick={addIntent} disabled={!canEdit}>
                    Add Intent
                  </button>
                )}

                <button className="btn btn-secondary btn-sm" onClick={trainModel} disabled={!canEdit}>
                  Train Model
                </button>
              </div>
            </div>

            <div className="admin-card">
              <div className="admin-card-title">Existing Intents</div>
              <div className="admin-table-wrap">
                <table className="admin-table">
                  <thead>
                    <tr>
                      <th>Intent</th>
                      <th>Examples</th>
                      <th>Response</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {intentList.length === 0 ? (
                      <tr>
                        <td colSpan="4" className="admin-empty-cell">No intents found</td>
                      </tr>
                    ) : (
                      intentList.map((item, idx) => (
                        <tr key={idx}>
                          <td>{item.intent}</td>
                          <td className="admin-td-wrap">
                            <pre className="intent-examples">{item.examples}</pre>
                          </td>
                          <td className="admin-td-wrap">
                            <pre className="intent-examples">{item.response || '—'}</pre>
                          </td>
                          <td>
                            <div className="admin-inline-actions">
                              <button
                                className="btn btn-secondary btn-sm"
                                onClick={() => startEditIntent(item)}
                                disabled={!canEdit}
                              >
                                Edit
                              </button>
                              <button
                                className="btn btn-secondary btn-sm"
                                onClick={() => deleteIntent(item.intent)}
                                disabled={!canEdit}
                              >
                                Delete
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}