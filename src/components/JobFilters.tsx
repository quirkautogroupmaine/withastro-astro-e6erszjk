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
  };
}

interface FilterState {
  department?: string;
  city?: string;
  locationId?: string;
}

export default function JobFilters({ departments, cities, locations, onFilterChange, initialFilters }: FilterProps) {
  const [filters, setFilters] = useState<FilterState>(initialFilters);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    setFilters(initialFilters);
  }, [initialFilters]);

  const handleFilterChange = (key: keyof FilterState, value: string | undefined) => {
    const newFilters = {
      ...filters,
      [key]: value === 'all' ? undefined : value
    };
    setFilters(newFilters);
    if (onFilterChange) {
      onFilterChange(newFilters);
    }
  };

  const handleReset = () => {
    setFilters({});
    if (onFilterChange) {
      onFilterChange({});
    }
  };

  const hasActiveFilters = Object.values(filters).some(value => value !== undefined);

  if (!mounted) {
    return null; // Prevent hydration mismatch by not rendering until mounted
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
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Clear Filters
          </button>
        )}
      </div>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
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