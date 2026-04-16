#!/bin/bash
# 一键部署脚本 - xxm_mjoys 项目
# 目标：将项目部署到 118.31.120.40 服务器

set -e

echo "========================================"
echo "🚀 xxm_mjoys 项目部署脚本"
echo "========================================"
echo ""

# 配置
SERVER_USER="root"
SERVER_HOST="118.31.120.40"
SERVER_DIR="/root/xxm_mjoys"
NGINX_CONF_NAME="xxm_mjoys.conf"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_step() {
    echo -e "${GREEN}>>> $1${NC}"
}

echo_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 步骤 1: 检查发布包
echo_step "1. 检查发布包"
LATEST_TAR=$(ls -t xxm_mjoys_dist_*.tar.gz 2>/dev/null | head -1)
if [ -z "$LATEST_TAR" ]; then
    echo_error "未找到发布包！请先运行：npm run build"
    exit 1
fi
echo "   ✅ 找到发布包：$LATEST_TAR"
echo ""

# 步骤 2: 上传文件
echo_step "2. 上传文件到服务器"
echo "   目标：${SERVER_USER}@${SERVER_HOST}:${SERVER_DIR}/"
echo ""
scp ${LATEST_TAR} ${SERVER_USER}@${SERVER_HOST}:${SERVER_DIR}/

if [ $? -eq 0 ]; then
    echo "   ✅ 上传成功"
else
    echo_error "上传失败"
    exit 1
fi
echo ""

# 步骤 3: SSH 登录并部署
echo_step "3. 在服务器上部署"
echo ""
echo "   正在连接到服务器..."
echo ""

ssh ${SERVER_USER}@${SERVER_HOST} << 'ENDSSH'
set -e

echo "========================================"
echo "📦 服务器端部署"
echo "========================================"
echo ""

SERVER_DIR="/root/xxm_mjoys"
NGINX_CONF_NAME="xxm_mjoys.conf"

# 查找最新的发布包
cd ${SERVER_DIR}
LATEST_TAR=$(ls -t xxm_mjoys_dist_*.tar.gz 2>/dev/null | head -1)

if [ -z "$LATEST_TAR" ]; then
    echo "❌ 未找到发布包"
    exit 1
fi

echo "1️⃣ 解压文件：${LATEST_TAR}"
tar -xzf ${LATEST_TAR}

echo "2️⃣ 备份旧版本"
if [ -d "dist" ]; then
    BACKUP_NAME="dist_backup_$(date +%Y%m%d_%H%M%S)"
    cp -r dist ${BACKUP_NAME}
    echo "   已备份：${BACKUP_NAME}"
fi

echo "3️⃣ 部署新版本"
rm -rf dist
mv dist_temp dist 2>/dev/null || true

echo "4️⃣ 设置权限"
chmod -R 755 dist/

echo "5️⃣ 清理发布包"
rm -f ${LATEST_TAR}

echo "6️⃣ 检查部署结果"
if [ -f "dist/index.html" ]; then
    echo "   ✅ index.html 存在"
else
    echo "   ❌ index.html 不存在"
    exit 1
fi

if [ -d "dist/assets" ]; then
    ASSET_COUNT=$(ls dist/assets/ | wc -l)
    echo "   ✅ assets 目录：${ASSET_COUNT} 个文件"
else
    echo "   ❌ assets 目录不存在"
    exit 1
fi

echo ""
echo "✅ 服务器端部署完成！"
ENDSSH

if [ $? -eq 0 ]; then
    echo "   ✅ 服务器部署成功"
else
    echo_error "服务器部署失败"
    exit 1
fi
echo ""

# 步骤 4: 配置 Nginx
echo_step "4. 配置 Nginx"
echo ""
echo_warn "请将以下内容复制到服务器并执行："
echo ""
cat << 'NGINX_INSTRUCTIONS'
========================================
在服务器上执行以下命令配置 Nginx:
========================================

# 1. 创建 Nginx 配置文件
cat > /etc/nginx/conf.d/xxm_mjoys.conf << 'EOF'
server {
    listen 80;
    server_name 118.31.120.40;
    
    root /root/xxm_mjoys/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|otf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    
    error_page 404 /index.html;
}
EOF

# 2. 测试 Nginx 配置
nginx -t

# 3. 重启 Nginx
systemctl restart nginx

# 4. 检查 Nginx 状态
systemctl status nginx

# 5. 测试访问
curl -I http://118.31.120.40

========================================
NGINX_INSTRUCTIONS

echo ""
echo "========================================"
echo "🎉 部署完成！"
echo "========================================"
echo ""
echo "📱 访问地址：http://118.31.120.40"
echo ""
echo_warn "请执行上面的 Nginx 配置命令来完成部署！"
echo ""
