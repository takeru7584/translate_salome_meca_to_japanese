#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#
# Salome-Meca 2012.1 日本語化スクリプト v0.07a 用
# ライブラリファイル
# 
require "rexml/document"
require "getoptlong"
require "pp"

# スクリプト用ライブラリモジュールの定義
module TranslateSMLIB
	#############################
	# setting accessor
	#############################
	#attr_accessor :h_opts_list
	#attr_accessor :disp_version
	#attr_accessor :disp_help
	#attr_accessor :dic_file
	#attr_accessor :udic_file
	#attr_accessor :log_level
	#attr_accessor :log_file
	#attr_accessor :debug_mode
	#attr_accessor :quiet_mode

	##############################
	#
	# 定数宣言
	#
	##############################
	COMMAND_STR = "the script of Salome Meca Translate to Japanese translate_sm.rb "
	VERSION_NUM_STR = "0.08a"
	VERSION_OPTION_STR = "ALPHA (DEVELOPMENT)"
	DEFAULT_DIC_FILE_PATH = "#{File.dirname(__FILE__)}/../dic/org/summary_translate_word.dic"
	DEFAULT_USER_DIC_FILE_PATH = "#{File.dirname(__FILE__)}/../dic/summary_translate_word_user.dic"
	SALOME_USER_CONFIG_FILE_PATH = "#{ENV["HOME"]}/.SalomeApprc.5.1.4"

	LANGUAGES = [ 
		:ar,	#アラビア語
		:bg,	#ブルガリア語
		:zh,	#中国語
		:zh_CN,	#中国語簡体
		:zh_TW,	#中国語繁体
		:ca,	#カタロニア語
		:hr,	#クロアチア語
		:cs,	#チェコ語
		:da,	#デンマーク語
		:en,	#英語
		:tl,	#フィリピノ語
		:fi,	#フィンランド語
		:fr,	#フランス語
		:de,	#ドイツ語
		:el,	#ギリシャ語
		:iw,	#ヘブライ語
		:hi,	#ヒンディー語
		:id,	#インドネシア語
		:it,	#イタリア語
		:ja,	#日本語
		:ko,	#韓国語
		:lv,	#ラトビア語
		:lt,	#リトアニア語
		:no,	#ノルウェー語
		:pl,	#ポーランド語
		:pt_PT,	#ポルトガル語
		:ro,	#ルーマニア語
		:ru,	#ロシア語
		:es,	#スペイン語
		:sr,	#セルビア語
		:sk,	#スロバキア語
		:sl,	#スロベニア語
		:sv,	#スウェーデン語
		:uk,	#ウクライナ語
		:vi,	#ベトナム語
	]

	# コマンドラインオプション用（作成中）
	A_TRANSLATE_SM_OPTION_VERSION = ["--version", "-v", GetoptLong::NO_ARGUMENT ]
	A_TRANSLATE_SM_OPTION_HELP = [ "--help", "-?", GetoptLong::NO_ARGUMENT ]
	A_TRANSLATE_SM_OPTION_DIC_FILE = [ "--dic-file", "-f", GetoptLong::REQUIRED_ARGUMENT ]
	A_TRANSLATE_SM_OPTION_USER_DIC_FILE = [ "--udic-file", "-u", GetoptLong::REQUIRED_ARGUMENT ]
	A_TRANSLATE_SM_OPTION_LOG_LEVEL = [ "--log-level", "-l", GetoptLong::REQUIRED_ARGUMENT ]
	A_TRANSLATE_SM_OPTION_LOG_FILE = [ "--log-file", "-o", GetoptLong::REQUIRED_ARGUMENT ]
	A_TRANSLATE_SM_OPTION_DEBUG = [ "--debug", "-d", GetoptLong::NO_ARGUMENT ]
	A_TRANSLATE_SM_OPTION_QUIET = [ "--quiet", "-q", GetoptLong::NO_ARGUMENT ]

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
	
	# initialize instance variety
	#@h_opts_list = Hash.new()
	#@disp_version = false
	#@disp_help = false
	#@dic_file = "#{DEFAULT_DIC_FILE_PATH}"
	#@udic_file = "#{DEFAULT_USER_DIC_FILE_PATH}"
	#@log_level = 1
	#@log_file = nil
	#@debug_mode = false
	#@quiet_mode = false

	
	module_function
	###############################
	# TranslateSMLIB::init_option
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
	# TranslateSMLIB::get_option
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
	# TranslateSMLIB::init
	# Salome-Mecaライブラリ（TranslateSMLIB）初期化関数
	# 概要：
	#    TranslateSMLIBライブラリモジュールを初期化します。
	#    コマンドラインオプション取得結果Hashから
	#    初期化情報を設定します。
	#
	#   hOptsList				コマンドラインオプション取得結果Hash
	#									（このHashオブジェクトの詳細は
	#									  TranslateSMLIB::get_optionを参照のこと)
	######################################
	def init()
		@h_opts_list = Hash.new()
		@disp_version = false
		@disp_help = false
		@dic_file = "#{DEFAULT_DIC_FILE_PATH}"
		@udic_file = "#{DEFAULT_USER_DIC_FILE_PATH}"
		@log_level = 1
		@log_file = nil
		@debug_mode = false
		@quiet_mode = false

		hOptsList = get_option()
		for sKey in hOptsList.keys
			case sKey
			when A_TRANSLATE_SM_OPTION_VERSION[0]
				@disp_version = true

			when A_TRANSLATE_SM_OPTION_HELP[0]
				@disp_help = true

			when A_TRANSLATE_SM_OPTION_DIC_FILE[0]
				@dic_file = "#{hOptsList[sKey]}"

			when A_TRANSLATE_SM_OPTION_USER_DIC_FILE[0]
				@udic_file = "#{hOptsList[sKey]}"

			when A_TRANSLATE_SM_OPTION_LOG_LEVEL[0]
				@log_level = hOptsList[sKey].to_i

			when A_TRANSLATE_SM_OPTION_LOG_FILE[0]
				@log_file = "#{hOptsList[sKey]}"

			when A_TRANSLATE_SM_OPTION_DEBUG[0]
				@debug_mode = true
				@log_level = 10

			when A_TRANSLATE_SM_OPTION_QUIET[0]
				@quiet_mode = true
				@log_level = 0
			else
			end

		end
	end

	######################################
	# TranslateSMLIB::h_opts_list
	# Salome-Mecaライブラリ（TranslateSMLIB）h_opts_listリーダ関数
	# 概要：
	#		@h_opts_listの内容を表示します。
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

	def dic_file(oIO=STDERR)
		return @dic_file
	end

	def udic_file(oIO=STDERR)
		return @udic_file
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

	######################################
	# TranslateSMLIB::make_usage_msg(aOptionFactor, sMsg)
	# Salome-Mecaライブラリ（TranslateSMLIB）usage表示メッセージ作成関数
	# 概要：
	#    usageを表示メッセージを作成します。
	#
	#		aOptionFactor	Array	コマンドラインオプション定義配列
	#		sMsg					String	コマンドラインオプション説明メッセージ文字列
	######################################
	def make_usage_msg(hOutputMsgLists=Hash.new(), aOptionFactor, sMsg)
		aOutputMsg = []
		aOutputMsg << ""
		aOutputMsg << "#{aOptionFactor[1]}, #{aOptionFactor[0]}"
		aOutputMsg << "#{sMsg}"
		hOutputMsgLists[aOptionFactor[1]] = aOutputMsg.join("	")
		return hOutputMsgLists
	end
	
	######################################
	# TranslateSMLIB::disp_usage()
	# Salome-Mecaライブラリ（TranslateSMLIB）usage表示関数
	# 概要：
	#    usageを表示します。
	#
	######################################
	def disp_usage(oIO=STDERR)
		hMakeUsageMessage = Hash.new()
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_SM_OPTION_VERSION, "display version of traslate_sm.rb")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_SM_OPTION_HELP, "display this messages")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_SM_OPTION_DIC_FILE, "specify translate dic file")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_SM_OPTION_USER_DIC_FILE, "specify translate user dic file")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_SM_OPTION_LOG_LEVEL, "specify executing message level.\n			default is 1. debug mode is 10. quiet mode is 0.")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_SM_OPTION_LOG_FILE, "specify log file path.\n			default is STDERR.")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_SM_OPTION_DEBUG, "display executing message on debug mode.\n")
		hMakeUsageMessage = make_usage_msg(hMakeUsageMessage, A_TRANSLATE_SM_OPTION_QUIET, "without display executing message.\n")

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
	# TranslateSMLIB::err_print(nLevel, sMsg,oIO=STDERR)
	# Salome-Mecaライブラリ（TranslateSMLIB）version表示関数
	# 概要：
	#    versionを表示します。
	#
	######################################
	def err_print(nLevel, sMsg, oIO=STDERR, nReturnMode=true)
		return false if nLevel > @log_level 
		oLogFileIO = nil
