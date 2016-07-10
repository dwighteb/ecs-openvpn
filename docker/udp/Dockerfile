FROM aws/openvpn:base
EXPOSE 443/udp
CMD ["--cd", "/etc/openvpn", "--script-security", "2", "--log", \
  "/var/log/openvpn-udp-server.log", "--config", \
  "/etc/openvpn/server-udp.conf"]
