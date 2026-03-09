import glob
import base64
import os

# 切换到正确目录
os.chdir('/private/tmp/mjoys/public/system_demo')

# 使用 glob 查找文件
files = glob.glob("AI*.png")
print(f"Found files: {files}")

if files:
    with open(files[0], 'rb') as f:
        data = f.read()
        print(f"File size: {len(data)} bytes")
        encoded = base64.b64encode(data).decode()
        print(f"Base64 length: {len(encoded)}")
        # 输出 base64 用于图片识别
        print("DATA:" + encoded)
