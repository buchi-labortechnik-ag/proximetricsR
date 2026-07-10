# Leave-one-out CV is correct without groups

    Code
      loo_sample$hold_in
    Output
              [,1] [,2] [,3] [,4] [,5]
      index_1    2    1    1    1    1
      index_2    3    3    2    2    2
      index_3    4    4    4    3    3
      index_4    5    5    5    5    4

# Leave-one-out CV is correct with groups

    Code
      loo_sample
    Output
      $hold_in
              [,1] [,2] [,3]
      index_1    2    1    1
      index_2    3    3    2
      index_3    4    4    5
      index_4    6    5    7
      index_5    9    6    8
      index_6   11    7    9
      index_7   12    8   10
      index_8   NA   10   11
      index_9   NA   12   NA
      
      $hold_out
              [,1] [,2] [,3]
      index_1    1    2    3
      index_2    5    9    4
      index_3    7   11    6
      index_4    8   NA   12
      index_5   10   NA   NA
      

