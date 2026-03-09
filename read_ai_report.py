from PIL import Image
import glob
import os

# 切换到目标目录
os.chdir('/private/tmp/mjoys/public/system_demo')

# 使用 glob 找到文件
files = glob.glob('AI*.png')
print(f'Found files: {files}')

if files:
    img = Image.open(files[0])
    print(f'Image size: {img.size}')
    print(f'Image mode: {img.mode}')
    # 保存图片到项目根目录
    img.save('/private/tmp/mjoys/ai_report_copy.png')
    print('Saved to /private/tmp/mjoys/ai_report_copy.png')
