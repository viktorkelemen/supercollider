#!/bin/bash
# Sound Type Classifier
# Analyzes an audio file and suggests the appropriate analysis template
#
# Usage: ./classify_sound.sh <audio_file>
#
# Returns: Suggested template and confidence metrics

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <audio_file>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File not found: $FILE"
    exit 1
fi

echo "========================================"
echo "Sound Type Classifier"
echo "========================================"
echo "File: $FILE"
echo ""

# Get basic file info
DURATION=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FILE" 2>/dev/null)
DURATION_INT=${DURATION%.*}
echo "Duration: ${DURATION}s"

# Count transients (silence gaps = hits)
TRANSIENT_COUNT=$(ffmpeg -i "$FILE" -af "silencedetect=noise=-40dB:d=0.03" -f null - 2>&1 | grep -c "silence_end" || echo "0")
echo "Transient count: $TRANSIENT_COUNT"

# Calculate transients per second
if (( $(echo "$DURATION > 0" | bc -l) )); then
    TRANSIENTS_PER_SEC=$(echo "scale=2; $TRANSIENT_COUNT / $DURATION" | bc)
else
    TRANSIENTS_PER_SEC=0
fi
echo "Transients/sec: $TRANSIENTS_PER_SEC"

# Get spectral flux (amount of change over time)
SPECTRAL_FLUX=$(ffmpeg -i "$FILE" -af "aspectralstats=measure=flux,ametadata=print:key=lavfi.aspectralstats.1.flux:file=-" -f null - 2>/dev/null | grep "flux" | awk -F= '{sum+=$2; count++} END {if(count>0) print sum/count; else print 0}')
echo "Avg spectral flux: $SPECTRAL_FLUX"

# Get spectral centroid range (brightness variation)
CENTROID_DATA=$(ffmpeg -i "$FILE" -af "aspectralstats=measure=centroid,ametadata=print:key=lavfi.aspectralstats.1.centroid:file=-" -f null - 2>/dev/null | grep "centroid" | awk -F= '{print $2}')
CENTROID_MIN=$(echo "$CENTROID_DATA" | sort -n | head -1)
CENTROID_MAX=$(echo "$CENTROID_DATA" | sort -n | tail -1)
CENTROID_RANGE=$(echo "scale=0; $CENTROID_MAX - $CENTROID_MIN" | bc 2>/dev/null || echo "0")
echo "Centroid range: ${CENTROID_MIN:-0} - ${CENTROID_MAX:-0} Hz (range: ${CENTROID_RANGE:-0})"

# Get RMS variance (dynamic range indicator)
RMS_DATA=$(ffmpeg -i "$FILE" -af "astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level:file=-" -f null - 2>/dev/null | grep "RMS" | awk -F= '{print $2}')
RMS_VARIANCE=$(echo "$RMS_DATA" | awk '{sum+=$1; sumsq+=$1*$1; count++} END {if(count>0) print sqrt(sumsq/count - (sum/count)^2); else print 0}')
echo "RMS variance: $RMS_VARIANCE dB"

# Check for pitch stability (indicates melodic content)
# High variance in pitch = FX/sweep, low variance = melodic/drone
echo ""

echo "========================================"
echo "Classification Scores"
echo "========================================"

# Scoring logic
DRUMS_SCORE=0
MELODIC_SCORE=0
PADS_SCORE=0
FX_SCORE=0

# Duration-based scoring
if (( $(echo "$DURATION < 2" | bc -l) )); then
    DRUMS_SCORE=$((DRUMS_SCORE + 20))
    FX_SCORE=$((FX_SCORE + 15))
elif (( $(echo "$DURATION < 5" | bc -l) )); then
    DRUMS_SCORE=$((DRUMS_SCORE + 10))
    MELODIC_SCORE=$((MELODIC_SCORE + 15))
    FX_SCORE=$((FX_SCORE + 20))
elif (( $(echo "$DURATION < 15" | bc -l) )); then
    MELODIC_SCORE=$((MELODIC_SCORE + 20))
    PADS_SCORE=$((PADS_SCORE + 15))
else
    PADS_SCORE=$((PADS_SCORE + 25))
fi

# Transient density scoring
if (( $(echo "$TRANSIENTS_PER_SEC > 4" | bc -l) )); then
    DRUMS_SCORE=$((DRUMS_SCORE + 30))
elif (( $(echo "$TRANSIENTS_PER_SEC > 1" | bc -l) )); then
    DRUMS_SCORE=$((DRUMS_SCORE + 20))
    MELODIC_SCORE=$((MELODIC_SCORE + 10))
elif (( $(echo "$TRANSIENTS_PER_SEC > 0.3" | bc -l) )); then
    MELODIC_SCORE=$((MELODIC_SCORE + 15))
    FX_SCORE=$((FX_SCORE + 10))
else
    PADS_SCORE=$((PADS_SCORE + 25))
fi

