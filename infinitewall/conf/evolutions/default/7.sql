# --- Folders and links

# --- !Ups

create table Folder (
	id bigint(20) NOT NULL,
	name varchar(255) NOT NULL,
	parent_id bigint(20),
	user_id bigint(20) NOT NULL,
	primary key (id)
);

CREATE SEQUENCE folder_seq start with 1000;

alter table Folder add constraint fk_folder_user_1 foreign key (user_id) references User (id) 
  on delete cascade on update restrict;
  
alter table Wall add column folder_id bigint(20);

alter table Wall add constraint fk_wall_folder_1 foreign key (folder_id) references Folder (id) 
  on delete cascade;

# --- !Downs

alter table Wall drop constraint fk_wall_folder_1;

alter table Wall drop column folder_id;
alter table Folder drop constraint fk_folder_user_1;

DROP SEQUENCE folder_seq;
DROP table Folder;