#==============================================================================#
#                       Parse config and sample information                    #
#==============================================================================#
# IMPORT python libraries
from os.path import join
import csv
import re

# Import config file & parameters
configfile: 'config.yaml'

# Read Annotation CSV and find samples with ChIPseq or/and RNAseq data
TUMOR_SAMPLES_CHIP = []
TUMOR_SAMPLES_RNA  = []
TUMOR_SAMPLES_CHIP_RNA = []
with open(config['tumor_annotation_csv']) as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        if row['avail.ChIPseq'] == 'TRUE':
            TUMOR_SAMPLES_CHIP.append(row['ProjectID'])
        if row['avail.RNAseq'] == 'TRUE':
            TUMOR_SAMPLES_RNA.append(row['ProjectID'])
            if row['avail.ChIPseq'] == 'TRUE':
                TUMOR_SAMPLES_CHIP_RNA.append(row['ProjectID'])

CELLS_SAMPLES_CHIP = []
CELLS_SAMPLES_RNA  = []
CELLS_SAMPLES_CHIP_RNA = []
with open(config['cells_annotation_csv']) as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        if row['avail.ChIPseq'] == 'TRUE':
            CELLS_SAMPLES_CHIP.append(row['ProjectID'])
        if row['avail.RNAseq'] == 'TRUE':
            CELLS_SAMPLES_RNA.append(row['ProjectID'])
            if row['avail.ChIPseq'] == 'TRUE':
                CELLS_SAMPLES_CHIP_RNA.append(row['ProjectID'])


# TUMOR_SAMPLES_CHIP
# TUMOR_SAMPLES_RNA
# TUMOR_SAMPLES_CHIP_RNA
# len(TUMOR_SAMPLES_CHIP)
# len(TUMOR_SAMPLES_RNA)
# len(TUMOR_SAMPLES_CHIP_RNA)


#==============================================================================#
#                  Main path to store results and tmp data                     #
#==============================================================================#
# Import paths from config file
DATAPATH = config['main_working_directory']


#==============================================================================#
#                               Include extra rules                            #
#==============================================================================#
# Include snakefiles containing figure rules
include: "snakefiles/Enhancers.Snakefile"
include: "snakefiles/figure1.Snakefile"
include: "snakefiles/figure2.Snakefile"
include: "snakefiles/figure3.Snakefile"
include: "snakefiles/figure4.Snakefile"
include: "snakefiles/sup_figure2.Snakefile"

        
#==============================================================================#
#               Print sample data at the pipeline's start.                     #
#==============================================================================#
    
def printExp():
  print("-------------------------------")
  print(str(len(TUMOR_SAMPLES_CHIP)) + " Tumor samples with ChIPseq data available")
  #print(TUMOR_SAMPLES_CHIP)
  print("-------------------------------")
  print(str(len(TUMOR_SAMPLES_RNA)) + " Tumor samples with RNAseq data available ")
  #print(TUMOR_SAMPLES_RNA)
  print("-------------------------------")
  print(str(len(TUMOR_SAMPLES_CHIP_RNA)) + " Tumor samples with ChIPseq and RNAseq data available")
  #print(TUMOR_SAMPLES_CHIP_RNA)
  print("")
  print("-------------------------------")
  print(str(len(CELLS_SAMPLES_CHIP)) + " Cell lines samples with ChIPseq data available")
  #print(CELLS_SAMPLES_CHIP)
  print("-------------------------------")
  print(str(len(CELLS_SAMPLES_RNA)) + " Cell lines samples with RNAseq data available ")
  #print(CELLS_SAMPLES_RNA)
  print("-------------------------------")
  print(str(len(CELLS_SAMPLES_CHIP_RNA)) + " Cell lines samples with ChIPseq and RNAseq data available")
  #print(CELLS_SAMPLES_CHIP_RNA)
  print("")
printExp()



