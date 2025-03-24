# Some examples of increasing difficulty: 
# - self
# - chrom1024-7
# - nug08-3rd
# - datt256
# - savsched1
# - neos3
# - karted
# - qap15 <--- This one should take about 5 seconds. Not more 
# POSSIBLE ERROR: On "savsched1" we get -nan in relative duality gap, but still solve it for some reason...
# Maybe we have made an error, or maybe this will be fixed by introducing some curve-breaking?
# Dual objective becomes: -inf very quickly, possibly due to the large dual objective coefficients?
instance="chrom1024-7"
instance_path="${HOME}/lp_benchmark/${instance}.mps" # We need to have already extracted it from mps.gz

accuracy="1.0e-4"

kkt_matrix_pass_limit=10000
major_iteration_frequency=40
verbosity=2

steering_vector_option="RESIDUAL_MOMENTUM"        # Select between: "NO_STEERING_VECTORS", "RESIDUAL_MOMENTUM"
steering_vector_restart_option="STEERING_VECTOR_EVERY_MAJOR_ITERATION"    # Select between: "STEERING_VECTOR_NO_RESTARTS",  
                                                                # "STEERING_VECTOR_EVERY_MAJOR_ITERATION", "STEERING_VECTOR_EVERY_PDLP_RESTART"
similarity_threshold="0.9"
use_feasibility_polishing="false"
restart_policy="ADAPTIVE_HEURISTIC"                        # Select between: "NO_RESTARTS", "ADAPTIVE_HEURISTIC" 
step_size_rule="ADAPTIVE_LINESEARCH_RULE"            # Select between: "CONSTANT_STEP_SIZE_RULE", "ADAPTIVE_LINESEARCH_RULE"

# Suitable experiment name:  
if [ $steering_vector_option == "NO_STEERING_VECTORS" ]; then
    experiment_name="${instance}_${accuracy}_PDLP"
else 
    experiment_name="${instance}_${accuracy}_PDLP+Steering_R=${steering_vector_restart_option}"
fi

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
    similarity_threshold: ${similarity_threshold}
"

solve_log_file="${HOME}/MasterThesisCpp/benchmarking_results/solve_logs/log_${experiment_name}.json"
# Running the algorithm:
cd "$HOME/MasterThesisCpp"
echo "Solving $instance..."
./temp_cpp/pdlp_solve/build/bin/pdlp_solve --input $instance_path --params "$params"

