generate(name) {
    for x in $(glob "results-$name/*with-output") {
        a=${split '-' $(basename $x)}
        echo -n $a[0] "" >> $name-shmem
        awk '$1~/gpgpu_n_shmem_insn/{a+=$3}END{print a}' $x >> $name-shmem
    }
}

generate reg2mem
generate vanilla
