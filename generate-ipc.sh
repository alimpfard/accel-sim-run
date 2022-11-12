generate(name) {
    for x in $(glob "results-$name/*with-output") {
        a=${split '-' $(basename $x)}
        echo -n $a[0] "" >> $name-total-ipc
        awk '$1~/gpu_sim_cycle/{b+=$3} $1~/gpu_sim_insn/{a+=$3} END{print a/b}' $x >> $name-total-ipc
    }
}

generate reg2mem
generate vanilla
