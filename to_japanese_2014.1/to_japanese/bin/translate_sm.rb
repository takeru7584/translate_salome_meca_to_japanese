#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#
# Salome-Meca 2012.1 日本語化開発スクリプト v0.07a
#
# Created by Takeru on 2012.2.10
# modified by Takeru on 2012.3.31
# modified by Takeru on 2012.4.29
# modified by Takeru on 2012.5.13
#
require "#{File.expand_path(File.dirname(__FILE__))}/translate_sm_lib.rb"
require "getoptlong"

module TranslateSM
	##############################
	#
	# 定数宣言
	#
	##############################
	# コマンドラインオプション用（作成中）
	A_TRANSLATE_SM_OPTION_VERSION = ["--version", "-v", GetoptLong::NO_ARGUMENT ]
	A_TRANSLATE_SM_OPTION_HELP = [ "--help", "-?", GetoptLong::NO_ARGUMENT ],
	A_TRALSLATE_SM_OPTION_DIC_FILE = [ "--dic-file", "-f", GetoptLong::REQUIRED_ARGUMENT ],
	A_TRALSLATE_SM_OPTION_USER_DIC_FILE = [ "--udic-file", "-u", GetoptLong::REQUIRED_ARGUMENT ],
	A_TRANSLATE_SM_OPTION_LOG_LEVEL = [ "--log-level", "-l", GetoptLong::REQUIRED_ARGUMENT ],
	A_TRANSLATE_SM_OPTION_LOG_FILE = [ "--log-file", "-o", GetoptLong::REQUIRED_ARGUMENT ],
	A_TRANSLATE_SM_OPTION_DEBUG = [ "--debug", "-d", GetoptLong::NO_ARGUMENT	]
	A_TRANSLATE_SM_OPTION_QUIET = [ "--quiet", "-q", GetoptLong::NO_ARGUMENT	]

	module_function
	###############################
	# TranslateSM::init_option
	# コマンドラインオプション初期化関数（作成中）
	#
	# 概要：
	# 　コマンドラインオプション用GetoptLongオブジェクトを初期化します。
	#   (作成中)
	###############################
	def init_option()
		coOpts = GetoptLong.new(
			A_TRANSLATE_SM_OPTION_VERSION,
			A_TRANSLATE_SM_OPTION_HELP,
			A_TRANSLATE_SM_OPTION_DIC_FILE,
			A_TRANSLATE_SM_OPTION_USER_DIC_FILE,
			A_TRANSLATE_SM_OPTION_LOG_LEVEL,
			A_TRANSLATE_SM_OPTION_LOG_FILE,
			A_TRANSLATE_SM_OPTION_DEBUG,
			A_TRANSLATE_SM_OPTION_QUIET
		)
		return coOpts
	end

	###############################
	# TranslateSM::get_option
	# コマンドラインオプション取得関数
	#
	# 概要：
	# 　コマンドラインオプションを取得します。
	#   (作成中)
	###############################
	def get_option()
		coOpts = init_option()
		hOptsList = Hash.new()
		coOpts.each do |sOpt, sArg|
			hOptsList[sOpt] = sArg
			return hOptsList
		end

	end
end

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
	aFilePath = ["."]
	# コマンド引数を処理対象ファイルパス配列に格納
	aFilePath = Array.new(ARGV) unless ARGV.size == 0
#	sFilePath = TranslateSMLIB::DEFAULT_DIC_FILE_PATH
	#	翻訳辞書ファイルから翻訳辞書オブジェクト（TranslateSummaries）を作成
	# 翻訳辞書ファイルの設定
	sDicFilePath = TranslateSMLIB.dic_file

	# Crowdin翻訳辞書ファイルの設定
	sCrowdinDicFilePath = TranslateSMLIB.crowdin_dic_file

	# eficas翻訳辞書ファイルの設定
	sEficasDicFilePath = TranslateSMLIB.eficas_dic_file

	# 翻訳ユーザ辞書ファイルの設定
	sUserDicFilePath = TranslateSMLIB.udic_file

	coSummaries = TranslateSMLIB.input_dic_file_with_group(sDicFilePath)
	coSummaries = TranslateSMLIB.input_dic_file_with_group(sCrowdinDicFilePath, coSummaries, true)
	coSummaries = TranslateSMLIB.input_dic_file_with_group(sEficasDicFilePath, coSummaries, true)
	coSummaries = TranslateSMLIB.input_dic_file_with_group(sUserDicFilePath, coSummaries, true)

	coSummaries.print(STDERR)
	##	翻訳辞書ファイルから翻訳辞書オブジェクト（TranslateDicLists）を作成
	##coKeywords = TranslateSMLIB.input_dic_file_to_cokeywords(TranslateSMLIB::DEFAULT_DIC_FILE_PATH)
	#coKeywords = TranslateSMLIB.input_dic_file_to_cokeywords(sDicFilePath)
	#coKeywords = TranslateSMLIB.input_dic_file_to_cokeywords(sUserDicFilePath, coKeywords, true)

	# 処理対象ファイルパス各個に処理
	for sFilePath in aFilePath
		# qm >> 翻訳変換後qmファイル生成
		bRet = TranslateSMLIB.traverse_qm_to_qm(sFilePath, coSummaries, "ja")
#		STDERR.puts "#{sFilePath}: #{bRet}"
		TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_01, "#{sFilePath}:#{bRet}", STDERR)
	end
#	coSummaries.print(STDERR)
oOutputSummaries = File.new("output_summaries.log", "w")
#	oOutputSummaries.puts oOutputSummaries
	coSummaries.print(oOutputSummaries)
oOutputSummaries.close
	TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "coSummaries_size:#{coSummaries.size}", STDERR)
end

