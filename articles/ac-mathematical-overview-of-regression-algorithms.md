# Mathematical overview of regression algorithms

## 1 Introduction

This package implements three main regression approaches: i) the
classical partial least squares regression (PLSR) algorithm ([Wold
1975](#ref-wold1975path)), ii) the modified PLSR algorithm used in
near-infrared spectroscopy ([Shenk and Westerhaus 1991](#ref-shenk1991);
[Westerhaus 2014](#ref-westerhaus2014eastern)), and iii) a proprietary
PLSR extension called XLS. The package also provides an NIRWise
PLUS-compatible implementation, referred to as `nwp`, which follows the
modified PLSR structure but applies an additional slope correction to
the weights and scores.

## 2 Correlation vs. covariance

Before jumping into the description of the regression algorithms used in
this R library, we first take a quick look at the definition and
calculation of both the sample covariance and correlation. Note that
throughout this document, we indicate an overwritten variable value by
an arrow to the left, to emphasize that a new value has been assigned.

Assume we are given a spectral data matrix $`X = [x_1, \dots, x_M]`$,
where each $`x_m = [x_{m1}, \dots, x_{mN}]^T`$ is a column vector of
length $`N`$. Additionally, we have a matrix of targets
$`Y = [y_1,\dots,y_N]^T`$, which indicates the reference values of one
single property. While it is possible to adjust the PLS algorithms to
allow regressing on several properties at once, it is often the case
that individual models for each property performs better.

Note that it is crucial for the PLS algorithm that both spectra and
targets are centered by their means, meaning that the mean of each
column vector is equal to zero:

``` math
\mu_{x_m} := \frac{1}{N} \sum_{j=1}^{N} x_{jm} = 0
```

for every $`m=1,\dots,M.`$ If a column vector of either the spectra or
the targets are non-centered, we may simply center them as follows:

``` math
\begin{split}
x_m &\leftarrow x_m - \mu_{x_m},\
Y &\leftarrow Y - \mu_Y.
\end{split}
```

Hereafter, we assume that both target vector $`Y`$ and spectral matrix
$`X`$ are mean-centered without loss of generality. This allows us to
simplify the calculations of the involved statistical terminology, as we
shall explore in the rest of this section.

The sample covariance of the centered matrices $`X`$ and $`Y`$ can be
calculated as follows:

``` math
\begin{split}
  \operatorname{cov}(X,Y) &= (\operatorname{cov}(x_m), Y)_{m=1}^M\\
  &= (\frac{1}{N-1} \sum_{j=1}^N ((x_{jm}-\mu_{x_m})(y_j-\mu_Y)))_{m=1}^M\\
  &= (\frac{1}{N-1} \sum_{j=1}^N x_{jm}y_j)_{m=1}^M\\
  &= (\frac{1}{N-1} x_m^T Y)_{m=1}^M\\
  &= \frac{1}{N-1} X^T Y.
\end{split}
```

On the other hand, if we consider $`Y`$ as a vector, and split the
matrix $`X`$ into column vectors $`x_m`$, we may calculate the sample
Pearson correlation coefficient of $`x_m`$ and $`Y`$ as follows:

``` math
\begin{split}
\operatorname{cor}(x_m,Y) &:= \frac{cov(x_m,Y)}{\sigma_{x_m} \sigma_Y} \\
&= \frac{x_m^TY}{\sqrt{(\sum_{j=1}^{N} x_{jm}^2)(\sum_{j=1}^{N} y_j^2)}}.
\end{split}
```

where the sample standard deviation is defined as follows:

``` math
\begin{split}
  \sigma_{x_m} &:= \sqrt{\frac{1}{N-1}\sum_{j=1}^N (x_{jm}-\mu_{x_m})^2}\\
  &= \sqrt{\frac{1}{N-1}\sum_{j=1}^N x_{jm}^2},
\end{split}
```

Similarly, the Pearson correlation matrix of the full spectral matrix
$`X`$ and the targets $`Y`$ is defined as:

``` math
\begin{split}
\operatorname{Cor}(X,Y) = [\operatorname{cor}(x_m, Y)]_{m=1}^M,
\end{split}
```

such that $`\operatorname{Cor}(X,Y) \in \mathbb{R}^{M \times 1}`$.

Note that this does not imply that there is a linear relationship
between the sample correlation and covariance, as each column vector
$`x_m`$ has a different standard deviation $`\sigma_{x_m}`$ in general.

## 3 Partial Least Squares Regression algorithms

The goal of this section is to provide insight into how the PLSR
algorithms are implemented in the package. The different variants share
the same broad score-loading-deflation structure, but they differ in the
way the weight vector is computed and, in the case of the NIRWise
PLUS-compatible implementation, in the additional slope correction
applied to weights and scores.

A common PLSR-type implementation may be summarized as follows:

- First, we calculate weights. In standard PLSR, these weights are based
  on covariances between the observations and targets. In modified PLSR,
  they are based on Pearson correlations. These weights indicate how
  much each individual wavelength contributes to the component being
  extracted.

- Then, we project the observed spectra onto the space of weights to
  obtain the scores. In other words, we compress the spectral data
  information into a lower-dimensional space, where each wavelength has
  influence on the outcome according to the weights.

- Afterwards, the loadings are computed by regressing the columns of the
  observations on the scores. In particular, regression is done on the
  scores of the spectra, and not on spectral matrix itself. As such, the
  scores are the central aspect of the algorithm.

- Lastly, the scores and loadings are used to deflate the observations.
  More precisely, we remove the aspects of the spectrum which we already
  have explained via the information of the scores.

The procedure is repeated for a pre-determined number of factors using
the deflated spectra for each repetition.

This document is organized as follows. In [Standard PLSR
algorithm](#standard-plsr), we describe the classical covariance-based
PLSR algorithm following the NIPALS approach ([Wold
1975](#ref-wold1975path)). In [Modified PLSR algorithm](#modified-plsr),
we describe the modified PLSR algorithm used in near-infrared
spectroscopy ([Shenk and Westerhaus 1991](#ref-shenk1991); [Westerhaus
2014](#ref-westerhaus2014eastern)). In [NIRWise PLUS-compatible PLSR
implementation](#plssection), we describe the implementation used to
reproduce the NIRWise PLUS behaviour. In [Derived matrices and
diagnostics](#addmat), we show how additional matrices may be obtained,
which serve as useful analysis tools to check the performance of the
algorithm. In [PLS predictions](#predsection), we discuss two separate,
but mathematically related, ways of calculating predictions for new
data. Finally, in [Extended PLSR: the XLS algorithm](#xls), we describe
the proprietary XLS weighting scheme.

## 4 Standard PLSR algorithm

Classical partial least squares regression can be described using the
NIPALS approach ([Wold 1975](#ref-wold1975path)). In the standard PLS1
formulation, the weights are selected according to the covariance
between the deflated spectral matrix and the response.

Consider a given spectral matrix $`X`$ with $`N`$ observations, each
containing $`M`$ wavelengths, such that
$`X \in \mathbb{R}^{N\times M}`$:

``` math
X = [x_1, \dots, x_N]^T = [x_1, \dots, x_M] = (x_{ij})_{i=1,\dots,N}^{j=1,\dots,M}.
```

Similarly, we have corresponding targets or reference values
$`Y \in \mathbb{R}^{N \times 1}`$ for each observation. Note that we
consider only one vector of targets at a time. If there are more
reference vectors to be considered, one computes PLSR on each of them
separately. As discussed before, we assume that the observations $`X`$
and targets $`Y`$ are mean-centered.

The following calculations are repeated $`F`$ times. We denote by $`i`$
the current factor, running through $`i=1,\dots, F`$, and by $`X^{(i)}`$
the corresponding observations for factor $`i`$, starting with the
mean-centered $`X`$:

``` math
X^{(1)} = X.
```

For every factor, $`X^{(i)}`$ will be adjusted; as such, we use this
notation to emphasize which matrix is utilized.

In standard PLSR, we begin the procedure by calculating the **weights**
of the current component $`i`$ from the covariance between $`X^{(i)}`$
and $`Y`$:

``` math
w^{(i)} = \operatorname{cov}(X^{(i)},Y)
= \frac{1}{N-1}(X^{(i)})^T Y \in \mathbb{R}^{M \times 1}.
```

These weights $`w^{(i)}`$ describe how much each column of $`X^{(i)}`$
covaries with the reference values $`Y`$.

We project the observations $`X^{(i)}`$ onto a lower-dimensional space
to obtain the **scores** as follows:

``` math
t^{(i)} = X^{(i)}w^{(i)}.
```

In particular, $`t^{(i)} \in \mathbb{R}^{N \times 1}`$. The **loadings**
$`p^{(i)}\in \mathbb{R}^{M \times 1}`$ are obtained by regressing the
columns of $`X^{(i)}`$ on the scores:

``` math
p^{(i)} = \frac{(X^{(i)})^T t^{(i)}}{| t^{(i)}|^2_2}.
```

The response loading is:

``` math
q^{(i)} = \frac{Y^T t^{(i)}}{| t^{(i)} |^2_2}.
```

As a last step of the PLSR algorithm, we deflate our observations by
removing the present component from $`X^{(i)}`$ as follows:

``` math
X^{(i+1)} = X^{(i)} - t^{(i)} p^{(i)T}.
```

Now, we may repeat the algorithm for the next factor $`i+1`$ by using
$`X^{(i+1)}`$ in place of $`X^{(i)}`$ for the calculation of the PLSR
weights at the beginning of the procedure until we have reached the last
factor $`F`$.

## 5 Modified PLSR algorithm

Modified PLSR is a variant widely used in near-infrared spectroscopy
calibration. It is commonly associated with the work of Shenk and
Westerhaus ([Shenk and Westerhaus 1991](#ref-shenk1991)). Westerhaus
later described the motivation for this modification as replacing raw
covariance-based wavelength weights with a normalized association
between each wavelength and the response ([Westerhaus
2014](#ref-westerhaus2014eastern)).

In the implementation described here, this normalized association is
expressed as the Pearson correlation coefficient. The algorithm follows
the same general score-loading-deflation structure as standard PLSR, but
replaces the covariance-based weights by correlation-based weights.

For every factor $`i`$, starting with $`X^{(1)} = X`$, the **weights**
are computed as:

``` math
w^{(i)} = \operatorname{Cor}(X^{(i)},Y) \in \mathbb{R}^{M \times 1}.
```

These weights $`w^{(i)}`$ show how much each column of $`X^{(i)}`$
correlates with the reference values $`Y`$.

The observations $`X^{(i)}`$ are then projected onto the space of
weights to obtain the **scores**:

``` math
t^{(i)} = X^{(i)}w^{(i)}.
```

The **loadings** are obtained by regressing the columns of $`X^{(i)}`$
on the scores:

``` math
p^{(i)} = \frac{(X^{(i)})^T t^{(i)}}{| t^{(i)}|^2_2}.
```

The response loading is:

``` math
q^{(i)} = \frac{Y^T t^{(i)}}{| t^{(i)} |^2_2}.
```

Finally, the observations are deflated:

``` math
X^{(i+1)} = X^{(i)} - t^{(i)} p^{(i)T}.
```

Thus, the main difference between standard and modified PLSR is the
construction of the weight vector: standard PLSR uses covariance-based
weights, whereas modified PLSR uses correlation-based weights.

## 6 NIRWise PLUS-compatible PLSR implementation

The NIRWise PLUS-compatible implementation in `proximetricsR`, referred
to as `type = "nwp"`, follows the modified PLSR structure by using
correlation-based weights, but applies an additional slope correction to
the weights and scores. This section preserves the details of that
implementation.

Consider a given spectral matrix $`X`$ with $`N`$ observations, each
containing $`M`$ wavelengths, such that
$`X \in \mathbb{R}^{N\times M}`$:

``` math
X = [x_1, \dots, x_N]^T = [x_1, \dots, x_M] = (x_{ij})_{i=1,\dots,N}^{j=1,\dots,M}.
```

Similarly, we have corresponding targets or reference values
$`Y \in \mathbb{R}^{N \times 1}`$ for each observation. Note that we
consider only one vector of targets at a time. If there are more
reference vectors to be considered, one computes PLSR on each of them
separately. As discussed before, we assume that the observations $`X`$
and targets $`Y`$ are mean-centered.

The following calculations are repeated $`F`$ times ($`F`$ is
pre-determined, often chosen as $`15`$). We denote by $`i`$ the current
factor, running through $`i=1,\dots, F`$, and by $`X^{(i)}`$ the
corresponding observations for factors $`i`$, starting with the
mean-centered $`X`$:

``` math
X^{(1)} = X.
```

For every factor, $`X^{(i)}`$ will be adjusted; as such, we use this
notation to emphasize which matrix is utilized.

We begin the procedure by calculating the **weights** of the current
component $`i`$ as the Pearson correlation coefficient matrix of
$`X^{(i)}`$ and $`Y`$:

``` math
w^{(i)} = \operatorname{Cor}(X^{(i)},Y) \in \mathbb{R}^{M \times 1}.
```

These weights $`w^{(i)}`$ show by how much each column of $`X^{(i)}`$
correlates to the references values $`Y`$. In the standard PLSR
formulation, following the NIPALS approach ([Wold
1975](#ref-wold1975path)), the weights are instead selected according to
the covariance between the spectral matrix $`X^{(i)}`$ and the reference
values $`Y`$.

We project the observations $`X^{(i)}`$ onto a lower-dimensional space
to obtain the **scores** as follows:

``` math
t^{(i)} = X^{(i)}w^{(i)}.
```

In particular, $`t^{(i)} \in \mathbb{R}^{N \times 1}`$. Common PLS
algorithms now usually continue by normalization of the scores or by
calculating the loadings. However, in the NIRWise PLUS-compatible
implementation, we first compute a regression of $`Y`$ on the scores:

``` math
a^{(i)} = \frac{Y^T t^{(i)}}{| t^{(i)}|^2_2} \in \mathbb{R},
```

and then adjust both weights and scores according to this factor:

``` math
\begin{split}
w^{(i)} &\leftarrow a^{(i)} w^{(i)},\
t^{(i)} &\leftarrow a^{(i)} t^{(i)}.
\end{split}
```

The reason for this adjustment factor $`a^{(i)}`$ is that we may later
simply add all calculated scores to obtain the estimates. Additionally,
we can directly compute the **bias** of our estimation in component
$`i`$ as follows:

``` math
\operatorname{bias}^{(i)} = \mu_{Y}-\mu_{t^{(i)}},
```

which allows us to further adjust the scores to an unbiased estimation
of $`Y`$:

``` math
t^{(i)} \leftarrow t^{(i)} - \operatorname{bias}^{(i)}.
```

Note that because the scores are regressed on the centered $`Y`$, this
bias should be very close to zero. However, due to computer precision,
some small values are observable.

By regressing the columns of $`X^{(i)}`$ on the scores $`t^{(i)}`$, we
obtain the **loadings** $`p^{(i)}\in \mathbb{R}^{M \times 1}`$ as
follows:

``` math
p^{(i)} = \frac{(X^{(i)})^T t^{(i)}}{| t^{(i)}|^2_2}.
```

As a last step of the PLSR algorithm, we deflate our observations by
removing the present component from $`X^{(i)}`$ as follows:

``` math
X^{(i+1)} = X^{(i)} - t^{(i)} p^{(i)T}.
```

Now, we may repeat the algorithm for the next factor $`i+1`$ by using
$`X^{(i+1)}`$ in place of $`X^{(i)}`$ for the calculation of the PLSR
weights at the beginning of the procedure until we have reached the last
factor $`F`$.

## 7 Derived matrices and diagnostics

In this section, we provide insights on how common additional matrices
for improved analysis of the procedure are obtained. As before, we
assume that the spectra $`X`$ and the target $`Y`$ are mean-centered.
However, for some of the calculations below, we also require the actual
reference values. As such, we denote by $`Y^{(0)}`$ the raw or original
target vector.

To obtain the scaled scores, we first compute the **scale**, which is
given by the standard deviation of $`t^{(i)}`$:

``` math
\operatorname{scale}^{(i)} = \sigma_{t^{(i)}}.
```

This allows us to normalize $`t^{(i)}`$ and to obtain the **scores
scaled** of component $`i`$:

``` math
t^{(i)}** =  t^{(i)} / \sigma*{t^{(i)}}.
```

The **Mahalanobis distance** of the scaled scores may be calculated as
follows:

``` math
D^{(i)} = \sqrt{\frac{\sum_{n=1}^{i}\big(t^{(n)}_*\big)^2}{i}}.
```

In particular, we calculate the Euclidean distance of the sum of all
previous components of the scaled scores.

For the estimates in the NIRWise PLUS-compatible implementation, note
that we have already regressed $`Y`$ on the scores $`t^{(i)}`$. Hence,
they may be calculated directly by summing all obtained scores. However,
the regression was done on the centered $`Y`$. Therefore, we have to add
the mean of the original, non-centered $`Y^{(0)}`$ back to obtain the
estimates $`\hat{Y}^{(i)}`$ as follows:

``` math
\hat{Y}^{(i)} = \mu_{Y^{(0)}} + \sum_{n=1}^{i} t^{(n)}.
```

The **residuals** $`r^{(i)}`$ are defined as the difference between the
targets $`Y`$ and the estimates. Again, since estimation is done on
non-centered targets, we must use the raw reference vector:

``` math
r^{(i)} = Y^{(0)} - \hat{Y}^{(i)}.
```

We may also calculate the regression coefficients $`\beta^{(i)}`$ as
follows.

First, we calculate the projection matrix $`A`$, which projects the
observations $`X`$ onto the space of scores:

``` math
A = (W P^T)^{-1} W \in \mathbb{R}^{F \times M},
```

where $`W`$ denotes the matrix of all weights and $`P`$ the matrix of
all loadings. In particular, the following holds true:

``` math
t^{(i)} = A_iX^T,
```

where $`A_i`$ denotes the $`i`$th row of $`A`$. Using the calculation of
the estimates, we may alternatively compute the estimates as follows:

``` math
\begin{split}
\hat{Y}^{(i)} &= \mu_{Y^{(0)}} + \sum_{n=1}^{i} t^{(n)}\\
&= \mu_{Y^{(0)}} + (\sum_{n=1}^i A_n)X^{T}\\
&= \mu_{Y^{(0)}} + \beta^{(i)} X^T,
\end{split}
```

where we defined the regression coefficients

``` math
\beta^{(i)} = \sum_{n=1}^i A_n.
```

Therefore, the calculation of the regression coefficients simplifies the
computation of estimates. As we shall see, they also allow for a quick
and simple calculation for the predictions (see [PLS
predictions](#predsection)). Furthermore, they allow an interpretation
of how each column of $`X`$ contributes to the estimates and predictions
of $`Y`$.

The **residuum** $`R^{(i)} \in \mathbb{R}^{N \times 1}`$ is calculated
by summing the squares of each row of our deflated $`X^{(i+1)}`$:

``` math
R^{(i)} = \sum_{m=1}^{M} \big(x^{(i+1)}_{m} \big)^2,
```

where multiplication is meant element-wise.

Furthermore, we note that this package does not provide any
$`Y`$-loadings for the NIRWise PLUS-compatible implementation, which are
commonly supplied in PLSR procedures. However, as we shall see, they do
not provide any contribution to the analysis of this implementation.
First of all, the definition of $`Y`$-loadings is as follows:

``` math
q^{(i)} = \frac{Y^T t^{(i)}}{| t^{(i)} |^2_2}.
```

Note that this is similar to the calculation of factor $`a^{(i)}`$ in
[NIRWise PLUS-compatible PLSR implementation](#plssection). In
particular, we are regressing $`Y`$ on the scores again; but since we
have already adjusted the scores according to the regression factor
$`a^{(i)}`$, we should get a constant $`Y`$-loading of $`1`$. Indeed, if
we denote by $`\tilde{t}^{(i)}`$ the score before the regression, i.e.

``` math
\tilde{t}^{(i)} = \frac{t^{(i)}}{a^{(i)}},
```

then we obtain

``` math
\begin{split}
q^{(i)} &= \frac{Y^T t^{(i)}}{| t^{(i)} |^2_2}\\
&= \frac{Y^T a^{(i)}\tilde{t}^{(i)}}{(a^{(i)})^2| \tilde{t}^{(i)} |^2_2}\\
&= \frac{Y^T \tilde{t}^{(i)}}{a^{(i)}\tilde{t}^{(i)T} \tilde{t}^{(i)}}\\
&= \frac{a^{(i)}}{a^{(i)}}\\
&= 1.
\end{split}
```

As such, outputting the $`Y`$-loadings is not of any actual use for the
NIRWise PLUS-compatible implementation and therefore omitted.

## 8 PLS predictions

In this section, we illustrate how the matrices of the previous section
may be used to obtain predictions. We assume that the PLSR algorithm has
already been fully calculated and all matrices of the previous section
are given. We indicate newly calculated vectors and matrices by a tilde,
while the given ones use the same notation as in the previous section.
Furthermore, we note that the predictions in case of XLS (discussed in
[Extended PLSR: the XLS algorithm](#xls)) are done similarly with the
respective matrices. Hence, there is no need to discuss the prediction
for XLS separately.

We provide two different approaches for the predictions: one uses the
scores, while the other one makes use of the regression coefficients. Of
course, both approaches provide equivalent results, but the necessary
matrices differ.

### 8.1 Predictions using scores

For this approach, we must be provided with the following matrices:

- Mean of the raw spectra before centering: $`\mu_{X^{(0)}}`$.

- Mean of the raw targets before centering: $`\mu_{Y^{(0)}}`$

- Weights of every component: $`w^{(i)}`$.

- Biases of every component: $`\operatorname{bias}^{(i)}`$.

- Loadings of each component: $`p^{(i)}`$

Assume we are given $`\tilde{N}`$ new observations in form of
$`\tilde{X} \in \mathbb{R}^{\tilde{N} \times M}`$, where we assume them
to have a similar number of wavelengths as the given spectra
$`X^{(0)}`$.

We start by centering the columns of our new observations by the means
of our calibration:

``` math
\tilde{X}^{(1)} = \tilde{X} - \mu_{X^{(0)}}.
```

We calculate the predictions based on the number of factors included,
i.e. we again run through $`i=1, \dots, F`$.

As a first step, we project $`\tilde{X}^{(i)}`$ onto the space of the
calibrated scores using the given weights:

``` math
\tilde{t}^{(i)} = \tilde{X}^{(i)} w^{(i)}.
```

We then adjust the obtained scores according to the previously obtained
bias:

``` math
\tilde{t}^{(i)} \leftarrow \tilde{t}^{(i)} - \operatorname{bias}^{(i)}.
```

The prediction can now be obtained by summing all previous scores and
adding the mean of $`Y^{(0)}`$ as follows:

``` math
\tilde{\hat{Y}}^{(i)} = \mu_{Y^{(0)}} + \sum_{n=1}^{i} \tilde{t}^{(n)}.
```

We then deflate $`\tilde{X}^{(i)}`$ using the new scores and the
loadings of the calibration:

``` math
\tilde{X}^{(i+1)} = \tilde{X}^{(i)} - \tilde{t}^{(i)} p^{(i)T},
```

and restart the procedure using the deflated $`\tilde{X}^{(i+1)}`$.

### 8.2 Predictions using regression coefficients

For this approach, we must be provided with the following matrices:

- Mean of the raw spectra before centering: $`\mu_{X^{(0)}}`$.

- Mean of the raw targets before centering: $`\mu_{Y^{(0)}}`$

- Correct regression coefficients: $`\tilde{\beta}`$.

Again, we assume that $`\tilde{N}`$ new observations in form of
$`\tilde{X} \in \mathbb{R}^{\tilde{N} \times M}`$ are given. We center
the columns of our new observations by the means of our calibration:

``` math
\tilde{X} \leftarrow \tilde{X} - \mu_{X^{(0)}}.
```

The predictions now may be obtained immediately for every component
$`i`$ by computing

``` math
\tilde{\hat{Y}} = \tilde{\beta} \tilde{X}^T + \mu_{Y^{(0)}},
```

where each row of
$`\tilde{\hat{Y}} \in \mathbb{R}^{F \times \tilde{N}}`$ provides the
prediction based on the corresponding number of components.

## 9 Extended PLSR: the XLS algorithm

In this section, we discuss how the weights for the XLS algorithm are
calculated. XLS is a proprietary extension of the PLSR framework used in
BUCHI workflows. Note that the calculation of the weights is the only
difference to the PLSR algorithms described above; the rest of the
outputs can be obtained in a similar way as in the [previous
sections](#plssection), including predictions.

For ease of notation, we drop the mention of the current component; in
particular, $`X`$ corresponds to $`X^{(i)}`$ in the preceding PLSR
algorithms.

As before, we assume that the observations $`X`$ and the targets $`Y`$
are centered. To calculate the weights, we run through all columns of
$`X`$ and calculate the weights element-wise. In particular, the
following calculation is done for all $`m=1,\dots,M`$.

Let us consider some fixed $`m \in [1,M]`$. We define the following
interval

``` math
J_m^+ = [m+m_{\min}, \min(M,m+m_{\max})],
```

where the default choice is $`m_\text{min}=3, m_\text{max}=15`$. We
proceed by computing the differences of column $`m`$ of $`X`$ with each
column in interval $`J_m^+`$:

``` math
X_{mj}^d = x_m - x_j, \forall j \in J_m^+.
```

Thereafter, we may compute the Pearson correlation coefficients between
those differences and $`Y`$ as follows:

``` math
d_{mj} = \operatorname{cor}(X_{mj}^d, Y), \forall j \in J_m^+.
```

The weights vector can now be obtained as follows:

``` math
w_m = w_m + d_{mj}, \forall j \in J_m^+,
```

``` math
w_j = w_j - d_{mj}, \forall j \in J_m^+,
```

where $`w_m = 0`$ whenever it has not been defined yet. The resulting
vector $`w = [w_1, \dots, w_M]`$ replaces the computation of the PLSR
weights above for each component $`i`$.

As there is no easy interpretation to the calculation of these weights,
we transform above calculations to obtain an equivalent algorithm, which
is hopefully easier to interpret.

Note that in the first equation above, we add all Pearson correlation
coefficients of the derivatives of columns $`m`$ and all $`j \in J_m^+`$
to weight $`m`$; whereas in the second equation, we subtract the same
correlations from weights $`w_j, j \in J_m^+`$. A careful analysis on
which differences $`d`$ are subtracted from a fixed weight element $`m`$
shows that it may also be expressed in the following way:

``` math
w_m = \sum_{j\in J_m^+} d_{mj} - \sum_{j = \max(0,m-m_\text{max})}^{m-3} d_{jm}.
```

Note that the order of $`j`$ and $`m`$ in the subscript of $`d`$ for the
second sum is inverted. In particular, if we define the ‘mirrored’
interval

``` math
J_m^- = [\max (0,m-m_\text{max}), m-m_\text{min}],
```

then each individual weight may be expressed as follows:

``` math
w_m = \sum_{j\in J_m^+} d_{mj} - \sum_{j\in J_m^-} d_{jm}.
```

A graphical representation of the intervals in relation to $`m`$ is
given at the end of this section.

Note that the Pearson correlation coefficient satisfies

``` math
\operatorname{cor}(x_j - x_m,Y) = - \operatorname{cor}(x_m - x_j,Y),
```

and therefore, plugging in the definition of $`d`$, we obtain

``` math
\begin{split}
w_m &= \sum_{j\in J_m^+} d_{mj} - \sum_{j\in J_m^-} d_{jm}\\
&= \sum_{j\in J_m^+} \operatorname{cor}(x_m - x_j, Y) - \sum_{j\in J_m^-} \operatorname{cor}(x_j-x_m, Y)\\
&=\sum_{j \in J_m^+} \operatorname{cor}(x_m - x_j, Y) + \sum_{j\in J_m^-} \operatorname{cor}(x_m-x_j, Y)\\
&= \sum_{j \in J_m^+ \cup J_m^-} \operatorname{cor}(x_m - x_j, Y).
\end{split}
```

Hence, the calculation of the XLS weights may be interpreted as follows.
As illustrated in [Figure 1](#fig-imagetikz), for each position $`m`$ we
consider the neighbouring intervals $`J_m^-`$ and $`J_m^+`$, truncated
where necessary so that they remain within $`[1, M]`$. We then compute
the first derivative of the current column $`m`$ with respect to each
column in the interval $`J = J_m^+ \cup J_m^-`$. The weight at position
$`m`$ is obtained as the sum of the correlations between each derivative
and the target. This procedure is repeated for every $`m \in [1, M]`$.
Note that for some $`m`$, one of the intervals may be truncated or even
empty (for example, when $`m = 1`$, $`J_1^-`$ is empty). By convention,
the sum over an empty interval is taken to be $`0`$.

![](xls_intervals-in-relation-to-m.svg)

Figure 1: Intervals in relation to $`m`$. Each interval is truncated so
that it covers only values in $`[1, M]`$.

## References

Shenk, JS, and MO Westerhaus. 1991. “Population Definition, Sample
Selection, and Calibration Procedures for Near Infrared Reflectance
Spectroscopy.” *Crop Science* 31 (2): 469–74.

Westerhaus, Mark. 2014. “Eastern Analytical Symposium Award for
Outstanding Achievements in Near Infrared Spectroscopy: My Contributions
to Near Infrared Spectroscopy.” *NIR News* 25 (8): 16–20.

Wold, Herman. 1975. “Path Models with Latent Variables: The NIPALS
Approach.” In *Quantitative Sociology*. Elsevier.
