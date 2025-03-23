# Experimental setup: 
The same benchmarks as in the PDLP paper are ran, with an iteration limit of 100 000, and the with the following instances excluded since they are too large for my testing resources, where PDLP could not solve them or complete 100 000 iterations in 15 minutes (900 seconds).

From the LP benchmark:
- netlarge1
- netlarge3
- netlarge6
- square41
- tp-6

From the MIP relaxations benchmark:
- fhnw-binschedule1
- square37
- supportcase19
- tpl-tub-ss16
- tpl-tub-ws1617

# Test settings:
For the baseline, we use the following settings in PDLP, which are kept when "adding on" the steering vectors, and their corresponding settings.

List of settings: 
- Iteration limit: 100 000
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
