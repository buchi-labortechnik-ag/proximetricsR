# Stratified sampling without replacements for validation is correct

    Code
      strat_sample
    Output
      $hold_in
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           1          1          1          1          1
      index_2           2          2          4          2          2
      index_3           3          3          5          4          3
      index_4           4          4          6          5          4
      index_5           5          5          7          6          5
      index_6           6          6          9          9          8
      index_7           8          7         10         10          9
      index_8           9         10         11         11         10
      index_9          11         11         12         12         13
      index_10         12         13         13         13         14
      index_11         13         15         14         14         15
      index_12         14         16         15         15         16
      index_13         17         17         16         16         17
      index_14         18         18         17         18         18
      index_15         19         19         19         19         19
      index_16         20         20         20         20         20
      
      $hold_out
              Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1          7          8          2          3          6
      index_2         10          9          3          7          7
      index_3         15         12          8          8         11
      index_4         16         14         18         17         12
      

# Stratified sampling without replacements for calibration is correct

    Code
      strat_sample
    Output
      $hold_in
              Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1          5          5          7          2          1
      index_2         11          7          8          5          5
      index_3         12          9         10         16          7
      index_4         13         10         14         17         11
      index_5         17         12         17         20         15
      index_6         20         16         22         22         19
      index_7         21         19         23         23         20
      index_8         25         21         26         24         23
      index_9         26         27         29         26         27
      
      $hold_out
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           1          1          1          1          2
      index_2           2          2          2          3          3
      index_3           3          3          3          4          4
      index_4           4          4          4          6          6
      index_5           6          6          5          7          8
      index_6           7          8          6          8          9
      index_7           8         11          9          9         10
      index_8           9         13         11         10         12
      index_9          10         14         12         11         13
      index_10         14         15         13         12         14
      index_11         15         17         15         13         16
      index_12         16         18         16         14         17
      index_13         18         20         18         15         18
      index_14         19         22         19         18         21
      index_15         22         23         20         19         22
      index_16         23         24         21         21         24
      index_17         24         25         24         25         25
      index_18         27         26         25         27         26
      index_19         28         28         27         28         28
      index_20         29         29         28         29         29
      index_21         30         30         30         30         30
      

# Stratified sampling with replacements for validation is correct

    Code
      strat_sample
    Output
      $hold_in
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           1          1          1          1          1
      index_2           2          1          3          2          3
      index_3           3          2          3          4          4
      index_4           5          3          4          4          4
      index_5           6          4          5          5          5
      index_6           6          5          6          6          7
      index_7           7          7          7          7          7
      index_8           8          8          8          7          8
      index_9          10          9          9          8          8
      index_10         11         10          9          8          9
      index_11         11         10         10          9          9
      index_12         13         11         12          9         10
      index_13         13         12         12         12         11
      index_14         14         12         13         13         12
      index_15         14         13         14         14         13
      index_16         15         14         16         15         14
      index_17         16         15         17         16         15
      index_18         17         17         18         17         16
      index_19         19         17         18         18         19
      index_20         20         20         19         20         20
      
      $hold_out
              Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1          4          6          2          3          2
      index_2          9         16         11         10          6
      index_3         12         18         15         11         17
      index_4         18         19         20         19         18
      

# Stratified sampling with replacements for calibration is correct

    Code
      strat_sample
    Output
      $hold_in
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           3          6          1          2          2
      index_2           3          6          1          2          2
      index_3           3          6          1          2          2
      index_4           3          6          1          3          2
      index_5           3          6          1          3          3
      index_6           3          6          1          3          3
      index_7           9          8          1          3          3
      index_8           9          8          6          7          3
      index_9           9          8          6          7          9
      index_10         11          9          6          7          9
      index_11         11          9          6          7         10
      index_12         11         12          8         10         10
      index_13         13         12          8         10         10
      index_14         13         12         12         10         12
      index_15         13         12         12         14         12
      index_16         17         13         14         14         12
      index_17         17         13         18         14         12
      index_18         17         13         18         19         12
      index_19         20         13         18         19         14
      index_20         20         14         18         19         14
      
      $hold_out
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           1          1          2          1          1
      index_2           2          2          3          4          4
      index_3           4          3          4          5          5
      index_4           5          4          5          6          6
      index_5           6          5          7          8          7
      index_6           7          7          9          9          8
      index_7           8         10         10         11         11
      index_8          10         11         11         12         13
      index_9          12         15         13         13         15
      index_10         14         16         15         15         16
      index_11         15         17         16         16         17
      index_12         16         18         17         17         18
      index_13         18         19         19         18         19
      index_14         19         20         20         20         20
      

