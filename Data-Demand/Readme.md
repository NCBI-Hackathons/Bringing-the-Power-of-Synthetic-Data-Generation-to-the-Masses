## Goals

Determine what kind(s) of data would have the highest impact as a community resource dataset.

## Proposed tasks

1. Assess what types of genomic data are most commonly used in human genomics research and stratify by technical characteristics (library type, sequencing technology, depth of coverage etc).

2. Assess the current landscape of data that can be shared openly, whether "real" or synthetic. What is already available and what needs do existing open datasets address? 

3. (stretch) Evaluate whether there are tools other than the NEAT Read Simulator that we should consider using depending on the type of data resource we decide to focus on. What are the strengths and weaknesses of the available tools? 

## Some background reading

If you find useful/interesting resources to add to this document, please open an issue or make a pull request to update it. 

### Sequence datasets 

* [Public data and open source tools for multi-assay genomic investigation of disease](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4945830/) 
A summary of public-access sources of genomics data. It will offer information on where there are gaps that synthetic data could fill.

### Synthetic read data generation tools

* [A comparison of tools for the simulation of genomic next-generation sequencing data (Escalona et al, 2016)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5224698/) 
A recent(ish) review of tools for generating synthetic read data (does not include NEAT, which was only published the following year). 

* [Simulating Next-Generation Sequencing Datasets from Empirical Mutation and Sequencing Models (Stephens et al, 2016)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5125660/) 
The paper describing the NEAT Read Simulator toolkit used in our original prototype. 

#### Other read simulation tools

* [Generation of Artificial FASTQ Files to Evaluate the Performance of Next-Generation Sequencing Pipelines (Frampton et al, 2012)](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0049110) 
This paper describes a tool for generating read data in FASTQ format. 

### Synthetic data in general (not specific to genomics) 

* [A Review Of Synthetic Data Generation Methods For Privacy Preserving Data Publishing](https://www.ijstr.org/final-print/mar2017/A-Review-Of-Synthetic-Data-Generation-Methods-For-Privacy-Preserving-Data-Publishing.pdf) . 

* [Synthetic data generation — a must-have skill for new data scientists](https://towardsdatascience.com/synthetic-data-generation-a-must-have-skill-for-new-data-scientists-915896c0c1ae) 
This is a general lay of the land with respect to synthetic data and how it is the food that all data scientists need to make progress. It is also only ten minutes or so to read through...

* [15 Best Test Data Generation Tools In 2019](https://www.rankred.com/test-data-generation-tools/) 
These are some examples of synthetic data generation tools from other fields. 

* [24 Ultimate Data Science Projects To Boost Your Knowledge and Skills (& can be accessed freely)](https://www.analyticsvidhya.com/blog/2018/05/24-ultimate-data-science-projects-to-boost-your-knowledge-and-skills/) 
These are some examples of sythetic data sets in other fields that might be interesting. 

* [Heart Disease Prevalence from SyntheticMass](https://syntheticmass.mitre.org/dashboard/synthea/town/pct_heart_disease)
This group has generated sythetic census data for the state of Massachusetts. Here's one example for heart disease.

### Some Initial Thoughts
* **Synthetic data sets are necessary to QC your analysis tools:** Because you know what you put in, nyou know what you expect your tools to return. You need to do this in order to believe the results from a real data set (i.e. real genomics research).

* **

