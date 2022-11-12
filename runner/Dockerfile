FROM anothertest/accel-sim-framework

#COPY used-registers.xsv           /accel-sim-framework/used-registers.xsv
#COPY regfile-vs-shmem-access.xsv  /accel-sim-framework/regfile-vs-shmem-access.xsv
#COPY ptx.sh                       /accel-sim-framework/ptx.sh

#RUN echo -e 'export REG2MEM=1\n#export REG2MEM_MAX_OP_COUNT=1' > env
COPY ptx.sh ptx.sh

ARG reg2mem=false
ARG insn_count=100M
ARG extra_config=

RUN bash -c "if $reg2mem; then echo 'export REG2MEM=1' >> .env; fi"
RUN echo "export INSN_COUNT=${insn_count}_INSN" >> .env
RUN echo "export EXTRA_CONFIGS=$extra_config" >> .env

RUN bash -c 'source ./.env && source ./ptx.sh'

# FROM alpine
# COPY --from=0 /results /results
# WORKDIR /results
# RUN sh -c 'for f in *; do mv $f $(echo $f | sed -e "s/-.*//g"); done'
# RUN sh -c 'paste -d\; * > all.csv'
# RUN sh -c 'ls * | sed -e "/\\W/d" | xargs echo | sed -e "s/ /,/g" > header.csv'
# RUN cat header.csv all.csv > result.csv
# COPY --from=0 /traces /results/traces
