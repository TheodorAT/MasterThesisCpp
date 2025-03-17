# Select the type of benchmark that we want to run: 
# Select between "lp_benchmark", "mip_relaxations", "netlib_benchmark"
benchmark="lp_benchmark"

accuracy="1.0e-4"
iteration_limit=10000
major_iteration_frequency=40
verbosity=2

steering_vector_option="NO_STEERING_VECTORS"        # Select between: "NO_STEERING_VECTORS", "RESIDUAL_MOMENTUM"
steering_vector_restart_option="STEERING_VECTOR_NO_RESTARTS"    # Select between: "STEERING_VECTOR_NO_RESTARTS",  
                                                                # "STEERING_VECTOR_EVERY_MAJOR_ITERATION", "STEERING_VECTOR_EVERY_PDLP_RESTART"

restart_policy="ADAPTIVE_HEURISTIC"                        # Select between: "NO_RESTARTS", "ADAPTIVE_HEURISTIC" 
step_size_rule="ADAPTIVE_LINESEARCH_RULE"            # Select between: "CONSTANT_STEP_SIZE_RULE", "ADAPTIVE_LINESEARCH_RULE"
use_feasibility_polishing="true"

# Suitable experiment name:  
if [ $steering_vector_option == "NO_STEERING_VECTORS" ]; then
    base_experiment_name="PDLP_polishing=${use_feasibility_polishing}"
else 
    base_experiment_name="PDLP+Steering_R=${steering_vector_restart_option}"
fi
solve_folder_name="fast_${benchmark}_${accuracy}_${base_experiment_name}"

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
        iteration_limit: ${iteration_limit},
        eps_primal_infeasible: ${accuracy},
        eps_dual_infeasible: ${accuracy},
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
    steering_vector_restart_option: ${steering_vector_restart_option}
"

# Extract all relevant instances:
instance_path_base="${HOME}/${benchmark}"
instance_list_path="${HOME}/MasterThesisCpp/benchmarking_scripts/${benchmark}_instance_list"

declare -a instances=() 
while IFS= read -r line; do
  if [[ $line != \#* ]]; then # Ignore commented lines starting with #.
    instances+=("${line//[$'\t\r\n ']}") # Here we remove the newlines and blank characters from the variable
  fi
done < "${instance_list_path}"

base_solve_log_dir="${HOME}/MasterThesisCpp/benchmarking_results/solve_logs/$solve_folder_name"

if [[ ! -e $base_solve_log_dir ]]; then
  mkdir $base_solve_log_dir
fi
cd "$HOME/MasterThesisCpp"

for INSTANCE in "${instances[@]}" 
do
  instance_path="${instance_path_base}/${INSTANCE}.mps"
  solve_log_file="${base_solve_log_dir}/${INSTANCE}.json"
  echo "Solving ${INSTANCE}..."
  if [ ! -f $instance_path ]; then
    echo "Did not find file at $instance_path"
  else 
    ./temp_cpp/pdlp_solve/build/bin/pdlp_solve --input $instance_path --params "${params}" --solve_log_file "${solve_log_file}"
  fi 
done

echo "All runs complete, creating summary file..."

cd "$HOME/MasterThesisCpp/benchmarking_scripts"
summary_file="${HOME}/MasterThesisCpp/benchmarking_results/csv_results/${solve_folder_name}.csv"
python3 parse_log_files.py $base_solve_log_dir $summary_file

echo "Done"
