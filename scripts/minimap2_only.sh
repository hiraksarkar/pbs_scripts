#!/bin/bash -e


start=`date +%s`

minimap2="/gpfs/scratch/moamin/anaconda3/bin/minimap2"
minimap2ind="/gpfs/scratch/moamin/hirak_sra_contamination/data/combined/taxid_combine_ref.mmi"
ref="/gpfs/scratch/moamin/hirak_sra_contamination/data/combined/genome/taxid_combine_ref.fa"
read_root_dir="/gpfs/scratch/moamin/hirak_sra_contamination/result/hisat_round2"
#minimap2ind="/mnt/scratch1/hirak/meta_genome/data_analysis_bacteria/bacteria_complete_assembly/ref_ncbi.mmi"
#output="/mnt/scratch3/hirak/meta_genome/samfiles2"
list_file=$1
output=$2
mkdir -p ${output}



while read line ; do    
#echo $line
	srrname=$line
	if [ ! -f ${output}/${srrname}.complete ]; then
			lstart=`date +%s`
			#srrname=$( echo $(basename $line) | cut -d. -f1)
			#srrnamepath=$( echo $line | cut -d. -f1)
			fq1=${read_root_dir}/${srrname}.1.fa
			fq2=${read_root_dir}/${srrname}.2.fa
			echo "Started for ${srrname} ..."
			#${minimap2} -ax sr ${minimap2ind} ${fq1} ${fq2} -t 25 | samtools view -bS -T ${ref} - -o ${output}/${srrname}.bam
		#/usr/bin/time ${minimap2} -ax sr ${minimap2ind} <(head -2000000 ${fq1}) <(head -2000000 ${fq2}) -t 25 2> ${output}/${srrname}.log | samtools view -Sb -@ 25 - > ${output}/${srrname}.bam
			/usr/bin/time ${minimap2} -ax sr ${minimap2ind} ${fq1} ${fq2} -t 25 2> ${output}/${srrname}.log | samtools view -Sb -@ 25 - | samtools sort -@ 8 -o ${output}/${srrname}.bam -
			lend=`date +%s`
			runtime=$((lend-lstart))
			printf "\nTime: $runtime sec\n\n"
			touch ${output}/${srrname}.complete
	fi
done < ${list_file}

end=`date +%s`
runtime=$((end-start))
printf "\n\nTotal time: $runtime sec\n\n"
