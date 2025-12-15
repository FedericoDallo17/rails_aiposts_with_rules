import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

const api = axios.create({
  baseURL: `${API_BASE_URL}/api/v1`,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle 401 errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      localStorage.removeItem('currentUser');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  signup: (userData) => api.post('/users', { user: userData }),
  login: (credentials) => api.post('/users/sign_in', { user: credentials }),
  logout: () => api.delete('/users/sign_out'),
  resetPassword: (email) => api.post('/users/password', { user: { email } }),
  updatePassword: (passwordData) => api.put('/users/password', { user: passwordData }),
};

// User API
export const userAPI = {
  getUser: (id) => api.get(`/users/${id}`),
  updateUser: (id, userData) => api.put(`/users/${id}`, { user: userData }),
  deleteUser: (id) => api.delete(`/users/${id}`),
  getFollowers: (id, params) => api.get(`/users/${id}/followers`, { params }),
  getFollowing: (id, params) => api.get(`/users/${id}/following`, { params }),
  getLikedPosts: (id, params) => api.get(`/users/${id}/liked_posts`, { params }),
  getCommentedPosts: (id, params) => api.get(`/users/${id}/commented_posts`, { params }),
};

// Post API
export const postAPI = {
  getPosts: (params) => api.get('/posts', { params }),
  getPost: (id) => api.get(`/posts/${id}`),
  createPost: (postData) => api.post('/posts', { post: postData }),
  updatePost: (id, postData) => api.put(`/posts/${id}`, { post: postData }),
  deletePost: (id) => api.delete(`/posts/${id}`),
  likePost: (id) => api.post(`/posts/${id}/like`),
  unlikePost: (id) => api.delete(`/posts/${id}/unlike`),
  repost: (id) => api.post(`/posts/${id}/repost`),
  unrepost: (id) => api.delete(`/posts/${id}/unrepost`),
  getReposts: (id, params) => api.get(`/posts/${id}/reposts`, { params }),
};

// Comment API
export const commentAPI = {
  getComments: (postId, params) => api.get(`/posts/${postId}/comments`, { params }),
  getComment: (id) => api.get(`/comments/${id}`),
  createComment: (postId, commentData) => api.post(`/posts/${postId}/comments`, { comment: commentData }),
  updateComment: (id, commentData) => api.put(`/comments/${id}`, { comment: commentData }),
  deleteComment: (id) => api.delete(`/comments/${id}`),
  likeComment: (id) => api.post(`/comments/${id}/like`),
  unlikeComment: (id) => api.delete(`/comments/${id}/unlike`),
};

// Follow API
export const followAPI = {
  follow: (userId) => api.post(`/follow/${userId}`),
  unfollow: (userId) => api.delete(`/unfollow/${userId}`),
};

// Feed API
export const feedAPI = {
  getFeed: (params) => api.get('/feed', { params }),
};

// Search API
export const searchAPI = {
  searchUsers: (params) => api.get('/search/users', { params }),
  searchPosts: (params) => api.get('/search/posts', { params }),
};

// Notification API
export const notificationAPI = {
  getNotifications: (params) => api.get('/notifications', { params }),
  markAsRead: (id) => api.patch(`/notifications/${id}/mark_as_read`),
  markAsUnread: (id) => api.patch(`/notifications/${id}/mark_as_unread`),
};

export default api;