#		puts "log_file: #{@log_file}"
		unless @log_file == nil then
#			if File.exist?(@log_file) == false then
#		puts "log_file_exist_check:"
#				oLogFileIO = File.new(@log_file, "w")
#			else
#				oLogFileIO = File.new(@log_file, "a")
#			end
			oLogFileIO = File.new(@log_file, "a")
#		puts "log_file_object: #{oLogFileIO}"
#		puts "log_file_message: #{sMsg}"
				oLogFileIO.print sMsg
				oLogFileIO.puts unless nReturnMode == false
			oLogFileIO.close
			if @debug_mode == true then
#puts "debug_mode:#{sMsg}"
				oIO.print sMsg
				oIO.puts unless nReturnMode == false
			end
			return true
		end
		oIO.print sMsg
		oIO.puts unless nReturnMode == false
		return true
	end
	
	######################################
	# TranslateSMLIB::summarize_recursively
	# Salome-Meca アプリケーション内datファイルからTranslateSummariesオブジェクト作成関数
	# 概要：
	# 　　カレントディレクトリ以下（サブディレクトリを再帰的に処理）
	# 　にあるqmファイル>>tsファイル>>から作成されたdatファイルを基に、
	# 　各メニュー単語キーワードを抽出して最終的に
	#   TranslateSummariesオブジェクトを作成する
	#   (TranslateSummariesは後に翻訳変換辞書として使用）
	#
	#   coDicSummaries	TranslateSummariesオブジェクト
	#   　　　　　　　　入力すれば入力したTranslateSummariesオブジェクトに
	#   　　　　　　　　追加
	#   　　　　　　　　省略すれば新規にTranslateSummariesを生成
	#										（再帰処理に対応するため）
	#		sFilePath				作業パス（再帰処理に対応するため）
	######################################
	def summarize_recursively(coDicSummaries=TranslateSummaries.new(), sFilePath=nil)
		# 作業パスチェック（sFilePathの入力なければカレントディレクトリ）
		sFilePath = Dir.getwd() if sFilePath == nil
		# 作業パスが存在しなければcoDicSummariesオブジェクトを返す
		return coDicSummaries unless File.exist?(sFilePath)
		# 作業パスがディレクトリではない場合
		if FileTest.directory?(sFilePath) == false then
			# *.datファイルからメニュー単語キーワードを抽出し、TranslateSummariesオブジェクトに登録
			return register_dic_from_dat(coDicSummaries, sFilePath)
		end
#STDERR.puts sFilePath
		err_print(ERROR_LEVEL_05, sFilePath)
		# 作業パスがディレクトリの場合、その中にあるファイル、ディレクトリリストを配列に格納
		aFileChildren = Dir.entries(sFilePath)
		# 上記格納した子供ファイルリストの各ファイルに対し、ファイルパスを作成して、再帰処理
		for sFileChild in aFileChildren
			next if sFileChild =~ /^\./
			sChildFilePath = File.expand_path("#{sFilePath}/#{sFileChild}")
			coDicSummaries = summarize_recursively(coDicSummaries, sChildFilePath)
		end
		# TranslateSummariesオブジェクトを返す
		return coDicSummaries
	end


	###################################################
	# TranslateSMLIB::register_dic_from_dat
	# datファイルからメニュー単語キーワードを抽出し、
	# TranslateSummariesオブジェクトに格納する関数
	#
	# 　qmファイル>>tsファイルから作成したdatファイルから
	# 　メニュー単語翻訳キーワードを抽出し、
	# 　対象dat（ts）ファイル用TranslateDicListsオブジェクトを作成
	# 　それをTranslateSummariesオブジェクトに格納する関数
	#
	#   coDicSummaries		キーワード登録先TranslateSummariesオブジェクト
	#   sCheckFilePath		対象tsファイルパス
	###################################################
	def register_dic_from_dat(coDicSummaries=TranslateSummaries.new(), sCheckFilePath)
		# sCheckFilePath 入力エラーチェック（なければcoDicSummariesを返す）
		return coDicSummaries unless File.exist?(sCheckFilePath)
		return coDicSummaries unless FileTest.file?(sCheckFilePath)

		# sCheckFilePath からtsファイル名とファイル存在パスを抽出
		sFileDir, sTSFileName = File.split(sCheckFilePath)

		# tsファイル名が *_msg_fr.tsで終わっていなければcoDicSummariesを返す
		return coDicSummaries unless sTSFileName =~ /(.+?_msg_fr).ts$/
			  # tsファイルのベースファイル名を取得
				sTargetBaseName=$1.to_s
		# tsファイルパスからdatファイルパスを抽出し、sFilePathに格納
		sFilePath = sCheckFilePath.gsub(/\.ts$/,".dat")

		# sFilePath存在チェック
		return coDicSummaries unless File.exist?(sFilePath)
		return coDicSummaries unless FileTest.file?(sFilePath)
# printf debug
#STDERR.puts sFilePath
		err_print(ERROR_LEVEL_03, sFilePath)

    # TranslateDicListsオブジェクト生成・初期化
		coDicLists = TranslateDicLists.new()
		coDicLists.create_dic_lists(sTargetBaseName, coDicSummaries)
#puts coDicLists.type
		err_print(ERROR_LEVEL_05, coDicLists.type)
		#
		# datファイルから各メニュー単語翻訳キーワードを抽出し、
		# TranslateDicListsオブジェクトに登録
		# 
		# 一行ずつ取り出して処理
		IO.foreach(sFilePath) do |sLine|
			sLine.chomp!
#puts sLine
			err_print(ERROR_LEVEL_05, sLine)
			# タブ区切りフォーマットから各要素を配列に格納
			aFactor = sLine.split(/\t/)
			# 格納した配列をTranslateKeywordオブジェクトに格納
			coKeywordItem = TranslateKeyword.new(aFactor)
			#TranslateKeywordオブジェクトをTranslateDicListsオブジェクトに登録
			coDicLists.install(coKeywordItem)
		end
		#TranslateDicListsオブジェクトをTranslateSummariesオブジェクトに登録
		coDicSummaries.install(coDicLists)
		return coDicSummaries
	end

	###################################################
	# TranslateSMLIB::output_dic_summary
	#  TranslateSummariesオブジェクトからIOオブジェクトに
	#　出力する関数
	#  (*.dat形式フォーマット（タブ区切り））
	#  
	#  概要：
	#    TranslateSummariesオブジェクトからIOオブジェクトに出力します。
	#    IOオブジェクトは、Fileオブジェクト、STDOUT等の出力オブジェクトに
	#    対応します。
	#    出力されるフォーマット形式は、*.dat形式のタブ区切りです。
	#    
	#    *.tsファイルベースファイル名	メニュー単語キーワード	フランス語	英語	日本語
	#
	#   coDicSummaries		TranslateSummariesオブジェクト
	#   oIO								出力対象IOオブジェクト
	###################################################
	def output_dic_summary(coDicSummaries=TranslateSummaries.new(), oIO=STDOUT)
		nOutputCount=0
		for sFileBaseName in coDicSummaries.keys.sort
			coDicLists = coDicSummaries[sFileBaseName]
			for sKeyword in coDicLists.keys.sort
				coKeywordItem = coDicLists[sKeyword]
				aLine = []
				aLine << sFileBaseName			# tsファイルベースファイル名
