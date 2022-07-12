#!/usr/bin/env bash

#Set up Amino Acid vars in order for mapping
aa1=('G' 'A' 'L' 'V' 'I' 'P' 'R' 'T' 'S' 'C' 'M' 'K' 'E' 'Q' 'D' 'N' 'W' 'Y' 'F' 'H')
aa3=('GLY' 'ALA' 'LEU' 'VAL' 'ILE' 'PRO' 'ARG' 'THR' 'SER' 'CYS' 'MET' 'LYS' 'GLU' 'GLN' 'ASP' 'ASN' 'TRP' 'TYR' 'PHE' 'HIS')

#Define inputs
OGpdb="GNB1L_bfact_avg_functional"
outdir="foldX_outputs"
chain="B"
outfile="GNB1L_foldX_output"
foldX_loc="/Users/lhoeg/Documents/foldX/foldx5MacStd/foldx_20221231"

#Initialize log file for current iteration
Currentdate=`date`
echo Starting analysis at ${Currentdate}
#Parse pdb file for inputs
echo Parsing pdb file ${OGpdb}.pdb for residues and positions on chain ${chain} >> log_foldX_batch.txt
#Extract only residue and position for specified chain
awk '$5 == "B" { print $4 "\t" $6 }' ${OGpdb}.pdb > temp_out.txt
#Remove duplicate rows
awk '!seen[$0]++' temp_out.txt > temp2_out.txt
#Remove unneccesary file
rm temp_out.txt

#Determine number of residues
maxres=`tail -n 1 temp2_out.txt | awk '{print $2}'`

#Iterate through each residue
echo Starting first residue for foldX search >> log_foldX_batch.txt
for i in `seq 1 $maxres` ; do
 res3=`head -n $i temp2_out.txt | tail -n 1 | awk '{print $1}'`

# Translate given 3 letter amino acid code to single letter
 for q in "${!aa3[@]}"; do
  if [[ "${aa3[$q]}" = "${res3}" ]]; then
   res1=${aa1[$q]} ;
  fi
 done
# Define search parameter based on residue and position
 param="${res1}${chain}${i}a"
# Write to log file what comparison is being started
 echo Starting foldX of ${res3} at position ${i} using parameter ${param} >> log_foldX_batch.txt
# Call foldX program with indicated parameters
 ${foldX_loc} \
  --command=PositionScan \
  --pdb=${OGpdb}.pdb \
  --positions=${param} \
  --out-pdb=FALSE \
  --output-dir=${outdir} \
  --output-file=Temp \
  --screen=false
# Remove self comparison from output & Concatenate output to a mainfile
# Note: histidine may retain the self comparison depending on how the software utilizes H1S and H2S
 echo Adding output scores from ${param} input to main file >> log_foldX_batch.txt
 rem_line=`head -n 1 ${outdir}/PS_Temp_scanning_output.txt`
 grep -v "${rem_line}" ${outdir}/PS_Temp_scanning_output.txt > ${outdir}/out_rem1.txt
 grep -v "${res3}${chain}${i}${res1}" ${outdir}/out_rem1.txt >> ${outdir}/${outfile}.txt
# Clean up extra pdb files
 echo Cleaning up intermittent files from ${param} input >> log_foldX_batch.txt
 for p in "${!aa3[@]}"; do
  pdb="${aa3[$p]}${i}_${OGpdb}.pdb"
  if test -f "$pdb"; then
   rm $pdb
  fi
 done
# Clean up other files
 rmdir molecules/
 rm Temp
 rm rotabase.txt
 rm binding_energies_${i}_${OGpdb}.txt
 rm energies_${i}_${OGpdb}.txt
 echo Done with ${param} input >> log_foldX_batch.txt
# Keeping ${outdir}/out_rem1.txt for now to allow preview of most recent output
done

#Remove extra files
rm ${outdir}/out_rem1.txt
rm temp2_out.txt

Currentdate=`date`
echo DONE at ${Currentdate} >> log_foldX_batch.txt


