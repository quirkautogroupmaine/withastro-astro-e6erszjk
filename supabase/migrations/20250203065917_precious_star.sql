-- Create employee_posts junction table
CREATE TABLE employee_posts (
  post_id uuid REFERENCES posts(id) ON DELETE CASCADE,
  employee_id uuid REFERENCES quirk_employees(id) ON DELETE CASCADE,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  PRIMARY KEY (post_id, employee_id)
);

-- Add comments for documentation
COMMENT ON TABLE employee_posts IS 'Junction table linking blog posts to Quirk employees';
COMMENT ON COLUMN employee_posts.is_primary IS 'Indicates if this employee is the primary author/owner of the post';

-- Create indexes for better query performance
CREATE INDEX idx_employee_posts_post ON employee_posts(post_id);
CREATE INDEX idx_employee_posts_employee ON employee_posts(employee_id);
CREATE INDEX idx_employee_posts_primary ON employee_posts(is_primary) WHERE is_primary = true;

-- Enable RLS
ALTER TABLE employee_posts ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Enable read access for all users"
ON employee_posts
FOR SELECT
TO public
USING (true);

CREATE POLICY "Enable all access for authenticated users"
ON employee_posts
FOR ALL
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Create updated_at trigger
CREATE TRIGGER set_employee_posts_updated_at
  BEFORE UPDATE ON employee_posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add constraint to ensure only one primary employee per post
CREATE UNIQUE INDEX idx_employee_posts_primary_unique 
ON employee_posts (post_id) 
WHERE is_primary = true;