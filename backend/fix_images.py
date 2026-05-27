import re
import os
import requests
import tempfile
import cloudinary
import cloudinary.uploader

env_path = r"c:\Users\Zainab\OneDrive\Documents\Desktop\ZDesktop\Musiverse\backend\.env"
controller_path = r"c:\Users\Zainab\OneDrive\Documents\Desktop\ZDesktop\Musiverse\backend\src\main\java\com\musiverse\backend\controller\SongController.java"

# 1. Parse .env
print("Parsing .env...")
cloudinary_creds = {}
if os.path.exists(env_path):
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, val = line.split('=', 1)
                if key.strip().startswith("CLOUDINARY_"):
                    cloudinary_creds[key.strip()] = val.strip()

cloud_name = cloudinary_creds.get("CLOUDINARY_CLOUD_NAME")
api_key = cloudinary_creds.get("CLOUDINARY_API_KEY")
api_secret = cloudinary_creds.get("CLOUDINARY_API_SECRET")

if not (cloud_name and api_key and api_secret):
    print("Error: Could not find complete Cloudinary credentials in .env file.")
    exit(1)

print(f"Cloudinary configured: cloud_name={cloud_name}")
cloudinary.config(
    cloud_name=cloud_name,
    api_key=api_key,
    api_secret=api_secret
)

# 2. Helper to parse arguments respecting quotes and commas
def parse_args(arg_str):
    args = []
    current = []
    in_quotes = False
    quote_char = None
    i = 0
    while i < len(arg_str):
        char = arg_str[i]
        if char in ('"', "'") and (i == 0 or arg_str[i-1] != '\\'):
            if in_quotes and char == quote_char:
                in_quotes = False
                quote_char = None
            elif not in_quotes:
                in_quotes = True
                quote_char = char
            current.append(char)
        elif char == ',' and not in_quotes:
            args.append(''.join(current).strip())
            current = []
        else:
            current.append(char)
        i += 1
    if current:
        args.append(''.join(current).strip())
    return args

def clean_arg(arg):
    arg = arg.strip()
    if arg == "null":
        return None
    if (arg.startswith('"') and arg.endswith('"')) or (arg.startswith("'") and arg.endswith("'")):
        return arg[1:-1]
    return arg

# 3. Read SongController.java
print("Reading SongController.java...")
with open(controller_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 4. Find all new Song(...)
matches = list(re.finditer(r'new\s+Song\((.*?)\)', content, re.DOTALL))
print(f"Found {len(matches)} song entries.")

# Check URLs and fix them
updated_content = content
fixed_count = 0

for idx, match in enumerate(matches):
    arg_str = match.group(1)
    args = parse_args(arg_str)
    if len(args) < 9:
        continue
    
    song_name = clean_arg(args[0])
    movie = clean_arg(args[1])
    singer = clean_arg(args[4])
    image_url_raw = args[8] # keeps quotes if string
    image_url = clean_arg(image_url_raw)
    
    if not image_url:
        continue
        
    # Check if URL is placeholder or broken
    is_broken = False
    if "your_image_url_" in image_url or "cloudinary.com/your_image" in image_url:
        is_broken = True
    else:
        try:
            # test URL
            headers = {'User-Agent': 'Mozilla/5.0'}
            response = requests.head(image_url, headers=headers, timeout=4, allow_redirects=True)
            if response.status_code != 200:
                response = requests.get(image_url, headers=headers, timeout=4)
                if response.status_code != 200:
                    is_broken = True
        except Exception:
            is_broken = True
            
    if is_broken:
        print(f"\n[{idx+1}] Broken image found for '{song_name}' (Current: {image_url})")
        # Search iTunes API
        search_query = f"{song_name}"
        if movie and movie != "N/A" and "Album" not in movie:
            search_query += f" {movie}"
        elif singer and singer != "N/A":
            search_query += f" {singer}"
            
        print(f"Searching iTunes for: {search_query}")
        try:
            search_url = f"https://itunes.apple.com/search?term={requests.utils.quote(search_query)}&entity=song&limit=5"
            res = requests.get(search_url, timeout=5).json()
            results = res.get("results", [])
            
            artwork_url = None
            if results:
                artwork_url = results[0].get("artworkUrl100")
                if artwork_url:
                    # Upgrade resolution to 500x500
                    artwork_url = artwork_url.replace("100x100bb.jpg", "500x500bb.jpg")
                    print(f"Found iTunes artwork: {artwork_url}")
            
            if not artwork_url:
                # Fallback to search without movie/singer if no results
                print("No results. Trying simple search...")
                search_url = f"https://itunes.apple.com/search?term={requests.utils.quote(song_name)}&entity=song&limit=3"
                res = requests.get(search_url, timeout=5).json()
                results = res.get("results", [])
                if results:
                    artwork_url = results[0].get("artworkUrl100")
                    if artwork_url:
                        artwork_url = artwork_url.replace("100x100bb.jpg", "500x500bb.jpg")
                        print(f"Found artwork (fallback): {artwork_url}")

            if artwork_url:
                # Download image
                img_data = requests.get(artwork_url, timeout=10).content
                with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as tmp:
                    tmp.write(img_data)
                    tmp_name = tmp.name
                
                # Upload to Cloudinary
                print("Uploading to Cloudinary...")
                upload_res = cloudinary.uploader.upload(
                    tmp_name,
                    folder="musiverse/covers",
                    resource_type="image"
                )
                new_url = upload_res['secure_url']
                print(f"Uploaded successfully! New URL: {new_url}")
                
                # Replace in SongController content
                # Make sure we replace only this specific instance's image_url
                old_str = f'"{image_url}"'
                new_str = f'"{new_url}"'
                
                # Verify that it is unique within this song entry
                match_block = match.group(0)
                if old_str in match_block:
                    new_match_block = match_block.replace(old_str, new_str, 1)
                    updated_content = updated_content.replace(match_block, new_match_block, 1)
                    fixed_count += 1
                    print("Updated file contents.")
                else:
                    print("Error: Could not locate URL inside matched constructor block.")
                
                # Clean up temp file
                os.remove(tmp_name)
            else:
                print(f"Could not find any artwork for '{song_name}' on iTunes.")
        except Exception as e:
            print(f"Error updating image for '{song_name}': {e}")

# Save updated SongController.java
if fixed_count > 0:
    with open(controller_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)
    print(f"\nSuccessfully fixed and updated {fixed_count} song image URLs in SongController.java!")
else:
    print("\nNo broken image URLs were updated.")
