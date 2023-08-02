FROM ros:foxy
# ENV ROS_DISTRO=foxy

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    curl tree \
    build-essential \
    python3-pip \
    python3-dev

RUN pip3 install cython
RUN apt-get install -y \
    ros-$ROS_DISTRO-xacro \
    ros-$ROS_DISTRO-controller-interface \
    ros-$ROS_DISTRO-controller-manager \
    ros-$ROS_DISTRO-robot-localization \
    ros-$ROS_DISTRO-interactive-marker-twist-server \
    ros-$ROS_DISTRO-twist-mux \
    ros-$ROS_DISTRO-joy \
    ros-$ROS_DISTRO-realsense2-camera \
    ros-$ROS_DISTRO-teleop-twist-joy
   

# copy in source files from working repo
RUN mkdir -p /ros2_ws/src
WORKDIR /ros2_ws/src
COPY ./husky ./husky
COPY ./ouster-ros ./ouster-ros
#COPY ./cci_husky ./cci_husky

# needed to skip interactive install prompts
ENV DEBIAN_FRONTEND=noninteractive

# install dependencies
WORKDIR /ros2_ws
RUN rosdep update --rosdistro=$ROS_DISTRO
RUN rosdep install --from-paths src --ignore-src --rosdistro=$ROS_DISTRO -y

# build the ros2 workspace
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && colcon build

# Update ros_entrypoint.sh
RUN /bin/sed -i \
  '/source "\/opt\/ros\/$ROS_DISTRO\/setup.bash"/a source "\/ros2_ws\/install\/setup.bash"' \
  /ros_entrypoint.sh
