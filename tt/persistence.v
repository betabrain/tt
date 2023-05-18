module tt

import json
import os

pub fn (mut state State) persist_if_dirty() ! {
	if state.dirty {
		mut fd := os.open_append(tt.path)!
		defer {
			fd.close()
		}
		r := Record{
			id: new_id()
			tags: state.tags
		}
		fd.writeln(json.encode(r))!
		state.records << r
		state.dirty = false
		state.persisted = true
	}
}

pub fn load_state() !State {
	mut persisted := true
	records := os.read_lines(tt.path) or {
		persisted = false
		[]
	}.map(json.decode(Record, it)!)
	return State{
		records: records
		tags: if records.len > 0 { records.last().tags } else { []string{} }
		dirty: false
		persisted: persisted
	}
}
