# AIPosts - Social Media Application

A complete social media platform built with Rails 8.0 API backend and React frontend, featuring posts, comments, likes, reposts, follows, notifications, feed, and search functionality.

## 🚀 Features

### User Authentication
- Sign up, sign in, sign out
- Password reset functionality
- Email and password changes
- Account deletion
- Secure token-based authentication with Devise

### Posts
- Create, edit, and delete posts
- Add tags to posts
- Like/unlike posts
- Repost functionality
- View post details with comments

### Comments
- Comment on posts
- Edit and delete own comments
- Like/unlike comments
- View comment likes count

### Social Features
- Follow/unfollow users
- View followers and following lists
- User feed with posts from followed users
- Mentions detection (@username)
- Reposts appear in feed with attribution

### Notifications
- Real-time notifications for:
  - New followers
  - Comments on posts
  - Likes on posts and comments
  - Mentions in posts
  - Reposts
- Mark notifications as read/unread

### Search
- Search users by name, username, email, location
- Search posts by content, author, tags, comments
- Multiple sorting options:
  - Newest/Oldest
  - Most liked
  - Most commented
  - Most recently commented
  - Most recently liked

### User Settings
- Update profile information
- Change profile and cover pictures
- Update bio, website, location
- Change email and password
- Delete account

## 🛠 Technology Stack

### Backend
- Ruby 3.4.4
- Rails 8.0 API mode
- PostgreSQL
- Devise for authentication
- JBuilder for JSON serialization
- Active Storage for file uploads
- RSpec + FactoryBot for testing
- RuboCop for code style
- Brakeman for security scanning
- Rswag for API documentation

### Frontend
- React 18
- Vite
- React Router for routing
- Axios for API requests
- TailwindCSS for styling
- Context API for state management

## 📋 Prerequisites

- Ruby 3.4.4
- Rails 8.0+
- PostgreSQL
- Node.js 18+ and npm

## 🔧 Backend Setup

### 1. Install Dependencies

```bash
cd backend
bundle install
```

### 2. Database Setup

Configure your database in `config/database.yml`, then run:

```bash
rails db:create
rails db:migrate
rails db:seed  # Optional: seed with sample data
```

### 3. Environment Variables

The backend uses Rails credentials for sensitive data. No additional environment variables are required for development.

### 4. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

### 5. API Documentation

Swagger documentation is available at `http://localhost:3000/api-docs` when the server is running.

## 🎨 Frontend Setup

### 1. Install Dependencies

```bash
cd frontend
npm install
```

### 2. Environment Variables

Create a `.env` file in the frontend directory:

```
VITE_API_BASE_URL=http://localhost:3000
```

### 3. Start Development Server

```bash
npm run dev
```

The frontend will be available at `http://localhost:5173`

### 4. Build for Production

```bash
npm run build
```

The build output will be in the `dist/` directory.

## 🧪 Running Tests

### Backend Tests

```bash
cd backend

# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with documentation format
bundle exec rspec --format documentation
```

### Frontend Tests

```bash
cd frontend

# Run tests
npm test

# Run with coverage
npm run test:coverage
```

### Code Quality

```bash
cd backend

# Run RuboCop
bundle exec rubocop

# Auto-fix RuboCop offenses
bundle exec rubocop -A

# Run Brakeman security scanner
bundle exec brakeman
```

## 📚 API Endpoints

### Authentication
- `POST /api/v1/users` - Sign up
- `POST /api/v1/users/sign_in` - Sign in
- `DELETE /api/v1/users/sign_out` - Sign out
- `POST /api/v1/users/password` - Request password reset
- `PUT /api/v1/users/password` - Update password

### Users
- `GET /api/v1/users/:id` - Get user profile
- `PUT /api/v1/users/:id` - Update user profile
- `DELETE /api/v1/users/:id` - Delete account
- `GET /api/v1/users/:id/followers` - Get followers
- `GET /api/v1/users/:id/following` - Get following
- `GET /api/v1/users/:id/liked_posts` - Get liked posts
- `GET /api/v1/users/:id/commented_posts` - Get commented posts

### Posts
- `GET /api/v1/posts` - List all posts
- `POST /api/v1/posts` - Create post
- `GET /api/v1/posts/:id` - Get post
- `PUT /api/v1/posts/:id` - Update post
- `DELETE /api/v1/posts/:id` - Delete post
- `POST /api/v1/posts/:id/like` - Like post
- `DELETE /api/v1/posts/:id/unlike` - Unlike post
- `POST /api/v1/posts/:id/repost` - Repost
- `DELETE /api/v1/posts/:id/unrepost` - Remove repost
- `GET /api/v1/posts/:id/reposts` - Get reposts

### Comments
- `GET /api/v1/posts/:post_id/comments` - List comments
- `POST /api/v1/posts/:post_id/comments` - Create comment
- `GET /api/v1/comments/:id` - Get comment
- `PUT /api/v1/comments/:id` - Update comment
- `DELETE /api/v1/comments/:id` - Delete comment
- `POST /api/v1/comments/:id/like` - Like comment
- `DELETE /api/v1/comments/:id/unlike` - Unlike comment

### Follows
- `POST /api/v1/follow/:id` - Follow user
- `DELETE /api/v1/unfollow/:id` - Unfollow user

### Feed
- `GET /api/v1/feed` - Get personalized feed

### Search
- `GET /api/v1/search/users` - Search users
- `GET /api/v1/search/posts` - Search posts

### Notifications
- `GET /api/v1/notifications` - List notifications
- `PATCH /api/v1/notifications/:id/mark_as_read` - Mark as read
- `PATCH /api/v1/notifications/:id/mark_as_unread` - Mark as unread

## 📊 Database Schema

### Users
- email, username, password_digest
- first_name, last_name
- bio, website, location
- profile_picture, cover_picture

### Posts
- content, tags
- belongs_to :user
- has_many :comments, :likes, :reposts

### Comments
- content
- belongs_to :user, :post
- has_many :likes

### Likes (polymorphic)
- belongs_to :user
- belongs_to :likeable (Post or Comment)

### Reposts
- belongs_to :user, :post

### Follows
- follower_id, followed_id

### Notifications
- message, notification_type, read_at
- belongs_to :user, :actor
- belongs_to :notifiable (polymorphic)

## 🚀 Deployment

### Backend Deployment

The backend is Docker-ready and can be deployed using Kamal:

```bash
cd backend
kamal setup
kamal deploy
```

Or deploy to any platform supporting Rails:
- Heroku
- Render
- Fly.io
- AWS/Azure/GCP

### Frontend Deployment

Build the frontend and deploy the `dist/` directory to:
- Vercel
- Netlify
- AWS S3 + CloudFront
- Any static hosting service

Update the `VITE_API_BASE_URL` environment variable to point to your production backend.

## 📝 Development Notes

### Code Style
- Backend follows StandardRB style guide
- All code passes RuboCop checks
- Security scanned with Brakeman (0 warnings)

### Testing
- Comprehensive RSpec test suite
- Model tests with validations and associations
- Request specs for API endpoints
- FactoryBot factories for test data

### Security
- CORS configured for API access
- Authentication with Devise
- Strong parameters for all controllers
- SQL injection protection via ActiveRecord
- XSS protection via Rails defaults

## 📄 License

This project was created as a demonstration of Rails 8.0 and React capabilities.

## 👥 Contributing

This is a demo project. Feel free to fork and modify for your own use.

## 📞 Support

For issues or questions, please refer to the PROMPT.md and PROMPT_CHECKLIST.md files.
