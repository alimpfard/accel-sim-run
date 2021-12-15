#!/bin/sh

res=$1
if [ -z $1 ] {
    res=res
}

for x in $(glob "$res/*") {
    a=${split '-' $(basename $x)}
    echo -n $a[0] ""
    awk '/Started with/{gsub(/.*Started with /,"");a=$1}/Ended up/{gsub(/.*Ended up with /,"");b=$1}END{print a, b}' $x
}
