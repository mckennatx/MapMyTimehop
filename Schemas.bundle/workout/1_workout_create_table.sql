-- workout
-- Table for Workout Entity
-- 1_workout_create_table.sql
CREATE TABLE workout_entity (
        _id INTEGER PRIMARY KEY AUTOINCREMENT, -- 0
        remote_id TEXT,

        name TEXT,
        start_datetime INTEGER,
        start_locale_timezone TEXT, -- 4
        created_datetime INTEGER,
        updated_datetime INTEGER,
        reference_key TEXT,
        source TEXT,
        notes TEXT, -- 9
        
        -- Aggregates
        distance_total REAL,
        metabolic_energy_total REAL,
        active_time_total REAL,
        elapsed_time_total REAL,
        steps_total REAL, -- 14

        heartrate_min REAL,
        heartrate_max REAL,
        heartrate_avg REAL,

        speed_min REAL,
        speed_max REAL, -- 19
        speed_avg REAL,

        cadence_min REAL,
        cadence_max REAL,
        cadence_avg REAL,

        power_min REAL, -- 24
        power_max REAL,
        power_avg REAL,

        -- Documentation deliberately removed
        -- but data still in responses
        torque_min REAL,
        torque_max REAL,
        torque_avg REAL, -- 29

        has_time_series BOOLEAN,

        -- Undocumented at time of schema creation
        willpower REAL,
        is_verified BOOLEAN,
        facebook BOOLEAN,
        twitter BOOLEAN -- 34
);
CREATE UNIQUE INDEX idx_workout_entity_remote_id ON workout_entity(remote_id);