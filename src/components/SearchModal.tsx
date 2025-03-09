import React, { useState, useEffect } from 'react';
import { client } from '../lib/meilisearch';
import type { SearchResult } from '../lib/search/types';
import { useDebounce } from '../lib/hooks';
import { 
  Search as SearchIcon, 
  X,
  Car, // For IYC
  Briefcase, // For Jobs
  Newspaper, // For News
  Building2, // For Locations
  Globe // For All Content
} from 'lucide-react';

interface SearchModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const MIN_QUERY_LENGTH = 2;
const DEBOUNCE_DELAY = 300;

export default function SearchModal({ isOpen, onClose }: SearchModalProps) {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedType, setSelectedType] = useState<string>('all');

  // Debounce search query
  const debouncedQuery = useDebounce(query, DEBOUNCE_DELAY);

  // Effect to perform search when debounced query changes
  useEffect(() => {
    const performSearch = async () => {
      if (!debouncedQuery.trim() || debouncedQuery.length < MIN_QUERY_LENGTH) {
        setResults([]);
        setError(null);
        return;
      }

      try {
        setLoading(true);
        setError(null);
        
        const index = client.index('unified');
        const searchParams: any = {
          limit: 10,
          attributesToHighlight: ['title', 'description'],
          attributesToRetrieve: [
            'id',
            'type',
            'title',
            'description',
            'featured_image_url',
            'url',
            'location',
            'additional_data'
          ]
        };

        // Add filter if type is selected
        if (selectedType !== 'all') {
          searchParams.filter = `type = ${selectedType}`;
        }

        const { hits } = await index.search(debouncedQuery, searchParams);
        setResults(hits as SearchResult[]);
      } catch (err) {
        console.error('Search error:', err);
        setError('Search service is currently unavailable');
      } finally {
        setLoading(false);
      }
    };

    if (isOpen) {
      performSearch();
    }
  }, [debouncedQuery, selectedType, isOpen]);

  // Clear state when modal closes
  useEffect(() => {
    if (!isOpen) {
      setQuery('');
      setResults([]);
      setError(null);
      setSelectedType('all');
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      {/* Backdrop */}
      <div 
        className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
        <div className="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-3xl">
          <div className="bg-white px-4 pb-4 pt-5 sm:p-6 sm:pb-4">
            {/* Close Button */}
            <div className="absolute top-0 right-0 pt-4 pr-4">
              <button
                type="button"
                className="rounded-md bg-white text-gray-400 hover:text-gray-500"
                onClick={onClose}
              >
                <span className="sr-only">Close</span>
                <X className="h-6 w-6" />
              </button>
            </div>

            {/* Search Content */}
            <div className="mt-3 sm:mt-0 sm:text-left">
              <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">
                Search Content
              </h3>

              {/* Search Input */}
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <SearchIcon className="h-5 w-5 text-gray-400" />
                </div>
                <input
                  type="search"
                  className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-primary focus:border-primary sm:text-sm"
                  placeholder="Search..."
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  autoFocus
                />
              </div>

              {/* Content Type Filter */}
              <div className="mt-4 flex flex-wrap gap-2">
                <button
                  onClick={() => setSelectedType('all')}
                  className={`inline-flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${
                    selectedType === 'all'
                      ? 'bg-primary text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  <Globe className="w-4 h-4" />
                  All Content
                </button>
                <button
                  onClick={() => setSelectedType('iyc')}
                  className={`inline-flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${
                    selectedType === 'iyc'
                      ? 'bg-primary text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  <Car className="w-4 h-4" />
                  It's Your Car
                </button>
                <button
                  onClick={() => setSelectedType('job')}
                  className={`inline-flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${
                    selectedType === 'job'
                      ? 'bg-primary text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  <Briefcase className="w-4 h-4" />
                  Careers
                </button>
                <button
                  onClick={() => setSelectedType('post')}
                  className={`inline-flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${
                    selectedType === 'post'
                      ? 'bg-primary text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  <Newspaper className="w-4 h-4" />
                  News
                </button>
                <button
                  onClick={() => setSelectedType('location')}
                  className={`inline-flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${
                    selectedType === 'location'
                      ? 'bg-primary text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  <Building2 className="w-4 h-4" />
                  Locations
                </button>
              </div>

              {/* Loading State */}
              {loading && (
                <div className="flex justify-center py-4">
                  <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-primary"></div>
                </div>
              )}

              {/* Error State */}
              {error && (
                <div className="bg-red-50 text-red-700 p-4 rounded-lg mt-4">
                  {error}
                </div>
              )}

              {/* Results */}
              <div className="mt-6 max-h-[60vh] overflow-y-auto">
                {results.length > 0 ? (
                  <div className="space-y-4">
                    {results.map((result) => (
                      <a
                        key={result.id}
                        href={result.url}
                        className="block bg-white p-4 rounded-lg shadow-sm hover:shadow-md transition-shadow"
                        onClick={onClose}
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
                            <div className="flex items-center gap-2 mb-1">
                              <span className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium ${
                                result.type === 'iyc' 
                                  ? 'bg-primary text-white'
                                  : result.type === 'job'
                                  ? 'bg-secondary text-white'
                                  : result.type === 'location'
                                  ? 'bg-secondary text-white'
                                  : 'bg-gray-100 text-gray-800'
                              }`}>
                                {result.type === 'iyc' && <Car className="w-3 h-3" />}
                                {result.type === 'job' && <Briefcase className="w-3 h-3" />}
                                {result.type === 'post' && <Newspaper className="w-3 h-3" />}
                                {result.type === 'location' && <Building2 className="w-3 h-3" />}
                                {result.type === 'iyc' 
                                  ? "It's Your Car"
                                  : result.type === 'job'
                                  ? 'Career'
                                  : result.type === 'location'
                                  ? 'Location'
                                  : 'News'}
                              </span>
                            </div>
                            <h3 className="text-lg font-medium text-primary line-clamp-1">
                              {result.title}
                            </h3>
                            <p className="mt-1 text-sm text-gray-600 line-clamp-2">
                              {result.description}
                            </p>
                            <div className="mt-2 flex flex-wrap gap-2">
                              {result.location?.title && (
                                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-secondary text-white">
                                  {result.location.title}
                                </span>
                              )}
                              {result.type === 'job' && result.additional_data?.department && (
                                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                                  {result.additional_data.department}
                                </span>
                              )}
                            </div>
                          </div>
                        </div>
                      </a>
                    ))}
                  </div>
                ) : query.length >= MIN_QUERY_LENGTH && !loading ? (
                  <div className="text-center py-12">
                    <div className="bg-white p-6 rounded-lg shadow-sm inline-block">
                      <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      <h3 className="mt-2 text-sm font-medium text-gray-900">No results found</h3>
                      <p className="mt-1 text-sm text-gray-500">
                        Try adjusting your search terms
                      </p>
                    </div>
                  </div>
                ) : null}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}