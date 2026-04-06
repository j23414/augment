# Augment

Augment an existing analysis 

Tree -> Auspice website

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

<!--

**Local Testing

```bash
nextflow run main.nf \
  --newick /Users/jchang99/github/nextstrain/astravirus/phylogenetic/results/tree_raw.nwk \
  --metadata /Users/jchang99/github/nextstrain/astravirus/phylogenetic/results/metadata.tsv \
  -resume \
  --export_params "--geo-resolutions region country"
```

-->