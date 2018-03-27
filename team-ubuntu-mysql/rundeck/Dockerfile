FROM ubuntu:16.04

## General package configuration
RUN apt-get -y update && \
         apt-get -y install \
         sudo \
         unzip \
         curl \
         xmlstarlet \
         git \
         netcat-traditional \
         software-properties-common \
         debconf-utils \
         uuid-runtime \
         ncurses-bin \
         iputils-ping \
         net-tools \
         zip \
         openssh-server \
         openssh-client \
         apt-transport-https \
         wget

## Install Java
RUN \
 add-apt-repository -y ppa:openjdk-r/ppa  && \
 apt-get update && \
 apt-get install -y openjdk-8-jdk 

# Installing rundeck-team
RUN curl https://bintray.com/user/downloadSubjectPublicKey?username=bintray > bintray.key 
RUN cat bintray.key | apt-key add -
RUN echo "deb https://rundeckpro.bintray.com/deb stable main" | tee -a /etc/apt/sources.list
RUN apt-get -y update && \ 
    apt-get -y install rundeckpro-team


ENV USERNAME=rundeck \
    USER=rundeck \
    HOME=/rundeck-install \
    RDECK_BASE=/var/lib/rundeck 

RUN mkdir -p $HOME
RUN mkdir -p $HOME/data
RUN mkdir -p $HOME/scripts
RUN mkdir -p $HOME/plugins

COPY data $HOME/data
COPY scripts $HOME/scripts
COPY plugins $HOME/libext

RUN chown -R rundeck:rundeck $HOME/scripts
RUN chown -R rundeck:rundeck $HOME/data
RUN chown -R rundeck:rundeck $HOME/plugins
RUN chmod -R a+x $HOME/scripts/*

#RUN cp $HOME/plugins/*.* $RDECK_BASE/libext

EXPOSE 4440
CMD $HOME/scripts/run.sh

