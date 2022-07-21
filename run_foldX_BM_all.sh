#!/usr/bin/env bash

#This will read the pdb file and make a individuals_list.txt file according to conventions in BuildModel of foldX
#Using the individuals_list, the Build Model command will then be used to extract the ddG score
#The data processing and output conventions are inspired by and adapted from the MutateX software
#See https://github.com/ELELAB/mutatex for a well developed program to utilize Build Model

#Inputs
OGpdb="GNB1L_bfact_avg_functional"
outfname="individual_list"
foldX_loc="/Users/lhoeg/Documents/foldX/foldx5MacStd/foldx_20221231"
outfile="GNB1L_foldX_BM_output"
chain="B"

#Set up Amino Acid vars in order for mapping
aa1=('G' 'A' 'L' 'V' 'I' 'P' 'R' 'T' 'S' 'C' 'M' 'K' 'E' 'Q' 'D' 'N' 'W' 'Y' 'F' 'H')
aa3=('GLY' 'ALA' 'LEU' 'VAL' 'ILE' 'PRO' 'ARG' 'THR' 'SER' 'CYS' 'MET' 'LYS' 'GLU' 'GLN' 'ASP' 'ASN' 'TRP' 'TYR' 'PHE' 'HIS')

#Initialize log file for current iteration
Currentdate=`date`
echo Starting analysis at ${Currentdate} >> log_foldX_batch.txt

#Parse pdb file for inputs
echo Parsing pdb file ${OGpdb}.pdb for residues and positions on chain ${chain} >> log_foldX_batch.txt

#Get unique residues in given chain from pdb
awk '$5 == "B" { print $4 "\t" $6 }' ${OGpdb}.pdb > temp_out.txt
#Remove duplicate rows
awk '!seen[$0]++' temp_out.txt > temp2_out.txt
#Remove unneccesary file
rm temp_out.txt

#Determine number of residues
maxres=`tail -n 1 temp2_out.txt | awk '{print $2}'`

#Iterate through each residue

for i in `seq 1 $maxres` ; do
 res3=`head -n $i temp2_out.txt | tail -n 1 | awk '{print $1}'`

# Translate given 3 letter amino acid code to single letter
 for q in "${!aa3[@]}"; do
  if [[ "${aa3[$q]}" = "${res3}" ]]; then
   res1=${aa1[$q]} ;
  fi
 done
# Define search parameter based on residue and position
 for p in "${!aa1[@]}"; do
  if [[ ${res1} != ${aa1[p]} ]]; then
   param="${res1}${chain}${i}${aa1[p]};"
   echo ${param} >> ${outfname}.txt
  fi
 done
done

rm temp2_out.txt

for r in "${!aa1[@]}"; do
 echo Starting BuildModel of foldX for all ${aa1[r]} residues >> log_foldX_batch.txt
 grep "^${aa1[r]}" ${outfname}.txt >  ${outfname}_${aa1[r]}.txt
 ${foldX_loc} \
  --command=BuildModel --pdb=${OGpdb}.pdb \
  --mutant-file=${outfname}_${aa1[r]}.txt \
  --screen=FALSE --out-pdb=FALSE
 nmut=`wc -l < ${outfname}_${aa1[r]}.txt`
 nres=`grep -c ${OGpdb} Dif_${OGpdb}.fxout`
 grep ${OGpdb} Dif_${OGpdb}.fxout > ${aa1[r]}Dif_${OGpdb}.fxout
 if [[ ${nmut} -eq ${nres} ]]; then
  echo Proceed with alignment and save of all ${aa1[r]} residues >> log_foldX_batch.txt
  for s in `seq 1 ${nres}` ; do
   resx=`head -n $s ${outfname}_${aa1[r]}.txt | tail -n1`
   resx2=`echo ${resx} | gsed -r 's/[B;]//g'`
   ddgx=`head -n $s ${aa1[r]}Dif_${OGpdb}.fxout | tail -n1 | cut -f2`
   echo -e ${resx2} "\t" ${ddgx} >> ${outfile}.txt
   echo Cleaning up intermittent files from ${aa1[r]} residues >> log_foldX_batch.txt
   rm ${aa1[r]}Dif_${OGpdb}.fxout
   rm ${outfname}_${aa1[r]}.txt
  done
 else
  echo Ooops! Somehow you have different numbers of inputs to outputs at ${aa1[r]} residues. >> log_foldX_batch.txt
  echo Refer to ${outfname}_${aa1[r]}.txt and ${aa1[r]}Dif_${OGpdb}.fxout >> log_foldX_batch.txt
  echo Cleaning up intermittent files from ${aa1[r]} residues >> log_foldX_batch.txt
 fi
 rm Dif_${OGpdb}.fxout
 rm Raw_${OGpdb}.fxout
 rm rotabase.txt
 rm PdbList_${OGpdb}.fxout
 rm Average_${OGpdb}.fxout
 echo Done with ${aa1[r]} residues >> log_foldX_batch.txt
done

Currentdate=`date`
echo DONE analysis at ${Currentdate} >> log_foldX_batch.txt

