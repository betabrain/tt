module tt

import tt.tags

[table: 'context']
struct Context {
	key   string [primary]
	value string
}

pub fn (app App) current_context() []string {
	result := sql app.db {
		select from Context
	} or { return [] }
	return result.map('${it.key}:${it.value}')
}

pub fn (app App) add_tag(tag string) ! {
	ctx := Context{
		key: tags.extract_key(tag)
		value: tags.extract_value(tag) or { '' }
	}
	sql app.db {
		delete from Context where key == ctx.key
		insert ctx into Context
	}!
}

pub fn (app App) remove_tag(tag string) ! {
	sql app.db {
		delete from Context where key == tags.extract_key(tag)
	}!
}
