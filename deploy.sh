#!/bin/bash

# 部署脚本 - 将项目发布到服务器
# 服务器：118.31.120.40
# 部署目录：/root/xxm_mjoys

set -e

# 配置
SERVER_USER="root"
SERVER_HOST="118.31.120.40"
SERVER_DIR="/root/xxm_mjoys"
LOCAL_DIST_DIR="./dist"

echo "🚀 开始部署到服务器 ${SERVER_HOST}:${SERVER_DIR}"
echo ""

# 1. 检查 dist 目录是否存在
if [ ! -d "$LOCAL_DIST_DIR" ]; then
    echo "❌ dist 目录不存在，正在构建项目..."
    npm run build
fi

# 2. 创建临时压缩包
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEMP_TAR="xxm_mjoys_temp_${TIMESTAMP}.tar.gz"
echo "📦 创建临时压缩包：${TEMP_TAR}"
tar -czf ${TEMP_TAR} dist/

# 3. 上传到服务器
echo "📤 上传文件到服务器..."
scp ${TEMP_TAR} ${SERVER_USER}@${SERVER_HOST}:${SERVER_DIR}/

# 4. 在服务器上解压和部署
echo "🔧 在服务器上部署..."
ssh ${SERVER_USER}@${SERVER_HOST} << EOF
    cd ${SERVER_DIR}
    echo "   解压文件..."
    tar -xzf ${TEMP_TAR}
    echo "   清理临时文件..."
    rm -f ${TEMP_TAR}
    echo "   设置文件权限..."
    chmod -R 755 dist/
    echo "✅ 部署完成!"
EOF

# 5. 清理本地临时文件
rm -f ${TEMP_TAR}

echo ""
echo "🎉 部署成功！"
echo "   访问地址：http://${SERVER_HOST}"
echo ""
