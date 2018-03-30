FROM centos:7

RUN yum -y update && \
    yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel \
    sudo \
    unzip \
    curl \
    xmlstarlet \
    git \
    netcat-traditional \
    uuid-runtime \
    net-tools \
    zip \
    openssh-server \
    openssh-client \
    apt-transport-https \
    wget


# Install rundeck
RUN wget https://bintray.com/rundeckpro/rpm/rpm -O bintray-rundeckpro-rpm.repo
RUN mv bintray-rundeckpro-rpm.repo /etc/yum.repos.d/
RUN yum -y install rundeckpro-cluster


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

