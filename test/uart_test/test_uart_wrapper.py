
import random
import cocotb
from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from cocotbext.uart import UartSource

# Async system reset function
async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    reset_n._log.debug("Reset complete")

 
@cocotb.test()
async def read_write(dut):
    """Simple test for axi slave"""

    cocotb.start_soon(Clock(dut.s_axi_aclk, 44.286, units="ns").start())

    # Declare uart source
    uart_source = UartSource(dut.midi_in, baud=31250, bits=8)

    # Declare axi lite master
    axi_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi"), dut.s_axi_aclk, 
                                dut.s_axi_aresetn, reset_active_level=False)

    # # Reset system
    await reset_dut(dut.s_axi_aresetn, 20)

    # # send uart data
    # num = 170
    # await uart_source.write(num.to_bytes(1, 'little'))
    # await RisingEdge(dut.midi_intr)
    # read_data = await axi_master.read(0, 4)

    num = 170
    write_op = await axi_master.write(0, (num).to_bytes(4, byteorder = 'little'))
    read_data = await axi_master.read(0, 4)
    await ClockCycles(dut.s_axi_aclk, 300)

    # num = 171
    # write_op = await axi_master.write(4, (num).to_bytes(4, byteorder = 'little'))
    # read_data = await axi_master.read(4, 4)
    # await ClockCycles(dut.s_axi_aclk, 300)

    # num = 172
    # write_op = await axi_master.write(8, (num).to_bytes(4, byteorder = 'little'))
    # read_data = await axi_master.read(8, 4)
    # await ClockCycles(dut.s_axi_aclk, 300)

    # num = 173
    # write_op = await axi_master.write(12, (num).to_bytes(4, byteorder = 'little'))
    # read_data = await axi_master.read(12, 4)
    # await ClockCycles(dut.s_axi_aclk, 300)


    dut._log.info('Test done')

