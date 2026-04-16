#!/bin/bash
# 服务器部署检查脚本
# 在服务器上执行：bash check_deploy.sh

echo "========================================"
echo "🔍 部署状态检查"
echo "========================================"
echo ""

# 1. 检查 Nginx 状态
echo "1️⃣ Nginx 状态："
if systemctl is-active --quiet nginx; then
    echo "   ✅ Nginx 正在运行"
else
    echo "   ❌ Nginx 未运行"
    echo "   执行：systemctl start nginx"
fi
echo ""

# 2. 检查端口监听
echo "2️⃣ 端口监听："
if command -v netstat &> /dev/null; then
    netstat -tlnp 2>/dev/null | grep :80 || echo "   ❌ 80 端口未监听"
elif command -v ss &> /dev/null; then
    ss -tlnp 2>/dev/null | grep :80 || echo "   ❌ 80 端口未监听"
else
    echo "   ⚠️ 无法检查端口（缺少 netstat/ss 命令）"
fi
echo ""

# 3. 检查项目目录
echo "3️⃣ 项目目录："
if [ -d "/root/xxm_mjoys" ]; then
    echo "   ✅ 目录存在"
    ls -lh /root/xxm_mjoys/
else
    echo "   ❌ 目录不存在"
fi
echo ""

# 4. 检查 dist 目录
echo "4️⃣ dist 目录："
if [ -d "/root/xxm_mjoys/dist" ]; then
    echo "   ✅ dist 目录存在"
    echo "   文件列表："
    ls -lh /root/xxm_mjoys/dist/
    
    if [ -f "/root/xxm_mjoys/dist/index.html" ]; then
        echo "   ✅ index.html 存在"
    else
        echo "   ❌ index.html 不存在"
    fi
    
    if [ -d "/root/xxm_mjoys/dist/assets" ]; then
        echo "   ✅ assets 目录存在"
        ls /root/xxm_mjoys/dist/assets/ | head -5
    else
        echo "   ❌ assets 目录不存在"
    fi
else
    echo "   ❌ dist 目录不存在"
fi
echo ""

# 5. 检查 Nginx 配置
echo "5️⃣ Nginx 配置："
if [ -f "/etc/nginx/nginx.conf" ]; then
    echo "   ✅ nginx.conf 存在"
else
    echo "   ❌ nginx.conf 不存在"
fi

if [ -d "/etc/nginx/conf.d" ]; then
    echo "   conf.d 目录内容："
    ls -la /etc/nginx/conf.d/
else
    echo "   ⚠️ conf.d 目录不存在"
fi
echo ""

# 6. 测试本地访问
echo "6️⃣ 测试访问："
if command -v curl &> /dev/null; then
    echo "   本地访问测试："
    curl -I http://localhost 2>&1 | head -5
    echo ""
    echo "   外网访问测试："
    curl -I http://118.31.120.40 2>&1 | head -5
else
    echo "   ⚠️ curl 命令未安装"
fi
echo ""

# 7. 检查 Nginx 日志
echo "7️⃣ Nginx 日志（最近 5 条错误）："
if [ -f "/var/log/nginx/error.log" ]; then
    tail -5 /var/log/nginx/error.log
else
    echo "   ⚠️ 错误日志文件不存在"
fi
echo ""

echo "========================================"
echo "检查完成！"
echo "========================================"
