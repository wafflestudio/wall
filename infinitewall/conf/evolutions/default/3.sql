# timestamp turn to long

# --- !Ups
alter table chatlog alter column time bigint(20) NOT NULL;
alter table UserInChatRoom alter column time bigint(20) NOT NULL;
alter table chatlog add column if not exists kind varchar(255) NOT NULL;
CREATE SEQUENCE chatlog_timestamp start with 1000;
CREATE SEQUENCE userinchatroom_timestamp start with 1000;

# --- !Downs

DROP SEQUENCE chatlog_timestamp;
DROP SEQUENCE userinchatroom_timestamp;
alter table chatlog drop column if not exists kind;
alter table chatlog alter column time timestamp NOT NULL;
alter table UserInChatRoom alter column time timestamp NOT NULL;