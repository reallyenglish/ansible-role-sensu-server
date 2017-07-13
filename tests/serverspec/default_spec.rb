require "spec_helper"
require "serverspec"

package = "sensu"
service = "sensu-server"
config_dir = "/etc/sensu"
log_dir = "/var/log/sensu"
user    = "sensu"
group   = "sensu"
# XXX bare-minimum server does not listen on any ports
ports   = []
default_user = "root"
default_group = "root"
embedded_bin_dir = "/opt/sensu/embedded/bin"
gem_binary = "#{embedded_bin_dir}/gem"
plugins = [
  "sensu-plugins-disk-checks",
  "sensu-plugins-load-checks"
]

case os[:family]
when "openbsd"
  user = "_sensu"
  group = "_sensu"
  default_group = "wheel"
  service = "sensu_server"
  # XXX duplicated but this allows same tests to run on all platforms
  embedded_bin_dir = "/bin"
  gem_binary = "gem"
when "freebsd"
  config_dir = "/usr/local/etc/sensu"
  default_group = "wheel"
  package = "sensu"
end
config = "#{config_dir}/config.json"

if os[:family] == "openbsd"
  describe package("sensu") do
    it do
      pending "the test does not find the gem"
      should be_installed.by("gem")
    end
  end

  describe command("gem list --local") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/^sensu\s\(/) }
  end
else
  describe package(package) do
    it { should be_installed }
  end
end

case os[:family]
when "openbsd"
  ["check-load.rb", "check-disk-usage.rb"].each do |f|
    describe file("/usr/local/bin/#{f}") do
      it { should exist }
      it { should be_symlink }
    end
  end
when "freebsd"
  describe file("/usr/local/etc/rc.d/sensu-server") do
    it { should exist }
    it { should be_file }
    it { should be_mode 755 }
    its(:content) { should_not match(/sensu_client/) }
  end
  path_to_patch_target = Specinfra.backend.run_command("#{gem_binary} content sensu-transport | grep 'lib/sensu/transport/rabbitmq.rb$'").stdout.strip
  describe file(path_to_patch_target) do
    it { should exist }
    it { should be_file }
    its(:content) { should match(/#{Regexp.escape(':user => (options.nil? || ! options.has_key?(:user)) ? "" : options[:user]')}/) }
  end
end

[
  "extensions",
  "plugins",
  "conf.d"
].each do |d|
  describe file("#{config_dir}/#{d}") do
    it { should exist }
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by user }
    it { should be_grouped_into group }
  end
end

describe file(log_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  # XXX currently, it is an empty json
  # its(:content) { should match Regexp.escape("sensu-server") }
end

describe file("#{config_dir}/conf.d/transport.json") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content_as_json) { should include("transport" => include("name" => "rabbitmq")) }
  its(:content_as_json) { should include("transport" => include("reconnect_on_error" => true)) }
end

plugins.each do |p|
  describe command("#{gem_binary} list #{p} -q | cut -d' ' -f1") do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    its(:stdout) { should match(/^#{Regexp.escape(p)}$/) }
  end
end

# XXX these unrealistic thresholds are intended not to cause failures in
# jenkins environment.
describe command("env PATH=\"#{embedded_bin_dir}:$PATH\" check-load.rb -c 1000,1000,1000 -w 900,900,900") do
  its(:stdout) { should match(/\s(?:OK):/) }
  its(:stderr) { should eq "" }
  its(:exit_status) { should eq 0 }
end

describe command("env PATH=\"#{embedded_bin_dir}:$PATH\" check-disk-usage.rb -I / -c 99 -w 99") do
  its(:stdout) { should match(/\s(?:OK):/) }
  its(:stderr) { should eq "" }
  its(:exit_status) { should eq 0 }
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
