## Workflow name: PredictVariantEffectsGEMINI

 This workflow annotates functional predictions using SnpEff and GEMINI after normalizing the variant representations
 using vt.

 **vt** is a toolkit for manipulating variants written by Adrian Tan et al. that is best known for its normalization
 capabilities, as described in the paper cited below. The source code is available on Github at
 http://github.com/atks/vt

 - Unified representation of genetic variants
 Adrian Tan, Gonçalo R. Abecasis, Hyun Min Kang
 Published: July 1, 2015 | https://doi.org/10.1093/bioinformatics/btv112

 **SnpEff** is a variant annotation and effect prediction tool written by Pablo Cingolani et al. that predicts the
 functional impact of variants on genes (such as amino acid changes), as described in the paper cited below. The
 source code is available at http://snpeff.sourceforge.net

 - A program for annotating and predicting the effects of single nucleotide polymorphisms, SnpEff: SNPs in the
 genome of Drosophila melanogaster strain w1118; iso-2; iso-3.
 Cingolani P, Platts A, Wang le L, Coon M, Nguyen T, Wang L, Land SJ, Lu X, Ruden DM. Fly
 https://doi.org/10.4161/fly.19695

 **GEMINI** is a toolkit written by Aaron Quinlan et al. that enables exploration of genetic variation for disease
 and population genetics via SQL, as described in the paper cited below. The source code is available on GitHub at
 https://github.com/arq5x/gemini

 - GEMINI: Integrative Exploration of Genetic Variation and Genome Annotations
 Paila U, Chapman BA, Kirchner R, Quinlan AR
 https://doi.org/10.1371/journal.pcbi.1003153

### Main inputs
 - One multisample VCF file to annotate
 - A PED file describing the case and control samples
 - Tar file of annotation resources used by Gemini
 - Reference genome (FASTA only) and name of the reference as it appears in the Gemini resources
 - A SnpEff jar executable and configuration file

### Important parameters
 - The query to apply to the Gemini database

### Outputs
 - A VCF file annotated by SnpEff
 - A queryable Gemini database
 - A text file containing the result of the Gemini query

### Workflow notes
 - The workflow is designed to be run per cohort.
 - Several pre-processing tasks are used to address minor incompatibilities that would break further analysis.
 - This version of the workflow does note scale well above a few hundred samples (tests ok with 100, but unreasonably slow with 500)

### Runtime notes
 - Cromwell version support: successfully tested on v34
 - Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
 - For program versions, see docker containers.

