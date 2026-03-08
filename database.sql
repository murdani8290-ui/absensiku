-- ============================================================
-- ABSENSI KU — Supabase Database Setup
-- Jalankan script ini di: Supabase Dashboard → SQL Editor
-- Dikembangkan oleh Murdani
-- ============================================================

-- 1. STUDENTS
CREATE TABLE IF NOT EXISTS students (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  student_code TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  kelas TEXT NOT NULL,
  nis TEXT,
  phone TEXT,
  active BOOLEAN DEFAULT true,
  device_id TEXT,
  device_info JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ATTENDANCE RECORDS
CREATE TABLE IF NOT EXISTS attendance_records (
  id TEXT PRIMARY KEY,
  student_id TEXT REFERENCES students(id) ON DELETE CASCADE,
  student_name TEXT NOT NULL,
  student_code TEXT NOT NULL,
  date DATE NOT NULL,
  clock_in TIME,
  clock_out TIME,
  clock_in_photo TEXT,
  clock_out_photo TEXT,
  clock_in_location JSONB,
  clock_out_location JSONB,
  clock_in_distance FLOAT,
  clock_out_distance FLOAT,
  device_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, date)
);

-- 3. LEAVE REQUESTS
CREATE TABLE IF NOT EXISTS leaves (
  id TEXT PRIMARY KEY,
  student_id TEXT REFERENCES students(id) ON DELETE CASCADE,
  student_name TEXT NOT NULL,
  student_code TEXT NOT NULL,
  type TEXT CHECK (type IN ('izin','sakit','dispensasi')) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason TEXT NOT NULL,
  status TEXT CHECK (status IN ('pending','approved','rejected')) DEFAULT 'pending',
  review_note TEXT,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ANNOUNCEMENTS
CREATE TABLE IF NOT EXISTS announcements (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  priority TEXT CHECK (priority IN ('normal','important','urgent')) DEFAULT 'normal',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  target_id TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info',
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. ACTIVITY LOG
CREATE TABLE IF NOT EXISTS activity_log (
  id TEXT PRIMARY KEY,
  actor TEXT NOT NULL,
  action TEXT NOT NULL,
  detail TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. SCHOOL SETTINGS
CREATE TABLE IF NOT EXISTS school_settings (
  id TEXT PRIMARY KEY DEFAULT '1',
  school_name TEXT DEFAULT 'SMA Negeri 1 Jakarta',
  school_start TIME DEFAULT '07:00',
  school_end TIME DEFAULT '15:00',
  device_lock BOOLEAN DEFAULT true,
  location_name TEXT DEFAULT 'SMA Negeri 1',
  location_lat FLOAT DEFAULT -6.2088,
  location_lng FLOAT DEFAULT 106.8456,
  location_radius INTEGER DEFAULT 200,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO school_settings (id) VALUES ('1') ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaves ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE school_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all_students" ON students FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_records" ON attendance_records FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_leaves" ON leaves FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_announcements" ON announcements FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_notifications" ON notifications FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_activity_log" ON activity_log FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_settings" ON school_settings FOR ALL TO anon USING (true) WITH CHECK (true);

-- ============================================================
-- SEED DATA
-- ============================================================
INSERT INTO students (id, name, student_code, password, kelas, nis, phone, active) VALUES
  ('stu1', 'Andi Pratama',   'SIS001', '123456', 'XII IPA 1', '2024001', '081234567890', true),
  ('stu2', 'Bunga Lestari',  'SIS002', '123456', 'XII IPA 2', '2024002', '081234567891', true),
  ('stu3', 'Cahya Ramadhan', 'SIS003', '123456', 'XI IPS 1',  '2024003', '081234567892', true),
  ('stu4', 'Dewi Anggraini', 'SIS004', '123456', 'XII IPA 1', '2024004', '081234567893', true),
  ('stu5', 'Eka Saputra',    'SIS005', '123456', 'XI IPS 1',  '2024005', '081234567894', true)
ON CONFLICT (id) DO NOTHING;
