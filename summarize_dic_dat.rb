#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#module TranslateLIB
require "#{File.expand_path(File.dirname(__FILE__))}/translate_sm_lib.rb"

if $0 == __FILE__ then
	aStartFilePathes = [Dir.getwd()]
	aStartFilePathes = Array.new(ARGV) if ARGV.size != 0
	coDicSummaries = TranslateSummaries.new()
	for sStartFilePath in aStartFilePathes
		coDicSummaries = TranslateSMLIB.summarize_recursively(coDicSummaries, sStartFilePath)
	end
	sOutputFilePath = "summary_translate_word.dic"
	fOutputFile = File.new(sOutputFilePath,"w")
#		TranslateSMLIB.output_dic_summary(coDicSummaries, STDOUT)
		TranslateSMLIB.output_dic_summary(coDicSummaries, fOutputFile)
	fOutputFile.close
end

