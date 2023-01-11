cd ../
set project [file tail [pwd]]
cd vivado/

open_project $project.xpr

update_compile_order -fileset sources_1

launch_runs synth_1 -jobs 4
wait_on_run synth_1

launch_runs impl_1 -jobs 4
wait_on_run impl_1

launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

write_hw_platform -fixed -include_bit -force -file C:/Users/mfall/Documents/School/year_4/senior_design/synth_git/vivado/block_design_wrapper.xsa