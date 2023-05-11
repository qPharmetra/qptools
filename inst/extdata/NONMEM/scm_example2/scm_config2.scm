model=example2scm.mod
directory=scm_example2

search_direction=both

p_forward=0.01
p_backward=0.001

continuous_covariates=AGE
categorical_covariates=GNDR

[test_relations]
CL=AGE,GNDR
V1=AGE,GNDR
V2=AGE,GNDR
Q=AGE,GNDR

[valid_states]
continuous = 1,5
categorical = 1,2


