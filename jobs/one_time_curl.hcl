job "one-time-test" {
	datacenters = ["dc1"]
	type 		= "batch"

	group "wgroup" {
		count = 1

		task "ping" {
			driver = "exec"

			config {
				command = "/usr/bin/curl"
				args = ["http://10.1.1.38:8080/this-only-once"]
			}
		}
	}
}