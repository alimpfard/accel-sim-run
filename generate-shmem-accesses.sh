generate(name) {
    filename=$(basename $name)-loads
    rm -f $filename
    for x in $(glob "$name/*with-output") {
        a=$(basename $x)
        echo -n $a "" >> $filename
        awk '$1~/gpgpu_n_load_insn/{a+=$3}END{print a}' $x >> $filename
    }
}

for $* {
    generate $it
}
