#!/bin/bash -e
#minimap2="/home/fatemeh/others_projects/minimap2/minimap2"
#minimap2ind="/mnt/scratch3/meta_genome/combined_contamenation/other64.mmi"
cedar="/gpfs/scratch/moamin/hirak_sra_scripts/bin/pufferfish-latest_linux_x86_64/bin/cedar"
bam_root_dir="/gpfs/scratch/moamin/hirak_sra_contamination/result/minimap2"
#ref="/mnt/scratch3/hirak/meta_genome/reference/ref_ncbi.fa"
#minimap2ind="/mnt/scratch1/hirak/meta_genome/data_analysis_bacteria/bacteria_complete_assembly/ref_ncbi.mmi"
#output="/mnt/scratch3/hirak/meta_genome/samfiles2"
list_file=$1
output=$2

mkdir -p ${output}

mapfile=$3
dmpfile=$4


while read line ; do
	srrname=$line
	echo "srrname: "${srrname}
	#if [ ! -f ${output}/${srrname}.complete ]; then
		#echo $line
		bamfile=${bam_root_dir}/${srrname}.bam
		#echo "$cedar --level species --sam ${srrnamepath}.bam --output $output/${srrname}.cedar  --seq2taxa $mapfile --taxtree $dmpfile --unique"
		export LD_LIBRARY_PATH=/gpfs/scratch/moamin/hirak_sra_scripts/bin/pufferfish-latest_linux_x86_64/lib
		$cedar --level species --sam ${bamfile} --output ${output}/${srrname}.cedar  --seq2taxa \
											$mapfile --taxtree $dmpfile --unique 2> ${output}/${srrname}.log
		$cedar --level genus --sam ${bamfile} --output ${output}/${srrname}_genus.cedar  --seq2taxa \
											$mapfile --taxtree $dmpfile --unique 2> ${output}/${srrname}_genus.log
		$cedar --level species --sam ${bamfile} --output ${output}/${srrname}_mm.cedar  --seq2taxa \
											$mapfile --taxtree $dmpfile 2> ${output}/${srrname}_mm.log
		
		touch ${output}/${srrname}.complete
	#fi
done < ${list_file} 
