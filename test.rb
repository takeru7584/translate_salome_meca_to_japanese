#!/usr/bin/ruby1.9.1
require "./translate_sm_lib.rb"

if $0 == __FILE__ then
	TranslateSMLIB.init()
	STDERR.puts "h_opts_list = #{TranslateSMLIB.h_opts_list}"
	STDERR.puts "disp_version = #{TranslateSMLIB.disp_version}"
	STDERR.puts "disp_help = #{TranslateSMLIB.disp_help}"
	STDERR.puts "dic_file = #{TranslateSMLIB.dic_file}"
	STDERR.puts "udic_file = #{TranslateSMLIB.udic_file}"
	STDERR.puts "log_level = #{TranslateSMLIB.log_level}"
	STDERR.puts "log_file = #{TranslateSMLIB.log_file}"
	STDERR.puts "debug_mode = #{TranslateSMLIB.debug_mode}"
	STDERR.puts "quiet_mode = #{TranslateSMLIB.quiet_mode}"
	TranslateSMLIB.exec_disp_version() if TranslateSMLIB.disp_version == true
	TranslateSMLIB.disp_usage() if TranslateSMLIB.disp_help == true
	STDERR.puts
	STDERR.puts "ErrorLevelCheck"
	for nI in 0..19 
		TranslateSMLIB.err_print(nI, "Check ErrorLevel#{nI}", STDERR)
	end
end
