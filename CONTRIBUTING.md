# Contributing to proximetricsR

Thanks for your interest in contributing to **proximetricsR**.

Whether you're fixing a bug, adding a feature, improving documentation, or proposing a new method, your contribution is appreciated.

**proximetricsR** is an R package developed by **BUCHI Labortechnik AG** to provide practical tools for developing chemometrics models for its NIR sensor. Contributions help improve the reliability, usability, and applicability of these methods across spectroscopy and analytical science.

## Reporting bugs

Found something that is not working as expected? Please open an issue in the **proximetricsR GitHub repository** and include:

- A minimal reproducible example
- The output from `sessionInfo()`
- A description of what you expected to happen and what actually happened

## Suggesting features

If you have an idea for a new feature or improvement, please open an issue and describe:

- The problem you are trying to solve
- Your proposed approach
- Any alternatives you have considered

## Contributing code

### Getting started

1. Fork the repository
2. Clone your fork:

```bash
git clone https://github.com/YOUR-USERNAME/proximetricsR.git
```

3. Create a branch:

```bash
git checkout -b feature/your-feature-name
```

4. Install the required dependencies:

```r
devtools::install_deps(dependencies = TRUE)
```

### Code style

- Follow the existing coding style and package conventions
- Use `roxygen2` for documentation
- Add or update tests for new functionality using `testthat`
- Keep changes focused and clearly documented

### Before submitting

Run:

```r
devtools::test()
devtools::check()
```

Please make sure that `R CMD check` passes without errors or warnings before submitting your contribution.

### Pull request process

1. Update the documentation where required using `devtools::document()`
2. Add an appropriate entry to `NEWS.md`
3. Ensure relevant tests are included and passing
4. Submit a pull request to the main branch
5. Clearly describe the purpose and scope of the proposed changes

## Code of Conduct

Contributors are expected to interact professionally and respectfully. Please refer to the project's Code of Conduct in the GitHub repository.

## Ownership and maintenance

**proximetricsR** is developed and maintained by **BUCHI Labortechnik AG**.

For questions related to the package, please open an issue in the GitHub repository or contact the package maintainer at:

**ramirez-lopez.l@buchi.com**
