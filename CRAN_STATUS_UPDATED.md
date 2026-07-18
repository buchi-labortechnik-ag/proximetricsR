# CRAN Readiness — Updated Status

**Last Updated:** 2026-06-09 (reflects commits through “fix: vignettes”)

------------------------------------------------------------------------

## ✅ FIXED SINCE LAST REPORT

| Item | Before | After | Status |
|----|----|----|----|
| `jsonlite` in Imports | ❌ Missing | ✅ Added (DESCRIPTION:35) | CLOSED |
| `lifecycle` in NAMESPACE | ❌ Imported but unused | ✅ Removed | CLOSED |
| Class order in `proximate_read_data.R:156` | ❌ `c("data.frame", "proximate_data")` | ✅ `c("proximate_data", "data.frame")` | CLOSED |
| Class order in `proximate_merge.R:149` | ❌ `c("data.frame", "proximate_data")` | ✅ `c("proximate_data", "data.frame")` | CLOSED |
| NEWS content | ❌ Placeholder text | ✅ Actual release notes | CLOSED |
| Function prefix renaming | ❌ `proc_detrend`, `proc_transform`, `proc_wav_trim` | ✅ Renamed to `prep_*` (commit ee9142f) | CLOSED |

------------------------------------------------------------------------

## ❌ STILL BLOCKING SUBMISSION (ERRORS)

### Error \#1: Repository Line in DESCRIPTION

- **File:** `DESCRIPTION:47`
- **Issue:** `Repository: CRAN` must be **removed** — CRAN adds this
  automatically
- **Fix:** Delete line 47
- **Status:** ⚠️ **WILL FAIL SUBMISSION**

### Error \#2: prepro_to_string() Missing Handlers

- **File:** `proximate_write_helpers.R:181–195`
- **Issue:**
  [`prepro_to_string()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prepro_to_string.md)
  only handles 4 of 7 preprocessing methods:
  - ✅ Handles: `prep_snv`, `prep_smooth`, `prep_resample`,
    `prep_derivative`
  - ❌ Missing: `prep_detrend`, `prep_transform`, `prep_wav_trim`
- **Impact:** If a user includes these in a preprocessing recipe and
  calls
  [`proximate_write_model()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/proximate_write_model.md),
  the .prj file will have **empty preprocessing strings** for these
  steps, silently corrupting the device file.
- **Flow:** `write_prj.R:326` → `recipe_to_prj_string()` →
  [`prepro_to_string()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prepro_to_string.md)
- **Severity:** High (silent data corruption)
- **Status:** ⚠️ **WILL CAUSE USER COMPLAINTS**

------------------------------------------------------------------------

## ⚠️ CRAN WILL LIKELY REJECT (WARNINGS)

| \# | Issue | Location | Count | Fix |
|----|----|----|----|----|
| 1 | `T`/`F` → must use `TRUE`/`FALSE` | write_prj.R | 8 occurrences (215, 216, 224, 225, 252, 253, 372, 373, 383) | Use `TRUE`/`FALSE` instead of `T`/`F` |
| 2 | `\|` in scalar `if` → must use `\|\|` | calibration_control.R:269 | 1+ location | Use `||` and `&&` in scalar if conditions |
| 3 | [`setwd()`](https://rdrr.io/r/base/getwd.html) not wrapped | proximate_write_nax.R:172, 278 | 2 calls | Replace with [`withr::with_dir()`](https://withr.r-lib.org/reference/with_dir.html) (withr already in Imports) |

------------------------------------------------------------------------

## 📋 CODE QUALITY ISSUES (Won’t block but should be fixed)

| \# | Issue | Location | Details |
|----|----|----|----|
| 1 | Dead commented code | write_cal.R | ~135 comment lines (need to identify which are dead) |
| 2 | Dead commented code | write_prj.R | ~143 comment lines (need to identify which are dead) |
| 3 | O(n²) [`rbind()`](https://rdrr.io/r/base/cbind.html) loop | proximate_merge.R:103–146 | `dfinal <- NULL; dfinal <- rbind(dfinal, ith_x)` in loop; use [`list()`](https://rdrr.io/r/base/list.html) + `do.call(rbind, ...)` instead |
| 4 | Old Author/Maintainer fields | DESCRIPTION:6–13 | CRAN will request conversion to `Authors@R` format |
| 5 | Thin Description | DESCRIPTION:16 | Current: “Build quantitative Near-Infrared applications for BUCHI ProxiMate sensors.” — should be 2–3 sentences |
| 6 | Package name references | README.md | 6 occurrences of “proximater” (old name) |

------------------------------------------------------------------------

## 🔍 DETAILED BREAKDOWN BY PRIORITY

### PRIORITY 1: Fix Blocking Issues (do first)

Remove `Repository: CRAN` from DESCRIPTION line 47

Add handlers for `prep_detrend`, `prep_transform`, `prep_wav_trim` to
[`prepro_to_string()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prepro_to_string.md)
OR add validation to reject them for Proximate models with clear error
message

### PRIORITY 2: Fix CRAN Warnings (do next)

Replace `T`/`F` with `TRUE`/`FALSE` in write_prj.R (8 locations)

Replace `|` with `||` in scalar `if` conditions (check all files, not
just calibration_control.R)

Replace [`setwd()`](https://rdrr.io/r/base/getwd.html) calls with
[`withr::with_dir()`](https://withr.r-lib.org/reference/with_dir.html)
in proximate_write_nax.R

### PRIORITY 3: Code Quality & Documentation

Convert DESCRIPTION to `Authors@R` format

Expand Description field (add 1–2 more sentences)

Remove dead commented code blocks

Fix O(n²) [`rbind()`](https://rdrr.io/r/base/cbind.html) pattern in
proximate_merge.R

Update README to reference “proximetricsR” instead of “proximater”

------------------------------------------------------------------------

## Function Naming Changes Confirmed

Since last report, the following renames have been completed: -
`proc_detrend()` →
[`prep_detrend()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_detrend.md) -
`proc_transform()` →
[`prep_transform()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_transform.md) -
`proc_wav_trim()` →
[`prep_wav_trim()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prep_wav_trim.md)

These are now exported functions that users can call, but they’re **not
handled** by
[`prepro_to_string()`](https://buchi-labortechnik-ag.github.io/proximetricsR/reference/prepro_to_string.md)
when writing Proximate models (see Error \#2 above).

------------------------------------------------------------------------

## Action Items Summary

    [ ] CRITICAL: Remove Repository: CRAN from DESCRIPTION
    [ ] CRITICAL: Handle prep_detrend/transform/wav_trim in prepro_to_string()
    [ ] T/F → TRUE/FALSE in write_prj.R
    [ ] | → || in if conditions (scan all files)
    [ ] Replace setwd() with withr::with_dir()
    [ ] Update Authors@R
    [ ] Expand Description
    [ ] Clean up dead code comments
    [ ] Fix rbind() pattern in merge
    [ ] Update README references
