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

CREATE TABLE ChatRoomForWall (
		id bigint(20) NOT NULL,
		wall_id bigint(20) NOT NULL,
		chatroom_id bigint(20) NOT NULL,
		PRIMARY KEY (id)
);

CREATE SEQUENCE wallpreference_seq start with 1000;
CREATE SEQUENCE chatroomforwall_seq start with 1000;

alter table WallPreference add constraint fk_wallpreference_user_1 foreign key (user_id) references User (id) 
  on delete cascade on update restrict;
alter table WallPreference add constraint fk_wallpreference_wall_1 foreign key (wall_id) references Wall (id) 
  on delete cascade on update restrict;
  
alter table ChatRoomForWall add constraint fk_chatroomforwall_chatroom_1 foreign key (chatroom_id) references ChatRoom (id) 
  on delete cascade on update restrict;
alter table ChatRoomForWall add constraint fk_chatroomforwall_wall_1 foreign key (wall_id) references Wall (id) 
  on delete cascade on update restrict;

# --- !Downs

DROP SEQUENCE chatroomforwall_seq;
DROP SEQUENCE wallpreference_seq;
DROP TABLE ChatRoomForWall;
DROP TABLE WallPreference;
