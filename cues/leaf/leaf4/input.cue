package nvue

_input: {
	Hostname: "leaf4"
	ASN:      65104
	RouterID: "10.10.10.4"
	EnableIntfs: ["swp1", "swp2", "swp3"]
	AnycastMAC: "44:38:39:BE:EF:BB"
	SVIs: [{
		name:    "vlan10"
		id:      10
		address: "10.1.10.5/24"
		vrf:     "RED"
		vrr: {
			address: "10.1.10.1/24"
			mac:     "00:00:00:00:00:10"
		}
	}, {
		name:    "vlan20"
		id:      20
		address: "10.1.20.5/24"
		vrf:     "RED"
		vrr: {
			address: "10.1.20.1/24"
			mac:     "00:00:00:00:00:20"
		}
	}, {
		name:    "vlan30"
		id:      30
		address: "10.1.30.5/24"
		vrf:     "BLUE"
		vrr: {
			address: "10.1.30.1/24"
			mac:     "00:00:00:00:00:30"
		}
	}]
}

config: "\(_input.Hostname)": set: _nvue
