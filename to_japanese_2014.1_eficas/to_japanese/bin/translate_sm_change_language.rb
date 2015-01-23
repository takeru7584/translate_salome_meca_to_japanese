#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#
# Salome-Meca 2010.2 言語設定スクリプト v0.09a
#
# Created by Takeru on 2012.8.5
#
require "#{File.expand_path(File.dirname(__FILE__))}/translate_sm_lib.rb"
require "getoptlong"

############################################################################################
#
# Main Routin
#
############################################################################################
if $0 == __FILE__ then
	TranslateSMLIB.init()
        # defaultファイルパスをカレントディレクトリに設定
        TranslateSMLIB.exec_disp_version() if TranslateSMLIB.disp_version == true
        TranslateSMLIB.disp_usage() if TranslateSMLIB.disp_help == true
	sSetLanguage = "en"
	sSetLanguage = ARGV[0] unless ARGV.size == 0

	TranslateSMLIB.change_language(sSetLanguage)
end

