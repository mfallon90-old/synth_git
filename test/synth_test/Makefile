###############################################################################
# Copyright (c) 2013 Potential Ventures Ltd
# Copyright (c) 2013 SolarFlare Communications Inc
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Potential Ventures Ltd,
#       SolarFlare Communications Inc nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL POTENTIAL VENTURES LTD BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###############################################################################

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

PWD=$(shell pwd)

VERILOG_SOURCES += $(PWD)/../../hdl/fm_synth_wrapper.v
VERILOG_SOURCES += $(PWD)/../../hdl/fm_synth_top.v
VERILOG_SOURCES += $(PWD)/../../hdl/const_pckg.sv
VERILOG_SOURCES += $(PWD)/../../hdl/axi_lite_cs_reg.sv
VERILOG_SOURCES += $(PWD)/../../hdl/control_unit.v
VERILOG_SOURCES += $(PWD)/../../hdl/note_gen.v
VERILOG_SOURCES += $(PWD)/../../hdl/phase_modulate.v
VERILOG_SOURCES += $(PWD)/../../hdl/note_registers.v
VERILOG_SOURCES += $(PWD)/../../hdl/i2s_transmitter.v
VERILOG_SOURCES += $(PWD)/../../hdl/phase_acc.v
VERILOG_SOURCES += $(PWD)/../../hdl/quadrant.v
VERILOG_SOURCES += $(PWD)/../../hdl/cos_lut.v
VERILOG_SOURCES += $(PWD)/../../hdl/fixed_point_mult.v
VERILOG_SOURCES += $(PWD)/../../hdl/shift_reg.v
VERILOG_SOURCES += $(PWD)/../../hdl/amp_shaper.v
VERILOG_SOURCES += $(PWD)/../../hdl/rc_filter_fsm.v
VERILOG_SOURCES += $(PWD)/../../hdl/sum_notes_16.v
VERILOG_SOURCES += $(PWD)/../../hdl/fixed_point_adder.v
VERILOG_SOURCES += $(PWD)/../../hdl/trig_gen.v

TOPLEVEL := fm_synth_wrapper
MODULE   := test_fm_synth

include $(shell cocotb-config --makefiles)/Makefile.sim
