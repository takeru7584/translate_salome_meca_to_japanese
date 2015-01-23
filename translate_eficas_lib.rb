#!/usr/bin/ruby1.9.1
## -*- coding:utf-8 -*-
##
## Salome-Meca 2011.2 Eficas 日本語化変換テーブルファイル作成用
## ライブラリファイル
##
## Salome-Meca 2012.1 用に修正
## Salome-Meca 2012.2 用に修正
########################################################
require "rexml/document"
require "getoptlong"
require "pp"

# スクリプト用ライブラリモジュールの定義
module TranslateEficasLIB
	#################################
	#
	# 定義宣言
	#
	#################################
	COMMAND_STR = "the script of Making Salome-Meca Eficas QM file"
	VERSION_NUM_STR = "0.01a"
	VERSION_OPTION_STR = "ALPHA (DEVELOPMENT)"

	# コマンドラインオプション用
	A_TRANSLATE_EFICAS_OPTION_VERSION = ["--version", "-v", GetoptLong::NO_ARGUMENT]
	A_TRANSLATE_EFICAS_OPTION_HELP = [ "--help", "-?", GetoptLong::NO_ARGUMENT ]
	A_TRANSLATE_EFICAS_OPTION_LOG_LEVEL = [ "--log-level", "-l", GetoptLong::REQUIRED_ARGUMENT ]
	A_TRANSLATE_EFICAS_OPTION_LOG_FILE = [ "--log-file", "-o", GetoptLong::REQUIRED_ARGUMENT ]
	A_TRANSLATE_EFICAS_OPTION_DEBUG = [ "--debug", "-d", GetoptLong::NO_ARGUMENT ]
	A_TRANSLATE_EFICAS_OPTION_QUIET = [ "--quiet", "-q", GetoptLong::NO_ARGUMENT ]

	# Error Level
	ERROR_LEVEL_01 = 1
	ERROR_LEVEL_02 = 2
	ERROR_LEVEL_03 = 3
	ERROR_LEVEL_04 = 4
	ERROR_LEVEL_05 = 5
	ERROR_LEVEL_06 = 6
	ERROR_LEVEL_07 = 7
	ERROR_LEVEL_08 = 8
	ERROR_LEVEL_09 = 9
	ERROR_LEVEL_10 = 10
	

	#################################
	#
	# 関数宣言
	#
	#################################
	module_function

	###############################
	# TranslateEficasLIB::init_option
	# コマンドラインオプション初期化関数（作成中）
	#
	# 概要：
	# 　コマンドラインオプション用GetoptLongオブジェクトを初期化します。
	#   (作成中)
	###############################
	def init_option()
		coOpts = GetoptLong.new(
				A_TRANSLATE_EFICAS_OPTION_VERSION,
				A_TRANSLATE_EFICAS_OPTION_HELP,
				A_TRANSLATE_EFICAS_OPTION_LOG_LEVEL,
				A_TRANSLATE_EFICAS_OPTION_LOG_FILE,
				A_TRANSLATE_EFICAS_OPTION_DEBUG,
				A_TRANSLATE_EFICAS_OPTION_QUIET
			)
		return coOpts
	end

		###############################
		# TranslateEficasLIB::get_option
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
			end
			return hOptsList

		end

	######################################
	# TranslateEficasLIB::init
	# Salome-Mecaライブラリ（TranslateEficasLIB）初期化関数
	# 概要：
	#    TranslateEficasLIBライブラリモジュールを初期化します。
	#    コマンドラインオプション取得結果Hashから
	#    初期化情報を設定します。
	#
	#   hOptsList^			コマンドラインオプション取得結果Hash
	#^								（このHashオブジェクトの詳細は
	#^								  TranslateEficasLIB::get_optionを参照のこと)
	######################################
	def init()
		@h_opts_list = Hash.new()
		@disp_version = false
		@disp_help = false
		@log_level = 1
		@log_file = nil
		@debug_mode = false
		@quiet_mode = false
		@gui_path = ""
		@eficas_ts_file_path = ""

		hOptsList = get_option()
		for sKey in hOptsList.keys
			case sKey
			when A_TRANSLATE_EFICAS_OPTION_VERSION[0]
				@disp_version = true

			when A_TRANSLATE_EFICAS_OPTION_HELP[0]
				@disp_help = true

			when A_TRANSLATE_EFICAS_OPTION_LOG_LEVEL[0]
				@log_level = hOptsList[sKey].to_i

			when A_TRANSLATE_EFICAS_OPTION_LOG_FILE[0]
				@log_file = "#{hOptsList[sKey]}"

			when A_TRANSLATE_EFICAS_OPTION_DEBUG[0]
				@debug_mode = true
				@log_level = 10

			when A_TRANSLATE_EFICAS_OPTION_QUIET[0]
				@quiet_mode = true
				@log_level = 0
			else
			end

		end
		STDERR.puts "Check(#{set_gui_path()})"
		#@gui_path = "#{set_gui_path()}"
		#@eficas_ts_file_path = "#{@gui_path}/Eficas_msg_fr.ts"
		@gui_path << set_gui_path()
		@eficas_ts_file_path << @gui_path
		@eficas_ts_file_path << "/Eficas_msg_fr.ts"
		STDERR.puts "gui_path=#{@gui_path}(#{@gui_path.size})"
		STDERR.puts "eficas_ts_file_path=#{@eficas_ts_file_path}(#{@eficas_ts_file_path.size})"
	end

	######################################
	# TranslateEficasLIB::h_opts_list
	# Salome-Mecaライブラリ（TranslateEficasLIB）h_opts_listリーダ関数
	# 概要：
	#^	@h_opts_listの内容を表示します。
	######################################
	def h_opts_list(oIO=STDERR)
		return @h_opts_list
	end

	def disp_version(oIO=STDERR)
		return @disp_version
	end

	def disp_help(oIO=STDERR)
		return @disp_help
	end

	def log_level(oIO=STDERR)
		return @log_level
	end

	def log_file(oIO=STDERR)
		return @log_file
	end

	def debug_mode(oIO=STDERR)
		return @debug_mode
	end

	def quiet_mode(oIO=STDERR)
		return @quiet_mode
	end

	def disp_gui_path(oIO=STDERR)
		return @gui_path
	end
	def disp_eficas_ts_file_path(oIO=STDERR)
		return @eficas_ts_file_path
	end
	######################################
	# TranslateEficasLIB::make_usage_msg(aOptionFactor, sMsg)
	# Salome-Mecaライブラリ（TranslateEficasLIB）usage表示メッセージ作成関数
	# 概要：
	#    usageを表示メッセージを作成します。
	#
	#^	aOptionFactor^Array^コマンドラインオプション定義配列
	#^	sMsg					String	コマンドラインオプション説明メッセージ文字列
	######################################
	def make_usage_msg(hOutputMsgLists=Hash.new(), aOptionFactor, sMsg)
		aOutputMsg = []
		aOutputMsg << ""
		aOutputMsg << "#{aOptionFactor[1]}, #{aOptionFactor[0]}"
		aOutputMsg << "#{sMsg}"
		hOutputMsgLists[aOptionFactor[1]] = aOutputMsg.join("^")
		return hOutputMsgLists
	end

	######################################
	# TranslateEficasLIB::disp_usage()
	# Salome-Mecaライブラリ（TranslateSMLIB）usage表示関数
	# 概要：
	#    usageを表示します。
	#
	######################################
	def disp_usage(oIO=STDERR)
		hMakeUsageMessage = Hash.new()
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_EFICAS_OPTION_VERSION, "display version of traslate_sm.rb")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_EFICAS_OPTION_HELP, "display this messages")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_EFICAS_OPTION_LOG_LEVEL, "specify executing message level.\n			default is 1. debug mode is 10. quiet mode is 0.")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_EFICAS_OPTION_LOG_FILE, "specify log file path.\n^		default is STDERR.")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_EFICAS_OPTION_DEBUG, "display executing message on debug mode.\n")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_EFICAS_OPTION_QUIET, "without display executing message.\n")

		oIO.puts
		oIO.puts "Usage:translate_sm.rb"
		for sKey in hMakeUsageMessage.keys.sort
			oIO.puts hMakeUsageMessage[sKey]
		end
		exit 0
	end

	######################################
	# TranslateSMLIB::exec_disp_version()
	# Salome-Mecaライブラリ（TranslateSMLIB）version表示関数
	# 概要：
	#    versionを表示します。
	#
	######################################
	def exec_disp_version(oIO=STDERR)
		oIO.puts "#{COMMAND_STR} version #{VERSION_NUM_STR} #{VERSION_OPTION_STR}"
		exit 0
	end

	######################################
	# TranslateEficasLIB::err_print(nLevel, sMsg,oIO=STDERR)
	# Salome-Mecaライブラリ（TranslateSMLIB）version表示関数
	# 概要：
	#    versionを表示します。
	#
	######################################
	def err_print(nLevel, sMsg, oIO=STDERR, nReturnMode=true)
		return false if nLevel > @log_level
		oLogFileIO = nil
