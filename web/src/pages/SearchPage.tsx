import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import api from '../lib/api';
import type { User, Post } from '../types';
import Navbar from '../components/Navbar';
import PostCard from '../components/PostCard';

type SearchType = 'users' | 'posts';

export default function SearchPage() {
  const [searchType, setSearchType] = useState<SearchType>('posts');
  const [query, setQuery] = useState('');
  const [debouncedQuery, setDebouncedQuery] = useState('');
  const [sortBy, setSortBy] = useState('newest');

  // Debounce search
  useState(() => {
    const timer = setTimeout(() => {
      setDebouncedQuery(query);
    }, 500);
    return () => clearTimeout(timer);
  });

  const { data: usersData, isLoading: usersLoading } = useQuery({
    queryKey: ['search-users', debouncedQuery],
    queryFn: async () => {
      if (!debouncedQuery) return { users: [] };
      const response = await api.get<{ users: User[] }>(`/search/users?q=${debouncedQuery}`);
      return response.data;
    },
    enabled: searchType === 'users' && debouncedQuery.length > 0,
  });

  const { data: postsData, isLoading: postsLoading } = useQuery({
    queryKey: ['search-posts', debouncedQuery, sortBy],
    queryFn: async () => {
      if (!debouncedQuery) return { posts: [] };
      const response = await api.get<{ posts: Post[] }>(
        `/search/posts?q=${debouncedQuery}&sort=${sortBy}`
      );
      return response.data;
    },
    enabled: searchType === 'posts' && debouncedQuery.length > 0,
  });

  const users = usersData?.users || [];
  const posts = postsData?.posts || [];
  const isLoading = searchType === 'users' ? usersLoading : postsLoading;

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <main className="max-w-5xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        {/* Search Header */}
        <div className="mb-6">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">Buscar</h1>
          
          {/* Search Input */}
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="block w-full pl-10 pr-3 py-3 border border-gray-300 rounded-lg leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              placeholder={`Buscar ${searchType === 'users' ? 'usuarios' : 'posts'}...`}
            />
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-lg shadow mb-6">
          <div className="border-b border-gray-200">
            <nav className="flex -mb-px">
              <button
                onClick={() => setSearchType('posts')}
                className={`flex-1 py-4 px-6 text-center font-medium border-b-2 transition-colors ${
                  searchType === 'posts'
                    ? 'border-indigo-600 text-indigo-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                Posts
              </button>
              <button
                onClick={() => setSearchType('users')}
                className={`flex-1 py-4 px-6 text-center font-medium border-b-2 transition-colors ${
                  searchType === 'users'
                    ? 'border-indigo-600 text-indigo-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                Usuarios
              </button>
            </nav>
          </div>

          {/* Sort (only for posts) */}
          {searchType === 'posts' && (
            <div className="px-6 py-3 border-b border-gray-200">
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="text-sm border-gray-300 rounded-md focus:ring-indigo-500 focus:border-indigo-500"
              >
                <option value="newest">Más recientes</option>
                <option value="oldest">Más antiguos</option>
                <option value="most_liked">Más gustados</option>
                <option value="most_commented">Más comentados</option>
              </select>
            </div>
          )}
        </div>

        {/* Results */}
        {!query ? (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <svg
              className="mx-auto h-12 w-12 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
            <h3 className="mt-2 text-sm font-medium text-gray-900">Busca algo</h3>
            <p className="mt-1 text-sm text-gray-500">
              Escribe para buscar {searchType === 'users' ? 'usuarios' : 'posts'}
            </p>
          </div>
        ) : isLoading ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
            <p className="text-gray-600 mt-4">Buscando...</p>
          </div>
        ) : searchType === 'users' ? (
          users.length > 0 ? (
            <div className="bg-white rounded-lg shadow divide-y divide-gray-200">
              {users.map((user) => (
                <Link
                  key={user.id}
                  to={`/profile/${user.username}`}
                  className="block hover:bg-gray-50 transition-colors"
                >
                  <div className="px-6 py-4 flex items-center space-x-4">
                    {user.profile_picture_url ? (
                      <img
                        src={user.profile_picture_url}
                        alt={user.username}
                        className="h-12 w-12 rounded-full object-cover"
                      />
                    ) : (
                      <div className="h-12 w-12 rounded-full bg-indigo-600 flex items-center justify-center text-white font-semibold">
                        {user.username.charAt(0).toUpperCase()}
                      </div>
                    )}
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {user.full_name}
                      </p>
                      <p className="text-sm text-gray-500 truncate">@{user.username}</p>
                      {user.bio && (
                        <p className="text-sm text-gray-600 truncate mt-1">{user.bio}</p>
                      )}
                    </div>
                    <div className="flex-shrink-0 text-sm text-gray-500">
                      <div>{user.followers_count || 0} seguidores</div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          ) : (
            <div className="bg-white rounded-lg shadow p-8 text-center">
              <p className="text-gray-600">No se encontraron usuarios</p>
            </div>
          )
        ) : posts.length > 0 ? (
          <div className="space-y-4">
            {posts.map((post) => (
              <PostCard key={post.id} post={post} />
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <p className="text-gray-600">No se encontraron posts</p>
          </div>
        )}
      </main>
    </div>
  );
}

