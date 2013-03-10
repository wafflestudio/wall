# chatlog detailed schema

# --- !Ups

truncate table ChatLog;
ALTER SEQUENCE Chatlog_Seq RESTART WITH 1000;
ALTER SEQUENCE Chatlog_Timestamp RESTART WITH 1000;
truncate table UserInChatRoom;
ALTER SEQUENCE userinchatroom_timestamp RESTART WITH 1000;

# --- !Downs
