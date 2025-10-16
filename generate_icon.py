#!/usr/bin/env python3
"""
Generate temporary app icon for Volunteer Management App
"""

try:
    from PIL import Image, ImageDraw, ImageFont
    import os
except ImportError:
    print("Installing required package: Pillow")
    import subprocess
    subprocess.check_call(['pip', 'install', 'Pillow'])
    from PIL import Image, ImageDraw, ImageFont
    import os

def create_app_icon():
    """Create main app icon with 'V' letter"""
    # Create 1024x1024 icon (will be resized by flutter_launcher_icons)
    size = 1024
    img = Image.new('RGB', (size, size), color='#ff5001')
    draw = ImageDraw.Draw(img)

    # Draw white letter 'V' for Volunteer
    try:
        # Try to use a bold font if available
        font = ImageFont.truetype("arial.ttf", 600)
    except:
        # Fallback to default font
        font = ImageFont.load_default()

    # Draw 'V' in the center
    text = "V"

    # Get text bounding box for centering
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    # Calculate position to center the text
    x = (size - text_width) / 2
    y = (size - text_height) / 2 - 50

    # Draw text with shadow for depth
    # Shadow
    draw.text((x + 8, y + 8), text, font=font, fill='#cc4001')
    # Main text
    draw.text((x, y), text, font=font, fill='white')

    # Save the icon
    output_path = 'assets/icon/app_icon.png'
    img.save(output_path, 'PNG')
    print(f"[OK] Created {output_path}")
    return output_path

def create_adaptive_icon_foreground():
    """Create adaptive icon foreground (just the V letter)"""
    size = 1024
    img = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    try:
        font = ImageFont.truetype("arial.ttf", 500)
    except:
        font = ImageFont.load_default()

    text = "V"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (size - text_width) / 2
    y = (size - text_height) / 2 - 50

    # Draw text
    draw.text((x, y), text, font=font, fill='white')

    output_path = 'assets/icon/app_icon_foreground.png'
    img.save(output_path, 'PNG')
    print(f"[OK] Created {output_path}")
    return output_path

def main():
    print("=" * 50)
    print("Generating Volunteer App Icons")
    print("=" * 50)
    print()

    # Create assets/icon directory if not exists
    os.makedirs('assets/icon', exist_ok=True)

    # Generate icons
    create_app_icon()
    create_adaptive_icon_foreground()

    print()
    print("=" * 50)
    print("[SUCCESS] Icon generation complete!")
    print("=" * 50)
    print()
    print("Next steps:")
    print("1. Run: flutter pub get")
    print("2. Run: dart run flutter_launcher_icons")
    print("3. Build APK: flutter build apk --release")
    print()

if __name__ == '__main__':
    main()
