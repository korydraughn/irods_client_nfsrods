FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y git python nfs-common tcpdump

RUN git clone git://git.linux-nfs.org/projects/mora/nfstest.git
WORKDIR /nfstest/test

ADD start.sh .
RUN chmod u+x ./start.sh

ENTRYPOINT ["./start.sh"]
CMD ["--help"]
