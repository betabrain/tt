module utils

import strings
import tt.minihash
import crypto.rand

const crockford = '0123456789abcdefghjkmnpqrstvwxyz'

pub fn random() !string {
	mut result := strings.new_builder(8)
	for _ in 0 .. 8 {
		result << minihash.crockford[rand.int_u64(u64(32))!]
	}
	return result.str()
}
