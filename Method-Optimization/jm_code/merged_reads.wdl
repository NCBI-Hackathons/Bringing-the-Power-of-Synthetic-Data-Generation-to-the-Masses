workflow testMergeReads {
  call mergeReads {}
}

task mergeReads {

	Array[File] scatteredBams = [
		"gs://fc-48d4a6c8-a0b5-4b7f-b16b-5cd3e96267c3/75fe97cd-0f9e-42f8-aadc-24fa72547bfc/GenerateSyntheticReads/f9419478-cbee-4cd2-b252-5f740d5ff258/call-GenerateReads/shard-20/HG00096_golden.bam", 
		"gs://fc-48d4a6c8-a0b5-4b7f-b16b-5cd3e96267c3/75fe97cd-0f9e-42f8-aadc-24fa72547bfc/GenerateSyntheticReads/f9419478-cbee-4cd2-b252-5f740d5ff258/call-GenerateReads/shard-23/HG00096_golden.bam"
	]

	Array[File] scatteredVCFs = [
		"gs://fc-48d4a6c8-a0b5-4b7f-b16b-5cd3e96267c3/75fe97cd-0f9e-42f8-aadc-24fa72547bfc/GenerateSyntheticReads/f9419478-cbee-4cd2-b252-5f740d5ff258/call-GenerateReads/shard-20/HG00096_golden.vcf", 
		"gs://fc-48d4a6c8-a0b5-4b7f-b16b-5cd3e96267c3/75fe97cd-0f9e-42f8-aadc-24fa72547bfc/GenerateSyntheticReads/f9419478-cbee-4cd2-b252-5f740d5ff258/call-GenerateReads/shard-23/HG00096_golden.vcf"
	]

    String baseName = basename(scatteredBams[0], ".bam")
    String path_to_bin = "/usr/neat-genreads/"

	command {

		mkdir reads_vcf_dir
		ln -sf `find . -type f -name '*.vcf'` reads_vcf_dir/
		ln -sf `find . -type f -name '*.bam'` reads_vcf_dir/

		python ${path_to_bin}mergeJobs.py \
		-i reads_vcf_dir/ \
		-o reads_vcf_dir/ \
		-s .

	}
	runtime {
		docker: "ruchim/neat-genreads-samtools:latest"
		preemptible: 0
	}
	output {
		
		File mergedVcf = baseName+"_golden.vcf"
		File mergedBam = baseName+"_golden.bam"
	}
}