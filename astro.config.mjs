import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import react from '@astrojs/react';
import netlify from '@astrojs/netlify';

export default defineConfig({
  integrations: [tailwind(), react()],
  output: 'server', // ✅ Ensures SSR instead of static
  adapter: netlify({
    functionPerRoute: true, // ✅ Ensures separate functions per route
  }),
  build: {
    inlineStylesheets: 'auto',
  },
  vite: {
    ssr: {
      noExternal: ['@fontsource-variable/inter', 'lucide-react'],
    },
  },
});
