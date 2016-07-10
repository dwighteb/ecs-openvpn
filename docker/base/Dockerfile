FROM alpine:latest
RUN (apk -Uuv add --no-cache openvpn iptables ca-certificates && \
  rm /var/cache/apk/*)
ONBUILD COPY openvpn /etc/openvpn
ONBUILD WORKDIR /etc/openvpn
ONBUILD RUN (mkdir -p /dev/net && \
  if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi)
ONBUILD ENTRYPOINT ["./openvpn-start.sh"]
