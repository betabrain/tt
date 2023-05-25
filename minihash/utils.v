module minihash

import crypto.sha256

const crockford = '0123456789abcdefghjkmnpqrstvwxyz'

pub fn hash(data string) u64 {
	checksum := sha256.sum256(data.bytes())[..5]
	mut sum = u64(0)
	for c in checksum {
		sum *= 256
		sum += c
	}
	return sum
}
