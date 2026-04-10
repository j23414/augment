# Augment

Augment an existing analysis 

Tree -> Auspice website

## Install Nextstrain cli on MacOS

Currently requires Nextstrain-cli installed within a conda environment

```bash
# Install Nextstrain CLI
curl -fsSL --proto '=https' https://nextstrain.org/cli/installer/mac | bash

# Set conda environment runtime
nextstrain setup --set-default conda
```

## Minimal Run

```bash
nextflow run main.nf \
  --newick "path/to/tree.nwk" \
  --conda_env "path/to/nextstrain/conda/env

nextstrain view results/export
```

## Add Metadata

```bash
nextflow run main.nf \
  --newick "path/to/tree.nwk \
  --conda_env "path/to/nextstrain/conda/env" \
  --metadata "path/to/metadata.tsv" \
  --metadata_id_columns "accession" \
  --metadata_annotate "date region country host is_lab_host"
```

## Add Gene Annotations (nucleotide and amino acid mutations)

```bash
nextflow run main.nf \
  --newick "path/to/tree.nwk \
  --conda_env "path/to/nextstrain/conda/env" \
  --alignment "path/to/alignment.fasta" \
  --reference_gb "path/to/reference.gb" \
  --reference_fasta "path/to/reference.fasta"
```


**Local Testing**

```bash
nextflow run main.nf \
  --newick phylo/results/tree_raw.nwk \
  --metadata phylo/results/metadata.tsv \
  --export_params "--geo-resolutions region country" \
  --alignment phylo/results/aligned.fasta \
  --reference_gb phylo/defaults/reference.gb \
  --reference_fasta phylo/defaults/reference.fasta \
    -resume \
```