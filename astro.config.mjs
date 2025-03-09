import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import react from '@astrojs/react';
import netlify from '@astrojs/netlify';

export default defineConfig({
  integrations: [tailwind(), react()], // ✅ Ensure React is included
  output: 'server',
  adapter: netlify({
    functionPerRoute: true,
  }),
  build: {
    inlineStylesheets: 'always',
  },
  vite: {
    ssr: {
      noExternal: ['@fontsource-variable/inter', 'lucide-react'],
    },
  },
});
