# Start with Ubuntu 18.04
FROM ubuntu:18.04

# Add ARG variables to be used only in the build
ARG BUILD_INFO=/build-info.txt

# ARMGCC is ADDed from a web url, the file is decompressed + extracted based on a wildcard matching pattern, and the name of the resulting directory must be added to the path
ARG ARMGCC_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2
ARG ARMGCC_DWNLD_MATCH=gcc-arm-none-eabi*.tar.bz2
ARG ARMGCC_VERSION=gcc-arm-none-eabi-10-2020-q4-major
ARG ARMGCC_PATH="/bin/${ARMGCC_VERSION}/bin"

# Create a build log
RUN touch ${BUILD_INFO} && \
  echo "Build created on: " >> ${BUILD_INFO} && \
  date >> ${BUILD_INFO} && \
  echo "" >> ${BUILD_INFO}

# Install necessary apt packages
RUN echo "Installing Packages" && \
  apt-get update -y && \
  apt-get install -y --no-install-recommends \
  build-essential \
  jq \
  git \
  mercurial \
  zip \
  wget \
  curl \
  unzip \
  # python-pip \
  # python-dev \
  # python-setuptools \
  python3-pip \
  python3-dev \
  python3-setuptools \
  && rm -rf /var/lib/apt/lists/* && \
  echo "" >> ${BUILD_INFO}

RUN echo "Installed packages: " >> ${BUILD_INFO} && \
  make --version | head -n 1 >> ${BUILD_INFO} && \
  git --version >> ${BUILD_INFO} && \
  which wget >> ${BUILD_INFO} && \
  curl --version | head -n 1 >> ${BUILD_INFO} && \
  which zip >> ${BUILD_INFO} && \
  which unzip >> ${BUILD_INFO} && \
  # python --version >> ${BUILD_INFO} && \
  # pip --version >> ${BUILD_INFO} && \
  python3 --version >> ${BUILD_INFO} && \
  pip3 --version >> ${BUILD_INFO} && \
  echo "" >> ${BUILD_INFO}

# Install ARM Embedded Toolchain
ADD ${ARMGCC_URL} /tmp/
RUN echo "Installing ARM Cross Compiler" && \
  tar -xvjf /tmp/${ARMGCC_DWNLD_MATCH} -C /bin/ && \
  rm -rf /tmp/* && \
  echo ""

ENV PATH="${ARMGCC_PATH}:${PATH}"

# Install mbed-cli
RUN echo "Installing mbed-cli" && \
  pip3 install mbed-cli && \
  echo "mbed-cli $(mbed --version)" >> ${BUILD_INFO}

ENV MBED_GCC_ARM_PATH="${ARMGCC_PATH}"


# Set up entry point for github action
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
