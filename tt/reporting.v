module tt

import time
import strings

pub enum Grouping {
	day
	week
	month
	quarter
	year
}

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

fn per_tag_duration(grouping Grouping, durations map[string]time.Duration) {
	mut tags := durations.keys()
	tags.sort(a < b)
	if tags.len > 0 {
		println('')
		for tag in tags {
			d := durations[tag]
			s := match grouping {
				.day, .week, .month { 61 }
				.quarter, .year { 69 }
			}
			w := strings.repeat(32, s)
			println('${w}${d.str():12}  ${color_tag(tag)}')
		}
		println('')
	}
}

fn group_key(grouping Grouping, t time.Time) string {
	return match grouping {
		.day { t.ymmdd() }
		.week { t.custom_format('YYYY-ww') }
		.month { t.custom_format('MMM YYYY') }
		.quarter { 'Q' + t.custom_format('Q YYYY') }
		.year { t.custom_format('YYYY') }
	}
}

fn group_inner_time(grouping Grouping, t time.Time) string {
	return match grouping {
		.day, .week, .month { t.custom_format('ddd DD hh:mm:ss') }
		.quarter, .year { t.custom_format('MMM ddd DD hh:mm:ss') }
	}
}

fn format_header(grouping Grouping, key string) string {
	mut b := strings.new_builder(120)

	// header with group key
	mut m := 26 - key.len
	mut l := m / 2
	b.write_string(strings.repeat(u8(45), l))
	b.write_string(key)
	b.write_string(strings.repeat(u8(45), m - l))

	// inner time headers
	s := match grouping {
		.day, .week, .month { 15 }
		.quarter, .year { 19 }
	}

	// start
	m = s - 5
	l = m / 2
	b.write_string('  ')
	b.write_string(strings.repeat(45, l))
	b.write_string('start')
	b.write_string(strings.repeat(45, l))

	// end
	m = s - 3
	l = m / 2
	b.write_string(' ')
	b.write_string(strings.repeat(45, l))
	b.write_string('end')
	b.write_string(strings.repeat(45, l))

	// remaining headers
	b.write_string('  --duration--')
	b.write_string('  ----------------tags----------------')
	println(b.len)
	return b.str()
}

pub fn (state State) report(grouping Grouping) {
	mut last_key := ''
	mut durations := map[string]time.Duration{}

	for timeframe in state.timeframes() {
		start := time_from_ulid(timeframe.id)
		end := start.add(timeframe.duration)
		tags := timeframe.tags.map(color_tag).join(', ')
		key := group_key(grouping, start.local())

		if last_key != key {
			per_tag_duration(grouping, durations)
			last_key = key
			durations = {}
			println(format_header(grouping, last_key))
		}
		for tag in timeframe.tags {
			if tag !in durations {
				durations[tag] = time.Duration(0)
			}
			durations[tag] += timeframe.duration
		}

		inner_start := group_inner_time(grouping, start.local())
		inner_end := group_inner_time(grouping, end.local())
		println('${blue(timeframe.id)}  ${green(inner_start)}–${red(inner_end)}  ${timeframe.duration.str():12}  ${tags}')
	}
	per_tag_duration(grouping, durations)
}
