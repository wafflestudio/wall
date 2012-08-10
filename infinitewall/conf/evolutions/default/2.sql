# Wall, Sheet, Content

# --- !Ups

insert into User values (
	(select next value for user_seq),
	'admin@infinitewall.com', '$2a$12$mfsXZmFLWCbh4fotGDNsVOhojQ9MH0Imjmsf53NOeGRS19/1fMZcq', 2
);


CREATE TABLE Wall (
    id bigint(20) NOT NULL,
    name varchar(255) NOT NULL,
    user_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE Sheet (
    id bigint(20) NOT NULL,
    x double NOT NULL,
    y double NOT NULL,
    width double NOT NULL,
    height double NOT NULL,
    title varchar(255) NOT NULL,
    content_type integer NOT NULL,
    wall_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
); 


CREATE TABLE TextContent (
		id bigint(20) NOT NULL,
    content text NOT NULL,
    scroll_x int NOT NULL,
    scroll_y int NOT NULL,
    sheet_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);


CREATE SEQUENCE wall_seq start with 1000;
CREATE SEQUENCE sheet_seq start with 1000;
CREATE SEQUENCE textcontent_seq start with 1000;

alter table Wall add constraint fk_wall_user_1 foreign key (user_id) references User (id) 
  on delete cascade on update restrict;
alter table Sheet add constraint fk_sheet_wall_1 foreign key (wall_id) references Wall (id) 
  on delete cascade on update restrict;
alter table TextContent add constraint fk_textcontent_sheet_1 foreign key (sheet_id) references Sheet (id) 
  on delete cascade on update restrict;
  
create index idx_wall_user_1 on Wall (user_id);
create index idx_sheet_wall_1 on Sheet (wall_id);
create index idx_textcontent_sheet_1 on TextContent (sheet_id);

# --- !Downs

drop table TextContent if exists;
drop table Sheet if exists;
drop table Wall if exists;

drop sequence wall_seq if exists;
drop sequence sheet_seq if exists;
drop sequence textcontent_seq if exists;