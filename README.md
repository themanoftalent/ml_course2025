# SoftAI Academy - AI & Machine Learning Learning Platform

A comprehensive learning platform for AI and Machine Learning courses, built with React, TypeScript, Supabase, and Tailwind CSS.

## Features

### For Students
- **Course Browsing**: Browse courses by level (beginner, intermediate, advanced)
- **Structured Learning**: Courses organized into modules and lessons
- **Progress Tracking**: Track your progress through courses and lessons
- **Interactive Quizzes**: Test your knowledge with quizzes at the end of lessons
- **Certificates**: Earn certificates upon completing courses
- **Blog & Resources**: Access curated blog posts, datasets, papers, and tools

### For Administrators
- **Content Management**: Full CMS for managing courses, lessons, quizzes, blog posts, and resources
- **User Management**: Manage user roles and permissions
- **Analytics**: View user progress and completion rates

## Tech Stack

- **Frontend**: React 18, TypeScript, Vite
- **Styling**: Tailwind CSS
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Edge Functions**: Supabase Edge Functions (Deno)
- **Icons**: Lucide React
- **Routing**: React Router v6

## Architecture

### Database Schema

The platform uses a comprehensive PostgreSQL schema with the following main tables:

- **User Management**: `user_roles`, `profiles`
- **Content**: `courses`, `modules`, `lessons`, `tags`
- **Assessment**: `quizzes`, `questions`, `attempts`
- **Progress**: `progress`, `certificates`
- **Blog**: `blog_posts`, `blog_post_tags`
- **Resources**: `resources`, `resource_tags`

All tables have Row Level Security (RLS) enabled for security.

### Edge Functions

Three edge functions provide secure server-side logic:

1. **make-slug**: Generates URL-friendly slugs from titles
2. **score-quiz**: Scores quiz attempts server-side (keeps correct answers secure)
3. **generate-certificate**: Generates certificates when courses are completed

### Security Features

- Row Level Security (RLS) on all tables
- Separate `user_roles` table for role management (prevents privilege escalation)
- Quiz correct answers hidden from client via RLS
- Server-side quiz scoring via edge functions
- Secure certificate generation with unique IDs

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Supabase account (database already configured via Lovable Cloud)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Environment variables are already configured via Lovable Cloud

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Build for production:
   ```bash
   npm run build
   ```

## Sample Data

The database is pre-seeded with:

- **2 Courses**:
  - "Introduction to Machine Learning" (Beginner, 4 lessons)
  - "Deep Learning Fundamentals" (Intermediate, 1 lesson)
- **1 Quiz**: ML Basics Quiz with 5 questions
- **2 Blog Posts**: Articles on ML concepts
- **3 Resources**: Datasets, papers, and tools
- **10 Tags**: Topics, skills, and frameworks

## User Roles

- **Student** (default): Can enroll in courses, track progress, take quizzes, earn certificates
- **Admin**: Full access to CMS, user management, and analytics

To make a user an admin, insert a record into the `user_roles` table with `role = 'admin'`.

## Routes

- `/` - Landing page
- `/auth` - Sign in / Sign up
- `/courses` - Browse all courses
- `/course/:slug` - Course detail page
- `/blog` - Blog posts listing
- `/resources` - Resources listing
- `/dashboard` - User dashboard (protected)
- `/profile` - User profile settings (protected)

## Mobile Support

The platform is fully responsive and ready for mobile deployment:

### Web
The app is mobile-optimized and works on all modern browsers.

### Native Apps (iOS/Android)
To build native apps using Capacitor:

1. Install Capacitor:
   ```bash
   npm install @capacitor/core @capacitor/cli @capacitor/ios @capacitor/android
   ```

2. Initialize Capacitor:
   ```bash
   npx cap init
   ```

3. Build the web assets:
   ```bash
   npm run build
   ```

4. Add platforms:
   ```bash
   npx cap add ios
   npx cap add android
   ```

5. Sync web assets:
   ```bash
   npx cap sync
   ```

6. Open in native IDE:
   ```bash
   npx cap open ios
   npx cap open android
   ```

## Future Enhancements

### High Priority
- Course detail page with enrollment functionality
- Lesson viewer with sidebar navigation
- Quiz interface with timer and scoring
- Certificate generation and download
- Admin CMS for full content management
- Search functionality across courses, lessons, and blog posts

### Medium Priority
- Video player integration for lessons
- Code demo embedding (CodePen, Replit, etc.)
- Dataset links and downloads
- User profile editing with avatar upload
- Newsletter subscription functionality
- Dark mode toggle
- Localization/i18n support

### Low Priority
- Discussion forums
- Course reviews and ratings
- Learning streaks and gamification
- Social sharing for certificates
- Course recommendations
- Mobile notifications
- Offline mode (PWA)

## Contributing

This project was created by SoftAIYazilim. Contributions are welcome!

## License

All rights reserved © 2025 SoftAIYazilim
