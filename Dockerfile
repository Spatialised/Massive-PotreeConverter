# DockertFile for the Massive-PotreeConverter
FROM ubuntu:16.04
MAINTAINER Oscar Martinez Rubi <o.rubi@esciencecenter.nl>
RUN apt-get update -y

# INSTALL compilers and build toold
RUN apt-get install -y wget git cmake build-essential gcc g++

# install dependencies

RUN apt-get install -y libboost-all-dev

RUN apt-get install -y libgeos-dev libproj-dev libtiff-dev libgeotiff-dev
RUN apt-get install -y libgdal-dev
RUN apt-get install -y libjsoncpp-dev
RUN apt-get install -y python3-pip


# install LASzip
WORKDIR /opt
RUN wget https://github.com/LASzip/LASzip/releases/download/3.2.8/laszip-src-3.2.8.tar.gz
RUN tar xvfz laszip-src-3.2.8.tar.gz
WORKDIR /opt/laszip-src-3.2.8
RUN mkdir build
WORKDIR /opt/laszip-src-3.2.8/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
RUN make; make install

# install PDAL
WORKDIR /opt
RUN wget https://github.com/PDAL/PDAL/releases/download/1.8.0/PDAL-1.8.0-src.tar.gz
RUN tar xvzf PDAL-1.8.0-src.tar.gz
WORKDIR /opt/PDAL-1.8.0-src
RUN mkdir makefiles
WORKDIR /opt/PDAL-1.8.0-src/makefiles
RUN cmake -G "Unix Makefiles" ../
RUN make ; make install

# INSTALL PotreeConverter
WORKDIR /opt
RUN git clone https://github.com/potree/PotreeConverter.git
WORKDIR /opt/PotreeConverter
RUN mkdir build
WORKDIR /opt/PotreeConverter/build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release -DLASZIP_INCLUDE_DIRS=/usr/include/laszip -DLASZIP_LIBRARY=/usr/lib/liblaszip.so
RUN make ; make install ; ldconfig
#RUN cp -R PotreeConverter/resources /usr
WORKDIR /opt
RUN rm -rf PotreeConverter
#RUN ln -s /opt/PotreeConverter/build/PotreeConverter/PotreeConverter /usr/local/bin/PotreeConverter

# INSTALL LAStools
WORKDIR /opt
RUN wget http://www.cs.unc.edu/~isenburg/lastools/download/lastools.zip
RUN apt-get install -y unzip
RUN unzip lastools.zip
WORKDIR /opt/LAStools/
RUN make
RUN ln -s /opt/LAStools/bin/lasinfo /usr/local/sbin/lasinfo
RUN ln -s /opt/LAStools/bin/lasmerge /usr/local/sbin/lasmerge


# INSTALL pycoeman
RUN apt-get install -y python-pip python-dev build-essential libfreetype6-dev libssl-dev libffi-dev
RUN pip3 install git+https://github.com/NLeSC/pycoeman

# INSTALL Massive-PotreeConverter
RUN pip3 install git+https://github.com/NLeSC/Massive-PotreeConverter

# Create 3 volumes to be used when running the script. Ideally each run must be mounted to a different physical device
VOLUME ["/data1"]
VOLUME ["/data2"]
VOLUME ["/data3"]

WORKDIR /data1
