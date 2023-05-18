module tt

import time

struct Timeframe {
	id       string
	duration time.Duration
	tags     []string
}

pub fn (state State) timeframes() []Timeframe {
	mut records := []Record{}
	records << Record{
		id: '00000000000000000000000000'
	}
	records << state.records
	records << Record{
		id: new_id()
	}
	mut last := records[0]
	mut last_ts := time_from_ulid(last.id)
	mut timestamps := []Timeframe{}
	for r in records[1..] {
		ts := time_from_ulid(r.id)
		if last.tags.len > 0 {
			timestamps << Timeframe{
				id: last.id
				duration: time.Duration(ts - last_ts)
				tags: last.tags
			}
		}
		last = r
		last_ts = ts
	}
	return timestamps
}

fn color_tag(tag string) string {
	k := extract_key(tag)
	if v := extract_value(tag) {
		return '${yellow(k)}:${purple(v)}'
	} else {
		return '${yellow(k)}'
	}
}

fn per_tag_duration(durations map[string]time.Duration) {
	mut tags := durations.keys()
	tags.sort(a < b)
	if tags.len > 0 {
		println('')
		for tag in tags {
			d := durations[tag]
			println('                                               ${d.str():12}  ${color_tag(tag)}')
		}
		println('')
	}
}

pub fn (state State) display() {
	mut date := ''
	mut durations := map[string]time.Duration{}

	for timeframe in state.timeframes() {
		start := time_from_ulid(timeframe.id)
		end := start.add(timeframe.duration)
		tags := timeframe.tags.map(color_tag).join(', ')

		if start.local().ymmdd() != date {
			if date != '' {
				per_tag_duration(durations)
			}
			date = start.local().ymmdd()
			durations = {}
			println('--------${date}--------  --start----end---  --duration--  --------------- tags ---------------')
		}
		for tag in timeframe.tags {
			if tag !in durations {
				durations[tag] = time.Duration(0)
			}
			durations[tag] += timeframe.duration
		}
		println('${blue(timeframe.id)}  ${green(start.local().hhmmss())}–${red(end.local().hhmmss())}  ${timeframe.duration.str():12}  ${tags}')
	}
	per_tag_duration(durations)
}
