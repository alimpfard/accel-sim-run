# Setup accel-sim
FROM accelsim/ubuntu-18.04_cuda-11

RUN apt-get install --yes gdb
RUN rm -f /bin/sh && ln /bin/bash /bin/sh
ENV CUDA_INSTALL_PATH=/usr/local/cuda-11.0

COPY accel-sim-framework /accel-sim-framework

WORKDIR /accel-sim-framework

# Build the SASS frontend
RUN bash -c "source gpu-simulator/setup_environment.sh && \
    make -j -C gpu-simulator"

RUN bash travis.sh

FROM alpine
COPY --from=0 /results /results
WORKDIR /results
RUN sh -c 'for f in *; do mv $f $(echo $f | sed -e "s/-.*//g"); done'
RUN sh -c 'paste -d\; * > all.csv'
RUN sh -c 'ls * | sed -e "/\\W/d" | xargs echo | sed -e "s/ /,/g" > header.csv'
RUN cat header.csv all.csv > result.csv
COPY --from=0 /traces /results/traces
