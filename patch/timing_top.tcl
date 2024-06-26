source $::env(TIMING_ROOT)/env/common.tcl
source $::env(TIMING_ROOT)/env/caravel_spef_mapping-mpw7.tcl

if { [file exists $::env(CUP_ROOT)/env/spef-mapping.tcl] } {
    source $::env(CUP_ROOT)/env/spef-mapping.tcl
} else {
    puts "WARNING no user project spef mapping file found"
}

foreach liberty $pdk(libs) {
}

foreach liberty $pdk(libs) {
    run_puts "read_liberty $liberty"
}

foreach verilog $verilogs {
    run_puts "read_verilog $verilog"
}

run_puts "link_design caravel"

if { $::env(SPEF_OVERWRITE) ne "" } {
    puts "overwriting spef from "
    puts "$spef to"
    puts "$::env(SPEF_OVERWRITE)"
    eval set spef $::env(SPEF_OVERWRITE)
}

set missing_spefs 0
set missing_spefs_list ""

if { [file exists $spef] } {
    run_puts "read_spef $spef"
} else {
    set missing_spefs 1
    set missing_spefs_list "$missing_spefs_list $::env(BLOCK)"
    puts "$spef not found"
    if { $::env(ALLOW_MISSING_SPEF) } {
        puts "WARNING ALLOW_MISSING_SPEF set to 1. continuing"
    } else {
        exit 1
    }
}

foreach key [array names spef_mapping] {
    set spef_file $spef_mapping($key)
    if { [file exists $spef_file] } {
        run_puts "read_spef -path $key $spef_mapping($key)"
    } else {
        set missing_spefs 1
        set missing_spefs_list "$missing_spefs_list $key"
        puts "$spef_file not found"
        if { $::env(ALLOW_MISSING_SPEF) } {
            puts "WARNING ALLOW_MISSING_SPEF set to 1. continuing"
        } else {
            exit 1
        }
    }
}

set sdc $::env(CARAVEL_ROOT)/signoff/caravel/caravel.sdc
run_puts "read_sdc -echo $sdc"

set logs_path "$::env(PROJECT_ROOT)/signoff/caravel/openlane-signoff/timing/$::env(LIB_CORNER)-$::env(RCX_CORNER)"
file mkdir $logs_path

proc check_reg_to_reg_min {report} {
    set result [exec python3 \
            $::env(TIMING_ROOT)/scripts/get_violations.py \
            --type "min" \
            -a \
            ${report}]
    return $result
}

proc check_reg_to_reg_max {report} {
    set result [exec python3 \
            $::env(TIMING_ROOT)/scripts/get_violations.py \
            --type "max" \
            -a \
            ${report}]
    return $result
}

set reports ""