# Spectral flux scoring (high flux = changing sound)
FLUX_VAL=$(echo "${SPECTRAL_FLUX:-0}" | bc -l 2>/dev/null || echo "0")
if (( $(echo "$FLUX_VAL > 0.1" | bc -l) )); then
    FX_SCORE=$((FX_SCORE + 20))
    DRUMS_SCORE=$((DRUMS_SCORE + 10))
elif (( $(echo "$FLUX_VAL > 0.01" | bc -l) )); then
    MELODIC_SCORE=$((MELODIC_SCORE + 15))
    DRUMS_SCORE=$((DRUMS_SCORE + 10))
else
    PADS_SCORE=$((PADS_SCORE + 20))
fi

# Centroid range scoring (wide range = FX/sweep)
CENTROID_VAL=$(echo "${CENTROID_RANGE:-0}" | bc -l 2>/dev/null || echo "0")
if (( $(echo "$CENTROID_VAL > 3000" | bc -l) )); then
    FX_SCORE=$((FX_SCORE + 25))
elif (( $(echo "$CENTROID_VAL > 1000" | bc -l) )); then
    MELODIC_SCORE=$((MELODIC_SCORE + 15))
    FX_SCORE=$((FX_SCORE + 10))
else
    PADS_SCORE=$((PADS_SCORE + 15))
    DRUMS_SCORE=$((DRUMS_SCORE + 10))
fi

# RMS variance scoring (high variance = percussive/dynamic)
RMS_VAL=$(echo "${RMS_VARIANCE:-0}" | bc -l 2>/dev/null || echo "0")
if (( $(echo "$RMS_VAL > 10" | bc -l) )); then
    DRUMS_SCORE=$((DRUMS_SCORE + 20))
    FX_SCORE=$((FX_SCORE + 10))
elif (( $(echo "$RMS_VAL > 5" | bc -l) )); then
    MELODIC_SCORE=$((MELODIC_SCORE + 15))
    DRUMS_SCORE=$((DRUMS_SCORE + 10))
else
    PADS_SCORE=$((PADS_SCORE + 20))
fi

echo "Drums/Percussion: $DRUMS_SCORE"
echo "Melodic:          $MELODIC_SCORE"
echo "Pads/Textures:    $PADS_SCORE"
echo "FX/Transitions:   $FX_SCORE"

echo ""
echo "========================================"
echo "Recommendation"
echo "========================================"

# Find highest score
MAX_SCORE=$DRUMS_SCORE
RECOMMENDED="drums"
TEMPLATE="drum_analysis_template.md"

if [ $MELODIC_SCORE -gt $MAX_SCORE ]; then
    MAX_SCORE=$MELODIC_SCORE
    RECOMMENDED="melodic"
    TEMPLATE="melodic_analysis_template.md"
fi

if [ $PADS_SCORE -gt $MAX_SCORE ]; then
    MAX_SCORE=$PADS_SCORE
    RECOMMENDED="pads/textures"
    TEMPLATE="pads_textures_analysis_template.md"
fi

if [ $FX_SCORE -gt $MAX_SCORE ]; then
    MAX_SCORE=$FX_SCORE
    RECOMMENDED="fx/transitions"
    TEMPLATE="fx_transitions_analysis_template.md"
fi

# Check for close scores (ambiguous classification)
SCORES=($DRUMS_SCORE $MELODIC_SCORE $PADS_SCORE $FX_SCORE)
SORTED_SCORES=($(echo "${SCORES[@]}" | tr ' ' '\n' | sort -rn))
SECOND_SCORE=${SORTED_SCORES[1]}
SCORE_DIFF=$((MAX_SCORE - SECOND_SCORE))

echo "Primary type: $RECOMMENDED (score: $MAX_SCORE)"
echo "Template: prompts/$TEMPLATE"

if [ $SCORE_DIFF -lt 10 ]; then
    echo ""
    echo "⚠️  Note: Classification is ambiguous (close scores)."
    echo "   Consider reviewing the sound manually or using hybrid approach."
fi

echo ""
echo "========================================"
echo "Quick Analysis Summary"
echo "========================================"

# Provide quick insights based on type
case $RECOMMENDED in
    "drums")
        echo "• High transient density suggests percussive content"
        echo "• Focus on: attack, decay, rhythm pattern, intervals"
        echo "• Key params: transient sharpness, frequency bands, BPM"
        ;;
    "melodic")
        echo "• Moderate transients with tonal content likely"
        echo "• Focus on: pitch, harmonics, envelope, vibrato"
        echo "• Key params: fundamental freq, waveform, filter, ADSR"
        ;;
    "pads/textures")
        echo "• Low transient density, sustained character"
        echo "• Focus on: spectral evolution, modulation, stereo"
        echo "• Key params: detuning, filter movement, reverb, width"
        ;;
    "fx/transitions")
        echo "• Significant spectral movement detected"
        echo "• Focus on: pitch contour, filter sweep, duration"
        echo "• Key params: start/end freq, curve type, layers"
        ;;
esac

echo ""
