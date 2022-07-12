# Batch_pdb2foldX
  
This shell script parses a Protein Data Base file for the three letter gene code at each position, maps the three letter code to the single letter code, and uses the information to iterate the foldX PositionScan command through each residue.  
  
**PDB File:**  
- Should be in current working directory where you are running the script from.  
- The one I've been using only has residues with ATOM designation, and starts immediately on the data with no header. Modifications to allow for a more flexible input may be considered in the future.  
  
**Inputs:**  
- Define name of original PDB file without the .pdb extension as the "OGpdb" variable  
- Define the name of the output directory as "outdir" for the main output file. The directory must already exist.  
- Identify the chain being considered.  
- Give the main output file that collects all scores a name as "outfile"  
  
**foldX parameters**  
- out-pdb=FALSE, this is set to prevent the software from making a new PDB file for each mutagenesis performed. Included in the code is a redundancy for specifying that if the novel PDB file exists, to delete it. I left this in mainly because it deletes files named from the expected 3 letter amino acid code, but if sometimes the software runs HIS as H2S or H1S, so if out-pdb=TRUE, then all the novel files will be deleted except the ones with the substituted histidine, which can serve as a marker for which residue outputs to explore further.  
- screen=false, this removes all of the statistical output from the terminal screen. Only progress markers of which mutagenesis is being performed will print on screen.  
  
**Considerations:**  
- Only 20 standard amino acid are described for mapping to single letter code. The foldX documentation lists additional recognized amino acids based on certain common modifications that you can add to the aa3 and aa1 variables at the top of the script.  
- Progress will be reported to a file called "log_foldX_batch.txt". If it does not already exist, it will be created. If it does exist, new lines will be appended to the end of the document.  
- Currently getting unexpected results with mutating to or from histidine. The software may substitute "H1S" or "H2S" as "o" or "e" representing charged "ND1" and "NE2" for mutagenesis from the standard "HIS"/"H", and I'm not sure why.  
- If the program is interrupted, just check the log or output file for the last added input, then change the starting sequence number to the next required residue.  
  
  
