-- Table for ActivityType List object
CREATE TABLE <ENTITY>_list(
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,
        total_count NUMERIC
);
CREATE UNIQUE INDEX <ENTITY>_list_id ON <ENTITY>_list(remote_id); 

-- Join table for many to many between lists and entity. 
-- This name follows a pattern of list table name (ie activity_type_list) + _join
CREATE TABLE <ENTITY>_list_join(
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_id INTEGER,
        entity_list_id INTEGER,
        FOREIGN KEY(entity_id) REFERENCES <ENTITY>_entity(_id) ON DELETE CASCADE
        FOREIGN KEY(entity_list_id) REFERENCES <ENTITY>_list(_id) ON DELETE CASCADE
);
CREATE INDEX idx_<ENTITY>_list_join_entity_list_id ON <ENTITY>_list_join(entity_list_id);

-- Links table for the links/refs included for the object or the list 
CREATE TABLE <ENTITY>_links (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,

        link_key TEXT,
        link_id TEXT,
        link_name TEXT,
        link_href TEXT,

        -- key to the resource
        entity_id INTEGER,
        entity_list_id INTEGER,
        FOREIGN KEY(entity_id) REFERENCES <ENTITY>_entity(_id) ON DELETE CASCADE
        FOREIGN KEY(entity_list_id) REFERENCES <ENTITY>_list(_id) ON DELETE CASCADE
);
CREATE INDEX idx_<ENTITY>_links_entity_id ON <ENTITY>_links(entity_id);
CREATE INDEX idx_<ENTITY>_links_entity_list_id ON <ENTITY>_links(entity_list_id);

-- Meta table to track cached state
CREATE TABLE <ENTITY>_meta (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,

        -- time in s from 1/1/1970 the data was last updated in the cache
        update_time INTEGER,

        -- 0 - none 
        -- 1 - create
        pending_operation NUMERIC,

        -- Used to track which option an object is cached with
        options NUMERIC,

         -- key to the resource
        entity_id INTEGER,
        entity_list_id INTEGER,
        FOREIGN KEY(entity_id) REFERENCES <ENTITY>_entity(_id) ON DELETE CASCADE
        FOREIGN KEY(entity_list_id) REFERENCES <ENTITY>_list(_id) ON DELETE CASCADE
);
CREATE INDEX idx_<ENTITY>_meta_entity_id ON <ENTITY>_meta(entity_id);
CREATE INDEX idx_<ENTITY>_meta_entity_list_id ON <ENTITY>_meta(entity_list_id);
