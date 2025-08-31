-- IoT Real-time Analytics Dashboard - TimescaleDB Schema
-- Optimized for high-volume IoT sensor data with time-series capabilities
-- Supports millions of data points with sub-second query performance

-- Create database
-- CREATE DATABASE iot_analytics;
-- \c iot_analytics;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
CREATE EXTENSION IF NOT EXISTS postgis;  -- For geospatial data
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;  -- For query optimization
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- For exclusion constraints

-- ============================================
-- CORE TABLES
-- ============================================

-- Device registry table
CREATE TABLE IF NOT EXISTS devices (
    device_id VARCHAR(64) PRIMARY KEY,
    device_type VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(100),
    model VARCHAR(100),
    firmware_version VARCHAR(20),
    serial_number VARCHAR(100) UNIQUE,
    mac_address VARCHAR(17),
    ip_address INET,
    
    -- Location information
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    altitude DECIMAL(8, 2),
    location_geom GEOGRAPHY(POINT, 4326),
    building VARCHAR(100),
    floor INTEGER,
    room VARCHAR(50),
    zone VARCHAR(50),
    
    -- Status and metadata
    status VARCHAR(20) DEFAULT 'offline' CHECK (status IN ('online', 'offline', 'maintenance', 'error', 'degraded')),
    battery_level DECIMAL(5, 2),
    signal_strength DECIMAL(5, 2),
    
    -- Timestamps
    installation_date TIMESTAMPTZ,
    last_maintenance TIMESTAMPTZ,
    last_seen TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Additional metadata as JSONB
    metadata JSONB DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    
    -- Indexes
    INDEX idx_device_status (status),
    INDEX idx_device_type (device_type),
    INDEX idx_device_location (building, floor, zone),
    INDEX idx_device_tags USING GIN (tags)
);

-- Create spatial index
CREATE INDEX idx_devices_location_geom ON devices USING GIST (location_geom);

-- Sensor types configuration
CREATE TABLE IF NOT EXISTS sensor_types (
    sensor_type VARCHAR(50) PRIMARY KEY,
    unit VARCHAR(20) NOT NULL,
    min_value DECIMAL(20, 6),
    max_value DECIMAL(20, 6),
    precision_digits INTEGER DEFAULT 3,
    category VARCHAR(50),
    description TEXT,
    thresholds JSONB DEFAULT '{}',  -- {"warning": 80, "critical": 95}
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert common sensor types
INSERT INTO sensor_types (sensor_type, unit, min_value, max_value, category, description) VALUES
    ('temperature', '°C', -50, 100, 'environmental', 'Temperature sensor'),
    ('humidity', '%', 0, 100, 'environmental', 'Relative humidity sensor'),
    ('pressure', 'hPa', 900, 1100, 'environmental', 'Atmospheric pressure sensor'),
    ('co2', 'ppm', 300, 5000, 'environmental', 'CO2 concentration sensor'),
    ('vibration', 'mm/s', 0, 50, 'industrial', 'Vibration sensor'),
    ('light', 'lux', 0, 100000, 'environmental', 'Light intensity sensor'),
    ('motion', 'boolean', 0, 1, 'security', 'Motion detection sensor'),
    ('power', 'W', 0, 10000, 'energy', 'Power consumption sensor'),
    ('flow_rate', 'L/min', 0, 1000, 'industrial', 'Flow rate sensor'),
    ('sound_level', 'dB', 20, 120, 'environmental', 'Sound level sensor')
ON CONFLICT (sensor_type) DO NOTHING;

-- Main sensor data table (will be converted to hypertable)
CREATE TABLE IF NOT EXISTS sensor_data (
    time TIMESTAMPTZ NOT NULL,
    device_id VARCHAR(64) NOT NULL,
    sensor_type VARCHAR(50) NOT NULL,
    value DECIMAL(20, 6) NOT NULL,
    quality DECIMAL(3, 2) DEFAULT 1.0 CHECK (quality >= 0 AND quality <= 1),
    
    -- Data validation flags
    is_validated BOOLEAN DEFAULT true,
    is_anomaly BOOLEAN DEFAULT false,
    anomaly_score DECIMAL(3, 2) DEFAULT 0.0,
    
    -- Additional context
    metadata JSONB DEFAULT '{}',
    
    -- Composite primary key for deduplication
    PRIMARY KEY (device_id, sensor_type, time),
    
    -- Foreign keys
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (sensor_type) REFERENCES sensor_types(sensor_type)
);

-- Convert to TimescaleDB hypertable
SELECT create_hypertable('sensor_data', 'time', 
    chunk_time_interval => INTERVAL '1 day',
    if_not_exists => TRUE);

-- Create indexes for common queries
CREATE INDEX idx_sensor_data_device_time ON sensor_data (device_id, time DESC);
CREATE INDEX idx_sensor_data_type_time ON sensor_data (sensor_type, time DESC);
CREATE INDEX idx_sensor_data_anomaly ON sensor_data (time DESC) WHERE is_anomaly = true;

-- Enable compression (after 7 days)
ALTER TABLE sensor_data SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'device_id, sensor_type',
    timescaledb.compress_orderby = 'time DESC'
);