#				aLine << sKeyword						# メニュー単語キーワード
#				aLine << coKeywordItem.fr		#	フランス語訳
#				aLine << coKeywordItem.en		#	英語訳
#				aLine << coKeywordItem.ja		# 日本語訳
				aLine << sKeyword.gsub(/\n/, "\\n")						# メニュー単語キーワード
				aLine << coKeywordItem.fr.gsub(/\n/, "\\n")		#	フランス語訳
				aLine << coKeywordItem.en.gsub(/\n/, "\\n")		#	英語訳
				aLine << coKeywordItem.ja.gsub(/\n/, "\\n")		# 日本語訳
				aLine << coKeywordItem.change_flag	unless coKeywordItem.change_flag == true	# change_flag
				sLine = aLine.join("\t")		# 配列からタブ区切りで1行分を作成
				if oIO != STDOUT && oIO != STDERR then
					oIO.puts sLine unless oIO == false	# IOオブジェクトに出力
					nOutputCount += 1
				end
				err_print(ERROR_LEVEL_03, sLine, oIO) unless oIO == false	# IOオブジェクトに出力
			end
		end
		STDERR.puts "nOutputCount=#{nOutputCount}"
	end

	###################################################
	# TranslateSMLIB::output_dic_summary
	#  TranslateSummariesオブジェクトからIOオブジェクトに
	#　出力する関数
	#  (*.dat形式フォーマット（タブ区切り））
	#  
	#  概要：
	#    TranslateSummariesオブジェクトからIOオブジェクトに出力します。
	#    IOオブジェクトは、Fileオブジェクト、STDOUT等の出力オブジェクトに
	#    対応します。
	#    出力されるフォーマット形式は、*.dat形式のタブ区切りです。
	#    
	#    *.tsファイルベースファイル名	メニュー単語キーワード	フランス語	英語	日本語
	#
	#   coDicSummaries		TranslateSummariesオブジェクト
	#   oIO								出力対象IOオブジェクト
	###################################################
	def output_dic_summary_with_group(coDicSummaries=TranslateSummaries.new(), oIO=STDOUT)
		nOutputCount=0
		for sFileBaseName in coDicSummaries.keys.sort
			coDicLists = coDicSummaries[sFileBaseName]
			for sKeywordGroupName in coDicLists.keys.sort
				coKeywordGroup = coDicLists[sKeywordGroupName]
				for sKeyword in coKeywordGroup.keys.sort
					coKeywordItem = coKeywordGroup[sKeyword]
					aLine = []
					aLine << sFileBaseName			# tsファイルベースファイル名
					aLine << sKeywordGroupName # tsファイルグループ名
	#				aLine << sKeyword						# メニュー単語キーワード
	#				aLine << coKeywordItem.fr		#	フランス語訳
	#				aLine << coKeywordItem.en		#	英語訳
	#				aLine << coKeywordItem.ja		# 日本語訳
					aLine << sKeyword.gsub(/\n/, "\\n")						# メニュー単語キーワード
					aLine << coKeywordItem.fr.gsub(/\n/, "\\n")		#	フランス語訳
					aLine << coKeywordItem.en.gsub(/\n/, "\\n")		#	英語訳
					aLine << coKeywordItem.ja.gsub(/\n/, "\\n")		# 日本語訳
					sLine = aLine.join("\t")		# 配列からタブ区切りで1行分を作成
					if oIO != STDOUT && oIO != STDERR then
						oIO.puts sLine unless oIO == false	# IOオブジェクトに出力
						nOutputCount += 1
					end
					err_print(ERROR_LEVEL_03, sLine, oIO) unless oIO == false	# IOオブジェクトに出力
				end
			end
		end
		STDERR.puts "nOutputCount=#{nOutputCount}"
	end

	###################################################
	# TranslateSMLIB::input_dic_file
	#   DEFAULT_DIC_FILE_PATHにあるdicファイルから
	#   TranslateSummariesオブジェクトを作成する関数
	#  (*.dic形式フォーマット（タブ区切り））
	#  
	#    *.tsファイルベースファイル名	メニュー単語キーワード	フランス語	英語	日本語
	#
	#DEFAULT_DIC_FILE_PATH = "#{File.dirname(__FILE__)}/../dic/summary_translate_word.dic"
	#
	#  概要：
	#    DEFAULT_DIC_FILE_PATH に登録されたsummary_translate_word.dicから
	#    TranslateSummariesオブジェクトを作成します。
	#    作成されたTranslateSummariesは、
	#    Salome-Mecaがインストールされたフォルダ内に存在する
	#    qmファイルから変換されたtsファイルを翻訳する際に使用します。
	#    
	#   sFilePath					dicファイルのパス
	#   coSummaries				TranslateSummariesクラス
	#   bForceFlag				強制フラグ
	###################################################
