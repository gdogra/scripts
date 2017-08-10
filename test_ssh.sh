#!/bin/bash -x

for h in lv-dnp-db102 lv-dnp-db103 lv-enp-db72 lv-enp-db73 lvn-qnp-db82 lvn-qnp-db83 lv-snp-devdbtools20 lv-snp-devdbtools21 lv-lnp-db60 lv-lnp-db61 lv-lnp-db62 lv-lnp-db63 lv-hnp-db50 lv-hnp-db51 lvn-dba-db110 lvn-dba-db111 lvn-dba-db112 lvn-ggd-db97 lvn-ggd-db98 lvn-dnp-db107 lvn-dnp-db108
do
        ssh -l goldengate $h whoami 2>/dev/null
done
