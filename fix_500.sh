#!/bin/bash
# Nginx 500 错误修复脚本

echo "🔧 开始修复 Nginx 500 错误..."
echo ""

# 1. 检查并修复文件权限
echo "1️⃣ 修复文件权限..."
chmod -R 755 /root/xxm_mjoys/dist/
chown -R www-data:www-data /root/xxm_mjoys/dist/ 2>/dev/null || chown -R nginx:nginx /root/xxm_mjoys/dist/ 2>/dev/null || echo "使用当前用户权限"
echo "   ✅ 权限已设置"
echo ""

# 2. 测试 Nginx 配置
echo "2️⃣ 测试 Nginx 配置..."
nginx -t
if [ $? -eq 0 ]; then
    echo "   ✅ Nginx 配置测试通过"
else
    echo "   ❌ Nginx 配置测试失败，请检查配置"
    exit 1
fi
echo ""

# 3. 重新加载 Nginx
echo "3️⃣ 重新加载 Nginx..."
nginx -s reload
if [ $? -eq 0 ]; then
    echo "   ✅ Nginx 已重新加载"
else
    echo "   尝试重启 Nginx..."
    systemctl restart nginx
fi
echo ""

# 4. 检查 Nginx 状态
echo "4️⃣ Nginx 状态："
systemctl status nginx --no-pager | head -10
echo ""

# 5. 查看最近的错误日志
echo "5️⃣ 最近 10 条错误日志："
tail -10 /var/log/nginx/error.log
echo ""

# 6. 测试访问
echo "6️⃣ 测试本地访问："
curl -I http://localhost 2>&1 | head -5
echo ""

echo "✅ 修复完成！请刷新浏览器查看结果。"
echo "   访问地址：http://118.31.120.40"
