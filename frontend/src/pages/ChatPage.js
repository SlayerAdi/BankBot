import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import toast from 'react-hot-toast';
import { useAuth } from '../context/AuthContext';

const PROMPTS = [
  'Check balance',
  'Transactions',
  'Transfer funds',
  'My cards',
  'Loan details',
  'Exchange rates',
  'Find ATM',
  'Help',
];

export default function ChatPage() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const [active, setActive] = useState(null);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [sending, setSending] = useState(false);
  const [typing, setTyping] = useState(false);

  const endRef = useRef(null);
  const taRef = useRef(null);

  useEffect(() => {
    createSession();
  }, []);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, sending, typing]);

  const createSession = async () => {
    try {
      const { data } = await axios.post('/api/chat/sessions', {
        title: 'New Conversation',
      });
      setActive(data.session);
      setMessages([]);
    } catch {
      toast.error('Failed to create session');
    }
  };

  const sendMessage = async (text = input) => {
    const msg = text.trim();
    if (!msg || sending || !active) return;

    setInput('');
    setSending(true);

    const tmpId = `tmp-${Date.now()}`;

    setMessages((prev) => [
      ...prev,
      {
        id: tmpId,
        sender: 'user',
        message_text: msg,
        created_at: new Date().toISOString(),
      },
    ]);

    try {
      setTyping(true);

      const { data } = await axios.post(`/api/chat/sessions/${active.id}/messages`, {
        message: msg,
      });

      setTimeout(() => {
        setMessages((prev) => [
          ...prev.filter((m) => m.id !== tmpId),
          data.user_message,
          data.bot_message,
        ]);
        setTyping(false);
      }, 700);
    } catch {
      setTyping(false);
      setMessages((prev) => prev.filter((m) => m.id !== tmpId));
      toast.error('Failed to send message');
    } finally {
      setSending(false);
      taRef.current?.focus();
    }
  };

  const giveFeedback = async (msgId, rating) => {
    try {
      await axios.post(`/api/chat/messages/${msgId}/feedback`, { rating });
      setMessages((prev) =>
        prev.map((m) => (m.id === msgId ? { ...m, _fb: rating } : m))
      );
    } catch {}
  };

  const doLogout = () => {
    logout();
    navigate('/login');
    toast.success('Signed out');
  };

  const goDashboard = () => {
    navigate('/dashboard');
  };

  const initials =
    user?.full_name
      ?.split(' ')
      .map((w) => w[0])
      .join('')
      .substring(0, 2)
      .toUpperCase() || '?';

  return (
    <div className="simple-chat-layout">
      <div className="simple-chat-topbar">
        <div className="top-left">
          <div className="bot-avatar">🤖</div>
          <div>
            <div className="bot-name">Aditya Bank Assistant</div>
            <div className="bot-status">
              <span className="live-dot"></span>
              Online · Real-time Support
            </div>
          </div>
        </div>

        <div className="top-right">
          {user?.role === 'admin' && (
            <button className="btn btn-secondary btn-sm" onClick={goDashboard}>
              Dashboard
            </button>
          )}
          <button className="btn btn-ghost btn-sm" onClick={createSession}>
            New Chat
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

      <div className="simple-chat-body">
        {messages.length === 0 && (
          <div className="empty-chat">
            <div className="empty-icon">🤖</div>
            <h3>Hello, {user?.full_name?.split(' ')[0]}!</h3>
            <p>I'm Aditya Bank Bot. How can I help you today?</p>

            <div className="quick-grid">
              {PROMPTS.map((p) => (
                <button key={p} className="qchip" onClick={() => sendMessage(p)}>
                  {p}
                </button>
              ))}
            </div>
          </div>
        )}

        {messages.map((m) => (
          <div key={m.id} className={`msg-row ${m.sender === 'user' ? 'user' : ''}`}>
            <div className={`msg-face ${m.sender === 'user' ? 'usr' : 'bot'}`}>
              {m.sender === 'user' ? initials : '🤖'}
            </div>

            <div>
              <div className={`bubble ${m.sender === 'user' ? 'usr' : 'bot'}`}>
                {m.message_text}
              </div>

              {/* {m.sender === 'bot' && (
                <div className="msg-actions">
                  <button
                    className={m._fb === 'positive' ? 'active' : ''}
                    onClick={() => giveFeedback(m.id, 'positive')}
                  >
                    👍
                  </button>
                  <button
                    className={m._fb === 'negative' ? 'active' : ''}
                    onClick={() => giveFeedback(m.id, 'negative')}
                  >
                    👎
                  </button>
                </div>
              )} */}
            </div>
          </div>
        ))}

        {typing && (
          <div className="msg-row">
            <div className="msg-face bot">🤖</div>
            <div className="typing-bubble">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        )}

        <div ref={endRef} />
      </div>

      <div className="simple-chat-inputbar">
        <div className="input-wrap">
          <textarea
            ref={taRef}
            rows={1}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Type your message..."
            onKeyDown={(e) => {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
              }
            }}
          />
          <button className="send-btn" onClick={() => sendMessage()} disabled={sending}>
            {sending ? '...' : '➤'}
          </button>
        </div>
      </div>
    </div>
  );
}