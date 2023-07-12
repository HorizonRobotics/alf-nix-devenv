// Copyright (c) 2023 Horizon Robotics and Hobot Contributors. All Rights
// Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <easylogging++.h>
#include <pybind11/numpy.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include <mutex>  // NOLINT

#include <librealsense2/rs.hpp>
#include <librealsense2-net/rs_net.hpp>

/***

* Install RealSense SDK on workstation:

sudo apt-get install libusb-1.0-0-dev
sudo apt-get install libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev libssl-dev

git clone https://github.com/HorizonRoboticsInternal/librealsense.git
mkdir librealsense/build
cd librealsense/build
cmake -DCMAKE_BUILD_TYPE=Release \
  -DOpenGL_GL_PREFERENCE=GLVND \
  -DBUILD_NETWORK_DEVICE=ON  ..
make -j8
sudo make install

* Install RealSense SDK On Raspberry Pi

sudo apt install cmake
sudo apt-get install libusb-1.0-0-dev

git clone https://github.com/HorizonRoboticsInternal/librealsense.git
mkdir librealsense/build
cd librealsense/build
cmake -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_NETWORK_DEVICE=ON \
  -DFORCE_RSUSB_BACKEND=ON \
  -DBUILD_GLSL_EXTENSIONS=ON \
  -DBUILD_EXAMPLES=OFF ..
make -j4
sudo make install
sudo cp ../config/99-realsense-libusb.rules /etc/udev/rules.d/

* Compile real_sense_sensor.cpp using the following commend:

PYTHON=python3.8
LIBREALSENSE_REPO=~/code/librealsense  # CHANGE TO YOUR librealsense repo path

g++ -O3 -Wall -shared -std=c++17 -fPIC -fvisibility=hidden \
  -I$LIBREALSENSE_REPO/third-party/easyloggingpp/src \
 `$PYTHON -m pybind11 --includes` \
  real_sense_sensor.cpp \
  -o real_sense_sensor`$PYTHON-config --extension-suffix` -lrt \
  -lrealsense2-net -lrealsense2

***/

namespace py = pybind11;

class RealSenseSensor {
 public:
  RealSenseSensor(const std::string& address,
                  int width = 424,
                  int height = 240,
                  int fps = 30);
  py::array GetLatestFrame();
  ~RealSenseSensor();

 private:
  std::mutex mutex_;
  std::unique_ptr<rs2::pipeline> pipeline_;
  rs2::frame frame_;
  void Callback(rs2::frame frame);
};

void DisableLogging() {
  // Disable librealsense logging
  el::Loggers::getLogger("librealsense");
  el::Loggers::reconfigureAllLoggers(
      el::Level::Global, el::ConfigurationType::ToStandardOutput, "false");
}

RealSenseSensor::RealSenseSensor(const std::string& address,
                                 int width,
                                 int height,
                                 int fps) {
  DisableLogging();
  if (address != "") {
    rs2::net_device dev(address);
    rs2::context ctx;
    dev.add_to(ctx);
    pipeline_ = std::make_unique<rs2::pipeline>(ctx);
  } else {
    pipeline_ = std::make_unique<rs2::pipeline>();
  }
  rs2::config config;
  config.enable_stream(RS2_STREAM_COLOR, width, height, RS2_FORMAT_RGB8, fps);
  pipeline_->start(config, [this](rs2::frame frame) { Callback(frame); });

  // loop until first frame
  while (true) {
    {
      std::lock_guard lock(mutex_);
      if (frame_) break;
    }
    sleep(1);
  }
}

void RealSenseSensor::Callback(rs2::frame frame) {
  std::lock_guard lock(mutex_);
  frame_ = frame;
}

py::array RealSenseSensor::GetLatestFrame() {
  rs2::frame f;
  {
    std::lock_guard lock(mutex_);
    f = frame_;
  }
  rs2::frameset frameset(f.as<rs2::frameset>());
  rs2::video_frame frame = frameset.get_color_frame();
  const void* data = frame.get_data();
  std::vector<ssize_t> shape{
      frame.get_height(), frame.get_width(), frame.get_bytes_per_pixel()};
  std::vector<ssize_t> strides{
      frame.get_stride_in_bytes(), frame.get_bytes_per_pixel(), 1};
  py::buffer_info info(const_cast<void*>(data),
                       1,  // itemsize
                       py::format_descriptor<uint8_t>::format(),
                       3,  // ndim
                       shape,
                       strides);
  return py::array(info);
}

RealSenseSensor::~RealSenseSensor() { pipeline_->stop(); }

struct StreamProfile {
  std::string type;
  std::string format;
  int width;
  int height;
  int fps;
};

std::vector<StreamProfile> GetAvailableStreams(const std::string& address) {
  DisableLogging();
  std::unique_ptr<rs2::device> dev;
  if (address != "") {
    dev = std::make_unique<rs2::net_device>(address);
  } else {
    rs2::context ctx;
    rs2::device_list devices = ctx.query_devices();
    if (devices.size() == 0) {
      return {};
    }
    dev = std::make_unique<rs2::device>(devices[0]);
  }
  std::vector<rs2::sensor> sensors = dev->query_sensors();
  std::vector<StreamProfile> sprofs;
  for (rs2::sensor& sensor : sensors) {
    auto profiles = sensor.get_stream_profiles();
    for (auto& profile : profiles) {
      if (profile.is<rs2::video_stream_profile>()) {
        auto prof = profile.as<rs2::video_stream_profile>();
        sprofs.emplace_back(
            StreamProfile{rs2_stream_to_string(prof.stream_type()),
                          rs2_format_to_string(prof.format()),
                          prof.width(),
                          prof.height(),
                          prof.fps()});
      }
    }
  }
  return sprofs;
}

PYBIND11_MODULE(real_sense_sensor, m) {
  m.def("get_available_streams", &GetAvailableStreams, py::arg("address"));
  py::class_<StreamProfile>(m, "StreamProfile")
      .def_readwrite("type", &StreamProfile::type)
      .def_readwrite("format", &StreamProfile::format)
      .def_readwrite("width", &StreamProfile::width)
      .def_readwrite("height", &StreamProfile::height)
      .def_readwrite("fps", &StreamProfile::fps);
  py::class_<RealSenseSensor>(m, "RealSenseSensor")
      .def(py::init<const std::string&, int, int, int>(),
           R"pbdoc(
            Create RealSenseSensor

            Note that only specific combinations of (width, height, fps) are available,
            which can be found by calling ``get_available_streams()``.

            Args:
                address (str): address of the rs-server. If empty, local device
                    is used.
                width (int): width of the images. Default: 424.
                height (int): height of the images. Default: 240.
                fps (int): frame rate. Default: 30.
        )pbdoc",
           py::arg("address"),
           py::arg("width") = 424,
           py::arg("height") = 240,
           py::arg("fps") = 30)
      .def("get_latest_frame",
           &RealSenseSensor::GetLatestFrame,
           R"pbdoc(
                Get the latest frame.

                Returns:
                  numpy array of the image. The shape of the numpy array is
                  (height, width, 3).
            )pbdoc");
}
