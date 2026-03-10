#!/bin/bash
# 执行场景模板数据库脚本

echo "请输入 MySQL 密码后执行 SQL 脚本..."
mysql -h localhost -u root -p < /private/tmp/xxm_mjoys/sql/scene_template.sql

if [ $? -eq 0 ]; then
    echo "✓ 数据库表创建成功！"
    echo ""
    echo "查看表结构："
    echo "mysql -h localhost -u root -p -e 'DESCRIBE scene_template;'"
    echo ""
    echo "查看示例数据："
    echo "mysql -h localhost -u root -p -e 'SELECT id, template_name, scene_code, follow_type, scene_count FROM scene_template;'"
else
    echo "✗ 数据库脚本执行失败，请检查 MySQL 连接"
    exit 1
fi
