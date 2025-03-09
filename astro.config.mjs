import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import react from '@astrojs/react';
import netlify from '@astrojs/netlify';

export default defineConfig({
  integrations: [tailwind({ applyBaseStyles: true })], // ✅ Ensures Tailwind applies base styles
  output: 'server',
  adapter: netlify({
    functionPerRoute: true,
  }),
  build: {
    inlineStylesheets: 'always', // ✅ Forces inlining CSS to avoid missing styles
  },
  vite: {
    ssr: {
      noExternal: ['@fontsource-variable/inter', 'lucide-react'],
    },
  },
});