if {!$::env(TIMING_USER_REPORTS)} {

    run_puts_logs "report_checks \\
        -path_delay min \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -group_count 10000 \\
        -slack_max 10 \\
        -digits 2 \\
        -endpoint_count 10 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/min.rpt"
    lappend reports "${logs_path}/min.rpt"

    run_puts_logs "report_checks \\
        -path_delay max \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -group_count 10000 \\
        -slack_max 10 \\
        -digits 2 \\
        -endpoint_count 10 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/max.rpt"
    lappend reports "${logs_path}/max.rpt"

    run_puts_logs "report_checks \\
        -path_delay min \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -path_group hk_serial_clk \\
        -group_count 1000 \\
        -slack_max 10 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/hk_serial_clk-min.rpt"
    lappend reports "${logs_path}/hk_serial_clk-min.rpt"

    run_puts_logs "report_checks \\
        -path_delay max \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -path_group hk_serial_clk \\
        -group_count 1000 \\
        -slack_max 10 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/hk_serial_clk-max.rpt"
    lappend reports "${logs_path}/hk_serial_clk-max.rpt"

    run_puts_logs "report_checks \\
        -path_delay max \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -path_group hkspi_clk \\
        -group_count 1000 \\
        -slack_max 10 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/hkspi_clk-max.rpt"
    lappend reports "${logs_path}/hkspi_clk-max.rpt"

    run_puts_logs "report_checks \\
        -path_delay min \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -path_group hkspi_clk \\
        -group_count 1000 \\
        -slack_max 10 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/hkspi_clk-min.rpt"
    lappend reports "${logs_path}/hkspi_clk-min.rpt"

    run_puts_logs "report_checks \\
        -path_delay min \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -path_group clk \\
        -group_count 1000 \\
        -slack_max 10 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/clk-min.rpt"
    lappend reports "${logs_path}/clk-min.rpt"

    run_puts_logs "report_checks \\
        -path_delay max \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -path_group clk \\
        -group_count 1000 \\
        -slack_max 10 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/clk-max.rpt"
    lappend reports "${logs_path}/clk-max.rpt"

    run_puts_logs "report_checks \\
        -path_delay min \\
        -through [get_cells chip_core/mprj] \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -group_count 1000 \\
        -slack_max 40 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/mprj-min.rpt"
    lappend reports "${logs_path}/mprj-min.rpt"

    run_puts_logs "report_checks \\
        -path_delay max \\
        -through [get_cells chip_core/mprj] \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -group_count 1000 \\
        -slack_max 40 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/mprj-max.rpt"
    lappend reports "${logs_path}/mprj-max.rpt"

    set summary_report ${logs_path}/summary.log
    run_puts_logs "report_check_types \\
        -max_slew \\
        -max_capacitance \\
        -format end \\
        -violators" \
        "${summary_report}"

    set worst_hold "[exec python3 $::env(TIMING_ROOT)/scripts/get_worst.py -i ${logs_path}/min.rpt]"
    set worst_setup "[exec python3 $::env(TIMING_ROOT)/scripts/get_worst.py -i ${logs_path}/max.rpt]"

    exec python3 $::env(TIMING_ROOT)/scripts/generate_async_paths_summary.py \
        --min ${logs_path}/min.rpt \
        --max ${logs_path}/max.rpt \
        -o $summary_report -a

} else {

    run_puts_logs "report_checks \\
        -path_delay min \\
        -through [get_cells chip_core/mprj] \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -group_count 1000 \\
        -slack_max 40 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/mprj-min.rpt"
    lappend reports "${logs_path}/mprj-min.rpt"

    run_puts_logs "report_checks \\
        -path_delay max \\
        -through [get_cells chip_core/mprj] \\
        -format full_clock_expanded \\
        -fields {slew cap input_pins nets fanout} \\
        -no_line_splits \\
        -group_count 1000 \\
        -slack_max 40 \\
        -digits 2 \\
        -unique_paths_to_endpoint \\
        "\
        "${logs_path}/mprj-max.rpt"
    lappend reports "${logs_path}/mprj-max.rpt"

    set summary_report ${logs_path}/summary.log
    run_puts_logs "report_check_types \\
        -max_slew \\
        -max_capacitance \\
        -format end \\
        -violators" \
        "${summary_report}"

    exec python3 $::env(TIMING_ROOT)/scripts/trim_violators.py -i $summary_report -o ${summary_report}.new
    file rename -force ${summary_report} ${summary_report}.untrimmed
    file rename -force ${summary_report}.new $summary_report

    set worst_hold "[exec python3 $::env(TIMING_ROOT)/scripts/get_worst.py -i ${logs_path}/mprj-min.rpt]"
    set worst_setup "[exec python3 $::env(TIMING_ROOT)/scripts/get_worst.py -i ${logs_path}/mprj-max.rpt]"

    exec python3 $::env(TIMING_ROOT)/scripts/generate_async_paths_summary.py \
        --min ${logs_path}/mprj-min.rpt \
        --max ${logs_path}/mprj-max.rpt \
        -o $summary_report -a
}


run_puts "report_parasitic_annotation -report_unannotated > ${logs_path}/unannotated.log"

set max_delay_result "met"
set min_delay_result "met"
set max_slew_result "met"
set max_cap_result "met"
set missing_spefs_result "incomplete"
set min_reg_to_reg_result "met"
set max_reg_to_reg_result "met"

