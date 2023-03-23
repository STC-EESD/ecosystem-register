#!/bin/bash

currentDIR=`pwd`
   codeDIR=${currentDIR}/code
 outputDIR=${currentDIR//github/gittmp}/output

parentDIR=`dirname ${currentDIR}`
  dataDIR=${parentDIR}/000-data

if [ ! -d ${outputDIR} ]; then
    mkdir -p ${outputDIR}
fi

cp -r ${codeDIR} ${outputDIR}
cp    $0         ${outputDIR}/code

########################################################
source ${HOME}/.gee_environment_variables
if [[ "${OSTYPE}" =~ .*"linux".* ]]; then
  # cp ${HOME}/.gee_environment_variables ${outputDIR}/code/gee_environment_variables.txt
  pythonBinDIR=${GEE_ENV_DIR}/bin
  RBinDIR=${pythonBinDIR}
else
  pythonBinDIR=`which python`
  pythonBinDIR=${pythonBinDIR//\/python/}
  RBinDIR=`which R`
  RBinDIR=${RBinDIR//\/R/}
fi

########################################################
googleDriveFolder=earthengine/ken
resolution=9

########################################################
# myPythonScript=${codeDIR}/main-generate-grids.py
# stdoutFile=${outputDIR}/stdout.py.`basename ${myPythonScript} .py`
# stderrFile=${outputDIR}/stderr.py.`basename ${myPythonScript} .py`
# ${pythonBinDIR}/python ${myPythonScript} ${dataDIR} ${codeDIR} ${outputDIR} ${googleDriveFolder} > ${stdoutFile} 2> ${stderrFile}
# sleep 2

##################################################
# myRscript=${codeDIR}/main-get-extent-point-rHEALPix-planar.R
# stdoutFile=${outputDIR}/stdout.R.`basename ${myRscript} .R`
# stderrFile=${outputDIR}/stderr.R.`basename ${myRscript} .R`
# ${RBinDIR}/R --no-save --args ${dataDIR} ${codeDIR} ${outputDIR} ${googleDriveFolder} ${resolution} < ${myRscript} > ${stdoutFile} 2> ${stderrFile}
# sleep 2

########################################################
# myPythonScript=${codeDIR}/main-get-extent-grid-rHEALPix-planar.py
# stdoutFile=${outputDIR}/stdout.py.`basename ${myPythonScript} .py`
# stderrFile=${outputDIR}/stderr.py.`basename ${myPythonScript} .py`
# ${pythonBinDIR}/python ${myPythonScript} ${dataDIR} ${codeDIR} ${outputDIR} ${googleDriveFolder} ${resolution} > ${stdoutFile} 2> ${stderrFile}
# sleep 2

##################################################
# myRscript=${codeDIR}/main-reproject.R
# stdoutFile=${outputDIR}/stdout.R.`basename ${myRscript} .R`
# stderrFile=${outputDIR}/stderr.R.`basename ${myRscript} .R`
# ${RBinDIR}/R --no-save --args ${dataDIR} ${codeDIR} ${outputDIR} ${googleDriveFolder} ${resolution} < ${myRscript} > ${stdoutFile} 2> ${stderrFile}
# sleep 2

##################################################
myRscript=${codeDIR}/main-crop-image.R
stdoutFile=${outputDIR}/stdout.R.`basename ${myRscript} .R`
stderrFile=${outputDIR}/stderr.R.`basename ${myRscript} .R`
${RBinDIR}/R --no-save --args ${dataDIR} ${codeDIR} ${outputDIR} ${googleDriveFolder} ${resolution} < ${myRscript} > ${stdoutFile} 2> ${stderrFile}
# sleep 2

##################################################
exit

