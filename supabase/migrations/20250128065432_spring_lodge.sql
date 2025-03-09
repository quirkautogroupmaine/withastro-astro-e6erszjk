-- Add YouTube links to selected posts
UPDATE posts 
SET youtube_url = CASE 
  WHEN slug = 'umaine-black-bear-athletics' 
    THEN 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
  WHEN slug = 'maine-mariners-hockey'
    THEN 'https://www.youtube.com/watch?v=jNQXAC9IVRw'
  END
WHERE slug IN ('umaine-black-bear-athletics', 'maine-mariners-hockey');