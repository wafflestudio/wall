# --- Test data

# --- !Ups

update User set nickname = 'infiniteWall' where email = 'wall@wall.com';
update User set nickname = '' where nickname = null;
alter table User alter column nickname varchar(255) default '' NOT NULL;


# --- !Downs

alter table User alter column nickname varchar(255);
update User set nickname = '' where email = 'wall@wall.com';