#!/bin/bash

# A stable internet connection is needed for this
# This script will build the opencv library from source
# I have taken this approach since the opencv library is not natively available in ARM through pip/PyPi

# Update and upgrade packages in the Pi
echo "Updating and upgrading your Pi..."
sudo apt-get update -y && sudo apt-get upgrade -y && sudo rpi-update -y

# Change the swap size to 2GB so as to have a stable build
sudo echo "CONF_SWAPSIZE=2048" >> /etc/dphys-swapfile
sudo systemctl restart dphys-swapfile

# Install build dependencies
echo "Installing all required dependencies..."
sudo apt-get install build-essential cmake pkg-config -y
sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev -y
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev -y
sudo apt-get install libxvidcore-dev libx264-dev -y
sudo apt-get install libgtk2.0-dev libgtk-3-dev -y
sudo apt-get install libatlas-base-dev gfortran -y

# Grub the opencv library source code and unzip
echo "Going back to the home directory..."
cd ~
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.4.0.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.4.0.zip
unzip opencv.zip
unzip opencv_contrib.zip

# Install minor dependency
sudo pip3 install numpy

cd ~
cd ~/opencv-4.4.0

# Get ready for the build
mkdir build
cd build
echo "Initiating build process..."
cmake -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-4.4.0/modules \
  -D BUILD_EXAMPLES=ON ..

# Use 4 threads for the build. (I've done this with the RPi 3B+ so that's the amount of threads I could allocate)
make -j4
sudo make install && sudo ldconfig
echo "Build complete."

# Reboot the Pi if need be. But everything should be working at this point
