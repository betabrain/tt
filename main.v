module main

import tt
import os
import cli
import time

fn main() {
	mut app := cli.Command{
		name: 'tt'
		description: 'time tracker'
		version: '0.0.1'
		execute: fn (cmd cli.Command) ! {
			now := time.parse_rfc3339(cmd.flags.get_string('time')!)!.local_to_utc()
			mut state := tt.load_state(now)!

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

			state.persist_if_dirty()!
			state.display()
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

	app.setup()
	app.parse(os.args)
}
