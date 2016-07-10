require 'serverspec'

set :backend, :docker

RSpec.configure do |c|
  c.docker_image = 'aws/openvpn:udp'
  if ENV['ASK_SUDO_PASSWORD']
    require 'highline/import'
    c.sudo_password = ask("Enter sudo password: ") { |q| q.echo = false }
  else
    c.sudo_password = ENV['SUDO_PASSWORD']
  end
end
