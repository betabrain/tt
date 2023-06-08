module minihash

import rand

fn test_empty() {
	h := hash('')
	assert h.len == 8
	assert h == 'werc8gmr'
}

fn test_short_string() {
	h := hash('abcdefgh')
	assert h.len == 8
	assert h == 'khbcrmdk'
}

fn test_random_string() {
	r := rand.string(100)
	h1 := hash(r)
	h2 := hash(r)
	assert h1.len == 8
	assert h1 == h2
}

fn test_random_value() {
	r := random()!
	assert r.len == 8
}
