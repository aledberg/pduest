# pduest
Data and code for estimating the number of problem drug users in Sweden. This project was commissioned by the Swedish SOU Narkotikautredningen (S 2022:01)
and is an adaptation of the method described in [Jones et al. 2020, Addiction, 115: 2393-2404](https://doi.org/10.1111/add.15111). 

---
## Data sources
The data used in the project was obtained from official Swedish statistics held by Socialstyrelsen (National board of Health and Welfare). In particular, data from the *patient* and *cause of death* registers have been used. The actual dataset used to estimate the number of problem drug users will be made public only after the final report of the commission is released (end of October 2023).

---
## The code
The model is estimated using Stan as interfaced from R. The easiest way to generate estimates is to run the code in main.R. 

---

## Example usage

To generate estiamtes and plot them in a figure do the following: 

* clone the repository (git clone https://github.com/aledberg/pduest)

* start R in the cloned directory and run the code in main.R