# Stratified group sampling without replacement for validation is correct

    Code
      strat_sample
    Output
      $hold_in
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           2          1          1          1          1
      index_2           6          2          2          3          2
      index_3           7          3          3          4          3
      index_4           9          4          4          5          4
      index_5          11          5          5          6          5
      index_6          13          6          8          7          6
      index_7          15          7          9          8          7
      index_8          16          8         10          9          8
      index_9          17         10         11         10         10
      index_10         18         12         12         11         12
      index_11         20         13         13         12         13
      index_12         22         14         14         14         14
      index_13         23         16         15         15         16
      index_14         24         17         16         19         17
      index_15         25         18         17         20         18
      index_16         26         19         18         21         19
      index_17         28         21         19         25         21
      index_18         11         22         20         27         22
      index_19         20         23         21          3         23
      index_20         24         24         22          6         24
      index_21         15         26         23         25         26
      index_22         20         27         24          6         27
      index_23         26         28         25         27         28
      index_24         15         21         26         19         22
      index_25         13         26         27          9         13
      index_26          9          7         28          7         27
      
      $hold_out
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           1          9          6          2          9
      index_2           3         11          7         13         11
      index_3           4         15          6         16         15
      index_4           5         20          7         17         20
      index_5           8         25          6         18         25
      index_6          10         20          7         22          9
      index_7          12         20          7         23         25
      index_8          14         15          6         24         15
      index_9          19         25          6         26         15
      index_10         21          9          7         28         11
      index_11         27         11          7         26          9
      

# Stratified group sampling without replacement for calibration is correct

    Code
      strat_sample
    Output
      $hold_in
              Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1          7          7          4          3          4
      index_2          8          8          5          9          5
      index_3          7          7         12         11         12
      
      $hold_out
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           1          1          1          1          1
      index_2           2          2          2          2          2
      index_3           3          3          3          4          3
      index_4           4          4          6          5          6
      index_5           5          5          7          6          7
      index_6           6          6          8          7          8
      index_7           9          9          9          8          9
      index_8          10         10         10         10         10
      index_9          11         11         11         12         11
      index_10         12         12          6          5          1
      

# Stratified group sampling with replacement for validation is correct

    Code
      strat_sample
    Output
      $hold_in
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           3          3          2          2          2
      index_2           5          5          2          1          1
      index_3          11         11          3          4          4
      index_4           3          3          5          6          6
      index_5           5          5         11          7          7
      index_6          11         11          2          8          8
      index_7           1          1          2          9          9
      index_8           4          4          2         10         10
      index_9           6          6          2         12         12
      index_10          7          7          2          1          1
      index_11          8          8          5          4          4
      index_12          9          9          3          6          6
      index_13         10         10         11          7          7
      index_14         12         12          5          8          8
      index_15          5          5         11          9          9
      index_16          7          7          2         10         10
      index_17         10          5          2         12         12
      
      $hold_out
              Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1          2          2          1          3          3
      index_2          2          2          4          5          5
      index_3          2          1          6         11         11
      index_4          2          1          7          3          3
      index_5          2          1          8         11         11
      index_6          1          2          9          3          3
      index_7          1          1         10          3         11
      index_8          2          2         12          5         11
      

# Stratified group sampling with replacement for calibration is correct

    Code
      strat_sample
    Output
      $hold_in
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           8          1          1          8          1
      index_2           8          4          4          8          4
      index_3           8         18         18          8         18
      index_4           8          1          1          8          1
      index_5           5          4          4          5          4
      index_6          11         18         18         11         18
      index_7          14          1          1         14          1
      index_8           8          4          4         14          4
      index_9           8         18         18          5         18
      index_10          8          5          1         11          5
      index_11         14         11          4          5         11
      index_12          8         14         18          8         14
      index_13          8          5          3         11          5
      index_14         11         11          7         14         11
      index_15          5         14          9          8         14
      index_16          8         11         12         11          1
      index_17          8         18         15          5          4
      index_18         11          4         17          8         14
      
      $hold_out
               Resample_1 Resample_2 Resample_3 Resample_4 Resample_5
      index_1           1          2          2          1          2
      index_2           2          3          5          2          3
      index_3           3          6          6          3          6
      index_4           4          7          8          4          7
      index_5           6          8         10          6          8
      index_6           7          9         11          7          9
      index_7           9         10         13          9         10
      index_8          10         12         14         10         12
      index_9          12         13         16         12         13
      index_10         13         15          8         13         15
      index_11         15         16          6         15         16
      index_12         16         17         10         16         17
      index_13         17         12          5         17          9
      index_14         18          2         10         18         16
      

