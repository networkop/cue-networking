package nvue

import (
	"tool/exec"
	"tool/cli"
	"tool/file"
	"encoding/json"
	"encoding/yaml"
	"strings"
)

host: *"spine1" | string @tag(host) // you can use "-t host=spine2" to change the output file

devices: [ for k, v in config if k != "" {v.set.system.hostname}]

command: diff: {
	diff: exec.Run & {
		cmd: ["dyff", "between", "-b", "../originals/\(host).yml", "-"]
		stdin:  yaml.Marshal(config[host])
		stdout: string
	}

	display: cli.Print & {
		text: diff.stdout
	}
}

diffResult: [string]: {}

command: cmp: {
	for d in devices {
		diffResult: {
			"\(d)": exec.Run & {
				cmd: ["dyff", "between", "-b", "../originals/\(d).yml", "-"]
				stdin:  yaml.Marshal(config[d])
				stdout: string
			}
		}

		"show-\(d)": cli.Print & {
			text: "diff for \(d):\n" + diffResult["\(d)"].stdout
		}
	}
}

command: ls: {
	list: cli.Print & {
		text: "- Identified Devices -\n" + strings.Join(devices, "\n")
	}
}

command: save: {
	for d in devices {
		"\(d)-print": cli.Print & {
			text: "saving \(d) in ../new/\(d).yml"
		}

		"\(d)-write": file.Create & {
			filename: "../new/\(d).yml"
			contents: yaml.Marshal(config[d])
		}
	}
}

command: j: {
	dump: cli.Print & {
		text: json.Marshal(config)
	}
}

command: y: {
	dump: cli.Print & {
		text: yaml.Marshal(config)
	}
}
