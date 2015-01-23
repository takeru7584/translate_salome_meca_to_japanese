#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#

require "#{File.expand_path(File.dirname(__FILE__))}/translate_sm_lib.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/translate_sm.rb"
require "getoptlong"


if $0 == __FILE__ then
	TranslateSMLIB.init()

	TranslateSMLIB.exec_disp_version() if TranslateSMLIB.disp_version == true
	TranslateSMLIB.disp_usage() if TranslateSMLIB.disp_help == true

	#sDicFilePath = TranslateSMLIB.dic_file

	#sUserDicFilePath = TranslateSMLIB.udic_file

	sDicFilePath = "./to_japanese/to_japanese/dic/org/summary_translate_word_2013.1.dic"
	sUserDicFilePath = "./to_japanese/to_japanese/dic/summary_translate_word_user.dic"
	coSummaries = TranslateSMLIB.input_dic_file_with_group(sDicFilePath)
	coSummaries = TranslateSMLIB.input_dic_file_with_group(sUserDicFilePath, coSummaries, true)

	coSummaries.print(STDERR)

	PP.pp(coSummaries, STDERR)

end

