# Bioconductor on Apollo

This repository provides a `Dockerfile` that extends the official [Bioconductor Docker](https://bioconductor.org/help/docker/) image by adding a few system packages and the HPC job scheduler SLURM. GitHub actions build the image and push it to GitHub Packages.

Provides Bioconductor version: **3.14**

It can be built for the HPC with:

```
 module load singualrity   
 singularity pull rstudio-rbioc.img docker://ghcr.io/drejom/rstudio-rbioc:main
```

And launched on the HPC by:
```
sbatch /opt/singularity-images/rbioc/rstudio.job
```
