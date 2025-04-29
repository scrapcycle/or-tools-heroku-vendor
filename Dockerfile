FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JOBS=4

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    libgflags-dev \
    libgtest-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libc++-dev \
    libc++abi-dev \
    libclang-dev \
    libomp-dev \
    libeigen3-dev \
    libgmp-dev \
    libgmpxx4ldbl \
    libbz2-dev \
    liblzma-dev \
    libzstd-dev \
    libssl-dev \
    libgsl-dev \
    libblas-dev \
    liblapack-dev \
    libsuitesparse-dev \
    libmetis-dev \
    libglpk-dev \
    coinor-libcbc-dev \
    coinor-libcgl-dev \
    coinor-libclp-dev \
    coinor-libcoinutils-dev \
    coinor-libosi-dev \
    coinor-libipopt-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Install Abseil
RUN git clone --depth 1 https://github.com/abseil/abseil-cpp.git && \
    cd abseil-cpp && \
    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON && \
    cmake --build build --parallel ${JOBS} && \
    cmake --install build && \
    cd .. && rm -rf abseil-cpp

# Install HiGHS
RUN git clone --depth 1 https://github.com/ERGO-Code/HiGHS.git && \
    cd HiGHS && \
    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_TESTING=OFF \
        -DOPENMP=OFF \
        -DCMAKE_INSTALL_INCLUDEDIR=/usr/local/include && \
    cmake --build build --parallel ${JOBS} && \
    cmake --install build && \
    cd .. && rm -rf HiGHS

# Install SoPlex
RUN git clone --depth 1 https://github.com/scipopt/soplex.git && \
    cd soplex && \
    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_TESTING=OFF \
        -DCMAKE_CXX_FLAGS="-fPIC" && \
    cmake --build build --parallel ${JOBS} && \
    cmake --install build && \
    cd .. && rm -rf soplex

# Install SCIP
RUN git clone --depth 1 https://github.com/scipopt/scip.git && \
    cd scip && \
    cmake -S . -B build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DBUILD_TESTING=OFF \
        -DAUTOBUILD=ON \
        -DCMAKE_CXX_FLAGS="-fPIC" && \
    cmake --build build --parallel ${JOBS} && \
    cmake --install build && \
    cd .. && rm -rf scip

# Clone OR-Tools
RUN git clone --depth 1 -b v9.10 https://github.com/google/or-tools.git /opt/or-tools

# Build OR-Tools
RUN cd /opt/or-tools && \
    mkdir -p build && \
    cd build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_DEPS=ON \
        -DBUILD_PYTHON=OFF \
        -DBUILD_JAVA=OFF \
        -DBUILD_DOTNET=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_SAMPLES=OFF \
        -DBUILD_BOP=OFF \
        -DBUILD_COINOR=ON \
        -DBUILD_GUROBI=OFF \
        -DBUILD_MATHOPT=OFF \
        -DBUILD_PDLP=OFF \
        -DCMAKE_PREFIX_PATH=/usr/local \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# Set output as a volume for easy docker cp
VOLUME ["/output"]