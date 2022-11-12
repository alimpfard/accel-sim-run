generate(name) {
    for x in $(glob "results-$name-*-counts/*with-output") {
        a=${split '-' $(basename $x)}
        echo -n $a[0] "" >> $name
        awk '$1~/incregfile/{if ($3 == "+read") a+=$4; else b+=$4}END{print a,b}' $x >> $name
    }
}

generate reg2mem
generate baseline
