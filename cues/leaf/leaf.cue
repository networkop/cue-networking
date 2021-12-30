package nvue

_Input: {
	BridgeVLANs: [...{
		vlan: int
		vni:  vlan
	}]
	AnycastMAC: string
	Bonds: [...{
		name: string
		members: [...string]
		access:       int
		mtu:          int
		mac:          _input.AnycastMAC
		segmentID:    int
		DFPreference: 50000
	}]
	MHIntfs: [...string]
	BGPIntfs: MHIntfs
	SVIs: [...{
		name:    string
		id:      int
		address: string
		vrf:     string
		vrr: {
			address: string
			mac:     string
		}
	}]
	VRFs: [...{
		name: string
		vni:  int
	}]
}

_input: {
	VRFs: [{
		name: "default"
		vni:  0
	}, {
		name: "RED"
		vni:  4001
	}, {
		name: "BLUE"
		vni:  4002
	}]
	BridgeVLANs: [
		{vlan: 10},
		{vlan: 20},
		{vlan: 30},
	]
	Bonds: [{
		name: "bond1"
		members: ["swp1"]
		access:    10
		mtu:       9000
		segmentID: 1
	}, {
		name: "bond2"
		members: ["swp2"]
		access:    20
		mtu:       9000
		segmentID: 2
	}, {
		name: "bond3"
		members: ["swp3"]
		access:    30
		mtu:       9000
		segmentID: 3
	}]
	MHIntfs: ["swp51", "swp52"]
}

_nvue: {
	bridge: domain: "\(_input.BridgeDomain)": vlan: _bridge_vlans
	evpn: {
		enable: "on"
		multihoming: enable: "on"
	}
	router: vrr: enable: "on"
	nve: vxlan: {
		"arp-nd-suppress": "on"
		enable:            "on"
		source: address: "\(_input.RouterID)"
	}
}

_bridge_vlans: {for m in _input.BridgeVLANs {
	"\(m.vlan)": vni: "\(m.vni)": {}}
}

_system: global: "anycast-mac": _input.AnycastMAC

_interfaces: {
	// Bond interfaces
	for b in _input.Bonds {
		"\(b.name)": {
			bond: {
				"lacp-bypass": "on"
				member: {for m in b.members {"\(m)": {}}}
			}
			bridge: domain: "\(_input.BridgeDomain)": access: b.access
			evpn: multihoming: segment: {
				"df-preference": b.DFPreference
				enable:          "on"
				"local-id":      b.segmentID
				"mac-address":   b.mac
			}
			link: mtu: b.mtu
			type: "bond"
		}
	}

	// EVPN MH interaces
	for intf in _input.MHIntfs {
		"\(intf)": {
			evpn: multihoming: uplink: "on"
			type: "swp"
		}
	}

	// SVI interfaces
	for svi in _input.SVIs {
		"\(svi.name)": {
			type: "svi"
			vlan: svi.id
			ip: {
				address: "\(svi.address)": {}
				vrf: svi.vrf
				vrr: {
					address: "\(svi.vrr.address)": {}
					enable:        "on"
					"mac-address": "\(svi.vrr.mac)"
					state: up: {}
				}
			}
		}
	}
}

_vrf: {
	for vrf in _input.VRFs {
		"\(vrf.name)": {
			if vrf.vni > 0 {
				router: bgp: "address-family": "ipv4-unicast": "route-export": "to-evpn": enable: "on"
				evpn: {
					enable: "on"
					vni: "\(vrf.vni)": {}
				}
				router: bgp: _global_bgp
			}
		}
	}
}
