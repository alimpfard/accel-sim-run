setopt --verbose
rm -f vanilla vanilla-shmem
$SHELL generate-register-accesses.sh
$SHELL generate-shmem-accesses.sh
paste vanilla* | awk '{print $1,$2+$3,$5,$5/($2+$3) }' > regfile-vs-shmem-access.xsv
