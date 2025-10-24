import { Post } from '../types';

interface PostCardProps {
  post: Post;
  onLike?: (postId: number) => void;
  onComment?: (postId: number) => void;
}

export default function PostCard({ post, onLike, onComment }: PostCardProps) {
  return (
    <div className="bg-white shadow rounded-lg p-6 hover:shadow-lg transition-shadow">
      <div className="flex items-start space-x-4">
        <div className="flex-shrink-0">
          {post.user.profile_picture_url ? (
            <img
              src={post.user.profile_picture_url}
              alt={post.user.username}
              className="h-12 w-12 rounded-full object-cover"
            />
          ) : (
            <div className="h-12 w-12 rounded-full bg-indigo-600 flex items-center justify-center text-white font-bold text-lg">
              {post.user.username.charAt(0).toUpperCase()}
            </div>
          )}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center space-x-2">
            <span className="font-semibold text-gray-900 hover:underline cursor-pointer">
              {post.user.full_name}
            </span>
            <span className="text-gray-500 text-sm">@{post.user.username}</span>
            <span className="text-gray-400">·</span>
            <span className="text-gray-500 text-sm">
              {new Date(post.created_at).toLocaleDateString()}
            </span>
          </div>
          
          <p className="mt-3 text-gray-900 whitespace-pre-wrap">{post.content}</p>
          
          {post.tags.length > 0 && (
            <div className="mt-3 flex flex-wrap gap-2">
              {post.tags.map((tag, index) => (
                <span
                  key={index}
                  className="text-sm text-indigo-600 hover:text-indigo-800 cursor-pointer font-medium"
                >
                  #{tag}
                </span>
              ))}
            </div>
          )}
          
          <div className="mt-4 flex items-center space-x-8 text-gray-500 text-sm">
            <button
              onClick={() => onComment?.(post.id)}
              className="flex items-center space-x-2 hover:text-indigo-600 transition-colors"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
              </svg>
              <span>{post.comments_count}</span>
            </button>
            
            <button
              onClick={() => onLike?.(post.id)}
              className={`flex items-center space-x-2 hover:text-red-600 transition-colors ${
                post.liked_by_current_user ? 'text-red-600' : ''
              }`}
            >
              <svg 
                className="w-5 h-5" 
                fill={post.liked_by_current_user ? 'currentColor' : 'none'} 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
              </svg>
              <span>{post.likes_count}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

