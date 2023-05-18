module tt

import os

const path = '${os.home_dir()}/.config/tt/records.jsonl'

struct Record {
	id   string
	tags []string
}

struct State {
mut:
	records   []Record
	tags      []string
	dirty     bool
	persisted bool
}

pub fn (mut state State) add(tag string) {
	if tag !in state.tags {
		k := extract_key(tag)
		state.tags = state.tags.filter(extract_key(it) != k)
		state.tags << tag
		state.dirty = true
	}
}

pub fn (mut state State) remove(tag string) {
	k := extract_key(tag)
	old_len := state.tags.len
	state.tags = state.tags.filter(extract_key(it) != k)
	if state.tags.len < old_len {
		state.dirty = true
	}
}

pub fn (mut state State) remove_prefix(tag string) {
	k := extract_key(tag)
	old_len := state.tags.len
	state.tags = state.tags.filter(!extract_key(it).starts_with(k))
	if state.tags.len < old_len {
		state.dirty = true
	}
}
