# python3 ./run_tests.py -w <work_dir>  \
# {--slurm -q <job_queue>} or  {-n <num_process> --ntasks-per-node <n>}

python3 ./run_tests.py -w ./ -n 20 --ntasks-per-node 1