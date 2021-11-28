# Setup accel-sim
FROM accelsim/ubuntu-18.04_cuda-11

#RUN apt-get install --yes gdb
RUN rm -f /bin/sh && ln /bin/bash /bin/sh
ENV CUDA_INSTALL_PATH=/usr/local/cuda-11.0

COPY accel-sim-framework /accel-sim-framework

WORKDIR /accel-sim-framework

# Build the SASS frontend
RUN bash -c "source gpu-simulator/setup_environment.sh && \
    make -j -C gpu-simulator"

# ENTRYPOINT ["bash", "ptx.sh"]
