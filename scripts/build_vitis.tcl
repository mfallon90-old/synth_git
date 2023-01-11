# setws C:/Users/mfall/Documents/School/year_4/senior_design/synth_git/vitis

setws C:/Users/mfall/Documents/School/year_4/senior_design/synth_git/vitis

platform create -name {platform} -hw {C:\Users\mfall\Documents\School\year_4\senior_design\synth_git\vivado\block_design_wrapper.xsa} 

domain create -name {domain} -proc {ps7_cortexa9_0} -os {standalone}

domain active {domain}

platform active {platform}

platform generate

app create -name {application} -platform {platform} -domain {domain} -template {Empty Application (C++)} -lang {c++}

importsources -name {application} -path {C:\Users\mfall\Documents\School\year_4\senior_design\synth_git\c} -soft-link

app build -name application