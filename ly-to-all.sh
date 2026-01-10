#!/bin/bash
#
# Convert all LilyPond files to SVG, MIDI, WebM, and MusicXML.
#
# Prerequisites:
#
# - lilypond 2.24.4
# - fluidsynth 2.5.2
# - FluidR3_GM.sf2
# - ffmpeg 8.0.1
#

# Exit immediately if any command fails
set -xeuo pipefail
IFS=$'\n\t'

SOUNDFONT='FluidR3_GM.sf2'

for file in */*.ly; do
  song="${file%.ly}"

  # Convert LilyPond to SVG and MIDI
  lilypond --svg -dmidi-extension=mid "$song.ly"

  # Set SVG background to white
  ./svg-bg.py "$song.svg"

  # Convert MIDI to WAV
  fluidsynth -ni "$SOUNDFONT" "$song.mid" -F "$song.wav"

  # Convert WAV to WebM
  ffmpeg -y -f lavfi -i 'color=c=black:s=320x180' -i "$song.wav" \
    -c:v libvpx-vp9 -c:a libopus \
    -af 'silenceremove=stop_periods=1:stop_threshold=-50dB' \
    -shortest -pix_fmt yuv420p \
    "$song.webm"

  rm "$song.wav"
done
