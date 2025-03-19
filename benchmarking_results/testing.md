# Test settings:
For the baseline, we use the following settings in PDLP, which are kept when "adding on" the steering vectors, and their corresponding settings.

List of settings: 
- Baseline PDLP settings with feasibility polishing = on
- Termination check and major iteration freq = 40
- l_inf_ruiz_iterations = 10
- The accuracy is changed with the "simple_optimality_criteria", and set to either 1.0e-4 or 1.0e-8  

The complete string fed into run_pdlp is: 
    handle_some_primal_gradients_on_finite_bounds_as_residuals: false,
    presolve_options {
        use_glop: false
    },
    termination_check_frequency: 40,
    major_iteration_frequency: 40,
    termination_criteria {
        iteration_limit: ${iteration_limit},
        simple_optimality_criteria {
            eps_optimal_absolute: ${accuracy},
            eps_optimal_relative: ${accuracy},
        },
    },
    l_inf_ruiz_iterations: 10,
    linesearch_rule: ADAPTIVE_LINESEARCH_RULE,
    restart_strategy: ADAPTIVE_HEURISTIC
    use_feasibility_polishing: true,
