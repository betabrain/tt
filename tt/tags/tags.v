module tags

pub fn new_tag(tag string) !string {
	if tag.len == 0 {
		return error('tag may not be empty')
	} else if tag.contains(' ') {
		return error('tag may not contain whitespace')
	} else if tag.count(':') > 1 {
		return error('tag may not contain multiple : chars')
	} else {
		return tag
	}
}

pub fn extract_key(tag string) string {
	return if idx := tag.index(':') {
		tag[..idx]
	} else {
		tag
	}
}

pub fn extract_value(tag string) ?string {
	return if idx := tag.index(':') {
		tag[idx + 1..]
	} else {
		none
	}
}
