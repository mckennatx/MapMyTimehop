-- Table for RatingBadge Entity
CREATE TABLE rating_badge_entity(
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,

        code TEXT,
        description TEXT,
        mobile_image_url TEXT
);
CREATE UNIQUE INDEX idx_rating_badge_remote_id ON rating_badge_entity(remote_id);