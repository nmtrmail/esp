------------------------------------------------------------------------------
--  This file is part of an extension to the GRLIB VHDL IP library.
--  Copyright (C) 2013, System Level Design (SLD) group @ Columbia University
--
--  GRLIB is a Copyright (C) 2008 - 2013, Aeroflex Gaisler
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  To receive a copy of the GNU General Public License, write to the Free
--  Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
--  02111-1307  USA.
-----------------------------------------------------------------------------
-- Entity:  misc_tile_q
-- File:    misc_tile_q.vhd
-- Authors: Paolo Mantovani - SLD @ Columbia University
-- Description:	FIFO queues for the CPU tile.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.amba.all;
use work.stdlib.all;
use work.devices.all;

use work.gencomp.all;
use work.genacc.all;

use work.nocpackage.all;
use work.tile.all;

entity misc_tile_q is
  generic (
    tech        : integer := virtex7);
  port (
    rst                                 : in  std_ulogic;
    clk                                 : in  std_ulogic;
    -- NoC1->tile
    ahbs_req_rdreq                      : in  std_ulogic;
    ahbs_req_data_out                   : out noc_flit_type;
    ahbs_req_empty                      : out std_ulogic;
    -- tile->NoC3
    ahbs_rsp_line_wrreq                 : in  std_ulogic;
    ahbs_rsp_line_data_in               : in  noc_flit_type;
    ahbs_rsp_line_full                  : out std_ulogic;
    -- NoC6->tile
    dma_rcv_rdreq                       : in  std_ulogic;
    dma_rcv_data_out                    : out noc_flit_type;
    dma_rcv_empty                       : out std_ulogic;
    -- tile->NoC4
    dma_snd_wrreq                       : in  std_ulogic;
    dma_snd_data_in                     : in  noc_flit_type;
    dma_snd_full                        : out std_ulogic;
    dma_snd_atleast_4slots              : out std_ulogic;
    dma_snd_exactly_3slots              : out std_ulogic;
    -- NoC5->tile
    apb_rcv_rdreq                       : in  std_ulogic;
    apb_rcv_data_out                    : out noc_flit_type;
    apb_rcv_empty                       : out std_ulogic;
    -- tile->NoC5
    apb_snd_wrreq                       : in  std_ulogic;
    apb_snd_data_in                     : in  noc_flit_type;
    apb_snd_full                        : out std_ulogic;
    -- NoC5->tile
    irq_ack_rdreq                       : in  std_ulogic;
    irq_ack_data_out                    : out noc_flit_type;
    irq_ack_empty                       : out std_ulogic;
    -- tile->NoC5
    irq_wrreq                           : in  std_ulogic;
    irq_data_in                         : in  noc_flit_type;
    irq_full                            : out std_ulogic;
    -- NoC5->tile
    interrupt_rdreq                     : in  std_ulogic;
    interrupt_data_out                  : out noc_flit_type;
    interrupt_empty                     : out std_ulogic;

    -- Cachable data plane 1 -> request messages
    noc1_out_data : in  noc_flit_type;
    noc1_out_void : in  std_ulogic;
    noc1_out_stop : out std_ulogic;
    noc1_in_data  : out noc_flit_type;
    noc1_in_void  : out std_ulogic;
    noc1_in_stop  : in  std_ulogic;
    -- Cachable data plane 2 -> forwarded messages
    noc2_out_data : in  noc_flit_type;
    noc2_out_void : in  std_ulogic;
    noc2_out_stop : out std_ulogic;
    noc2_in_data  : out noc_flit_type;
    noc2_in_void  : out std_ulogic;
    noc2_in_stop  : in  std_ulogic;
    -- Cachable data plane 3 -> response messages
    noc3_out_data : in  noc_flit_type;
    noc3_out_void : in  std_ulogic;
    noc3_out_stop : out std_ulogic;
    noc3_in_data  : out noc_flit_type;
    noc3_in_void  : out std_ulogic;
    noc3_in_stop  : in  std_ulogic;
    -- Non cachable data data plane 4 -> DMA transfers
    noc4_out_data : in  noc_flit_type;
    noc4_out_void : in  std_ulogic;
    noc4_out_stop : out std_ulogic;
    noc4_in_data  : out noc_flit_type;
    noc4_in_void  : out std_ulogic;
    noc4_in_stop  : in  std_ulogic;
    -- Configuration plane 5 -> RD/WR registers
    noc5_out_data : in  noc_flit_type;
    noc5_out_void : in  std_ulogic;
    noc5_out_stop : out std_ulogic;
    noc5_in_data  : out noc_flit_type;
    noc5_in_void  : out std_ulogic;
    noc5_in_stop  : in  std_ulogic;
    -- Non cachable data data plane 6 -> DMA transfers request
    noc6_out_data : in  noc_flit_type;
    noc6_out_void : in  std_ulogic;
    noc6_out_stop : out std_ulogic;
    noc6_in_data  : out noc_flit_type;
    noc6_in_void  : out std_ulogic;
    noc6_in_stop  : in  std_ulogic);

