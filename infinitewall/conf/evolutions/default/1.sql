# Initial Schema Generation
# case class User(id: Pk[Long], val email: String, val hashedPW: String, val permission: Permission)
# case class ChatLog(id:Pk[Long], message:String, time:Date, roomId: Long, userId:Long) 
# case class ChatRoom(id:Pk[Long], title: String)
# Chat room user presence

 
# --- !Ups
 
CREATE TABLE User (
    id bigint(20) NOT NULL,
    email varchar(255) NOT NULL,
    hashedpw varchar(255) NOT NULL,
    permission int NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (email)
);

CREATE TABLE ChatLog (
    id bigint(20) NOT NULL,
    message varchar(255) NOT NULL,
    time bigint(20) NOT NULL,
    chatroom_id bigint(20) NOT NULL,
    user_id bigint(20) NOT NULL,
    kind varchar(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE ChatRoom (
		id bigint(20) NOT NULL,
    title varchar(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE UserInChatRoom (
    user_id bigint(20) NOT NULL,
    chatroom_id bigint(20) NOT NULL,
    time bigint(20) NOT NULL,
    PRIMARY KEY(user_id, chatroom_id)
);

CREATE SEQUENCE user_seq start with 1000;
CREATE SEQUENCE chatlog_seq start with 1000;
CREATE SEQUENCE chatroom_seq start with 1000;
CREATE SEQUENCE chatlog_timestamp start with 1000;
CREATE SEQUENCE userinchatroom_timestamp start with 1000;

alter table ChatLog add constraint fk_chatlog_user_1 foreign key (user_id) references User (id) 
  on delete restrict on update restrict;
alter table ChatLog add constraint fk_chatlog_chatroom_1 foreign key (chatroom_id) references ChatRoom (id) 
  on delete restrict on update restrict;
  
alter table UserInChatRoom add constraint fk_userinchatroom_user_1 foreign key (user_id) references User (id) 
  on delete cascade on update restrict;
alter table UserInChatRoom add constraint fk_userinchatroom_chatroom_1 foreign key (chatroom_id) references ChatRoom (id) 
  on delete cascade on update restrict;
  
create index idx_userinchatroom_user_1 on UserInChatRoom (user_id);
create index idx_userinchatroom_chatroom_1 on UserInChatRoom (chatroom_id);
create index idx_chatlog_user_1 on chatlog (user_id);
create index idx_chatlog_chatroom_1 on chatlog (chatroom_id);

# --- !Downs

DROP SEQUENCE chatlog_timestamp;
DROP SEQUENCE userinchatroom_timestamp;
DROP SEQEUNCE user_seq;
DROP SEQEUNCE chatroom_seq;
DROP SEQEUNCE chatlog_seq;
 
DROP TABLE UserInChatRoom IF NOT EXIST; 
DROP TABLE User IF NOT EXIST;
DROP TABLE ChatLog IF NOT EXIST;
DROP TABLE ChatRoom IF NOT EXIST;
