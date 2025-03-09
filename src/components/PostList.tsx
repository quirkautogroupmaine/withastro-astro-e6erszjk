import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface Post {
  id: string;
  title: string;
  slug: string;
  excerpt: string;
  featured_image_url: string;
  published: boolean;
  published_at: string;
  quirk_location?: {
    id: string;
    title: string;
  };
  categories?: {
    category: {
      id: string;
      name: string;
      slug: string;
    } | null;
  }[];
}

interface Category {
  id: string;
  name: string;
  count: number;
}

interface Location {
  id: string;
  title: string;
  count: number;
}

export default function PostList() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalPosts, setTotalPosts] = useState(0);
  const postsPerPage = 10;

  // Filter states
  const [categories, setCategories] = useState<Category[]>([]);
  const [locations, setLocations] = useState<Location[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('');
  const [selectedLocation, setSelectedLocation] = useState<string>('');
  const [searchQuery, setSearchQuery] = useState<string>('');

  // Fetch categories and locations with counts
  useEffect(() => {
    let isMounted = true;

    const fetchFilters = async () => {
      try {
        // Get categories with post counts
        const { data: catData, error: catError } = await supabase
          .from('categories')
          .select('id, name, post_categories!inner(posts!inner(id))')
          .order('name');

        if (catError) throw catError;

        // Get locations with post counts
        const { data: locData, error: locError } = await supabase
          .from('quirk_locations')
          .select('id, title, posts!inner(id)')
          .order('title');

        if (locError) throw locError;

        if (isMounted) {
          // Format categories with counts
          const formattedCategories = catData
            ?.map(cat => ({
              id: cat.id,
              name: cat.name,
              count: cat.post_categories?.length || 0
            }))
            .filter(cat => cat.count > 0)
            .sort((a, b) => a.name.localeCompare(b.name));

          // Format locations with counts
          const formattedLocations = locData
            ?.map(loc => ({
              id: loc.id,
              title: loc.title,
              count: loc.posts?.length || 0
            }))
            .filter(loc => loc.count > 0)
            .sort((a, b) => a.title.localeCompare(b.title));

          setCategories(formattedCategories || []);
          setLocations(formattedLocations || []);
        }
      } catch (err) {
        console.error('Error fetching filters:', err);
        if (isMounted) {
          setError('Failed to load filter options');
        }
      }
    };

    fetchFilters();

    return () => {
      isMounted = false;
    };
  }, []);

  // Fetch posts when filters change
  useEffect(() => {
    let isMounted = true;

    const fetchPosts = async () => {
      try {
        setLoading(true);
        setError(null);

        // Build base query
        let query = supabase
          .from('posts')
          .select(`
            *,
            quirk_location:quirk_locations(id, title),
            categories:post_categories(category:categories(id, name, slug))
          `, { count: 'exact' });

        // Apply filters
        if (selectedCategory) {
          query = query.eq('post_categories.category_id', selectedCategory);
        }

        if (selectedLocation) {
          query = query.eq('quirk_location_id', selectedLocation);
        }

        if (searchQuery) {
          query = query.or(`title.ilike.%${searchQuery}%,excerpt.ilike.%${searchQuery}%,content.ilike.%${searchQuery}%`);
        }

        // Get total count
        const { count } = await query;
        
        if (isMounted) {
          setTotalPosts(count || 0);
          setTotalPages(Math.ceil((count || 0) / postsPerPage));
        }

        // Fetch paginated data
        const from = (page - 1) * postsPerPage;
        const to = from + postsPerPage - 1;

        const { data, error: postsError } = await query
          .order('published_at', { ascending: false })
          .range(from, to);

        if (postsError) throw postsError;

        if (isMounted) {
          setPosts(data || []);
        }
      } catch (err) {
        console.error('Error:', err);
        if (isMounted) {
          setError('Unable to load posts. Please check your connection and try again.');
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    fetchPosts();

    return () => {
      isMounted = false;
    };
  }, [page, selectedCategory, selectedLocation, searchQuery]);

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Filter Section */}
      <div className="bg-primary py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center mb-6">
            <h1 className="text-2xl font-bold text-white">Manage Posts</h1>
            <a
              href="/cms/posts/new"
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-secondary hover:bg-secondary-light"
            >
              New Post
            </a>
          </div>

          <div className="bg-white/10 backdrop-blur-sm p-6 rounded-lg shadow-lg">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Search Box */}
              <div>
                <label htmlFor="search" className="block text-sm font-medium text-white mb-1">
                  Search Posts
                </label>
                <div className="relative">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                  </div>
                  <input
                    type="search"
                    id="search"
                    className="block w-full pl-10 pr-3 py-2 border border-white/20 rounded-md leading-5 bg-white/10 text-white placeholder-gray-300 focus:outline-none focus:placeholder-gray-400 focus:ring-2 focus:ring-white focus:border-transparent sm:text-sm"
                    placeholder="Search by title or content..."
                    onChange={(e) => {
                      setSearchQuery(e.target.value);
                      setPage(1);
                    }}
                  />
                </div>
              </div>

              {/* Category Filter */}
              <div>
                <label htmlFor="category-filter" className="block text-sm font-medium text-white mb-1">
                  Filter by Category
                </label>
                <select
                  id="category-filter"
                  value={selectedCategory}
                  onChange={(e) => {
                    setSelectedCategory(e.target.value);
                    setPage(1);
                  }}
                  className="block w-full rounded-md border-white/20 bg-white text-gray-900 shadow-sm focus:border-white focus:ring-white"
                >
                  <option value="">All Categories</option>
                  {categories.map((category) => (
                    <option key={category.id} value={category.id} className="text-gray-900">
                      {category.name} ({category.count})
                    </option>
                  ))}
                </select>
              </div>

              {/* Location Filter */}
              <div>
                <label htmlFor="location-filter" className="block text-sm font-medium text-white mb-1">
                  Filter by Location
                </label>
                <select
                  id="location-filter"
                  value={selectedLocation}
                  onChange={(e) => {
                    setSelectedLocation(e.target.value);
                    setPage(1);
                  }}
                  className="block w-full rounded-md border-white/20 bg-white text-gray-900 shadow-sm focus:border-white focus:ring-white"
                >
                  <option value="">All Locations</option>
                  {locations.map((location) => (
                    <option key={location.id} value={location.id} className="text-gray-900">
                      {location.title} ({location.count})
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Clear Filters */}
            {(selectedCategory || selectedLocation || searchQuery) && (
              <div className="mt-4 flex justify-end">
                <button
                  onClick={() => {
                    setSelectedCategory('');
                    setSelectedLocation('');
                    setSearchQuery('');
                    setPage(1);
                  }}
                  className="text-sm text-white/80 hover:text-white transition-colors flex items-center"
                >
                  <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                  Clear Filters
                </button>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Results Count */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div className="bg-white/80 backdrop-blur-sm px-4 py-2 rounded-lg shadow-sm inline-flex items-center gap-2">
          <span className="text-sm text-gray-600">
            {totalPosts} {totalPosts === 1 ? 'post' : 'posts'} found
          </span>
          {(selectedCategory || selectedLocation || searchQuery) && (
            <span className="text-sm text-gray-400">
              with current filters
            </span>
          )}
        </div>
      </div>

      {/* Posts List */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {loading ? (
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
          </div>
        ) : error ? (
          <div className="bg-red-50 border-l-4 border-red-400 p-4 rounded">
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
        ) : posts.length === 0 ? (
          <div className="text-center py-12">
            <div className="bg-white p-8 rounded-lg shadow-sm inline-block">
              <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
              </svg>
              <h3 className="mt-2 text-sm font-medium text-gray-900">No posts found</h3>
              <p className="mt-1 text-sm text-gray-500">
                {selectedCategory || selectedLocation || searchQuery ? 'Try adjusting your filters or search terms' : 'Create your first post to get started'}
              </p>
            </div>
          </div>
        ) : (
          <div className="space-y-6">
            {posts.map((post) => (
              <div key={post.id} className="bg-white rounded-lg shadow-lg overflow-hidden">
                <div className="p-6">
                  <div className="flex items-start gap-6">
                    {post.featured_image_url && (
                      <div className="flex-shrink-0 w-24">
                        <img 
                          src={post.featured_image_url}
                          alt={post.title}
                          className="w-24 h-24 object-cover rounded-lg"
                        />
                      </div>
                    )}
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap gap-2 mb-2">
                        {post.categories?.map((cat) => (
                          cat?.category?.name && (
                            <span key={cat.category.id} className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary text-white">
                              {cat.category.name}
                            </span>
                          )
                        ))}
                        {post.quirk_location?.title && (
                          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-secondary text-white">
                            {post.quirk_location.title}
                          </span>
                        )}
                      </div>
                      <h2 className="text-xl font-bold text-primary mb-2">
                        <a href={`/posts/${post.slug}`} className="hover:text-secondary">
                          {post.title}
                        </a>
                      </h2>
                      <p className="text-gray-600 text-sm mb-4">{post.excerpt}</p>
                      <div className="flex items-center justify-between">
                        <time className="text-sm text-gray-500">
                          {new Date(post.published_at).toLocaleDateString('en-US', {
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                          })}
                        </time>
                        <div className="flex items-center gap-2">
                          <a
                            href={`/cms/posts/${post.id}/edit`}
                            className="text-blue-600 hover:text-blue-800"
                          >
                            Edit
                          </a>
                          <button
                            onClick={async () => {
                              if (confirm('Are you sure you want to delete this post?')) {
                                try {
                                  const { error } = await supabase
                                    .from('posts')
                                    .delete()
                                    .eq('id', post.id);

                                  if (error) throw error;
                                  
                                  // Refresh posts
                                  const newPosts = posts.filter(p => p.id !== post.id);
                                  setPosts(newPosts);
                                } catch (err) {
                                  console.error('Error:', err);
                                  alert('Failed to delete post');
                                }
                              }
                            }}
                            className="text-red-600 hover:text-red-800"
                          >
                            Delete
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="mt-8 flex justify-center">
            <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span className="sr-only">Previous</span>
                <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 19l-7-7 7-7" />
                </svg>
              </button>
              {Array.from({ length: totalPages }, (_, i) => i + 1).map((pageNum) => (
                <button
                  key={pageNum}
                  onClick={() => setPage(pageNum)}
                  className={`relative inline-flex items-center px-4 py-2 border text-sm font-medium ${
                    page === pageNum
                      ? 'z-10 bg-primary border-primary text-white'
                      : 'bg-white border-gray-300 text-gray-500 hover:bg-gray-50'
                  }`}
                >
                  {pageNum}
                </button>
              ))}
              <button
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
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