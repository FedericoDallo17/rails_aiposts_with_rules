export interface User {
  id: number;
  email: string;
  username: string;
  first_name: string;
  last_name: string;
  full_name: string;
  bio?: string;
  website?: string;
  location?: string;
  profile_picture_url?: string;
  cover_picture_url?: string;
  followers_count: number;
  following_count: number;
  posts_count: number;
  is_following?: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface Post {
  id: number;
  content: string;
  tags: string[];
  likes_count: number;
  comments_count: number;
  created_at: string;
  updated_at: string;
  user: User;
  liked_by_current_user: boolean;
}

export interface Comment {
  id: number;
  content: string;
  created_at: string;
  updated_at: string;
  user: User;
  post_id: number;
}

export interface Notification {
  id: number;
  event_type: 'like' | 'comment' | 'follow' | 'mention';
  read_at: string | null;
  created_at: string;
  notifiable_type: string;
  notifiable_id: number;
  notifiable?: any;
  actor?: User;
}

