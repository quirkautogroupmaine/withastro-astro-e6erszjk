import React, { useState, useEffect } from 'react';
import { client } from '../../lib/meilisearch';
import type { SearchResult } from '../../lib/search/types';
import { useDebounce } from '../../lib/hooks';
import { supabase } from '../../lib/supabase';
import { Search as SearchIcon } from 'lucide-react';

interface QuirkLocation {
  id: string;
  title: string;
  post_count: number;
}

const RESULTS_PER_PAGE = 10;

export default function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'all' | 'iyc'>('all');
  const [locations, setLocations] = useState<QuirkLocation[]>([]);
  const [selectedLocation, setSelectedLocation] = useState<string>('');
  const [totalHits, setTotalHits] = useState<number>(0);
  const [currentPage, setCurrentPage] = useState(1);

  // Fetch Quirk locations with post counts
  useEffect(() => {
    async function fetchLocations() {
      try {
        // Get locations with IYC post counts
        const { data: locationData, error: locationError } = await supabase
          .from('quirk_locations')
          .select(`
            id,
            title,
            iyc!inner (
              id
            )
          `)
          .order('title');

        if (locationError) throw locationError;

        // Process locations to include post count
        const locationsWithCounts = (locationData || []).map(loc => ({
          id: loc.id,
          title: loc.title,
          post_count: Array.isArray(loc.iyc) ? loc.iyc.length : 0
        })).filter(loc => loc.post_count > 0);

        setLocations(locationsWithCounts);
      } catch (err) {
        console.error('Error fetching locations:', err);
      }
    }

    if (activeTab === 'iyc') {
      fetchLocations();
    }
  }, [activeTab]);

  // Debounce search query
  const debouncedQuery = useDebounce(query, 300);

  // Reset page when query or filters change
  useEffect(() => {
    setCurrentPage(1);
  }, [debouncedQuery, selectedLocation, activeTab]);

  // Effect to perform search when debounced query changes
  useEffect(() => {
    const performSearch = async () => {
      if (!debouncedQuery.trim()) {
        setResults([]);
        setTotalHits(0);
        return;
      }

      try {
        setLoading(true);
        setError(null);
        
        const index = client.index('iyc');
        const searchParams: any = {
          limit: RESULTS_PER_PAGE,
          offset: (currentPage - 1) * RESULTS_PER_PAGE,
          attributesToHighlight: ['title', 'excerpt'],
          attributesToRetrieve: [
            'id',
            'title',
            'slug',
            'excerpt',
            'featured_image_url',
            'published_at',
            'quirk_location',
            'location'
          ]
        };

        // Add location filter if selected
        if (selectedLocation) {
          searchParams.filter = `quirk_location.id = "${selectedLocation}"`;
        }

        const { hits, estimatedTotalHits } = await index.search(debouncedQuery, searchParams);
        
        setResults(hits.map(hit => ({
          ...hit,
          type: 'iyc' as const
        })));
        setTotalHits(estimatedTotalHits || hits.length);
      } catch (err) {
        console.error('Search error:', err);
        setError('Search service is currently unavailable');
      } finally {
        setLoading(false);
      }
    };

    performSearch();
  }, [debouncedQuery, selectedLocation, activeTab, currentPage]);

  const totalPages = Math.ceil(totalHits / RESULTS_PER_PAGE);

  return (
    <div className="w-full">
      {/* Search Tabs */}
      <div className="mb-6 border-b border-gray-200">
        <nav className="-mb-px flex space-x-8" aria-label="Search Categories">
          <button
            onClick={() => {
              setActiveTab('all');
              setSelectedLocation('');
            }}
            className={`${
              activeTab === 'all'
                ? 'border-primary text-primary'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            } whitespace-nowrap pb-4 px-1 border-b-2 font-medium`}
          >
            All Content
          </button>
          <button
            onClick={() => setActiveTab('iyc')}
            className={`${
              activeTab === 'iyc'
                ? 'border-primary text-primary'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            } whitespace-nowrap pb-4 px-1 border-b-2 font-medium`}
          >
            It's Your Car
          </button>
        </nav>
      </div>

      {/* Search Content */}
      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row gap-4">
          {/* Search Input */}
          <div className="flex-1">
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <SearchIcon className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="search"
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-primary focus:border-primary sm:text-sm"
                placeholder={`Search ${activeTab === 'iyc' ? "It's Your Car" : 'all content'}...`}
                value={query}
                onChange={(e) => setQuery(e.target.value)}
              />
            </div>
          </div>

          {/* Location Filter */}
          {activeTab === 'iyc' && locations.length > 0 && (
            <div className="sm:w-64">
              <select
                value={selectedLocation}
                onChange={(e) => setSelectedLocation(e.target.value)}
                className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary focus:ring-primary sm:text-sm"
              >
                <option value="">All Locations</option>
                {locations.map((location) => (
                  <option key={location.id} value={location.id}>
                    {location.title} ({location.post_count})
                  </option>
                ))}
              </select>
            </div>
          )}
        </div>

        {/* Results Count */}
        {query && !loading && !error && (
          <div className="text-sm text-gray-600">
            Showing {results.length} {results.length === 1 ? 'result' : 'results'}
            {totalHits > results.length && ` of ${totalHits} total`}
          </div>
        )}

        {/* Loading State */}
        {loading && (
          <div className="flex justify-center py-4">
            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary"></div>
          </div>
        )}

        {/* Error State */}
        {error && (
          <div className="bg-red-50 text-red-700 p-4 rounded-lg">
            {error}
          </div>
        )}

        {/* Results */}
        {results.length > 0 && (
          <div className="space-y-4">
            {results.map((result) => (
              <a
                key={result.id}
                href={`/its-your-car/${result.slug}`}
                className="block bg-white p-4 rounded-lg shadow-sm hover:shadow-md transition-shadow"
              >
                <div className="flex gap-4">
                  {result.featured_image_url && (
                    <img
                      src={result.featured_image_url}
                      alt={result.title}
                      className="w-24 h-24 object-cover rounded-lg flex-shrink-0"
                    />
                  )}
                  <div className="flex-1 min-w-0">
                    <h3 className="text-lg font-medium text-primary line-clamp-1">
                      {result.title}
                    </h3>
                    {result.excerpt && (
                      <p className="mt-1 text-sm text-gray-600 line-clamp-2">
                        {result.excerpt}
                      </p>
                    )}
                    <div className="mt-2 flex flex-wrap gap-2">
                      {result.quirk_location?.title && (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary text-white">
                          {result.quirk_location.title}
                        </span>
                      )}
                      {result.location?.name && (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-secondary text-white">
                          {result.location.name}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              </a>
            ))}
          </div>
        )}

        {/* No Results */}
        {query && !loading && results.length === 0 && (
          <div className="text-center py-12">
            <div className="bg-white p-6 rounded-lg shadow-sm inline-block">
              <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <h3 className="mt-2 text-sm font-medium text-gray-900">No results found</h3>
              <p className="mt-1 text-sm text-gray-500">
                Try adjusting your search terms
                {selectedLocation && ' or location filter'}
              </p>
            </div>
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="mt-8 flex justify-center">
            <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              {/* Previous Page */}
              <button
                onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                disabled={currentPage === 1}
                className="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span className="sr-only">Previous</span>
                <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 19l-7-7 7-7" />
                </svg>
              </button>

              {/* Page Numbers */}
              {Array.from({ length: totalPages }, (_, i) => i + 1).map((pageNum) => (
                <button
                  key={pageNum}
                  onClick={() => setCurrentPage(pageNum)}
                  className={`relative inline-flex items-center px-4 py-2 border text-sm font-medium ${
                    pageNum === currentPage
                      ? 'z-10 bg-primary border-primary text-white'
                      : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'
                  }`}
                >
                  {pageNum}
                </button>
              ))}

              {/* Next Page */}
              <button
                onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                disabled={currentPage === totalPages}
                className="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span className="sr-only">Next</span>
                <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7" />
                </svg>
              </button>
            </nav>
          </div>
        )}
      </div>
    </div>
  );
}