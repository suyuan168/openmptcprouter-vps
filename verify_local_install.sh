#!/bin/bash
set -e

echo "=== Verifying Local Installation Path ==="
echo ""

# 1. Check all required source archives
echo "[1/3] Checking source archives..."
SOURCES=(
    "sources/shadowsocks-libev.tar.gz"
    "sources/simple-obfs.tar.gz"
    "sources/MLVPN.tar.gz"
    "sources/ubond.tar.gz"
    "sources/glorytun-udp.tar.gz"
    "sources/glorytun-tcp.tar.gz"
    "sources/dsvpn.tar.gz"
    "sources/mptcpize.tar.gz"
    "sources/iproute2.tar.gz"
    "sources/iperf-3.18.tar.gz"
    "sources/iperf3_3.18-2.debian.tar.xz"
    "sources/openmptcprouter-vps-admin-*.zip"
    "sources/v2ray-plugin-linux-amd64-v4.43.0.tar.gz"
    "sources/glorytun-0.0.35.tar.gz"
    "sources/EasyRSA-unix-v3.2.2.tgz"
    "sources/001-fix-compilation-errors-gcc14.patch"
    "sources/002-fix-crypto-aead-pointer-types.patch"
)

missing_sources=0
for src in "${SOURCES[@]}"; do
    if ! ls $src >/dev/null 2>&1; then
        echo "  ❌ Missing: $src"
        ((missing_sources++))
    fi
done

if [ $missing_sources -eq 0 ]; then
    echo "  ✅ All ${#SOURCES[@]} source archives present"
else
    echo "  ❌ $missing_sources source archives missing"
fi

# 2. Check all required config files
echo ""
echo "[2/3] Checking config files..."
CONFIGS=(
    "shadowsocks.conf"
    "shadowsocks.6.1.conf"
    "shadowsocks.6.18.conf"
    "shadowsocks-go.server.json"
    "v2ray-server.json"
    "v2ray.service"
    "xray-server.json"
    "xray-vless-reality.json"
    "xray.service"
    "iperf3.service.in"
    "iperf3.override.conf"
    "fail2ban-jail-openmptcprouter.conf"
    "fail2ban-filter-openvpn.conf"
    "openvpn-tun0.conf"
    "openvpn-tun1.conf"
    "openvpn-tun0.6.1.conf"
    "openvpn-tun1.6.1.conf"
    "openvpn-bonding1.conf"
    "openvpn-bonding2.conf"
    "openvpn-bonding3.conf"
    "openvpn-bonding4.conf"
    "openvpn-bonding5.conf"
    "openvpn-bonding6.conf"
    "openvpn-bonding7.conf"
    "openvpn-bonding8.conf"
    "mlvpn0.conf"
    "mlvpn.network"
    "mlvpn@.service.in"
    "ubond0.conf"
    "ubond.network"
    "ubond@.service.in"
    "glorytun-tcp-run"
    "glorytun-tcp@.service.in"
    "glorytun-tcp-post.sh"
    "tun0.glorytun"
    "glorytun-udp-run"
    "glorytun-udp@.service.in"
    "glorytun-udp-post.sh"
    "tun0.glorytun-udp"
    "dsvpn-run"
    "dsvpn-server@.service.in"
    "dsvpn0-config"
    "omr-update"
    "omr-update.service.in"
    "omr-admin.service.in"
    "omr.service.in"
    "omr-6in4-run"
    "omr6in4@.service.in"
    "omr-bypass"
    "omr-bypass.service.in"
    "omr-bypass.timer.in"
    "multipath"
    "omr-test-speed"
    "omr-test-speedv6"
    "omr-service"
    "shadowsocks-libev-manager@.service.in"
    "manager.json"
    "update-grub.sh"
    "openmptcprouter-shorewall.tar.gz"
    "openmptcprouter-shorewall6.tar.gz"
)

missing_configs=0
for cfg in "${CONFIGS[@]}"; do
    if [ ! -f "$cfg" ]; then
        echo "  ❌ Missing: $cfg"
        ((missing_configs++))
    fi
done

if [ $missing_configs -eq 0 ]; then
    echo "  ✅ All ${#CONFIGS[@]} config files present"
else
    echo "  ❌ $missing_configs config files missing"
fi

# 3. Check script syntax
echo ""
echo "[3/3] Checking script syntax..."
if sh -n debian9-x86_64.sh 2>/dev/null; then
    echo "  ✅ Script syntax valid"
else
    echo "  ❌ Script syntax error"
fi

# Summary
echo ""
echo "=== Summary ==="
if [ $missing_sources -eq 0 ] && [ $missing_configs -eq 0 ]; then
    echo "✅ Ready for: SOURCES=yes LOCALFILES=yes ./debian9-x86_64.sh"
    echo ""
    echo "Installation command:"
    echo "  git clone https://github.com/suyuan168/openmptcprouter-vps.git"
    echo "  cd openmptcprouter-vps"
    echo "  SOURCES=yes LOCALFILES=yes KERNEL=6.18 ./debian9-x86_64.sh"
    exit 0
else
    echo "❌ Missing files detected. Cannot proceed with local installation."
    exit 1
fi
