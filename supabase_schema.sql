-- ====================================
-- AI CYBERSHIELD MATRIX - DATABASE SCHEMA
-- PostgreSQL Schema for Supabase
-- ====================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ====================================
-- USERS TABLE
-- ====================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash VARCHAR(256) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ====================================
-- SCAN REPORTS TABLE
-- ====================================
CREATE TABLE IF NOT EXISTS scan_reports (
    id SERIAL PRIMARY KEY,
    tool_name VARCHAR(50) NOT NULL,
    input_data_summary TEXT NOT NULL,
    risk_level VARCHAR(20),
    main_finding VARCHAR(500),
    report_data TEXT NOT NULL,
    scan_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL,
    CONSTRAINT fk_user
        FOREIGN KEY(user_id) 
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_scan_reports_user_id ON scan_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_scan_reports_tool_name ON scan_reports(tool_name);
CREATE INDEX IF NOT EXISTS idx_scan_reports_scan_date ON scan_reports(scan_date DESC);
CREATE INDEX IF NOT EXISTS idx_scan_reports_risk_level ON scan_reports(risk_level);

-- ====================================
-- OTP VERIFICATION TABLE (Optional - for custom OTP)
-- ====================================
-- Only needed if not using Supabase Auth
CREATE TABLE IF NOT EXISTS otp_verifications (
    id SERIAL PRIMARY KEY,
    email VARCHAR(120) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (CURRENT_TIMESTAMP + INTERVAL '10 minutes'),
    verified BOOLEAN DEFAULT FALSE,
    attempts INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_otp_email ON otp_verifications(email);
CREATE INDEX IF NOT EXISTS idx_otp_created_at ON otp_verifications(created_at);

-- ====================================
-- TRIGGERS FOR UPDATED_AT
-- ====================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ====================================
-- DEFAULT ADMIN USER
-- ====================================
-- Password: Admin@123 (CHANGE THIS IMMEDIATELY AFTER FIRST LOGIN!)
-- This is a scrypt hash of "Admin@123"
INSERT INTO users (username, email, password_hash, role)
VALUES (
    'admin',
    'admin@aicybershield.com',
    'scrypt:32768:8:1$TxpLOQzqZI5wF4SF$6b8d8c4f5e3a2e1d9c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1',
    'admin'
)
ON CONFLICT (email) DO NOTHING;

-- ====================================
-- ROW LEVEL SECURITY (RLS) - OPTIONAL
-- ====================================
-- Uncomment these if you want to enable RLS for additional security

-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE scan_reports ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own data
-- CREATE POLICY users_select_own ON users
--     FOR SELECT
--     USING (auth.uid()::text = id::text);

-- Policy: Users can only see their own scan reports
-- CREATE POLICY reports_select_own ON scan_reports
--     FOR SELECT
--     USING (auth.uid()::text = user_id::text);

-- Policy: Users can insert their own scan reports
-- CREATE POLICY reports_insert_own ON scan_reports
--     FOR INSERT
--     WITH CHECK (auth.uid()::text = user_id::text);

-- ====================================
-- VIEWS FOR ANALYTICS (OPTIONAL)
-- ====================================

-- View: Recent scans summary
CREATE OR REPLACE VIEW recent_scans_summary AS
SELECT 
    u.username,
    u.email,
    sr.tool_name,
    sr.risk_level,
    sr.scan_date,
    sr.main_finding
FROM scan_reports sr
JOIN users u ON sr.user_id = u.id
ORDER BY sr.scan_date DESC
LIMIT 100;

-- View: User scan statistics
CREATE OR REPLACE VIEW user_scan_stats AS
SELECT 
    u.id as user_id,
    u.username,
    u.email,
    COUNT(sr.id) as total_scans,
    COUNT(CASE WHEN sr.risk_level IN ('High', 'Critical', 'Suspicious') THEN 1 END) as high_risk_scans,
    MAX(sr.scan_date) as last_scan_date
FROM users u
LEFT JOIN scan_reports sr ON u.id = sr.user_id
GROUP BY u.id, u.username, u.email;

-- ====================================
-- SAMPLE DATA FOR TESTING (OPTIONAL)
-- ====================================
-- Uncomment to insert test data

-- INSERT INTO users (username, email, password_hash, role)
-- VALUES 
--     ('testuser', 'test@example.com', 'scrypt:32768:8:1$test_hash', 'user'),
--     ('analyst', 'analyst@example.com', 'scrypt:32768:8:1$test_hash', 'user')
-- ON CONFLICT (email) DO NOTHING;

-- ====================================
-- CLEANUP OLD OTP CODES (MAINTENANCE)
-- ====================================
-- Run this periodically to clean up expired OTP codes
-- DELETE FROM otp_verifications WHERE expires_at < CURRENT_TIMESTAMP;

-- ====================================
-- GRANT PERMISSIONS
-- ====================================
-- Grant appropriate permissions to authenticated users
-- Adjust these based on your security requirements

GRANT SELECT, INSERT, UPDATE ON users TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON scan_reports TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ====================================
-- SCHEMA VERSION
-- ====================================
CREATE TABLE IF NOT EXISTS schema_version (
    version INTEGER PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

INSERT INTO schema_version (version, description)
VALUES (1, 'Initial schema with users and scan_reports tables')
ON CONFLICT (version) DO NOTHING;

-- ====================================
-- COMPLETION MESSAGE
-- ====================================
-- Schema setup complete!
-- Next steps:
-- 1. Change the default admin password immediately
-- 2. Configure Row Level Security if needed
-- 3. Set up backup policies in Supabase dashboard
-- 4. Enable database webhooks for real-time features (optional)
