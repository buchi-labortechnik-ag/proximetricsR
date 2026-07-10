# The recipe is correctly printed

    Code
      recipe_print
    Output
      [1] "Spectral preprocessing recipe (device: \"unspecified\"): "
      [2] " - Step 1: prep_smooth"                                   
      [3] "    w: 5; p: 3; algorithm: 'savitzky-golay'"              
      [4] " - Step 2: prep_resample"                                 
      [5] "    min_wav: 1; max_wav: 1000; resolution: 2"             
      [6] " - Step 3: prep_derivative"                               
      [7] "    m: 1; w: 5; p: 3; algorithm: 'savitzky-golay'"        
      [8] " - Step 4: prep_snv"                                      

