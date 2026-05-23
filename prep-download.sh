#!/bin/sh
#
# 预下载所有外部依赖到 sources/ 目录
# 在能访问外网的机器上运行此脚本，然后将整个仓库传输到目标 VPS
# 在目标 VPS 上使用 LOCALFILES=yes 运行安装脚本
#
# 用法: ./prep-download.sh
#

SHADOWSOCKS_VERSION="8fc18fcba3226e31f9f2bb9e60d6be6a1837862b"
IPROUTE2_VERSION="29da83f89f6e1fe528c59131a01f5d43bcd0a000"
GLORYTUN_UDP_VERSION="23100474922259d00a8c0c4b00a0c8de89202cf9"
GLORYTUN_TCP_VERSION="8aebb3efb3b108b1276aa74679e200e003f298de"
MLVPN_VERSION="8aa1b16d843ea68734e2520e39a34cb7f3d61b2b"
UBOND_VERSION="31af0f69ebb6d07ed9348dca2fced33b956cedee"
OBFS_VERSION="486bebd9208539058e57e23a12f23103016e09b4"
OMR_ADMIN_VERSION="ccac898d295e5c0d74229d66f0eb04c9f051349d"
DSVPN_VERSION="3b99d2ef6c02b2ef68b5784bec8adfdd55b29b1a"
V2RAY_PLUGIN_VERSION="4.43.0"
EASYRSA_VERSION="3.2.2"

SOURCES_DIR="$(cd "$(dirname "$0")" && pwd)/sources"
mkdir -p "$SOURCES_DIR"

dl() {
	local url="$1" output="$2"
	if [ -f "$output" ]; then
		echo "[跳过] $(basename "$output") 已存在"
		return 0
	fi
	echo "[下载] $(basename "$output")"
	wget -q --show-progress -O "$output" "$url" || {
		echo "[错误] 下载失败: $url"
		rm -f "$output"
		return 1
	}
}

clone_tar() {
	local repo_url="$1" commit="$2" name="$3" output="$4"
	if [ -f "$output" ]; then
		echo "[跳过] $(basename "$output") 已存在"
		return 0
	fi
	echo "[克隆] $name ($commit)"
	rm -rf "/tmp/prep-${name}"
	git clone --recursive "$repo_url" "/tmp/prep-${name}" || {
		echo "[错误] 克隆失败: $repo_url"
		return 1
	}
	cd "/tmp/prep-${name}"
	git checkout "$commit" || {
		echo "[错误] checkout 失败: $commit"
		cd /tmp && rm -rf "/tmp/prep-${name}"
		return 1
	}
	git submodule update --init --recursive 2>/dev/null || true
	cd /tmp
	tar czf "$output" -C /tmp "prep-${name}"
	rm -rf "/tmp/prep-${name}"
	echo "[完成] $(basename "$output")"
}

echo "================================================================================"
echo " 预下载所有外部依赖到 $SOURCES_DIR"
echo "================================================================================"

echo ""
echo "=== Git 仓库源码 (GitHub) ==="
clone_tar "https://github.com/Ysurac/shadowsocks-libev.git" "$SHADOWSOCKS_VERSION" "shadowsocks-libev" "$SOURCES_DIR/shadowsocks-libev.tar.gz"
clone_tar "https://github.com/shadowsocks/simple-obfs.git" "$OBFS_VERSION" "simple-obfs" "$SOURCES_DIR/simple-obfs.tar.gz"
clone_tar "https://github.com/zehome/MLVPN.git" "$MLVPN_VERSION" "MLVPN" "$SOURCES_DIR/MLVPN.tar.gz"
clone_tar "https://github.com/Ysurac/glorytun.git" "$GLORYTUN_UDP_VERSION" "glorytun-udp" "$SOURCES_DIR/glorytun-udp.tar.gz"
clone_tar "https://github.com/Ysurac/glorytun.git" "$GLORYTUN_TCP_VERSION" "glorytun-tcp" "$SOURCES_DIR/glorytun-tcp.tar.gz"
clone_tar "https://github.com/ysurac/dsvpn.git" "$DSVPN_VERSION" "dsvpn" "$SOURCES_DIR/dsvpn.tar.gz"
clone_tar "https://github.com/Ysurac/mptcpize.git" "master" "mptcpize" "$SOURCES_DIR/mptcpize.tar.gz"

echo ""
echo "=== Git 仓库源码 (hub.55860.com 备用) ==="
echo "如果上面的 GitHub 下载失败，可以尝试从 hub.55860.com 下载"
if [ ! -f "$SOURCES_DIR/mptcpize.tar.gz" ]; then
	clone_tar "https://hub.55860.com/Ysurac/mptcpize.git" "master" "mptcpize" "$SOURCES_DIR/mptcpize.tar.gz"
fi

echo ""
echo "=== Git 仓库源码 (其他) ==="
clone_tar "https://github.com/shemminger/iproute2.git" "$IPROUTE2_VERSION" "iproute2" "$SOURCES_DIR/iproute2.tar.gz"