-- Add compression policy
SELECT add_compression_policy('sensor_data', INTERVAL '7 days');

-- Add retention policy (optional, keeps 1 year of raw data)
SELECT add_retention_policy('sensor_data', INTERVAL '1 year');

-- ============================================
-- CONTINUOUS AGGREGATES
-- ============================================

-- 1-minute aggregates
CREATE MATERIALIZED VIEW sensor_data_1min
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 minute', time) AS bucket,
    device_id,
    sensor_type,
    AVG(value) AS avg_value,
    MIN(value) AS min_value,
    MAX(value) AS max_value,
    COUNT(*) AS sample_count,
    SUM(value) AS sum_value,
    STDDEV(value) AS stddev_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY value) AS median_value,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY value) AS p95_value,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY value) AS p99_value,
    SUM(CASE WHEN is_anomaly THEN 1 ELSE 0 END) AS anomaly_count,
    AVG(quality) AS avg_quality
FROM sensor_data
GROUP BY bucket, device_id, sensor_type
WITH NO DATA;

-- 5-minute aggregates
CREATE MATERIALIZED VIEW sensor_data_5min
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('5 minutes', time) AS bucket,
    device_id,
    sensor_type,
    AVG(value) AS avg_value,
    MIN(value) AS min_value,
    MAX(value) AS max_value,
    COUNT(*) AS sample_count,
    STDDEV(value) AS stddev_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY value) AS median_value,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY value) AS p95_value
FROM sensor_data
GROUP BY bucket, device_id, sensor_type
WITH NO DATA;

-- 1-hour aggregates
CREATE MATERIALIZED VIEW sensor_data_1hour
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 hour', time) AS bucket,
    device_id,
    sensor_type,
    AVG(value) AS avg_value,
    MIN(value) AS min_value,
    MAX(value) AS max_value,
    COUNT(*) AS sample_count,
    STDDEV(value) AS stddev_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY value) AS median_value
FROM sensor_data
GROUP BY bucket, device_id, sensor_type
WITH NO DATA;

-- Daily aggregates
CREATE MATERIALIZED VIEW sensor_data_daily
WITH (timescaledb.continuous) AS
SELECT 
    time_bucket('1 day', time) AS bucket,
    device_id,
    sensor_type,
    AVG(value) AS avg_value,
    MIN(value) AS min_value,
    MAX(value) AS max_value,
    COUNT(*) AS sample_count,
    STDDEV(value) AS stddev_value
FROM sensor_data
GROUP BY bucket, device_id, sensor_type
WITH NO DATA;

-- Add refresh policies for continuous aggregates
SELECT add_continuous_aggregate_policy('sensor_data_1min',
    start_offset => INTERVAL '10 minutes',
    end_offset => INTERVAL '1 minute',
    schedule_interval => INTERVAL '1 minute');

SELECT add_continuous_aggregate_policy('sensor_data_5min',
    start_offset => INTERVAL '30 minutes',
    end_offset => INTERVAL '5 minutes',
    schedule_interval => INTERVAL '5 minutes');

