module tt

import time

[table: 'frames']
struct Frame {
	start string [default: 'CURRENT_TIMESTAMP'; primary; sql_type: 'TIMESTAMP']
	end   string [default: '0000-00-00 00:00:00.000'; sql_type: 'TIMESTAMP']
	tags  string
}

pub fn (app App) current_frame() ?Frame {
	result := sql app.db {
		select from Frame where end < start
	} or { return none }
	if result.len == 1 {
		return result[0]
	} else {
		return none
	}
}

pub fn (app App) start_frame() ! {
	tags := sql app.db {
		select from Context where name == ''
	}!
	frame := Frame{
		tags: tags.map(it.tag).join_lines()
	}
	sql app.db {
		insert frame into Frame
	}!
}

pub fn (app App) stop_frame() ! {
	now := time.utc().format_ss_milli()
	sql app.db {
		update Frame set end = now where end < start
	}!
}
