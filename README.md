# YouTube Downloader

**Please note:** This is currently in *Alpha* state, so may not work for you.

Grab the installer exe file from the [Releases](https://github.com/jvdw008/ytdownloader/releases/) link.

If you clone the repo, remember to rename the example-installer.nsi to installer.nsi and change the path inside to where you cloned this project to, eg:
File "PATH\TO\GITPROJECT\ytdownloader.exe" becomes File "C:\repo\YTDownloader\ytdownloader.exe" - etc.
Please also keep in mind you will need the FFMpeg exe files in the project folder for this to work, ie ffmpeg.exe, ffplay.exe and ffprobe.exe. All can be found on their repo at [https://github.com/BtbN/FFmpeg-Builds/releases](https://github.com/BtbN/FFmpeg-Builds/releases)

Thanks for checking out my simple GUI app to download Youtube videos. This lets you choose a video and download it in the best to worst format depending on what's available: 
If you choose Audio-only, you can choose from a range of audio formats to download into, eg. mp3, wav, ogg, etc.

More features will come over time, but for now these are the features I was after, so hopefully others find this useful too.

This app is basically a 'GUI' for **yt-dlp** from [https://github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp) which I felt was a *bit* user-unfriendly and intimidating, so I decided to tone it down for simpler folk like me who just want an uncomplicated tool to grab some videos or audio for offline use.

## Current features
- Paste a YT link
- Choose if you want audio only or not
- Download for offline viewing/listering

## License

This project is licensed under the MIT License.