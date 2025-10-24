import { useState } from 'react';
import { useParams } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../lib/api';
import type { User, Post } from '../types';
import Navbar from '../components/Navbar';
import PostCard from '../components/PostCard';
import { useAuthStore } from '../stores/authStore';

export default function ProfilePage() {
  const { username } = useParams<{ username: string }>();
  const currentUser = useAuthStore((state) => state.user);
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState<'posts' | 'likes'>('posts');

  const { data: user, isLoading: userLoading } = useQuery({
    queryKey: ['user', username],
    queryFn: async () => {
      const response = await api.get<User>(`/users/${username}`);
      return response.data;
    },
    enabled: !!username,
  });

  const { data: posts, isLoading: postsLoading } = useQuery({
    queryKey: ['user-posts', user?.id, activeTab],
    queryFn: async () => {
      if (!user?.id) return [];
      const endpoint = activeTab === 'posts' 
        ? `/posts?user_id=${user.id}`
        : `/me/likes`;
      const response = await api.get<{ posts: Post[] }>(endpoint);
      return response.data.posts;
    },
    enabled: !!user?.id && activeTab === 'posts',
  });

  const followMutation = useMutation({
    mutationFn: async (userId: number) => {
      await api.post(`/users/${userId}/follow`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user', username] });
    },
  });

  const unfollowMutation = useMutation({
    mutationFn: async (userId: number) => {
      await api.delete(`/users/${userId}/unfollow`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['user', username] });
    },
  });

  const isOwnProfile = currentUser?.username === username;
  const isFollowing = user?.is_following;

  const handleFollowToggle = () => {
    if (!user) return;
    if (isFollowing) {
      unfollowMutation.mutate(user.id);
    } else {
      followMutation.mutate(user.id);
    }
  };

  if (userLoading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <Navbar />
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
        </div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-gray-50">
        <Navbar />
        <div className="max-w-3xl mx-auto py-8 px-4">
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <h2 className="text-2xl font-bold text-gray-900">Usuario no encontrado</h2>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />

      <main className="max-w-5xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        {/* Profile Header */}
        <div className="bg-white rounded-lg shadow overflow-hidden mb-6">
          {/* Cover Image */}
          <div className="h-48 bg-gradient-to-r from-indigo-500 to-purple-600"></div>
          
          {/* Profile Info */}
          <div className="px-6 pb-6">
            <div className="flex items-start justify-between -mt-16">
              <div className="flex items-end space-x-5">
                {user.profile_picture_url ? (
                  <img
                    src={user.profile_picture_url}
                    alt={user.username}
                    className="h-32 w-32 rounded-full border-4 border-white object-cover"
                  />
                ) : (
                  <div className="h-32 w-32 rounded-full border-4 border-white bg-indigo-600 flex items-center justify-center">
                    <span className="text-5xl font-bold text-white">
                      {user.username.charAt(0).toUpperCase()}
                    </span>
                  </div>
                )}
              </div>
              
              {!isOwnProfile && (
                <button
                  onClick={handleFollowToggle}
                  disabled={followMutation.isPending || unfollowMutation.isPending}
                  className={`mt-4 px-6 py-2 rounded-lg font-medium transition-colors ${
                    isFollowing
                      ? 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                      : 'bg-indigo-600 text-white hover:bg-indigo-700'
                  }`}
                >
                  {isFollowing ? 'Siguiendo' : 'Seguir'}
                </button>
              )}
            </div>

            <div className="mt-6">
              <h1 className="text-2xl font-bold text-gray-900">{user.full_name}</h1>
              <p className="text-gray-600">@{user.username}</p>
              
              {user.bio && (
                <p className="mt-3 text-gray-700">{user.bio}</p>
              )}
              
              <div className="mt-4 flex items-center space-x-6 text-sm text-gray-600">
                {user.location && (
                  <div className="flex items-center space-x-1">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    <span>{user.location}</span>
                  </div>
                )}
                {user.website && (
                  <a
                    href={user.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center space-x-1 hover:text-indigo-600"
                  >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
                    </svg>
                    <span>{user.website}</span>
                  </a>
                )}
              </div>

              <div className="mt-4 flex space-x-6 text-sm">
                <div>
                  <span className="font-bold text-gray-900">{user.following_count || 0}</span>
                  <span className="text-gray-600"> Siguiendo</span>
                </div>
                <div>
                  <span className="font-bold text-gray-900">{user.followers_count || 0}</span>
                  <span className="text-gray-600"> Seguidores</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-lg shadow mb-6">
          <div className="border-b border-gray-200">
            <nav className="flex -mb-px">
              <button
                onClick={() => setActiveTab('posts')}
                className={`flex-1 py-4 px-6 text-center font-medium border-b-2 transition-colors ${
                  activeTab === 'posts'
                    ? 'border-indigo-600 text-indigo-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                Posts
              </button>
              <button
                onClick={() => setActiveTab('likes')}
                className={`flex-1 py-4 px-6 text-center font-medium border-b-2 transition-colors ${
                  activeTab === 'likes'
                    ? 'border-indigo-600 text-indigo-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                Me gusta
              </button>
            </nav>
          </div>
        </div>

        {/* Posts Grid */}
        {postsLoading ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
          </div>
        ) : posts && posts.length > 0 ? (
          <div className="space-y-4">
            {posts.map((post) => (
              <PostCard key={post.id} post={post} />
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-lg shadow p-8 text-center">
            <p className="text-gray-600">
              {activeTab === 'posts' ? 'No hay posts todavía' : 'No hay posts con me gusta'}
            </p>
          </div>
        )}
      </main>
    </div>
  );
}

