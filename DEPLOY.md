# 项目部署指南

## 📦 构建信息

- **构建时间**: 2026-04-16 17:09
- **发布包**: `xxm_mjoys_dist_20260416_170946.tar.gz` (4.3 MB)
- **服务器**: root@118.31.120.40
- **部署目录**: /root/xxm_mjoys

---

## 🚀 部署步骤

### 方式一：使用 scp 命令（推荐）

#### 1. 上传发布包到服务器
```bash
# 在项目根目录执行
scp xxm_mjoys_dist_20260416_170946.tar.gz root@118.31.120.40:/root/xxm_mjoys/
# 输入密码：yezewei123!
```

#### 2. 登录服务器并部署
```bash
# SSH 登录服务器
ssh root@118.31.120.40
# 输入密码：yezewei123!

# 进入部署目录
cd /root/xxm_mjoys

# 备份旧版本（如果有）
if [ -d "dist" ]; then
    mv dist dist_backup_$(date +%Y%m%d_%H%M%S)
fi

# 解压新版本
tar -xzf xxm_mjoys_dist_20260416_170946.tar.gz

# 设置权限
chmod -R 755 dist/

# 清理发布包
rm xxm_mjoys_dist_20260416_170946.tar.gz

# 验证部署
ls -lh dist/
```

---

### 方式二：使用 rsync 同步

```bash
# 直接同步 dist 目录到服务器
rsync -avz --delete ./dist/ root@118.31.120.40:/root/xxm_mjoys/dist/
# 输入密码：yezewei123!
```

---

### 方式三：使用自动化脚本

#### 安装 sshpass（可选）
```bash
# macOS
brew install sshpass

# Ubuntu/Debian
sudo apt-get install sshpass

# CentOS/RHEL
sudo yum install sshpass
```

#### 执行自动部署脚本
```bash
chmod +x deploy_auto.sh
./deploy_auto.sh
```

---

## 🌐 Nginx 配置（如未配置）

### 1. 创建 Nginx 配置文件
```bash
# 在服务器上执行
sudo vim /etc/nginx/conf.d/xxm_mjoys.conf
```

### 2. 配置内容
```nginx
server {
    listen 80;
    server_name _;
    
    # 项目根目录
    root /root/xxm_mjoys/dist;
    index index.html;

    # 主应用
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;

    # 错误页面
    error_page 404 /index.html;
    error_page 500 502 503 504 /50x.html;
}
```

### 3. 重启 Nginx
```bash
# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx

# 查看状态
sudo systemctl status nginx
```

---

## ✅ 验证部署

### 1. 检查服务状态
```bash
# 检查 Nginx 是否运行
sudo systemctl status nginx

# 检查端口监听
sudo netstat -tlnp | grep :80
```

### 2. 访问测试
```bash
# 本地测试
curl -I http://118.31.120.40

# 或使用浏览器访问
# http://118.31.120.40
```

### 3. 检查文件权限
```bash
cd /root/xxm_mjoys/dist
ls -lh
```

---

## 🔄 快速部署命令（复制粘贴）

```bash
# ===== 在本地执行 =====
# 1. 构建项目
npm run build

# 2. 上传到服务器
scp xxm_mjoys_dist_*.tar.gz root@118.31.120.40:/root/xxm_mjoys/

# ===== 在服务器执行 =====
# 3. SSH 登录
ssh root@118.31.120.40

# 4. 部署
cd /root/xxm_mjoys
tar -xzf xxm_mjoys_dist_*.tar.gz
chmod -R 755 dist/
rm xxm_mjoys_dist_*.tar.gz

# 5. 重启 Nginx（如果需要）
sudo systemctl reload nginx
```

---

## 📝 注意事项

1. **密码安全**: 建议配置 SSH 密钥认证，避免在脚本中明文存储密码
2. **备份策略**: 部署前自动备份旧版本，保留最近 3 个版本
3. **回滚方案**: 如部署失败，可快速回滚到备份版本
   ```bash
   cd /root/xxm_mjoys
   rm -rf dist
   mv dist_backup_YYYYMMDD_HHMMSS dist
   sudo systemctl reload nginx
   ```
4. **监控日志**: 部署后检查 Nginx 日志
   ```bash
   sudo tail -f /var/log/nginx/access.log
   sudo tail -f /var/log/nginx/error.log
   ```

---

## 🛠️ 故障排查

### 问题 1: 访问页面空白
- 检查浏览器控制台错误
- 确认 Nginx 配置正确
- 检查文件权限：`chmod -R 755 dist/`

### 问题 2: 资源加载失败
- 检查 Nginx 的 root 路径配置
- 确认静态文件存在：`ls dist/assets/`
- 清除浏览器缓存

### 问题 3: 路由 404 错误
- 确保 Nginx 配置了 `try_files $uri $uri/ /index.html;`
- 重启 Nginx：`sudo systemctl reload nginx`

---

**部署时间**: 2026-04-16
**文档版本**: v1.0
