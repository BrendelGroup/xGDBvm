# Case study: Rapid Setup of an Analysis Environment for Comparative *Polistes* Genomics

Contributed by Daniel Standage, February 2016.

During our recently work on assembling and annotating the genome of the paper wasp *Polistes dominula*, the genome of its cogener *P. canadensis* became available.
Here we demonstrate how **xGDBvm** can be used for rapid setup of an environment for visualizing the genome, as well as evaluating and refining annotations for genes of interest.

## 1. Setup

From the iPlant/CyVerse Atmosphere portal, launch a new instance using the latest **xGDBvm** image (v1.15 as of this writing).
When the VM is available, connect via SSH, execute the `quickstart` command, and follow the instructions for setting up the VM.

## 2. Data access

For this case study, we will be using the following data.

- Genome sequence (assembled scaffolds) of the *P. canadensis* genome, as made available by colleagues [here](http://wasp.crg.eu/download.html).
- Transcript shotgun assemblies from four *Polistes* species, as available from the NCBI TSA database.
  Download link annotated as the final `TSA` entry of the record.
    - [*P. canadensis*](http://www.ncbi.nlm.nih.gov/nuccore/GAFR00000000.1)
    - [*P. dominula*](http://www.ncbi.nlm.nih.gov/nuccore/GEDB00000000.1)
    - [*P. fuscatus*](http://www.ncbi.nlm.nih.gov/nuccore/GDFS00000000.1)
    - [*P. metricus*](http://www.ncbi.nlm.nih.gov/nuccore/GDHQ00000000.1)
- Reference proteins obtained from RefSeq entries of the following species.
    - *Apis mellifera* (honey bee)
    - *Drosophila melanogaster* (fruit fly)
    - *Nasonia vitripennis* (jewel wasp)

The `data_commands.sh` script is provided to facilitate easy download of these data.
After successful set up of the VM, execute the following commands to download the data files.

```bash
# Create a dedicated directory for our input data
cd /xGDBvm/input/xgdbvm/
mkdir pcan/
cd pcan/

# Load the data download helper commands
source /xGDBvm/case-studies/Polistes/data_commands.sh

# Now download the data
download_genome
download_refrprot
download_tsa GAFR01.1 Pcan
download_tsa GEDB01.1 Pdom
download_tsa GDFS01.1 Pfus
download_tsa GDHQ01.1 Pmet
```

These commands should create seven data files in the VM's `/xGDBvm/input/xgdbvm/pcan/` directory.

- `Pcan.gdna.fa`: genome sequence
- `Pcan.annot.fa`: genome annotation
- `AmelDmelNvit.prot.fa`: reference proteins
- `Pcan.tsa.fa`: *P. canadensis* transcripts
- `Pdom.tsa.fa`: *P. dominula* transcripts
- `Pfus.tsa.fa`: *P. fuscatus* transcripts
- `Pmet.tsa.fa`: *P. metricus* transcripts

## 3. Configuring the GDB

To go here.
