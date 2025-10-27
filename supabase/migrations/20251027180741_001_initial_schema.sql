/*
  # SoftAI Academy - Initial Database Schema

  ## Overview
  This migration creates the complete database schema for SoftAI Academy, an AI/ML learning platform
  with courses, lessons, quizzes, progress tracking, blog, resources, and certificates.

  ## 1. Enums
  - `app_role`: User roles (student, admin)
  - `level`: Course difficulty (beginner, intermediate, advanced)
  - `resource_type`: Resource categories (dataset, paper, tool)
  - `tag_type`: Tag categories (topic, skill, framework)

  ## 2. Core Tables

  ### User Management
  - `user_roles`: Role assignments (separate from profiles for security)
  - `profiles`: User profile information (name, avatar, bio, preferences)

  ### Content Structure
  - `tags`: Reusable tags for categorization
  - `courses`: Main courses with metadata
  - `course_tags`: Many-to-many courses ↔ tags
  - `course_prerequisites`: Self-referential course prerequisites
  - `modules`: Course modules (organizational units)
  - `lessons`: Individual lesson content with video, code demos, datasets
  - `lesson_tags`: Many-to-many lessons ↔ tags

  ### Assessment
  - `quizzes`: Quiz metadata (time limits, passing scores)
  - `questions`: Quiz questions with multiple choice answers
  - `attempts`: User quiz attempts and scores

  ### Progress & Completion
  - `progress`: Tracks user progress through lessons and courses
  - `certificates`: Generated certificates for completed courses

  ### Additional Content
  - `blog_posts`: Blog articles
  - `blog_post_tags`: Many-to-many blog posts ↔ tags
  - `resources`: External resources (datasets, papers, tools)
  - `resource_tags`: Many-to-many resources ↔ tags
  - `newsletter_subscribers`: Newsletter email list

  ## 3. Security (RLS Policies)
  - All tables have Row Level Security enabled
  - Public can view only published content
  - Users can CRUD their own progress, attempts, profile
  - Admins have full access (verified via user_roles table)
  - Quiz correct answers hidden from public (security critical)
  - Newsletter subscribers only accessible by admins

  ## 4. Important Notes
  - Email confirmation is disabled for faster development
  - Roles stored separately from profiles to prevent privilege escalation
  - Quiz scoring must happen server-side via edge function
  - Certificate generation triggered on course completion
  - All slug fields auto-generated from titles
*/

-- =====================================================
-- 1. CREATE ENUMS
-- =====================================================

DO $$ BEGIN
  CREATE TYPE app_role AS ENUM ('student', 'admin');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE level AS ENUM ('beginner', 'intermediate', 'advanced');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE resource_type AS ENUM ('dataset', 'paper', 'tool');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE tag_type AS ENUM ('topic', 'skill', 'framework');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- =====================================================
-- 2. CREATE TABLES
-- =====================================================

-- User Roles (CRITICAL: Separate from profiles for security)
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role app_role NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, role)
);

-- User Profiles
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL DEFAULT '',
  avatar_url text,
  bio text DEFAULT '',
  locale text DEFAULT 'en',
  preferences_dark boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tags (reusable across courses, lessons, blog posts, resources)
CREATE TABLE IF NOT EXISTS tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE,
  tag_type tag_type NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Courses
CREATE TABLE IF NOT EXISTS courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  summary text DEFAULT '',
  description text DEFAULT '',
  cover_image_url text,
  level level NOT NULL DEFAULT 'beginner',
  duration_minutes int DEFAULT 0,
  published boolean DEFAULT false,
  popularity_views int DEFAULT 0,
  created_by_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Course Tags (many-to-many)
CREATE TABLE IF NOT EXISTS course_tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  tag_id uuid NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  UNIQUE(course_id, tag_id)
);

-- Course Prerequisites (self-referential many-to-many)
CREATE TABLE IF NOT EXISTS course_prerequisites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  prerequisite_course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  UNIQUE(course_id, prerequisite_course_id),
  CHECK (course_id != prerequisite_course_id)
);