set max_cap_value "[exec bash -c "grep 'max cap' $summary_report -A 4 | tail -n1 | awk -F '  *' '{print \$4}'"]"
set max_slew_value "[exec bash -c "grep 'max slew' $summary_report -A 4 | tail -n1 | awk -F '  *' '{print \$4}'"]"

set table_format "%7s| %13s |%13s |%13s |%13s |%13s |%13s"
set separator ""
set header [format "$table_format" \
    "corner" \
    "min delay" \
    "min reg2reg" \
    "max delay" \
    "max reg2reg" \
    "max cap" \
    "max slew"]
foreach char [split $header ""] {
    set separator "$separator-"
}
if {![catch {exec grep -q {max cap} $summary_report} err]} {
    set max_cap_result "vio($max_cap_value)"
}

if {![catch {exec grep -q {max slew} $summary_report} err]} {
    set max_slew_result "vio($max_slew_value)"
}

if { [exec python3 -c "print($worst_hold<0)"] eq "True" } {
    set min_delay_result "vio($worst_hold)"
}

if { [exec python3 -c "print($worst_setup<0)"] eq "True" } {
    set max_delay_result "vio($worst_setup)"
}

if { !$missing_spefs } {
    set missing_spefs_result "complete"
}

set vio "0"
set min_vio "0"
set violating_min_reports ""
foreach report $reports {
    set vio [check_reg_to_reg_min $report]
    if { [exec python3 -c "print($vio<0)"] eq "True" } {
        set violating_min_reports "$violating_min_reports $report"
    }
    set min_vio [exec python3 -c "print(f'{min($vio, $min_vio):.2f}')"]
}
if { [exec python3 -c "print($min_vio<0)"] eq "True" } {
    set min_reg_to_reg_result "vio($min_vio)"
}

set vio "0"
set min_vio "0"
set violating_max_reports ""
foreach report $reports {
    set vio [check_reg_to_reg_max $report]
    if { [exec python3 -c "print($vio<0)"] eq "True" } {
        set violating_max_reports "$violating_max_reports $report"
    }
    set min_vio [exec python3 -c "print(f'{min($vio, $min_vio):.2f}')"]
}
if { [exec python3 -c "print($min_vio<0)"] eq "True" } {
    set max_reg_to_reg_result "vio($min_vio)"
}

set summary [format "$table_format" "$::env(LIB_CORNER)-$::env(RCX_CORNER)"\
    "$min_delay_result" \
    "$min_reg_to_reg_result" \
    "$max_delay_result" \
    "$max_reg_to_reg_result" \
    "$max_cap_result" \
    "$max_slew_result"]

exec echo "$separator" > "${summary_report}-tmp-table"
exec echo "SUMMARY" >> "${summary_report}-tmp-table"
exec echo "$separator" >> "${summary_report}-tmp-table"
exec echo "" >> "${summary_report}-tmp-table"
exec echo "$header" >> "${summary_report}-tmp-table"
exec echo "$separator" >> "${summary_report}-tmp-table"
exec echo "$summary" >> "${summary_report}-tmp-table"
exec echo "" >> "${summary_report}-tmp-table"
exec echo "violating reg2reg min reports\n${violating_min_reports}\n" >> "${summary_report}-tmp-table"
exec echo "violating reg2reg max reports\n${violating_max_reports}\n" >> "${summary_report}-tmp-table"
exec cat ${summary_report}-tmp-table ${summary_report} > ${summary_report}-tmp
exec mv ${summary_report}-tmp ${summary_report}
exec rm ${summary_report}-tmp-table

report_parasitic_annotation

if { $missing_spefs } {
    puts "there are missing spefs. check the log for ALLOW_MISSING_SPEF"
    puts "the following macros don't have spefs"
    foreach spef $missing_spefs_list {
        puts "$spef"
    }
}

puts "you may want to edit sdc: $sdc to change i/o constraints"
puts "check $logs_path"
