module main

import tt
import os
import cli

fn main() {
	mut app := cli.Command{
		name: 'tt'
		description: 'time tracker'
		version: '0.0.1'
		execute: fn (cmd cli.Command) ! {
			mut state := tt.load_state()!

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
		]
		disable_man: true
	}

	app.setup()
	app.parse(os.args)
}
