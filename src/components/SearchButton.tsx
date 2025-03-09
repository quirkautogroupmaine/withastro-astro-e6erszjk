import React, { useState } from 'react';
import SearchModal from './SearchModal';
import { Search as SearchIcon } from 'lucide-react';

const SearchButton: React.FC = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <>
      <button
        onClick={() => setIsModalOpen(true)}
        className="flex items-center gap-2 px-4 py-2 rounded-md bg-primary text-white hover:bg-primary-dark transition-colors shadow-sm hover:shadow-md"
        aria-label="Open search"
      >
        <SearchIcon className="w-4 h-4" />
        <span className="text-sm font-medium hidden sm:inline">Search</span>
      </button>

      <SearchModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
    </>
  );
};

export default SearchButton;