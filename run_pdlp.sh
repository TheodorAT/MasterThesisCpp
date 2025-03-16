# Some examples of increasing difficulty: 
# - self
# - chrom1024-7
# - nug08-3rd
# - datt256
# - neos3
instance="self"
instance_path="${HOME}/lp_benchmark/${instance}.mps" # We need to have already extracted it from mps.gz

# Select between "STEERING_VECTOR_UNSPECIFIED" and "RESIDUAL_MOMENTUM"
steering_vector_option="RESIDUAL_MOMENTUM" 
accuracy="1.0e-4"
use_feasibility_polishing="false"
# The params passed to the solver:
params="
    verbosity_level: 1, 
    handle_some_primal_gradients_on_finite_bounds_as_residuals: false,
    presolve_options {
        use_glop: false
    },
    termination_criteria {
        iteration_limit: 10000,
        simple_optimality_criteria {
            eps_optimal_absolute: ${accuracy},
            eps_optimal_relative: ${accuracy},
        },
        eps_primal_infeasible: ${accuracy},
        eps_dual_infeasible: ${accuracy},
    },
    num_threads: 1
    termination_check_frequency: 40,
    major_iteration_frequency: 40,
    l_inf_ruiz_iterations: 10,
    use_feasibility_polishing: ${use_feasibility_polishing},
    linesearch_rule: CONSTANT_STEP_SIZE_RULE,
    steering_vector_option: ${steering_vector_option},
"

# Running the algorithm:
./temp_cpp/pdlp_solve/build/bin/pdlp_solve --input $instance_path --params "$params"
 
# For instance: 
# - ./temp_cpp/pdlp_solve/build/bin/pdlp_solve --input $HOME/lp_benchmark/self.mps --params "verbosity_level: 2" 


# Additional option, for logging in different file, future: :
# --solve_log_file