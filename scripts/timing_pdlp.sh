# Some examples of increasing difficulty: 
# - self
# - chrom1024-7
# - nug08-3rd
# - datt256
# - savsched1
# - neos3
# - karted
# - qap15 <--- This one should take about 5 seconds. Not more 
# Very affected fast instances: (in netlib)
# forplan   (large improvement)
# bnl2      (large deterioration)
instance="netlarge6" # This one is very difficult to solve, and has large cost for KKT passes.
instance_path_base="${HOME}/lp_benchmark"
instance_path_zipped="${instance_path_base}/${instance}.mps.gz"

accuracy="1.0e-8"
save_similarity="false"
similarity_file_name="'./similarity_logs/${instance}_PDLP'"
kkt_matrix_pass_limit=2
major_iteration_frequency=40
verbosity=2

similarity_scaling="true"
similarity_threshold="0.8"
momentum_scaling="0.3"
# Select between: "NO_STEERING_VECTORS", "RESIDUAL_MOMENTUM", "POLYAK_MOMENTUM", "NESTEROV_MOMENTUM"
steering_vector_option="NESTEROV_MOMENTUM"        

steering_vector_restart_option="STEERING_VECTOR_NO_RESTARTS"    # Select between: "STEERING_VECTOR_NO_RESTARTS",  
                                                                # "STEERING_VECTOR_EVERY_MAJOR_ITERATION", "STEERING_VECTOR_EVERY_PDLP_RESTART"
use_feasibility_polishing="false"
restart_policy="NO_RESTARTS"                        # Select between: "NO_RESTARTS", "ADAPTIVE_HEURISTIC" 
step_size_rule="CONSTANT_STEP_SIZE_RULE"            # Select between: "CONSTANT_STEP_SIZE_RULE", "ADAPTIVE_LINESEARCH_RULE"

# Suitable experiment name:  
if [ $steering_vector_option == "NO_STEERING_VECTORS" ]; then
    experiment_name="${instance}_${accuracy}_PDHG"
else 
    experiment_name="${instance}_${accuracy}_PDHG_${steering_vector_option}"
fi
solve_folder_name="${experiment_name}"

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
    save_similarity: ${save_similarity},
    similarity_file_name: ${similarity_file_name},
    momentum_scaling: ${momentum_scaling},
"


base_solve_log_dir="${HOME}/MasterThesisCpp/benchmarking_results/solve_logs/$solve_folder_name"

if [[ ! -e $base_solve_log_dir ]]; then
  mkdir -p $base_solve_log_dir
fi

# Running the algorithm:
cd "$HOME/MasterThesisCpp"
if [ ! -f $instance_path_zipped ]; then
  echo "Did not find file at $instance_path_zipped"
else   
  echo "Unzipping $instance_path_zipped"...
  echo "N" | gunzip -k $instance_path_zipped
  solve_log_file="${base_solve_log_dir}/${INSTANCE}.json"
  instance_path="${instance_path_base}/${instance}.mps"
  
  if [ ! -f $instance_path ]; then
    echo "Did not find unzipped file at $instance_path"
  else 
    echo "Solving ${INSTANCE}..."
    ./temp_cpp/pdlp_solve/build/bin/pdlp_solve --input $instance_path --params "${params}" --solve_log_file "${solve_log_file}"
    echo "Solved, deleting unzipped file to save storage... "
    rm $instance_path

    # Saving the results in file:
    cd "$HOME/MasterThesisCpp/scripts"
    summary_file="${HOME}/MasterThesisCpp/benchmarking_results/csv_results/${solve_folder_name}.csv"
    python3 parse_log_files.py $base_solve_log_dir $summary_file
  fi
fi