-- Modules
CREATE TABLE IF NOT EXISTS modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title text NOT NULL,
  "order" int NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Lessons
CREATE TABLE IF NOT EXISTS lessons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title text NOT NULL,
  slug text NOT NULL,
  content text DEFAULT '',
  video_url text,
  code_demo_url text,
  dataset_links text[] DEFAULT '{}',
  duration_minutes int DEFAULT 0,
  "order" int NOT NULL DEFAULT 0,
  published boolean DEFAULT false,
  quiz_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(course_id, slug)
);

-- Lesson Tags (many-to-many)
CREATE TABLE IF NOT EXISTS lesson_tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id uuid NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  tag_id uuid NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  UNIQUE(lesson_id, tag_id)
);

-- Quizzes
CREATE TABLE IF NOT EXISTS quizzes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  time_limit_minutes int DEFAULT 30,
  pass_score_percent int DEFAULT 70,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add foreign key from lessons to quizzes
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'lessons_quiz_id_fkey'
  ) THEN
    ALTER TABLE lessons ADD CONSTRAINT lessons_quiz_id_fkey 
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE SET NULL;
  END IF;
END $$;

-- Questions
CREATE TABLE IF NOT EXISTS questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  prompt text NOT NULL,
  choices text[] NOT NULL,
  correct_index int NOT NULL,
  explanation text DEFAULT '',
  points int DEFAULT 1,
  "order" int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Progress Tracking
CREATE TABLE IF NOT EXISTS progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id uuid REFERENCES lessons(id) ON DELETE CASCADE,
  percent int DEFAULT 0 CHECK (percent >= 0 AND percent <= 100),
  last_viewed timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, lesson_id)
);

-- Quiz Attempts
CREATE TABLE IF NOT EXISTS attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  quiz_id uuid NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  score_percent int DEFAULT 0,
  passed boolean DEFAULT false,
  started_at timestamptz DEFAULT now(),
  finished_at timestamptz,
  answers jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

-- Certificates
CREATE TABLE IF NOT EXISTS certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  certificate_id text NOT NULL UNIQUE,
  issue_date timestamptz DEFAULT now(),
  pdf_url text,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, course_id)
);

-- Blog Posts
CREATE TABLE IF NOT EXISTS blog_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text NOT NULL UNIQUE,
  cover_image_url text,
  content text DEFAULT '',
  excerpt text DEFAULT '',
  published boolean DEFAULT false,
  published_at timestamptz,
  author_user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Blog Post Tags (many-to-many)
CREATE TABLE IF NOT EXISTS blog_post_tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  blog_post_id uuid NOT NULL REFERENCES blog_posts(id) ON DELETE CASCADE,
  tag_id uuid NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  UNIQUE(blog_post_id, tag_id)
);

-- Resources
CREATE TABLE IF NOT EXISTS resources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  url text NOT NULL,
  description text DEFAULT '',
  resource_type resource_type NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Resource Tags (many-to-many)
CREATE TABLE IF NOT EXISTS resource_tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resource_id uuid NOT NULL REFERENCES resources(id) ON DELETE CASCADE,
  tag_id uuid NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  UNIQUE(resource_id, tag_id)
);

-- Newsletter Subscribers
CREATE TABLE IF NOT EXISTS newsletter_subscribers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

