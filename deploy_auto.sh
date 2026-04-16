#!/bin/bash

# 一键部署脚本（需要安装 sshpass）
# 使用方法：./deploy_auto.sh

set -e

# 服务器配置
SERVER_USER="root"
SERVER_HOST="118.31.120.40"
SERVER_PASS="yezewei123!"
SERVER_DIR="/root/xxm_mjoys"

echo "🚀 开始部署到服务器 ${SERVER_HOST}"
echo ""

# 1. 检查是否有最新的发布包
LATEST_TAR=$(ls -t xxm_mjoys_dist_*.tar.gz 2>/dev/null | head -1)
if [ -z "$LATEST_TAR" ]; then
    echo "❌ 未找到发布包，请先运行 npm run build"
    exit 1
fi

echo "📦 使用发布包：${LATEST_TAR}"

# 2. 上传到服务器
echo "📤 上传文件到服务器..."
sshpass -p "${SERVER_PASS}" scp -o StrictHostKeyChecking=no ${LATEST_TAR} ${SERVER_USER}@${SERVER_HOST}:${SERVER_DIR}/

# 3. 在服务器上部署
echo "🔧 在服务器上部署..."
sshpass -p "${SERVER_PASS}" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_HOST} << EOF
    cd ${SERVER_DIR}
    echo "   解压文件..."
    tar -xzf ${LATEST_TAR}
    echo "   备份旧版本..."
    if [ -d "dist_backup" ]; then
        rm -rf dist_backup
    fi
    if [ -d "dist" ]; then
        mv dist dist_backup
    fi
    echo "   部署新版本..."
    mv dist dist_temp && mv dist_temp dist
    echo "   清理临时文件..."
    rm -f ${LATEST_TAR}
    echo "   设置文件权限..."
    chmod -R 755 dist/
    echo "✅ 部署完成!"
EOF

echo ""
echo "🎉 部署成功！"
echo "   访问地址：http://${SERVER_HOST}"
echo ""
