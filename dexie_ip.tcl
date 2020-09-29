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

create_project -force dummy dummy -part xc7z020clg400-1
set ipname dexie
if { $::argc >= 1 } {
	append ipname _[lindex $::argv 0]
}
ipx::infer_core -vendor esa.informatik.tu-darmstadt.de -library dexie -taxonomy /UserIP IP
ipx::edit_ip_in_project -upgrade true -name edit_ip_project -directory dummy.tmp IP/component.xml
ipx::current_core IP/component.xml
set_property name "${ipname}" [ipx::current_core]
update_compile_order -fileset sources_1
ipx::remove_bus_interface rst [ipx::current_core]
ipx::remove_bus_interface rstn [ipx::current_core]
set_property name Mem0 [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_bram -of_objects [ipx::current_core]]]
set_property usage memory [ipx::get_address_blocks Mem0 -of_objects [ipx::get_memory_maps s_axi_bram -of_objects [ipx::current_core]]]
set_property previous_version_for_upgrade "esa.informatik.tu-darmstadt.de:dexie:${ipname}:1.0" [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core "IP/esa.informatik.tu-darmstadt.de_dexie_${ipname}_1.0.zip" [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
set_property  ip_repo_paths IP [current_project]
update_ip_catalog
exit