end misc_tile_q;

architecture rtl of misc_tile_q is

  signal fifo_rst : std_ulogic;

  -- NoC1->tile
  signal ahbs_req_wrreq                 : std_ulogic;
  signal ahbs_req_data_in               : noc_flit_type;
  signal ahbs_req_full                  : std_ulogic;
  -- tile->NoC3
  signal ahbs_rsp_line_rdreq            : std_ulogic;
  signal ahbs_rsp_line_data_out         : noc_flit_type;
  signal ahbs_rsp_line_empty            : std_ulogic;
  -- NoC5->tile
  signal apb_rcv_wrreq                : std_ulogic;
  signal apb_rcv_data_in              : noc_flit_type;
  signal apb_rcv_full                 : std_ulogic;
  -- NoC6->tile
  signal dma_rcv_wrreq                       : std_ulogic;
  signal dma_rcv_data_in                     : noc_flit_type;
  signal dma_rcv_full                        : std_ulogic;
  -- tile->NoC4
  signal dma_snd_rdreq                       : std_ulogic;
  signal dma_snd_data_out                    : noc_flit_type;
  signal dma_snd_empty                       : std_ulogic;
  -- tile->NoC5
  signal apb_snd_rdreq                : std_ulogic;
  signal apb_snd_data_out             : noc_flit_type;
  signal apb_snd_empty                : std_ulogic;
  -- NoC5->tile
  signal irq_ack_wrreq                : std_ulogic;
  signal irq_ack_data_in              : noc_flit_type;
  signal irq_ack_full                 : std_ulogic;
  -- tile->Noc5
  signal irq_rdreq                    : std_ulogic;
  signal irq_data_out                 : noc_flit_type;
  signal irq_empty                    : std_ulogic;
  -- NoC5->tile
  signal interrupt_wrreq              : std_ulogic;
  signal interrupt_data_in            : noc_flit_type;
  signal interrupt_full               : std_ulogic;

  type noc5_packet_fsm is (none, packet_apb_rcv,
                           packet_irq_ack, packet_interrupt);
  signal noc5_fifos_current, noc5_fifos_next : noc5_packet_fsm;
  type to_noc5_packet_fsm is (none, packet_apb_snd, packet_irq);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;

  signal noc5_msg_type : noc_msg_type;
  signal noc5_preamble : noc_preamble_type;

  signal noc1_dummy_in_stop   : std_ulogic;
  signal noc2_dummy_in_stop   : std_ulogic;
  signal noc2_dummy_out_data  : noc_flit_type;
  signal noc2_dummy_out_void  : std_ulogic;
  signal noc3_dummy_out_data  : noc_flit_type;
  signal noc3_dummy_out_void  : std_ulogic;
  signal noc4_dummy_out_data  : noc_flit_type;
  signal noc4_dummy_out_void  : std_ulogic;
  signal noc6_dummy_in_stop   : std_ulogic;

