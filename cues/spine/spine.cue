package nvue

_vrf_bgp: "address-family": "l2vpn-evpn": enable: "on"

_input: {
	EnableIntfs: ["swp1", "swp2", "swp3", "swp4"]
	BGPIntfs: EnableIntfs
	VRFs: [{name: "default"}]
	ASN: 65199
}
