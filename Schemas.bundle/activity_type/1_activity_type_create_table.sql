-- Table for ActivityType Entity
CREATE TABLE activity_type_entity(
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,

        name TEXT,
        short_name TEXT,
        mets REAL,
        icon_url TEXT,
        has_children BOOLEAN
);
CREATE UNIQUE INDEX idx_activity_type_remote_id ON activity_type_entity(remote_id); 

-- Child table for ActivityType Entity for the mets
CREATE TABLE activity_type_entity_mets_speed(
        _id INTEGER PRIMARY KEY AUTOINCREMENT,

        mets REAL,
        speed REAL,
        
        entity_id INTEGER,
        FOREIGN KEY(entity_id) REFERENCES activity_type_entity(_id) ON DELETE CASCADE
);
CREATE INDEX activity_type_mets_speed_entity_id ON activity_type_entity_mets_speed(entity_id); 