#	def input_dic_file(sFilePath=DEFAULT_DIC_FILE_PATH, bForceFlag=false)
	def input_dic_file(sFilePath=@dic_file, coSummaries=TranslateSummaries.new(), bForceFlag=false)
		# TranslateSummariesオブジェクトの作成
		#coSummaries = TranslateSummaries.new()
		# sFilePathの各行から各要素を抽出し、配列に格納
		nCount = 0
		IO.foreach(sFilePath) do |sLine|
			sLine.chomp!
			sLine.chomp!("\\n")
			#STDERR.puts "#{nCount}:#{sLine}"
			#sLine.strip!
			# #コメント行に対応 modified by Takeru 2012.4.30
			next if sLine =~ /^#/
			# #コメントに対応 modified by Takeru 2012.4.30
			sTargetLine, = sLine.split(/#/)
			sTargetLine = "#{sLine}" if sTargetLine == nil
			aDicLine = sTargetLine.split(/\t/)
			#aDicLine.last
			STDERR.puts "#{aDicLine}\naDicLine.size=#{aDicLine.size}" if aDicLine.size != 5
			# 上記格納した配列から1行（1単語）ずつ TranslateSummariesに登録
			coSummaries.install_all_components(aDicLine, bForceFlag)
			nCount += 1
		end
		STDERR.puts "nCount=#{nCount}"
		return coSummaries
	end

	###################################################
	# TranslateSMLIB::input_dic_file_with_group
	#   DEFAULT_DIC_FILE_PATHにあるdicファイルから
	#   TranslateSummariesオブジェクトを作成する関数
	#  (*.dic形式フォーマット（タブ区切り））
	#  
	#    *.tsファイルベースファイル名	メニュー単語キーワード	フランス語	英語	日本語
	#
	#DEFAULT_DIC_FILE_PATH = "#{File.dirname(__FILE__)}/../dic/summary_translate_word.dic"
	#
	#  概要：
	#    DEFAULT_DIC_FILE_PATH に登録されたsummary_translate_word.dicから
	#    TranslateSummariesオブジェクトを作成します。
	#    作成されたTranslateSummariesは、
	#    Salome-Mecaがインストールされたフォルダ内に存在する
	#    qmファイルから変換されたtsファイルを翻訳する際に使用します。
	#    
	#   sFilePath					dicファイルのパス
	#   coSummaries				TranslateSummariesクラス
	#   bForceFlag				強制フラグ
	###################################################
#	def input_dic_file(sFilePath=DEFAULT_DIC_FILE_PATH, bForceFlag=false)
	def input_dic_file_with_group(sFilePath=@dic_file, coSummaries=TranslateSummaries.new(), bForceFlag=false)
		# TranslateSummariesオブジェクトの作成
		#coSummaries = TranslateSummaries.new()
		# sFilePathの各行から各要素を抽出し、配列に格納
		nCount = 0
		IO.foreach(sFilePath) do |sLine|
			sLine.chomp!
			sLine.chomp!("\\n")
			#STDERR.puts "#{nCount}:#{sLine}"
			#sLine.strip!
			# #コメント行に対応 modified by Takeru 2012.4.30
			next if sLine =~ /^#/
			# #コメントに対応 modified by Takeru 2012.4.30
			sTargetLine, = sLine.split(/#/)
			sTargetLine = "#{sLine}" if sTargetLine == nil
			aDicLine = sTargetLine.split(/\t/)
			#aDicLine.last
			STDERR.puts "#{aDicLine}\naDicLine.size=#{aDicLine.size}" if aDicLine.size != 5
			# 上記格納した配列から1行（1単語）ずつ TranslateSummariesに登録
			coSummaries.install_all_components_with_group(aDicLine, bForceFlag)
			nCount += 1
		end
		STDERR.puts "nCount=#{nCount}"
		return coSummaries
	end

	###################################################
	# TranslateSMLIB::input_dic_file_to_cokeywords
	#   DEFAULT_DIC_FILE_PATHにあるdicファイルから
	#   TranslateSummariesオブジェクトを作成する関数
	#  (*.dic形式フォーマット（タブ区切り））
	#  
	#    *.tsファイルベースファイル名	メニュー単語キーワード	フランス語	英語	日本語
	#
	#DEFAULT_DIC_FILE_PATH = "#{File.dirname(__FILE__)}/../dic/summary_translate_word.dic"
	#
	#  概要：
	#    DEFAULT_DIC_FILE_PATH に登録されたsummary_translate_word.dicから
	#    TranslateDicListsオブジェクトを作成します。
	#    作成されたTranslateDicListsオブジェクトは、
	#    Salome-Mecaがインストールされたフォルダ内に存在する
	#    qmファイルから変換されたtsファイルを翻訳する際に使用します。
	#     TranslateSMLIB::input_dic_fileとの違いは
	#    tsファイル毎に格納せず、すべてのキーワードを
	#    TranslateDicListsに同列に格納します。
	#    (メニュー単語キーワードがtsファイルが異なっても
	#    独立性を保つことが確認された場合、こちらに切り替える予定）
	#    
	#   sFilePath					dicファイルのパス
	#   coKeywords				TranslateDicListsクラス
	#   bForceFlag				強制フラグ
	###################################################
	def input_dic_file_to_cokeywords(sFilePath=@dic_file, coKeywords=TranslateDicLists.new(), bForceFlag=false)
		# TranslateDicListsオブジェクトの作成
		#coKeywords = TranslateDicLists.new()
		# sFilePathから1行ずつ取り出し、各要素を配列に格納
		IO.foreach(sFilePath) do |sLine|
			sLine.chomp!
			aDicLine = sLine.split(/\t/)
			# 上記作成した配列の1つめ（tsファイルベースファイル名）は
			# 必要ないので、shiftして削除する
			aDicLine.shift
			# TranslateKeywordオブジェクトに登録(親をcoKeywordsとする）
			coKeywordItem = TranslateKeyword.new(aDicLine, coKeywords)
		end

		return coKeywords
	end

	###################################################
	# TranslateSMLIB::translate_from_summaries
	# TranslateSummariesオブジェクトを用いて
	# 指定したtsファイルから翻訳したtsファイル作成関数
	#  
	#  概要：
	#    あらかじめ翻訳辞書オブジェクトとして用意した
	#    TranslateSummariesオブジェクトを用いて、
	#    指定したtsファイルから翻訳したtsファイルを作成します。
	#  
	#  指定可能翻訳元、翻訳先
	#    "fr"		フランス語
	#    "en"		英語
	#    "ja"		日本語
	#    
	#   sFilePath					tsファイルパス
	#   coSummaries				翻訳辞書オブジェクト（TranslateSummaries)
	#   sFromLang					翻訳元言語
	#   sToLang						翻訳先言語
	###################################################
	def translate_from_summaries(sFilePath, coSummaries, sFromLang="fr", sToLang="ja")
		# printf debug
		#STDERR.puts "#{sFilePath}:" 
		err_print(ERROR_LEVEL_03, "sFilePath:#{sFilePath}:", STDERR) 
#STDERR.puts "Check1"
		err_print(ERROR_LEVEL_05, "Check1", STDERR)
		# 翻訳元と翻訳先が同じ場合は戻す
		return false if sFromLang == sToLang
#STDERR.puts "Check2"
		err_print(ERROR_LEVEL_05, "Check2", STDERR)
		# 翻訳辞書オブジェクトがnilの場合戻す
		return false unless coSummaries
#STDERR.puts "Check3"
		err_print(ERROR_LEVEL_05, "Check3", STDERR)

		# 翻訳先（出力先）ファイルパス作成
		sOutputFilePath = sFilePath.gsub("_msg_#{sFromLang}.ts", "_msg_#{sToLang}.ts")
#STDERR.puts "Check4(#{sOutputFilePath})"
		err_print(ERROR_LEVEL_05, "Check4(#{sOutputFilePath})", STDERR)
		#
		#出力先ファイルパスと入力ファイルパスが同じ場合戻す
		return false if sOutputFilePath == sFilePath

		# tsファイルのベースファイル名を抽出
		# （翻訳辞書オブジェクトの検索キー（Hashキー）となる
		# modified by Takeru on 2012.5.2
		# modified by Takeru on 2012.5.12
		sSummariesKey = File.basename(sFilePath.gsub(/\.ts$/, ""))
		#sSummariesKey = "#{sFilePath.gsub(/\.ts$/,"")}"
		sSummariesKey = "#{sSummariesKey.gsub("_msg_#{sFromLang}","_msg_fr")}"

		# tsファイルのベースファイル名から検索して
		# TranslateDicListsオブジェクトを抽出
		coDicLists = coSummaries[sSummariesKey]
STDERR.puts "sFromLang:#{sFromLang}"
STDERR.puts "sSummariesKey:#{sSummariesKey}"
		err_print(ERROR_LEVEL_05, "Check5(sSummariesKey:#{sSummariesKey})", STDERR)
#STDERR.puts "Check5(#{coDicLists})"
#		err_print(ERROR_LEVEL_05, "Check5(coDicLists:#{coDicLists.size})", STDERR)
		#err_print(ERROR_LEVEL_05, "Check5(#{coSummaries})", STDERR)
		#
		# 対象TranslateDicListsオブジェクトを抽出
		return false unless coDicLists
		# 入力XMLファイルを読み込んでREXML::Documentを生成
#STDERR.puts "Check6(#{coDicLists})"
		err_print(ERROR_LEVEL_05, "Check6(#{coDicLists})", STDERR)
		#
		# tsファイル（xmlファイル形式）から作成する
		# REXMLオブジェクト格納用変数の定義
		doc = nil

		# tsファイルを開き、REXMLパーサを用いて
		# REXML rootオブジェクトを作成
		File.open(sFilePath) {|xmlfile|
				doc = REXML::Document.new(xmlfile)
		}

		# 変換対象メニュー単語キーワード数計算関数呼び出し
		nTotalCount = traverse_count_translate_tag(doc.root)

		# トラバースにて翻訳実行関数実行
		#nCount = traverse_translation_from_codiclists(doc.root, coDicLists, nTotalCount, 0, sToLang) 
		nCount = ts_translation_from_codiclists(doc.root, coDicLists, nTotalCount, 0, sToLang) 
		#		STDERR.puts doc
		err_print(ERROR_LEVEL_05, "#{doc}", STDERR)
		#		printf debug
		#STDERR.puts
		err_print(ERROR_LEVEL_05, "", STDERR)
		# 翻訳先tsファイル作成
		fOutputXmlFile = File.new(sOutputFilePath, "w")
		#			doc.write(fOutputXmlFile, -1, true)
		#	tsファイル書き込み実行
			doc.write(fOutputXmlFile)
		fOutputXmlFile.close
		return true
	end

	###################################################
	# TranslateSMLIB::traverse_translation_from_codiclists
	# TranslateDicListsオブジェクトを用いて
	# xml（REXMLオブジェクト）内のメニュー単語キーワードを
	# 翻訳する関数
	#  
	#  概要：
	#    あらかじめ翻訳辞書オブジェクトとして用意した
	#    TranslateSummariesオブジェクトを用いて、
	#    tsファイルから作成したREXMLオブジェクト内の
	#    対象要素を翻訳します。
	#    翻訳先は指定できます。
	#  
	#  指定可能翻訳先
	#    "fr"		フランス語
	#    "en"		英語
	#    "ja"		日本語
	#    
	#   coParent					親REXML::Elementオブジェクト
	#   coDicLists				翻訳辞書オブジェクト（TranslateSummaries)
	#   nTotalCount				変換対象単語数　
	#   nCount						現在までに翻訳した単語数
	#   sToLang						翻訳先言語
	###################################################
	def traverse_translation_from_codiclists(coParent, coDicLists, nTotalCount, nCount=0, sToLang="ja")
		# 
		#
		# 親REXML::Elementオブジェクトから
		# REXML::Elementsオブジェクトを作成し、
		# その子供を取り出して各個に処理
		for coChild in coParent.elements
			# 対象REXML::Elementsオブジェクトに対して再帰処理
			nCount = traverse_translation_from_codiclists(coChild, coDicLists, nTotalCount, nCount, sToLang)

			# 対象REXML::Elementsオブジェクトの要素名が
			# translationでなければ次の要素へ
			next unless coChild.name.to_s =~ /^translation$/

			# 要素名"translation"と同列にある要素名"source"の
			# 値を取り出す。
			# （メニュー単語キーワードの格納場所）
			sKeyword = coParent.elements["source"].text.to_s
			# 現在まで処理した単語数を1つ増やす
			nCount += 1
			# メニュー単語キーワードを用いて
			# TranslateDicLIstsからTranslateKeywordを抽出
			coKeyword = coDicLists[sKeyword]
			# 対象TranslateKeywordが存在しなければ次の要素へ
			next unless coKeyword
			
			# 翻訳変換後の言葉をメニュー単語キーワードに設定
			sToString = sKeyword.to_s

			# 翻訳実行部分
			# 翻訳先言語の選択
			case sToLang
				# フランス語の場合
			when "fr"
				# 翻訳変換後の言葉をTranslateKeywordから抽出
				sToString = coKeyword.fr unless (coKeyword.fr == nil) || (coKeyword.fr == "")

				# 英語の場合
			when "en"
				# 翻訳変換後の言葉をTranslateKeywordから抽出
				sToString = coKeyword.en unless (coKeyword.en == nil) || (coKeyword.en == "")

				# 日本語の場合
			when "ja"
				# 翻訳変換後の言葉をTranslateKeywordから抽出
				sToString = coKeyword.ja unless (coKeyword.ja == nil) || (coKeyword.ja == "")
			else
			end
			# printf debug
			#STDERR.puts "#{sKeyword}=>#{sToString}(#{nCount}/#{nTotalCount}):"
			err_print(ERROR_LEVEL_03, "#{sKeyword}=>#{sToString}(#{nCount}/#{nTotalCount}):", STDERR)

			sToString.gsub!(/\\n/, "\n") if sToString =~ /\\n/

			# 翻訳後言葉をREXML::Elementsの値に設定
			coChild.text = sToString
			#STDERR.puts coChild.text
			err_print(ERROR_LEVEL_03, coChild.text, STDERR)
		end
#STDERR.puts hDatabase
			#err_print(ERROR_LEVEL_05, "#{hDataBase}".text, STDERR)
		# 現在までの翻訳単語数を返す
		return nCount
	end

	###################################################
	# TranslateSMLIB::ts_translation_from_codiclists
	# TranslateDicListsオブジェクトを用いて
	# xml（REXMLオブジェクト）内のメニュー単語キーワードを
	# 翻訳する関数
	#  
	#  概要：
	#    あらかじめ翻訳辞書オブジェクトとして用意した
	#    TranslateSummariesオブジェクトを用いて、
	#    tsファイルから作成したREXMLオブジェクト内の
	#    対象要素を翻訳します。
	#    翻訳先は指定できます。
	#  
	#  指定可能翻訳先
	#    "fr"		フランス語
	#    "en"		英語
	#    "ja"		日本語
	#    
	#   coParent					親REXML::Elementオブジェクト
	#   coDicLists				翻訳辞書オブジェクト（TranslateSummaries)
	#   nTotalCount				変換対象単語数　
	#   nCount						現在までに翻訳した単語数
	#   sToLang						翻訳先言語
	###################################################
	def ts_translation_from_codiclists(coDocRoot, coDicLists, nTotalCount, nCount=0, sToLang="ja")
		# 
		#
		# 親REXML::Elementオブジェクトから
		# REXML::Elementsオブジェクトを作成し、
		# その子供を取り出して各個に処理
		#coDocument = coDocRoot.document
		coDocument = coDocRoot
		acoContexts = coDocument.get_elements("/TS/context")

STDERR.puts "acoContexts num = #{acoContexts.size}"

		for coContext in acoContexts
			acoGroupNames = coContext.get_elements("name")
			sGroupName = ""
			for coGroupName in acoGroupNames
				sGroupName = coGroupName.text.to_s
				break
			end
STDERR.puts "	sKeywordGroup:#{sGroupName}"
			coDicKeywordGroup = coDicLists[sGroupName]
			next if coDicKeywordGroup.to_s.size == 0

			acoMessages = coContext.get_elements("message")
			for coMessage in acoMessages
				coSource = coMessage.elements["source"]
				next if coSource == nil
				sKeyword = coSource.text.to_s
				nCount += 1
				coDicKeyword = coDicKeywordGroup[sKeyword]
				next unless coDicKeyword
				coChild = coMessage.elements["translation"]
				# 翻訳変換後の言葉をメニュー単語キーワードに設定
				sToString = sKeyword.to_s
	
				# 翻訳実行部分
				# 翻訳先言語の選択
				case sToLang
					# フランス語の場合
				when "fr"
					# 翻訳変換後の言葉をTranslateKeywordから抽出
					sToString = coDicKeyword.fr unless (coDicKeyword.fr == nil) || (coDicKeyword.fr == "")
	
					# 英語の場合
				when "en"
					# 翻訳変換後の言葉をTranslateKeywordから抽出
					sToString = coDicKeyword.en unless (coDicKeyword.en == nil) || (coDicKeyword.en == "")
	
					# 日本語の場合
				when "ja"
					# 翻訳変換後の言葉をTranslateKeywordから抽出
					sToString = coDicKeyword.ja unless (coDicKeyword.ja == nil) || (coDicKeyword.ja == "")
				else
				end
				# printf debug
				#STDERR.puts "#{sKeyword}=>#{sToString}(#{nCount}/#{nTotalCount}):"
				err_print(ERROR_LEVEL_03, "#{sKeyword}=>#{sToString}(#{nCount}/#{nTotalCount}):", STDERR)
	
				sToString.gsub!(/\\n/, "\n") if sToString =~ /\\n/
	
				# 翻訳後言葉をREXML::Elementsの値に設定
				coChild.text = sToString
				STDERR.puts "		#{sKeyword}:<#{coChild.text}>"
				#STDERR.puts coChild.text
				err_print(ERROR_LEVEL_03, coChild.text, STDERR)
			end

		end

#STDERR.puts hDatabase
			#err_print(ERROR_LEVEL_05, "#{hDataBase}".text, STDERR)
		# 現在までの翻訳単語数を返す
		return nCount
	end

	###################################################
	# TranslateSMLIB::traverse_count_translate_tag
	# xml（REXMLオブジェクト）内のメニュー単語キーワード数算出関数
	#  
	#  概要：
	#		xml(REXMLオブジェクト)内にメニュー単語キーワード数を
	#		トラバースしながら数える関数です。
	#		現在までの変換数/総変換数　の表示のように
	#		進捗表示に用います。
	#  
	#   coParent					親REXML::Elementオブジェクト
	#   count							現在までに翻訳した単語数
	#   sToLang						翻訳先言語
	###################################################
	def traverse_count_translate_tag(coParent, nCount=0)
		# 親REXML::Elementオブジェクトから
		# REXML::Elementsオブジェクトを呼び出し
		# 各子供REXML::Elementsオブジェクトを取り出す
		for coChild in coParent.elements
			# 再帰処理
			nCount = traverse_count_translate_tag(coChild, nCount)
			## 要素名が"translation"の要素の数があればnCountに1足す
			#next unless coChild.name.to_s =~ /^translation$/
			# 要素名が"source"の要素の数があればnCountに1足す
			next unless coChild.name.to_s =~ /^source$/
			nCount += 1
		end
		# nCount を返す
		return nCount
	end

	###################################################
	# TranslateSMLIB::qm_to_ts_exec
	# qmファイルからtsファイル変換・生成関数
	#  
	#  概要：
	#    指定したqmファイルパスから
	#    同ディレクトリにtsファイルを生成する関数です。
	#
	#   sQMFilePath				qmファイルパス
	###################################################
	def qm_to_ts_exec(sQMFilePath)
		# 出力tsファイルパスの生成
		#STDERR.puts "sQMFilePath = <#{sQMFilePath}(#{sQMFilePath.class})>"
		sTSFilePath = sQMFilePath.gsub(/\.qm$/, ".ts")

		# sQMFilePath エラーチェック
		return sTSFilePath unless sQMFilePath =~ /_msg_(.+?)\.qm$/
		return sTSFilePath unless File.exist?(sQMFilePath)

		# システムコマンド　lconvertを用いて、tsファイルを作成
		# (lconvertは関数を実行)
		cmd = "lconvert -if qm -of ts -o #{sTSFilePath} -verbose #{sQMFilePath}"
		# printf debug
		#STDERR.puts cmd
		err_print(ERROR_LEVEL_03, cmd, STDERR)
		# システムコマンド実行エラーフラグ格納
		bRet = system(cmd)
		# tsファイルパスを返す
		return sTSFilePath
	end

	###################################################
	# TranslateSMLIB::ts_to_qm_exec
	# tsファイルからqmファイル変換・生成関数
	#  
	#  概要：
	#    指定したtsファイルパスから
	#    同ディレクトリにqmファイルを生成する関数です。
	#
	#   sTSFilePath				tsファイルパス
	###################################################
	def ts_to_qm_exec(sTSFilePath)
		# sTSFilePath エラーチェック
		return false unless sTSFilePath =~ /_msg_(.+?)\.ts$/
		return false unless File.exist?(sTSFilePath)

		# 出力qmファイルパスの生成
		sQMFilePath = sTSFilePath.gsub(/\.ts$/, ".qm")

		# システムコマンド　lconvertを用いて、qmファイルを作成
		# (lconvertは関数を実行)
		cmd = "lconvert -if ts -of qm -o #{sQMFilePath} -verbose #{sTSFilePath}"
		# printf debug
		#STDERR.puts cmd
		err_print(ERROR_LEVEL_03, cmd, STDERR)
		# システムコマンド実行エラーフラグ格納
		bRet = system(cmd)
		# qmファイルパスを返す
		return sQMFilePath
	end

	###################################################
	# TranslateSMLIB::qm_to_qm_exec
	# qmファイル>>tsファイル
	#     >>翻訳後tsファイル>>qmファイル変換・生成関数
	#  
	#  概要：
	#    指定したqmファイルパスから
	#    指定した翻訳先言語に翻訳したqmファイルを作成する関数です。
	#     qmファイル>>tsファイル
	#       >>翻訳後tsファイル>>qmファイル変換・生成関数
	#    の順番に処理を行います。
	#
	#   sQMFilePath				qmファイルパス
	#   coSummaries				翻訳辞書オブジェクト（TranslateSummaries)
	#   sToLang						翻訳先言語
	###################################################
	def qm_to_qm_exec(sQMFilePath, coSummaries, sToLang="ja")
		# sQMFilePath エラーチェック
		# 及び sQMFilePathから翻訳元言語の抽出
		return false unless sQMFilePath =~ /_msg_(.+?)\.qm$/
		sFromLang = $1.to_s
		return false unless File.exist?(sQMFilePath)

		# sQMFilePathに対応したtsファイルパスを生成(中間ファイル1）
		sTSFilePath = sQMFilePath.gsub(/\.qm$/, ".ts")
		# ベースファイル名に含まれる _msg_<翻訳元言語名>の生成
		sFromLangStr = "_msg_#{sFromLang}"
		# ベースファイル名に含まれる _msg_<翻訳先言語名>の生成
		sToLangStr = "_msg_#{sToLang}"
		# 出力qmファイルパスの生成
		sOutputQMFilePath = sQMFilePath.gsub(sFromLangStr, sToLangStr)
		# 中間出力tsファイルパスの生成（中間ファイル2）
		sOutputTSFilePath = sTSFilePath.gsub(sFromLangStr, sToLangStr)

		err_print(ERROR_LEVEL_05, "sQMFilePath:#{sQMFilePath}", STDERR)
		err_print(ERROR_LEVEL_05, "sTSFilePath:#{sTSFilePath}", STDERR)
		err_print(ERROR_LEVEL_05, "sOutputQMFilePath:#{sOutputQMFilePath}", STDERR)
		err_print(ERROR_LEVEL_05, "sOutputTSFilePath:#{sOutputTSFilePath}", STDERR)
		# システムコマンド lconvert を用いて変換実施 ( qm >> ts )
		cmd = "lconvert -if qm -of ts -o #{sTSFilePath} -verbose --target-language #{sToLang} #{sQMFilePath}"
		# printf debug
		#STDERR.puts cmd
		err_print(ERROR_LEVEL_03, cmd, STDERR)
		bRet = system(cmd)

		#エラーチェック 
		return false unless bRet

		# tsファイルの翻訳実行　
		#STDERR.puts "#{sTSFilePath}: #{sFromLang} >> #{sToLang}"
		err_print(ERROR_LEVEL_03, "#{sTSFilePath}: #{sFromLang} >> #{sToLang}", STDERR)
		bRet = translate_from_summaries(sTSFilePath, coSummaries, sFromLang, sToLang)
		# printf debug
		#STDERR.puts bRet
		err_print(ERROR_LEVEL_03, "translate_from_summaries_check:#{sTSFilePath}:#{bRet}", STDERR)

		#エラーチェック 
		return false unless bRet

		# システムコマンド lconvert を用いて変換実施 ( ts >> qm )
		cmd = "lconvert -if ts -of qm -o #{sOutputQMFilePath} -verbose --target-language #{sToLang} #{sOutputTSFilePath}"
		# printf debug
		#STDERR.puts cmd
		err_print(ERROR_LEVEL_03, cmd, STDERR)
		bRet = system(cmd)

		#エラーチェック 
		return false unless bRet

	end

	###################################################
	# TranslateSMLIB::traverse_qm_to_qm
	# qmファイル>>tsファイル
	#     >>翻訳後tsファイル>>qmファイル変換・生成処理を
	#     トラバースして実行する関数
	#  
	#  概要：
	#    指定したフォルダ・ファイル以下に存在するqmファイルについて
	#    指定した翻訳先言語に翻訳したqmファイルを作成する関数です。
	#     qmファイル>>tsファイル
	#       >>翻訳後tsファイル>>qmファイル変換・生成関数
	#    の順番にトラバースしながら再帰処理を行います。
	#
	#   sParentFilePath				処理を行いたいフォルダ・ファイルパス
	#   coSummaries						翻訳辞書オブジェクト（TranslateSummaries)
	#   sToLang								翻訳先言語
	###################################################
	def traverse_qm_to_qm(sParentFilePath, coSummaries, sToLang="ja")
		# sParentFilePath 存在チェック
		return false unless File.exist?(sParentFilePath)
		
		# sParentFilePath がディレクトリでなければqm>>翻訳qm変換実行し、その結果を返す
		return qm_to_qm_exec(sParentFilePath, coSummaries, sToLang) unless File.stat(sParentFilePath).directory?
		# 子供要素（ファイル、フォルダ）を配列に格納
		aChildrenFactors = Dir.entries(sParentFilePath)
		for sChildFactor in aChildrenFactors
			# .(自フォルダ)、..(親フォルダ)はスルー
			next if sChildFactor =~ /\.{1,2}$/
			
			# 子供ファイル・フォルダパスの生成
			aChildFilePath = []
			aChildFilePath << sParentFilePath
			aChildFilePath << sChildFactor
			sChildFilePath = aChildFilePath.join("/")

			# 子供ファイル・フォルダに対して再帰処理
			traverse_qm_to_qm(sChildFilePath,coSummaries, sToLang)
		end
		return true
		
	end

	###################################################
	# TranslateSMLIB::change_language
	# Salome-meca 2010.2 対応
	#     >>翻訳後、日本語-英語切り替えに使用
	#  
	#  概要：
	#    Salome-Meca 2010.2 では対応していない環境設定での
	#    言語切り替えをコマンドベースで対応します。
	#
	#   sSetLanguage				切り替えたい言語
	#                       "ja"		日本語
	#                       "en"		英語
	#                       "fr"		フランス語
	#                       "raw_keyword"	生キーワード	
	###################################################
  def change_language(sSetLanguage="en", sInputFilePath=SALOME_USER_CONFIG_FILE_PATH)
		
		if File.exist?(sInputFilePath) == false then
			err_print(ERROR_LEVEL_01, "Input File \"#{sInputFilePath}\" is none. \nYou have to you execute Salome-Meca at once.", STDERR) 
			exit 1
		end
		# 入力XMLファイルを読み込んでREXML::Documentを生成
		#
		# CONFIGファイル（xmlファイル形式）から作成する
		# REXMLオブジェクト格納用変数の定義
		rexmlDoc = nil

		# tsファイルを開き、REXMLパーサを用いて
		# REXML rootオブジェクトを作成
		File.open(sInputFilePath) {|xmlfile|
				rexmlDoc = REXML::Document.new(xmlfile)
		}
		unless traverse_setting_language_tag(rexmlDoc, sSetLanguage) == true		
			add_language_settings(rexmlDoc, sSetLanguage)
		end


		fOutputXmlFile = File.new(sInputFilePath, "w")
		#			doc.write(fOutputXmlFile, -1, true)
		#	tsファイル書き込み実行
			rexmlDoc.write(fOutputXmlFile)
		fOutputXmlFile.close

	end

	###################################################
	# TranslateSMLIB::traverse_setting_language_tag
	# xml（REXMLオブジェクト）内の言語設定探索及び設定関数
	#  
	#  概要：
	#		xml(REXMLオブジェクト)内の言語設定を探索しながら
	#		変更する関数です。
	#  
	#   coParent					親REXML::Elementオブジェクト
	#   sSetLanguage			言語指定
	#									"ja"	日本語
	#									"en"	英語
	#									"fr"	フランス語
	#									"raw_keyword"	生のキーワード
	###################################################
	def traverse_setting_language_tag(coParent, sSetLanguage="en")
		# 親REXML::Elementオブジェクトから
		# REXML::Elementsオブジェクトを呼び出し
		# 各子供REXML::Elementsオブジェクトを取り出す
		for coChild in coParent.elements
			# 再帰処理
			bRet = traverse_setting_language_tag(coChild, sSetLanguage)
			return bRet if bRet == true
			next unless coChild.name.to_s =~ /^section$/
			next unless coChild.attribute("name").to_s == "language"
			
			for coChildChild in coChild.elements
				next unless coChildChild.attributes["name"] == "language"
				coChildChild.attributes["value"] = sSetLanguage
				bRet = true 
				return bRet
			end
		end
		# false を返す
		return false
	end

	###################################################
	# TranslateSMLIB::add_language_settings
	# xml（REXMLオブジェクト）内の言語設定追加関数
	#  
	#  概要：
	#		xml(REXMLオブジェクト)内の言語設定追加する関数です。
	#  
	#   coParent					親REXML::Elementオブジェクト
	#   sSetLanguage			言語指定
	#									"ja"	日本語
	#									"en"	英語
	#									"fr"	フランス語
	#									"raw_keyword"	生のキーワード
	###################################################
	def add_language_settings(coDoc, sSetLanguage="en")
		#coParent = coDoc.elements.first.parent()
		# 親REXML::Elementオブジェクトに子Elementオブジェクトを追加
		coParent = coDoc.elements["document"]
		#coChild = coParent.add_element("section")
		#coChild.add_attribute("name", "language")
		coChild = coParent.add_element("section", {"name" => "language"})
		coChild.add_element("parameter", {"value" => sSetLanguage, "name" => "language"})
		coChild.add_element("parameter", {"value" => "%P_msg_%L.qm|%P_icons.qm|%P_image.qm", "name" => "translators"})
		# true を返す
		return true
	end

end

############################################
# TranslateKeyword
# メニュー単語キーワード1つ分の翻訳オブジェクト
#
#	accessor :keyword		メニュー単語キーワード
#	accessor :fr				フランス語訳
#	accessor :en				英語訳
#	accessor :ja				日本語訳
#	accessor :raw				Array[keyword,fr,en,ja]
#	accessor :input_ja	日本語の登録データ（含ショートカットキー文字）
#	accessor :option_text	ショートカットキー文字（括弧で囲む）
############################################
class TranslateKeyword
	attr_accessor :keyword
	attr_accessor :fr_raw
	attr_accessor :fr
	attr_accessor :en
	attr_accessor :en_raw
	attr_accessor :ja
	attr_accessor :ja_raw
	attr_accessor :raw
	attr_accessor :input_ja
	attr_accessor :option_text
	attr_accessor :change_flag
	##########################################
	# TranslateKeyword::initialize
	# TranslateKeyword 初期化関数
	#  aFactor		登録キーワード配列[キーワード,フランス語,英語,日本語]
	#  coParentDicLists		親TranslateDicListsオブジェクト
	#  exclusion: aFactor [keyword, fr, en, ja]
	##########################################
	def initialize(aFactor=["","","",""],coParentDicLists=TranslateDicLists.new(), bForceFlag=false, coParentKeywordGroup=false)
		@change_flag = false
		@keyword = aFactor[0].to_s.gsub(/\\n\n/,"\n")
		@fr = aFactor[1].to_s.gsub(/\\n\n/,"\n")
		@en = aFactor[2].to_s.gsub(/\\n\n/,"\n")
		@ja = aFactor[3].to_s.gsub(/\\n\n/,"\n")
		@fr_raw = ""
		@en_raw = ""
		@ja_raw = ""
		@raw = Array.new(aFactor)
		if coParentKeywordGroup == false then
			coParentDicLists.install(self, bForceFlag)
		else
			coParentKeywordGroup.install(self, bForceFlag)
		end
		@parent_dic_lists = coParentDicLists
		@parent_keyword_group = coParentKeywordGroup
		@option_text = ""
	end
	
	def update(aFactor=["","","",""])
		self.keyword = aFactor[0].to_s.gsub(/\\n\n/,"\n")
		self.fr = aFactor[1].to_s.gsub(/\\n\n/,"\n")
		self.en = aFactor[2].to_s.gsub(/\\n\n/,"\n")
		self.ja = aFactor[3].to_s.gsub(/\\n\n/,"\n")
		self.raw = Array.new(aFactor)
	end

	##########################################
	# TranslateKeyword::parent
	# getter　親TranslateDicListsオブジェクトを返す
	##########################################
	def parent()
		return @parent_dic_lists
	end

	##########################################
	# TranslateKeyword::parent_keyword_group
	# getter　親TranslateKeywordGroupオブジェクトを返す
	##########################################
	def parent_keyword_group()
		return @parent_keyword_group
	end

	##########################################
	# TranslateKeyword::print
	# オブジェクト内表示関数
	##########################################
	def print(oIO=STDOUT)
		if oIO != STDOUT && oIO != STDERR then
			oIO.puts "			keyword     : #{@keyword}"
			oIO.puts "			raw         : #{@fr}"
			oIO.puts "			fr_raw          : #{@fr_raw}"
			oIO.puts "			en_raw          : #{@en_raw}"
			oIO.puts "			ja_raw          : #{@ja_raw}"
			oIO.puts "			fr          : #{@fr}"
			oIO.puts "			en          : #{@en}"
			oIO.puts "			ja          : #{@ja}"
			oIO.puts "			input_ja    : #{@input_ja}"
			oIO.puts "			option_text : #{@option_text}"
			oIO.puts "			change_flag : #{@change_flag}"
		end
		nErrorLevel = TranslateSMLIB::ERROR_LEVEL_03
		TranslateSMLIB.err_print(nErrorLevel, "			keyword     : #{@keyword}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			raw         : #{@fr}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			fr_raw      : #{@fr_raw}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			en_raw      : #{@en_raw}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			ja_raw      : #{@ja_raw}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			fr          : #{@fr}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			en          : #{@en}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			ja          : #{@ja}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			input_ja    : #{@input_ja}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			option_text : #{@option_text}", oIO)
		TranslateSMLIB.err_print(nErrorLevel, "			change_flag : #{@change_flag}", oIO)
	end
end

############################################
# TranslateKeywordGroup
# メニュー単語キーワードグループ
#
#	attr_accessor :sGroupName
#	attr_accessor :coParentDicLists
############################################
class TranslateKeywordGroup < Hash
	attr_accessor :sGroupName
	attr_accessor :coParentDicLists
	def initialize(sGroupName, coParentDicLists=TranslateDicLists.new())
		@sGroupName = sGroupName
		@coParentDicLists = coParentDicLists
		#coParentDicLists[sGroupName] = self
		coParentDicLists.install_for_group(self)
	end

	##########################################
	# TranslateKeywordGroup::install
	# TranslateKeywordオブジェクトの登録
	#		KeywordGroup		TranslateKeywordオブジェクト
	#		bForceFlag			強制フラグ
	##########################################
	def install(coKeywordItem, bForceFlag=false)
		#self[coKeywordItem.keyword]=coKeywordItem if (self[coKeywordItem.keyword] == nil) || (bForceFlag == true)
		if (self[coKeywordItem.keyword] == nil) || (bForceFlag == true) then
			self[coKeywordItem.keyword]=coKeywordItem
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "	#{coKeywordItem.keyword}(bForceFlag:#{bForceFlag}):installed or updated.", STDERR)
		else
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "	#{coKeywordItem.keyword}(bForceFlag:#{bForceFlag}):already registered.", STDERR)
		end

		STDERR.puts "		coKeywordItem<#{coKeywordItem.keyword}>(#{coKeywordItem.class})"
	end

	##########################################
	# TranslateKeywordGroup::parents
	# 親TranslateDicListsオブジェクトを返す
	# （getter)
	##########################################
	def parent()
		return @coParentDicLists
	end


	##################################
	# TranslateKeywordGroup::print
	# クラスオブジェクトの中身表示
	#  oIO	出力先IOオブジェクト
	##################################
	def print(oIO=STDOUT)
		for sKeyword in self.keys
			if oIO != STDOUT && oIO != STDERR then
				oIO.puts "		sGroupName : #{@sGroupName}"
				oIO.puts
			end
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_03, "		sGroupName : #{@sGroupName}", oIO)
			self[sKeyword].print(oIO)
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_03, "", oIO)
		end
	end
