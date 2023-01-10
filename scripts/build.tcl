cd ../
set project [file tail [pwd]]
cd vivado/

set target xc7z007sclg225-1

create_project $project -part $target -force
set_property BOARD_PART em.avnet.com:minized:part0:1.2 [current_project]

add_files -fileset sources_1 ../hdl/
add_files -norecurse ../hdl/lut.mem

add_files -fileset constrs_1 ../constraints/

update_compile_order -fileset sources_1 -quiet

source ../scripts/block_design.tcl
# source ../scripts/bd.tcl

make_wrapper -files [get_files C:/Users/mfall/Documents/School/year_4/senior_design/synth_git/vivado/synth_git.srcs/sources_1/bd/block_design/block_design.bd] -top
add_files -norecurse c:/Users/mfall/Documents/School/year_4/senior_design/synth_git/vivado/synth_git.gen/sources_1/bd/block_design/hdl/block_design_wrapper.v
update_compile_order -fileset sources_1
set_property top block_design_wrapper [current_fileset]