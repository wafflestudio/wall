# timestamp walllog

# --- !Ups

CREATE TABLE WallLog (
    id bigint(20) NOT NULL,
    kind varchar(255) NOT NULL,
    message varchar(255) NOT NULL,
    time bigint(20) NOT NULL,
    wall_id bigint(20) NOT NULL,
    user_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);
CREATE SEQUENCE walllog_seq start with 1000;

alter table WallLog add constraint fk_walllog_wall_1 foreign key (wall_id) references Wall (id) 
  on delete restrict on update restrict;
alter table WallLog add constraint fk_walllog_user_1 foreign key (user_id) references User (id) 
  on delete restrict on update restrict;

CREATE SEQUENCE walllog_timestamp start with 1000;
  
# --- !Downs

DROP SEQUENCE walllog_timestamp;
DROP SEQUENCE walllog_seq;
DROP TABLE WallLog;

