FROM ev3dev/ev3dev-stretch-ev3-generic

RUN echo "robot ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#RUN apt-get install --yes --no-install-recommends python-rosdep python-rosinstall-generator python-wstool python-rosinstall build-essential 
RUN apt-get install --yes --no-install-recommends python-pip build-essential 
RUN sudo pip install -U rosdep rosinstall_generator wstool rosinstall

RUN rosdep init
USER robot
RUN rosdep update

RUN mkdir /home/robot/ros_catkin_ws
WORKDIR /home/robot/ros_catkin_ws

RUN rosinstall_generator robot --rosdistro melodic --deps --tar > melodic-robot.rosinstall
#RUN rosinstall_generator robot --rosdistro melodic --deps --exclude roslisp --tar > melodic-robot.rosinstall
RUN wstool init -j8 src melodic-robot.rosinstall

RUN rosdep install --os=debian:stretch --from-paths src --ignore-src --rosdistro melodic --skip-keys=sbcl -y

RUN ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release
