require 'spec_helper'

describe 'Packages are installed' do
  packages = ['openvpn', 'iptables', 'ca-certificates']

  packages.each do |the_package|
    describe package(the_package) do
      it { should be_installed }
    end
  end
end

describe 'Configuration files are present and have appropriate entries' do
  ['/etc/openvpn/server-tcp.conf', '/etc/openvpn/server-udp.conf'].each do |the_file|
    describe file(the_file) do
      it { should exist }
      its(:content) { should match /^tls-version-min 1.2/ }
      its(:content) { should match /^auth SHA256/ }
      its(:content) { should match /^dh dh4096.pem/ }
      its(:content) { should match /^remote-cert-tls client/ }
      its(:content) { should match /^chroot jail/ }
    end
  end

  describe file ('/etc/openvpn/jail/tmp') do
    it { should be_directory }
  end

  describe file ('/etc/openvpn/openvpn-start.sh') do
    it { should exist }
    its(:content) { should match /^exec openvpn $*/ }
    its(:content) { should match /.\/gets3files -bucket=private-dwighteb-com -directory=openvpn\/ -region=us-east-1 ca.crt crl.pem dh4096.pem server.crt server.key ta.key/ }
  end

  ['/etc/openvpn/openvpn.iptables', '/etc/openvpn/gets3files'].each do |the_file|
    describe file (the_file) do
      it { should exist }
    end
  end

  describe 'Credentials are not present in the image itself' do
    ['crl.pem', 'dh4096.pem', 'server.crt', 'server.key', 'ta.key'].each do |the_file|
      describe file("/etc/openvpn/#{the_file}") do
        it { should_not exist }
        its(:size) { should == 0 }
      end
    end
  end
  # with the way serverspec and docker api works, the entrypoint still seems
  # to run, thus a zero byte ca.crt is created.  Just want to make sure that
  # the file has no contents
  describe file('/etc/openvpn/ca.crt') do
    it { should exist }
    its(:size) { should == 0 }
  end
end