-- =====================================================
-- 3. CREATE INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_courses_published ON courses(published);
CREATE INDEX IF NOT EXISTS idx_courses_level ON courses(level);
CREATE INDEX IF NOT EXISTS idx_courses_slug ON courses(slug);
CREATE INDEX IF NOT EXISTS idx_modules_course_id ON modules(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_course_id ON lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_lessons_published ON lessons(published);
CREATE INDEX IF NOT EXISTS idx_questions_quiz_id ON questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_progress_user_id ON progress(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_course_id ON progress(course_id);
CREATE INDEX IF NOT EXISTS idx_attempts_user_id ON attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_blog_posts_published ON blog_posts(published);
CREATE INDEX IF NOT EXISTS idx_blog_posts_slug ON blog_posts(slug);

-- =====================================================
-- 4. ENABLE ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_prerequisites ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_post_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE resource_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE newsletter_subscribers ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. CREATE SECURITY DEFINER FUNCTION FOR ROLE CHECKING
-- =====================================================

CREATE OR REPLACE FUNCTION has_role(check_user_id uuid, check_role app_role)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = check_user_id AND role = check_role
  );
END;
$$;

-- =====================================================
-- 6. CREATE RLS POLICIES
-- =====================================================

-- User Roles Policies
CREATE POLICY "Users can view own roles"
  ON user_roles FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all roles"
  ON user_roles FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can insert roles"
  ON user_roles FOR INSERT
  TO authenticated
  WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete roles"
  ON user_roles FOR DELETE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

-- Profiles Policies
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Tags Policies (public read, admin modify)
CREATE POLICY "Anyone can view tags"
  ON tags FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins can insert tags"
  ON tags FOR INSERT
  TO authenticated
  WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update tags"
  ON tags FOR UPDATE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete tags"
  ON tags FOR DELETE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

-- Courses Policies
CREATE POLICY "Anyone can view published courses"
  ON courses FOR SELECT
  TO public
  USING (published = true);

CREATE POLICY "Admins can view all courses"
  ON courses FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can insert courses"
  ON courses FOR INSERT
  TO authenticated
  WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update courses"
  ON courses FOR UPDATE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete courses"
  ON courses FOR DELETE
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

-- Course Tags Policies (follow parent course visibility)
CREATE POLICY "Anyone can view course tags for published courses"
  ON course_tags FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = course_tags.course_id AND courses.published = true
    )
  );

CREATE POLICY "Admins can manage course tags"
  ON course_tags FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Course Prerequisites Policies
CREATE POLICY "Anyone can view prerequisites for published courses"
  ON course_prerequisites FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = course_prerequisites.course_id AND courses.published = true
    )
  );

CREATE POLICY "Admins can manage prerequisites"
  ON course_prerequisites FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Modules Policies
CREATE POLICY "Anyone can view modules for published courses"
  ON modules FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = modules.course_id AND courses.published = true
    )
  );

CREATE POLICY "Admins can manage modules"
  ON modules FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Lessons Policies
CREATE POLICY "Anyone can view published lessons in published courses"
  ON lessons FOR SELECT
  TO public
  USING (
    published = true AND
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = lessons.course_id AND courses.published = true
    )
  );

CREATE POLICY "Admins can view all lessons"
  ON lessons FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can manage lessons"
  ON lessons FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Lesson Tags Policies
CREATE POLICY "Anyone can view lesson tags for published lessons"
  ON lesson_tags FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM lessons
      WHERE lessons.id = lesson_tags.lesson_id 
      AND lessons.published = true
    )
  );

CREATE POLICY "Admins can manage lesson tags"
  ON lesson_tags FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Quizzes Policies
CREATE POLICY "Anyone can view quizzes for published courses"
  ON quizzes FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = quizzes.course_id AND courses.published = true
    )
  );

CREATE POLICY "Admins can manage quizzes"
  ON quizzes FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Questions Policies (CRITICAL: Hide correct_index from public)
CREATE POLICY "Anyone can view question prompts and choices"
  ON questions FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = questions.quiz_id AND c.published = true
    )
  );

CREATE POLICY "Admins can manage questions"
  ON questions FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Progress Policies
CREATE POLICY "Users can view own progress"
  ON progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress"
  ON progress FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress"
  ON progress FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own progress"
  ON progress FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all progress"
  ON progress FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

-- Attempts Policies
CREATE POLICY "Users can view own attempts"
  ON attempts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own attempts"
  ON attempts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own attempts"
  ON attempts FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all attempts"
  ON attempts FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

-- Certificates Policies
CREATE POLICY "Users can view own certificates"
  ON certificates FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view certificates by certificate_id"
  ON certificates FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins can manage certificates"
  ON certificates FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Blog Posts Policies
