call 0_clean

call C:\Xilinx\Vivado\2020.2\settings64 - quiet

cd vivado\ 

vivado -mode batch -source ../scripts/build.tcl
