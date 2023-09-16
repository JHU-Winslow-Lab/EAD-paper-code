Simulation code and tutorial for [Jin et al. 2023 Estimating the Probability of EAD and Predicting Arrhythmic Risk of LQTS1 Mutations. Biophys. J.](https://www.cell.com/biophysj/fulltext/S0006-3495(23)00557-X)


# Part 1. Estimating the probability of early-afterdepolarization (P(EAD))
The aim is to develop a simple logistic regression model (LRM) to directly map the a set of model parameters to the P(EAD). The myocyte model used is Modified Walker model. The model parameters are 5 I<sub>Ks</sub>-related parameters:
1. scaling factor of activation time constant τ<sub>+</sub>_sf 
2. scaling factor of deactivation time constant τ<sub>-</sub>_sf 
3. shift of half maximal activation voltage ∆V<sub>1/2</sub> 
4. scaling factor of voltage-dependent activation curve slope k_sf
5. scaling factor of maximal conductance G<sub>Ks</sub>_sf

The selection of parameters is designed for predicting the LQTS1 mutations in Part 2.

The range of parameters is defined in the following table (Table S3) in which covers all LQTS1 mutations described in part 2 (Table S1)

Parameters    | Lower bound   | Upper bound
:-------------: | :-------------: | :-------------:
τ<sub>+</sub>_sf  | 0.2903  | 2.8510
τ<sub>-</sub>_sf   | 0.2051  | 1.6577
∆V<sub>1/2</sub> (mV)    | -11.9267  | 36.4100
k_sf   | 0.0000  | 10.8687
G<sub>Ks</sub>_sf   | 0.0000  | 1.9044


To build a LRM predicting P(EAD), we applied our previously published [statistical learning pipeline for the delayed afterdepolarization induced ectopic beat](https://doi.org/10.1371/journal.pcbi.1009536). First, we performed the two-round sampling strategy. In the first round, we randomly uniformly sampled 100 parameter sets in the given range. For each parameter set, we estimate the probabilty of EAD with 100 realizations. In the second round, we randomly sampled 100 parameter sets in the transition domain, which defined coarsely by fitted logistic regression with first-round 100 samples (0.01 < P(EAD) <0.99). We also then independently randomly uniformly generated 100 samples in the given range for the test sample size to evaluate the LRM performance. 

Specifically,
1. [F0_generate_samples.m](./Sampling%20files/F0_generate_samples.m) uniformly generate [100 samples](./Sampling%20files/Samples_general_train.mat) for the first round and also [100 samples](./Sampling%20files/Samples_general_test.mat) for the test set.
2. [F1_calculatePEAD.m](./Sampling%20files/F1_calculatePEAD.m) calculated the [P(EAD)](./Sampling%20files/General_train_EAD_summary.mat) of the first-round training set based on the model simulation.
3. [F2_generate_Transdata.m](./Sampling%20files/F2_generate_Transdata.m) generates the [100 samples](./Sampling%20files/Samples_trans_train.mat) in the transition domain for the 2nd round sampling.

The randomly generated parameter sets from [F0_generate_samples.m](./Sampling%20files/F0_generate_samples.m) and [F2_generate_Transdata.m](./Sampling%20files/F2_generate_Transdata.m) will be merged into [Random_sample.txt](./ModifiedWalkerModel/output/Random_samples.txt), where first 100 rows are general train samples, 101-200 rows are training samples in transition domain, 201-300 rows are test samples.

To run the myocyte model in [ModifiedWalkerModel folder](./ModifiedWalkerModel), 
1. Modify the filename of main_general_train.cc /main_trans_train.cc /main_general_test.cc to main.cc.
2. Compile and run code (in the Discovery Cluster): 
```bash
# Compile the code
module load gcc
module load openmpi
make

# Run the code
sbatch run_discovery.sh
```
Simulation data are collected into one csv file by [Gather_info.ipynb](./ModifiedWalkerModel/output/loadingData/Gather_info.ipynb), which is the input for [F1_calculatePEAD.m](./Sampling%20files/F1_calculatePEAD.m).

[F1_calculatePEAD.m](./Sampling%20files/F1_calculatePEAD.m) will be used to obtain of P(EAD) for two-round training samples and test samples.

After sampling and large-scale simulations, the results are gathered to fit to the Logistic regression model (LRM). In the fitting process, we include quadratic terms of the 5 I<sub>Ks</sub>-related parameters. [F3_Calculate_optmizeGLM.m](./LRMmodeling/F3_Calculate_optmizeGLM.m) enumerates all possible combinations of quadratic terms and choose the optimal combination based on the Consistent Akaike information criterion (CAIC).

The LRM performance evaluation is performed and plotted in [Fig1.m](./LRMmodeling/Fig1.m) (Figs 1C-F is shown)



# Part 2. Predicting the clinical arrhythmic risk of LQTS1 mutations

![Figure 3](./Prediction%20results/fig3.png)