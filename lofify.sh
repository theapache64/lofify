#!/bin/bash

# [latest version - i promise!]
echo "🎶 Lofify - v25.11.12.0 (12 Nov 2025)"

# lofify - A script to add random lofi background music to videos
# Usage: lofify <video_file> [-c|-cf] [-r]
#   -c: Compress video (slower processing, best compression)
#   -cf: Compress video fast (faster processing, good compression)
#   -r: Replace original audio instead of overlapping

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: lofify <video_file> [-c|-cf] [-r]"
    echo "  -c: Compress video (slower processing, best compression)"
    echo "  -cf: Compress video fast (faster processing, good compression)"
    echo "  -r: Replace original audio instead of overlapping"
    exit 1
fi

VIDEO_FILE="$1"
REPLACE_AUDIO=0
COMPRESS_VIDEO=0
COMPRESS_FAST=0

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
        *)
            echo "Unknown flag: $1"
            echo "Usage: lofify <video_file> [-c|-cf] [-r]"
            exit 1
            ;;
    esac
done

# Check for conflicting compression flags
if [ $COMPRESS_VIDEO -eq 1 ] && [ $COMPRESS_FAST -eq 1 ]; then
    echo "Error: Cannot use both -c and -cf flags together"
    exit 1
fi

# Check if video file exists
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Error: Video file not found: $VIDEO_FILE"
    exit 1
fi

# Directory containing lofi audio files
LOFI_DIR="$HOME/lofi_audios"

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

# Output file name
OUTPUT_FILE="${VIDEO_FILE%.*}_lofi.mp4"

# Set video codec options based on compression flag
if [ $COMPRESS_VIDEO -eq 1 ]; then
    VIDEO_CODEC="-c:v libx264 -crf 28 -preset slow"
    echo "Processing video with compression (this may take a while)..."
elif [ $COMPRESS_FAST -eq 1 ]; then
    VIDEO_CODEC="-c:v libx264 -crf 28 -preset superfast"
    echo "Processing video with fast compression..."
else
    VIDEO_CODEC="-c:v copy"
    echo "Processing video..."
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
else
    # Overlay the lofi audio on top of the original audio
    echo "Overlaying lofi track with original audio..."
    ffmpeg -y -hide_banner -loglevel error \
        -i "$VIDEO_FILE" \
        -i "$TEMP_AUDIO" \
        -filter_complex "[0:a][1:a]amix=inputs=2:duration=shortest:weights=1 0.5[a]" \
        -map 0:v -map "[a]" \
        $VIDEO_CODEC -c:a aac \
        "$OUTPUT_FILE"
fi

# Clean up temporary file
rm "$TEMP_AUDIO"

echo "✅ Lofified video created: $OUTPUT_FILE"
