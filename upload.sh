#!/bin/bash
# 快速上传脚本

echo "正在上传文件到服务器..."
echo "密码：yezewei123!"
echo ""

scp xxm_mjoys_dist_20260416_170946.tar.gz root@118.31.120.40:/root/xxm_mjoys/

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 上传成功！"
    echo ""
    echo "现在请执行以下命令在服务器上部署："
    echo ""
    echo "ssh root@118.31.120.40"
    echo "# 然后执行："
    echo "cd /root/xxm_mjoys"
    echo "tar -xzf xxm_mjoys_dist_20260416_170946.tar.gz"
    echo "chmod -R 755 dist/"
    echo "ls -lh dist/"
else
    echo ""
    echo "❌ 上传失败，请检查网络连接或密码"
fi
