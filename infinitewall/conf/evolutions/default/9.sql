# --- Add more detail to user model (profile image, nickname)

# --- !Ups
alter table User add column nickname varchar(255);
alter table User add column picture_path varchar(255);

# --- !Downs
alter table User drop column picture_path;
alter table User drop column nickname;
