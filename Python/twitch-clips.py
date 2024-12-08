import requests
import json
import os
import time

CLIENT_ID = 'your_client_id'
CLIENT_SECRET = 'your_client_secret'
ACCESS_TOKEN = 'your_access_token'  # Implement OAuth for this
BROADCASTER_ID = 'broadcaster_id'  # Replace with actual broadcaster ID

def get_clips():
    headers = {
        'Client-ID': CLIENT_ID,
        'Authorization': f'Bearer {ACCESS_TOKEN}'
    }
    params = {
        'broadcaster_id': BROADCASTER_ID
    }
    response = requests.get('https://api.twitch.tv/helix/clips', headers=headers, params=params)
    clips = response.json()
    return clips

def download_clip(clip_url, file_name):
    response = requests.get(clip_url)
    with open(file_name, 'wb') as file:
        file.write(response.content)

def read_downloaded_clip_ids():
    if os.path.exists('downloaded_clips.txt'):
        with open('downloaded_clips.txt', 'r') as file:
            return file.read().splitlines()
    return []

def write_downloaded_clip_id(clip_id):
    with open('downloaded_clips.txt', 'a') as file:
        file.write(f'{clip_id}\n')

def main():
    downloaded_clip_ids = read_downloaded_clip_ids()
    while True:
        clips = get_clips()
        for clip in clips['data']:
            if clip['id'] not in downloaded_clip_ids:
                clip_url = clip['thumbnail_url'].replace('-preview-480x272.jpg', '.mp4')  # Modify as needed
                file_name = os.path.join('downloads', clip['id'] + '.mp4')  # Modify as needed
                download_clip(clip_url, file_name)
                write_downloaded_clip_id(clip['id'])
        time.sleep(60 * 15)  # Check every 15 minutes; adjust as necessary

if __name__ == '__main__':
    main()
