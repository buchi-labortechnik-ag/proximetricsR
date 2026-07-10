# Sequential kfold sampling is as expected

    Code
      seq_sample$hold_in
    Output
              Fold_1 Fold_2 Fold_3 Fold_4 Fold_5
      index_1      2      1      1      1      1
      index_2      3      3      2      2      2
      index_3      4      4      4      3      3
      index_4      5      5      5      5      4
      index_5      7      6      6      6      6
      index_6      8      8      7      7      7
      index_7      9      9      9      8      8
      index_8     10     10     10     10      9

# Leftover indices are correctly assigned to a sequential fold

    Code
      seq_sample$hold_in
    Output
              Fold_1 Fold_2 Fold_3 Fold_4
      index_1      2      1      1      1
      index_2      3      3      2      2
      index_3      4      4      4      3
      index_4      6      5      5      5
      index_5      7      7      6      6
      index_6      8      8      8      7
      index_7     NA      9      9      9

# Grouped sequential kfold sampling computes the correct indices

    Code
      seq_group_sample
    Output
      $hold_in
              Fold_1 Fold_2
      index_1      2      1
      index_2      4      3
      index_3      7      5
      index_4      9      6
      index_5     12      8
      index_6     14     10
      index_7     NA     11
      index_8     NA     13
      index_9     NA     15
      
      $hold_out
              Fold_1 Fold_2
      index_1      1      2
      index_2      3      4
      index_3      5      7
      index_4      6      9
      index_5      8     12
      index_6     10     14
      index_7     11     NA
      index_8     13     NA
      index_9     15     NA
      

# Random kfold sampling is as expected

    Code
      rand_sample
    Output
      $hold_in
               Fold_1 Fold_2 Fold_3 Fold_4 Fold_5
      index_1       1      2      1      1      1
      index_2       2      3      4      2      2
      index_3       3      4      5      3      3
      index_4       4      5      6      5      4
      index_5       5      6      7      7      6
      index_6       6      7      8      8      7
      index_7       9      8      9     10      8
      index_8      10      9     10     11      9
      index_9      11     10     11     12     11
      index_10     12     12     13     13     12
      index_11     14     13     14     14     13
      index_12     15     14     15     15     15
      
      $hold_out
              Fold_1 Fold_2 Fold_3 Fold_4 Fold_5
      index_1      7      1      2      4      5
      index_2      8     11      3      6     10
      index_3     13     15     12      9     14
      

# Leftover indices are correctly assigned to a random fold

    Code
      rand_sample
    Output
      $hold_in
               Fold_1 Fold_2 Fold_3 Fold_4 Fold_5 Fold_6
      index_1       2      1      1      1      1      1
      index_2       3      2      2      2      3      2
      index_3       5      3      3      3      4      4
      index_4       6      4      4      4      5      6
      index_5       7      5      5      5      6      7
      index_6       8      6      6      8      7      8
      index_7       9      7      7      9      8      9
      index_8      10     10      8     10      9     10
      index_9      11     11      9     11     10     11
      index_10     12     13     11     12     12     12
      index_11     13     14     12     13     13     13
      index_12     14     15     15     14     14     14
      index_13     NA     NA     NA     15     15     15
      
      $hold_out
              Fold_1 Fold_2 Fold_3 Fold_4 Fold_5 Fold_6
      index_1      1      8     10      6      2      3
      index_2      4      9     13      7     11      5
      index_3     15     12     14     NA     NA     NA
      

# Grouped random kfold sampling computes the correct indices

    Code
      rand_group_sample
    Output
      $hold_in
              Fold_1 Fold_2
      index_1      1      2
      index_2      4      3
      index_3      6      5
      index_4      9      7
      index_5     11      8
      index_6     14     10
      index_7     NA     12
      index_8     NA     13
      index_9     NA     15
      
      $hold_out
              Fold_1 Fold_2
      index_1      2      1
      index_2      3      4
      index_3      5      6
      index_4      7      9
      index_5      8     11
      index_6     10     14
      index_7     12     NA
      index_8     13     NA
      index_9     15     NA
      

