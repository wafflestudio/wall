# database timestamp


# --- !Ups

create table activerecord (initialized_timestamp timestamp NOT NULL);
insert into activerecord VALUES(current_timestamp());


# --- !Downs

drop table activerecord;