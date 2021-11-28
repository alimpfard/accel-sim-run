FROM anothertest/accel-sim-framework

RUN echo -e 'export REG2MEM=1\n#export REG2MEM_MAX_OP_COUNT=1' > env
RUN bash -c 'source ./env && source ptx.sh'

# FROM alpine
# COPY --from=0 /results /results
# WORKDIR /results
# RUN sh -c 'for f in *; do mv $f $(echo $f | sed -e "s/-.*//g"); done'
# RUN sh -c 'paste -d\; * > all.csv'
# RUN sh -c 'ls * | sed -e "/\\W/d" | xargs echo | sed -e "s/ /,/g" > header.csv'
# RUN cat header.csv all.csv > result.csv
# COPY --from=0 /traces /results/traces
