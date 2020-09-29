 # 
 # Copyright (c) 2019-2020 Embedded Systems and Applications, TU Darmstadt.
 # This file is part of RT-LIFE
 # (see https://github.com/esa-tu-darmstadt/RT-LIFE).
 #
 # Permission is hereby granted, free of charge, to any person obtaining
 # a copy of this software and associated documentation files (the "Software"),
 # to deal in the Software without restriction, including without limitation
 # the rights to use, copy, modify, merge, publish, distribute, sublicense,
 # and/or sell copies of the Software, and to permit persons to whom the
 # Software is furnished to do so, subject to the following conditions:
 #
 # The above copyright notice and this permission notice shall be included
 # in all copies or substantial portions of the Software.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 # THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 # THE SOFTWARE.
 #

#*****************************************************************************************
# Vivado (TM) v2019.1 (64-bit)
#
# piccolo32_pe_dexie.tcl: Tcl script for re-creating project 'piccolo32_pe'
#
# Generated by Vivado on Sun Aug 25 13:01:45 CEST 2019
# IP Build 2548770 on Fri May 24 18:01:18 MDT 2019
#
# This file contains the Vivado Tcl commands for re-creating the project to the state*
# when this script was generated. In order to re-create the project, please source this
# file in the Vivado Tcl Shell.
#
# * Note that the runs in the created project will be configured the same way as the
#   original project, however they will not be launched automatically. To regenerate the
#   run results please launch the synthesis/implementation runs as needed.
#
#*****************************************************************************************
# NOTE: In order to use this script for source control purposes, please make sure that the
#       following files are added to the source control system:-
#
# 1. This project restoration tcl script (piccolo32_pe_dexie.tcl) that was generated.
#
# 2. The following source(s) files that were local or imported into the original project.
#    (Please see the '$orig_proj_dir' and '$origin_dir' variable setting below at the start of the script)
#
# 3. The following remote source files that were added to the original project:-
#
#    <none>
#
#*****************************************************************************************

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set _xil_proj_name_ "piccolo32_pe"

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

variable script_file
set script_file "piccolo32_pe_dexie.tcl"

