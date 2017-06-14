require "spec_helper"
require "serverspec"

package = "sensu-server"
service = "sensu-server"
config  = "/etc/sensu-server/sensu-server.conf"
user    = "sensu-server"
group   = "sensu-server"
ports   = [PORTS]
log_dir = "/var/log/sensu-server"
db_dir  = "/var/lib/sensu-server"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/sensu-server.conf"
  db_dir = "/var/db/sensu-server"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("sensu-server") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/sensu-server") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
