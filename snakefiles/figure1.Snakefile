#==============================================================================#
#            Analysis and figures included in manuscript figure 1              #
#==============================================================================#


rule compile_figure1:
    input:
        #figure1a = join(DATAPATH, 'results/figure1/figure1a_tumor_SE_hmatrix.pdf'),
        #figure1b = join(DATAPATH, 'results/figure1/figure1b_cells_SE_hmatrix.pdf'),
        #figure1c = join(DATAPATH, 'results/figure1/figure1c_tumor_cells_SE_UMAP.pdf'),
        #figure1d = join(DATAPATH, 'results/figure1/figure1d_01_tumor_riverplot.pdf'),
        figure1e = join(DATAPATH, 'results/figure1/figure1e_IGV_plot.pdf')
    output: join(DATAPATH, 'results/figure1/figure1_paths.txt')
    shell:
        """
        touch {output}
        #echo 'Figure 1a {input.figure1e}' >> {output}
        #echo 'Figure 1b {input.figure1e}' >> {output}
        #echo 'Figure 1c {input.figure1e}' >> {output}
        #echo 'Figure 1d {input.figure1e}' >> {output}
        echo 'Figure 1e {input.figure1e}' >> {output}
        
        """



#================================================================================#
#                      Figure 4i - VSNL1 loci                                    #
#================================================================================#
rule fig1e_IGV:
    input:
        consensusSE = join(DATAPATH, 'analysis/tumor/chipseq/H3K27ac/consensusSE/tumor_H3K27ac_noH3K4me3_consensusSE.bed')
    output:
        report = join(DATAPATH, 'reports/figure1e_IGV_plot.html'),
        rmd    = temp(join(DATAPATH, 'reports/figure1e_IGV_plot.Rmd')),
        figure = join(DATAPATH, 'results/figure1/figure1e_IGV_plot.pdf')
    params:
        script       = 'scripts/figure1/figure1e_IGV_plot.Rmd',
        work_dir     = DATAPATH,
        path_config  = join(os.getcwd(), 'scripts/figure1/figure1e_tracks.txt'),
        window   = config['igv_plot']['figure1e']['window'],
        ymax     = config['igv_plot']['figure1e']['ymax'],
        gr_chr   = config['igv_plot']['figure1e']['chr'],
        gr_start = config['igv_plot']['figure1e']['start'],
        gr_end   = config['igv_plot']['figure1e']['end'],
        gr_name  = config['igv_plot']['figure1e']['name']
    conda: '../envs/R3.5.yaml'
    shell:
        """
        cp {params.script} {output.rmd}

        Rscript -e "rmarkdown::render( '{output.rmd}', \
                params = list( \
                  work_dir     = '{params.work_dir}', \
                  path_config  = '{params.path_config}', \
                  width_window = {params.window}, \
                  ymax  = '{params.ymax}', \
                  chr   = '{params.gr_chr}', \
                  start = {params.gr_start}, \
                  end   = {params.gr_end}, \
                  name  = '{params.gr_name}', \
                  figure = '{output.figure}' \
                ))"


        """
