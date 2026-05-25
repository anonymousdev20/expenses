from PIL import Image
import os

src = r"D:\ChatGPT Image May 25, 2026, 04_34_33 PM.png"
base = r"d:\new project\expense_tracker_pwa\android\app\src\main\res"

sizes = {
    'mipmap-mdpi':    48,
    'mipmap-hdpi':    72,
    'mipmap-xhdpi':   96,
    'mipmap-xxhdpi':  144,
    'mipmap-xxxhdpi': 192,
}

img = Image.open(src).convert('RGBA')

for folder, size in sizes.items():
    out_dir = os.path.join(base, folder)
    os.makedirs(out_dir, exist_ok=True)
    resized = img.resize((size, size), Image.LANCZOS)
    resized.save(os.path.join(out_dir, 'ic_launcher.png'))
    print(f'Saved {folder}/ic_launcher.png ({size}x{size})')

print('Done!')
