ARG BUILD_FROM=ubuntu:18.04
FROM ${BUILD_FROM}

# Avoid getting asked questions during installation (tzdata)
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    autoconf \
    automake \
    autotools-dev \
    bison \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    debhelper \
    flex \
    g++ \
    gcc \
    git \
    jq \
    libffi-dev \
    libkrb5-3 \
    libkrb5-dev \
    libncurses5-dev \
    libsasl2-2 \
    libsasl2-dev \
    libsasl2-modules-gssapi-mit \
    libssl-dev \
    libtool \
    make \
    software-properties-common \
    unixodbc \
    unixodbc-dev \
    unzip \
    vim \
    wget \
    zip \
    zlib1g-dev

# The following is not necessary for Kerberos authentication but makes testing
# https://github.com/kafka4beam/sasl_auth easier
RUN apt-get install -y \
    krb5-kdc \
    krb5-admin-server \
    expect

ADD get-git.sh get-cmake.sh /

WORKDIR /

# We need git >= 2.18 otherwise actions/checkout@v3 in github
# workflows will use REST API to download source code archive without
# .git directory instead of normal git clone. And if release is
# configured to take it's version from git tag, rebar3 will not be
# able to resolve the version correctly and will fallback to 0.0.0,
# like it happened with emqtt-bench.
# The error from actions/checkout@v3 is as follows:
# > The repository will be downloaded using the GitHub REST API
# > To create a local Git repository instead, add Git 2.18 or higher to the PATH
RUN apt-get install -y libcurl4-openssl-dev \
    && /get-git.sh \
    && git --version

RUN wget https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tgz \
    && tar xvf Python-3.7.4.tgz \
    && cd Python-3.7.4 \
    && echo "_socket socketmodule.c" >> Modules/Setup.dist \
    && echo "_ssl _ssl.c -DUSE_SSL -I/usr/local/ssl/include -I/usr/local/ssl/include/openssl -L/usr/local/ssl/lib -lssl -lcrypto" >> Modules/Setup.dist \
    && ./configure --prefix=/usr/local/python3.7.4 \
    && make \
    && make install \
    && rm -rf /usr/bin/python3 /usr/bin/python \
    && ln -s /usr/local/python3.7.4/bin/python3.7 /usr/bin/python3 \
    && ln -s /usr/local/python3.7.4/bin/python3.7 /usr/bin/python

RUN sed -i 's/python3/python2.7/1' /usr/bin/lsb_release \
    && curl -k -L -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py \
    && python /tmp/get-pip.py \
    && python3 /tmp/get-pip.py

ENV PATH=/usr/local/python3.7.4/bin:$PATH

RUN /get-cmake.sh build

# cleanup
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm /get-git.sh /get-cmake.sh

# Elixir complains if runs without UTF-8
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

CMD [ "/bin/bash" ]