# Help information for this script
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--tapasco_riscv" { incr i; set tapasco_riscv_dir [lindex $::argv $i] }
      "--dexieMemSize" { incr i; set dexieMemSize [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/piccolo32_pe"]"

# Create project
create_project -force ${_xil_proj_name_} ./${_xil_proj_name_} -part xc7z020clg400-1

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Calculate range of AXI BRAM slave
set program_size 0x10000

set s_axi_bram_size [expr $dexieMemSize + $program_size]
set addr_width [expr {int(ceil(log10($s_axi_bram_size*2)/log10(2)))}]
set range [expr {int(pow(2, $addr_width))}]

# Set project properties
set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "dsa.num_compute_units" -value "60" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "part" -value "xc7z020clg400-1" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY" -objects $obj
set_property -name "dsa.accelerator_binary_content" -value "bitstream" -objects $obj
set_property -name "dsa.accelerator_binary_format" -value "xclbin2" -objects $obj
set_property -name "dsa.description" -value "Vivado generated DSA" -objects $obj
set_property -name "dsa.dr_bd_base_address" -value "0" -objects $obj
set_property -name "dsa.emu_dir" -value "emu" -objects $obj
set_property -name "dsa.flash_interface_type" -value "bpix16" -objects $obj
set_property -name "dsa.flash_offset_address" -value "0" -objects $obj
set_property -name "dsa.flash_size" -value "1024" -objects $obj
set_property -name "dsa.host_architecture" -value "x86_64" -objects $obj
set_property -name "dsa.host_interface" -value "pcie" -objects $obj
set_property -name "dsa.platform_state" -value "pre_synth" -objects $obj
set_property -name "dsa.vendor" -value "xilinx" -objects $obj
set_property -name "dsa.version" -value "0.0" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize "$tapasco_riscv_dir/IP/AXIGate"] [file normalize "$tapasco_riscv_dir/IP/axi_offset"] [file normalize "$origin_dir/ip"] [file normalize "$origin_dir/core/IP"]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Import local files from the original project
#set files [list  \
# [file normalize "${origin_dir}/piccolo32_pe_wrapper.v" ]\
#]
#set imported_files [import_files -fileset sources_1 $files]
set imported_files [import_files -fileset sources_1]

# Set 'sources_1' fileset file properties for remote files
# None

# Set 'sources_1' fileset file properties for local files
# None

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "mkCore" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Empty (no sources present)

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property -name "target_part" -value "xc7z020clg400-1" -objects $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property -name "top" -value "piccolo32_axi" -objects $obj
set_property -name "top_lib" -value "xil_defaultlib" -objects $obj

# Set 'utils_1' fileset object
set obj [get_filesets utils_1]
# Empty (no sources present)

# Set 'utils_1' fileset properties
set obj [get_filesets utils_1]


# Adding sources referenced in BDs, if not already added


# Proc to create BD piccolo32_pe
proc cr_bd_piccolo32_pe { parentCell addr_width range } {

  # CHANGE DESIGN NAME HERE
  set design_name piccolo32_pe

  common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  esa.informatik.tu-darmstadt.de:tapasco:AXIGate:1.0\
  esa.informatik.tu-darmstadt.de:dexie:dexie_piccolo32:1.0\
  esa.cs.tu-darmstadt.de:axi:axi_offset:0.1\
  xilinx.com:ip:blk_mem_gen:8.4\
  bluespec.com:piccolo:RV32ACIMU:0.1\
  xilinx.com:ip:axi_bram_ctrl:4.1\
  xilinx.com:ip:proc_sys_reset:5.0\
  xilinx.com:ip:smartconnect:1.0\
  "

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

  }

  if { $bCheckIPsPassed != 1 } {
    common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M_AXI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.PROTOCOL {AXI4} \
   ] $M_AXI

  set S_AXI_BRAM [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_BRAM ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH $addr_width \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {6} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_BRAM

  set S_AXI_CTRL [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {16} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_CTRL


  # Create ports
  set ARESET_N [ create_bd_port -dir I -type rst ARESET_N ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $ARESET_N
  set CLK [ create_bd_port -dir I -type clk CLK ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXI_BRAM:S_AXI_CTRL:M_AXI} \
 ] $CLK
  set interrupt [ create_bd_port -dir O -type intr interrupt ]

  # Create instance: AXIGate_0, and set properties
  set AXIGate_0 [ create_bd_cell -type ip -vlnv esa.informatik.tu-darmstadt.de:tapasco:AXIGate:1.0 AXIGate_0 ]
  set_property -dict [ list \
   CONFIG.threshold {0x00004000} \
 ] $AXIGate_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
 ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.STRATEGY {1} \
 ] $axi_interconnect_1

  # Create instance: axi_mem_intercon_1, and set properties
  set axi_mem_intercon_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_1 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
   CONFIG.NUM_SI {1} \
   CONFIG.STRATEGY {2} \
 ] $axi_mem_intercon_1

  # Create instance: dexie_0, and set properties
  set dexie_0 [ create_bd_cell -type ip -vlnv esa.informatik.tu-darmstadt.de:dexie:dexie_piccolo32:1.0 dexie_0 ]

  # Create instance: dmaOffset, and set properties
  set dmaOffset [ create_bd_cell -type ip -vlnv esa.cs.tu-darmstadt.de:axi:axi_offset:0.1 dmaOffset ]
  set_property -dict [ list \
   CONFIG.ADDRESS_WIDTH {32} \
   CONFIG.BYTES_PER_WORD {4} \
 ] $dmaOffset

  # Create instance: dmem, and set properties
  set dmem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 dmem ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $dmem

  # Create instance: imem, and set properties
  set imem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 imem ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {true} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $imem

  # Create instance: piccolo32_0, and set properties
  set piccolo32_0 [ create_bd_cell -type ip -vlnv bluespec.com:piccolo:RV32ACIMU:0.1 piccolo32_0 ]
  set_property -dict [ list \
   CONFIG.AUX_MEMORY_REGIONS {0} \
   CONFIG.UC_MEMORY_REGIONS {1} \
 ] $piccolo32_0

  # Create instance: ps_dmem_ctrl, and set properties
  set ps_dmem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 ps_dmem_ctrl ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $ps_dmem_ctrl

  # Create instance: ps_imem_ctrl, and set properties
  set ps_imem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 ps_imem_ctrl ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $ps_imem_ctrl

  # Create instance: rst_CLK_100M, and set properties
  set rst_CLK_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_CLK_100M ]

  # Create instance: rv_dmem_ctrl, and set properties
  set rv_dmem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 rv_dmem_ctrl ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.ECC_TYPE {Hamming} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $rv_dmem_ctrl

  # Create instance: rv_imem_ctrl, and set properties
  set rv_imem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 rv_imem_ctrl ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.ECC_TYPE {Hamming} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $rv_imem_ctrl

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_SI {1} \
 ] $smartconnect_0

  # Create interface connections
  connect_bd_intf_net -intf_net AXIGate_0_maxi [get_bd_intf_pins AXIGate_0/maxi] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net S_AXI_BRAM_1 [get_bd_intf_ports S_AXI_BRAM] [get_bd_intf_pins dexie_0/s_axi_bram]
  connect_bd_intf_net -intf_net S_AXI_CTRL_1 [get_bd_intf_ports S_AXI_CTRL] [get_bd_intf_pins AXIGate_0/saxi]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins dexie_0/s_axi_ctrl]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins ps_imem_ctrl/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M01_AXI [get_bd_intf_pins axi_interconnect_1/M01_AXI] [get_bd_intf_pins ps_dmem_ctrl/S_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_1_M00_AXI [get_bd_intf_pins axi_mem_intercon_1/M00_AXI] [get_bd_intf_pins rv_dmem_ctrl/S_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_1_M01_AXI [get_bd_intf_pins axi_mem_intercon_1/M01_AXI] [get_bd_intf_pins dmaOffset/S_AXI]
  connect_bd_intf_net -intf_net axi_mem_intercon_1_M02_AXI [get_bd_intf_pins axi_interconnect_0/S01_AXI] [get_bd_intf_pins axi_mem_intercon_1/M02_AXI]
  connect_bd_intf_net -intf_net dexie_0_m_axi_cpu_mem [get_bd_intf_pins axi_interconnect_1/S00_AXI] [get_bd_intf_pins dexie_0/m_axi_cpu_mem]
  connect_bd_intf_net -intf_net dmaOffset_M_AXI [get_bd_intf_ports M_AXI] [get_bd_intf_pins dmaOffset/M_AXI]
  connect_bd_intf_net [get_bd_intf_pins piccolo32_0/cpu_dmem_master] [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]
  connect_bd_intf_net [get_bd_intf_pins piccolo32_0/cpu_imem_master] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net ps_dmem_ctrl_BRAM_PORTA [get_bd_intf_pins dmem/BRAM_PORTB] [get_bd_intf_pins ps_dmem_ctrl/BRAM_PORTA]
  connect_bd_intf_net -intf_net ps_imem_ctrl_BRAM_PORTA [get_bd_intf_pins imem/BRAM_PORTB] [get_bd_intf_pins ps_imem_ctrl/BRAM_PORTA]
  connect_bd_intf_net -intf_net rv_dmem_ctrl_BRAM_PORTA [get_bd_intf_pins dmem/BRAM_PORTA] [get_bd_intf_pins rv_dmem_ctrl/BRAM_PORTA]
  connect_bd_intf_net -intf_net rv_imem_ctrl_BRAM_PORTA [get_bd_intf_pins imem/BRAM_PORTA] [get_bd_intf_pins rv_imem_ctrl/BRAM_PORTA]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins rv_imem_ctrl/S_AXI] [get_bd_intf_pins smartconnect_0/M00_AXI]

  # Create port connections
  connect_bd_net -net ARESET_N_1 [get_bd_ports ARESET_N] [get_bd_pins rst_CLK_100M/ext_reset_in]
  connect_bd_net -net CLK_1 [get_bd_ports CLK] [get_bd_pins AXIGate_0/CLK] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_mem_intercon_1/ACLK] [get_bd_pins axi_mem_intercon_1/M00_ACLK] [get_bd_pins axi_mem_intercon_1/M01_ACLK] [get_bd_pins axi_mem_intercon_1/M02_ACLK] [get_bd_pins axi_mem_intercon_1/S00_ACLK] [get_bd_pins dexie_0/CLK] [get_bd_pins dmaOffset/CLK] [get_bd_pins piccolo32_0/clk] [get_bd_pins ps_dmem_ctrl/s_axi_aclk] [get_bd_pins ps_imem_ctrl/s_axi_aclk] [get_bd_pins rst_CLK_100M/slowest_sync_clk] [get_bd_pins rv_dmem_ctrl/s_axi_aclk] [get_bd_pins rv_imem_ctrl/s_axi_aclk] [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net dexie_0_irq [get_bd_ports interrupt] [get_bd_pins dexie_0/irq] [get_bd_pins piccolo32_0/nmi_req_set_not_clear]
  connect_bd_net -net dexie_0_rst [get_bd_pins dexie_0/rstn] [get_bd_pins piccolo32_0/RST_N]
  # Soft reset
  #  Connect Get interfaces with Put.
  #  Just connecting RDY of one side with EN of the other side is not enough, since one side can be ready while the other isn't.
  #   Setting EN in this case would force execution, i.e. causing reads from empty FIFOs or writes to full FIFOs.
  #  The DExIE side is always ready, since it just assigns Wires. Therefore, using the RDY signal of the Core as a ready condition for DExIE is enough.
  connect_bd_net [get_bd_pins dexie_0/RDY_cpu_reset_client_request_get] [get_bd_pins piccolo32_0/EN_cpu_reset_server_request_put]
  connect_bd_net [get_bd_pins dexie_0/EN_cpu_reset_client_request_get] [get_bd_pins dexie_0/cpu_reset_request_rdy_rdy] [get_bd_pins piccolo32_0/RDY_cpu_reset_server_request_put]
  connect_bd_net [get_bd_pins dexie_0/cpu_reset_client_request_get] [get_bd_pins piccolo32_0/cpu_reset_server_request_put]
  connect_bd_net [get_bd_pins dexie_0/RDY_cpu_reset_client_response_put] [get_bd_pins piccolo32_0/EN_cpu_reset_server_response_get]
  connect_bd_net [get_bd_pins dexie_0/EN_cpu_reset_client_response_put] [get_bd_pins dexie_0/cpu_reset_response_rdy_rdy] [get_bd_pins piccolo32_0/RDY_cpu_reset_server_response_get]
  connect_bd_net [get_bd_pins dexie_0/cpu_reset_client_response_put] [get_bd_pins piccolo32_0/cpu_reset_server_response_get]
  # Trace
  connect_bd_net [get_bd_pins dexie_0/RDY_trace_data_in_put] [get_bd_pins piccolo32_0/EN_trace_data_out_get]
  connect_bd_net [get_bd_pins dexie_0/EN_trace_data_in_put] [get_bd_pins dexie_0/trace_data_rdy_rdy] [get_bd_pins piccolo32_0/RDY_trace_data_out_get]
  connect_bd_net [get_bd_pins dexie_0/trace_data_in_put] [get_bd_pins piccolo32_0/trace_data_out_get]
  
  connect_bd_net [get_bd_pins dexie_0/RDY_dexie_cfdata_in_put] [get_bd_pins piccolo32_0/EN_dexie_cfdata_out_get]
  connect_bd_net [get_bd_pins dexie_0/EN_dexie_cfdata_in_put] [get_bd_pins dexie_0/dexie_cfdata_rdy_rdy] [get_bd_pins piccolo32_0/RDY_dexie_cfdata_out_get]
  connect_bd_net [get_bd_pins dexie_0/dexie_cfdata_in_put] [get_bd_pins piccolo32_0/dexie_cfdata_out_get]
  
  connect_bd_net [get_bd_pins dexie_0/RDY_dexie_dfmemdata_in_put] [get_bd_pins piccolo32_0/EN_dexie_dfmemdata_out_get]
  connect_bd_net [get_bd_pins dexie_0/EN_dexie_dfmemdata_in_put] [get_bd_pins dexie_0/dexie_dfmemdata_rdy_rdy] [get_bd_pins piccolo32_0/RDY_dexie_dfmemdata_out_get]
  connect_bd_net [get_bd_pins dexie_0/dexie_dfmemdata_in_put] [get_bd_pins piccolo32_0/dexie_dfmemdata_out_get]
  
  connect_bd_net [get_bd_pins dexie_0/RDY_dexie_dfregdata_in_put] [get_bd_pins piccolo32_0/EN_dexie_dfregdata_out_get]
  connect_bd_net [get_bd_pins dexie_0/EN_dexie_dfregdata_in_put] [get_bd_pins dexie_0/dexie_dfregdata_rdy_rdy] [get_bd_pins piccolo32_0/RDY_dexie_dfregdata_out_get]
  connect_bd_net [get_bd_pins dexie_0/dexie_dfregdata_in_put] [get_bd_pins piccolo32_0/dexie_dfregdata_out_get]
  
  connect_bd_net [get_bd_pins dexie_0/dexie_stall] [get_bd_pins piccolo32_0/dexie_stall_set_or_clear]
  connect_bd_net [get_bd_pins dexie_0/dexie_stallOnStore] [get_bd_pins piccolo32_0/dexie_stallOnStore_set_or_clear]
  connect_bd_net [get_bd_pins dexie_0/dexie_continueStore] [get_bd_pins piccolo32_0/dexie_continueStore_set_or_clear]
  
  connect_bd_net -net rst_CLK_100M_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_mem_intercon_1/ARESETN] [get_bd_pins rst_CLK_100M/interconnect_aresetn] [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net rst_CLK_100M_peripheral_aresetn [get_bd_pins AXIGate_0/RST_N] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_mem_intercon_1/M00_ARESETN] [get_bd_pins axi_mem_intercon_1/M01_ARESETN] [get_bd_pins axi_mem_intercon_1/M02_ARESETN] [get_bd_pins axi_mem_intercon_1/S00_ARESETN] [get_bd_pins dexie_0/RST_N] [get_bd_pins dmaOffset/RST_N] [get_bd_pins ps_dmem_ctrl/s_axi_aresetn] [get_bd_pins ps_imem_ctrl/s_axi_aresetn] [get_bd_pins rst_CLK_100M/peripheral_aresetn] [get_bd_pins rv_dmem_ctrl/s_axi_aresetn] [get_bd_pins rv_imem_ctrl/s_axi_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x00004000 -offset 0x11000000 [get_bd_addr_spaces AXIGate_0/maxi] [get_bd_addr_segs dexie_0/s_axi_ctrl/reg0] SEG_dexie_0_reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x00010000 [get_bd_addr_spaces dexie_0/m_axi_cpu_mem] [get_bd_addr_segs ps_dmem_ctrl/S_AXI/Mem0] SEG_ps_dmem_ctrl_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces dexie_0/m_axi_cpu_mem] [get_bd_addr_segs ps_imem_ctrl/S_AXI/Mem0] SEG_ps_imem_ctrl_Mem0
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces dmaOffset/M_AXI] [get_bd_addr_segs M_AXI/Reg] SEG_MAXI_Reg
  create_bd_addr_seg -range 0x00004000 -offset 0x11000000 [get_bd_addr_spaces piccolo32_0/cpu_dmem_master] [get_bd_addr_segs dexie_0/s_axi_ctrl/reg0] SEG_dexie_0_reg0
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces piccolo32_0/cpu_dmem_master] [get_bd_addr_segs dmaOffset/S_AXI/reg0] SEG_dmaOffset_reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x00010000 [get_bd_addr_spaces piccolo32_0/cpu_dmem_master] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces piccolo32_0/cpu_imem_master] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs AXIGate_0/saxi/reg0] SEG_AXIGate_0_reg0
  create_bd_addr_seg -range $range -offset 0x00000000 [get_bd_addr_spaces S_AXI_BRAM] [get_bd_addr_segs dexie_0/s_axi_bram/Mem0] SEG_dexie_0_Mem0
  save_bd_design
  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   "ExpandedHierarchyInLayout":"",
   "guistr":"# # String gsaved with Nlview 7.0.19  2019-03-26 bk=1.5019 VDI=41 GEI=35 GUI=JA:9.0 TLS
