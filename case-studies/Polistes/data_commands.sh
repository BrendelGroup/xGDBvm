#!/usr/bin/env bash
set -eo pipefail

download_genome()
{
    curl http://wasp.crg.eu/PCAN.v01.fa.gz | gunzip -c > Pcan.gdna.fa
    curl http://wasp.crg.eu/PCAN.v01.gff3 \
        | sed $'s/\ttranscript\t/\tmRNA\t/' \
        > Pcan.annot.gff3
}

download_refrprot()
{
    dmel="ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/invertebrate/Drosophila_melanogaster/all_assembly_versions/GCF_000001215.4_Release_6_plus_ISO1_MT/GCF_000001215.4_Release_6_plus_ISO1_MT_protein.faa.gz"
    amel="ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/invertebrate/Apis_mellifera/all_assembly_versions/GCF_000002195.4_Amel_4.5/GCF_000002195.4_Amel_4.5_protein.faa.gz"
    nvit="ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/invertebrate/Nasonia_vitripennis/all_assembly_versions/GCF_000002325.3_Nvit_2.1/GCF_000002325.3_Nvit_2.1_protein.faa.gz"

    curl $dmel | gunzip -c > Dmel.refrprot.fa
    curl $amel | gunzip -c > Amel.refrprot.fa
    curl $nvit | gunzip -c > Nvit.refrprot.fa
}

download_tsa()
{
    local tsaid=$1
    local label=$2

    curl http://www.ncbi.nlm.nih.gov/Traces/wgs/?download=${tsaid}.fsa_nt.gz \
        | gunzip -c \
        | perl -ne 's/^>gb\|([^\|]+)\|/>$1/; print' \
        > ${label}-tsa.fa
}
