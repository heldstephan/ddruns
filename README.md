This README describes how to reproduce the coloring results with the ddcolor program,
using the full  decision diagram formulation for graph coloring.
Arising IPs are solved exactly with SCIP exact.
To compile SCIP, we recommend to use Ubuntu 22.04, e.g. as a podman image.


First, we describe how to setup an Ubuntu 22.04 podman.
You find more information here:
https://community.endlessos.com/t/running-ubuntu-with-podman/10506

```
podman image pull ubuntu:22.04

# Create a work dir, e.g.
Clone this repository into a new directory, here called  ~/podman_sharing.
```
git clone TBD ~/podman_sharing
```

Make  cplex studio accessible. It is used to write out LP files. The CPLEX version is of minor importance.
```
rsync  -vau  <installaciton-of-cplex>/CPLEX_Studio126/ ~/podman_sharing/CPLEX_Studio126/
```

Start podman (alternatively log into your existing Ubuntu server):

```
podman run --interactive --tty --name ddcolors --volume /tmp/.X11-unix:/tmp/.X11-unix \
--env DISPLAY  \
--volume /etc/localtime:/etc/localtime:ro --volume ${HOME}/podman_sharing/:/mnt:z ubuntu:22.04
```


Make sure that following packages are installed on your (podman) Ubuntu:

```
apt-get update; apt-get -y dist-upgrade
apt install libtbb-dev libopenblas-dev libgmp*dev libboost-all-dev libmpfr*dev build-essential cmake libreadline*dev *bison*dev flex libblas-dev liblapack-dev pkgconf gawk git parallel
````


Download and compile SCIP and its dependencies:
```
cd /mnt/scip/
git clone https://github.com/scipopt/papilo.git
cd papilo
git checkout 9a800b2711a874e8ca97a349b917c1c02941c165 -b 9a800b2711a874e8ca97a349b917c1c02941c165
mkdir  build
cd build
cmake ..
make -j 16
make install

cd /mnt/scip/
git clone https://github.com/scipopt/soplex.git
cd soplex
git checkout 416b95376627036c1df7f2c5ed0bdc2a0944f2e2 -b 416b95376627036c1df7f2c5ed0bdc2a0944f2e2
mkdir  build
cd build
cmake ..
make -j 16
make install

cd /mnt/scip/
git clone https://github.com/ambros-gleixner/VIPR.git
cd VIPR
git checkout 121e72e8d191631691499135b05c14bc76b51150 -b 121e72e8d191631691499135b05c14bc76b51150
mkdir  build
cd build
cmake ../code  -DVIPRCOMP=off
make -j 16
# make install

# cd /mnt/scip/
# git clone https://github.com/scipopt/zimpl
# cd zimpl
# git checkout b3aa64ad38c67b4c73f1c18600a217563109b2d2 -b b3aa64ad38c67b4c73f1c18600a217563109b2d2
# mkdir  build
# cd build
# cmake ..
# make -j 16
# make install

cd /mnt/scip/
git clone https://github.com/scipopt/scip.git
cd scip
git checkout  165e6e1ad972b374bc2db7e2a90e4d0ebf065e0b -b 165e6e1ad972b374bc2db7e2a90e4d0ebf065e0b
mkdir  build
cd build
cmake .. -DAUTOBUILD=on
make -j 16
make install
```

ddcolors uses the LP interface from exactcolors:
```
cd /mnt/
git clone https://github.com/heldstephan/exactcolors.git
cd exactcolors
git checkout f7a57b211db19d1b4d2d083c0bbf434cf5179b68 -b f7a57b211db19d1b4d2d083c0bbf434cf5179b68
export CPLEX_HOME=/mnt/CPLEX_Studio126/cplex/
make -j 16
```


#Finally, download & build the flow_extraction branch from ddcolors:
cd /mnt/
git clone https://github.com/trewes/ddcolors.git
cd ddcolors
git checkout origin/flow_extraction -b flow_extraction
mkdir  build
cd build
cmake .. -DCPLEX_ROOT_DIR=/mnt/CPLEX_Studio126/cplex -DEXACTCOLORS_ROOT_DIR=/mnt/exactcolors
make -j 16



#### Experiments ####

First, build the IPs using ddcolors:

```
cd /mnt/ddruns/;
mkdir IPs;
./create_mips.sh
```

This uses 8 threads per default. You can change it via the parm that is passed to `parallel` in create_mips.sh.

Solve the IPs with scip.
```
cd /mnt/ddruns/;
mkdir scip_runs;
./solve_mips.sh | sh
```
The results are written into scip_runs/.
Ideally you would like to do this in parallel, piping to `parallel -j 8`, but in our experiments, runs started to die randomly.

For r1000.1c.log you need a little more time (3 h on modern EPYC CPUs):
```
cd /mnt/ddruns/;
mkdir scip_long_runs;
./solve_mips_long.sh | sh
```

Finally, you may solve  r1000.1c.edd.batch and DSJC500.9.batch (new best lower bound) with cplex (and unsafe floating poing arithmetic):
```

cd /mnt/ddruns/cplex_runs
./solve_mips.sh
```
