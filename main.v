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
			mut app := tt.load_app()!
			defer { app.close() }

			app.add_tag("test:true")!
			app.start_frame()!
			app.add_tag("other:tag")!
			app.stop_frame()!
			app.remove_tag("other")!
			app.remove_tag("test")!
		}
		disable_man: true
	}

	app.setup()
	app.parse(os.args)
}
