
FROM teego/steem-base:0.2

MAINTAINER Aleksandr Zykov <tiger@mano.email>

ENV DEBIAN_FRONTEND="noninteractive"

RUN echo "Boost library" &&\
    ( \
        apt-get install -qy --no-install-recommends \
        libboost-all-dev \
    ) && \
    apt-get clean -qy

RUN mkdir -p /root/src && \
    ( \
        git clone https://github.com/TigerND/steem.git steem &&\
        cd steem ;\
        ( \
            git checkout replay-blockchain-and-exit &&\
            git submodule update --init --recursive &&\
            cmake \
                -DENABLE_CONTENT_PATCHING=OFF \
                -DLOW_MEMORY_NODE=OFF \
                CMakeLists.txt &&\
            make install \
        ) \
    ) &&\
    ( \
        cd /root/src ;\
        rm -Rf steem \
    )

RUN mkdir -p /witness_node_data_dir

ADD config.ini /witness_node_data_dir

RUN /usr/local/bin/steemd --replay-blockchain-and-exit

VOLUME ["/witness_node_data_dir"]

CMD ["/bin/bash"]
