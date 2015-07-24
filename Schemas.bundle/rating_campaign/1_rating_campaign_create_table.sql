-- Table for RatingCampaign Entity
CREATE TABLE rating_campaign_entity(
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        remote_id TEXT,

        short_name TEXT,
        title TEXT,
        pre_logo_text TEXT,
        no_badge_selected_text TEXT,
        mobile_sponsor_logo_url TEXT,
        note_autofill_text TEXT,
        start_datetime_utc INTEGER,
        end_datetime_utc INTEGER
);
CREATE UNIQUE INDEX idx_rating_campaign_remote_id ON rating_campaign_entity(remote_id);