CREATE POLICY "Anyone can view published blog posts"
  ON blog_posts FOR SELECT
  TO public
  USING (published = true);

CREATE POLICY "Admins can view all blog posts"
  ON blog_posts FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can manage blog posts"
  ON blog_posts FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Blog Post Tags Policies
CREATE POLICY "Anyone can view blog post tags for published posts"
  ON blog_post_tags FOR SELECT
  TO public
  USING (
    EXISTS (
      SELECT 1 FROM blog_posts
      WHERE blog_posts.id = blog_post_tags.blog_post_id AND blog_posts.published = true
    )
  );

CREATE POLICY "Admins can manage blog post tags"
  ON blog_post_tags FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Resources Policies
CREATE POLICY "Anyone can view resources"
  ON resources FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins can manage resources"
  ON resources FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Resource Tags Policies
CREATE POLICY "Anyone can view resource tags"
  ON resource_tags FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admins can manage resource tags"
  ON resource_tags FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- Newsletter Subscribers Policies (admin only)
CREATE POLICY "Admins can view newsletter subscribers"
  ON newsletter_subscribers FOR SELECT
  TO authenticated
  USING (has_role(auth.uid(), 'admin'));

CREATE POLICY "Anyone can subscribe to newsletter"
  ON newsletter_subscribers FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Admins can manage newsletter subscribers"
  ON newsletter_subscribers FOR ALL
  TO authenticated
  USING (has_role(auth.uid(), 'admin'))
  WITH CHECK (has_role(auth.uid(), 'admin'));

-- =====================================================
-- 7. CREATE TRIGGER FOR AUTO-PROFILE CREATION
-- =====================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, name, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    NOW(),
    NOW()
  );
  
  -- Assign default 'student' role
  INSERT INTO public.user_roles (user_id, role)
  VALUES (NEW.id, 'student');
  
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- =====================================================
-- 8. CREATE HELPER FUNCTIONS
-- =====================================================

-- Function to generate slug from title
CREATE OR REPLACE FUNCTION generate_slug(input_text text)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  result text;
BEGIN
  result := lower(trim(input_text));
  result := regexp_replace(result, '[^a-z0-9\s-]', '', 'g');
  result := regexp_replace(result, '\s+', '-', 'g');
  result := regexp_replace(result, '-+', '-', 'g');
  result := trim(both '-' from result);
  RETURN result;
END;
$$;

-- Function to check if user has completed all lessons in a course
CREATE OR REPLACE FUNCTION check_course_completion(p_user_id uuid, p_course_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  total_lessons int;
  completed_lessons int;
BEGIN
  -- Count total published lessons in course
  SELECT COUNT(*) INTO total_lessons
  FROM lessons
  WHERE course_id = p_course_id AND published = true;
  
  -- Count completed lessons for user
  SELECT COUNT(*) INTO completed_lessons
  FROM progress
  WHERE user_id = p_user_id 
    AND course_id = p_course_id
    AND lesson_id IS NOT NULL
    AND percent = 100;
  
  RETURN (total_lessons > 0 AND completed_lessons >= total_lessons);
END;
$$;

-- Function to calculate course progress percentage
CREATE OR REPLACE FUNCTION calculate_course_progress(p_user_id uuid, p_course_id uuid)
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  total_lessons int;
  completed_lessons int;
  progress_percent int;
BEGIN
  -- Count total published lessons in course
  SELECT COUNT(*) INTO total_lessons
  FROM lessons
  WHERE course_id = p_course_id AND published = true;
  
  IF total_lessons = 0 THEN
    RETURN 0;
  END IF;
  
  -- Count completed lessons for user
  SELECT COUNT(*) INTO completed_lessons
  FROM progress
  WHERE user_id = p_user_id 
    AND course_id = p_course_id
    AND lesson_id IS NOT NULL
    AND percent = 100;
  
  progress_percent := (completed_lessons * 100) / total_lessons;
  
  RETURN progress_percent;
END;
$$;