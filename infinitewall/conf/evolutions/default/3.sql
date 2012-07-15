# timestamp turn to long

# --- !Ups
alter table chatlog alter column time bigint(20) NOT NULL;
alter table UserInChatRoom alter column time bigint(20) NOT NULL;
alter table chatlog add column if not exists kind varchar(255) NOT NULL;
CREATE SEQUENCE chatlog_timestamp start with 1000;
CREATE SEQUENCE userinchatroom_timestamp start with 1000;

CREATE TABLE WallLog (
    id bigint(20) NOT NULL,
    kind varchar(255) NOT NULL,
    message varchar(255) NOT NULL,
    time bigint(20) NOT NULL,
    wall_id bigint(20) NOT NULL,
    user_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

alter table WallLog add constraint fk_walllog_wall_1 foreign key (wall_id) references Wall (id) 
  on delete restrict on update restrict;
alter table WallLog add constraint fk_walllog_user_1 foreign key (user_id) references User (id) 
  on delete restrict on update restrict;

CREATE SEQUENCE walllog_timestamp start with 1000;
  
# --- !Downs

DROP TABLE WallLog;
DROP SEQUENCE chatlog_timestamp;
DROP SEQUENCE userinchatroom_timestamp;
alter table chatlog drop column if exists kind;
alter table chatlog alter column time timestamp NOT NULL;
alter table UserInChatRoom alter column time timestamp NOT NULL;