#  -string -flagsOSRD
preplace port M_AXI -pg 1 -lvl 9 -x 2860 -y 280 -defaultsOSRD
preplace port S_AXI_BRAM -pg 1 -lvl 0 -x 0 -y 550 -defaultsOSRD
preplace port S_AXI_CTRL -pg 1 -lvl 0 -x 0 -y 620 -defaultsOSRD
preplace port ARESET_N -pg 1 -lvl 0 -x 0 -y 190 -defaultsOSRD
preplace port CLK -pg 1 -lvl 0 -x 0 -y 110 -defaultsOSRD
preplace port interrupt -pg 1 -lvl 9 -x 2860 -y 630 -defaultsOSRD
preplace inst AXIGate_0 -pg 1 -lvl 3 -x 1030 -y 640 -defaultsOSRD
preplace inst axi_interconnect_0 -pg 1 -lvl 4 -x 1360 -y 730 -defaultsOSRD
preplace inst dmaOffset -pg 1 -lvl 5 -x 1770 -y 280 -defaultsOSRD
preplace inst axi_interconnect_1 -pg 1 -lvl 6 -x 2140 -y 640 -defaultsOSRD
preplace inst axi_mem_intercon_1 -pg 1 -lvl 3 -x 1030 -y 180 -defaultsOSRD
preplace inst dmem -pg 1 -lvl 8 -x 2730 -y 800 -defaultsOSRD
preplace inst imem -pg 1 -lvl 8 -x 2730 -y 450 -defaultsOSRD
preplace inst ps_dmem_ctrl -pg 1 -lvl 7 -x 2460 -y 710 -defaultsOSRD
preplace inst ps_imem_ctrl -pg 1 -lvl 7 -x 2460 -y 550 -defaultsOSRD
preplace inst rst_CLK_100M -pg 1 -lvl 1 -x 200 -y 210 -defaultsOSRD
preplace inst rv_dmem_ctrl -pg 1 -lvl 4 -x 1360 -y 180 -defaultsOSRD
preplace inst rv_imem_ctrl -pg 1 -lvl 4 -x 1360 -y 440 -defaultsOSRD
preplace inst smartconnect_0 -pg 1 -lvl 3 -x 1030 -y 420 -defaultsOSRD
preplace inst dexie_0 -pg 1 -lvl 5 -x 1770 -y 640 -defaultsOSRD
preplace inst piccolo32_0 -pg 1 -lvl 2 -x 600 -y 260 -defaultsOSRD
preplace netloc CLK_1 1 0 7 20 110 400 530 810 500 1200 280 1600 460 1990 500 2300
preplace netloc ARESET_N_1 1 0 1 NJ 190
preplace netloc rst_CLK_100M_interconnect_aresetn 1 1 5 390 560 870 720 1180 580 1580J 490 1950
preplace netloc rst_CLK_100M_peripheral_aresetn 1 1 6 380J 540 850 730 1210 300 1590 470 1960 490 2310
preplace netloc dexie_0_irq 1 5 4 1970J 470 NJ 470 2610J 630 NJ
preplace netloc dexie_0_rst 1 1 5 410 520 NJ 520 NJ 520 1540J 480 1940
preplace netloc piccolo32_0_dexie_next_instruction 1 2 3 860J 540 NJ 540 1540
preplace netloc piccolo32_0_dexie_pc 1 2 3 800J 560 NJ 560 1560
preplace netloc piccolo32_0_dexie_ra 1 2 3 840J 510 1180J 570 1510
preplace netloc piccolo32_0_dexie_data_instruction 1 2 3 820J 530 NJ 530 1550
preplace netloc piccolo32_0_dexie_data_addr 1 2 3 790J 20 NJ 20 1570
preplace netloc piccolo32_0_dexie_data_data 1 2 3 830J 340 NJ 340 1530
preplace netloc ps_dmem_ctrl_BRAM_PORTA 1 7 1 2600 710n
preplace netloc rv_dmem_ctrl_BRAM_PORTA 1 4 4 1590 200 NJ 200 NJ 200 2620J
preplace netloc ps_imem_ctrl_BRAM_PORTA 1 7 1 2600 460n
preplace netloc rv_imem_ctrl_BRAM_PORTA 1 4 4 N 440 NJ 440 NJ 440 NJ
preplace netloc axi_mem_intercon_1_M02_AXI 1 3 1 1190 200n
preplace netloc smartconnect_0_M00_AXI 1 3 1 N 420
preplace netloc axi_interconnect_1_M01_AXI 1 6 1 2290 650n
preplace netloc axi_mem_intercon_1_M01_AXI 1 3 2 1180 100 1600J
preplace netloc axi_interconnect_1_M00_AXI 1 6 1 2320 530n
preplace netloc axi_mem_intercon_1_M00_AXI 1 3 1 N 160
preplace netloc dmaOffset_M_AXI 1 5 4 NJ 280 NJ 280 NJ 280 NJ
preplace netloc S_AXI_CTRL_1 1 0 3 NJ 620 NJ 620 NJ
preplace netloc AXIGate_0_maxi 1 3 1 N 640
preplace netloc S_AXI_BRAM_1 1 0 5 NJ 550 NJ 550 NJ 550 NJ 550 NJ
preplace netloc dexie_0_m_axi_cpu_mem 1 5 1 1980 560n
preplace netloc piccolo32_0_mem_axi 1 2 1 880 60n
preplace netloc axi_interconnect_0_M00_AXI 1 4 1 1520 570n
levelinfo -pg 1 0 200 600 1030 1360 1770 2140 2460 2730 2860
pagesize -pg 1 -db -bbox -sgen -140 0 2980 880
"
}

  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_piccolo32_pe()
cr_bd_piccolo32_pe "" $addr_width $range
set bd_file [get_files piccolo32_pe.bd]
#make_wrapper -files $bd_file -top
#add_files -norecurse [file join piccolo32_pe_wrapper.v]
set_property synth_checkpoint_mode Singular $bd_file
generate_target all $bd_file




source package_dexie_pe.tcl