SELECT add_continuous_aggregate_policy('sensor_data_1hour',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour');

SELECT add_continuous_aggregate_policy('sensor_data_daily',
    start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day');

-- ============================================
-- ALERT TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS alert_rules (
    rule_id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    device_id VARCHAR(64),
    sensor_type VARCHAR(50),
    condition_type VARCHAR(20) CHECK (condition_type IN ('threshold', 'rate_of_change', 'anomaly', 'offline')),
    condition_operator VARCHAR(10) CHECK (condition_operator IN ('>', '<', '>=', '<=', '==', '!=')),
    threshold_value DECIMAL(20, 6),
    time_window INTERVAL,
    severity VARCHAR(20) CHECK (severity IN ('info', 'warning', 'critical', 'emergency')),
    enabled BOOLEAN DEFAULT true,
    notification_channels TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE,
    FOREIGN KEY (sensor_type) REFERENCES sensor_types(sensor_type)
);

CREATE TABLE IF NOT EXISTS alerts (
    alert_id SERIAL PRIMARY KEY,
    rule_id INTEGER NOT NULL,
    device_id VARCHAR(64) NOT NULL,
    sensor_type VARCHAR(50),
    triggered_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    severity VARCHAR(20),
    value DECIMAL(20, 6),
    threshold DECIMAL(20, 6),
    message TEXT,
    acknowledged BOOLEAN DEFAULT false,
    acknowledged_by VARCHAR(100),
    acknowledged_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    
    FOREIGN KEY (rule_id) REFERENCES alert_rules(rule_id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
);

-- Convert alerts to hypertable for better performance
SELECT create_hypertable('alerts', 'triggered_at', 
    chunk_time_interval => INTERVAL '1 month',
    if_not_exists => TRUE);

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Function to get latest sensor reading for a device
CREATE OR REPLACE FUNCTION get_latest_reading(p_device_id VARCHAR, p_sensor_type VARCHAR)
RETURNS TABLE (
    time TIMESTAMPTZ,
    value DECIMAL,
    quality DECIMAL,
    is_anomaly BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT sd.time, sd.value, sd.quality, sd.is_anomaly
    FROM sensor_data sd
    WHERE sd.device_id = p_device_id 
    AND sd.sensor_type = p_sensor_type
    ORDER BY sd.time DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate sensor statistics for a time range
CREATE OR REPLACE FUNCTION get_sensor_stats(
    p_device_id VARCHAR,
    p_sensor_type VARCHAR,
    p_start_time TIMESTAMPTZ,
    p_end_time TIMESTAMPTZ
)
RETURNS TABLE (
    avg_value DECIMAL,
    min_value DECIMAL,
    max_value DECIMAL,
    stddev_value DECIMAL,
    sample_count BIGINT,
    anomaly_count BIGINT,
    uptime_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        AVG(value) AS avg_value,
        MIN(value) AS min_value,
        MAX(value) AS max_value,
        STDDEV(value) AS stddev_value,
        COUNT(*) AS sample_count,
        SUM(CASE WHEN is_anomaly THEN 1 ELSE 0 END) AS anomaly_count,
        (COUNT(*) * 100.0 / EXTRACT(EPOCH FROM (p_end_time - p_start_time))) AS uptime_percentage
    FROM sensor_data
    WHERE device_id = p_device_id
    AND sensor_type = p_sensor_type
    AND time BETWEEN p_start_time AND p_end_time;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PERFORMANCE OPTIMIZATIONS
-- ============================================

-- Create additional indexes for dashboard queries
CREATE INDEX idx_sensor_data_time_desc ON sensor_data (time DESC);
CREATE INDEX idx_devices_last_seen ON devices (last_seen DESC);
CREATE INDEX idx_alerts_unresolved ON alerts (triggered_at DESC) WHERE resolved_at IS NULL;

-- Create statistics for query planner
CREATE STATISTICS sensor_data_stats (dependencies) ON device_id, sensor_type FROM sensor_data;

-- ============================================
-- SAMPLE DATA FOR TESTING
-- ============================================

-- Insert sample devices
INSERT INTO devices (device_id, device_type, manufacturer, model, latitude, longitude, building, floor, zone, status)
VALUES 
    ('IOT-001', 'Environmental Monitor', 'Bosch', 'ENV-X200', 37.7749, -122.4194, 'Building-A', 3, 'North', 'online'),
    ('IOT-002', 'Industrial Sensor', 'Siemens', 'IND-Pro', 37.7751, -122.4180, 'Building-B', 1, 'South', 'online'),
    ('IOT-003', 'Smart Building', 'Honeywell', 'SB-Ultra', 37.7745, -122.4200, 'Building-A', 5, 'East', 'online')
ON CONFLICT (device_id) DO NOTHING;

-- Update location geometry
UPDATE devices 
SET location_geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE location_geom IS NULL AND latitude IS NOT NULL AND longitude IS NOT NULL;

-- ============================================
-- MAINTENANCE QUERIES
-- ============================================

-- Query to check hypertable chunk information
-- SELECT * FROM timescaledb_information.chunks WHERE hypertable_name = 'sensor_data';

-- Query to check compression status
-- SELECT * FROM timescaledb_information.compressed_chunk_stats WHERE hypertable_name = 'sensor_data';

-- Query to manually compress old chunks
-- SELECT compress_chunk(c) FROM show_chunks('sensor_data', older_than => INTERVAL '7 days') c;