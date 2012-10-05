# ImageSheet

# --- !Ups

CREATE TABLE ImageContent (
		id bigint(20) NOT NULL,
    url text NOT NULL,
    width int NOT NULL,
    height int NOT NULL,
    sheet_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);


CREATE SEQUENCE imagecontent_seq start with 1000;

alter table ImageContent add constraint fk_imagecontent_sheet_1 foreign key (sheet_id) references Sheet (id) 
  on delete cascade on update restrict;
  
create index idx_imagecontent_sheet_1 on ImageContent (sheet_id);

# --- !Downs

drop table ImageContent if exists;

drop sequence imagecontent_seq if exists;
