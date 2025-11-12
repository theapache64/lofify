![](cover.jpeg)

# 🎵 Lofify

![buildStatus](https://img.shields.io/github/workflow/status/theapache64/lofify/Java%20CI%20with%20Gradle?style=plastic)
![latestVersion](https://img.shields.io/github/v/release/theapache64/lofify)
<a href="https://twitter.com/theapache64" target="_blank">
<img alt="Twitter: theapache64" src="https://img.shields.io/twitter/follow/theapache64.svg?style=social" />
</a>

> A simple shell utility to add lofi background music to your videos.

lofify takes videos, adds randomly selected lofi track from collection, with smooth fade-in and fade-out effects, to create perfect ambiance for boring screen recordings 🤷🏼

https://github.com/user-attachments/assets/67b617a2-1832-404e-88e0-23500b5c53a4

## Features

- 🎲 Randomly selects lofi background tracks
- 🎚️ Option to overlay or completely replace original audio
- 🔊 Smart fade-in and fade-out effects
- ⏱️ Automatically trims audio to match video length
- 🎯 Random starting point selection for variety
- 📦 Optional video compression to reduce file size

## Usage

### Basic Usage

Add lofi background music to your video (overlaying with original audio):

```bash
lofify /path/to/your/video.mp4
```

### Replace Original Audio

To completely replace the original audio with lofi music:

```bash
lofify /path/to/your/video.mp4 -r
```

### Compress Video

To compress the video while adding lofi music (reduces file size, but takes longer to process):

```bash
lofify /path/to/your/video.mp4 -c
```

You can also combine flags:

```bash
lofify /path/to/your/video.mp4 -c -r
```

**Note**: Compression uses H.264 codec with CRF 28 and slow preset for optimal file size reduction. This will take significantly longer than the default mode which simply copies the video stream.

### Output

The processed video will be saved as `[original_name]_lofi.mp4` in the same directory as the original video.


## Prerequisites

Before installing Lofify, make sure you have the following dependencies:

- **ffmpeg**: Required for audio/video processing
  - macOS: `brew install ffmpeg`
  - Ubuntu/Debian: `sudo apt install ffmpeg`
  - Other systems: Visit [ffmpeg.org/download.html](https://ffmpeg.org/download.html)

- **bc**: Required for floating-point calculations
  - macOS: `brew install bc`
  - Ubuntu/Debian: `sudo apt install bc`

## Quick Installation

Install Lofify with a single command:

```bash
curl -s https://raw.githubusercontent.com/theapache64/lofify/master/install.sh | bash
```

or

```bash
wget -qO- https://raw.githubusercontent.com/theapache64/lofify/master/install.sh | bash
```

This will:
- Install the Lofify script to your `~/bin` directory
- Set up sample lofi audio files in `~/lofi_audios`
- Add `~/bin` to your PATH (if not already there)

After installation, you may need to restart your terminal or run `source ~/.bashrc` or `source ~/.zshrc` to make the command available in your current session.

## Manual Installation

If you prefer manual installation:

1. Clone the repository:
   ```bash
   git clone https://github.com/theapache64/lofify.git
   ```

2. Make the script executable:
   ```bash
   chmod +x lofify.sh
   ```

3. Move the script to a directory in your PATH:
   ```bash
   mkdir -p ~/bin
   cp lofify.sh ~/bin/lofify
   ```

4. Create a directory for lofi audio files:
   ```bash
   mkdir -p ~/lofi_audios
   ```

5. Copy the sample lofi audio files:
   ```bash
   cp -r lofi_audios/* ~/lofi_audios/
   ```

6. Add `~/bin` to your PATH (if not already there):
   ```bash
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
   source ~/.bashrc  # or source ~/.zshrc
   ```


## Adding Your Own Lofi Tracks

To add your own lofi tracks:

1. Place your audio files (MP3, WAV, or OGG format) in the `~/lofi_audios` directory:
   ```bash
   cp your_lofi_track.mp3 ~/lofi_audios/
   ```

2. That's it! Lofify will now include your tracks in the random selection.

## Examples

### Add lofi background to a screen recording:

```bash
lofify ~/Desktop/screen_recording.mp4
```

### Replace audio in a tutorial video:

```bash
lofify ~/Videos/tutorial.mp4 -r
```

### Compress a large video while adding lofi music:

```bash
lofify ~/Desktop/large_video.mp4 -c
```

### Compress and replace audio (combine both flags):

```bash
lofify ~/Videos/presentation.mp4 -c -r
```

### Author

👤 **theapache64**

* Twitter: <a href="https://twitter.com/theapache64" target="_blank">@theapache64</a>
* Email: theapache64@gmail.com

Feel free to ping me 😉

### Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any
contributions you make are **greatly appreciated**.

1. Open an issue first to discuss what you would like to change.
1. Fork the Project
1. Create your feature branch (`git checkout -b feature/amazing-feature`)
1. Commit your changes (`git commit -m 'Add some amazing feature'`)
1. Push to the branch (`git push origin feature/amazing-feature`)
1. Open a pull request

Please make sure to update tests as appropriate.

## ❤ Show your support

Give a ⭐️ if this project helped you!

<a href="https://www.patreon.com/theapache64">
  <img alt="Patron Link" src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160"/>
</a>

<a href="https://www.buymeacoffee.com/theapache64" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="160">
</a>



## License

```
Copyright © 2025 - theapache64

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

_This README was generated by [readgen](https://github.com/theapache64/readgen)_ ❤
