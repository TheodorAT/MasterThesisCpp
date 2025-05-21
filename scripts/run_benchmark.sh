# A script to run the different algorithms on a selected benchmark.

# Select the benchmark:
benchmark="netlib_benchmark" # Select between "lp_benchmark", "mip_relaxations", "netlib_benchmark"

### Select appropriate paths: 
# The path to where the instances are stored: (this requires that benchmarks are stored in the $HOME directory, otherwise change the path)
instance_path_base="${HOME}/${benchmark}"
# The path to the instance list (If MasterThesisCpp is not in the $HOME directory, change the path):
instance_list_path="${HOME}/MasterThesisCpp/scripts/${benchmark}_instance_list"

# Termination settings:
accuracy="1.0e-4"                   # The accuracy of the solver, suggested values: "1.0e-4", "1.0e-8"
kkt_matrix_pass_limit=100000
major_iteration_frequency=40

# PDLP Settings:
restart_policy="ADAPTIVE_HEURISTIC"         # Select between: "NO_RESTARTS", "ADAPTIVE_HEURISTIC" 
step_size_rule="ADAPTIVE_LINESEARCH_RULE"   # Select between: "CONSTANT_STEP_SIZE_RULE", "ADAPTIVE_LINESEARCH_RULE"
use_feasibility_polishing="true"            # Select between: "false", "true"
verbosity=2

# Acceleration scheme settings:
acceleration_scheme="NESTEROV_MOMENTUM"     # Select between: "NO_ACCELERATION", "RESIDUAL_MOMENTUM", "POLYAK_MOMENTUM", "NESTEROV_MOMENTUM"
momentum_scaling=0.3                        # The kappa in the algorithms
steering_vector_lambda=1                    # The lambda_0 in the algorithm with Steering Vectors in a Residual Momentum direction 
similarity_threshold=0.8                    # The Gamma in the algorithms, Select in range: [-1, 1]
similarity_scaling="false"                   # Select between: "false", "true"
similarity_option="COSINE_SIMILARITY"       # Select between "COSINE_SIMILARITY" and "MULTITHREADED_COSINE_SIMILARITY"
acceleration_restart_option="ACCELERATION_RESTARTS_EVERY_MAJOR_ITERATION"  # Select between: "NO_ACCELERATION_RESTARTS", 
                                                                           # "ACCELERATION_RESTARTS_EVERY_PDLP_RESTART", 
                                                                           # "ACCELERATION_RESTARTS_EVERY_MAJOR_ITERATION"

# Suitable experiment name:  
if [ $acceleration_scheme == "NO_ACCELERATION" ]; then
  base_experiment_name="PDLP_similarity_option=${similarity_option}"
elif [ $acceleration_scheme == "POLYAK_MOMENTUM" ]; then 
  base_experiment_name="PDLP+Polyak_kappa=${momentum_scaling}_threshold=${similarity_threshold}_similarity_scaling=${similarity_scaling}_similarity_option=${similarity_option}"
elif [ $acceleration_scheme == "NESTEROV_MOMENTUM" ]; then 
  base_experiment_name="PDLP+Nesterov_kappa=${momentum_scaling}_threshold=${similarity_threshold}_similarity_scaling=${similarity_scaling}_similarity_option=${similarity_option}"
elif [ $acceleration_scheme == "RESIDUAL_MOMENTUM" ]; then 
  base_experiment_name="PDLP+SVRM_kappa=${momentum_scaling}_lambda=${steering_vector_lambda}_threshold=${similarity_threshold}_similarity_scaling=${similarity_scaling}_similarity_option=${similarity_option}"
else 
  echo "Unknown acceleration scheme: $acceleration_scheme"
  exit 1
fi
solve_folder_name="${benchmark}_${accuracy}_${base_experiment_name}"

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
    acceleration_scheme: ${acceleration_scheme},
    acceleration_restart_option: ${acceleration_restart_option},
    momentum_scaling: ${momentum_scaling},
    steering_vector_lambda: ${steering_vector_lambda},
    similarity_threshold: ${similarity_threshold},
    similarity_scaling: ${similarity_scaling}, 
    similarity_option: ${similarity_option},
"

# Read the instance list:
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
  instance_path="${instance_path_base}/${INSTANCE}.mps"
  solve_log_file="${base_solve_log_dir}/${INSTANCE}.json"
  if [ ! -f $instance_path ]; then
    echo "Did not find file at $instance_path"
  elif [ -f $solve_log_file ]; then 
    echo "Found existing solve log $solve_log_file$, skipping identical solve..."
  else 
    echo "Solving ${INSTANCE}..."
    ./temp_cpp/pdlp_solve/build/bin/pdlp_solve --input $instance_path --params "${params}" --solve_log_file "${solve_log_file}"
  fi 
done

echo "All runs complete, creating summary file..."

cd "$HOME/MasterThesisCpp/scripts"
summary_file="${HOME}/MasterThesisCpp/benchmarking_results/csv_results/${solve_folder_name}.csv"
python3 parse_log_files.py $base_solve_log_dir $summary_file

echo "Done"