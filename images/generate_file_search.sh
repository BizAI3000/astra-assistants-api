#!/bin/bash

set -x

# List of models
models=("gpt4-o" "claude-3-5-sonnet" "groq/llama3-8b-8192" "cohere/command-r-plus" "ollama_chat/deepseek_coder_v2" "gemini/gemini-1.5-pro-latest" "pplx-70b-online")

# Counter for frame numbers
counter=1

# Generate silicon images for each model
for model in "${models[@]}"; do
  silicon -o frame${counter}.png -l python -f 'Hack; DejaVu Sans Mono=31' --background '#4f2a83' --shadow-color '#555' --shadow-blur-radius 30 <<EOF
from openai import OpenAI
from astra_assistants import patch

client = patch(OpenAI())

with open("how_to_code_better_volume_3.pdf", "rb") as f:
    file = openai_client.files.create(purpose="assistants", file=f)

assistant = client.beta.assistants.create(
    instructions="You are an ASCII artist, reply only with art.",
    model="${model}",
    tools=[{"type": "file_search"}],
    tool_resources={'file_search': {'vector_stores': [{'file_ids': [file.id]}]}}
)
EOF
  counter=$((counter + 1))
done

# Duplicate frames to increase display time (2 seconds per frame at 1 fps)
for i in $(seq 1 ${#models[@]}); do
  for j in {1..30}; do
    cp frame${i}.png frame${i}_${j}.png
  done
done

# Create a high-quality palette with more colors
ffmpeg -i frame1_1.png -vf "palettegen=stats_mode=full:max_colors=256" -y palette.png

# Create animated GIF using ffmpeg with optimized settings
#ffmpeg -framerate 30 -pattern_type glob -i 'frame*_?.png' -i palette.png -filter_complex "fps=1,scale=1920:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=floyd_steinberg" -y create_assistant.gif
ffmpeg -framerate 30 -pattern_type glob -i 'frame*_*.png' -i palette.png -filter_complex "fps=1,scale=1920:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=floyd_steinberg" -y create_assistant_file_search.gif

# Clean up the individual frames
rm frame*.png palette.png
