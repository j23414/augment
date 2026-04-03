params.infiles = "*.txt"
params.outdir = "results"

process ADD_GREETING {
    publishDir "${params.outdir}/debug", mode: "copy"
    input: path(infile)
    output: path("${infile.baseName}_greeting.txt")

    script:
    """
    echo "Hello," > "${infile.baseName}_greeting.txt"
    sleep 100
    cat ${infile} >> "${infile.baseName}_greeting.txt"
    """
}

process ADD_FAREWELL {
    publishDir "${params.outdir}/", mode: "copy"
    input: path(infile)
    output: path("${infile.baseName}_letter.txt")

    script:
    """
    cat ${infile} >> "${infile.baseName}_letter.txt"
    sleep 50
    echo "Goodbye!" > "${infile.baseName}_letter.txt"
    """
}

workflow {
    main:
    ch_infiles = channel.fromPath(params.infiles)

    ch_infiles
    | ADD_GREETING
    | ADD_FAREWELL
    | view
}