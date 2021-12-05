#!/bin/bash

if [ ! -n "$CUDA_INSTALL_PATH" ]; then
	echo "ERROR ** Install CUDA Toolkit and set CUDA_INSTALL_PATH.";
	exit;
fi

#Make the simulator
export PATH=$CUDA_INSTALL_PATH/bin:$PATH;
source ./gpu-simulator/setup_environment.sh
#make -C ./gpu-simulator

mkdir /results

source gpu-app-collection/src/setup_environment
make rodinia_2.0-ft -j -C gpu-app-collection/src

util/job_launching/run_simulations.py -B rodinia_2.0-ft -C RTX2060 -N rodinia_2.0-ft-ptx -n
for lin in sim_run_11.0/*; do
    case "$lin" in
        # Streamcluster SIGSEGVs
        # BFS seems to never finish?
        *streamcluster*|*bfs*) continue
            ;;
        *)
            ;;
    esac
    name=$(basename "$lin" | sed -e 's/-.*//')

    # count=$(grep $name used-registers.xsv | awk 'END{printf "%d",($2*65536/$3)}')
    # vcount=$(grep $name used-registers.xsv | awk 'END{printf "%d",($2*65536/$3)}')

    # count=$(grep $name regfile-vs-shmem-access.xsv | awk 'END{printf "%d",int(int((1+$4)*16)/4)*4+4}')

    count=$(grep $name used-registers.xsv | awk 'END{printf "%d",($3*20/$2)}')

    pushd $lin/*/* || continue

    # sed -i -e "s/-gpgpu_shader_registers.*/-gpgpu_shader_registers $count/" gpgpusim.config
    # sed -i -e "s/-gpgpu_registers_per_block.*/-gpgpu_registers_per_block $vcount/" gpgpusim.config

    # sed -i -e "s/-gpgpu_num_reg_banks.*/-gpgpu_num_reg_banks $count/" gpgpusim.config

    sed -i -e "s/-gpgpu_smem_latency.*/-gpgpu_smem_latency $count/" gpgpusim.config

    mkdir with
    bash slurm.sim 2>&1 | tee with/output
    cp with/output /results/$(basename "$lin")-with-output
    cp gpgpusim_*power*.log /results/$(basename "$lin")-power-report
    popd
done

# for line in sim_run_11.0/*; do
#     cd $line/*/*;
#     mkdir without
#     bash slurm.sim 2>&1 > with/output
# done
# util/job_launching/monitor_func_test.py -I -v -s rodinia-stats-per-app-ptx.csv -N rodinia_2.0-ft-ptx-$$
