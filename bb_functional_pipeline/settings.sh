#!/usr/bin/env bash

## Default is fsl/5.0.11

module unload fsl
module load fsl/5.0.10
which fsl

module load fsl/fix/1.06.15

#module unload python; module load python/canopy2/2.7
which python

export MATLAB=/cbica/software/external/matlab/R2014B
export FSLOUTPUTTYPE=NIFTI_GZ
export FSL_FIXDIR=/cbica/software/external/fsl/fix/1.06.15

#export BB_BIN_DIR=/cbica/home/srinivad/istaging_data_consolidation/Representation/fMRI/UK_biobank_pipeline_v_1

#export FSLNets=${BB_BIN_DIR}/FSLNets

#export templ=${BB_BIN_DIR}/templates
#export PATH=${BB_BIN_DIR}/bb_pipeline_tools:$PATH
##FSLPARALLEL=0; export FSLPARALLEL
#unset SGE_ROOT
#export FSLSUBALREADYRUN=true


export FSL_FIXDIR=/cbica/software/external/fsl/fix/1.06.15
export MCRROOT=/cbica/software/external/matlab/R2018A
LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64;
export LD_LIBRARY_PATH;

