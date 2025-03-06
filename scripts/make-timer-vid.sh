OUTPUT_PATH="${1}"
DISPLAY_TITLE=$(echo "${2}" | sed 's/\([:,{}]\)/\\\1/g')

if [[ "${3}" != "" ]]; then
   META_TITLE="${3}"
else
   META_TITLE="${2}"
fi

LAST_LINE_TEXT=$(echo "${4}" | sed 's/\([:,{}]\)/\\\1/g')

# make a black background
magick -size 720x480 xc:black /tmp/bg.png

# make a video with countdown timer
# see https://gist.github.com/derand/31b8312fd64156120cb8f45825a1f0f7

DURATION_SECONDS=30
FONT_COLOR=white
FRAMES_PER_SEC=23.98
TITLE_FONT_SIZE=36
TITLE_VERTICAL_CENTER_OFFSET=-90
TIMER_FONT_SIZE=64
TIMER_VERTICAL_CENTER_OFFSET=48
LOWER_LINE_VERTICAL_OFFSET=116 # from where the timer is
LOWER_FONT_SIZE=18
LAST_LINE_VERTICAL_OFFSET=144
LAST_LINE_FONT_SIZE=18
MANTISSA_DIGITS=2

echo "Making a ${DURATION_SECONDS} second countdown timer with title '${META_TITLE}' written to '${OUTPUT_PATH}'"

ffmpeg -loop 1 \
   -i /tmp/bg.png \
   -c:v libx264 \
   -r "${FRAMES_PER_SEC}" \
   -t "${DURATION_SECONDS}" \
   -pix_fmt yuv420p \
   -metadata title="${META_TITLE}" \
   -vf "fps=${FRAMES_PER_SEC},drawtext=fontcolor=${FONT_COLOR}:fontsize=${TIMER_FONT_SIZE}:x=(w-text_w)/2:y=((h-text_h)/2)+${TIMER_VERTICAL_CENTER_OFFSET}:text='%{eif\:(${DURATION_SECONDS}-t)\:d}.%{eif\:(mod(${DURATION_SECONDS}-t, 1)*pow(10,${MANTISSA_DIGITS}))\:d\:${MANTISSA_DIGITS}}',drawtext=fontcolor=${FONT_COLOR}:fontsize=${LOWER_FONT_SIZE}:x=(w-text_w)/2:y=((h-text_h)/2)+${LOWER_LINE_VERTICAL_OFFSET}:text='Elapsed\: %{eif\:(t)\:d}.%{eif\:(mod(t, 1)*pow(10,${MANTISSA_DIGITS}))\:d\:${MANTISSA_DIGITS}}',drawtext=fontcolor=${FONT_COLOR}:fontsize=${TITLE_FONT_SIZE}:x=(w-text_w)/2:y=((h-text_h)/2)+${TITLE_VERTICAL_CENTER_OFFSET}:text_align=C:text='${DISPLAY_TITLE}',drawtext=fontcolor=${FONT_COLOR}:fontsize=${LAST_LINE_FONT_SIZE}:x=(w-text_w)/2:y=((h-text_h)/2)+${LAST_LINE_VERTICAL_OFFSET}:text_align=C:text='${LAST_LINE_TEXT}'" \
   "${OUTPUT_PATH}" -y
