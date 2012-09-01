# Referential tables

# --- !Ups


CREATE TABLE WallFork (
		id bigint(20) NOT NULL,
    origin_id bigint(20) NOT NULL,
    fork_id bigint(20) NOT NULL,
    time bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE WallReference (
		id bigint(20) NOT NULL,
    referring_id bigint(20) NOT NULL,
    referrer_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE SheetFork (
		id bigint(20) NOT NULL,
    origin_id bigint(20) NOT NULL,
    fork_id bigint(20) NOT NULL,
    time bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE SheetReference (
		id bigint(20) NOT NULL,
    referring_id bigint(20) NOT NULL,
    referrer_id bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

alter table WallFork add constraint fk_wallfork_origin_1 foreign key (origin_id) references Wall (id) 
  on delete cascade on update restrict;
alter table WallFork add constraint fk_wallfork_fork_1 foreign key (fork_id) references Wall (id) 
  on delete cascade on update restrict;

alter table SheetFork add constraint fk_sheetfork_origin_1 foreign key (origin_id) references Sheet (id) 
  on delete cascade on update restrict;
alter table SheetFork add constraint fk_sheetfork_fork_1 foreign key (fork_id) references Sheet (id) 
  on delete cascade on update restrict;
  
alter table WallReference add constraint fk_wallreference_refererring_1 foreign key (referring_id) references Wall (id) 
  on delete cascade on update restrict;
alter table WallReference add constraint fk_wallreference_referrer_1 foreign key (referrer_id) references Wall (id) 
  on delete cascade on update restrict;

alter table SheetReference add constraint fk_sheetreference_referring_1 foreign key (referring_id) references Sheet (id) 
  on delete cascade on update restrict;
alter table SheetReference add constraint fk_sheetreference_referrer_1 foreign key (referrer_id) references Sheet (id) 
  on delete cascade on update restrict;

alter table Wall add column is_reference integer NOT NULL DEFAULT 0;
alter table Sheet add column is_reference integer NOT NULL DEFAULT 0;

# --- !Downs


alter table Sheet drop column is_reference;
alter table Wall drop column is_reference;

DROP table SheetReference;
DROP table WallReference;
DROP table SheetFork;
DROP table WallFork;

