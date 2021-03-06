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

# Installing rundeck-cluster
RUN curl https://bintray.com/user/downloadSubjectPublicKey?username=bintray > bintray.key 
RUN cat bintray.key | apt-key add -
RUN echo "deb https://rundeckpro.bintray.com/deb stable main" | tee -a /etc/apt/sources.list
RUN apt-get -y update && \ 
    apt-get -y install rundeckpro-cluster


ENV USERNAME=rundeck \
    USER=rundeck \
    HOME=/rundeck-install \
    RDECK_BASE=/var/lib/rundeck 

WORKDIR $HOME

RUN mkdir -p $HOME
RUN mkdir -p $HOME/data
RUN mkdir -p $HOME/scripts
RUN mkdir -p $HOME/plugins

COPY data $HOME/data
COPY scripts $HOME/scripts
COPY plugins $HOME/plugins

RUN chown -R rundeck:rundeck $HOME/scripts
RUN chown -R rundeck:rundeck $HOME/data
RUN chown -R rundeck:rundeck $HOME/plugins
RUN chmod -R a+x $HOME/scripts/*

RUN cp $HOME/plugins/*.* $RDECK_BASE/libext

#install license
RUN mkdir $RDECK_BASE/etc
RUN chown -R rundeck:rundeck $RDECK_BASE/etc

RUN test -f $HOME/data/rundeckpro-license.key && \
     cp $HOME/data/rundeckpro-license.key $RDECK_BASE/etc/rundeckpro-license.key || \
     true

EXPOSE 4440
CMD $HOME/scripts/run

