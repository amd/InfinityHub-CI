#!/bin/bash


OUT_DIR=$1
if [ -z "${OUT_DIR}" ]; then
    OUT_DIR=".."
fi

OUT_FILE=${OUT_DIR}/gromacs_tmpi.txt

# Support execution from outside root dir
_CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
cd $_CWD


cd adh_dodec/
tar zxf adh_dodec.tar.gz
# 1GPU
echo "benchmark,adh_dodec,gpus_1,rank_1,thread_64" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 1 -ntomp 64 -noconfout -nb gpu -bonded gpu -pme gpu -v -gpu_id 0 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 2GPUs
echo "benchmark,adh_dodec,gpus_2,rank_4,thread_16" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 16 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 01 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 4GPUs
echo "benchmark,adh_dodec,gpus_4,rank_4,thread_16" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 16 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 0123 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 8GPUs
echo "benchmark,adh_dodec,gpus_8,rank_8,thread_4" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 4 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 01234567 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

cd ..
cd stmv/
tar zxf stmv.tar.gz

# 1GPU
echo "benchmark,stmv,gpus_1,rank_1,thread_64" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 1 -ntomp 64 -noconfout -nb gpu -bonded gpu -pme gpu -v -gpu_id 0 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 2GPUs
echo "benchmark,stmv,gpus_2,rank_4,thread_16" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 16 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 01 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 4GPUs
echo "benchmark,stmv,gpus_4,rank_8,thread_8" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 0123 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 8GPUs
echo "benchmark,stmv,gpus_8,rank_8,thread_8" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 01234567 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

cd ..
cd cellulose_nve/
tar zxf cellulose_nve.tar.gz

# 1GPU
echo "benchmark,cellulose,gpus_1,rank_1,thread_64" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 1 -ntomp 64 -noconfout -nb gpu -bonded gpu -pme gpu -v -gpu_id 0 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 2GPUs
echo "benchmark,cellulose,gpus_2,rank_4,thread_16" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 16 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 01 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 4GPUs
echo "benchmark,cellulose,gpus_4,rank_8,thread_8" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 0123 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}

# 8GPUs
echo "benchmark,cellulose,gpus_8,rank_8,thread_8" | tee -a ${OUT_FILE}
gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 8 -ntomp 8 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 01234567 -s topol.tpr 2>&1 | tee -a ${OUT_FILE}
