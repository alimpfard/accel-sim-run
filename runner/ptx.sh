#!/bin/bash
#bust

if [ ! -n "$CUDA_INSTALL_PATH" ]; then
	echo "ERROR ** Install CUDA Toolkit and set CUDA_INSTALL_PATH.";
	exit;
fi

export NVIDIA_COMPUTE_SDK_LOCATION=$(realpath 4.2)

#Make the simulator
export PATH=$CUDA_INSTALL_PATH/bin:$PATH;
source ./gpu-simulator/setup_environment.sh
#make -C ./gpu-simulator

mkdir /results

source gpu-app-collection/src/setup_environment
make -j -C gpu-app-collection/src \
    rodinia-3.1 \
    polybench \
    parboil \
    lonestargpu-2.0

util/job_launching/run_simulations.py -B rodinia-3.1,polybench,parboil,lonestargpu-2.0 -C "RTX2060_S-${INSN_COUNT:-100M_INSN}${EXTRA_CONFIGS:-}" -N rodinia_2.0-ft-ptx -n

p=$(($(nproc) - 4))
echo "Running with $p processes!"
sleep 1
j=0
i=0
total=0

for lin in sim_run_11.0/*; do
    case "$lin" in
        # Not a useful dir.
        *gpgpu-sim-builds*) continue
            ;;
        # Streamcluster SIGSEGVs
        # BFS seems to never finish?
        *streamcluster*|*bfs*|*lonestar-dmr*) continue
            ;;
        *)
            ;;
    esac
    total=$((total + 1))
done

echo -ne '\x1b[2J'

scroll() {
    echo -ne '\x1b[r'
}

limitscroll() {
    echo -ne '\x1b[1;20r'
}

state() {
    if [ "$1" -lt 3 ]; then
        echo "$2"
    fi
    echo -ne '\x1b[s'
    scroll
    echo -ne '\x1b['$(expr 20 + $1)H
    shift
    echo -ne '\x1b[2K'
    echo "$*"
    limitscroll
    echo -ne '\x1b[u'
}

limitscroll
trap scroll EXIT

declare -A ass

for lin in sim_run_11.0/*; do
    case "$lin" in
        # Not a useful dir.
        *gpgpu-sim-builds*) continue
            ;;
        # Streamcluster SIGSEGVs
        # BFS seems to never finish?
        *streamcluster*|*bfs*|*lonestar-dmr*) continue
            ;;
        *)
            ;;
    esac
    name=$(basename "$lin" | sed -e 's/-.*//')
    i=$((i + 1))

    (
        for dir in "$lin"/*/*; do
            start=$(date +%s)
            pushd "$dir" || continue
            mkdir with
            bash slurm.sim > with/output 2>&1
            cat with/output >> /results/$(basename "$lin")-with-output || true
            cat gpgpusim_*power*.log >> /results/$(basename "$lin")-power-report || true
            popd
            end=$(date +%s)
            state 1 "[done @ $((end - start)) sec] $(basename "$lin")" >&3
        done
    ) 3>&1 >/dev/null 2>&1 &
    ass["$!"]="$name"
    j=$((j + 1))

    if [[ "$j" -ge "$p" ]]; then
        wait -n
        running=$(jobs -p)
        j="$(echo "$running" | wc -l)"
        state 2 "$(printf "%- 3d/%- 3d (running: %- 3d)" $i $total $j)"
        cs=""
        for a in $running; do
            cs="${cs} ${ass["$a"]}";
        done
        state 3 "running$cs"
    fi
done

echo "Waiting for $(jobs -p | wc -l) jobs to finish"
cs=""
for a in $(jobs -p); do
    cs="${cs} ${ass["$a"]}";
done
state 3 "running$cs"

wait

# for line in sim_run_11.0/*; do
#     cd $line/*/*;
#     mkdir without
#     bash slurm.sim 2>&1 > with/output
# done
# util/job_launching/monitor_func_test.py -I -v -s rodinia-stats-per-app-ptx.csv -N rodinia_2.0-ft-ptx-$$
