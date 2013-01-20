# Add Email verification/password reset token to user

# --- !Ups

alter table User add column verification_token varchar(255);
alter table User add column verified int DEFAULT 0 NOT NULL;
alter table User add column verification_token_date date;
alter table User add column verification_token_time time;

alter table User add column password_token varchar(255);
alter table User add column password_token_date date;
alter table User add column password_token_time time;

create index user_verification_token_idx on User (verification_token);
create index user_password_token_idx on User (password_token);


# --- !Downs
alter table User drop column password_token;
alter table User drop column password_token_date;
alter table User drop column password_token_time;

alter table User drop column verification_token_time;
alter table User drop column verification_token_date;
alter table User drop column verified;
alter table User drop column verification_token;