echo ""
echo "=== 二进制下载 ==="
dl "https://github.com/esnet/iperf/releases/download/3.18/iperf-3.18.tar.gz" "$SOURCES_DIR/iperf-3.18.tar.gz"
dl "https://github.com/OpenVPN/easy-rsa/releases/download/v${EASYRSA_VERSION}/EasyRSA-${EASYRSA_VERSION}.tgz" "$SOURCES_DIR/EasyRSA-unix-v${EASYRSA_VERSION}.tgz"
dl "https://github.com/angt/glorytun/releases/download/v0.0.35/glorytun-0.0.35.tar.gz" "$SOURCES_DIR/glorytun-0.0.35.tar.gz"
dl "https://github.com/teddysun/v2ray-plugin/releases/download/v${V2RAY_PLUGIN_VERSION}/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz" "$SOURCES_DIR/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VERSION}.tar.gz"

echo ""
echo "=== 补丁文件 ==="
dl "https://github.com/Ysurac/openmptcprouter-feeds/raw/refs/heads/develop/glorytun/patches/001-fix-compilation-errors-gcc14.patch" "$SOURCES_DIR/001-fix-compilation-errors-gcc14.patch"
dl "https://github.com/Ysurac/openmptcprouter-feeds/raw/refs/heads/develop/glorytun/patches/002-fix-crypto-aead-pointer-types.patch" "$SOURCES_DIR/002-fix-crypto-aead-pointer-types.patch"

echo ""
echo "=== openmptcprouter-vps-admin ==="
dl "https://github.com/Ysurac/openmptcprouter-vps-admin/archive/${OMR_ADMIN_VERSION}.zip" "$SOURCES_DIR/openmptcprouter-vps-admin-${OMR_ADMIN_VERSION}.zip"

echo ""
echo "=== iperf3 Debian 打包文件 ==="
dl "https://www.openmptcprouter.com/debian/iperf3_3.18-2.debian.tar.xz" "$SOURCES_DIR/iperf3_3.18-2.debian.tar.xz"

echo ""
echo "=== XanMod 内核 (默认 KERNEL=6.18, ~100MB/个) ==="
echo "内核文件较大，请确保网络稳定后下载"
mkdir -p "$SOURCES_DIR/kernel"
VPSURL="https://www.openmptcprouter.com/"
for PSABI in x64v2 x64v3; do
	KV="6.18.6"
	KR="0~20260119.g84d30e6"
	dl "${VPSURL}kernel/linux-image-${KV}-${PSABI}-xanmod1_${KV}-${PSABI}-xanmod1-${KR}_amd64.deb" \
		"$SOURCES_DIR/kernel/linux-image-${KV}-${PSABI}-xanmod1_${KV}-${PSABI}-xanmod1-${KR}_amd64.deb"
	dl "${VPSURL}kernel/linux-headers-${KV}-${PSABI}-xanmod1_${KV}-${PSABI}-xanmod1-${KR}_amd64.deb" \
		"$SOURCES_DIR/kernel/linux-headers-${KV}-${PSABI}-xanmod1_${KV}-${PSABI}-xanmod1-${KR}_amd64.deb"
done

echo ""
echo "=== MPTCP 内核 (KERNEL=5.4, 可选) ==="
KV="5.4.207"
KP="1.22"
dl "${VPSURL}kernel/linux-image-${KV}-mptcp_${KP}_amd64.deb" \
	"$SOURCES_DIR/kernel/linux-image-${KV}-mptcp_${KP}_amd64.deb"
dl "${VPSURL}kernel/linux-headers-${KV}-mptcp_${KP}_amd64.deb" \
	"$SOURCES_DIR/kernel/linux-headers-${KV}-mptcp_${KP}_amd64.deb"

echo ""
echo "=== XanMod 内核 (KERNEL=6.12, 可选) ==="
for PSABI in x64v2 x64v3; do
	KV="6.12.67"
	KR="0~20260123.ga077982"
	dl "${VPSURL}kernel/linux-image-${KV}-${PSABI}-xanmod1_${KV}-${PSABI}-xanmod1-${KR}_amd64.deb" \
		"$SOURCES_DIR/kernel/linux-image-${KV}-${PSABI}-xanmod1_${KV}-${PSABI}-xanmod1-${KR}_amd64.deb"
	dl "${VPSURL}kernel/linux-headers-${KV}-${PSABI}-xanmod1_${KV}-${PSABI}-xanmod1-${KR}_amd64.deb" \
		"$SOURCES_DIR/kernel/linux-headers-${KV}-${PSABI}-xanmod1_${KV}-${PSABI}-xanmod1-${KR}_amd64.deb"
done

echo ""
echo "================================================================================"
echo " 下载完成！文件保存在: $SOURCES_DIR"
echo ""
echo " 使用方法:"
echo " 1. 将整个仓库目录传输到目标 VPS (scp -r / rsync)"
echo " 2. 在 VPS 上运行: CHINA=yes LOCALFILES=yes ./debian9-x86_64.sh"
echo ""
echo " 注意: 内核文件每个约100MB，如果下载失败不影响其他组件安装"
echo "       内核安装会自动从 SourceForge (国内可访问) 尝试下载"
echo "================================================================================"
echo ""
echo "sources/ 目录内容:"
ls -lh "$SOURCES_DIR"
echo ""
echo "sources/kernel/ 目录内容:"
ls -lh "$SOURCES_DIR/kernel/" 2>/dev/null || echo "  (空 - 内核未下载)"
