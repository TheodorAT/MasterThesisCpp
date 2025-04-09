# This is a collection of notes to self: 
To recompile basic example of running pdlp with input as mps file:
 - make build SOURCE=examples/cpp/pdlp_solve.cc

##  The timing of different implementations: 

10000 KKT Passes on set-cover (heron 05) 
- PDLP: 682.9 (6984 Iterations)
- 

10000 KKT Passes on netlarge6

# Previously large differences:
lp_benchmark/netlarge6 <-- The largest instance 



# 1000 KKT Passes on set-cover
PDLP:  950 Iters in 178.4 secs
PLDP+STSN: 960 Iters in 178.6 secs

# On "heron02"
PDLP:  950 Iters in 75.6 secs
PDLP+STSN: 950 Iters in ~80 secs


# 100 000 KKT Passes on stat96v1
PDLP: 99999 Iters in 462.7 secs



## Tuning 

Tuning is done on the Netlib benchmark

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

# Tuning Nesterov for higher accuracy: 
- scaling=0.3_threshold=0.9_sim_scaling=false

## The worst performers for steering vectors:
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