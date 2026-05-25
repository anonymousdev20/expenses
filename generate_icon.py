from PIL import Image, ImageDraw, ImageFont
import os

sizes = {
    'mipmap-mdpi':    48,
    'mipmap-hdpi':    72,
    'mipmap-xhdpi':   96,
    'mipmap-xxhdpi':  144,
    'mipmap-xxxhdpi': 192,
}

base = r'd:\new project\expense_tracker_pwa\android\app\src\main\res'

def draw_icon(size):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background rounded rect - deep blue gradient simulation
    margin = int(size * 0.05)
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=int(size * 0.22),
        fill=(21, 101, 192, 255)  # primaryBlue #1565C0
    )

    # Inner lighter blue highlight
    draw.rounded_rectangle(
        [margin, margin, size - margin, int(size * 0.55)],
        radius=int(size * 0.22),
        fill=(25, 118, 210, 255)  # #1976D2
    )

    # Draw wallet shape
    cx = size // 2
    cy = size // 2

    w = int(size * 0.55)
    h = int(size * 0.38)
    wx = cx - w // 2
    wy = cy - h // 2 + int(size * 0.04)

    # Wallet body
    draw.rounded_rectangle(
        [wx, wy, wx + w, wy + h],
        radius=int(size * 0.06),
        fill=(255, 255, 255, 255)
    )

    # Wallet flap (top)
    flap_h = int(h * 0.35)
    draw.rounded_rectangle(
        [wx, wy - flap_h + int(size*0.02), wx + w, wy + int(size*0.02)],
        radius=int(size * 0.05),
        fill=(224, 242, 254, 255)
    )

    # Coin/circle on wallet
    coin_r = int(size * 0.09)
    coin_x = wx + w - coin_r - int(size * 0.06)
    coin_y = wy + h // 2
    draw.ellipse(
        [coin_x - coin_r, coin_y - coin_r, coin_x + coin_r, coin_y + coin_r],
        fill=(255, 214, 0, 255)  # accentYellow #FFD600
    )

    # Rupee symbol on coin
    font_size = max(int(coin_r * 1.1), 8)
    try:
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        font = ImageFont.load_default()

    draw.text(
        (coin_x, coin_y),
        '₹',
        fill=(21, 101, 192, 255),
        font=font,
        anchor='mm'
    )

    return img

for folder, size in sizes.items():
    out_dir = os.path.join(base, folder)
    os.makedirs(out_dir, exist_ok=True)
    img = draw_icon(size)
    img.save(os.path.join(out_dir, 'ic_launcher.png'))
    print(f'Generated {folder}/ic_launcher.png ({size}x{size})')

print('All icons generated!')
