import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

export default function Navbar() {
  const { user, logout } = useAuth();

  return (
    <nav className="bg-white shadow-md border-b border-gray-200 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <Link to="/feed" className="flex items-center">
            <span className="text-2xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
              AIPosts
            </span>
          </Link>
          
          <div className="hidden md:flex items-center space-x-1">
            <Link
              to="/feed"
              className="px-4 py-2 rounded-lg text-gray-700 hover:bg-blue-50 hover:text-blue-600 transition-colors font-medium"
            >
              Feed
            </Link>
            <Link
              to="/search"
              className="px-4 py-2 rounded-lg text-gray-700 hover:bg-blue-50 hover:text-blue-600 transition-colors font-medium"
            >
              Search
            </Link>
            <Link
              to="/notifications"
              className="px-4 py-2 rounded-lg text-gray-700 hover:bg-blue-50 hover:text-blue-600 transition-colors font-medium"
            >
              Notifications
            </Link>
            <Link
              to={`/profile/${user.id}`}
              className="px-4 py-2 rounded-lg text-gray-700 hover:bg-blue-50 hover:text-blue-600 transition-colors font-medium"
            >
              Profile
            </Link>
            <Link
              to="/settings"
              className="px-4 py-2 rounded-lg text-gray-700 hover:bg-blue-50 hover:text-blue-600 transition-colors font-medium"
            >
              Settings
            </Link>
          </div>

          <div className="flex items-center space-x-3">
            <span className="text-sm text-gray-600 hidden sm:block">@{user.username}</span>
            <button
              onClick={logout}
              className="px-4 py-2 rounded-lg text-red-600 hover:bg-red-50 transition-colors font-medium"
            >
              Logout
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}

