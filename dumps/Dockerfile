FROM alpine
COPY --from=anothertest/accel-sim /accel-sim-framework/sim_run_11.0 /runs
RUN mkdir /dumps
RUN sh -c 'for c in /runs/*rodinia*/*/QV100/with/output; do c=$(dirname $(dirname $c)); x=$(basename $(dirname $(dirname $(realpath "$c")))); mkdir /dumps/$x; cp $c/with/* /dumps/$x; done'
RUN rm -fr /runs
