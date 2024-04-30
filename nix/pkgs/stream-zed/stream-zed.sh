# Launch a gstreamer producer that reads from "/dev/video0" (which is assumed to
# be a ZED Mini camera or similar) and stream the frames to the shared memory
# "/tmp/zed_camera_frames")

function run() {
    local fps=100 # default fps

    while [[ "$#" -gt 0 ]]; do
        key="$1"
        case $key in
            --fps)
                fps=$1
                shift
                ;;
        esac
    done

    gst-launch-1.0 -v v4l2src device=/dev/video0 \
                   ! video/x-raw,format=YUY2,width=1344,height=376,framerate="${fps}"/1 \
                   ! shmsink socket-path=/tmp/zed_camera_frames sync=false \
                   wait-for-connection=true shm-size=10000000
}

run "$@"
