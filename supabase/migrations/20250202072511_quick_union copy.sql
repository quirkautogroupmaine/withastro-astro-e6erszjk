-- Create jobs table
CREATE TABLE IF NOT EXISTS jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  location text NOT NULL,
  employment_type text NOT NULL,
  application_url text NOT NULL,
  department text,
  salary_range text,
  requirements text,
  benefits text,
  is_featured boolean DEFAULT false,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add comments for documentation
COMMENT ON TABLE jobs IS 'Job listings for Quirk Auto Group careers';
COMMENT ON COLUMN jobs.employment_type IS 'Type of employment (Full-time, Part-time, Contract, etc.)';
COMMENT ON COLUMN jobs.is_featured IS 'Whether the job should be featured in listings';
COMMENT ON COLUMN jobs.is_active IS 'Whether the job listing is currently active';

-- Create index for active jobs
CREATE INDEX idx_jobs_active ON jobs(is_active) WHERE is_active = true;

-- Create index for featured jobs
CREATE INDEX idx_jobs_featured ON jobs(is_featured) WHERE is_featured = true;

-- Create index for job locations
CREATE INDEX idx_jobs_location ON jobs(location);

-- Create index for job dates
CREATE INDEX idx_jobs_dates ON jobs(created_at DESC, updated_at DESC);

-- Enable RLS
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Enable read access for all users"
ON jobs
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "Enable all access for authenticated users"
ON jobs
FOR ALL
TO authenticated
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

-- Create updated_at trigger
CREATE TRIGGER set_jobs_updated_at
  BEFORE UPDATE ON jobs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample jobs
INSERT INTO jobs (title, description, location, employment_type, application_url, department, salary_range, requirements, benefits, is_featured)
VALUES
  (
    'Automotive Service Technician',
    'Join our team of skilled technicians providing top-quality service to our customers. Experience with diagnostic equipment and various vehicle repairs required.',
    'Bangor, ME',
    'Full-time',
    'https://careers.quirkauto.com/service-tech-bangor',
    'Service',
    'Competitive salary based on experience',
    'ASE Certification preferred, 2+ years experience, valid driver''s license',
    'Health insurance, 401(k) match, paid training, tool allowance',
    true
  ),
  (
    'Sales Consultant',
    'Looking for motivated sales professionals to join our award-winning sales team. Previous automotive sales experience preferred but not required.',
    'Portland, ME',
    'Full-time',
    'https://careers.quirkauto.com/sales-portland',
    'Sales',
    'Base + Commission',
    'Valid driver''s license, excellent communication skills, customer service experience',
    'Health insurance, 401(k) match, paid training, commission structure',
    true
  ),
  (
    'Parts Specialist',
    'Seeking knowledgeable parts professional to assist customers and service department with parts needs.',
    'Augusta, ME',
    'Full-time',
    'https://careers.quirkauto.com/parts-augusta',
    'Parts',
    'Competitive hourly rate',
    'Automotive parts experience preferred, computer proficiency',
    'Health insurance, 401(k) match, employee discounts',
    false
  ),
  (
    'Service Advisor',
    'Customer-focused service advisor needed to act as liaison between customers and service department.',
    'Bangor, ME',
    'Full-time',
    'https://careers.quirkauto.com/advisor-bangor',
    'Service',
    'Competitive salary + bonus potential',
    'Customer service experience, automotive knowledge preferred',
    'Health insurance, 401(k) match, paid training',
    true
  ),
  (
    'Finance Manager',
    'Experienced finance professional needed to assist customers with vehicle financing and F&I products.',
    'Portland, ME',
    'Full-time',
    'https://careers.quirkauto.com/finance-portland',
    'Finance',
    'Base + Commission',
    'Finance experience required, automotive experience preferred',
    'Health insurance, 401(k) match, competitive commission structure',
    true
  );