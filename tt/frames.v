module tt

import time
import json

[table: 'timeframes']
struct Timeframe {
	start string [default: 'CURRENT_TIMESTAMP'; primary; sql_type: 'TIMESTAMP']
	end   string [sql_type: 'TIMESTAMP']
	tags  string
}

pub fn (mut app App) current_frame() ?Timeframe {
	result := sql app.db {
		select from Timeframe where end == ''
	} or { return none }
	if result.len == 1 {
		return result[0]
	} else {
		return none
	}
}

pub fn (app App) start_frame() ! {
	frame := Timeframe{
		tags: json.encode(app.current_context())
	}
	sql app.db {
		insert frame into Timeframe
	}!
}

pub fn (app App) stop_frame() ! {
	now := time.utc().format_ss_milli()
	sql app.db {
		update Timeframe set end = now where end == ''
	}!
}
