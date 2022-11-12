# Setup accel-sim
FROM accelsim/ubuntu-18.04_cuda-11

#RUN apt-get install --yes gdb
RUN rm -f /bin/sh && ln /bin/bash /bin/sh
ENV CUDA_INSTALL_PATH=/usr/local/cuda-11.0

COPY accel-sim-framework /accel-sim-framework

WORKDIR /accel-sim-framework
ENV NVIDIA_COMPUTE_SDK_LOCATION=/accel-sim-framework/4.2
ENV PATH="${CUDA_INSTALL_PATH}/bin:${PATH}"

# Build the SASS frontend
RUN bash -c "source gpu-simulator/setup_environment.sh && \
    make -j -C gpu-simulator"

# Build the apps
RUN bash -c "source gpu-app-collection/src/setup_environment; make -C gpu-app-collection/src -j rodinia-3.1 polybench parboil lonestargpu-2.0"

# ENTRYPOINT ["bash", "ptx.sh"]
