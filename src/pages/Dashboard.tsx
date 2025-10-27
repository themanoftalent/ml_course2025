import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { useAuth } from '../hooks/useAuth';
import { BookOpen, Award, Clock } from 'lucide-react';
import type { Course, Progress, Certificate } from '../lib/types';

interface EnrolledCourse extends Course {
  progress_percent: number;
}

export default function Dashboard() {
  const { user } = useAuth();
  const [enrolledCourses, setEnrolledCourses] = useState<EnrolledCourse[]>([]);
  const [certificates, setCertificates] = useState<Certificate[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;

    const loadDashboard = async () => {
      const { data: progressData } = await supabase
        .from('progress')
        .select(`
          course_id,
          percent,
          last_viewed,
          courses (*)
        `)
        .eq('user_id', user.id)
        .not('lesson_id', 'is', null)
        .order('last_viewed', { ascending: false });

      if (progressData) {
        const coursesMap = new Map<string, EnrolledCourse>();

        progressData.forEach((item: any) => {
          const course = item.courses;
          if (course && !coursesMap.has(course.id)) {
            coursesMap.set(course.id, {
              ...course,
              progress_percent: 0,
            });
          }
        });

        for (const [courseId, course] of coursesMap.entries()) {
          const { data: courseProgress } = await supabase
            .rpc('calculate_course_progress', {
              p_user_id: user.id,
              p_course_id: courseId,
            });

          if (courseProgress !== null) {
            course.progress_percent = courseProgress;
          }
        }

        setEnrolledCourses(Array.from(coursesMap.values()));
      }

      const { data: certsData } = await supabase
        .from('certificates')
        .select('*')
        .eq('user_id', user.id)
        .order('issue_date', { ascending: false });

      if (certsData) {
        setCertificates(certsData);
      }

      setLoading(false);
    };

    loadDashboard();
  }, [user]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Loading your dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold mb-2">Welcome back!</h1>
          <p className="text-gray-600 dark:text-gray-400">Continue your learning journey</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm">
            <div className="flex items-center space-x-4">
              <div className="p-3 bg-blue-100 dark:bg-blue-900/20 rounded-lg">
                <BookOpen className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{enrolledCourses.length}</p>
                <p className="text-sm text-gray-600 dark:text-gray-400">Enrolled Courses</p>
              </div>
            </div>
          </div>

          <div className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm">
            <div className="flex items-center space-x-4">
              <div className="p-3 bg-green-100 dark:bg-green-900/20 rounded-lg">
                <Award className="w-6 h-6 text-green-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{certificates.length}</p>
                <p className="text-sm text-gray-600 dark:text-gray-400">Certificates Earned</p>
              </div>
            </div>
          </div>

          <div className="bg-white dark:bg-gray-800 p-6 rounded-xl shadow-sm">
            <div className="flex items-center space-x-4">
              <div className="p-3 bg-purple-100 dark:bg-purple-900/20 rounded-lg">
                <Clock className="w-6 h-6 text-purple-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">
                  {enrolledCourses.reduce((sum, c) => sum + c.duration_minutes, 0)}
                </p>
                <p className="text-sm text-gray-600 dark:text-gray-400">Minutes of Content</p>
              </div>
            </div>
          </div>
        </div>

        {enrolledCourses.length === 0 ? (
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-12 text-center">
            <BookOpen className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h2 className="text-2xl font-semibold mb-2">No courses yet</h2>
            <p className="text-gray-600 dark:text-gray-400 mb-6">
              Start your learning journey by enrolling in a course
            </p>
            <Link
              to="/courses"
              className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition inline-block"
            >
              Browse Courses
            </Link>
          </div>
        ) : (
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6">
            <h2 className="text-2xl font-semibold mb-6">Your Courses</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {enrolledCourses.map((course) => (
                <Link
                  key={course.id}
                  to={`/course/${course.slug}`}
                  className="border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden hover:shadow-lg transition"
                >
                  {course.cover_image_url && (
                    <img
                      src={course.cover_image_url}
                      alt={course.title}
                      className="w-full h-48 object-cover"
                    />
                  )}
                  <div className="p-4">
                    <h3 className="font-semibold mb-2">{course.title}</h3>
                    <div className="space-y-2">
                      <div className="flex items-center justify-between text-sm">
                        <span className="text-gray-600 dark:text-gray-400">Progress</span>
                        <span className="font-semibold">{course.progress_percent}%</span>
                      </div>
                      <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                        <div
                          className="bg-blue-600 h-2 rounded-full transition-all"
                          style={{ width: `${course.progress_percent}%` }}
                        />
                      </div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          </div>
        )}

        {certificates.length > 0 && (
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 mt-8">
            <h2 className="text-2xl font-semibold mb-6">Your Certificates</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {certificates.map((cert) => (
                <Link
                  key={cert.id}
                  to={`/certificate/${cert.certificate_id}`}
                  className="border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:shadow-lg transition"
                >
                  <Award className="w-12 h-12 text-yellow-500 mb-3" />
                  <p className="font-semibold mb-1">Certificate</p>
                  <p className="text-sm text-gray-600 dark:text-gray-400">
                    ID: {cert.certificate_id}
                  </p>
                  <p className="text-xs text-gray-500 dark:text-gray-500 mt-2">
                    Issued: {new Date(cert.issue_date).toLocaleDateString()}
                  </p>
                </Link>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
