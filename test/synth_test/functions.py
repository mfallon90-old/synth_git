import random
import cocotb
from cocotbext.axi import AxiLiteBus, AxiLiteMaster
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles
from const import *

# Async system reset function
async def reset_dut(reset, reset_n, duration_ns):
    reset_n.value = 0
    reset.value = 1
    await Timer(duration_ns, units="ns")
    reset_n.value = 1
    reset.value = 0
    reset_n._log.debug("Reset complete")


async def synth_init(axi_master, init):
    write_op = await axi_master.write(CTRL_REG_ADDR, init.to_bytes(4, byteorder = 'little'))


async def note_on(axi_master, channel, car, mod, vel):
    vel_attack = (vel << 24)
    vel_decay = (vel << 7)
    velocity = (vel_attack | vel_decay).to_bytes(4, byteorder = 'little')
    modulator = mod.to_bytes(4, byteorder = 'little')
    carrier = (car | ON_MASK).to_bytes(4, byteorder = 'little')
    write_op = await axi_master.write(VELOCITY_ADDR[channel],  velocity)
    write_op = await axi_master.write(MODULATOR_ADDR[channel], modulator)
    write_op = await axi_master.write(CARRIER_ADDR[channel],   carrier)


async def note_off(axi_master, channel):
    carrier = await axi_master.read(CARRIER_ADDR[channel], 4)
    carrier = (int.from_bytes(carrier.data, 'little') & OFF_MASK).to_bytes(4, byteorder = 'little')
    write_op = await axi_master.write(CARRIER_ADDR[channel], carrier)
