#Pull base image
FROM ubuntu:18.04

#Install
RUN \
	apt-get update && \
  	apt-get -y upgrade && \
	apt-get install -y build-essential && \
	apt-get install -y software-properties-common && \
	apt-get install -y byobu curl git htop man unzip zip vim wget && \
	rm -rf /var/lib/apt/lists/*

#Copy directory to /opt
ADD repackage /usr/local/appd
RUN chmod -R 777 /usr/local/appd

# Define working directory.
WORKDIR /usr/local/appd

# Define default command.
CMD ["bash"]