end

############################################
# TranslateDicLists
# tsファイル一つ分をまとめたクラスオブジェクト（Hash)
#
#    TranslateSummaries::keys	メニュー単語のキーワード群
############################################
class TranslateDicLists < Hash
	##########################################
	# TranslateDicLists::create_dic_lists
	# TranslateDicListsオブジェクトの初期化関数
	# （Hashから継承したのでinitializeができなかった）
	#  sListsFileBaseName		tsファイルのベースファイル名
	#  coParentSummaries		自分が所属する親TranslateSummariesオブジェクト
	##########################################
	def create_dic_lists(sListsFileBaseName="", coParentSummaries=TranslateSummaries.new())
		@file_basename = sListsFileBaseName
TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05,"create_dic_lists:sListsFileBaseName:#{sListsFileBaseName}", STDERR)
		coParentSummaries.install(self)
		@parent_summaries = coParentSummaries
		return self
	end

	##########################################
	# TranslateDicLists::file_basename
	# TranslateDicLIstsオブジェクトの対応tsファイルベースファイル名
	# （getter)
	##########################################
	def file_basename()
		return @file_basename
	end

	##########################################
	# TranslateDicLists::parents
	# 親TranslateSummariesオブジェクトを返す
	# （getter)
	##########################################
	def parent()
		return @parent_summaries
	end

	##########################################
	# TranslateDicLists::install
	# TranslateKeywordオブジェクトの登録
	#		coKeywordItem		TranslateKeywordオブジェクト
	#		bForceFlag			強制フラグ
	##########################################
	def install(coKeywordItem, bForceFlag=false)
		#self[coKeywordItem.keyword]=coKeywordItem if (self[coKeywordItem.keyword] == nil) || (bForceFlag == true)
		if (self[coKeywordItem.keyword] == nil) || (bForceFlag == true) then
			self[coKeywordItem.keyword]=coKeywordItem
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "	#{coKeywordItem.keyword}(bForceFlag:#{bForceFlag}):installed or updated.", STDERR)
		else
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "	#{coKeywordItem.keyword}(bForceFlag:#{bForceFlag}):already registered.", STDERR)
		end
	end

	##########################################
	# TranslateDicLists::install_for_group
	# TranslateKeywordGroupオブジェクトの登録
	#		coKeywordGroup		TranslateKeywordGroupオブジェクト
	#		bForceFlag			強制フラグ
	##########################################
	def install_for_group(coKeywordGroup, bForceFlag=false)
		#self[coKeywordItem.keyword]=coKeywordItem if (self[coKeywordItem.keyword] == nil) || (bForceFlag == true)
		if (self[coKeywordGroup.sGroupName] == nil) || (bForceFlag == true) then
			self[coKeywordGroup.sGroupName]=coKeywordGroup
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "	#{coKeywordGroup.sGroupName}(bForceFlag:#{bForceFlag}):installed or updated.", STDERR)
		else
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "	#{coKeywordGroup.sGroupName}(bForceFlag:#{bForceFlag}):already registered.", STDERR)
		end
		#STDERR.puts "coTranslateDicLists = #{self}"
		STDERR.puts "	coKeywordGroup<#{coKeywordGroup.sGroupName}>(#{coKeywordGroup.class})"
	end

	##################################
	# TranslateDicLists::print
	# クラスオブジェクトの中身表示
	#  oIO	出力先IOオブジェクト
	##################################
	def print(oIO=STDOUT)
		for sKeyword in self.keys
			if oIO != STDOUT && oIO != STDERR then
				oIO.puts "	file_basename : #{@file_basename}"
				oIO.puts
			end
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_03, "	file_basename : #{@file_basename}", oIO)
			self[sKeyword].print(oIO)
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_03, "", oIO)
		end
	end
