#!/bin/bash

set -e  # Exit on error
KEY_SIZE=64
CIRCUIT_NAME=s1494
HOP=2
LOCK_DIR=data/${CIRCUIT_NAME}_MUX_K${KEY_SIZE}
LOCKED_BENCH=locked_MUX_2_K_${KEY_SIZE}_${CIRCUIT_NAME}.bench

echo "[Step 1] Locking the circuit using MUX_random_lock.pl"
cd ./prepare_datasets/perl_scripts/
perl MUX_random_lock.pl -k $KEY_SIZE -i ../${CIRCUIT_NAME}/ > ${CIRCUIT_NAME}_MUX_K${KEY_SIZE}_log.txt

cd ../../

echo "[Step 2] Training UNTANGLE model"
python Main.py \
  --file-name ${CIRCUIT_NAME}_MUX_K${KEY_SIZE} \
  --train-name links_train.txt \
  --test-name links_test.txt \
  --testneg-name link_test_n.txt \
  --hop $HOP \
  --save-model > Log_train_${CIRCUIT_NAME}_MUX_K${KEY_SIZE}.txt

echo "[Step 3] Getting predictions (positive links)"
python Main.py \
  --file-name ${CIRCUIT_NAME}_MUX_K${KEY_SIZE} \
  --train-name links_train.txt \
  --test-name links_test.txt \
  --hop $HOP \
  --only-predict > Log_pos_predict_${CIRCUIT_NAME}_MUX_K${KEY_SIZE}.txt

echo "[Step 4] Getting predictions (negative links)"
python Main.py \
  --file-name ${CIRCUIT_NAME}_MUX_K${KEY_SIZE} \
  --train-name links_train.txt \
  --test-name link_test_n.txt \
  --hop $HOP \
  --only-predict > Log_neg_predict_${CIRCUIT_NAME}_MUX_K${KEY_SIZE}.txt

echo "[Step 5] Breaking the MUX Locking using break_MUX.pl"
perl break_MUX.pl ${CIRCUIT_NAME}_MUX_K${KEY_SIZE}

echo "[✅ Done] Full attack pipeline complete. Locked circuit: $LOCKED_BENCH"