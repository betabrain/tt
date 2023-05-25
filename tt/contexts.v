module tt

[table: 'contexts']
struct Context {
	name      string [primary]
	tag       string
	activated string [default: 'CURRENT_TIMESTAMP'; sql_type: 'TIMESTAMP']
}

pub fn (app App) add_tag(tag string) ! {
	return error('not yet implemented')
}

pub fn (app App) remove_tag(t string) ! {
	sql app.db {
		delete from Context where name == '' && tag == t
	}!
}
