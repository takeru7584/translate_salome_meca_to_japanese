#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
require "#{File.dirname(File.expand_path(__FILE__))}/translate_sm_sbin_lib"

if $0 == __FILE__ then
	exit 1 unless ARGV.size > 1
	sBaseInputFilePath = "#{ARGV[0]}"
	sAddInputFilePath = "#{ARGV[1]}"
	TranslateSMsbinLIB.merge_dic_files(sBaseInputFilePath, sAddInputFilePath, true)
end
