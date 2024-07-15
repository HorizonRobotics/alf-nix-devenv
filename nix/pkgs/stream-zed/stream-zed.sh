#!/bin/bash

# Launch a gstreamer producer that reads from a specified camera device (default
# "/dev/video0") and streams the frames to the shared memory "/tmp/zed_camera_frames"

# Usage examples:
#
# 1. Default usage:
#    Stream from the default camera device (/dev/video0) at 100 fps.
#    $ stream-zed
#
# 2. Specify a different camera device:
#    Stream from a specific camera device (/dev/video1) at 100 fps.
#    $ stream-zed /dev/video1
#
# 3. Specify a different frame rate:
#    Stream from the default camera device (/dev/video0) at 60 fps.
#    $ stream-zed --fps 60
#
# 4. Specify both camera device and frame rate:
#    Stream from a specific camera device (/dev/video1) at 60 fps.
#    $ stream-zed /dev/video1 --fps 60

function run() {
    local fps=100  # default fps
    local device="/dev/video0"  # default camera device

    # Process the command line arguments
    while [[ "$#" -gt 0 ]]; do
        key="$1"
        case $key in
            --fps)
                fps=$2
                shift 2
                ;;
            *)
                device=$1
                shift
                ;;
        esac
    done

    echo "${device} ${fps}"

    gst-launch-1.0 -v v4l2src device="$device" \
                   ! video/x-raw,format=YUY2,width=1344,height=376,framerate="${fps}"/1 \
                   ! shmsink socket-path=/tmp/zed_camera_frames sync=false \
                   wait-for-connection=true shm-size=10000000
}

run "$@"
