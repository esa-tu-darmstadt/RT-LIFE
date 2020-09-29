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

open_project taiga_pe/taiga_pe.xpr
set _xil_proj_name_ "taiga_pe"


set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
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

ipx::package_project -root_dir dexie_ip -vendor esa.informatik.tu-darmstadt.de -library dexie -taxonomy /UserIP -module "${_xil_proj_name_}" -import_files -generated_files -force
set_property supported_families {virtex7 Beta qvirtex7 Beta kintex7 Beta kintex7l Beta qkintex7 Beta qkintex7l Beta artix7 Beta artix7l Beta aartix7 Beta qartix7 Beta zynq Beta qzynq Beta azynq Beta spartan7 Beta aspartan7 Beta virtexu Beta virtexuplus Beta kintexuplus Beta zynquplus Beta kintexu Beta} [ipx::current_core]
set core [ipx::current_core]
set_property name "${_xil_proj_name_}_dexie" $core
set_property name INTERRUPT [ipx::get_bus_interfaces INTR.INTERRUPT -of_objects $core]
set_property name ARESET_N [ipx::get_bus_interfaces RST.ARESET_N -of_objects $core]
set_property name CLK [ipx::get_bus_interfaces CLK.CLK -of_objects $core]
ipx::remove_bus_parameter PHASE [ipx::get_bus_interfaces CLK -of_objects $core]
ipx::remove_bus_parameter FREQ_HZ [ipx::get_bus_interfaces CLK -of_objects $core]
#set_property name Mem0 [ipx::get_address_blocks Reg0 -of_objects [ipx::get_memory_maps S_AXI_BRAM -of_objects $core]]
set_property core_revision 2 $core
ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core
set_property  ip_repo_paths  "[file normalize "$tapasco_riscv_dir/IP/AXIGate"] [file normalize "$tapasco_riscv_dir/IP/axi_offset"] [file normalize "$origin_dir/ip"] [file normalize "$origin_dir/core/IP"]" [current_project]
update_ip_catalog
ipx::check_integrity -quiet $core
ipx::archive_core "dexie_ip/esa.informatik.tu-darmstadt.de_dexie_${_xil_proj_name_}_dexie_1.0.zip" $core
ipx::unload_core component_1
