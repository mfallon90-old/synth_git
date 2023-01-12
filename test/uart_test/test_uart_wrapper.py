
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
    """Test for uart mIDI interface"""

    cocotb.start_soon(Clock(dut.s_axi_aclk, 44.286, units="ns").start())

    # Declare uart source
    uart_source = UartSource(dut.midi_in, baud=31250, bits=8)

    # Declare axi lite master
    axi_master = AxiLiteMaster(AxiLiteBus.from_prefix(dut, "s_axi"), dut.s_axi_aclk, 
                                dut.s_axi_aresetn, reset_active_level=False)

    # # Reset system
    await reset_dut(dut.s_axi_aresetn, 20)


    # loop through test
    for index in range(6):

        # Randomize data
        num = random.randrange(0,255)
        uart_tx = num.to_bytes(1, 'little')
        
        # Send UART data
        await uart_source.write(uart_tx)
        
        # Wait for interrupt
        await RisingEdge(dut.midi_intr)
        
        # Read from register and check valeu
        # read_data = await axi_master.read(0, 4)
        # assert read_data.data[0] == num

    await ClockCycles(dut.s_axi_aclk, 1000)

    # loop through test
    for index in range(5):

        # Read from register and check valeu
        read_data = await axi_master.read(0, 4)
        await ClockCycles(dut.s_axi_aclk, 1000)

    await ClockCycles(dut.s_axi_aclk, 1000)
    dut._log.info('Test done')

