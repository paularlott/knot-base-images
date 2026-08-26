<?php

/**
 * Enable SRV record lookups for hostnames
 */
class AdminerSRVLookup {

	function credentials() {
		if(preg_match('/:\d+$/', Adminer\SERVER)) {
			$host = Adminer\SERVER;
		}
		else {
			// Attempt a SRV record lookup
			$dns = dns_get_record(Adminer\SERVER, DNS_SRV);
			$host = $dns && count($dns) ? $dns[0]['host'] . ':' . $dns[0]['port'] : Adminer\SERVER;
		}

		return array($host, $_GET["username"], Adminer\get_password());
	}
}
