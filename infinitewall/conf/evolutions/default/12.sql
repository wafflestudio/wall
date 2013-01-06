# --- !Ups

create table WallInGroup (
	wall_id bigint(20) not null,
	group_id bigint(20) not null,  
  primary key(wall_id, group_id),
  constraint fk_wallingroup_wall_1 foreign key (wall_id) references Wall (id),
  constraint fk_wallingroup_group_1 foreign key (group_id) references UserGroup (id)
);

create index idx_wallingroup_wall_1 on WallInGroup (wall_id);
create index idx_wallingroup_group_1 on WallInGroup (group_id);

# --- !Downs

drop table WallInGroup;
