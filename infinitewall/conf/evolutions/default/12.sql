# ImageSheet

# --- !Ups

CREATE TABLE SheetLink (
		id bigint(20) NOT NULL,
    from_id bigint(20) NOT NULL,
    to_id bigint(20) NOT NULL,
    wall_id  bigint(20) NOT NULL,
    PRIMARY KEY (id)
);

CREATE SEQUENCE sheetlink_seq start with 1000;
# --- !Downs

drop table SheetLink if exists;
drop sequence sheetlink_seq if exists;
