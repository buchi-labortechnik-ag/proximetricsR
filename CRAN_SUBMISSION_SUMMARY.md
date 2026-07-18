# CRAN Submission Readiness Summary

## Current Status

The `proximetricsR` package is **not yet CRAN-ready** but close. Recent
work has resolved 5 major issues (class ordering, imports, function
naming). However, **2 critical blocking issues** and **3 CRAN
warning-level issues** remain before submission.

------------------------------------------------------------------------

## Blocking Issues (Must Fix)

### 1. Repository Field in DESCRIPTION

**Status:** ⚠️ **MUST FIX**  
**Location:** `DESCRIPTION` line 47  
**Issue:** The line `Repository: CRAN` must be removed. CRAN adds this
field automatically during submission.  
**Fix:** Delete line 47.

### 2. Incomplete Preprocessing Method Handlers

**Status:** ⚠️ **MUST FIX**  
**Location:** `proximate_write_helpers.R:181–195`
([`prepro_to_string()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prepro_to_string.md)
function)  
**Issue:** The function handles only 4 of 7 preprocessing methods: - ✅
Supported: `prep_snv`, `prep_smooth`, `prep_resample`,
`prep_derivative` - ❌ Missing: `prep_detrend`, `prep_transform`,
`prep_wav_trim`

When users include these three methods in a preprocessing recipe and
call
[`proximate_write_model()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_model.md),
the generated .prj file will contain **empty preprocessing strings**,
silently corrupting the device configuration file.

**Fix Options:** - (A) Add handlers for all three methods to
[`prepro_to_string()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prepro_to_string.md),
or - (B) Add validation to
[`proximate_write_model()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_model.md)
that explicitly rejects these three methods with a clear error message
for Proximate models

------------------------------------------------------------------------

## CRAN Warning-Level Issues (Will Get Rejection Comments)

| Issue | Location | Count | Fix |
|----|----|----|----|
| **Use `TRUE`/`FALSE`, not `T`/`F`** | `write_prj.R` | 8 occurrences (lines 215, 216, 224, 225, 252, 253, 372, 373, 383) | Replace all instances of `= T` and `= F` with `= TRUE` and `= FALSE` |
| **Use `\|\|` in scalar `if` conditions** | `calibration_control.R:269` and elsewhere | 1+ location | Replace `if (x \| y)` with `if (x \|\| y)` — bitwise OR is only valid in vectorized contexts |
| **Wrap [`setwd()`](https://rdrr.io/r/base/getwd.html) calls** | `proximate_write_nax.R` (lines 172, 278) | 2 calls | Replace with [`withr::with_dir()`](https://withr.r-lib.org/reference/with_dir.html) (withr is already in Imports) to avoid permanently changing the working directory |

------------------------------------------------------------------------

## Code Quality Issues (Should Fix Before Release)

| Issue | Location | Details |
|----|----|----|
| **Dead commented code** | `write_cal.R`, `write_prj.R` | ~135 and ~143 comment lines respectively; identify and remove dead code blocks |
| **O(n²) loop pattern** | `proximate_merge.R:103–146` | `dfinal <- NULL; dfinal <- rbind(dfinal, ith_x)` in loop causes quadratic copying; use [`list()`](https://rdrr.io/r/base/list.html) + `do.call(rbind, ...)` instead |
| **Old author format** | `DESCRIPTION` lines 6–13 | CRAN prefers `Authors@R` over separate `Author`/`Maintainer` fields; update to modern format |
| **Thin description** | `DESCRIPTION` line 16 | Expand from single sentence to 2–3 sentences explaining package purpose and capabilities |
| **Stale package references** | `README.md` | 6 occurrences of “proximater” (old package name); update to “proximetricsR” |

------------------------------------------------------------------------

## Fixed Issues ✅

| Issue | Status |
|----|----|
| S3 class ordering in `proximate_read_data.R:156` | ✅ Fixed (correct order: `c("proximate_data", "data.frame")`) |
| S3 class ordering in `proximate_merge.R:149` | ✅ Fixed (correct order: `c("proximate_data", "data.frame")`) |
| Missing `jsonlite` in Imports | ✅ Fixed (now in DESCRIPTION:35) |
| Unused `lifecycle` import | ✅ Fixed (removed from NAMESPACE) |
| Function prefix renaming | ✅ Fixed (commit ee9142f: `proc_*` → `prep_*`) |
| NEWS placeholder content | ✅ Fixed (actual release notes now present) |

------------------------------------------------------------------------

## Recommended Action Plan

### Phase 1: Blocking Issues (1–2 hours)

1.  Remove `Repository: CRAN` line from DESCRIPTION
2.  Decide on prepro_to_string(): add handlers or add validation + error
    messages
3.  Test affected workflows

### Phase 2: CRAN Warnings (1 hour)

1.  Replace `T`/`F` with `TRUE`/`FALSE`
2.  Replace `|` with `||` in scalar conditions
3.  Replace [`setwd()`](https://rdrr.io/r/base/getwd.html) with
    [`withr::with_dir()`](https://withr.r-lib.org/reference/with_dir.html)

### Phase 3: Polish (1–2 hours)

1.  Remove dead code comments
2.  Refactor rbind loop in merge function
3.  Convert to <Authors@R> format
4.  Expand Description field
5.  Update README references

------------------------------------------------------------------------

## Submission Readiness

- **Blocking:** 2 issues (Repository line, incomplete handlers)
- **Warnings:** 3 issues (T/F, \|/\|\|, setwd)
- **Quality:** 5 issues (code cleanliness, documentation)
- **Estimated time to CRAN-ready:** 3–4 hours
- **Estimated time for submission:** After Phase 1 (blocking issues
  only)

All issues are straightforward and low-risk to fix. No architectural
changes required.
