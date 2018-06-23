FROM ev3dev/ev3dev-stretch-ev3-generic

RUN echo "robot ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN dpkg --add-architecture amd64 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        libc6:amd64 libz1:amd64 liblzma5:amd64 libncurses5:amd64 libpython2.7:amd64

# install the cross-compiler toolchain
RUN mkdir -p /brickstrap/cross && \
    cd /brickstrap/cross && \
    wget https://github.com/ev3dev/ev3dev-crosstool-ng/releases/download/gcc-ev3dev-6.3.0-2017.10/gcc-ev3dev-6.3.0-2017.10-x86_64_arm-ev3-linux-gnueabi.tar.gz && \
    tar xf gcc-ev3dev-6.3.0-2017.10-x86_64_arm-ev3-linux-gnueabi.tar.gz && \
    rm gcc-ev3dev-6.3.0-2017.10-x86_64_arm-ev3-linux-gnueabi.tar.gz && \
    ln -s gcc-ev3dev-6.3.0-2017.10-x86_64_arm-ev3-linux-gnueabi arm-ev3-linux-gnueabi

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV ROS_PYTHON_VERSION 3

RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends python3-pip build-essential 
RUN pip3 install -U rosdep rosinstall_generator wstool rosinstall

RUN rosdep init
USER robot
RUN rosdep update

RUN mkdir /home/robot/ros_catkin_ws
WORKDIR /home/robot/ros_catkin_ws

RUN rosinstall_generator ros_comm --rosdistro melodic --deps --tar > melodic-ros_comm.rosinstall
RUN wstool init -j8 src melodic-ros_comm.rosinstall

RUN rosdep install --os=debian:stretch --from-paths src --ignore-src --rosdistro melodic --skip-keys=sbcl -y

# install missing py3 deps
RUN sudo pip3 install empy
COPY toolchain.cmake /home/robot/toolchain.cmake
RUN python3 ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --cmake-args -DCMAKE_TOOLCHAIN_FILE=/home/robot/toolchain.cmake

RUN DEBIAN_FRONTEND=noninteractive sudo apt-get purge --yes ".*:amd64" && \
    sudo dpkg --remove-architecture amd64
