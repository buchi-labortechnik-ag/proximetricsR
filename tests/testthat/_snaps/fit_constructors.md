# Modified pls fitting type is displayed correctly

    Code
      print(mpls_m)
    Output
      Fitting method: fit_plsr
        ncomp: 15 
        type : modified 

# Standard pls fitting method is displayed correctly

    Code
      print(pls_m)
    Output
      Fitting method: fit_plsr
        ncomp: 10 
        type : standard 

# NIRWise PLUS pls fitting method is displayed correctly

    Code
      print(nwppls_m)
    Output
      Fitting method: fit_plsr
        ncomp: 5 
        type : nwp 

# Modified xls fitting method is displayed correctly

    Code
      print(mxls_m)
    Output
      Fitting method: fit_xlsr
        ncomp: 15 
        type : modified 
        min_w: 5 
        max_w: 10 

# Standard xls fitting method is displayed correctly

    Code
      print(xls_m)
    Output
      Fitting method: fit_xlsr
        ncomp: 10 
        type : standard 
        min_w: 3 
        max_w: 15 

# NIRWise PLUS xls fitting method is displayed correctly

    Code
      print(nwpxls_m)
    Output
      Fitting method: fit_xlsr
        ncomp: 5 
        type : nwp 
        min_w: 3 
        max_w: 15 

# Unrecognized methods are printed correctly

    Code
      print(no_pls)
    Output
      Fitting method: fit_plsr
        ncomp: 5 
        type : no_pls 

