### Workflow name: JointCallAndHardFilterGATK4

 This workflow uses several GATK4 tools, including the GenomicsDB tooling for scalable joint calling, to apply joint
 variant discovery analysis to GVCFs produced by HaplotypeCaller and apply a simple hard filtering threshold. Note
 that this does not completely follow the official GATK Best Practices recommendations, which use VQSR for multisample
 datasets and CNN for single WGS or small exome cohorts (N<30).

 GATK is a genomics toolkit mainly focused on variant discovery developed at the Broad Institute. For documentation
 and support, see https://software.broadinstitute.org/gatk. To cite the joint calling methodology, see the preprint
 cited below. The source code is available on Github at https://github.com/broadinstitute/gatk

 Scaling accurate genetic variant discovery to tens of thousands of samples
 Ryan Poplin, Valentin Ruano-Rubio, Mark A. DePristo, Tim J. Fennell, Mauricio O. Carneiro, Geraldine A. Van der
 Auwera, David E. Kling, Laura D. Gauthier, Ami Levy-Moonshine, David Roazen, Khalid Shakir, Joel Thibault, Sheila
 Chandran, Chris Whelan, Monkol Lek, Stacey Gabriel, Mark J. Daly, Benjamin Neale, Daniel G. MacArthur, Eric Banks
 Preprint posted: November 14, 2017 | https://doi.org/10.1101/201178

### Main inputs
 - Reference genome, index and dictionary
 - List of GVCF files to joint-call and the corresponding sample names
 - List of intervals in GATK-style format

### Important parameters
 - Batch size for import step (use the provided default of 50 unless you know what you're doing)
 - Filtering expression and corresponding filter name

### Outputs
 - Joint-called multisample VCF with hard filtering applied, in compressed .gz format, and its .tbi index

### Workflow notes
 - The workflow is designed to be run per cohort.
 - The GenomicsDB-centric import and joint calling steps are scattered across supersets of WGS intervals.
 - All sites that are present in the input VCF are retained; filtered sites are annotated as such in the FILTER field.

### Runtime notes
 - Cromwell version support: successfully tested on v34
 - Runtime parameters are optimized for Broad's Google Cloud Platform implementation.
 - For program versions, see docker containers.
