import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuthStore } from '../stores/authStore';
import CreatePostModal from './CreatePostModal';

export default function Navbar() {
  const user = useAuthStore((state) => state.user);
  const logout = useAuthStore((state) => state.logout);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);

  return (
    <>
      <nav className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center space-x-8">
              <Link to="/" className="flex items-center">
                <span className="text-2xl font-bold text-indigo-600">AIPosts</span>
              </Link>
              
              {user && (
                <div className="hidden md:flex space-x-6">
                  <Link
                    to="/"
                    className="text-gray-700 hover:text-indigo-600 px-3 py-2 text-sm font-medium transition-colors"
                  >
                    Feed
                  </Link>
                  <Link
                    to="/search"
                    className="text-gray-700 hover:text-indigo-600 px-3 py-2 text-sm font-medium transition-colors"
                  >
                    Buscar
                  </Link>
                  <Link
                    to="/notifications"
                    className="text-gray-700 hover:text-indigo-600 px-3 py-2 text-sm font-medium transition-colors"
                  >
                    Notificaciones
                  </Link>
                </div>
              )}
            </div>
            
            {user && (
              <div className="flex items-center space-x-4">
                <button
                  onClick={() => setIsCreateModalOpen(true)}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors"
                >
                  <svg className="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                  </svg>
                  Post
                </button>
                
                <Link
                  to={`/profile/${user.username}`}
                  className="flex items-center space-x-2 hover:bg-gray-50 px-3 py-2 rounded-lg transition-colors"
                >
                  {user.profile_picture_url ? (
                    <img
                      src={user.profile_picture_url}
                      alt={user.username}
                      className="h-8 w-8 rounded-full object-cover"
                    />
                  ) : (
                    <div className="h-8 w-8 rounded-full bg-indigo-600 flex items-center justify-center text-white font-semibold text-sm">
                      {user.username.charAt(0).toUpperCase()}
                    </div>
                  )}
                  <span className="text-sm font-medium text-gray-700 hidden lg:block">
                    {user.username}
                  </span>
                </Link>
                
                <button
                  onClick={logout}
                  className="text-sm text-gray-600 hover:text-gray-900 px-3 py-2 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  Salir
                </button>
              </div>
            )}
          </div>
        </div>
      </nav>

      <CreatePostModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
      />
    </>
  );
}

