#!/bin/bash

# install.sh - Installation script for lofify
# This script downloads lofify.sh, sets it up in PATH, and sets up lofi_audios directory

# Print colored text
print_color() {
  local color=$1
  local text=$2
  
  case $color in
    "green") echo -e "\033[0;32m$text\033[0m" ;;
    "blue") echo -e "\033[0;34m$text\033[0m" ;;
    "red") echo -e "\033[0;31m$text\033[0m" ;;
    *) echo "$text" ;;
  esac
}

# Check if ffmpeg is installed
check_ffmpeg() {
  if ! command -v ffmpeg &> /dev/null; then
    print_color "red" "❌ ffmpeg is not installed, which is required for lofify."
    print_color "blue" "Please install ffmpeg first:"
    echo "  - For macOS: brew install ffmpeg"
    echo "  - For Ubuntu/Debian: sudo apt install ffmpeg"
    echo "  - For other systems: visit https://ffmpeg.org/download.html"
    exit 1
  else
    print_color "green" "✅ ffmpeg is installed"
  fi
}

# Check if bc is installed (required for floating point calculations)
check_bc() {
  if ! command -v bc &> /dev/null; then
    print_color "red" "❌ bc is not installed, which is required for lofify."
    print_color "blue" "Please install bc first:"
    echo "  - For macOS: brew install bc"
    echo "  - For Ubuntu/Debian: sudo apt install bc"
    exit 1
  else
    print_color "green" "✅ bc is installed"
  fi
}

# Create the installation directory
setup_directories() {
  print_color "blue" "Setting up directories..."
  
  # Create lofi_audios directory in home directory if it doesn't exist
  if [ ! -d "$HOME/lofi_audios" ]; then
    mkdir -p "$HOME/lofi_audios"
    print_color "green" "✅ Created $HOME/lofi_audios directory"
  else
    print_color "green" "✅ $HOME/lofi_audios directory already exists"
  fi
  
  # Create bin directory in home if it doesn't exist
  if [ ! -d "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
    print_color "green" "✅ Created $HOME/bin directory"
  else
    print_color "green" "✅ $HOME/bin directory already exists"
  fi
}

# Download lofify script
download_lofify() {
  print_color "blue" "Downloading lofify script..."
  
  # Download the script
  if curl -s -f -L "https://raw.githubusercontent.com/theapache64/lofify/master/lofify.sh" -o "$HOME/bin/lofify"; then
    chmod +x "$HOME/bin/lofify"
    print_color "green" "✅ Downloaded and made lofify executable"
  else
    print_color "red" "❌ Failed to download lofify.sh"
    exit 1
  fi
}

# Download sample lofi audio files
download_sample_audio() {
  print_color "blue" "Downloading sample lofi audio files..."
  
  # Sample files from the repository
  FILES=(
    "Japan Coastal Vibes 🌅 Lofi Mix for Focus and Relaxation.mp3"
    "Rainy Japanese Street 🌧 No Copyright Lofi Hip Hop Mix 2022 🌧 Sleep Lofi Beats with Rain Sounds.mp3"
  )
  
  # Create a temporary directory for downloading
  TEMP_DIR=$(mktemp -d)
  
  for file in "${FILES[@]}"; do
    ENCODED_FILENAME=$(echo "$file" | sed 's/ /%20/g' | sed 's/🌅/%F0%9F%8C%85/g' | sed 's/🌧/%F0%9F%8C%A7/g')
    
    if curl -s -f -L "https://raw.githubusercontent.com/theapache64/lofify/master/lofi_audios/$ENCODED_FILENAME" -o "$TEMP_DIR/$file"; then
      # Move to the final destination
      mv "$TEMP_DIR/$file" "$HOME/lofi_audios/"
      print_color "green" "✅ Downloaded: $file"
    else
      print_color "red" "❌ Failed to download: $file"
    fi
  done
  
  # Remove temporary directory
  rm -rf "$TEMP_DIR"
}

# Update PATH if needed
update_path() {
  # Determine which shell configuration file to use
  SHELL_CONFIG=""
  if [ -f "$HOME/.zshrc" ] && [ "$SHELL" = "/bin/zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
  elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
  elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
  fi
  
  if [ -n "$SHELL_CONFIG" ]; then
    # Check if PATH already contains $HOME/bin
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_CONFIG"; then
      echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_CONFIG"
      print_color "green" "✅ Added $HOME/bin to your PATH in $SHELL_CONFIG"
      print_color "blue" "Please run 'source $SHELL_CONFIG' or start a new terminal session to update your PATH"
    else
      print_color "green" "✅ PATH already includes $HOME/bin"
    fi
  else
    print_color "red" "⚠️  Could not determine your shell configuration file."
    print_color "blue" "Please manually add the following line to your shell configuration file:"
    echo 'export PATH="$HOME/bin:$PATH"'
  fi
}

# Main installation process
main() {
  print_color "blue" "🎵 Installing lofify..."
  
  check_ffmpeg
  check_bc
  setup_directories
  download_lofify
  download_sample_audio
  update_path
  
  print_color "green" "\n🎉 Lofify has been successfully installed!"
  print_color "blue" "Usage: lofify <video_file> [-r]"
  print_color "blue" "  -r: Replace original audio instead of overlapping"
  print_color "blue" "\nYou might need to restart your terminal or run 'source ~/.bashrc' or 'source ~/.zshrc'"
  print_color "blue" "to make the command available in your current session."
}

# Run the installation
main