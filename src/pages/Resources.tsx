import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import type { Resource, ResourceType } from '../lib/types';
import { Database, FileText, Wrench, ExternalLink } from 'lucide-react';

export default function Resources() {
  const [resources, setResources] = useState<Resource[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState<ResourceType | 'all'>('all');

  useEffect(() => {
    const loadResources = async () => {
      let query = supabase.from('resources').select('*').order('created_at', { ascending: false });

      if (filter !== 'all') {
        query = query.eq('resource_type', filter);
      }

      const { data } = await query;
      if (data) {
        setResources(data);
      }
      setLoading(false);
    };

    loadResources();
  }, [filter]);

  const getIcon = (type: ResourceType) => {
    switch (type) {
      case 'dataset':
        return <Database className="w-8 h-8 text-blue-600" />;
      case 'paper':
        return <FileText className="w-8 h-8 text-green-600" />;
      case 'tool':
        return <Wrench className="w-8 h-8 text-purple-600" />;
    }
  };

  const getTypeBadge = (type: ResourceType) => {
    const colors = {
      dataset: 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400',
      paper: 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400',
      tool: 'bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-400',
    };
    return colors[type];
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Loading resources...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-4">Resources</h1>
          <p className="text-gray-600 dark:text-gray-400">
            Curated datasets, research papers, and tools for your AI journey
          </p>
        </div>

        <div className="mb-6 flex flex-wrap gap-2">
          <button
            onClick={() => setFilter('all')}
            className={`px-4 py-2 rounded-lg font-medium transition ${
              filter === 'all'
                ? 'bg-blue-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
            }`}
          >
            All Resources
          </button>
          <button
            onClick={() => setFilter('dataset')}
            className={`px-4 py-2 rounded-lg font-medium transition ${
              filter === 'dataset'
                ? 'bg-blue-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
            }`}
          >
            Datasets
          </button>
          <button
            onClick={() => setFilter('paper')}
            className={`px-4 py-2 rounded-lg font-medium transition ${
              filter === 'paper'
                ? 'bg-blue-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
            }`}
          >
            Papers
          </button>
          <button
            onClick={() => setFilter('tool')}
            className={`px-4 py-2 rounded-lg font-medium transition ${
              filter === 'tool'
                ? 'bg-blue-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
            }`}
          >
            Tools
          </button>
        </div>

        {resources.length === 0 ? (
          <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-12 text-center">
            <p className="text-gray-600 dark:text-gray-400">No resources found!</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {resources.map((resource) => (
              <a
                key={resource.id}
                href={resource.url}
                target="_blank"
                rel="noopener noreferrer"
                className="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 hover:shadow-lg transition"
              >
                <div className="flex items-start justify-between mb-4">
                  {getIcon(resource.resource_type)}
                  <span
                    className={`text-xs px-2 py-1 rounded-full font-semibold ${getTypeBadge(
                      resource.resource_type
                    )}`}
                  >
                    {resource.resource_type}
                  </span>
                </div>
                <h3 className="text-lg font-semibold mb-2 flex items-center">
                  {resource.title}
                  <ExternalLink className="w-4 h-4 ml-2 text-gray-400" />
                </h3>
                <p className="text-gray-600 dark:text-gray-400 text-sm">{resource.description}</p>
              </a>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
