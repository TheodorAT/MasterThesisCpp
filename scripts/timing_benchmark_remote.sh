# Select the type of benchmark that we want to run: 
# Select between "lp_benchmark", "mip_relaxations", "netlib_benchmark"
benchmark="netlib_benchmark"
accuracy="1.0e-4"
kkt_matrix_pass_limit=100000
verbosity=2

# Select between: "NO_STEERING_VECTORS", "NO_STEERING_VECTORS_CALC_SIMILARITY", 
# "NO_STEERING_VECTORS_USE_INPUT_METHOD", "NO_STEERING_VECTORS_CALC_SUM", 
# "NO_STEERING_VECTORS_CALC_SIMILARITY_SHARDED", "NESTEROV_MOMENTUM"
steering_vector_option="NO_STEERING_VECTORS_CALC_SIMILARITY_SHARDED"    

similarity_scaling="true"
momentum_scaling=0.3
similarity_threshold=0.8

# Select between: "STEERING_VECTOR_NO_RESTARTS", "STEERING_VECTOR_EVERY_MAJOR_ITERATION", 
# "STEERING_VECTOR_EVERY_PDLP_RESTART"
steering_vector_restart_option="STEERING_VECTOR_EVERY_MAJOR_ITERATION"    

# Default parameters
major_iteration_frequency=40
restart_policy="ADAPTIVE_HEURISTIC"         # Select between: "NO_RESTARTS", "ADAPTIVE_HEURISTIC" 
step_size_rule="ADAPTIVE_LINESEARCH_RULE"   # Select between: "CONSTANT_STEP_SIZE_RULE", "ADAPTIVE_LINESEARCH_RULE"
use_feasibility_polishing="true"

# Suitable experiment name:  
if [ $steering_vector_option == "NO_STEERING_VECTORS" ]; then
  base_experiment_name="PDLP"
elif [ $steering_vector_option == "NO_STEERING_VECTORS_CALC_SIMILARITY" ]; then 
  base_experiment_name="PDLP+calc_sim"
elif [ $steering_vector_option == "NO_STEERING_VECTORS_CALC_SIMILARITY_SHARDED" ]; then 
  base_experiment_name="PDLP+calc_sim_sharded"
elif [ $steering_vector_option == "NO_STEERING_VECTORS_USE_INPUT_METHOD" ]; then 
  base_experiment_name="PDLP+use_input_method"
elif [ $steering_vector_option == "NO_STEERING_VECTORS_CALC_SUM" ]; then 
  base_experiment_name="PDLP+calc_dual_sum"
elif [ $steering_vector_option == "NESTEROV_MOMENTUM" ]; then 
  base_experiment_name="PDLP+STSN"
else 
  echo "Please select an appropriate experiment name"
  exit
fi
solve_folder_name="${benchmark}_${accuracy}_${base_experiment_name}_timing"

# No settings after this point:
# The params passed to the solver:
params="
    verbosity_level: ${verbosity}, 
    handle_some_primal_gradients_on_finite_bounds_as_residuals: false,
    presolve_options {
        use_glop: false
    },
    termination_check_frequency: ${major_iteration_frequency},
    major_iteration_frequency: ${major_iteration_frequency},
    termination_criteria {
        kkt_matrix_pass_limit: ${kkt_matrix_pass_limit},
        simple_optimality_criteria {
            eps_optimal_absolute: ${accuracy},
            eps_optimal_relative: ${accuracy},
        },
    },
    l_inf_ruiz_iterations: 10,
    linesearch_rule: ${step_size_rule},
    restart_strategy: ${restart_policy}
    use_feasibility_polishing: ${use_feasibility_polishing},
    steering_vector_option: ${steering_vector_option},
    steering_vector_restart_option: ${steering_vector_restart_option},
    similarity_threshold: ${similarity_threshold},
    similarity_scaling: ${similarity_scaling}, 
    momentum_scaling: ${momentum_scaling},
"

# Extract all relevant instances:
# Getting the path to where the instances are stored:
if [[ $benchmark == fast_* ]]; then
  benchmark_location=${benchmark:5:${#benchmark}}
  instance_path_base="${HOME}/${benchmark_location}"
else
  instance_path_base="${HOME}/${benchmark}"
fi

instance_list_path="${HOME}/MasterThesisCpp/scripts/${benchmark}_instance_list"

declare -a instances=() 
while IFS= read -r line; do
  if [[ $line != \#* ]]; then # Ignore commented lines starting with #.
    instances+=("${line//[$'\t\r\n ']}") # Here we remove the newlines and blank characters from the variable
  fi
done < "${instance_list_path}"

base_solve_log_dir="${HOME}/MasterThesisCpp/benchmarking_results/solve_logs/$solve_folder_name"

if [[ ! -e $base_solve_log_dir ]]; then
  mkdir -p $base_solve_log_dir
fi
cd "$HOME/MasterThesisCpp"

for INSTANCE in "${instances[@]}" 
do
  instance_path_zipped="${instance_path_base}/${INSTANCE}.mps.gz"
  solve_log_file="${base_solve_log_dir}/${INSTANCE}.json"
  if [ ! -f $instance_path_zipped ]; then
    echo "Did not find file at $instance_path_zipped"
  else   
    echo "Unzipping $instance_path_zipped"...
    echo "N" | gunzip -k $instance_path_zipped
    
    instance_path="${instance_path_base}/${INSTANCE}.mps"
    echo "Solving ${INSTANCE}..."
    ./temp_cpp/pdlp_solve/build/bin/pdlp_solve --input $instance_path --params "${params}" --solve_log_file "${solve_log_file}"
    echo "Solved, deleting unzipped file to save storage... "
    rm $instance_path
  fi 
done

echo "All runs complete, creating summary file..."

cd "$HOME/MasterThesisCpp/scripts"
summary_file="${HOME}/MasterThesisCpp/benchmarking_results/csv_results/${solve_folder_name}.csv"
python3 parse_log_files.py $base_solve_log_dir $summary_file

echo "Done"
