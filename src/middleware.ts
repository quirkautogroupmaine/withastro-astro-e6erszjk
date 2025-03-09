import { defineMiddleware } from 'astro:middleware';

export const onRequest = defineMiddleware(async ({ request, redirect }, next) => {
  try {
    const response = await next();
    return response;
  } catch (error) {
    if (error.status === 404) {
      return redirect('/404');
    }
    throw error;
  }
});