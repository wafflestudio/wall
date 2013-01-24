# --- Test data

# --- !Ups

update User set nickname = 'infiniteWall' where email = 'wall@wall.com'

# --- !Downs

update User set nickname = '' where email = 'wall@wall.com'
