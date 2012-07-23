# Wall preference

 
# --- !Ups

CREATE TABLE WallPreference (
		id bigint(20) NOT NULL,
    alias varchar(255),
		pan_x double NOT NULL,
    pan_y double NOT NULL,
    zoom double NOT NULL,
    user_id bigint(20) NOT NULL,
    wall_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE ChatForWall (
		id bigint(20) NOT NULL,
		wall_id bigint(20) NOT NULL,
		chatroom_id bigint(20) NOT NULL,
		PRIMARY KEY (id)
);

CREATE SEQUENCE wall_preference_seq start with 1000;
CREATE SEQUENCE chat_for_wall_seq start with 1000;

alter table WallPreference add constraint fk_wallpreference_user_1 foreign key (user_id) references User (id) 
  on delete restrict on update restrict;
alter table WallPreference add constraint fk_wallpreference_wall_1 foreign key (wall_id) references Wall (id) 
  on delete restrict on update restrict;
  
alter table ChatForWall add constraint fk_chatforwall_chatroom_1 foreign key (chatroom_id) references ChatRoom (id) 
  on delete restrict on update restrict;
alter table ChatForWall add constraint fk_chatforwall_wall_1 foreign key (wall_id) references Wall (id) 
  on delete restrict on update restrict;

# --- !Downs

DROP SEQUENCE chat_for_wall_seq;
DROP SEQUENCE wall_preference_seq;
DROP TABLE ChatForWall;
DROP TABLE WallPreference;
