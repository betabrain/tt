module tt

import db.sqlite
import os

const db_path = '${os.home_dir()}/.config/tt/records.sqlite'

[table: 'records']
struct DbRecord {
	id   string [primary]
	tags string
}

pub fn store_record(record Record) ! {
	db := sqlite.connect(tt.db_path)!

	id := new_id()
	tmp := DbRecord{
		id: record.id
		tags: record.tags.join_lines()
	}

	sql db {
		create table DbRecord
		insert tmp into DbRecord
	}!

	count := sql db {
		select count from DbRecord
	}!

	println('changes: ${count}')
}
