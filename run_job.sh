#!/bin/bash
#
# This script runs a test_bed simulation with some defined arguments in the slurm HPCs
#
# To run under quincy/contrib/test_bed/
# It does require a template_land folder. It can be recreated by running a simple test_bed. Then remove the outputs and the binary.
#

set -eux

set_option() {
  KEY=$1
  VAL=$2
  CFGNAME=$3
  sed -i -e "/$KEY[ ]*=/ s/=.*/=$VAL/" $CFGNAME
}

run_quincy() {
  SNAME=$1
  NYEARS=$2
  NPFT=$3
  AREABURNED=$4
  CFG="namelist.slm"

  SFOLDER="${SNAME}_${NYEARS}y_pft${NPFT}"

  cp -R template_land/ ${SFOLDER}
  # copy latest binary
  cp ../../x86_64-gfortran/bin/land.x ${SFOLDER}/land.x
  # go to the exps folder
  cd ${SFOLDER}

  # change several namelist.slm options
  set_option "simulation_length_number" ${NYEARS} ${CFG}
  set_option "plant_functional_type_id" ${NPFT} ${CFG}
  set_option "area_burned_fract" ${AREABURNED} ${CFG}

  cat <<EOT >> job.sh
#!/bin/bash

#SBATCH --job-name=${SNAME}
#SBATCH --ntasks=1
#SBATCH --time=0-01:00:00
#SBATCH --output=s-%x.%j.out
#SBATCH --error=s-%x.%j.err

./land.x
EOT

echo "Launching job..."
sbatch job.sh
}

# add your simulations here
run_quincy "aburned5" 50 4 "0.5"
run_quincy "aburned05" 50 4 "0.05"
run_quincy "aburned005" 50 4 "0.005"
run_quincy "aburned0005" 50 4 "0.0005"
