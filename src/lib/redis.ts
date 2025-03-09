import Redis from 'ioredis';

// Initialize Redis client with fallback to memory cache if Redis is not available
let redis: Redis | null = null;
const memoryCache = new Map<string, { data: string; expires: number }>();

try {
  redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
  console.log('Redis client initialized');
} catch (error) {
  console.warn('Redis connection failed, falling back to memory cache:', error);
}

export async function getCachedData<T>(key: string, fetchFn: () => Promise<T>, ttl = 3600): Promise<T> {
  try {
    if (redis) {
      // Try to get cached data from Redis
      const cached = await redis.get(key);
      if (cached) {
        return JSON.parse(cached);
      }

      // If no cache, fetch fresh data
      const data = await fetchFn();

      // Cache the fresh data
      await redis.setex(key, ttl, JSON.stringify(data));

      return data;
    } else {
      // Use memory cache if Redis is not available
      const now = Date.now();
      const cached = memoryCache.get(key);

      if (cached && cached.expires > now) {
        return JSON.parse(cached.data);
      }

      // Fetch fresh data
      const data = await fetchFn();

      // Cache in memory
      memoryCache.set(key, {
        data: JSON.stringify(data),
        expires: now + (ttl * 1000)
      });

      // Clean up expired items
      for (const [k, v] of memoryCache.entries()) {
        if (v.expires <= now) {
          memoryCache.delete(k);
        }
      }

      return data;
    }
  } catch (error) {
    console.error(`Cache error for key ${key}:`, error);
    // On cache error, fall back to fresh data
    return await fetchFn();
  }
}