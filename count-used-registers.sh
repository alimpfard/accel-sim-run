#!/bin/sh

for x in res/* {
    a=${split '-' $(basename $x)}
    echo -n $a[0] ""
    awk '/Started with/{gsub(/.*Started with /,"");a=$1}/Ended up/{gsub(/.*Ended up with /,"");b=$1}END{print a, b}' $x
}
