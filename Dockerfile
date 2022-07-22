ARG BUILD_FROM=ubuntu:20.04
FROM ${BUILD_FROM}

ARG OTP_VERSION
COPY get-otp.sh /get-otp.sh
RUN /get-otp.sh ${OTP_VERSION}

RUN mkdir /tools

# Only for emqx-builder/4.4
ENV BUILD_WITHOUT_QUIC=1
ARG EMQTT_BENCH_REF
ENV EMQTT_BENCH_REF=${EMQTT_BENCH_REF:-0.4.5}

RUN git clone --depth=1 --branch=${EMQTT_BENCH_REF} https://github.com/emqx/emqtt-bench.git /tools/emqtt-bench \
    && make -C /tools/emqtt-bench

ENV PATH="/tools/emqtt-bench:$PATH"

ARG LUX_REF
ENV LUX_REF=${LUX_REF:-lux-2.6}

RUN git clone --depth=1 --branch=${LUX_REF} https://github.com/hawk/lux /tools/lux \
    && cd /tools/lux \
    && autoconf \
    && ./configure \
    && make \
    && make install \
    && cd /tools \
    && rm -rf lux

WORKDIR /
CMD [ "/bin/bash" ]
