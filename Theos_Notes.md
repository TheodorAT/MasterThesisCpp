# This is a collection of notes to self: 
To recompile basic example of running pdlp with input as mps file:
 - make build SOURCE=examples/cpp/pdlp_solve.cc

(Tuning is done on the Netlib benchmark for Polyak & Nesterov)
# Results of Polyak Tuning: 
Best performance: 
- scaling=0.3_threshold=0.995_sim_scaling=false (Most Solves = 102, KKT SGM10 = 5756)
- scaling=0.3_threshold=0.990_sim_scaling=true (Lowest KKT SGM10 = 5645, Solves = 101)

# Results of Nesterov Tuning:  
Best performance: 
- scaling=0.4_threshold=0.80_sim_scaling=true (Lowest KKT SGM10 = 5182, Solves = 102)
- scaling=0.3_threshold=0.80_sim_scaling=true (Most Solves = 103, KKT SGM10 = 5391)
- scaling=0.3_threshold=0.9_sim_scaling=false (Lowest KKT SGM10 = 5320, Solves =  102)
TODO: Tune around with scaling=0.4, try different thresholds and with/without similarity scaling.

# The worst performers for steering vectors:
LP benchmark: 
- buildingenergy
- neos
Mip Relaxations:
- triptim7
- triptim8
- piperout-d20
- map16715-04
- map10
- buildingenergy
Netlib:
- scorpion
- gfrd-pnc
- lotfi
- bnl2
# The best performers with steering vectors
LP benchmark: 
- rail02
Mip Relaxations:
- mzzv42z
- supportcase7
- rail02
- neos-4533806-waima
- ger50-17-trans-pop-3t
Netlib:
- forplan
- maros