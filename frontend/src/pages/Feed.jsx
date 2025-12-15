import { useState, useEffect } from 'react';
import { feedAPI, postAPI } from '../services/api';
import { useAuth } from '../contexts/AuthContext';
import { Link } from 'react-router-dom';

export default function Feed() {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [newPost, setNewPost] = useState('');
  const [posting, setPosting] = useState(false);
  const { user } = useAuth();

  useEffect(() => {
    loadFeed();
  }, []);

  const loadFeed = async () => {
    try {
      const response = await feedAPI.getFeed();
      setPosts(response.data.feed);
    } catch (error) {
      console.error('Failed to load feed:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreatePost = async (e) => {
    e.preventDefault();
    if (!newPost.trim()) return;
    setPosting(true);
    try {
      await postAPI.createPost({ content: newPost });
      setNewPost('');
      loadFeed();
    } catch (error) {
      console.error('Failed to create post:', error);
    } finally {
      setPosting(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading your feed...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-6">
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Create Post Card */}
        <div className="bg-white rounded-xl shadow-md p-6 mb-6">
          <div className="flex items-center mb-4">
            <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center text-white font-bold">
              {user.username?.charAt(0).toUpperCase()}
            </div>
            <span className="ml-3 font-medium text-gray-900">@{user.username}</span>
          </div>
          <form onSubmit={handleCreatePost}>
            <textarea
              value={newPost}
              onChange={(e) => setNewPost(e.target.value)}
              placeholder="What's on your mind?"
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
              rows="3"
            />
            <div className="mt-3 flex justify-end">
              <button
                type="submit"
                disabled={posting || !newPost.trim()}
                className="px-6 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {posting ? 'Posting...' : 'Post'}
              </button>
            </div>
          </form>
        </div>

        {/* Feed */}
        <div className="space-y-4">
          {posts.length === 0 ? (
            <div className="bg-white rounded-xl shadow-md p-8 text-center">
              <p className="text-gray-500 text-lg">No posts yet. Follow some users to see their posts!</p>
            </div>
          ) : (
            posts.map(post => (
              <div key={post.id} className="bg-white rounded-xl shadow-md hover:shadow-lg transition-shadow">
                <div className="p-6">
                  {/* Post Header */}
                  <div className="flex items-start">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center text-white font-bold text-lg flex-shrink-0">
                      {post.user.username?.charAt(0).toUpperCase()}
                    </div>
                    <div className="ml-3 flex-1">
                      <Link
                        to={`/profile/${post.user.id}`}
                        className="font-bold text-gray-900 hover:text-blue-600"
                      >
                        {post.user.first_name && post.user.last_name
                          ? `${post.user.first_name} ${post.user.last_name}`
                          : post.user.username}
                      </Link>
                      <Link
                        to={`/profile/${post.user.id}`}
                        className="block text-sm text-gray-500 hover:text-blue-600"
                      >
                        @{post.user.username}
                      </Link>
                    </div>
                  </div>

                  {/* Post Content */}
                  <div className="mt-4">
                    <p className="text-gray-800 whitespace-pre-wrap">{post.content}</p>
                    {post.tags && post.tags.length > 0 && (
                      <div className="mt-3 flex flex-wrap gap-2">
                        {post.tags.map((tag, index) => (
                          <span
                            key={index}
                            className="px-3 py-1 bg-blue-50 text-blue-600 rounded-full text-sm font-medium"
                          >
                            #{tag}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>

                  {/* Post Actions */}
                  <div className="mt-4 flex items-center gap-6 pt-3 border-t border-gray-100">
                    <button className="flex items-center gap-2 text-gray-500 hover:text-red-500 transition-colors">
                      <span className="text-lg">❤️</span>
                      <span className="text-sm font-medium">{post.likes_count}</span>
                    </button>
                    <Link
                      to={`/posts/${post.id}`}
                      className="flex items-center gap-2 text-gray-500 hover:text-blue-500 transition-colors"
                    >
                      <span className="text-lg">💬</span>
                      <span className="text-sm font-medium">{post.comments_count}</span>
                    </Link>
                    <button className="flex items-center gap-2 text-gray-500 hover:text-green-500 transition-colors">
                      <span className="text-lg">🔁</span>
                      <span className="text-sm font-medium">{post.reposts_count}</span>
                    </button>
                  </div>
                </div>

                {/* Reposted By */}
                {post.reposted_by && post.reposted_by.length > 0 && (
                  <div className="px-6 py-2 bg-gray-50 border-t border-gray-100 text-sm text-gray-600">
                    🔁 Reposted by {post.reposted_by.map(r => r.username).join(', ')}
                  </div>
                )}
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