begin  -- rtl

  fifo_rst <= rst;                  --FIFO rst active low

  -- From noc1: ahbs requests from CPU to some slave (DVI, ..) (GET/PUT)
  noc1_out_stop         <= ahbs_req_full and (not noc1_out_void);
  ahbs_req_data_in      <= noc1_out_data;
  ahbs_req_wrreq        <= (not noc1_out_void) and (not ahbs_req_full);
  noc1_in_data          <= (others => '0');
  noc1_in_void          <= '1';
  noc1_dummy_in_stop    <= noc1_in_stop;

  fifo_16: fifo
    generic map (
      depth => 6,                       --Header, address, [cache line]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => ahbs_req_rdreq,
      wrreq    => ahbs_req_wrreq,
      data_in  => ahbs_req_data_in,
      empty    => ahbs_req_empty,
      full     => ahbs_req_full,
      data_out => ahbs_req_data_out);

  -- to noc3: ahbs response messages to CPU
  noc3_out_stop <= '0';
  noc3_dummy_out_data <= noc3_out_data;
  noc3_dummy_out_void <= noc3_out_void;
  noc3_in_data <= ahbs_rsp_line_data_out;
  noc3_in_void <= ahbs_rsp_line_empty or noc3_in_stop;
  ahbs_rsp_line_rdreq <= (not ahbs_rsp_line_empty) and (not noc3_in_stop);
  fifo_17: fifo
    generic map (
      depth => 5,                       --Header, cache line
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => ahbs_rsp_line_rdreq,
      wrreq    => ahbs_rsp_line_wrreq,
      data_in  => ahbs_rsp_line_data_in,
      empty    => ahbs_rsp_line_empty,
      full     => ahbs_rsp_line_full,
      data_out => ahbs_rsp_line_data_out);


  -- From noc6: DMA requests from accelerators
  noc6_in_data          <= (others => '0');
  noc6_in_void          <= '1';
  noc6_dummy_in_stop    <= noc6_in_stop;
  noc6_out_stop   <= dma_rcv_full and (not noc6_out_void);
  dma_rcv_data_in <= noc6_out_data;
  dma_rcv_wrreq   <= (not noc6_out_void) and (not dma_rcv_full);
  fifo_18: fifo
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => dma_rcv_rdreq,
      wrreq    => dma_rcv_wrreq,
      data_in  => dma_rcv_data_in,
      empty    => dma_rcv_empty,
      full     => dma_rcv_full,
      data_out => dma_rcv_data_out);

  -- To noc4: DMA response to accelerators
  noc4_out_stop <= '0';
  noc4_dummy_out_data <= noc4_out_data;
  noc4_dummy_out_void <= noc4_out_void;
  noc4_in_data <= dma_snd_data_out;
  noc4_in_void <= dma_snd_empty or noc4_in_stop;
  dma_snd_rdreq <= (not dma_snd_empty) and (not noc4_in_stop);
  fifo_19: fifo2
    generic map (
      depth => 18,                      --Header, address, [data]
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => dma_snd_rdreq,
      wrreq    => dma_snd_wrreq,
      data_in  => dma_snd_data_in,
      empty    => dma_snd_empty,
      full     => dma_snd_full,
      atleast_4slots => dma_snd_atleast_4slots,
      exactly_3slots => dma_snd_exactly_3slots,
      data_out => dma_snd_data_out);


  -- From noc5: APB request frim remote core (APB rcv)
  -- From noc5: IRQ ack.
  noc5_msg_type <= get_msg_type(noc5_out_data);
  noc5_preamble <= get_preamble(noc5_out_data);
  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      noc5_fifos_current <= noc5_fifos_next;
    end if;
  end process;
  noc5_fifos_get_packet: process (noc5_out_data, noc5_out_void, noc5_msg_type,
                                  noc5_preamble, apb_rcv_full,
                                  irq_ack_full,
                                  interrupt_full, noc5_fifos_current)
  begin  -- process noc5_get_packet
    apb_rcv_wrreq <= '0';
    irq_ack_wrreq <= '0';
    interrupt_wrreq <= '0';
    noc5_fifos_next <= noc5_fifos_current;
    noc5_out_stop <= '0';

    case noc5_fifos_current is
      when none => if noc5_out_void = '0' then
                     if ((noc5_msg_type = REQ_REG_RD or noc5_msg_type = REQ_REG_WR)
                         and noc5_preamble = PREAMBLE_HEADER) then
                       if apb_rcv_full = '0' then
                         apb_rcv_wrreq <= '1';
                         noc5_fifos_next <= packet_apb_rcv;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     elsif (noc5_msg_type = IRQ_MSG and noc5_preamble = PREAMBLE_HEADER) then
                       if irq_ack_full = '0' then
                         irq_ack_wrreq <= '1';
                         noc5_fifos_next <= packet_irq_ack;
                       else
                         noc5_out_stop <= '1';
                       end if;
                     elsif (noc5_msg_type = INTERRUPT and noc5_preamble = PREAMBLE_1FLIT) then
                       interrupt_wrreq <= not interrupt_full;
                       noc5_out_stop <= interrupt_full;
                     end if;
                   end if;

      when packet_apb_rcv => apb_rcv_wrreq <= not noc5_out_void and (not apb_rcv_full);
                             noc5_out_stop <= apb_rcv_full and (not noc5_out_void);
                             if (noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                                 apb_rcv_full = '0') then
                               noc5_fifos_next <= none;
                             end if;


      when packet_irq_ack => irq_ack_wrreq <= not noc5_out_void and (not irq_ack_full);
                             noc5_out_stop <= irq_ack_full and (not noc5_out_void);
                             if (noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and
                                 irq_ack_full = '0') then
                               noc5_fifos_next <= none;
                             end if;

      when others => noc5_fifos_next <= none;
    end case;
  end process noc5_fifos_get_packet;

  apb_rcv_data_in <= noc5_out_data;
  fifo_7: fifo
    generic map (
      depth => 3,                       --Header, address, data
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_rcv_rdreq,
      wrreq    => apb_rcv_wrreq,
      data_in  => apb_rcv_data_in,
      empty    => apb_rcv_empty,
      full     => apb_rcv_full,
      data_out => apb_rcv_data_out);


  irq_ack_data_in <= noc5_out_data;
  fifo_12: fifo
    generic map (
      depth => 8,                       --Header, irq info x # cpus
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => irq_ack_rdreq,
      wrreq    => irq_ack_wrreq,
      data_in  => irq_ack_data_in,
      empty    => irq_ack_empty,
      full     => irq_ack_full,
      data_out => irq_ack_data_out);

  interrupt_data_in <= noc5_out_data;
  fifo_15: fifo
    generic map (
      depth => 9,                       --Header x # accelerators
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => interrupt_rdreq,
      wrreq    => interrupt_wrreq,
      data_in  => interrupt_data_in,
      empty    => interrupt_empty,
      full     => interrupt_full,
      data_out => interrupt_data_out);

  -- To noc5: APB response to remote core (APB snd)
  -- To noc5: IRQ

  process (clk, rst)
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      to_noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then  -- rising clock edge
      to_noc5_fifos_current <= to_noc5_fifos_next;
    end if;
  end process;

  to_noc5_select_packet: process (noc5_in_stop, to_noc5_fifos_current,
                                  apb_snd_data_out, apb_snd_empty,
                                  irq_data_out, irq_empty)
    variable to_noc5_preamble : noc_preamble_type;
  begin  -- process to_noc5_select_packet
    noc5_in_data <= (others => '0');
    noc5_in_void <= '1';
    apb_snd_rdreq <= '0';
    irq_rdreq <= '0';
    to_noc5_fifos_next <= to_noc5_fifos_current;
    to_noc5_preamble := "00";

    case to_noc5_fifos_current is
      when none  => if irq_empty = '0' then
                      noc5_in_data <= irq_data_out;
                      noc5_in_void <= irq_empty;
                      if noc5_in_stop = '0' then
                        irq_rdreq <= '1';
                        to_noc5_fifos_next <= packet_irq;
                      end if;
                    elsif apb_snd_empty = '0' then
                      noc5_in_data <= apb_snd_data_out;
                      noc5_in_void <= apb_snd_empty;
                      if noc5_in_stop = '0' then
                        apb_snd_rdreq <= '1';
                        to_noc5_fifos_next <= packet_apb_snd;
                      end if;
                    end if;

      when packet_apb_snd => to_noc5_preamble := get_preamble(apb_snd_data_out);
                             if (noc5_in_stop = '0' and apb_snd_empty = '0') then
                               noc5_in_data <= apb_snd_data_out;
                               noc5_in_void <= apb_snd_empty;
                               apb_snd_rdreq <= not noc5_in_stop;
                               if to_noc5_preamble = PREAMBLE_TAIL then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when packet_irq     => to_noc5_preamble := get_preamble(irq_data_out);
                             if (noc5_in_stop = '0' and irq_empty = '0') then
                               noc5_in_data <= irq_data_out;
                               noc5_in_void <= irq_empty;
                               irq_rdreq <= not noc5_in_stop;
                               if (to_noc5_preamble = PREAMBLE_TAIL) then
                                 to_noc5_fifos_next <= none;
                               end if;
                             end if;

      when others => to_noc5_fifos_next <= none;
    end case;
  end process to_noc5_select_packet;

  fifo_10: fifo
    generic map (
      depth => 2,                       --Header, data (1 word)
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_snd_rdreq,
      wrreq    => apb_snd_wrreq,
      data_in  => apb_snd_data_in,
      empty    => apb_snd_empty,
      full     => apb_snd_full,
      data_out => apb_snd_data_out);

  fifo_9: fifo
    generic map (
      depth => 2,                       --Header, irq level
      width => NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => irq_rdreq,
      wrreq    => irq_wrreq,
      data_in  => irq_data_in,
      empty    => irq_empty,
      full     => irq_full,
      data_out => irq_data_out);

  -- noc2,4,6 do not interact with misc. tiles

  noc2_dummy_out_data <= noc2_out_data;
  noc2_dummy_out_void <= noc2_out_void;
  noc2_out_stop <= '0';
  noc2_in_data <= (others => '0');
  noc2_in_void <= '1';
  noc2_dummy_in_stop <= noc2_in_stop;

end rtl;