FROM ev3dev/ev3dev-stretch-ev3-generic


RUN DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends ros-robot
