# derivatives without smoothing returns correct result

    Code
      round_result(process(X, prep_derivative(m = 1, w = 9, p = 1, algorithm = "nwp")))
    Output
               1313      1316      1319      1322      1325     1328     1331
      [1,] -0.00014 -0.000037  0.000129  0.000346  0.000526 0.000704 0.000917
      [2,] -0.00067 -0.000561 -0.000399 -0.000199 -0.000044 0.000130 0.000338
               1334     1337     1340     1343     1346     1349     1352     1355
      [1,] 0.001095 0.001361 0.001642 0.001828 0.001980 0.002115 0.002217 0.002365
      [2,] 0.000516 0.000767 0.001031 0.001232 0.001372 0.001503 0.001612 0.001777
               1358     1361     1364     1367     1370     1373     1376     1379
      [1,] 0.002451 0.002535 0.002635 0.002745 0.002843 0.003009 0.003210 0.003355
      [2,] 0.001865 0.001957 0.002062 0.002193 0.002311 0.002474 0.002675 0.002826
               1382     1385     1388     1391     1394     1397     1400     1403
      [1,] 0.003475 0.003577 0.003744 0.003900 0.004058 0.004133 0.004290 0.004415
      [2,] 0.002954 0.003064 0.003238 0.003413 0.003608 0.003728 0.003953 0.004146
               1406     1409     1412     1415     1418     1421     1424     1427
      [1,] 0.004517 0.004695 0.004831 0.004903 0.004934 0.004856 0.004663 0.004465
      [2,] 0.004304 0.004525 0.004705 0.004829 0.004901 0.004843 0.004646 0.004426
               1430     1433
      [1,] 0.004050 0.003633
      [2,] 0.003954 0.003488
      attr(,"preprocess_recipe")
      Spectral preprocessing recipe (device: "unspecified"): 
       - Step 1: prep_derivative
          m: 1; w: 9; p: 1; algorithm: 'nwp'
      attr(,"processed_wavs")
      Spectral variables by preprocessing step:
        step_0: 51 spectral variables
        step_1: 41 spectral variables 

---

    Code
      round_result(process(X, prep_derivative(m = 2, w = 39, p = 1, algorithm = "nwp")))
    Output
                1358      1361      1364      1367      1370      1373      1376
      [1,] -0.001434 -0.001446 -0.001451 -0.001436 -0.001397 -0.001381 -0.001326
      [2,] -0.001514 -0.001542 -0.001562 -0.001561 -0.001540 -0.001536 -0.001490
                1379      1382      1385      1388
      [1,] -0.001248 -0.001123 -0.000964 -0.000803
      [2,] -0.001419 -0.001298 -0.001141 -0.000982
      attr(,"preprocess_recipe")
      Spectral preprocessing recipe (device: "unspecified"): 
       - Step 1: prep_derivative
          m: 2; w: 39; p: 1; algorithm: 'nwp'
      attr(,"processed_wavs")
      Spectral variables by preprocessing step:
        step_0: 51 spectral variables
        step_1: 11 spectral variables 

# first derivative with smoothing works

    Code
      round_result(process(X, prep_derivative(m = 1, w = 5, p = 23, algorithm = "nwp")))
    Output
               1340     1343     1346     1349     1352     1355     1358     1361
      [1,] 0.001397 0.001552 0.001714 0.001886 0.002056 0.002223 0.002382 0.002533
      [2,] 0.000828 0.000983 0.001145 0.001317 0.001488 0.001657 0.001818 0.001970
               1364     1367     1370     1373     1376     1379     1382     1385
      [1,] 0.002676 0.002812 0.002944 0.003082 0.003223 0.003361 0.003496 0.003624
      [2,] 0.002116 0.002259 0.002404 0.002558 0.002721 0.002885 0.003048 0.003204
               1388     1391     1394     1397     1400     1403     1406
      [1,] 0.003747 0.003857 0.003951 0.004024 0.004082 0.004112 0.004113
      [2,] 0.003354 0.003490 0.003608 0.003703 0.003780 0.003827 0.003843
      attr(,"preprocess_recipe")
      Spectral preprocessing recipe (device: "unspecified"): 
       - Step 1: prep_derivative
          m: 1; w: 5; p: 23; algorithm: 'nwp'
      attr(,"processed_wavs")
      Spectral variables by preprocessing step:
        step_0: 51 spectral variables
        step_1: 23 spectral variables 

# second derivative with smoothing works

    Code
      round_result(process(X, prep_derivative(m = 1, w = 13, p = 31, algorithm = "nwp")))
    Output
               1364     1367     1370     1373     1376     1379     1382
      [1,] 0.002606 0.002748 0.002885 0.003014 0.003133 0.003240 0.003332
      [2,] 0.002102 0.002256 0.002407 0.002550 0.002685 0.002807 0.002915
      attr(,"preprocess_recipe")
      Spectral preprocessing recipe (device: "unspecified"): 
       - Step 1: prep_derivative
          m: 1; w: 13; p: 31; algorithm: 'nwp'
      attr(,"processed_wavs")
      Spectral variables by preprocessing step:
        step_0: 51 spectral variables
        step_1: 7 spectral variables 

