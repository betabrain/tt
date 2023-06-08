module minihash

import strings
import crypto.rand
import crypto.sha256

const crockford = '0123456789abcdefghjkmnpqrstvwxyz'

pub fn hash(data string) string {
	checksum := sha256.sum256(data.bytes())[..5]
	mut sum := u64(0)
	for c in checksum {
		sum *= 256
		sum += c
	}
	mut result := strings.new_builder(8)
	for _ in 0 .. 8 {
		result << minihash.crockford[sum % 32]
		sum /= 32
	}
	return result.str().reverse()
}

pub fn random() !string {
	mut result := strings.new_builder(8)
	for _ in 0 .. 8 {
		result << minihash.crockford[rand.int_u64(u64(32))!]
	}
	return result.str()
}
