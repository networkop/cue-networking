package nvue

import (
	"net"
)

_Input: {
	Hostname:   string
	ASN:        <=65535 & >=64512
	RouterID:   net.IPv4 & string
	LoopbackIP: "\(RouterID)/32"
	EnableIntfs: [...string]
	BGPIntfs: [...string]
	VRFs: [...{name: string}]
	PeerGroup: "underlay"
	BridgeDomain: "br_default"
}

config: [string]: set: {}

_input: _Input

_nvue: {
	system:    _system
	interface: _interfaces
	router: bgp: {
		_global_bgp
	}
	vrf: _vrf
}

_system: hostname: _input.Hostname

_global_bgp: {
	"autonomous-system": _input.ASN
	enable:              "on"
	"router-id":         _input.RouterID
}

_interfaces: {
	lo: {
		ip: address: "\(_input.LoopbackIP)": {}
		type: "loopback"
	}
	for intf in _input.EnableIntfs {"\(intf)": type: "swp"}
}

_vrf: {
	for vrf in _input.VRFs {
		"\(vrf.name)": {
			router: bgp: _vrf_bgp
			if vrf.name == "default" {
				router: bgp: neighbor:     _neighbor
				router: bgp: "peer-group": _peer_group
			}
		}
	}
}

_vrf_bgp: {
	"address-family": "ipv4-unicast": {
		enable: "on"
		redistribute: connected: enable: "on"
	}
	enable: "on"
}

_neighbor: {
	for intf in _input.BGPIntfs {
		"\(intf)": {
			"peer-group": "\(_input.PeerGroup)"
			type:         string | *"unnumbered"
		}
	}
}

_peer_group: "\(_input.PeerGroup)": {
	"address-family": "l2vpn-evpn": enable: "on"
	"remote-as": string | *"external"
}
