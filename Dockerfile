FROM python:3.13-alpine as builder

# Install system dependencies and build tools
RUN echo "Updating and installing dependencies" && \
    apk update && apk upgrade && \
    apk add --no-cache \
        bash \
        build-base \
        linux-headers \
        cmake \
        git \
        openblas-dev \
        libffi-dev \
        jpeg-dev \
        zlib-dev \
        gfortran \
        freetype-dev \
        libpng-dev \
        musl-dev \
        protobuf \
        protobuf-dev && \
        rm -rf /root/.cache && \
        rm -rf /var/cache/apk/* 

RUN python -m venv /opt/venv && \
    pip install --no-cache-dir --upgrade pip setuptools wheel numpy pyyaml typing_extensions && \
    rm -rf /root/.cache

ENV USE_FBGEMM=0 \
    USE_CUDA=0 \
    USE_CUDNN=0 \
    USE_DISTRIBUTED=0 \
    USE_TENSORPIPE=0 \
    USE_MKLDNN=0 \
    USE_KINETO=0 \
    MAX_JOBS=4

# Clone PyTorch repository
WORKDIR /tmp
RUN git clone --branch v2.5.0 --recursive https://github.com/pytorch/pytorch.git && \
    cd pytorch && \
    git submodule sync && \
    git submodule update --init --recursive && \
    sed -i 's/unsigned int line/int line/' c10/macros/Macros.h && \
    sed -i '/#include <execinfo.h>/d' c10/util/Type_demangle.cpp && \
    sed -i 's/LONG_LONG_MAX/LLONG_MAX/g' torch/csrc/profiler/unwind/unwind.cpp && \
    python setup.py install &&\
    rm -rf /tmp/pytorch && \
    rm -rf /tmp/*

WORKDIR /app
