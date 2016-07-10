FROM aws/openvpn:base
EXPOSE 443/tcp
CMD ["--cd", "/etc/openvpn", "--script-security", "2", "--log", \
  "/var/log/openvpn-tcp-server.log", "--config", \
  "/etc/openvpn/server-tcp.conf"]
