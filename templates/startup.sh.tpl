#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

sudo apt-get update
sudo apt-get install -y unzip

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/${consul_version}/consul_${consul_version}_linux_amd64.zip

echo "Fetching Nomad..."
cd /tmp
curl -sLo nomad.zip https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_linux_amd64.zip

echo "Installing Nomad..."
unzip nomad.zip >/dev/null
sudo chmod +x nomad
sudo mv nomad /usr/local/bin/nomad

sudo echo "export NOMAD_ADDR=\"http://${nomad_alb}:4646\"" >> /home/ubuntu/.profile

echo "Fetch Jobs"
curl -sLo /home/ubuntu/http_test.hcl https://raw.githubusercontent.com/hashicorp/nomad-auto-join/master/jobs/http_test.hcl
curl -sLo /home/ubuntu/syslog.hcl https://raw.githubusercontent.com/hashicorp/nomad-auto-join/master/jobs/syslog.hcl


echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

echo "Running Consul..."
tee /var/consul-server-base.json > /dev/null <<EOF
${consul_config}
EOF

/usr/local/bin/consul agent -config-file="/var/consul-server-base.json" > /dev/null 2>&1 << /dev/null &