proc alt_vipitc131_get_timequest_name {hier_name} {
	set sta_name ""
	for {set inst_start [string first ":" $hier_name]} {$inst_start != -1} {set inst_start [string first ":" $hier_name $inst_start]} {
		incr inst_start
		set inst_end [string first "|" $hier_name $inst_start]
		if {$inst_end == -1} {
			append sta_name [string range $hier_name $inst_start end]
		} else {
			append sta_name [string range $hier_name $inst_start $inst_end]
		}
	}
	return $sta_name
}

proc alt_vipitc131_get_core_instance_list {corename} {
	set full_instance_list [alt_vipitc131_get_core_full_instance_list $corename]
	set instance_list [list]

	foreach inst $full_instance_list {
		set sta_name [alt_vipitc131_get_timequest_name $inst]
		if {[lsearch $instance_list $sta_name] == -1} {
			lappend instance_list $sta_name
		}
	}
	return $instance_list
}

proc alt_vipitc131_get_core_full_instance_list {corename} {
	set instance_list [list]

	# Look for a keeper (register) name
	# Try mem_clk[0] to determine core instances
	set search_list [list "*"]
	set found 0
	for {set i 0} {$found == 0 && $i != [llength $search_list]} {incr i} {
		set pattern [lindex $search_list $i]
		set instance_collection [get_keepers -nowarn "*|${corename}:*|$pattern"]
		if {[get_collection_size $instance_collection] == 0} {
			set instance_collection [get_keepers "${corename}:*|$pattern"]
		}
		if {[get_collection_size $instance_collection] > 0} {
			set found 1
		}
	}
	# regexp to extract the full hierarchy path of an instance name
	set inst_regexp {(^.*}
	append inst_regexp ${corename}
	append inst_regexp {:[A-Za-z0-9\.\\_\[\]\-\$()]+)\|}
	foreach_in_collection inst $instance_collection {
		set name [get_node_info -name $inst]
		if {[regexp -- $inst_regexp $name -> hier_name] == 1} {
			if {[lsearch $instance_list $hier_name] == -1} {
				lappend instance_list $hier_name
			}
		}
	}
	return $instance_list
}

set corename "alt_vipitc131_IS2Vid"
set instance_list [alt_vipitc131_get_core_instance_list $corename]
foreach inst $instance_list {
	post_message -type info "Adding SDC requirements for $corename instance $inst"
    set_multicycle_path -setup -start -through [get_nets "${inst}|mode_banks|u_calculate_mode_dynamic|*"] 2
    set_multicycle_path -hold -start -through [get_nets "${inst}|mode_banks|u_calculate_mode_dynamic|*"] 1
}

set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_mode_match[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_interlaced[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_serial_output[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_sample_count[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_line_count_f0[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_line_count_f1[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_h_front_porch[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_h_sync_length[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_h_blank[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_v_front_porch[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_v_sync_length[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_v_blank[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_v1_front_porch[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_v1_sync_length[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_v1_blank[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_ap_line[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_v1_rising_edge[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_f_rising_edge[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_f_falling_edge[*][*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_standard[*][*}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_sof_sample[*][*}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_sof_subsample[*][*}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_sof_line[*][*}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_vcoclk_divider_value[*][*}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_anc_line[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_v1_anc_line[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|is_valid_mode[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|dirty_mode[*]}]

set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|rst_vid_clk_reg}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_sync:clear_underflow_sticky_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_sync:enable_resync_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_sync:enable_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_sync:genlocked_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_sync:genlock_enable_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_sync:underflow_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_trigger_sync:av_waitrequest_trigger_sync|alt_vipitc131_common_sync:toggle_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_trigger_sync:av_write_trigger_sync|alt_vipitc131_common_sync:toggle_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_trigger_sync:mode_change_trigger_sync|alt_vipitc131_common_sync:toggle_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_sync:sync_generation_generate.sof_cvi_locked_sync|data_out_sync0[*]}]
set_false_path -to [get_keepers {*alt_vipitc131_IS2Vid:*|alt_vipitc131_common_sync:sync_generation_generate.sof_cvi_sync|data_out_sync0[*]}]
