#!/bin/bash -e

start=`date +%s`

#hisat2_binary="/home/hirak/Projects/hisat2/hisat2"
hisat2_binary="/gpfs/scratch/moamin/hirak_sra_scripts/bin/hisat2-2.1.0/hisat2"
hisat2_ind="/gpfs/scratch/moamin/hirak_sra_contamination/data/human/genome/hisat_index/grch38/genome"
unmapped_printer_binary="/gpfs/scratch/moamin/hirak_sra_scripts/scripts/unmapped_read_printer"
round1_base_dir="/gpfs/scratch/moamin/hirak_sra_contamination/result/hisat_round1/"
#hisat2_ind="/mnt/scratch1/meta_genome/downloads/hisat_grch38_genome_tran_idx/genome_tran"
#output="/mnt/scratch2/hirak/meta_genome/data_analysis_bacteria/samples2/"

#list_file="/mnt/scratch1/hirak/meta_genome/data_analysis_bacteria/samples2/file2.list"
list_file=$1
output=$2
mkdir -p $output

while read line ; do
	lstart=`date +%s`
 ##this line is not correct, should strip :port and store to ip var
  #fq1=$( echo "$line" |cut -f1 )
  #fq2=$( echo "$line" |cut -f2 )
  fq1=${round1_base_dir}/${line}.1.fa
  fq2=${round1_base_dir}/${line}.2.fa
  srrname=$( echo $( basename $fq1) | cut -d'.' -f1)
  echo "running for ${srrname}"
  echo "output to ${output}/"

	tmpdir=$(mktemp -d)
	p1=$tmpdir/samrec
	mkfifo $p1
#trap "rm -rf $tmpdir" EXIT

	runAgain=true
	if [ -s "${output}/${srrname}" ] & [ -s "${output}/${srrname}" ]; then
    	filesize1=$(stat -c%s "${output}/${srrname}.1.fa")                                                     
    	filesize2=$(stat -c%s "${output}/${srrname}.2.fa")              
    	if (( filesize1 > 20000000 && filesize2 > 20000000 )); then                                                        
	    	echo "Files exist for ${output}/${srrname}. Sizes: $filesize1 bytes and $filesize2 bytes."
        	runAgain=false   
	    fi
	fi
	if [ "$runAgain" = true ]; then
  #if [ ! -f "${output}/${srrname}.complete" ]; then
#echo "${hisat2_binary}  --un-conc-gz \
#                       ${output}/$srrname \
#                       --sp 1,0 --score-min L,0,-0.5 -p 16 \
#                       -x ${hisat2_ind} \
#                       -1 $fq1 -2 $fq2 2>${output}/${srrname}.log > ${p1} &"
#						--un-conc-gz \
#                      ${output}/$srrname \
#

   /usr/bin/time ${hisat2_binary} \
                        --sp 1,0 --score-min L,0,-0.5 -p 16 \
                        -x ${hisat2_ind} \
						-f --no-spliced-alignment \
                        -1 $fq1 -2 $fq2 -S ${p1} 2>${output}/${srrname}.log & #> ${p1} &#/dev/null
	hisat_return_code=$?
    pid=`echo $!`
    echo "Hisat pid: ${pid}"

###################### stop the aligner after n rows ######################
	if ps -p ${pid} > /dev/null; then
		n=1000000
		n=$((n*2))
		echo "/mnt/scratch3/meta_genome/unmappedReadPrinter ${p1} ${n} ${pid} ${output}/${srrname}"
		${unmapped_printer_binary} ${p1} ${n} ${output}/${srrname}
		printer_return_code=$?
		echo "printer return code: ${printer_return_code}"
		echo "hisat return code: ${hisat_return_code}"
		if [[ ${printer_return_code} != 0 ]]; then
			echo "unmapped read finder failed for ${srrname} with return code ${printer_return_code}"
			rm ${output}/${srrname}.1.fa
			rm ${output}/${srrname}.2.fa
		fi
		if ps -p ${pid} > /dev/null; then
			echo "killing hisat"
			kill $pid
		else
			if [[ ${hisat_return_code} != 0 ]]; then
				echo "hisat failed for ${srrname} with return code ${hisat_return_code}"
				rm ${output}/${srrname}.1.fa
				rm ${output}/${srrname}.2.fa

			fi
		fi
	fi
	rm -rf $tmpdir
	lend=`date +%s`
	runtime=$((lend-lstart))
	printf "\n\nTotal time: $runtime sec\n\n"
fi
done < ${list_file} 

end=`date +%s`
runtime=$((end-start))
printf "\n\nTotal time: $runtime sec\n\n"
