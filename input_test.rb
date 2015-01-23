#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
require "#{File.dirname(File.expand_path(__FILE__))}/translate_sm_sbin_lib"

TranslateSMLIB.init()
if $0 == __FILE__ then
	exit 1 unless ARGV.size > 0
	sBaseInputFilePath = "#{ARGV[0]}"
	STDERR.puts "#{sBaseInputFilePath}:"
	TranslateSMLIB.input_dic_file(sBaseInputFilePath)
end
