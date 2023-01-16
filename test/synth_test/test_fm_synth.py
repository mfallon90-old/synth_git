
import random
import cocotb
from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from const import *
from functions import *


@cocotb.test()
async def read_write(dut):
    """Simple test for axi slave"""

    cocotb.start_soon(Clock(dut.s_axi_aclk, 5, units="ns").start())
    
    # Declare axi lite master
    axi_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi"), dut.s_axi_aclk, 
                                dut.s_axi_aresetn, reset_active_level=False)

    # Reset system
    await reset_dut(dut.sys_rst, dut.s_axi_aresetn, 20)

    # Initialize synthesizer
    await synth_init(axi_master, CTRL_INIT_TRI)

    await note_on(axi_master, 0, A5, 0, 64)

    await ClockCycles(dut.word_select, 10)

    await note_off(axi_master, 0)

    await RisingEdge(dut.interrupt)

    await ClockCycles(dut.word_select, 10)

    dut._log.info('Test done')

