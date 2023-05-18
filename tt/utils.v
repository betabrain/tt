module tt

import time
import rand

const crockford = '0123456789abcdefghjkmnpqrstvwxyz'

fn new_id() string {
	return rand.ulid().to_lower()
}

fn time_from_ulid(ulid string) time.Time {
	mut timestamp := u64(0)
	for c in ulid[..10] {
		timestamp *= 32
		timestamp += u64(tt.crockford.index_u8(c))
	}

	seconds := i64(timestamp / 1000)
	microseconds := int((timestamp % 1000) * 1000)
	return time.unix2(seconds, microseconds)
}