end

############################################
# TranslateSummaries
# すべてのtsファイルをまとめたクラスオブジェクト（Hash)
#
#    TranslateSummaries::keys	各tsファイルのベースファイル名
############################################
class TranslateSummaries < Hash
	##################################
	#TranslateSummaries::install
	#tsファイル一つ分の翻訳キーワード群の追加
	#　　coDicLists		tsファイル内翻訳キーワード群
	#    bForceFlag		強制上書き
	##################################
	def install(coDicLists, bForceFlag=false)
		self[coDicLists.file_basename]=coDicLists if (self[coDicLists.file_basename] == nil) || (bForceFlag == true)
		#PP.pp(coDicLists, STDERR)
		STDERR.puts "coDicLists<#{coDicLists.file_basename}>(#{coDicLists.class})"
	end

	##################################
	# TranslateSummaries::install_all_components
	# 翻訳キーワードの追加（変換辞書オブジェクトとしての作成用）
	#
	# exclusion: aDicLine = [sListFileBaseName, sKeyword, sStr_fr, sStr_en, sStr_ja]
	##################################
	def install_all_components(aDicLine, bForceFlag=false)
		return false if aDicLine.size < 5
		sListFileBaseName = "#{aDicLine[0]}"
		sTargetKeyword = "#{aDicLine[1]}"
		aDicLine.shift
TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "install_all_components:bForceFlag(#{bForceFlag}):sListFileBaseName:#{sListFileBaseName}:#{aDicLine}", STDERR)
		coDicLists = self[sListFileBaseName]

		if coDicLists == nil then
			coKeywordItem = TranslateKeyword.new(aDicLine)
TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "coKeywordItem:#{coKeywordItem}", STDERR)
			coDicLists = coKeywordItem.parent
			coDicLists.create_dic_lists(sListFileBaseName, self)
			coDicLists.install(coKeywordItem, bForceFlag)
			self.install(coDicLists, bForceFlag)
			return true
		end
		coKeywordItem = coDicLists[sTargetKeyword]
		if coKeywordItem == nil
			coKeywordItem = TranslateKeyword.new(aDicLine, coDicLists)
			return true
		end
		if bForceFlag == true then
			coKeywordItem.update(aDicLine)
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "coKeywordItem:#{coKeywordItem.keyword}:updated", STDERR)
		end
		return true
	end

	##################################
	# TranslateSummaries::install_all_components_with_group
	# 翻訳キーワードの追加（変換辞書オブジェクトとしての作成用）
	#
	# exclusion: aDicLine = [sListFileBaseName, sKeywordGroup, sKeyword, sStr_fr, sStr_en, sStr_ja]
	##################################
	def install_all_components_with_group(aDicLine, bForceFlag=false)
		return false if aDicLine.size < 5
		sListFileBaseName = "#{aDicLine[0]}"
		sTargetKeywordGroup = "#{aDicLine[1]}"
		sTargetKeyword = "#{aDicLine[2]}"
		aDicLine.shift
		aDicLine.shift
TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "install_all_components:bForceFlag(#{bForceFlag}):sListFileBaseName:#{sListFileBaseName}:#{aDicLine}", STDERR)
		coDicLists = self[sListFileBaseName]

		if coDicLists == nil then
			coKeywordGroup = TranslateKeywordGroup.new(sTargetKeywordGroup)
TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "coKeywordGroup:#{coKeywordGroup}", STDERR)
			coDicLists = coKeywordGroup.parent
			coDicLists.create_dic_lists(sListFileBaseName, self)
			coDicLists.install_for_group(coKeywordGroup, bForceFlag)
			coKeywordItem = TranslateKeyword.new(aDicLine, coDicLists, bForceFlag, coKeywordGroup)
TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "coKeywordItem:#{coKeywordItem}", STDERR)
			self.install(coDicLists, bForceFlag)
			return true
		end
		coKeywordGroup = coDicLists[sTargetKeywordGroup]
		if coKeywordGroup == nil then
			coKeywordGroup = TranslateKeywordGroup.new(sTargetKeywordGroup, coDicLists)
			coKeywordItem = TranslateKeyword.new(aDicLine, coDicLists, bForceFlag, coKeywordGroup)
TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "coKeywordItem:#{coKeywordItem}", STDERR)
		end
		if coKeywordItem == nil
			coKeywordItem = TranslateKeyword.new(aDicLine, coDicLists, bForceFlag, coKeywordGroup)
TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "coKeywordItem:#{coKeywordItem}", STDERR)
			return true
		end
		if bForceFlag == true then
			coKeywordItem.update(aDicLine)
			TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_05, "coKeywordItem:#{coKeywordItem.keyword}:updated", STDERR)
		end
		return true
	end

	def update_only_ja(sInputKeyword, sJaWord)
		for sTSFileName in self.keys
			STDERR.puts "#{sTSFileName} >> "
			#coTargetKeyword = self[sTSFileName][sInputKeyword]
			next if self[sTSFileName][sInputKeyword] == nil
			#STDERR.puts coTargetKeyword
			STDERR.puts self[sTSFileName][sInputKeyword]
			self[sTSFileName][sInputKeyword].ja = "#{sJaWord}"
		end
	end
	
	##################################
	# TranslateDicLists::print
	# クラスオブジェクトの中身表示
	#  oIO	出力先IOオブジェクト
	##################################
	def print(oIO=STDOUT)
		for sListFileBaseName in self.keys
			self[sListFileBaseName].print(oIO)
			if oIO != STDOUT && oIO != STDERR then
				oIO.puts
			else
				TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_03, "", oIO)
			end
		end

	end

	def search_keyword_groups(sTargetKeywordGroupName)
		aTargetKeywordGroups = []
		for sBaseFileName in self.keys
			coDicLists = self[sBaseFileName]
			coKeywordGroups = coDicLists[sTargetKeywordGroupName]
			aTargetKeywordGroups << coKeywordGroups unless coKeywordGroups == nil
		end

		return aTargetKeywordGroups
	end
end


#########################################################
#
# Main Routin
#		(Execute Test Library)
#
#########################################################
if $0 == __FILE__ then
	TranslateSMLIB.init()
	# 翻訳辞書ファイルの設定
	#sFilePath = TranslateSMLIB::DEFAULT_DIC_FILE_PATH
	sFilePath = TranslateSMLIB.dic_file
	sUserFilePath = TranslateSMLIB.udic_file
	# 翻訳辞書ファイルから 翻訳辞書オブジェクト作成（TranslateSummaries）
	coSummaries = TranslateSMLIB.input_dic_file(sFilePath)
	# 翻訳ユーザ辞書ファイルから 翻訳辞書オブジェクト作成（TranslateSummaries）
	coSummaries = TranslateSMLIB.input_dic_file(sUserFilePath, true)
	# 翻訳辞書ファイルから 翻訳辞書オブジェクト作成（TranslateDicLists）
	coKeywords = TranslateSMLIB.input_dic_file_to_cokeywords(sFilePath)
	# 翻訳ユーザ辞書ファイルから 翻訳辞書オブジェクト作成（TranslateDicLists）
	coKeywords = TranslateSMLIB.input_dic_file_to_cokeywords(sUserFilePath, true)
oOutputSummaries = File.new("output_summaries.log", "w")
	coSummaries.print(oOutputSummaries)
oPutputSummaries.close
	# 引数から*_msg_??.qmファイルに対し各個に処理
	for sFilePath in ARGV
#		next unless sFilePath =~ /_msg_\w\w.ts$/
		next unless sFilePath =~ /_msg_\w\w.qm$/
#		TranslateSMLIB.translate_from_summaries(sFilePath, coSummaries, "fr", "ja")
			#		printf debug
		#STDERR.puts "#{sFilePath}:"
		TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_01, "#{sFilePath}:", STDERR)
		# qm >> 翻訳変換後qm
		bRet = TranslateSMLIB.qm_to_qm_exec(sFilePath, coSummaries, "ja")
		# printf debug
		#STDERR.puts bRet
		TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_01, "#{bRet}", STDERR)
		STDERR.puts
		TranslateSMLIB.err_print(TranslateSMLIB::ERROR_LEVEL_01, "", STDERR)
		
	end
end

