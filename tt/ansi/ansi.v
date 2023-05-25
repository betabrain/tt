module ansi

pub fn blue(s string) string {
	return '\033[0;34m${s}\033[0m'
}

pub fn green(s string) string {
	return '\033[0;32m${s}\033[0m'
}

pub fn purple(s string) string {
	return '\033[0;35m${s}\033[0m'
}

pub fn red(s string) string {
	return '\033[0;31m${s}\033[0m'
}

pub fn yellow(s string) string {
	return '\033[1;33m${s}\033[0m'
}
