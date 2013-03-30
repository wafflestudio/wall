# add when field to chatlog

# --- !Ups
ALTER TABLE ChatLog add column when bigint(20) NOT NULL default 0;

# --- !Downs
ALTER TABLE ChatLog drop column when;
