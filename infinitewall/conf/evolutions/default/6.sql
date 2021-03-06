# --- Test data

# --- !Ups

insert into User (id, email, hashedpw, permission) values (
	(select next value for user_seq),
	'wall@wall.com', '$2a$12$Sn0vi8ttwkzUFz9uKZkFUuklAYWLzGwlYgDRrPWXGaTBV1IM.josa', 2
);

insert into Wall (id, name, user_id, is_reference) values (
	(select next value for wall_seq),
	'First wall', (select id from User where email='wall@wall.com'), 0
);

# --- !Downs

delete from Wall where user_id = (select id from User where email='wall@wall.com');
delete from User where email='wall@wall.com';
