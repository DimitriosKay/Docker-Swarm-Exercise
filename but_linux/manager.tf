# - - - CREATE PRIMARY VM INSTANCE - - - 
resource "google_compute_instance" "main" {
	name = "${var.name}-${formatdate("DDmmss", timestamp())}"
	machine_type = "${var.machine_type}"
	zone = "${var.zone}"
	tags = ["${var.name}"]
	boot_disk {
		initialize_params {
			image = "${var.image}"
		}
	}
	network_interface {
		network = "${var.network}"
		access_config {
		
		}
	}
	metadata = {
		sshKeys = "terraform:${file("${var.public_key}")}"
	}
	connection {
		type = "ssh"
		user = "terraform"
		host = "${google_compute_instance.main.network_interface.0.access_config.0.nat_ip}"
		private_key = "${file("${var.private_key}")}"
	}
	provisioner "remote-exec" {
		inline = [
			"${var.update_packages[var.package_manager]}",
			"${var.install_packages[var.package_manager]} ${join(" ", var.packages)}"
		]
	}
	provisioner "remote-exec" {
		scripts = [
                  "scripts/test_script",
                  "scripts/docker_tf_script",
                  "scripts/docker-compose_tf_script"
                ]
	}
}