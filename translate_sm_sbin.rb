#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#
# Salome-Meca 2011.2 日本語化変換テーブルファイル作成用
# ライブラリファイル
#
require "#{File.dirname(File.expand_path(__FILE__))}/translate_sm_sbin_lib"

module TranslateSMsbin
	module_function
	def usage()
	end
end
if $0==__FILE__ then
	TranslateLIB.init()
	TranslateSMLIB.init()
	sTestOutputLogFilePath = "./test.log"
	sTestOutputLog2FilePath = "./test2.log"
	coParentDicListsByFr = TranslateDicListsByFr.new()
	coParentDicListsByEn = TranslateDicListsByEn.new()
	sDicFilePath="#{TranslateSMsbinLIB::OLD_DIC_FILE_PATH}"
	sDicFilePath2="#{TranslateSMsbinLIB::OLD_DIC_FILE_PATH_2}"
	IO.foreach(sDicFilePath) do |sLine|
		sLine.chomp!
		aFactor = sLine.split(/\t/)
		TranslateKeywordFr.new(aFactor, aFactor[2], coParentDicListsByFr, coParentDicListsByEn)
	end
	IO.foreach(sDicFilePath2) do |sLine|
		sLine.chomp!
		aFactor = sLine.split(/\t/)
		TranslateKeywordFr.new(aFactor, aFactor[2], coParentDicListsByFr, coParentDicListsByEn)
	end
	fTestOutputLogFile = File.new(sTestOutputLogFilePath, "w")
		coParentDicListsByFr.disp(STDERR)
		coParentDicListsByEn.disp(fTestOutputLogFile)
	fTestOutputLogFile.close

	coTranslateSummaries = TranslateSummaries.new()
#	STDERR.puts "Check1"
	aFileDirs = Array.new(ARGV)
	aFileDirs = ["."] if aFileDirs.size == 0
#	STDERR.puts "Check2(#{aFileDirs})"
	hQmFileBaseNamePath = Hash.new()
	for sFileDir in aFileDirs 
		#TranslateSMsbinLIB.traverse_make_dic_file_exec(sFileDir, coTranslateSummaries)
		TranslateSMsbinLIB.traverse_make_dic_file_from_current_version_exec(sFileDir, hQmFileBaseNamePath, coTranslateSummaries)
	end

#coTranslateSummaries.print(STDERR)
#STDERR.puts "SummariesList is Done."
#TranslateSMsbinLIB.pause(STDERR)
	TranslateSMsbinLIB.translate_from_class_for_current_version(coTranslateSummaries, coParentDicListsByFr, coParentDicListsByEn)
	fTestOutputLog2File = File.new(sTestOutputLog2FilePath, "w")
		coTranslateSummaries.print(STDERR)
		coTranslateSummaries.print(fTestOutputLog2File)
	fTestOutputLog2File.close
	fOutputFile = File.new(TranslateSMsbinLIB::OUTPUT_DIC_FILE_PATH, "w")
		TranslateSMLIB.output_dic_summary_with_group(coTranslateSummaries, fOutputFile)
	fOutputFile.close
end

