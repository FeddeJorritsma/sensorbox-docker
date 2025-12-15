#Use the official multi-arch image
FROM ros:jazzy

#Install the desktop tools, dependencies AND Foxglove Bridge
RUN apt-get update && apt-get install -y \
    ros-jazzy-desktop \
    ros-jazzy-diagnostic-updater \
    ros-jazzy-pcl-ros \
    ros-jazzy-foxglove-bridge \
    python3-pip \
    git \
    xterm \
    can-utils \
    libusb-dev \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

#Create a temporary directory for the .deb files
WORKDIR /tmp/debs

#Make sure the .deb files for the camera are downloaded. It newer version will probably have a different name so change that line below
COPY pylon_25.09.0-deb0_arm64.deb .
COPY pylon-supplementary-package-for-blaze-1.7.3.73dbe706a_arm64.deb .

#Install the .deb files
RUN apt-get update && apt-get install -y \
    ./pylon_25.09.0-deb0_arm64.deb \
    ./pylon-supplementary-package-for-blaze-1.7.3.73dbe706a_arm64.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/debs


RUN rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && rosdep init && rosdep update

WORKDIR /root/ros2_ws/src


# The ROS camera driver
RUN git clone -b jazzy https://github.com/basler/pylon-ros-camera.git


# velodyne LiDAR driver
RUN git clone -b ros2 https://github.com/ros-drivers/velodyne.git


# UBLOX GPS driver 
RUN git clone -b ros2 https://github.com/KumarRobotics/ublox.git

# NTRIP corrections driver

# Custom ROS package to launch all the nodes
RUN git clone https://github.com/FeddeJorritsma/RAS_Sensorbox.git

RUN git clone -b ros2 https://github.com/LORD-MicroStrain/ntrip_client.git



# Install the ROS dependencies and build the workspace
WORKDIR /root/ros2_ws


RUN apt-get update && rosdep install --from-paths src --ignore-src -r -y --rosdistro jazzy \
    && rm -rf /var/lib/apt/lists/*

RUN /bin/bash -c "source /opt/ros/jazzy/setup.bash && colcon build --symlink-install"

# Source ROS and the environment
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc
RUN echo "source /root/ros2_ws/install/setup.bash" >> /root/.bashrc