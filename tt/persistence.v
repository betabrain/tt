module tt

import json
import os
import rand
import time

pub fn (mut state State) persist_if_dirty() ! {
	if state.dirty {
		mut fd := os.open_append(path)!
		defer {
			fd.close()
		}
		r := Record{
			id: rand.ulid_at_millisecond(u64(state.now.unix_time_milli())).to_lower()
			tags: state.tags
		}
		fd.writeln(json.encode(r))!
		state.records << r
		state.records.sort(a.id < b.id)
		state.dirty = false
		state.persisted = true
	}
}

pub fn load_state(now time.Time) !State {
	mut persisted := true
	mut records := os.read_lines(path) or {
		persisted = false
		[]
	}.map(json.decode(Record, it)!)
	records.sort(a.id < b.id)
	mut cutoff_id := rand.ulid_at_millisecond(u64(now.unix_time_milli())).to_lower()
	cutoff_id = cutoff_id[..10] + 'zzzzzzzzzzzzzzzzzzzz'
	records = records.filter(it.id < cutoff_id)
	return State{
		now: now
		records: records
		tags: if records.len > 0 { records.last().tags } else { []string{} }
		dirty: false
		persisted: persisted
	}
}
