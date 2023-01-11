rmdir vitis /s /q

md vitis

cd vitis\ 

call C:\Xilinx\Vitis\2020.2\settings64 -quiet

xsct ..\scripts\build_vitis.tcl
