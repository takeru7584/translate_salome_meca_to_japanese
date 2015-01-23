#!/usr/bin/ruby1.9.1
## -*- coding:utf-8 -*-
#
require "#{File.expand_path(File.dirname(__FILE__))}/translate_sm_lib.rb"

if $0 == __FILE__ then
	sFilePath = TranslateSMLIB::DEFAULT_DIC_FILE_PATH
	sFilePath = ARGV.first if ARGV.size > 0
	sTempOutputFilePath1 = "#{ENV["HOME"]}/dic_summaries_test.txt"
	sTempOutputFilePath2 = "#{ENV["HOME"]}/dic_keywords_test.txt"
	coSummaries = TranslateSMLIB.input_dic_file(sFilePath)
	coKeywords = TranslateSMLIB.input_dic_file_to_cokeywords(sFilePath)
	fTempOutputFile1 = File.new(sTempOutputFilePath1,"w")
		coSummaries.print(fTempOutputFile1)
	fTempOutputFile1.close
	fTempOutputFile2 = File.new(sTempOutputFilePath2,"w")
		coKeywords.print(fTempOutputFile2)
	fTempOutputFile2.close
end

