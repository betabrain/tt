module main

import tt
import os
import cli
import time
import math
import rand

fn main() {
	mut app := cli.Command{
		name: 'tt'
		description: 'time tracker'
		version: '0.0.1'
		execute: fn (cmd cli.Command) ! {
			// parse the time parameter and apply the local offset because parse defaults to UTC
			mut now_string := cmd.flags.get_string('time')!
			if !now_string.contains('Z') {
				offset := int(math.ceil(time.Duration(time.now() - time.utc()).minutes()))
				now_string += '${offset / 60:+02}:${offset % 60:02}'
			}
			mut now := time.parse_iso8601(now_string)!.local_to_utc()

			// load the application state
			mut state := tt.load_state(now)!

			// apply all tag flags
			for flag in cmd.flags {
				match flag.name {
					'add' {
						for tag in flag.get_strings()! {
							state.add(tag)
						}
					}
					'remove' {
						for tag in flag.get_strings()! {
							state.remove(tag)
						}
					}
					'remove-prefix' {
						for tag in flag.get_strings()! {
							state.remove_prefix(tag)
						}
					}
					else {}
				}
			}

			// persist state if necessary
			state.persist_if_dirty()!

			// reporting
			grouping := match cmd.flags.get_string('group')!.to_lower() {
				'day' { tt.Grouping.day }
				'week' { tt.Grouping.week }
				'month' { tt.Grouping.month }
				'quarter' { tt.Grouping.quarter }
				'year' { tt.Grouping.year }
				else { tt.Grouping.week }
			}
			state.report(grouping)
		}
		flags: [
			cli.Flag{
				flag: .string_array
				name: 'add'
				abbrev: 'a'
				description: 'add a tag'
			},
			cli.Flag{
				flag: .string_array
				name: 'remove'
				abbrev: 'r'
				description: 'remove a tag'
			},
			cli.Flag{
				flag: .string_array
				name: 'remove-prefix'
				abbrev: 'rp'
				description: 'remove all tags by prefix'
			},
			cli.Flag{
				flag: .string
				name: 'time'
				abbrev: 't'
				description: 'use time other than now'
				default_value: [time.now().format_rfc3339()]
			},
			cli.Flag{
				flag: .string
				name: 'group'
				abbrev: 'g'
				description: 'what to group the output by'
				default_value: ['week']
			},
		]
		disable_man: true
	}

	app.add_command(cli.Command{
		name: 'dump'
		description: 'dump the state for debugging'
		execute: fn (cmd cli.Command) ! {
			state := tt.load_state(time.utc())!
			dump(state)
		}
	})

	app.add_command(cli.Command{
		name: 'dummy-data'
		description: 'generate dummy data for testing'
		execute: fn (cmd cli.Command) ! {
			mut now := time.utc().add(-500 * 24 * time.hour)
			mut state := tt.load_state(now)!
			tags := ['work:a', 'work:b', 'work:c', 'home:a', 'home:b', 'chores', 'paperwork',
				'testing']

			for i in 0 .. 500 * 12 {
				if i % 500 == 0 {
					println('generating... ${i}/${500 * 12}')
				}
				for tag in rand.choose(tags, 3)! {
					state.add(tag)
				}
				for tag in rand.choose(tags, 4)! {
					state.remove(tag)
				}
				state.persist_if_dirty()!
				now = now.add(111 * time.minute)
				state = tt.load_state(now)!
			}

			state.report(tt.Grouping.month)
		}
	})

	app.setup()
	app.parse(os.args)
}
