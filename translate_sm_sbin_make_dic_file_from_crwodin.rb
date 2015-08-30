#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-

require "#{File.dirname(File.expand_path(__FILE__))}/translate_sm_sbin_lib"
require "pp"

SALOME_OUTPUT_VERSION="2015.1"
SALOME_DIC_FILE_PATH="/home/takeru/bin/to_japanese_#{SALOME_OUTPUT_VERSION}/to_japanese/dic/org/summary_translate_word_from_crowdin_#{SALOME_OUTPUT_VERSION}.dic"


if $0==__FILE__ then
	TranslateSMLIB.init()
	sTestOutputLogFilePath = "./test_crowdin.log"
	sTestOutputLog2FilePath = "./test_crowdin2.log"

	#aTSFileList = TranslateSMsbinLIB.list_up_make_dic_file_from_crowdin_fr_ts_file()
	coTranslateSummaries = TranslateSMsbinLIB.import_from_crowdin_to_summaries_class()

	PP.pp(coTranslateSummaries, STDERR)

	sOutputFilePath = SALOME_DIC_FILE_PATH
	sOutputFilePath = ARGV.shift if ARGV.size > 0
	fOutputFile = File.new(sOutputFilePath, "w")
		TranslateSMLIB.output_dic_summary_with_group(coTranslateSummaries, fOutputFile)
	fOutputFile.close
end
	
