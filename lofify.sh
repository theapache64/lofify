#!/bin/bash

# [latest version - i promise!]
echo "🎶 Lofify - v25.11.12.0 (12 Nov 2025)"

# lofify - A script to add random lofi background music to videos
# Usage: lofify <video_file> [-c|-cf] [-r]
#   -c: Compress video (best compression, slower processing)
#   -cf: Compress video fast (good compression, faster processing)
#   -r: Replace original audio instead of overlapping
#   -v <volume>: Set lofi volume (default: 0.5)
#   If no compression flag is provided, you'll be prompted to select a mode

# Check for required dependencies
for cmd in ffmpeg ffprobe bc; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    if [ -n "$TEMP_AUDIO" ] && [ -f "$TEMP_AUDIO" ]; then
        rm "$TEMP_AUDIO"
    fi
}
trap cleanup EXIT

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: lofify <video_file> [-c|-cf] [-r]"
    echo "  -c: Compress video (best compression, slower processing)"
    echo "  -cf: Compress video fast (good compression, faster processing)"
    echo "  -r: Replace original audio instead of overlapping"
    echo "  -v <volume>: Set lofi volume (default: 0.5)"
    echo "  If no compression flag is provided, you'll be prompted to select a mode"
    exit 1
fi

VIDEO_FILE="$1"
REPLACE_AUDIO=0
COMPRESS_VIDEO=0
COMPRESS_FAST=0
VOLUME=0.5

# Parse optional flags
shift # Remove the video file argument
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c)
            COMPRESS_VIDEO=1
            shift
            ;;
        -cf)
            COMPRESS_FAST=1
            shift
            ;;
        -r)
            REPLACE_AUDIO=1
            shift
            ;;
        -v)
            VOLUME="$2"
            shift 2
            ;;
        *)
            echo "Unknown flag: $1"
            echo "Usage: lofify <video_file> [-c|-cf] [-r] [-v <volume>]"
            exit 1
            ;;
    esac
done

# Check for conflicting compression flags
if [ $COMPRESS_VIDEO -eq 1 ] && [ $COMPRESS_FAST -eq 1 ]; then
    echo "Error: Cannot use both -c and -cf flags together"
    exit 1
fi

# Prompt for compression mode if no compression flag was provided
if [ $COMPRESS_VIDEO -eq 0 ] && [ $COMPRESS_FAST -eq 0 ]; then
    echo ""
    echo "Select compression mode:"
    echo "  1) No compression - Fastest, same size as original"
    echo "  2) Fast compression - Quick processing, good file size reduction"
    echo "  3) Balanced compression - Moderate speed, better file size reduction"
    echo "  4) Best compression - Slowest, maximum file size reduction"
    echo ""
    read -p "Enter your choice (1-4): " COMPRESSION_CHOICE

    case "$COMPRESSION_CHOICE" in
        1)
            echo "Selected: No compression"
            # COMPRESS_VIDEO and COMPRESS_FAST remain 0
            ;;
        2)
            echo "Selected: Fast compression"
            COMPRESS_FAST=1
            ;;
        3)
            echo "Selected: Balanced compression"
            COMPRESS_VIDEO=1
            COMPRESS_MODE="medium"
            ;;
        4)
            echo "Selected: Best compression"
            COMPRESS_VIDEO=1
            COMPRESS_MODE="slow"
            ;;
        *)
            echo "Invalid choice. Using no compression."
            ;;
    esac
    echo ""
fi

# Check if video file exists
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Error: Video file not found: $VIDEO_FILE"
    exit 1
fi

# Directory containing lofi audio files
LOFI_DIR="${LOFIFY_PATH:-$HOME/lofi_audios}"

# Check if lofi directory exists
if [ ! -d "$LOFI_DIR" ]; then
    echo "Error: Lofi audio directory not found: $LOFI_DIR"
    exit 1
fi

