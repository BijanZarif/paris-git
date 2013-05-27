#! /bin/bash
#set -x

if [ $# -lt 5 ]; then
    echo "missing arguments"
    echo usage $0 nr_of_dt_values dt0 nx0 Implicit:T/F precision
    exit
fi

let ndt=$1
dt0=$2
let nx0=$3
let idt=0
imp=$4
precision=$5

dt=$dt0

/bin/rm -f flowrates-IMP-$imp*

while [ $idt -lt $ndt ] ; do
    rm -fr input out stats
    let nx=$nx0
    sed s/NXTEMP/$nx/g testinput.template | sed s/DTTEMP/$dt/g | sed s/IMPTEMP/$imp/g > testinput-$nx-$idt
    ln -s testinput-$nx-$idt input
    let npx=`grep -i NPX input |  awk 'BEGIN {FS = "="}{print $2}' | awk '{print $1}'`
    let npy=`grep -i NPY input |  awk 'BEGIN {FS = "="}{print $2}' | awk '{print $1}'`
    let npz=`grep -i NPZ input |  awk 'BEGIN {FS = "="}{print $2}' | awk '{print $1}'`
#    echo $npx $npy $npz
    if [ `grep DoFront input | awk '{print $3}'` == 'T' ]; then
	let np=$npx*$npy*$npz+1
    else
	let np=$npx*$npy*$npz
    fi
    mpirun -np $np paris > tmpout-$nx-$idt
    awk ' /Step:/ { cpu = $8 } END { print "cpu = " cpu } ' < tmpout-$nx-$idt
    awk -v dt=$dt '{ print dt " " $1 " " $2}' < out/flowrate.txt >> flowrates-IMP-$imp.txt
    dt=`awk -v dt=$dt 'BEGIN {print dt/2}'`
    let idt=$idt+1
done

end=`grep -i EndTime input |  awk 'BEGIN {FS = "="}{print $2}' | awk '{print $1}'`
phi=`cat out/porosity.txt | awk '{print $1}'`
# echo phi = $phi

awk '{print $1 " " $3}' < stats > deriv
parisdeconv deriv > toplot.txt

gnuplot <<EOF > tmp 2>&1
f(x) = a*x + b
FIT_LIMIT = 1e-6
fit [2*$end/3:$end] f(x) "toplot.txt" via a, b
plot "toplot.txt", f(x)
print "decaytime = ",-1/a
EOF

grep deccaytime tmp | awk -v phi=$phi '{print "decaytime = " $3*phi}' > perm.txt

awk '{radius=0.0625; print "K/R^2 = " $2/(radius*radius)}' < out/flowrate.txt >> perm.txt

if [ -d out ]; then
    cd out
	compare ../reference.txt flowrate.txt $precision
    cd ..
else
    echo "FAIL: directory out not created"
fi
#! /bin/bash


