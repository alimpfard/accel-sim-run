generate(name) {
    for x in $(glob "results-$name/*with-output") {
        a=${split '-' $(basename $x)}
        echo -n $a[0] "" >> $name-total-ipc
        awk '$1~/gpu_tot_ipc/{a+=$3; b+=1} END{print a/b}' $x >> $name-total-ipc
    }
}

generate reg2mem
generate vanilla
