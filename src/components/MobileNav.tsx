import React, { useState, useEffect } from 'react';
import { X, ChevronRight } from 'lucide-react';

export default function MobileNav() {
  const [isOpen, setIsOpen] = useState(false);

  // Lock body scroll when menu is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  const menuItems = [
    {
      title: 'Home',
      href: '/',
      description: 'Return to homepage'
    },
    {
      title: 'Community Impact',
      href: '/community',
      description: 'See how we support Maine communities'
    },
    {
      title: 'Community Support',
      href: '/sponsorships',
      description: 'Our sponsorship and donation programs'
    },
    {
      title: 'Locations',
      href: '/locations',
      description: 'Find your nearest Quirk location'
    },
    {
      title: 'Careers',
      href: '/careers',
      description: 'Join our team'
    },
    {
      title: 'News & Updates',
      href: '/news',
      description: 'Latest news from Quirk Auto Group'
    },
    {
      title: "It's Your Car",
      href: '/its-your-car',
      description: 'Recent vehicle deliveries'
    },
    {
      title: 'Visit Quirk Auto',
      href: 'https://quirkauto.com',
      description: 'Shop our inventory online',
      external: true
    }
  ];

  // Subscribe to mobile menu button clicks
  useEffect(() => {
    const button = document.getElementById('mobile-menu-button');
    if (button) {
      button.addEventListener('click', () => setIsOpen(true));
    }
    return () => {
      if (button) {
        button.removeEventListener('click', () => setIsOpen(true));
      }
    };
  }, []);

  return (
    <div 
      className={`fixed inset-0 z-50 bg-primary transform transition-transform duration-300 ease-in-out ${
        isOpen ? 'translate-x-0' : 'translate-x-full'
      }`}
    >
      {/* Close button */}
      <button
        onClick={() => setIsOpen(false)}
        className="absolute top-4 right-4 z-50 p-2 text-white hover:bg-white/10 rounded-full"
        aria-label="Close menu"
      >
        <X className="w-6 h-6" />
      </button>

      {/* Menu items */}
      <div className="h-full overflow-y-auto pt-16 pb-8 px-6">
        <nav className="space-y-2">
          {menuItems.map((item) => (
            <a
              key={item.title}
              href={item.href}
              target={item.external ? '_blank' : undefined}
              rel={item.external ? 'noopener noreferrer' : undefined}
              className="flex items-center justify-between p-4 rounded-lg bg-white/5 hover:bg-white/10 transition-colors group"
              onClick={() => !item.external && setIsOpen(false)}
            >
              <div>
                <h3 className="text-lg font-medium text-white">{item.title}</h3>
                <p className="text-sm text-white/70">{item.description}</p>
              </div>
              <ChevronRight className="w-5 h-5 text-white/50 group-hover:text-white transition-colors" />
            </a>
          ))}
        </nav>
      </div>
    </div>
  );
}