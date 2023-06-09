module tt

import db.sqlite
import os

const db_path = '${os.home_dir()}/.config/tt/tt.sqlite'

struct App {
mut:
	db sqlite.DB
}

pub fn load_app() !App {
	mut app := App{}
	app.db = sqlite.connect(tt.db_path)!
	sql app.db {
		create table Context
		create table Timeframe
	}!
	return app
}

pub fn (mut app App) close() {
	app.db.close() or {
		println('error: ${err}')
		exit(-1)
	}
}

pub fn (mut app App) reset() ! {
	os.rm(tt.db_path)!
	app = load_app()!
}
