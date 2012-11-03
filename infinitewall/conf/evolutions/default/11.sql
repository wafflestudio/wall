# Revision on Wall log

# --- !Ups
ALTER TABLE WallLog ADD COLUMN basetime bigint(20) DEFAULT 0 NOT NULL;

# --- !Downs
ALTER TABLE WallLog DROP COLUMN basetime;