# Get a random lofi audio file
LOFI_FILES=("$LOFI_DIR"/*.mp3)
if [ ${#LOFI_FILES[@]} -eq 0 ]; then
    echo "Error: No audio files found in $LOFI_DIR"
    exit 1
fi

# Select a random audio file
RANDOM_INDEX=$((RANDOM % ${#LOFI_FILES[@]}))
echo "Found ${#LOFI_FILES[@]} lofi audio files."
LOFI_AUDIO="${LOFI_FILES[$RANDOM_INDEX]}"
echo "Selected lofi track: $(basename "$LOFI_AUDIO")"

# Get video duration using ffprobe
VIDEO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO_FILE")
VIDEO_DURATION=$(printf "%.2f" "$VIDEO_DURATION")
echo "Video duration: $VIDEO_DURATION seconds"

# Get lofi audio duration
AUDIO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$LOFI_AUDIO")

# Calculate a random start point if the audio is longer than the video
START_POINT=0
if (( $(echo "$AUDIO_DURATION > $VIDEO_DURATION" | bc -l) )); then
    MAX_START=$(echo "$AUDIO_DURATION - $VIDEO_DURATION" | bc -l)
    # Generate random float between 0 and MAX_START
    START_POINT=$(echo "scale=2; $RANDOM/32767 * $MAX_START" | bc -l)
    START_POINT=$(printf "%.2f" "$START_POINT")
    echo "Using audio segment starting at $START_POINT seconds"
else
    echo "Audio is shorter than video, using from beginning"
fi

# Create a temporary audio file with the right duration and fades
TEMP_AUDIO="/tmp/temp_lofi_$(date +%s).mp3"

# Apply fade in (0.5s) and fade out (1.5s) and trim to correct duration
FADE_IN=0.5
FADE_OUT=1.5

echo "Preparing lofi audio with fades..."
ffmpeg -y -hide_banner -loglevel error \
    -ss "$START_POINT" \
    -i "$LOFI_AUDIO" \
    -t "$VIDEO_DURATION" \
    -af "afade=t=in:st=0:d=$FADE_IN,afade=t=out:st=$(echo "$VIDEO_DURATION - $FADE_OUT" | bc -l):d=$FADE_OUT" \
    "$TEMP_AUDIO"

if [ $? -ne 0 ]; then
    echo "Error: Failed to process lofi audio."
    exit 1
fi

# Output file name
OUTPUT_FILE="${VIDEO_FILE%.*}_lofi.mp4"

# Set video codec options based on compression flag
if [ $COMPRESS_VIDEO -eq 1 ]; then
    if [ "$COMPRESS_MODE" = "medium" ]; then
        VIDEO_CODEC="-c:v libx264 -crf 28 -preset medium"
        echo "Processing video with balanced compression..."
    else
        VIDEO_CODEC="-c:v libx264 -crf 28 -preset slow"
        echo "Processing video with best compression (this may take a while)..."
    fi
elif [ $COMPRESS_FAST -eq 1 ]; then
    VIDEO_CODEC="-c:v libx264 -crf 28 -preset superfast"
    echo "Processing video with fast compression..."
else
    VIDEO_CODEC="-c:v copy"
    echo "Processing video without compression..."
fi
if [ $REPLACE_AUDIO -eq 1 ]; then
    # Replace the original audio
    echo "Replacing original audio with lofi track..."
    ffmpeg -y -hide_banner -loglevel error \
        -i "$VIDEO_FILE" \
        -i "$TEMP_AUDIO" \
        -map 0:v -map 1:a \
        $VIDEO_CODEC -c:a aac \
        "$OUTPUT_FILE"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to replace audio."
        exit 1
    fi
else
    # Overlay the lofi audio on top of the original audio
    echo "Overlaying lofi track with original audio..."
    ffmpeg -y -hide_banner -loglevel error \
        -i "$VIDEO_FILE" \
        -i "$TEMP_AUDIO" \
        -filter_complex "[0:a][1:a]amix=inputs=2:duration=shortest:weights=1 $VOLUME[a]" \
        -map 0:v -map "[a]" \
        $VIDEO_CODEC -c:a aac \
        "$OUTPUT_FILE"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to overlay audio."
        exit 1
    fi
fi

# Clean up temporary file
# Clean up is handled by trap

echo "✅ Lofified video created: $OUTPUT_FILE"
