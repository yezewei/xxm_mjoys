#!/bin/bash
# Nginx 故障诊断脚本

echo "========================================"
echo "🔍 Nginx 故障诊断"
echo "========================================"
echo ""

echo "1️⃣ 测试 Nginx 配置："
nginx -t 2>&1
echo ""

echo "2️⃣ 查看 Nginx 状态："
systemctl status nginx.service -l 2>&1 | head -20
echo ""

echo "3️⃣ 检查配置文件："
echo "   /etc/nginx/conf.d/ 目录内容："
ls -la /etc/nginx/conf.d/
echo ""

echo "4️⃣ 检查 Nginx 错误日志："
if [ -f "/var/log/nginx/error.log" ]; then
    echo "   最近 10 条错误："
    tail -10 /var/log/nginx/error.log
else
    echo "   ⚠️ 错误日志文件不存在"
fi
echo ""

echo "5️⃣ 检查端口占用："
if command -v netstat &> /dev/null; then
    netstat -tlnp 2>/dev/null | grep :80 || echo "   80 端口未被占用"
elif command -v ss &> /dev/null; then
    ss -tlnp 2>/dev/null | grep :80 || echo "   80 端口未被占用"
else
    echo "   ⚠️ 无法检查端口"
fi
echo ""

echo "6️⃣ 检查 xxm_mjoys.conf 内容："
if [ -f "/etc/nginx/conf.d/xxm_mjoys.conf" ]; then
    cat /etc/nginx/conf.d/xxm_mjoys.conf
else
    echo "   ⚠️ xxm_mjoys.conf 文件不存在"
fi
echo ""

echo "========================================"
echo "诊断完成！"
echo "========================================"