#==============================================================================#
#                         Function to collect final files                      #
#==============================================================================#
#helper function to collect final files from pipeline
def inputall(wilcards):
    collectfiles = []
    # Compile figures
    if config["compileFigs"]["figure1"]:
        collectfiles.append(join(DATAPATH, 'results/figure1/figure1_paths.txt'))
    if config["compileFigs"]["figure2"]:
        collectfiles.append(join(DATAPATH, 'results/figure2/figure2_paths.txt'))
    if config["compileFigs"]["figure3"]:
        collectfiles.append(join(DATAPATH, 'results/figure3/figure3_paths.txt'))
    if config["compileFigs"]["figure4"]:
        collectfiles.append(join(DATAPATH, 'results/figure4/figure4_paths.txt'))
        collectfiles.append(join(DATAPATH, 'reports/make_supptables.html'))
    if config["compileFigs"]["sup_figure2"]:
        collectfiles.append(join(DATAPATH, 'results/sup_figure2/sup_figure2_paths.txt'))
    # ARACNe
    if config["phase03_ARACNe"]["input_matrix"]:
        collectfiles.extend(expand(join(DATAPATH, 'analysis/{type}/rnaseq/exprs/{type}_RNAseq_SYMBOL_TPM_Matrix_filt_log.txt'), zip, type = ["tumor", "cells"]))
    if config["phase03_ARACNe"]["run_ARACNe"]:
        collectfiles.append(join(DATAPATH, 'analysis/tumor/ARACNe/network.txt'))
    if config["phase03_ARACNe"]["run_VIPER"]:
        collectfiles.append(join(DATAPATH, 'analysis/tumor/VIPER/networkViper.txt'))
        collectfiles.append(join(DATAPATH, 'analysis/tumor/VIPER/NBpersampleTFactivity.RDS'))
    # NMF
    if config["phase02_NMF"]["NMF_rnaseq"]:
        collectfiles.extend(expand(join(DATAPATH, 'reports/04_{type}_SE_targets_rnaseq_NMF_report.html'), zip, type = ["tumor", "cells"]))
        collectfiles.extend(expand(join(DATAPATH, 'reports/05_{type}_mostVariable_rnaseq_NMF_report.html'), zip, type = ["tumor", "cells"]))        
    if config["phase02_NMF"]["NMF_chipseq"]:
        collectfiles.append(join(DATAPATH, 'reports/09_tumor_Enhancers_chipseq_NMF_report.html'))
        collectfiles.append(join(DATAPATH, 'reports/03_tumor_chipseq_NMF_report.html'))
        collectfiles.append(join(DATAPATH, 'reports/03_tumor_cells_chipseq_NMF_report.html'))
        collectfiles.append(join(DATAPATH, 'reports/03_cells_chipseq_NMF_report.html'))        
    # Consensus SE
    if config["phase01_consensusSE"]["SE_target_gene"]:
        # Enhancers 
        collectfiles.append(join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusEnhancers/tumor_consensusEnhancers_target_GRanges.RDS'))
        # Super Enhancers
        collectfiles.append(join(DATAPATH, 'analysis/tumor/SE_annot/tumor_consensusSE_target_GRanges.RDS'))
        collectfiles.append(join(DATAPATH, 'reports/02_SE_target_genes_report.html'))
    if config["phase01_consensusSE"]["consensus_cells_SE"]:
        collectfiles.append(join(DATAPATH, 'analysis/cells/chipseq/H3K27ac/consensusSE/cells_H3K27ac_noH3K4me3_consensusSE.bed'))
    if config["phase01_consensusSE"]["consensus_tumor_SE"]:
        # Enhancers
        collectfiles.append(join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/consensusEnhancers/tumor_cells_H3K27ac_noH3K4me3_consensusEnhancers_SignalScore.RDS'))
        collectfiles.extend(expand(join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/consensusEnhancers/{type}_H3K27ac_noH3K4me3_consensusEnhancers_SignalScore.txt'), zip, type = ["tumor", "cells"]))
        # Super Enhancers
        collectfiles.append(join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE.bed'))
        collectfiles.append(join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/consensusSE/tumor_cells_H3K27ac_noH3K4me3_consensusSE_SignalScore.RDS'))
        collectfiles.extend(expand(join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/consensusSE/{type}_H3K27ac_noH3K4me3_consensusSE_SignalScore.txt'), zip, type = ["tumor", "cells"]))
    #return final list of all files to collect from the pipeline
    return collectfiles

# Collect pipeline result files
rule all:
    input: inputall


#"envs/R3.5.yaml"

rule placeh:
    input:
        consensusSE = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE.bed')
    output: 
        outtmp = join(DATAPATH, 'tmp.txt')
    params:
        script='scripts/analysis/01_SEmatrix.R',
    conda:
        'envs/cuda_R3.5.yaml'
    shell:
        """
        Rscript {params.script} {output.outtmp} {input.consensusSE} 
        """

#================================================================================#
#                         Compile supplementary tables                           #
#================================================================================#
rule supp_tables:
    input:
        annot_t   = join(DATAPATH, 'annotation/annotation_tumor.RDS'),
        annot_c   = join(DATAPATH, 'annotation/annotation_cells.RDS'),
        purity_t  = join(DATAPATH, 'annotation/purity_tumor.csv'),
        SEtarget  = join(DATAPATH, 'analysis/tumor/SE_annot/tumor_consensusSE_target_GRanges.RDS'),
        
        go_enrich   = join(DATAPATH, 'results/supptables/GO_BP_enrichment_SE_target_genes.txt'),
        eChIP_tumor = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/NMF/tumor_consensusSE_K4_GO_BP_enrichment.RDS'),
        eChIP_cells = join(DATAPATH, 'analysis/cells/chipseq/H3K27ac/NMF/cells_consensusSE_K3_GO_BP_enrichment.RDS'),
        eRNAs_tumor = join(DATAPATH, 'analysis/tumor/rnaseq/NMF/tumor_consensusSE_K4_GO_BP_enrichment.RDS'),
        eRNAv_tumor = join(DATAPATH, 'analysis/tumor/rnaseq/NMF_mostVariable/tumor_mostVariable_K4_GO_BP_enrichment.RDS'),
        
        Hchip_t   = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/NMF/tumor_consensusSE_K4_Hmatrix_wnorm.RDS'),
        Hchip_c   = join(DATAPATH, 'analysis/cells/chipseq/H3K27ac/NMF/cells_consensusSE_K3_Hmatrix_wnorm.RDS'),
        Hchip_tc  = join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/NMF/tumor_cells_consensusSE_K5_Hmatrix_wnorm.RDS'),
        Hrna_tt   = join(DATAPATH, 'analysis/tumor/rnaseq/NMF/tumor_consensusSE_K4_Hmatrix_wnorm.RDS'),
        Hrna_tmv  = join(DATAPATH, 'analysis/tumor/rnaseq/NMF_mostVariable/tumor_mostVariable_K4_Hmatrix_wnorm.RDS'),
        
        NBregulome = join(DATAPATH, 'analysis/tumor/ARACNe/network.txt'),
        TFactivity = join(DATAPATH, 'results/supptables/TFactivity_across_all_signatures_ZnormPerSig.txt'),
        CRCfracobs = join(DATAPATH, 'results/supptables/crcTF_fractionObserved.xls'),
        CRCmodules = join(DATAPATH, 'results/supptables/crcTF_modules.txt'),
        EnrichTF   = join(DATAPATH, 'analysis/tumor/Rel_vs_Pri/RelapseVsPrimary_EnrichTFregulons.txt')
    output:
        report  = join(DATAPATH, 'reports/make_supptables.html'),
        rmd     = temp(join(DATAPATH, 'reports/make_supptables.Rmd')),
        
        S1t = join(DATAPATH, 'results/supptables/S1_annotation.xlsx'),
        S2t = join(DATAPATH, 'results/supptables/S2_SE_regions_and_target.xlsx'),
        S3t = join(DATAPATH, 'results/supptables/S3_SE_target_genes_GO_BP_enrichment.xlsx'),
        S4t = join(DATAPATH, 'results/supptables/S4_NMF_H_Matrices.xlsx'),
        S5t = join(DATAPATH, 'results/supptables/S5_NB_regulome.xlsx'),
        S6t = join(DATAPATH, 'results/supptables/S6_TFactivity_across_all_signatures.xlsx'),
        S7t = join(DATAPATH, 'results/supptables/S7_crcTF_fractionObserved.xlsx'),
        S8t = join(DATAPATH, 'results/supptables/S8_RelapseVsPrimary_EnrichTFregulons.xlsx')
    params:
        script   = 'scripts/supptables/make_supptables.Rmd'
    conda: 'envs/R3.5_2.yaml'
    shell:
        """
    
        cp {params.script} {output.rmd}

        Rscript -e "rmarkdown::render( '{output.rmd}', \
                params = list( \
                  annot_t    = '{input.annot_t}', \
                  annot_c    = '{input.annot_c}', \
                  purity_t   = '{input.purity_t}', \
                  SE         = '{input.SEtarget}', \
                  go_enrich  = '{input.go_enrich}', \
                  eChIP_tumor= '{input.eChIP_tumor}', \
                  eChIP_cells= '{input.eChIP_cells}', \
                  eRNAs_tumor= '{input.eRNAs_tumor}', \
                  eRNAv_tumor= '{input.eRNAv_tumor}', \
                  Hchip_t    = '{input.Hchip_t}', \
                  Hchip_c    = '{input.Hchip_c}', \
                  Hchip_tc   = '{input.Hchip_tc}', \
                  Hrna_tt    = '{input.Hrna_tt}', \
                  Hrna_tmv   = '{input.Hrna_tmv}', \
                  NBregulome = '{input.NBregulome}', \
                  TFactivity = '{input.TFactivity}', \
                  CRCfracobs = '{input.CRCfracobs}', \
                  CRCmodules = '{input.CRCmodules}', \
                  EnrichTF   = '{input.EnrichTF}', \
                  S1  = '{output.S1t}', \
                  S2  = '{output.S2t}', \
                  S3  = '{output.S3t}', \
                  S4  = '{output.S4t}', \
                  S5  = '{output.S5t}', \
                  S6  = '{output.S6t}', \
                  S7  = '{output.S7t}', \
                  S8  = '{output.S8t}'\
                ))"

        
        
        """

#================================================================================#
#  siRNA based knockdown of putative CRCs in GIMEN and NMB cells (in house data) #
#================================================================================#

rule GIEMSA_siRNA_CRC:
    input:
        KDdata = join(DATAPATH, 'data/cells/CRCsiRNAknockdown/')
    output:
        KDresult = join(DATAPATH, 'analysis/cells/crcGIEMSAkd/nbKDinhouse.RDS')
    params:
        script  = 'scripts/analysis/08_allKDanalysis.R'
    conda: 'envs/R3.5.yaml'
    shell:
        """
        Rscript {params.script} {input.KDdata} {output.KDresult}
        """


#================================================================================#
#                                    ARACNe                                      #
#================================================================================#
#-------------------------------------------------------------------------------
# ARACNe-AP (https://github.com/califano-lab/ARACNe-AP) is used for constructing
# the transcription factor (TF) - target gene regulome network from -
#
# (1) A given gene expression matrix
# (2) List of transcription factors (can be any other regulator too)
#
# ARACNe-AP has three major sequential steps -
#
# (a) Calculate the mutual information threshold
# (b) Perform Bootstrapping
# (c) Consolidate the bootstrapping results
#-------------------------------------------------------------------------------

#==============================================================================#
#              Viper based transcription factor activity calculation           #
#==============================================================================#

rule viperTF:
    input:
        exprMat = join(DATAPATH, 'analysis/tumor/rnaseq/exprs/tumor_RNAseq_SYMBOL_TPM_Matrix_filt_log.txt'),
        regulon = join(DATAPATH, 'analysis/tumor/ARACNe/network.txt'),
        NMFexpo = join(DATAPATH, 'analysis/tumor/rnaseq/NMF/tumor_consensusSE_K4_Hmatrix_hnorm.RDS')
    output:
        network  = join(DATAPATH, 'analysis/tumor/VIPER/networkViper.txt'),
        viperout = join(DATAPATH, 'analysis/tumor/VIPER/NBpersampleTFactivity.RDS'),
        MES_activity   = join(DATAPATH, 'analysis/tumor/VIPER/MES_TFactivity.RDS'),
    params:
        script = 'scripts/analysis/07_viperTFactivity.R',
        outdir = join(DATAPATH, 'analysis/tumor/VIPER')
    conda:
        'envs/R3.5.yaml'
    shell:
        """

        # Cleaning ARACNE regulome file to make it compatible for viper
        sed '1d' {input.regulon} > {output.network}

        # Viper script
        Rscript {params.script} {input.exprMat} {output.network} {input.NMFexpo} {params.outdir}

        """

#================================================================================#
#   ARACNE-AP - Algorithm for the Reconstruction of Accurate Cellular Networks   #
#   with Adaptive Partitioning (https://doi.org/10.1093/bioinformatics/btw216)   #
#================================================================================#

rule runAracneAP:
    input:
        exprMat = join(DATAPATH, 'analysis/tumor/rnaseq/exprs/tumor_RNAseq_SYMBOL_TPM_Matrix_filt_log.txt'),
        regList = join(DATAPATH, 'db/misc/fantom5_humanTF_hg19.csv')
    output: 
        tf_list = join(DATAPATH, 'analysis/tumor/ARACNe/tf_regulators.txt'),
        network = join(DATAPATH, 'analysis/tumor/ARACNe/network.txt')
    params:
        outdir          = join(DATAPATH, 'analysis/tumor/ARACNe/'),
        aracneap        = 'bin/Aracne.jar',
        miPval          = config['ARACNe']['mi_pval_cutoff'],
        consolidatePval = config['ARACNe']['consolidation_pval_cutoff'],
        cores           = config['ARACNe']['cpus']
    conda:
        "envs/aracneap.yaml"
    shell:
        """
        
        #-----------------------------------------------------------------------
        # Cleaning TF regulators file
        #-----------------------------------------------------------------------
        tail -n +3 {input.regList} | cut -f 2 -d ',' | sed -e 's/"//g' > {output.tf_list}
        
        #-----------------------------------------------------------------------
        # Computing the mutual information threshold
        #-----------------------------------------------------------------------

        java -Xmx5G -jar {params.aracneap} \
        -e {input.exprMat} \
        --tfs {output.tf_list} \
        --pvalue {params.miPval} \
        --seed 1  \
        -o {params.outdir} \
        --calculateThreshold

        #-----------------------------------------------------------------------
        # Running 100 Bootstrapping
        #-----------------------------------------------------------------------

        for i in {{1..100}}
        do
        java -Xmx5G -jar {params.aracneap} \
        -e {input.exprMat} \
        --tfs {output.tf_list} \
        --pvalue {params.miPval} \
        --threads {params.cores}\
        --seed $i  \
        -o {params.outdir}
        done

        #-----------------------------------------------------------------------
        # Consolidating the bootstrap results
        #-----------------------------------------------------------------------

        java -Xmx5G -jar {params.aracneap} \
        -o {params.outdir} \
        --consolidate --consolidatepvalue {params.consolidatePval}

        """


rule expr_to_ARACNe:
    input:
        matrix  = join(DATAPATH, 'analysis/{type}/rnaseq/exprs/{type}_RNAseq_TPM_Matrix_filt_log.RDS')
    output:
        report  = join(DATAPATH, 'reports/06_{type}_rnaseq_expr_to_ARACNe.html'),
        rmd     = temp(join(DATAPATH, 'reports/06_{type}_rnaseq_expr_to_ARACNe.Rmd')),
        mat_sym = join(DATAPATH, 'analysis/{type}/rnaseq/exprs/{type}_RNAseq_SYMBOL_TPM_Matrix_filt_log.txt')
    params:
        script   = 'scripts/analysis/06_rnaseq_expr_to_ARACNe.Rmd',
        assayID  = '{type}_rnaseq'
    wildcard_constraints:
        type = "[a-z]+"
    conda: 'envs/R3.5.yaml'
    shell:
        """
    
        cp {params.script} {output.rmd}

        Rscript -e "rmarkdown::render( '{output.rmd}', \
                params = list( \
                  assayID       = '{params.assayID}', \
                  matrix        = '{input.matrix}', \
                  matrix_symbol = '{output.mat_sym}' \
                ))"
        
        
        """



#================================================================================#
#                        SE targets Gene Expression NMF                          #
#================================================================================#
#optK_tcc = str(config['NMFparams']['tumor_cells']['optimalK']['chipseq'])
rule NMF_report_rnaseq:
    input:
        SE_target  = join(DATAPATH, 'analysis/tumor/SE_annot/tumor_consensusSE_target_GRanges.RDS'),
        matrix     = join(DATAPATH, 'analysis/{type}/rnaseq/exprs/{type}_RNAseq_TPM_Matrix_filt_log.RDS'),
        #matrix     = join(DATAPATH, 'data/{type}/rnaseq/exprs/{type}_RNAseq_Counts_Matrix.RDS'),
        annotation = join(DATAPATH, 'annotation/annotation_{type}.RDS')
    output:
        report    = join(DATAPATH, 'reports/04_{type}_SE_targets_rnaseq_NMF_report.html'),
        rmd       = temp(join(DATAPATH, 'reports/04_{type}_SE_targets_rnaseq_NMF_report.Rmd')),
        nmf       = join(DATAPATH, 'analysis/{type}/rnaseq/NMF/{type}_consensusSE_targetExprs_NMF.RDS'),
        norm_nmfW = join(DATAPATH, 'analysis/{type}/rnaseq/NMF/{type}_consensusSE_targetExprs_normNMF_W.RDS'),
        norm_nmfH = join(DATAPATH, 'analysis/{type}/rnaseq/NMF/{type}_consensusSE_targetExprs_normNMF_H.RDS')
    params:
        script   = 'scripts/analysis/04_SE_targets_rnaseq_NMF_report.Rmd',
        assayID  = '{type}_rnaseq',
        nmf_kmin = lambda wildcards: config['NMFparams'][wildcards.type]['k.min'],
        nmf_kmax = lambda wildcards: config['NMFparams'][wildcards.type]['k.max'],
        nmf_iter = lambda wildcards: config['NMFparams'][wildcards.type]['iterations']
    wildcard_constraints:
        type = "[a-z]+"
    conda: 'envs/R3.5.yaml'
    shell:
        """
        #unset LD_LIBRARY_PATH
        #export PATH="/usr/local/cuda/bin:$PATH"
        #nvidia-smi
    
        cp {params.script} {output.rmd}

        Rscript -e "rmarkdown::render( '{output.rmd}', \
                params = list( \
                  assayID   = '{params.assayID}', \
                  nmf_kmin  = '{params.nmf_kmin}', \
                  nmf_kmax  = '{params.nmf_kmax}', \
                  nmf_iter  = '{params.nmf_iter}', \
                  nmf       = '{output.nmf}', \
                  norm_nmfW = '{output.norm_nmfW}', \
                  norm_nmfH = '{output.norm_nmfH}', \
                  matrix    = '{input.matrix}', \
                  SE        = '{input.SE_target}', \
                  metadata  = '{input.annotation}' \
                ))"
        
        
        """

rule NMF_report_rnaseq_mostVariable:
    input:
        SE_target  = join(DATAPATH, 'analysis/tumor/SE_annot/tumor_consensusSE_target_GRanges.RDS'),
        #matrix     = join(DATAPATH, 'data/{type}/rnaseq/exprs/{type}_RNAseq_Counts_Matrix.RDS'),
        matrix     = join(DATAPATH, 'analysis/{type}/rnaseq/exprs/{type}_RNAseq_TPM_Matrix_filt_log.RDS'),
        annotation = join(DATAPATH, 'annotation/annotation_{type}.RDS')
    output:
        report    = join(DATAPATH, 'reports/05_{type}_mostVariable_rnaseq_NMF_report.html'),
        rmd       = temp(join(DATAPATH, 'reports/05_{type}_mostVariable_rnaseq_NMF_report.Rmd')),
        nmf       = join(DATAPATH, 'analysis/{type}/rnaseq/NMF_mostVariable/{type}_mostVariable_NMF.RDS'),
        norm_nmfW = join(DATAPATH, 'analysis/{type}/rnaseq/NMF_mostVariable/{type}_mostVariable_normNMF_W.RDS'),
        norm_nmfH = join(DATAPATH, 'analysis/{type}/rnaseq/NMF_mostVariable/{type}_mostVariable_normNMF_H.RDS')
    params:
        script   = 'scripts/analysis/05_mostVariable_rnaseq_NMF_report.Rmd',
        assayID  = '{type}_rnaseq',
        nmf_kmin = lambda wildcards: config['NMFparams'][wildcards.type]['k.min'],
        nmf_kmax = lambda wildcards: config['NMFparams'][wildcards.type]['k.max'],
        nmf_iter = lambda wildcards: config['NMFparams'][wildcards.type]['iterations']
    wildcard_constraints:
        type = "[a-z]+"
    conda: 'envs/R3.5.yaml'
    shell:
        """
        #unset LD_LIBRARY_PATH
        #export PATH="/usr/local/cuda/bin:$PATH"
        #nvidia-smi
    
        cp {params.script} {output.rmd}

        Rscript -e "rmarkdown::render( '{output.rmd}', \
                params = list( \
                  assayID   = '{params.assayID}', \
                  nmf_kmin  = '{params.nmf_kmin}', \
                  nmf_kmax  = '{params.nmf_kmax}', \
                  nmf_iter  = '{params.nmf_iter}', \
                  nmf       = '{output.nmf}', \
                  norm_nmfW = '{output.norm_nmfW}', \
                  norm_nmfH = '{output.norm_nmfH}', \
                  matrix    = '{input.matrix}', \
                  SE        = '{input.SE_target}', \
                  metadata  = '{input.annotation}' \
                ))"
        
        
        """

#================================================================================#
#                              SE ChIPseq Signal NMF                             #
#================================================================================#
optK_tcc = str(config['NMFparams']['tumor_cells']['optimalK']['chipseq'])
rule NMF_report_chipseq_tumor_cells:
    input:
        matrix      = join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/consensusSE/tumor_cells_H3K27ac_noH3K4me3_consensusSE_SignalScore.RDS'),
        annot_tumor = join(DATAPATH, 'annotation/annotation_tumor.RDS'),
        annot_cells = join(DATAPATH, 'annotation/annotation_cells.RDS')
    output:
        report    = join(DATAPATH, 'reports/03_tumor_cells_chipseq_NMF_report.html'),
        rmd       = temp(join(DATAPATH, 'reports/03_tumor_cells_chipseq_NMF_report.Rmd')),
        nmf       = join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/NMF/tumor_cells_consensusSE_SignalScore_NMF.RDS'),
        norm_nmfW = join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/NMF/tumor_cells_consensusSE_SignalScore_normNMF_W.RDS'),
        norm_nmfH = join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/NMF/tumor_cells_consensusSE_SignalScore_normNMF_H.RDS'),
        hmatrix_wnorm = join(DATAPATH, ('analysis/tumor_cells/chipseq/H3K27ac/NMF/tumor_cells_consensusSE_K' + optK_tcc + '_Hmatrix_wnorm.RDS')),
        wmatrix_wnorm = join(DATAPATH, ('analysis/tumor_cells/chipseq/H3K27ac/NMF/tumor_cells_consensusSE_K' + optK_tcc + '_Wmatrix_Wnorm.RDS')),
        nmf_features  = join(DATAPATH, ('analysis/tumor_cells/chipseq/H3K27ac/NMF/tumor_cells_consensusSE_K' + optK_tcc + '_NMF_features.RDS')),
        hmatrix_hnorm = join(DATAPATH, ('analysis/tumor_cells/chipseq/H3K27ac/NMF/tumor_cells_consensusSE_K' + optK_tcc + '_Hmatrix_hnorm.RDS'))
    params:
        script   = 'scripts/analysis/03_tumor_cells_chipseq_NMF_report.Rmd',
        assayID  = 'tumor_cells_chipseq',
        nmf_kmin = config['NMFparams']['tumor_cells']['k.min'],
        nmf_kmax = config['NMFparams']['tumor_cells']['k.max'],
        nmf_iter = config['NMFparams']['tumor_cells']['iterations'],
        optimalK = optK_tcc
    conda: 'envs/R3.5.yaml'
    shell:
        """
    
        cp {params.script} {output.rmd}

        Rscript -e "rmarkdown::render( '{output.rmd}', \
                params = list( \
                  assayID     = '{params.assayID}', \
                  annot_tumor = '{input.annot_tumor}', \
                  annot_cells = '{input.annot_cells}', \
                  nmf_kmin  = '{params.nmf_kmin}', \
                  nmf_kmax  = '{params.nmf_kmax}', \
                  nmf_iter  = '{params.nmf_iter}', \
                  nmf       = '{output.nmf}', \
                  norm_nmfW = '{output.norm_nmfW}', \
                  norm_nmfH = '{output.norm_nmfH}', \
                  matrix    = '{input.matrix}', \
                  K         = {params.optimalK}, \
                  hmatrix_wnorm = '{output.hmatrix_wnorm}', \
                  wmatrix_wnorm = '{output.wmatrix_wnorm}', \
                  nmf_features  = '{output.nmf_features}', \
                  hmatrix_hnorm = '{output.hmatrix_hnorm}' \
                ))"
        
        
        """


rule NMF_report_chipseq:
    input:
        matrix     = join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/consensusSE/{type}_H3K27ac_noH3K4me3_consensusSE_SignalScore.RDS'),
        annotation = join(DATAPATH, 'annotation/annotation_{type}.RDS')
    output:
        report    = join(DATAPATH, 'reports/03_{type}_chipseq_NMF_report.html'),
        rmd       = temp(join(DATAPATH, 'reports/03_{type}_chipseq_NMF_report.Rmd')),
        nmf       = join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/NMF/{type}_consensusSE_SignalScore_NMF.RDS'),
        norm_nmfW = join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/NMF/{type}_consensusSE_SignalScore_normNMF_W.RDS'),
        norm_nmfH = join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/NMF/{type}_consensusSE_SignalScore_normNMF_H.RDS')
    params:
        script   = 'scripts/analysis/03_chipseq_NMF_report.Rmd',
        assayID  = '{type}_chipseq',
        workdir  = join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/NMF/'),
        nmf_kmin = lambda wildcards: config['NMFparams'][wildcards.type]['k.min'],
        nmf_kmax = lambda wildcards: config['NMFparams'][wildcards.type]['k.max'],
        nmf_iter = lambda wildcards: config['NMFparams'][wildcards.type]['iterations']
    wildcard_constraints:
        type = "[a-z]+"
    conda: 'envs/R3.5.yaml'
    shell:
        """
        #unset LD_LIBRARY_PATH
        #export PATH="/usr/local/cuda/bin:$PATH"
        #nvidia-smi
    
        cp {params.script} {output.rmd}

        Rscript -e "rmarkdown::render( '{output.rmd}', \
                params = list( \
                  assayID   = '{params.assayID}', \
                  work_dir  = '{params.workdir}', \
                  nmf_kmin  = '{params.nmf_kmin}', \
                  nmf_kmax  = '{params.nmf_kmax}', \
                  nmf_iter  = '{params.nmf_iter}', \
                  nmf       = '{output.nmf}', \
                  norm_nmfW = '{output.norm_nmfW}', \
                  norm_nmfH = '{output.norm_nmfH}', \
                  matrix    = '{input.matrix}', \
                  metadata  = '{input.annotation}' \
                ))"
        
        
        """


#================================================================================#
#                                  SE target genes                               #
#================================================================================#
# Finds SE target gene, also saves RNAseq expression matrix (TPMs) for tumor and cells
rule SE_target_genes:
    input:
        tumor_annot    = join(DATAPATH, 'annotation/annotation_tumor.RDS'),
        SE_bed         = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE.bed'),
        hichip_SK_N_AS = join(DATAPATH, 'data/cells/hichip/mango/SK-N-AS_HiChIP_mango.all'),
        hichip_CLB_GA  = join(DATAPATH, 'data/cells/hichip/mango/CLB-GA_HiChIP_mango.all'),
        SE_signal      = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE_SignalScore.RDS'),
        gene_exprs     = join(DATAPATH, 'data/tumor/rnaseq/exprs/tumor_RNAseq_TPM_Matrix.RDS'),
        gene_exprs_cl  = join(DATAPATH, 'data/cells/rnaseq/exprs/cells_RNAseq_TPM_Matrix.RDS'),
        hic            = join(DATAPATH, 'db/hic/GSE63525_K562_HiCCUPS_looplist.txt'),
        TADs           = join(DATAPATH, 'db/TADs/hESC_domains_hg19.RDS'),
        hsapiens_genes = join(DATAPATH, 'db/misc/EnsDb_Hsapiens_v75_genes.RDS')
    output:
        report          = join(DATAPATH, 'reports/02_SE_target_genes_report.html'),
        rmd             = temp(join(DATAPATH, 'reports/02_SE_target_genes_report.Rmd')),
        SE_target       = join(DATAPATH, 'analysis/tumor/SE_annot/tumor_consensusSE_target_GRanges.RDS'),
        SE_target_df    = join(DATAPATH, 'analysis/tumor/SE_annot/tumor_consensusSE_target_annotation_df.RDS'),
        tumor_exprs_fil = join(DATAPATH, 'analysis/tumor/rnaseq/exprs/tumor_RNAseq_TPM_Matrix_filt_log.RDS'),
        cells_exprs_fil = join(DATAPATH, 'analysis/cells/rnaseq/exprs/cells_RNAseq_TPM_Matrix_filt_log.RDS')
    params:
        script   = 'scripts/analysis/02_SE_target_genes.Rmd',
        workdir  = DATAPATH
    conda: 'envs/R3.5.yaml'
    shell:
        """
        #unset LD_LIBRARY_PATH
        #export PATH="/usr/local/cuda/bin:$PATH"
        #nvidia-smi
    
        cp {params.script} {output.rmd}

        Rscript -e "rmarkdown::render( '{output.rmd}', \
            params = list( \
                work_dir       = '{params.workdir}', \
                tumor_annot    = '{input.tumor_annot}', \
                SE             = '{input.SE_bed}', \
                hichip_SK_N_AS = '{input.hichip_SK_N_AS}', \
                hichip_CLB_GA  = '{input.hichip_CLB_GA}', \
                SE_signal      = '{input.SE_signal}', \
                gene_exprs     = '{input.gene_exprs}', \
                hic            = '{input.hic}', \
                TADs           = '{input.TADs}', \
                hsapiens_genes = '{input.hsapiens_genes}', \
                SE_target_gr   = '{output.SE_target}', \
                gene_exprs_cells     = '{input.gene_exprs_cl}', \
                tumor_exprs_filtered = '{output.tumor_exprs_fil}', \
                cells_exprs_filtered = '{output.cells_exprs_fil}' \
                ))"
        
        
        """


#================================================================================#
#                     SE signal bigWig AVERAGE OVER BED                          #
#================================================================================#
### Computes the SE average score signal for tumors and cells
rule SE_SignalMatrix_combined:
    input:
        averageOverBed_tumor = expand((DATAPATH + 'analysis/tumor/chipseq/H3K27ac/consensusSE/{sample}_H3K27ac_bigWigAverageOverBed.txt'), zip, sample = TUMOR_SAMPLES_CHIP),
        averageOverBed_cells = expand((DATAPATH + 'analysis/cells/chipseq/H3K27ac/consensusSE/{sample}_H3K27ac_bigWigAverageOverBed.txt'), zip, sample = CELLS_SAMPLES_CHIP),
        consensusSE          = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE.bed')
    output: 
        matrix_rds = join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/consensusSE/tumor_cells_H3K27ac_noH3K4me3_consensusSE_SignalScore.RDS'),
        matrix_txt = join(DATAPATH, 'analysis/tumor_cells/chipseq/H3K27ac/consensusSE/tumor_cells_H3K27ac_noH3K4me3_consensusSE_SignalScore.txt')
    params:
        script = 'scripts/analysis/01_SEmatrix.R'
    conda:
        'envs/R3.5.yaml'
    shell:
        """
        Rscript {params.script} {output.matrix_rds} {output.matrix_txt} {input.consensusSE} {input.averageOverBed_tumor} {input.averageOverBed_cells}
        """


### Computes the SE average score signal for tumors or cells
def find_bwAverage(wildcards):
    SAMPLES = TUMOR_SAMPLES_CHIP if wildcards.type == "tumor" else CELLS_SAMPLES_CHIP
    averageOverBed = expand((DATAPATH + 'analysis/' + wildcards.type + '/chipseq/H3K27ac/consensusSE/{sample}_H3K27ac_bigWigAverageOverBed.txt'), zip, sample = SAMPLES)
    #print(wildcards.type)
    #print(averageOverBed)
    return averageOverBed
    
rule SE_SignalMatrix:
    input:
        averageOverBed_path = find_bwAverage,
        consensusSE         = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE.bed')
    output: 
        matrix_rds = join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/consensusSE/{type}_H3K27ac_noH3K4me3_consensusSE_SignalScore.RDS'),
        matrix_txt = join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/consensusSE/{type}_H3K27ac_noH3K4me3_consensusSE_SignalScore.txt')
    params:
        script = 'scripts/analysis/01_SEmatrix.R'
    wildcard_constraints:
        type = "[a-z]+"
    conda:
        'envs/R3.5.yaml'
    shell:
        """
        Rscript {params.script} {output.matrix_rds} {output.matrix_txt} {input.consensusSE} {input.averageOverBed_path}
        """


### Computes the average score over each bed for tumors
rule SE_bigwigaverageoverbed:
    input:
        hsapiens_genes = join(DATAPATH, 'db/misc/EnsDb_Hsapiens_v75_genes.RDS'),
        bw             = join(DATAPATH, 'data/{type}/chipseq/H3K27ac/bw/{sample}_H3K27ac.bw'), 
        consensusSE    = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE.bed')
    output:
        bw_over_bed    = join(DATAPATH, 'analysis/{type}/chipseq/H3K27ac/consensusSE/{sample}_H3K27ac_bigWigAverageOverBed.txt')
    conda:
        'envs/generaltools.yaml'
    shell:
        """
        # Compute the average score of the SES_substract.bw bigWig over the noH3K4me3 consensus SE
        bigWigAverageOverBed {input.bw} {input.consensusSE} {output.bw_over_bed}
        """


#================================================================================#
#              CELL LINES CONSENSUS SUPER ENHANCERS  FILTER H3K4me3              #
#================================================================================#
### Compute consensus SE list from SE called by rose for each sample after H3K4me3 filtering
rule cells_consensus_SE_noH3K4me3:
    input:
        seH3K27ac_noH3K4me3 = expand(join(DATAPATH, 'data/cells/chipseq/H3K27ac/SE/{sample}_H3K27ac_ROSE_noH3K4me3_SuperEnhancers.bed'), zip, sample=CELLS_SAMPLES_CHIP)
    output:
        consensusbed        = join(DATAPATH, 'analysis/cells/chipseq/H3K27ac/consensusSE/cells_H3K27ac_noH3K4me3_consensusSE.bed')
    conda:
        'envs/generaltools.yaml'
    shell:
        """
        # Merge all SE
        cat {input.seH3K27ac_noH3K4me3}| sortBed | bedtools merge -c 4,4 -o distinct,count_distinct | 
        awk '$5 > 1' |sed -e 's/$/\tcellSE_/' | sed -n 'p;=' |
        paste -d "" - - | awk 'BEGIN{{FS="\t";OFS="\t"}} {{ t = $4; $4 = $6; $6 = t; print;}} ' > {output.consensusbed}
        """


#================================================================================#
#                TUMORS CONSENSUS SUPER ENHANCERS  FILTER H3K4me3                #
#================================================================================#
### Compute consensus SE list from SE called by rose for each sample after H3K4me3 filtering
rule tumors_consensus_SE_noH3K4me3:
    input:
        seH3K27ac_noH3K4me3 = expand(join(DATAPATH, 'data/tumor/chipseq/H3K27ac/SE/{sample}_H3K27ac_ROSE_noH3K4me3_SuperEnhancers.bed'), zip, sample=TUMOR_SAMPLES_CHIP)
    output:
        consensusbed        = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE.bed')
    conda:
        'envs/generaltools.yaml'
    shell:
        """
        # Merge all SE
        cat {input.seH3K27ac_noH3K4me3}| sortBed | bedtools merge -c 4,4 -o distinct,count_distinct | 
        awk '$5 > 1' |sed -e 's/$/\tSE_/' | sed -n 'p;=' |
        paste -d "" - - | awk 'BEGIN{{FS="\t";OFS="\t"}} {{ t = $4; $4 = $6; $6 = t; print;}} ' > {output.consensusbed}
        """



#================================================================================#
#    Download auxiliary data and install missing R packages in conda env         #
#================================================================================#



# Download and preprocessing of TCGA, TARGET and GTex data

rule TCGA_TARGET_Gtex_Download:
    output:
        expr = join(DATAPATH, 'db/TCGA_TARGET_GTex/TcgaTargetGtex_log2_fpkm.RDS'),
        samp = join(DATAPATH, 'db/TCGA_TARGET_GTex/TcgaTargetGtex_sample_information.RDS')
    params:
        allExpr  = 'https://toil.xenahubs.net/download/TcgaTargetGtex_rsem_gene_tpm.gz',
        sampDesp = 'https://toil.xenahubs.net/download/TcgaTargetGTEX_phenotype.txt.gz',
        geneAnno = 'https://toil.xenahubs.net/download/probeMap/gencode.v23.annotation.gene.probemap',
        script   = 'scripts/aux/TCGA_TARGET_GTeX_data_download_and_processing.R',
        outpath  = join(DATAPATH, 'db/')
    conda: 'envs/R3.5_2.yaml'
    shell:
        """
        Rscript {params.script} {params.allExpr} {params.sampDesp} {params.geneAnno} {params.outpath}
        """


# Download and preprocessing of super enhancers from multiple tissues

rule SEDownload:
    output:
        SEdir   = directory(join(DATAPATH, 'db/SEmultiTisuues/'))
    params:
        urlSErange = 'https://www.cell.com/cms/10.1016/j.cell.2013.09.053/attachment/c44ace85-27a5-4f4f-b7e4-db375a76f583/mmc7.zip',
        urlSEdesp  = 'https://ars.els-cdn.com/content/image/1-s2.0-S0092867413012270-mmc2.xlsx',
        script     = 'scripts/aux/download_super_enhancers_multiple_tissues.R',
        outpath    = join(DATAPATH, 'db/')
    conda: 'envs/R3.5.yaml'
    shell:
        """
        Rscript {params.script} {params.urlSErange} {params.urlSEdesp} {params.outpath}
        """


# Download and preprocessing of DeepMap cell-line data

rule DeepMapDownload:
    output:
        desp = join(DATAPATH, 'db/DeepMap19Q2/README.txt'),
        anno = join(DATAPATH, 'db/DeepMap19Q2/cellAnnotation.RDS'),
        expr = join(DATAPATH, 'db/DeepMap19Q2/cellExpression.RDS'),
        kval = join(DATAPATH, 'db/DeepMap19Q2/cellKnockdownCERES.RDS'),
        kpro = join(DATAPATH, 'db/DeepMap19Q2/cellKnockdownProb.RDS')
    params:
        projDesp = "https://ndownloader.figshare.com/files/15023474",
        cellAnno = "https://ndownloader.figshare.com/files/15023525",
        cellExpr = "https://ndownloader.figshare.com/files/15023486",
        valsKD   = "https://ndownloader.figshare.com/files/15023465",
        probsKD  = "https://ndownloader.figshare.com/files/15023459",
        script   = 'scripts/aux/processDeepMap.R',
        outpath  = join(DATAPATH, 'db/')
    conda: 'envs/R3.5.yaml'
    shell:
        """
        Rscript {params.script} {params.projDesp} {params.cellAnno} {params.cellExpr} {params.valsKD} {params.probsKD} {params.outpath}
        """

# Download and preprocessing of RAS target genes

rule RAS_Download:
    output:
        rasrds = join(DATAPATH, 'db/publicGeneSigs/ras_target_genes.RDS')
    params:
        urlras = 'https://static-content.springer.com/esm/art%3A10.1186%2F1755-8794-3-26/MediaObjects/12920_2010_161_MOESM3_ESM.XLS',
        script  = 'scripts/aux/download_RAS_signature.R',
        outpath = join(DATAPATH, 'db/')
    conda: 'envs/R3.5.yaml'
    shell:
        """
        Rscript {params.script} {params.urlras} {params.outpath}
        """


# Download HiC data and H. sapiens genes GRanges

rule down_misc_install_missing_R:
    output:
        hsapiens_genes = join(DATAPATH, 'db/misc/EnsDb_Hsapiens_v75_genes.RDS'),
        hic_K562       = join(DATAPATH, 'db/hic/GSE63525_K562_HiCCUPS_looplist.txt'),
        tads           = join(DATAPATH, 'db/TADs/hESC_domains_hg19.RDS')
    params:
        script  = 'scripts/aux/missing_packages_and_aux_data.R',
        workdir = DATAPATH
    conda: 'envs/R3.5.yaml'
    shell:
        """
        
        #unset LD_LIBRARY_PATH
        #export PATH="/usr/local/cuda/bin:$PATH"
        #nvidia-smi
        #conda install openssl=1.0
        
        Rscript {params.script} {params.workdir} {output.hsapiens_genes} {output.hic_K562} {output.tads}
        #git clone https://github.com/cudamat/cudamat.git
        #pip install cudamat/
        #rm -rf cudamat
        
        """


