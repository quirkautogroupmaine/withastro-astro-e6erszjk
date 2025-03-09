import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { BarChart3, TrendingUp } from 'lucide-react';

interface PostStats {
  total: number;
  lastWeek: number;
  lastMonth: number;
}

interface CategoryStats {
  name: string;
  total: number;
  lastWeek: number;
  lastMonth: number;
}

interface LocationStats {
  title: string;
  total: number;
  lastWeek: number;
  lastMonth: number;
}

export default function PostStats() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [stats, setStats] = useState<PostStats>({ total: 0, lastWeek: 0, lastMonth: 0 });
  const [categoryStats, setCategoryStats] = useState<CategoryStats[]>([]);
  const [locationStats, setLocationStats] = useState<LocationStats[]>([]);

  useEffect(() => {
    async function fetchStats() {
      try {
        setLoading(true);
        setError(null);

        const now = new Date();
        const lastWeek = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        const lastMonth = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

        // Fetch total posts
        const { count: total, error: totalError } = await supabase
          .from('posts')
          .select('*', { count: 'exact', head: true })
          .eq('published', true);

        if (totalError) throw totalError;

        // Fetch last week's posts
        const { count: lastWeekCount, error: weekError } = await supabase
          .from('posts')
          .select('*', { count: 'exact', head: true })
          .eq('published', true)
          .gte('published_at', lastWeek.toISOString());

        if (weekError) throw weekError;

        // Fetch last month's posts
        const { count: lastMonthCount, error: monthError } = await supabase
          .from('posts')
          .select('*', { count: 'exact', head: true })
          .eq('published', true)
          .gte('published_at', lastMonth.toISOString());

        if (monthError) throw monthError;

        // Fetch category stats
        const { data: categories, error: catError } = await supabase
          .from('categories')
          .select(`
            name,
            posts:post_categories!inner (
              post:posts!inner (
                id,
                published_at
              )
            )
          `)
          .order('name');

        if (catError) throw catError;

        // Process category stats
        const processedCategoryStats = categories?.map(category => ({
          name: category.name,
          total: category.posts?.length || 0,
          lastWeek: category.posts?.filter(p => 
            new Date(p.post.published_at) >= lastWeek
          ).length || 0,
          lastMonth: category.posts?.filter(p => 
            new Date(p.post.published_at) >= lastMonth
          ).length || 0
        })) || [];

        // Fetch location stats
        const { data: locations, error: locError } = await supabase
          .from('quirk_locations')
          .select(`
            title,
            posts!inner (
              id,
              published_at
            )
          `)
          .order('title');

        if (locError) throw locError;

        // Process location stats
        const processedLocationStats = locations?.map(location => ({
          title: location.title,
          total: location.posts?.length || 0,
          lastWeek: location.posts?.filter(post => 
            new Date(post.published_at) >= lastWeek
          ).length || 0,
          lastMonth: location.posts?.filter(post => 
            new Date(post.published_at) >= lastMonth
          ).length || 0
        })) || [];

        // Update state
        setStats({
          total: total || 0,
          lastWeek: lastWeekCount || 0,
          lastMonth: lastMonthCount || 0
        });
        setCategoryStats(processedCategoryStats);
        setLocationStats(processedLocationStats);

      } catch (err) {
        console.error('Error fetching stats:', err);
        setError('Failed to load statistics');
      } finally {
        setLoading(false);
      }
    }

    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border-l-4 border-red-400 p-4">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <p className="text-sm text-red-700">{error}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Overall Stats */}
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex items-center gap-4 mb-6">
          <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
            <TrendingUp className="w-6 h-6 text-primary" />
          </div>
          <div>
            <h2 className="text-2xl font-bold text-primary">Post Activity</h2>
            <p className="text-sm text-gray-500">Overview of post creation activity</p>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="text-4xl font-bold text-primary">{stats.total}</div>
            <div className="text-sm text-gray-600">Total Posts</div>
          </div>
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="text-4xl font-bold text-secondary">{stats.lastWeek}</div>
            <div className="text-sm text-gray-600">Last 7 Days</div>
          </div>
          <div className="bg-gray-50 rounded-lg p-4">
            <div className="text-4xl font-bold text-secondary">{stats.lastMonth}</div>
            <div className="text-sm text-gray-600">Last 30 Days</div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Category Stats */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center gap-4 mb-6">
            <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
              <BarChart3 className="w-6 h-6 text-primary" />
            </div>
            <div>
              <h2 className="text-xl font-bold text-primary">Posts by Category</h2>
              <p className="text-sm text-gray-500">Distribution across categories</p>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead>
                <tr>
                  <th className="text-left text-xs font-medium text-gray-500 uppercase tracking-wider pb-3">Category</th>
                  <th className="text-right text-xs font-medium text-gray-500 uppercase tracking-wider pb-3">Total</th>
                  <th className="text-right text-xs font-medium text-gray-500 uppercase tracking-wider pb-3">7 Days</th>
                  <th className="text-right text-xs font-medium text-gray-500 uppercase tracking-wider pb-3">30 Days</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {categoryStats.map((cat) => (
                  <tr key={cat.name}>
                    <td className="py-2 text-sm text-gray-900">{cat.name}</td>
                    <td className="py-2 text-sm text-gray-900 text-right">{cat.total}</td>
                    <td className="py-2 text-sm text-gray-900 text-right">{cat.lastWeek}</td>
                    <td className="py-2 text-sm text-gray-900 text-right">{cat.lastMonth}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Location Stats */}
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center gap-4 mb-6">
            <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
              <BarChart3 className="w-6 h-6 text-primary" />
            </div>
            <div>
              <h2 className="text-xl font-bold text-primary">Posts by Location</h2>
              <p className="text-sm text-gray-500">Distribution across locations</p>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full">
              <thead>
                <tr>
                  <th className="text-left text-xs font-medium text-gray-500 uppercase tracking-wider pb-3">Location</th>
                  <th className="text-right text-xs font-medium text-gray-500 uppercase tracking-wider pb-3">Total</th>
                  <th className="text-right text-xs font-medium text-gray-500 uppercase tracking-wider pb-3">7 Days</th>
                  <th className="text-right text-xs font-medium text-gray-500 uppercase tracking-wider pb-3">30 Days</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {locationStats.map((loc) => (
                  <tr key={loc.title}>
                    <td className="py-2 text-sm text-gray-900">{loc.title}</td>
                    <td className="py-2 text-sm text-gray-900 text-right">{loc.total}</td>
                    <td className="py-2 text-sm text-gray-900 text-right">{loc.lastWeek}</td>
                    <td className="py-2 text-sm text-gray-900 text-right">{loc.lastMonth}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}