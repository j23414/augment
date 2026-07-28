process AUGUR_ANCESTRAL {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    // container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
    //     ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/e9/e994bf4eb3731150511a14f5706b7bdfd64df1b6d40898fff334286c027e0859/data'
    //     : 'community.wave.seqera.io/library/htslib_samtools:1.24--d697cfb9dce007cd'}"

    input:
    tuple val(meta), path(tree)
    path(aln_fasta)
    path(ref_fasta)

    output:
    path("${tree.baseName}_nt-muts.json"), emit: node
    
    script:
    def args = task.ext.args ?: ''
    def alignment_args = aln_fasta ? "--alignment ${aln_fasta}" : ""
    def root_args = ref_fasta ? "--root-sequence ${ref_fasta}": ""
    """
    augur ancestral \\
    --tree ${tree} \\
    ${args} \\
    ${alignment_args} \\
    ${root_args} \\
    --output-node-data ${tree.baseName}_nt-muts.json
    """
}