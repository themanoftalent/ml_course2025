export type AppRole = 'student' | 'admin';
export type Level = 'beginner' | 'intermediate' | 'advanced';
export type ResourceType = 'dataset' | 'paper' | 'tool';
export type TagType = 'topic' | 'skill' | 'framework';

export interface Profile {
  id: string;
  name: string;
  avatar_url?: string;
  bio: string;
  locale: string;
  preferences_dark: boolean;
  created_at: string;
  updated_at: string;
}

export interface UserRole {
  id: string;
  user_id: string;
  role: AppRole;
  created_at: string;
}

export interface Tag {
  id: string;
  name: string;
  slug: string;
  tag_type: TagType;
  created_at: string;
}

export interface Course {
  id: string;
  title: string;
  slug: string;
  summary: string;
  description: string;
  cover_image_url?: string;
  level: Level;
  duration_minutes: number;
  published: boolean;
  popularity_views: number;
  created_by_user_id?: string;
  created_at: string;
  updated_at: string;
}

export interface Module {
  id: string;
  course_id: string;
  title: string;
  order: number;
  created_at: string;
  updated_at: string;
}

export interface Lesson {
  id: string;
  module_id: string;
  course_id: string;
  title: string;
  slug: string;
  content: string;
  video_url?: string;
  code_demo_url?: string;
  dataset_links: string[];
  duration_minutes: number;
  order: number;
  published: boolean;
  quiz_id?: string;
  created_at: string;
  updated_at: string;
}

export interface Quiz {
  id: string;
  title: string;
  time_limit_minutes: number;
  pass_score_percent: number;
  course_id?: string;
  created_at: string;
  updated_at: string;
}

export interface Question {
  id: string;
  quiz_id: string;
  prompt: string;
  choices: string[];
  correct_index: number;
  explanation: string;
  points: number;
  order: number;
  created_at: string;
}

export interface Progress {
  id: string;
  user_id: string;
  course_id: string;
  lesson_id?: string;
  percent: number;
  last_viewed: string;
  created_at: string;
  updated_at: string;
}

export interface Attempt {
  id: string;
  user_id: string;
  quiz_id: string;
  score_percent: number;
  passed: boolean;
  started_at: string;
  finished_at?: string;
  answers: Record<string, any>;
  created_at: string;
}

export interface Certificate {
  id: string;
  user_id: string;
  course_id: string;
  certificate_id: string;
  issue_date: string;
  pdf_url?: string;
  created_at: string;
}

export interface BlogPost {
  id: string;
  title: string;
  slug: string;
  cover_image_url?: string;
  content: string;
  excerpt: string;
  published: boolean;
  published_at?: string;
  author_user_id?: string;
  created_at: string;
  updated_at: string;
}

export interface Resource {
  id: string;
  title: string;
  url: string;
  description: string;
  resource_type: ResourceType;
  created_at: string;
  updated_at: string;
}

export interface NewsletterSubscriber {
  id: string;
  email: string;
  created_at: string;
}
