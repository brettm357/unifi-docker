FROM debian:stretch
MAINTAINER brettm357@me.com

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV UNIFI_VERSION 5.6.2-224554000b

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
  echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" \
    | tee -a /etc/apt/sources.list.d/mongodb.list && \
  echo "deb http://ftp.debian.org/debian jessie-backports main" \
    | tee -a /etc/apt/sources.list.d/jessie-backports.list && \
  apt-get update -q && \
  apt-get --no-install-recommends -y install \
    supervisor \
    binutils \
    wget && \
  apt-get -t jessie-backports --no-install-recommends -y install \
    openjdk-8-jre-headless && \
  apt-get --no-install-recommends -y install \
    jsvc \
    prelink \
    mongodb-server && \    
  wget -nv https://www.ubnt.com/downloads/unifi/$UNIFI_VERSION/unifi_sysvinit_all.deb && \ 
  dpkg --install unifi_sysvinit_all.deb && \ 
  # fix WebRTC stack guard error 
  execstack -c /usr/lib/unifi/lib/native/Linux/amd64/libubnt_webrtc_jni.so && \ 
  rm unifi_sysvinit_all.deb && \ 
  apt-get -y autoremove wget prelink && \ 
  apt-get -q clean && \ 
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /tmp/* /var/tmp/*  
   

# Forward ports
EXPOSE 3478/udp 6789/tcp 8080/tcp 8081/tcp 8443/tcp 8843/tcp 8880/tcp 

# Set internal storage volume
VOLUME ["/usr/lib/unifi""]

# Set working directory for program
WORKDIR /usr/lib/unifi

#  Add supervisor config
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]





#RUN apt-get update
#RUN apt-get -t install jessie-backports openjdk-8-jre-headless

# MongoDB
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
#DD mongodb.list /etc/apt/sources.list.d/mongodb.list
#RUN apt-get update && apt-get -y install mongodb-server

# UniFi
#RUN apt-get -y install jsvc
#RUN curl -L -o unifi_sysvinit_all.deb http://www.ubnt.com/downloads/unifi/5.5.7-0cbda0cd4a/unifi_sysvinit_all.deb
#RUN dpkg --install unifi_sysvinit_all.deb

# fix execstack warning on library
#RUN apt-get install -y \
#	execstack
#RUN execstack -c \
#	/usr/lib/unifi/lib/native/Linux/amd64/libubnt_webrtc_jni.so

# Wipe out auto-generated data
#RUN rm -rf /var/lib/unifi/*

# Volumes and Ports
#WORKDIR /usr/lib/unifi
#VOLUME /config
#EXPOSE 8080 8081 8443 8843 8880

#ADD run.sh /run.sh
#RUN chmod 755 /run.sh

#CMD ["/run.sh"]
