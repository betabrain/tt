module tt

fn test_key_extraction_no_value() {
	k := extract_key("k")
	assert k == "k"
}

fn test_key_extraction_with_value() {
	k := extract_key("k:v")
	assert k == "k"
}

fn test_value_extraction_no_value() {
	v := extract_value("k")
	assert v == none
}

fn test_value_extraction_with_value() {
	v := extract_value("k:v")
	if unwrapped := v {
		assert unwrapped == "v"
	} else {
		assert false
	}
}
