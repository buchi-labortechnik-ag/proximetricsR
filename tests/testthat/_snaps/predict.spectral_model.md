# Predictions with formula from a data.frame are correct

    Code
      predictions_df_form$predictions
    Output
            ncomp_1     ncomp_2     ncomp_3     ncomp_4      ncomp_5      ncomp_6
      46 0.30674032 0.320636544 0.333660354 0.331273561 0.3634687767 0.3364168607
      54 0.23590773 0.294600782 0.289079432 0.307923549 0.3189520418 0.2863374436
      67 0.21963147 0.238837611 0.241393613 0.253460720 0.2637369937 0.2761933268
      71 0.12162060 0.111804446 0.128429306 0.056808077 0.0515597347 0.0247356051
      73 0.15393442 0.080740218 0.078241031 0.012452985 0.0057112824 0.0069032748

# Model information of predictions with formula from a data.frame is correct

    Code
      predictions_df_form$model_information$model_grid
    Output
        ncomp           rsq       rmse largest_residual
      1     1 0.00538444397 0.23880883        1.0896055
      2     2 0.00111608609 0.24756153        1.1178821
      3     3 0.00695744878 0.24854622        1.0930028
      4     4 0.00508401634 0.25199983        1.0932020
      5     5 0.00226522313 0.25154415        1.0728407
      6     6 0.00027641142 0.26078089        1.0852900

# Predictions for dataframes from a formula are correctly printed

    Code
      print(predictions_df_form)
    Output
      Predicted response: THC 
      Spectral preprocessing recipe (device: "unspecified"): 
       - Step 1: prep_resample
          min_wav: 1100; max_wav: 1600; resolution: 5
       - Step 2: prep_derivative
          m: 1; w: 5; p: 11; algorithm: 'nwp'
       - Step 3: prep_snv
       - Step 4: prep_smooth
          w: 3; algorithm: 'moving-average'
      Number of predictions: 5 
      Considered pls factors: 1, 2, 3, 4, 5, 6 
      Proposed number of pls factors by the model:  10 
      Units of the predicted response:  % 
      _______________________________________________________ 
      
       Predictions obtained from the model with 'newdata' 
      
         ncomp_1 ncomp_2 ncomp_3 ncomp_4 ncomp_5 ncomp_6
      46   0.307  0.3206  0.3337  0.3313 0.36347  0.3364
      54   0.236  0.2946  0.2891  0.3079 0.31895  0.2863
      67   0.220  0.2388  0.2414  0.2535 0.26374  0.2762
      71   0.122  0.1118  0.1284  0.0568 0.05156  0.0247
      73   0.154  0.0807  0.0782  0.0125 0.00571  0.0069
      _______________________________________________________ 

# Predictions with matrices from a matrix are correct

    Code
      predictions_mat_mat$predictions
    Output
            ncomp_4      ncomp_5      ncomp_6     ncomp_7     ncomp_8    ncomp_9
      1 0.331273561 0.3634687767 0.3364168607 0.444516433 0.428319964 0.43800532
      2 0.307923549 0.3189520418 0.2863374436 0.214666114 0.179239192 0.13620860
      3 0.253460720 0.2637369937 0.2761933268 0.303615214 0.296301182 0.28890156
      4 0.056808077 0.0515597347 0.0247356051 0.088918495 0.076994889 0.11173230
      5 0.012452985 0.0057112824 0.0069032748 0.058709537 0.059256168 0.10013744
          ncomp_10
      1 0.40031979
      2 0.21029308
      3 0.31424760
      4 0.10084960
      5 0.11502699

# Model information of predictions with matrices from a matrix is correct

    Code
      predictions_mat_mat$model_information$model_grid
    Output
         ncomp           rsq       rmse largest_residual
      4      4 0.00508401634 0.25199983        1.0932020
      5      5 0.00226522313 0.25154415        1.0728407
      6      6 0.00027641142 0.26078089        1.0852900
      7      7 0.01320488098 0.29068948        1.1786691
      8      8 0.03013242118 0.30963986        1.2389772
      9      9 0.02727642180 0.33867561        1.2063062
      10    10 0.04107142279 0.33881800        1.2398988

# Predictions of a dataframe from a matrix are correctly printed

    Code
      print(predictions_df_mat)
    Output
      Predicted response: THC 
      Spectral preprocessing recipe (device: "unspecified"): 
       - Step 1: prep_resample
          min_wav: 1100; max_wav: 1600; resolution: 5
       - Step 2: prep_derivative
          m: 1; w: 5; p: 11; algorithm: 'nwp'
       - Step 3: prep_snv
       - Step 4: prep_smooth
          w: 3; algorithm: 'moving-average'
      Number of predictions: 5 
      Final number of pls factors: 4 
      Proposed number of pls factors by the model:  10 
      _______________________________________________________ 
      
       Predictions obtained from the model with 'newdata' 
      
         ncomp_4
      46  0.3313
      54  0.3079
      67  0.2535
      71  0.0568
      73  0.0125
      _______________________________________________________ 

