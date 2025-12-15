import { createContext, useState, useContext, useEffect } from 'react';
import { authAPI } from '../services/api';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedUser = localStorage.getItem('currentUser');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
    setLoading(false);
  }, []);

  const login = async (credentials) => {
    const response = await authAPI.login(credentials);
    const userData = response.data.data;
    setUser(userData);
    localStorage.setItem('currentUser', JSON.stringify(userData));
    localStorage.setItem('authToken', response.headers.authorization);
    return userData;
  };

  const signup = async (userData) => {
    const response = await authAPI.signup(userData);
    const user = response.data.data;
    setUser(user);
    localStorage.setItem('currentUser', JSON.stringify(user));
    localStorage.setItem('authToken', response.headers.authorization);
    return user;
  };

  const logout = async () => {
    try {
      await authAPI.logout();
    } finally {
      setUser(null);
      localStorage.removeItem('currentUser');
      localStorage.removeItem('authToken');
    }
  };

  return (
    <AuthContext.Provider value={{ user, login, signup, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

