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

pub fn (mut app App) add_tag(tag string) ! {
	stopped := app.current_frame() == none
	if !stopped {
		app.stop_frame()!
	}
	ctx := Context{
		key: tags.extract_key(tag)
		value: tags.extract_value(tag) or { '' }
	}
	tag_key := ctx.key
	sql app.db {
		delete from Context where key == tag_key
		insert ctx into Context
	}!
	if !stopped {
		app.start_frame()!
	}
}

pub fn (app App) remove_tag(tag string) ! {
	tag_key := tags.extract_key(tag)
	sql app.db {
		delete from Context where key == tag_key
	}!
}
