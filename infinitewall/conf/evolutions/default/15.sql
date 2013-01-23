# --- Test data

# --- !Ups

alter table User alter column nickname varchar(255) default '' NOT NULL;
update User set nickname = 'infiniteWall' where email = 'wall@wall.com';

# --- !Downs

update User set nickname = '' where email = 'wall@wall.com';
alter table alter User column nickname varchar(255);
