# correct foreign key constraints for sheetlinks

# --- !Ups
delete from SheetLink where from_id NOT IN (select id from Sheet) or to_id NOT IN (select id from Sheet);
ALTER TABLE SheetLink add constraint fk_sheetlink_from_id foreign key (from_id) references Sheet (id) on delete cascade;

ALTER TABLE SheetLink add constraint fk_sheetlink_to_id foreign key (to_id) references Sheet (id) on delete cascade;


# --- !Downs

ALTER TABLE SheetLink drop constraint fk_sheetlink_from_id;

ALTER TABLE SheetLink drop constraint fk_sheetlink_to_id;
