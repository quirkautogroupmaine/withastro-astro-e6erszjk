import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

interface JobStats {
  totalJobs: number;
  departments: { [key: string]: number };
  locations: { [key: string]: number };
  error?: string;
}

export default function JobsCard() {
  const [stats, setStats] = useState<JobStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [syncing, setSyncing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchStats = async () => {
    try {
      setLoading(true);
      setError(null);

      const { data: jobs, error: jobsError } = await supabase
        .from('jobs')
        .select(`
          *,
          locations:job_locations(
            quirk_location:quirk_locations(
              id,
              title
            )
          )
        `)
        .eq('is_active', true);

      if (jobsError) throw jobsError;

      // Calculate stats
      const stats: JobStats = {
        totalJobs: jobs?.length || 0,
        departments: {},
        locations: {}
      };

      jobs?.forEach(job => {
        // Count departments
        if (job.department) {
          stats.departments[job.department] = (stats.departments[job.department] || 0) + 1;
        }

        // Count locations
        job.locations?.forEach(loc => {
          const locationName = loc.quirk_location.title;
          stats.locations[locationName] = (stats.locations[locationName] || 0) + 1;
        });
      });

      setStats(stats);
    } catch (error) {
      console.error('Error fetching job stats:', error);
      setError(error instanceof Error ? error.message : 'Failed to fetch job statistics');
    } finally {
      setLoading(false);
    }
  };

  const syncJobs = async () => {
    try {
      setSyncing(true);
      setError(null);

      const response = await fetch('/api/jobs/sync', { method: 'POST' });
      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.details || data.error || 'Failed to sync jobs');
      }

      // Refresh stats after sync
      await fetchStats();
    } catch (error) {
      console.error('Error syncing jobs:', error);
      setError(error instanceof Error ? error.message : 'Failed to sync jobs');
    } finally {
      setSyncing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  return (
    <div className="bg-white overflow-hidden shadow rounded-lg">
      <div className="p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center">
            <div className="flex-shrink-0 bg-primary/10 rounded-md p-3">
              <svg className="h-6 w-6 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
            </div>
            <h2 className="ml-3 text-lg font-medium text-gray-900">Jobs</h2>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={syncJobs}
              disabled={syncing}
              className="inline-flex items-center px-3 py-1.5 border border-transparent text-sm font-medium rounded text-white bg-primary hover:bg-primary-dark disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {syncing ? (
                <>
                  <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Syncing...
                </>
              ) : (
                <>
                  <svg className="mr-1.5 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                  Sync
                </>
              )}
            </button>
            <a
              href="/cms/jobs"
              className="inline-flex items-center px-3 py-1.5 border border-gray-300 text-sm font-medium rounded text-gray-700 bg-white hover:bg-gray-50 transition-colors"
            >
              View All
              <svg className="ml-1.5 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7" />
              </svg>
            </a>
          </div>
        </div>

        {error ? (
          <div className="bg-red-50 border-l-4 border-red-400 p-4 mb-4">
            <div className="flex">
              <div className="flex-shrink-0">
                <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                </svg>
              </div>
              <div className="ml-3">
                <h3 className="text-sm font-medium text-red-800">Error</h3>
                <div className="mt-2 text-sm text-red-700">{error}</div>
              </div>
            </div>
          </div>
        ) : loading ? (
          <div className="flex justify-center items-center py-8">
            <svg className="animate-spin h-8 w-8 text-primary" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
          </div>
        ) : (
          <div>
            <div className="mb-6">
              <h3 className="text-3xl font-bold text-primary">{stats?.totalJobs || 0}</h3>
              <p className="text-sm text-gray-500">Active job listings</p>
            </div>

            {stats && Object.keys(stats.departments).length > 0 && (
              <div className="mb-4">
                <h4 className="text-sm font-medium text-gray-700 mb-2">By Department</h4>
                <div className="space-y-1">
                  {Object.entries(stats.departments)
                    .sort(([,a], [,b]) => b - a)
                    .slice(0, 3)
                    .map(([dept, count]) => (
                      <div key={dept} className="flex items-center justify-between">
                        <span className="text-sm text-gray-600">{dept}</span>
                        <span className="text-sm font-medium text-gray-900">{count}</span>
                      </div>
                    ))}
                </div>
              </div>
            )}

            {stats && Object.keys(stats.locations).length > 0 && (
              <div>
                <h4 className="text-sm font-medium text-gray-700 mb-2">Top Locations</h4>
                <div className="space-y-1">
                  {Object.entries(stats.locations)
                    .sort(([,a], [,b]) => b - a)
                    .slice(0, 3)
                    .map(([loc, count]) => (
                      <div key={loc} className="flex items-center justify-between">
                        <span className="text-sm text-gray-600">{loc}</span>
                        <span className="text-sm font-medium text-gray-900">{count}</span>
                      </div>
                    ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}