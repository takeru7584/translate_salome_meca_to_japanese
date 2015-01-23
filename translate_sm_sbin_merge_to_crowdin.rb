#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#
require "#{File.dirname(File.expand_path(__FILE__))}/translate_sm_sbin_lib"

SALOME_CURRENT_VERSION="2013.1"
SALOME_DIC_FILE_PATH="/home/takeru/bin/to_japanese_#{SALOME_CURRENT_VERSION}/to_japanese/dic/org/summary_translate_word_#{SALOME_CURRENT_VERSION}.dic"

if $0==__FILE__ then
	TranslateSMLIB.init()
	sTestOutputLogFilePath = "./test_crowdin.log"
	sTestOutputLog2FilePath = "./test_crowdin2.log"

	aTargetFilePaths = ["."]
	aTargetFilePaths = Array.new(ARGV) unless ARGV.size == 0

	aCurrentDicFilePath = SALOME_DIC_FILE_PATH

	coCurrentSummaries = TranslateSMLIB.input_dic_file_with_group(aCurrentDicFilePath)

	coCurrentSummaries.print(STDERR)

	coNewSummaries = TranslateSummaries.new()
	hQmFileBaseNamePath=Hash.new()
	for sTargetFilePath in aTargetFilePaths
		#sFrFilePath = sJaFilePath.gsub(/\/ja\//,"/fr/")
		#sFrFilePath.gsub!(/_msg_ja.ts$/, "msg_fr.ts")
		#sEnFilePath = sJaFilePath.gsub(/\/en\//,"/fr/")
		#sEnFilePath.gsub!(/_msg_ja.ts$/, "msg_en.ts")

		TranslateSMsbinLIB.traverse_merge_from_dic_summaries_to_crowdin_ts_file(sTargetFilePath, coCurrentSummaries)

	end
end

