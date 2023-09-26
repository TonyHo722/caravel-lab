# for setup caravel-lab and execution run_la_test1, please refence below sequence
- run_la_test1 - Integrate a gcd exmaple RTL design to Caravel SoC
- run_fsic - Integrate a fsic RTL design to Caravel SoC
- please reference [bol-edu/caravel-lab](https://github.com/bol-edu/caravel-lab) for more tail information in caravel-lab

# 1. Download docket image(efabless/mpw_precheck) 
- this image is not found in docker server when build caravel_user_project. reference [this link](https://hackmd.io/@TonyHo/rJ1GU-xCh) for the detail
## Download docket image by web browser
down mpw_precheck_mpw8c.tgz (the docker image is comefrom the machine run the carave_user_project building flow on Jan 2023)
```
https://1drv.ms/u/s!AtJnzpDx-p62g-dAl5zpqggRKWwDPQ?e=HV49jl
```
![](https://hackmd.io/_uploads/Hyj6XmEA3.png)

## load the docker image and add tag for the docker image
```
$ gunzip -c mpw_precheck_mpw8c.tgz | docker load
$ docker tag eca176d9adb3 efabless/mpw_precheck:mpw8c
```
- show the docker image afer add tag on it.

```
$ docker images
```
![](https://hackmd.io/_uploads/BkxoNS7VA3.png)

# 2. set PATH for volare to avoid "make setup" report error
```
$ export PATH=$PATH:~/.local/bin
```
- error log for "make setup"
```
    make[1]: *** [/home/tonyho/workspace/debug/la_test1/caravel_user_project/caravel/Makefile:1226: pdk-with-volare] Error 127
    make: *** [Makefile:84: pdk-with-volare] Error 2
    
```

# 3. git clone & execution run_la_test1

```
$ git clone https://github.com/TonyHo722/caravel-lab
```

# 4. execution run_la_test1

## 4.1 edit bash_auto/run_la_test1
```
$ cd caravel-lab/bash_auto
$ gedit run_la_test1
```
- update your main folder path
```
# setup your main folder(MF)
export MF=/ADATA2T/debug/la_test1_0921
```
[run_la_test1 link](https://github.com/TonyHo722/caravel-lab/blob/e6a32d27a64c1ec3fb76040307d5f4cae207c53d/bash_auto/run_la_test1#L14)


## 4.2 mkdir your main folder
```
$ mkdir /ADATA2T/debug/la_test1_0921
```
## 4.3 execution run_la_test1 and save log file
```
$ ./run_la_test1 2>&1 | tee run_la_test1.log
```
### [run_la_test1](https://github.com/TonyHo722/caravel-lab/blob/e6a32d27a64c1ec3fb76040307d5f4cae207c53d/bash_auto/run_la_test1) as below

```
#!/bin/bash

on_error(){
  echo "error occurred"
  exit 1
}

# enable trap for detect error
trap 'on_error' ERR

set -x # echo on for debug 

# setup your main folder(MF)
export MF=/ADATA2T/debug/la_test1_0921

# setup your fsic_fpga folder(FFF)
#export FFF=/home/tonyho/workspace/fsic/fsic_fpga

# setup your fsic_asic folder(FFF)
#export FAF=/home/tonyho/workspace/fsic/fsic_asic

# setup your PRECHECK_ROOT 
export PRECHECK_ROOT=$MF/mpw_precheck
# setup your log folder(LF)
export LF=$MF/log-0919
# setup your caravel-lab folder(CLF)
export CLF=$MF/caravel-lab
# setup your caravel_user_project folder(CUPF)
export CUPF=$MF/caravel_user_project

if [ ! -d "$MF" ] ;
then
    echo "$MF not exist, please create it"
    exit 1
fi    
cd $MF

[ ! -d $LF ] && echo "$LF not exist, create it" && mkdir $LF
[ -d $CLF ] && echo "$CLF exist, remove it" && rm -rf $CLF
[ ! -d $CLF ] && echo "$CLF not exist, git clone it" && git clone https://github.com/TonyHo722/caravel-lab
[ ! -d $CUPF ] && echo "$CUPF not exist, git clone it" && git clone -b mpw-8c-patch https://github.com/TonyHo722/caravel_user_project

#cd $FFF
#git log -1 2>&1 | tee $LF/mpw-8c-FFF-git-log.log
#cd $FAF
#git log -1 2>&1 | tee $LF/mpw-8c-FAF-git-log.log
cd $CLF
git log -1 2>&1 | tee $LF/mpw-8c-CLF-git-log.log
cd $CUPF
git log -1 2>&1 | tee $LF/mpw-8c-CUPF-git-log.log

[ ! -d $CUPF/dependencies] && echo "$CLF/dependencies not exist, create it" && mkdir $CLF/dependencies
export OPENLANE_ROOT=$(pwd)/dependencies/openlane_src
export PDK_ROOT=$(pwd)/dependencies/pdks
export PDK=sky130A

[ ! -d $CUPF/caravel ] && echo "$CUPF/caravel not exist, run make setup" && make -d setup 2>&1 | tee $LF/mpw-8c-make-steup.log

# copy file for user_project_wrapper.v
cp $CLF/custom_design/gcd/user_proj_example/user_project_wrapper.v $CUPF/verilog/rtl/user_project_wrapper.v
# copy file for user_proj_example.v
cp $CLF/custom_design/gcd/user_proj_example/user_proj_example.v $CUPF/verilog/rtl/user_proj_example.v

# copy files for testbench
cp $CLF/custom_design/gcd/verify-la_test1-rtl/la_test1.c $CUPF/verilog/dv/la_test1/la_test1.c
cp $CLF/custom_design/gcd/verify-la_test1-rtl/la_test1_tb.v $CUPF/verilog/dv/la_test1/la_test1_tb.v

## copy includes file
cp $CLF/custom_design/gcd/user_proj_example/includes/includes.rtl.caravel_user_project $CUPF/verilog/includes/includes.rtl.caravel_user_project
cp $CLF/custom_design/gcd/user_proj_example/includes/includes.gl.caravel_user_project $CUPF/verilog/includes/includes.gl.caravel_user_project
cp $CLF/custom_design/gcd/user_proj_example/includes/includes.gl+sdf.caravel_user_project $CUPF/verilog/includes/includes.gl+sdf.caravel_user_project

## copy sim.makefile for debugging
cp $CLF/custom_design/gcd/verify-la_test1-rtl/sim.makefile $CUPF/mgmt_core_wrapper/verilog/dv/make/sim.makefile

make -d simenv 2>&1 | tee $LF/mpw-8c-simenv.log

# Run RTL simulation
make -d verify-la_test1-rtl 2>&1 | tee $LF/mpw-8c-verify-la_test1-rtl.log

# Run Openlane to generate RTL netlist
cp $CLF/custom_design/gcd/openlane/user_proj_example/config.json $CUPF/openlane/user_proj_example/config.json
cp $CLF/custom_design/gcd/openlane/user_proj_example/pin_order.cfg $CUPF/openlane/user_proj_example/pin_order.cfg
cp $CLF/custom_design/gcd/openlane/user_project_wrapper/config.json $CUPF/openlane/user_project_wrapper/config.json

make -d user_proj_example 2>&1 | tee $LF/mpw-8c-user_proj_example.log
make -d user_project_wrapper 2>&1 | tee $LF/mpw-8c-user_project_wrapper.log

# Run gate level simulation (it will take 2~3 hours@i9/64GB)
make -d verify-la_test1-gl 2>&1 | tee $LF/mpw-8c-verify-la_test1-gl.log

# Run gate level static timing verifier
make -d setup-timing-scripts 2>&1 | tee $LF/mpw-8c-setup-timing-scripts.log
make -d extract-parasitics 2>&1 | tee $LF/mpw-8c-extract-parasitics.log
make -d create-spef-mapping 2>&1 | tee $LF/mpw-8c-create-spef-mapping.log
make -d caravel-sta 2>&1 | tee $LF/mpw-8c-caravel-sta.log

# Run MPW precheck
cp $CLF/custom_design/gcd/mpw_precheck/README.md  $CUPF/README.md
cp $CLF/custom_design/gcd/mpw_precheck/user_defines.v  $CUPF/verilog/rtl/user_defines.v
make -d precheck 2>&1 | tee $LF/mpw-8c-precheck.log
make -d run-precheck 2>&1 | tee $LF/mpw-8c-run-precheck.log
```

# 4. execution run_fsic
- run_fsic still in debugging, you may found issues in step 4.3

## 4.1 edit bash_auto/run_fsic
```
$ cd caravel-lab/bash_auto
$ gedit run_fsic
```
- update your main folder path
```
# setup your main folder(MF)
export MF=/ADATA2T/debug/fsic_0921
```


## 4.2 mkdir your main folder
```
$ mkdir /ADATA2T/debug/fsic_0921
```
## 4.3 execution run_fsic and save log file
```
$ ./run_fsic 2>&1 | tee run_fsic.log
```


