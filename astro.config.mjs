import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import react from '@astrojs/react';
import netlify from '@astrojs/netlify/functions'; // ✅ Use functions, not edge

export default defineConfig({
  integrations: [tailwind(), react()],
  output: 'server', // ✅ Ensures SSR instead of static
  adapter: netlify({
    functionPerRoute: true, // ✅ Keep this
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
