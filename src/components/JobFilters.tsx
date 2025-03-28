import React, { useState, useEffect } from 'react';

interface FilterProps {
  departments: string[];
  cities: string[];
  locations: { id: string; title: string }[];
  onFilterChange: (filters: FilterState) => void;
  initialFilters: {
    department?: string;
    city?: string;
    locationId?: string;
    search?: string;
  };
}

interface FilterState {
  department?: string;
  city?: string;
  locationId?: string;
  search?: string;
}

export default function JobFilters({
  departments,
  cities,
  locations,
  onFilterChange,
  initialFilters,
}: FilterProps) {
  const [filters, setFilters] = useState<FilterState>(initialFilters);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    setFilters(initialFilters);
  }, [initialFilters]);

  const handleFilterChange = (key: keyof FilterState, value: string) => {
    const newFilters = {
      ...filters,
      [key]: value === 'all' ? undefined : value,
    };
    setFilters(newFilters);

    // Create URL with new parameters
    const url = new URL(window.location.href);
    Object.entries(newFilters).forEach(([key, value]) => {
      if (value) {
        url.searchParams.set(key, value);
      } else {
        url.searchParams.delete(key);
      }
    });

    // Update URL and trigger page reload
    window.location.href = url.toString();
  };

  const handleReset = () => {
    setFilters({});
    window.location.href = window.location.pathname;
  };

  const hasActiveFilters = Object.values(filters).some((value) => value !== undefined);

  if (!mounted) {
    return null;
  }

  return (
    <div className="bg-white p-4 rounded-lg shadow-sm mb-8">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-lg font-semibold text-primary">Filter Jobs</h2>
        {hasActiveFilters && (
          <button
            onClick={handleReset}
            className="text-sm text-secondary hover:text-primary transition-colors flex items-center gap-1"
          >
            <svg
              className="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
              />
            </svg>
            Clear Filters
          </button>
        )}
      </div>

      {/* Grid Filters */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        {/* Keyword Search */}
        <div className="md:col-span-1">
          <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-1">
            Keyword
          </label>
          <input
            id="search"
            type="text"
            placeholder="Search title or description"
            className="block w-full rounded-lg border-gray-300 shadow-sm p-2 focus:border-primary focus:ring-primary"
            value={filters.search || ''}
            onChange={(e) => handleFilterChange('search', e.target.value)}
          />
        </div>

        {/* Department Filter */}
        <div>
          <label htmlFor="department" className="block text-sm font-medium text-gray-700 mb-1">
            Department
          </label>
          <select
            id="department"
            className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary focus:ring-primary"
            onChange={(e) => handleFilterChange('department', e.target.value)}
            value={filters.department || 'all'}
          >
            <option value="all">All Departments</option>
            {departments.map((dept) => (
              <option key={dept} value={dept}>
                {dept}
              </option>
            ))}
          </select>
        </div>

        {/* City Filter */}
        <div>
          <label htmlFor="city" className="block text-sm font-medium text-gray-700 mb-1">
            City
          </label>
          <select
            id="city"
            className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary focus:ring-primary"
            onChange={(e) => handleFilterChange('city', e.target.value)}
            value={filters.city || 'all'}
          >
            <option value="all">All Cities</option>
            {cities.map((city) => (
              <option key={city} value={city}>
                {city}
              </option>
            ))}
          </select>
        </div>

        {/* Location Filter */}
        <div>
          <label htmlFor="location" className="block text-sm font-medium text-gray-700 mb-1">
            Quirk Location
          </label>
          <select
            id="location"
            className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-primary focus:ring-primary"
            onChange={(e) => handleFilterChange('locationId', e.target.value)}
            value={filters.locationId || 'all'}
          >
            <option value="all">All Locations</option>
            {locations.map((loc) => (
              <option key={loc.id} value={loc.id}>
                {loc.title}
              </option>
            ))}
          </select>
        </div>
      </div>
    </div>
  );
}
