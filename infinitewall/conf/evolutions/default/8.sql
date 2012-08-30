# --- Group

# --- !Ups


create table UserGroup (
	id bigint(20) not null,
	primary key (id)
);

create table UserInGroup (
	group_id bigint(20) not null,  
	user_id bigint(20) not null,
  constraint fk_useringroup_user foreign key (user_id) references User (id),
  constraint fk_useringroup_group foreign key (group_id) references UserGroup (id)
);

create index idx_useringroup_user_1 on UserInGroup (user_id);
create index idx_useringroup_group_1 on UserInGroup (group_id);

# --- !Downs

drop table UserInGroup;
drop table UserGroup;
