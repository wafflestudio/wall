# --- Group

# --- !Ups


create table UserGroup (
	id bigint(20) not null,
	primary key (id)
);


# --- !Downs

drop table UserGroup