#^	puts "log_file: #{@log_file}"
		unless @log_file == nil then
#^		if File.exist?(@log_file) == false then
#^	puts "log_file_exist_check:"
#^			oLogFileIO = File.new(@log_file, "w")
#^		else
#^			oLogFileIO = File.new(@log_file, "a")
#^		end
			oLogFileIO = File.new(@log_file, "a")
#^	puts "log_file_object: #{oLogFileIO}"
#^	puts "log_file_message: #{sMsg}"
				oLogFileIO.print sMsg
#				PP.pp(oMsg, oLogFileIO)
				oLogFileIO.puts unless nReturnMode == false
			oLogFileIO.close
			if @debug_mode == true then
#puts "debug_mode:#{sMsg}"
				oIO.print sMsg
				#PP.pp(oMsg, oLogFileIO)
				oIO.puts unless nReturnMode == false
			end
			return true
		end
		oIO.print sMsg
		#PP.pp(oMsg, oLogFileIO)
		oIO.puts unless nReturnMode == false
		return true
	end
	

	def search_eficas_directory(sSearchRootDir=Dir.pwd(), aList=[])
		err_print(ERROR_LEVEL_03, "sSearchRootDir=<#{sSearchRootDir}>")
		return "" unless File.exist?(sSearchRootDir)
		return "" unless File.stat(sSearchRootDir).directory?
		Dir.chdir(sSearchRootDir)
		sCmdRet = `find ./ -type d -name "Eficas*"`
		aLists = sCmdRet.split(/\n/)
		err_print(ERROR_LEVEL_03, aLists)
		return aLists
	end

	def exec_making_ts_in_eficas(aLists=[])
		sCurrentDir = File.expand_path(Dir.pwd())
		for sList in aLists
			sTargetDir = File.expand_path(sList)
			cmd = "find #{sList} -type f -name \"*.py\" -exec pylupdate4 {} -ts {}.ts \\;"
			err_print(ERROR_LEVEL_03, cmd)
			system(cmd)
		end
	end

	def search_eficas_ts_file(aLists=[])
		aLists = [] unless aLists
		aEficasTSLists = []
		for sList in aLists
			sCmdRet = `find #{sList} -type f -name \"*.ts\" -exec grep -l message {} +`
			aEficasTSListsTemp = sCmdRet.split(/\n/)
			aEficasTSLists.concat(aEficasTSListsTemp)
		end
		err_print(ERROR_LEVEL_03, "aEficasTSLists:")
		err_print(ERROR_LEVEL_03, aEficasTSLists)
		return aEficasTSLists
	end

	def set_gui_path(sCurrentDir=Dir.pwd())
		sCmdRet = `find #{sCurrentDir} -type d -name \"gui\" | grep GUI | grep resource`
		#sCmdRet = `find #{sCurrentDir} -type d -name \"gui\"`
		#STDERR.puts sCmdRet
		aGUIDirLists = sCmdRet.split(/\n/)
		aGUIDirLists = [sCmdRet] unless aGUIDirLists.size > 0 
		#STDERR.puts aGUIDirLists
		#STDERR.puts aGUIDirLists.first
		return aGUIDirLists.first
	end

	def rexml_merge_eficas_ts_file(aEficasTSLists=[])
		rexmlTrueDoc = nil
		for sEficasTSFile in aEficasTSLists
			rexmlTargetDoc = nil
			if sEficasTSFile == aEficasTSLists.first then
				err_print(ERROR_LEVEL_01, "Open File = <#{sEficasTSFile}>")
				File.open(sEficasTSFile) {|xmlfile|
					rexmlTrueDoc = REXML::Document.new(xmlfile)
				}
				err_print(ERROR_LEVEL_01, rexmlTrueDoc)
				next
			end
			err_print(ERROR_LEVEL_01, "Open File = <#{sEficasTSFile}>")
			File.open(sEficasTSFile) {|xmlfile|
				rexmlTargetDoc = REXML::Document.new(xmlfile)
			}
			#err_print(ERROR_LEVEL_03, rexmlTargetDoc)
			rexmlTrueDoc = rexml_merge_eficas_ts_file_core(rexmlTrueDoc, rexmlTargetDoc)
		end
		fEficasTSFile = File.new(@eficas_ts_file_path, "w")
			rexmlTrueDoc.write(fEficasTSFile)
		fEficasTSFile.close

	end

	def rexml_merge_eficas_ts_file_core(rexmlTrueDoc, rexmlTargetDoc)
		sNameFlag = false
		for rexmlTargetDocElement in rexmlTargetDoc.root.elements
			#err_print(ERROR_LEVEL_03, rexmlTargetDocElement)
			next unless rexmlTargetDocElement.name == "context"
			#err_print(ERROR_LEVEL_03, "Check1")
			aRexmlTargetDocElementNames = rexmlTargetDocElement.get_elements("name")
			for rexmlTargetDocElementName in aRexmlTargetDocElementNames
				sTargetNameText = rexmlTargetDocElementName.text
				err_print(ERROR_LEVEL_03, "sTargetNameText = <#{sTargetNameText}>")
				sNameFlag = false
				for rexmlTrueDocElement in rexmlTrueDoc.root.elements
					#err_print(ERROR_LEVEL_03, rexmlTrueDocElement)
					next unless rexmlTrueDocElement.name == "context"
					aRexmlTrueDocElementNames = rexmlTrueDocElement.get_elements("name")
					for rexmlTrueDocElementName in aRexmlTrueDocElementNames
						#err_print(ERROR_LEVEL_03, rexmlTargetDocElementName)
						#rexmlTargetDocTextName = rexmlTargetDocElementName.text
						sTrueNameText = rexmlTrueDocElementName.text
						err_print(ERROR_LEVEL_03, "sTrueNameText = <#{sTrueNameText}>")
						next unless sTargetNameText == sTrueNameText
						for rexmlTargetDocElementMessage in rexmlTargetDocElement.elements
							next if rexmlTargetDocElementMessage.name == "name"
							sNameFlag = true
		#					rexmlTargetDocElementMessage = rexml_make_fr_from_source(rexmlTargetDocElementMessage)
							rexmlTrueDocElementName.parent.add_element(rexmlTargetDocElementMessage)
						end
					end
				end
			end
		end
		if sNameFlag == false then
			rexmlTrueDoc.root.add_element(rexmlTargetDocElement)
		end
		rexmlTrueDoc = rexml_traverse_make_fr_from_source(rexmlTrueDoc)
		rexmlTrueDoc = rexml_traverse_delete_location(rexmlTrueDoc)
		return rexmlTrueDoc
	end

	def rexml_merge_eficas_ts_file_core_old(rexmlTrueDoc, rexmlTargetDoc)
		sNameFlag = false
		for rexmlTrueDocElement in rexmlTrueDoc.root.elements
			#err_print(ERROR_LEVEL_03, rexmlTrueDocElement)
			next unless rexmlTrueDocElement.name == "context"
			#err_print(ERROR_LEVEL_03, "Check1")
			aRexmlTrueDocElementNames = rexmlTrueDocElement.get_elements("name")
			for rexmlTrueDocElementName in aRexmlTrueDocElementNames
				sTrueNameText = rexmlTrueDocElementName.text
				err_print(ERROR_LEVEL_03, "sTrueNameText = <#{sTrueNameText}>")
				sNameFlag = false
				for rexmlTargetDocElement in rexmlTargetDoc.root.elements
					#err_print(ERROR_LEVEL_03, rexmlTargetDocElement)
					next unless rexmlTargetDocElement.name == "context"
					aRexmlTargetDocElementNames = rexmlTargetDocElement.get_elements("name")
					for rexmlTargetDocElementName in aRexmlTargetDocElementNames
						#err_print(ERROR_LEVEL_03, rexmlTrueDocElementName)
						#rexmlTrueDocTextName = rexmlTrueDocElementName.text
						sTargetNameText = rexmlTargetDocElementName.text
						err_print(ERROR_LEVEL_03, "sTargetNameText = <#{sTargetNameText}>")
						next unless sTargetNameText == sTrueNameText
						for rexmlTargetDocElementMessage in rexmlTargetDocElement.elements
							next if rexmlTargetDocElementMessage.name == "name"
							sNameFlag = true
		#					rexmlTargetDocElementMessage = rexml_make_fr_from_source(rexmlTargetDocElementMessage)
							rexmlTrueDocElementName.add_element(rexmlTargetDocElementMessage)
						end
					end
				end
			end
		end
		if sNameFlag == false then
			rexmlTrueDoc.root.add_element(rexmlTargetDocElement)
		end
		rexmlTrueDoc = rexml_traverse_make_fr_from_source(rexmlTrueDoc)
		rexmlTrueDoc = rexml_traverse_delete_location(rexmlTrueDoc)
		return rexmlTrueDoc
	end


	def rexml_make_fr_from_source(rexmlDocElementMessage=nil)
		if rexmlDocElementMessage == nil then
			err_print(ERROR_LEVEL_02, "rexmlDocElementMessage is nil")
			return false 
		end
		unless rexmlDocElementMessage.name == "message" then
			return false 
		end
		rexmlDocElementSource = rexmlDocElementMessage.elements["source"]
		rexmlDocElementTranslation = rexmlDocElementMessage.elements["translation"]
		err_print(ERROR_LEVEL_02, "rexmlDocElementSource is #{rexmlDocElementSource.text}")
		unless rexmlDocElementTranslation.attributes["type"] == nil then
			rexmlDocElementTranslation.delete_attribute("type")
		end
		rexmlDocElementTranslation.text = rexmlDocElementSource.text
		err_print(ERROR_LEVEL_02, rexmlDocElementMessage)
		return rexmlDocElementMessage
	end

	def rexml_traverse_make_fr_from_source(rexmlElement=nil)
		rexmlElement.elements.each() do | rexmlChildElement |
			#rexmlChildElement = rexmlElement.elements[rexmlChildElementName]
			rexmlChildElementName = rexmlChildElement.name
			unless rexmlChildElementName == "message" then
				rexmlChildElement = rexml_traverse_make_fr_from_source(rexmlChildElement)
				next
			end
			rexmlChildElement = rexml_make_fr_from_source(rexmlChildElement)
		end
		return rexmlElement
	end
	
	def rexml_traverse_delete_location(rexmlElement=nil)
		rexmlElement.delete_element("location")
		rexmlElement.elements.each() do | rexmlChildElement |
			#rexmlChildElement = rexmlElement.elements[rexmlChildElementName]
			rexmlChildElementName = rexmlChildElement.name
			unless rexmlChildElementName == "location" then
				rexmlChildElement = rexml_traverse_delete_location(rexmlChildElement)
				next
			end
		end
		return rexmlElement
	end
end

if $0 == __FILE__ then
	TranslateEficasLIB.init()
	TranslateEficasLIB.exec_disp_version() if TranslateEficasLIB.disp_version == true
	TranslateEficasLIB.disp_usage() if TranslateEficasLIB.disp_help == true

	aList = TranslateEficasLIB.search_eficas_directory()
	TranslateEficasLIB.exec_making_ts_in_eficas(aList)
	aEficasTSLists = TranslateEficasLIB.search_eficas_ts_file(aList)
	#PP.pp(aEficasTSLists, STDERR)
	TranslateEficasLIB.rexml_merge_eficas_ts_file(aEficasTSLists)

end
