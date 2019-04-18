## Goals

Determine what kind(s) of data would have the highest impact as a community resource dataset.

## Proposed tasks

1. Assess what types of genomic data are most commonly used in human genomics research and stratify by technical characteristics (library type, sequencing technology, depth of coverage etc).

2. Assess the current landscape of data that can be shared openly, whether "real" or synthetic. What is already available and what needs do existing open datasets address? 

3. (stretch) Evaluate whether there are tools other than the NEAT Read Simulator that we should consider using depending on the type of data resource we decide to focus on. What are the strengths and weaknesses of the available tools? 

## A Roadmap for Synthetic Data - What's Useful? What's Attainable? What Can We Aspire To?

### Sanity check for end users
- Help researchers understand how to use available tools and data sets. 
- Practice on synthetic data sets 
- Answer questions like "how do I use these tools?" and "What kind of output can I expct?"  
- Also useful for onboarding and training   

### Sanity check for developers    
QC of existing analysis tools:     
- Testing the plumbing (note: today's synthetic data is sufficient)  
- Testing the algorithm (note: today's synthetic data is not currently up to the task)  

### Enabler of reproducible research  
- First step to expanding the research (replication)
- Entirely reproducible publications


### What would a public-facing synthetic data set resource look like?   

**1. A curated selection of pre-made public synthetic data sets (data)**

    a. WES and GWS 
    b. Cohort sizees of hundreds to thousands
    c. Pre-selected read lengths (TBD)
    d Pre-selected read depths (TBD)
    e. Pre-defined variant types (TBD)
    
    **Questions**
    - Who would pay to generate and host these sets?   
    - Who would be able to access and would there be a nominal fee?  
    
**2. Self-service (choose your own mutation)**
Researchers could access this set of tools via a platform interface that would allow them to control the parameters of their synthetic data set to reproduce published results.   
   - Source data   
   - Cohort size  
   - Read length  
   - Read depth  
   - Variant types   
       

### Aspirational goals  
**Non-human genomes**
   - Mock metagenome communities
   - What is a (non-human) whole genome?  
   - Can you even have a reference genome?   
   
**Polygenic diseases**  


### The ultimate holy grail      
- Can we generate a totally synthetic "genome" that is functionally correct but not based on any one public-access genome?
- Can we integrate allelic frequencies from the human population?   

------

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

### Some Initial Thoughts (AHajian)
* **Synthetic data sets are necessary to QC your analysis tools:** Because with synthetic data, you know what variants you put in, and you know what you expect your tools to return. Thus synthetic data plays an important role in validating that the tools are working as expected, and that you can believe the results from a real data set.

* **Synthetic data sets are valuable for enabling reproducibility** But this is a longer-term benefit. The first is a more immediate need.

* **To be truly valuable as a resource, synthetic data sets need to be completely unidentifiable from their source data (i.e. 1,000 genomes)**

* **There is value in a lerge cohort of synthetic data sets across a range of populations** 

* **What data sets are available for use as the foundation of the synthetic data?** What are the pros and cons of each?


