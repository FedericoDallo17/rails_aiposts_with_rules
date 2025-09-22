# ✅ AIPosts Development Checklist

This checklist defines the full scope of work required to complete the AIPosts app.

---

## 🧩 Setup
- [ ] Initialize a new Rails 8.0 API project (Ruby 3.4.4, PostgreSQL).
- [ ] Add and configure required gems: Devise, JBuilder, Swagger, RSpec, FactoryBot, RuboCop, Brakeman.
- [ ] Configure database and environment files.
- [ ] Create and migrate the database.
- [ ] Initialize Git and commit base project setup.
- [ ] Initialize frontend (React, Vite, or Next.js).
- [ ] Connect frontend to backend API (environment variables, base URL).

## 👤 User Authentication
- [ ] User can sign up.
- [ ] User can sign in.
- [ ] User can sign out.
- [ ] User can reset their password.
- [ ] User can change their email.
- [ ] User can change their password.
- [ ] User can delete their account.
- [ ] Proper authentication tokens or sessions are used.
- [ ] RSpec tests for all auth actions.
- [ ] Swagger docs for auth endpoints.

## 📝 Posts
- [ ] User can create a post.
- [ ] User can edit their own posts.
- [ ] User can delete their own posts.
- [ ] Post includes content and tags.
- [ ] Posts validated for content presence.
- [ ] RSpec tests for post CRUD.
- [ ] JSON output includes author, content, tags.
- [ ] Swagger docs for post endpoints.

## 💬 Comments
- [ ] User can comment on a post.
- [ ] User can view all comments on a post.
- [ ] User can like a comment.
- [ ] Comment likes count is included where relevant.
- [ ] RSpec tests for comments and comment likes.
- [ ] Swagger docs for comments and comment likes.

## ❤️ Likes
- [ ] User can like/unlike a post.
- [ ] User can like/unlike a comment.
- [ ] Each like references a user and a target entity.
- [ ] User can see all likes on a post.
- [ ] User can see all likes on a comment.
- [ ] RSpec tests for like actions.
- [ ] Swagger docs for likes.

## 🔁 Reposts
- [ ] User can repost another user’s post.
- [ ] Reposted posts appear in the feed.
- [ ] Original author is credited in reposts.
- [ ] Reposts have list and toggle endpoints.
- [ ] RSpec tests for reposts.
- [ ] Swagger docs for reposts.

## 👥 Follows
- [ ] User can follow/unfollow another user.
- [ ] User can view followers.
- [ ] User can view following.
- [ ] Feed is based on followed users.
- [ ] RSpec tests for follow relationships.
- [ ] Swagger docs for follows.

## 🔔 Notifications
- [ ] Notifications created for: new follower, new comment, likes on posts/comments, mentions/tags, reposts.
- [ ] User can see all notifications.
- [ ] User can mark notifications as read/unread.
- [ ] Notifications indicate type and related resource.
- [ ] RSpec tests for notifications.
- [ ] Swagger docs for notifications.

## 📰 Feed
- [ ] User sees posts from followed users.
- [ ] Feed also includes reposts by followed users.
- [ ] Feed sorted by newest first.
- [ ] Feed shows counts (likes, comments, reposts).
- [ ] RSpec tests for feed generation.
- [ ] Swagger docs for feed endpoint.

## 🔎 Search
- [ ] Search users by name, username, email, location.
- [ ] Search posts by content, author, tags, comments.
- [ ] Sorting supports newest, oldest, most liked, most commented, most recently commented, most recently liked.
- [ ] RSpec tests for search.
- [ ] Swagger docs for search endpoints.

## ⚙️ Settings
- [ ] Update profile picture.
- [ ] Update cover picture.
- [ ] Update bio.
- [ ] Update website.
- [ ] Update email.
- [ ] Update password.
- [ ] Delete account.
- [ ] RSpec tests for settings.
- [ ] Swagger docs for settings endpoints.

## 🧩 Frontend Features
- [ ] Implement UI (React/Vite/Next.js).
- [ ] Pages: Auth (Sign up / Sign in / Reset), Feed, Profile, Post details, Settings, Notifications, Search.
- [ ] Display dynamic counts and states.
- [ ] Display reposted posts in feed.
- [ ] Manage auth tokens securely.
- [ ] Handle error, loading, and empty states.
- [ ] `npm run build` passes without warnings.

## 🧪 Testing and Quality
- [ ] RSpec: all backend tests pass.
- [ ] Jest/Vitest: all frontend tests pass.
- [ ] RuboCop: no offenses remain.
- [ ] Brakeman: no critical warnings remain.
- [ ] Swagger: all endpoints documented with examples.

## 📘 Documentation
- [ ] Generate Swagger API docs for all controllers.
- [ ] Write `README.md` with setup, environment variables, testing, and deployment notes.
- [ ] Include instructions for running tests and linters.
- [ ] Verify that all checkboxes above are `[x]` before finishing.
