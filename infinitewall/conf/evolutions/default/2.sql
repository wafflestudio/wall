# Wall, Sheet, Content

# --- !Ups
 
CREATE TABLE Wall (
    id bigint(20) NOT NULL,
    name varchar(255) NOT NULL,
    pan_x double NOT NULL,
    pan_y double NOT NULL,
    zoom double NOT NULL,
    user_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE Sheet (
    id bigint(20) NOT NULL,
    x double NOT NULL,
    y double NOT NULL,
    width double NOT NULL,
    height double NOT NULL,
    wall_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE Content (
		id bigint(20) NOT NULL,
		title varchar(255) NOT NULL,
    content_type integer NOT NULL,
    sheet_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE TextContent (
		id bigint(20) NOT NULL,
    content text NOT NULL,
    scroll_x integer NOT NULL,
    scroll_y integer NOT NULL,
    content_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
)

CREATE SEQUENCE wall_seq start with 1000;
CREATE SEQUENCE sheet_seq start with 1000;
CREATE SEQUENCE content_seq start with 1000;
CREATE SEQUENCE textcontent_seq start with 1000;

alter table Wall add constraint fk_wall_user_1 foreign key (user_id) references User (id) 
  on delete restrict on update restrict;
alter table Sheet add constraint fk_sheet_wall_1 foreign key (wall_id) references Wall (id) 
  on delete restrict on update restrict;
alter table Content add constraint fk_content_sheet_1 foreign key (sheet_id) references Sheet (id) 
  on delete restrict on update restrict;
alter table TextContent add constraint fk_textcontent_content_1 foreign key (content_id) references Content (id) 
  on delete restrict on update restrict;
  
create index idx_wall_user_1 on Wall (user_id);
create index idx_sheet_wall_1 on Sheet (wall_id);
create index idx_content_sheet_1 on Content (sheet_id);
create index idx_textcontent_content_1 on TextContent (content_id);

# --- !Downs


drop table TextContent;
drop table Content;
drop table Sheet;
drop table Wall;

drop sequence wall_seq;
drop sequence sheet_seq;
drop sequence content_seq;
drop sequence textcontent_seq;