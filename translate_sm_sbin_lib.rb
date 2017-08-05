#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#
# Salome-Meca 2011.2 日本語化変換テーブルファイル作成用
# ライブラリファイル
#
# Salome-Meca 2012.1 用に修正
# Salome-Meca 2012.2 用に修正
#######################################################
require "#{File.dirname(File.expand_path(__FILE__))}/translate_sm_lib.rb"
require "#{File.dirname(File.expand_path(__FILE__))}/translate_ts.rb"
require "fileutils"
require "date"
require "pp"

module TranslateSMsbinLIB
	OLD_VERSION = "from_crowdin_2015.2"
	OLD_VERSION_2 = "2015.1"
	NEW_VERSION = "2015.2"
	DIC_FILE_PATH="#{File.dirname(File.expand_path(__FILE__))}/to_japanese_#{OLD_VERSION}/to_japanese/dic/org/summary_translate_word.dic"
	OLD_DIC_FILE_PATH_2="#{File.dirname(File.expand_path(__FILE__))}/to_japanese_#{OLD_VERSION_2}/to_japanese/dic/org/summary_translate_word.dic"
	OLD_DIC_FILE_PATH="#{File.dirname(File.expand_path(__FILE__))}/to_japanese_#{OLD_VERSION}/to_japanese/dic/org/summary_translate_word.dic"
	OUTPUT_DIC_FILE_PATH="#{File.dirname(File.expand_path(__FILE__))}/to_japanese_#{NEW_VERSION}/to_japanese/dic/org/summary_translate_word_#{NEW_VERSION}.dic"
	module_function
	def traverse_make_dic_file_exec(sParentFilePath, coTranslateSummaries=TranslateSummaries.new())
		return false unless File.exist?(sParentFilePath)
		return make_dic_file_exec(sParentFilePath, coTranslateSummaries) unless File.stat(sParentFilePath).directory?
		aChildrenFactors = Dir.entries(sParentFilePath)
		bRet = true
		for sChildFactor in aChildrenFactors
			next if sChildFactor =~ /\.{1,2}$/
			aChildFilePath = []
			aChildFilePath << sParentFilePath
			aChildFilePath << sChildFactor
			sChildFilePath = aChildFilePath.join("/")
			bOneRet = traverse_make_dic_file_exec(sChildFilePath, coTranslateSummaries)
			bRet = false unless bRet == true
		end
		return bRet
	end

	def make_dic_file_exec(sQMFilePath, coTranslateSummaries=TranslateSummaries.new)
		#return false unless sQMFilePath =~ /_msg_(.+?)\.qm$/
		return false unless sQMFilePath =~ /_(\w{2})\.qm$/
		#return false if sQMFilePath =~ /_msg_ja.qm$/
		case $1.to_s
			when "fr"
				sFrQMFilePath = sQMFilePath.to_s
				#sEnQMFilePath = sFrQMFilePath.gsub("_msg_fr.qm", "_msg_en.qm")
				sEnQMFilePath = sFrQMFilePath.gsub("_fr.qm", "_en.qm")
			when "en"
				sEnQMFilePath = sQMFilePath.to_s
				#sFrQMFilePath = sEnQMFilePath.gsub("_msg_en.qm", "_msg_fr.qm")
				sFrQMFilePath = sEnQMFilePath.gsub("_en.qm", "_fr.qm")
#			when "ja"
#				return true
		end
		bRet = true
		sFrTSFilePath = TranslateSMLIB.qm_to_ts_exec(sFrQMFilePath)
		STDERR.print "#{sFrTSFilePath}: "
		bOneRet = make_dic_lists_class_from_ts(sFrTSFilePath, coTranslateSummaries) unless sFrTSFilePath == false
		STDERR.puts "done(#{bRet})"
		bRet = false if bOneRet == false
		sEnTSFilePath = TranslateSMLIB.qm_to_ts_exec(sEnQMFilePath)
		STDERR.print "#{sEnTSFilePath}: "
		bRet = make_dic_lists_class_from_ts(sEnTSFilePath, coTranslateSummaries) unless sEnTSFilePath == false
		STDERR.puts "done(#{bRet})"
		bRet = false if bOneRet == false
		STDERR.puts 
		#pause()
		#pause() if sFrTSFilePath =~ /LightApp_msg_/
		return bRet
	end
	
	#def make_dic_lists_class_from_ts(sTSFilePath, coTranslateSummaries=TranslateSummaries.new(), coTranslateDicLists=TranslateDicLists.new())
	def make_dic_lists_class_from_ts(sTSFilePath, coTranslateSummaries=TranslateSummaries.new())
#		STDOUT.puts "Check1:#{sTSFilePath}"
		#return false unless sTSFilePath =~ /_msg_(.+?)\.ts$/
		return false unless sTSFilePath =~ /_(\w{2})\.ts$/
		sLang = $1.to_s
		sTSFileBaseName_temp = File.basename(sTSFilePath).gsub(/\.ts$/, "")
		#sTSFileBaseName = sTSFileBaseName_temp.gsub(/_msg_(en|ja)$/, "_msg_fr")
		sTSFileBaseName = sTSFileBaseName_temp.gsub(/_(en|ja)$/, "_fr")
		sTargetTSFilePath = sTSFilePath.gsub(/\.ts$/, "")
		#sTargetTSFilePath = sTargetTSFilePath.gsub(/_msg_(en|ja)$/, "_msg_fr")
		sTargetTSFilePath = sTargetTSFilePath.gsub(/_(en|ja)$/, "_fr")
		# modified by takeru on 2012.5.2
		# modified by takeru on 2012.5.12
		coTranslateDicLists = coTranslateSummaries[sTSFileBaseName]
		#coTranslateDicLists = coTranslateSummaries[sTargetTSFilePath]
		if coTranslateDicLists == nil then
			coTranslateDicLists = TranslateDicLists.new()
			#coTranslateDicLists.create_dic_lists(sTSFileBaseName, coTranslateSummaries) 
		end

		# modified by takeru on 2012.5.2
		# modified by takeru on 2012.5.12
		coTranslateDicLists.create_dic_lists(sTSFileBaseName, coTranslateSummaries) 
		#coTranslateDicLists.create_dic_lists(sTargetTSFilePath, coTranslateSummaries) 
		
		doc = nil
		File.open(sTSFilePath) {|xmlfile|
			doc = REXML::Document.new(xmlfile)
		}
		nTotalCount = TranslateTsLIB.traverse_count_translate_tag(doc.root)
		nCount = traverse_install_keyword(coTranslateDicLists, sLang, doc.root, nTotalCount, 0)
#		STDOUT.puts "Check2:#{sTSFilePath}"

		return true

	end
	
	def traverse_make_dic_file_from_current_version_exec(sParentFilePath, hQmFileBaseNamePath=Hash.new(), coTranslateSummaries=TranslateSummaries.new())
		return false unless File.exist?(sParentFilePath)
		return make_dic_file_from_current_version_exec(sParentFilePath, hQmFileBaseNamePath, coTranslateSummaries) unless File.stat(sParentFilePath).directory?
		begin
			aChildrenFactors = Dir.entries(sParentFilePath)
		rescue
			return false
		end
		bRet = true
		for sChildFactor in aChildrenFactors
			next if sChildFactor =~ /\.{1,2}$/
			aChildFilePath = []
			aChildFilePath << sParentFilePath
			aChildFilePath << sChildFactor
			sChildFilePath = aChildFilePath.join("/")
			bOneRet = traverse_make_dic_file_from_current_version_exec(sChildFilePath, hQmFileBaseNamePath, coTranslateSummaries)
			bRet = false unless bRet == true
		end
		return bRet
	end

	def make_dic_file_from_current_version_exec(sQMFilePath, hQmFileBaseNamePath=Hash.new(), coTranslateSummaries=TranslateSummaries.new)
		#pause()
		#return false unless sQMFilePath =~ /_msg_(.+?)\.qm$/
		return false unless sQMFilePath =~ /_(\w{2}).qm$/
		#return false if sQMFilePath =~ /_msg_ja.qm$/
		STDERR.puts "sQMFilePath = <#{sQMFilePath}(#{sQMFilePath.class})>"

		case $1.to_s
			when "fr"
				sFrQMFilePath = sQMFilePath.to_s
				#sEnQMFilePath = sFrQMFilePath.gsub("_msg_fr.qm", "_msg_en.qm")
				#sJaQMFilePath = sFrQMFilePath.gsub("_msg_fr.qm", "_msg_ja.qm")
				sEnQMFilePath = sFrQMFilePath.gsub("_fr.qm", "_en.qm")
				sJaQMFilePath = sFrQMFilePath.gsub("_fr.qm", "_ja.qm")
			when "en"
				sEnQMFilePath = sQMFilePath.to_s
				#sFrQMFilePath = sEnQMFilePath.gsub("_msg_en.qm", "_msg_fr.qm")
				#sJaQMFilePath = sEnQMFilePath.gsub("_msg_en.qm", "_msg_ja.qm")
				sFrQMFilePath = sEnQMFilePath.gsub("_en.qm", "_fr.qm")
				sJaQMFilePath = sEnQMFilePath.gsub("_en.qm", "_ja.qm")
			when "ja"
				sJaQMFilePath = sQMFilePath.to_s
				#sFrQMFilePath = sJaQMFilePath.gsub("_msg_ja.qm", "_msg_fr.qm")
				#sEnQMFilePath = sJaQMFilePath.gsub("_msg_ja.qm", "_msg_en.qm")
				sFrQMFilePath = sJaQMFilePath.gsub("_ja.qm", "_fr.qm")
				sEnQMFilePath = sJaQMFilePath.gsub("_ja.qm", "_en.qm")
			else
				return false
		end
		bRet = true
		sFrTSFilePath = TranslateSMLIB.qm_to_ts_exec(sFrQMFilePath)
		sEnTSFilePath = TranslateSMLIB.qm_to_ts_exec(sEnQMFilePath)
		sJaTSFilePath = TranslateSMLIB.qm_to_ts_exec(sJaQMFilePath)
		#STDERR.print "#{sFrTSFilePath}: "
		STDERR.puts "sFrTSFilePath: #{sFrTSFilePath}"
		STDERR.puts "sEnTSFilePath: #{sEnTSFilePath}"
		STDERR.puts "sJaTSFilePath: #{sJaTSFilePath}"
		bOneRet = make_dic_lists_class_from_ts_from_current_version(sFrTSFilePath, sEnTSFilePath, sJaTSFilePath, hQmFileBaseNamePath, coTranslateSummaries) unless sFrTSFilePath == false
		#STDERR.puts "done(#{bOneRet}/#{bRet})"
		bRet = false if bOneRet == false
		#STDERR.puts 
		#pause()
		#pause() if sFrTSFilePath =~ /LightApp_msg_/
		return bRet
	end
	
	#def make_dic_lists_class_from_ts(sTSFilePath, coTranslateSummaries=TranslateSummaries.new(), coTranslateDicLists=TranslateDicLists.new())
	def make_dic_lists_class_from_ts_from_current_version(sFrTSFilePath, sEnTSFilePath, sJaTSFilePath, hQmFileBaseNamePath=Hash.new(), coTranslateSummaries=TranslateSummaries.new())
#		STDOUT.puts "Check1:#{sTSFilePath}"
		#return false unless sFrTSFilePath =~ /_msg_(.+?)\.ts$/
		return false unless sFrTSFilePath =~ /_(\w{2})\.ts$/
		sLang = $1.to_s
		sTSFileBaseName_temp = File.basename(sFrTSFilePath).gsub(/\.ts$/, "")
		#sTSFileBaseName = sTSFileBaseName_temp.gsub(/_msg_(en|ja)$/, "_msg_fr")
		sTSFileBaseName = sTSFileBaseName_temp.gsub(/_(en|ja)$/, "_fr")
		#return true if hQmFileBaseNamePath[sTSFileBaseName] == true
		sTargetTSFilePath = sFrTSFilePath.gsub(/\.ts$/, "")
		#sTargetTSFilePath = sTargetTSFilePath.gsub(/_msg_(en|ja)$/, "_msg_fr")
		sTargetTSFilePath = sTargetTSFilePath.gsub(/_(en|ja)$/, "_fr")
		# modified by takeru on 2012.5.2
		# modified by takeru on 2012.5.12
		coTranslateDicLists = coTranslateSummaries[sTSFileBaseName]
		#coTranslateDicLists = coTranslateSummaries[sTargetTSFilePath]
		if coTranslateDicLists == nil then
			coTranslateDicLists = TranslateDicLists.new()
			#coTranslateDicLists.create_dic_lists(sTSFileBaseName, coTranslateSummaries) 
			coTranslateDicLists.create_dic_lists(sTSFileBaseName, coTranslateSummaries) 
		end

		#PP.pp(coTranslateDicLists, STDERR)
		#STDERR.puts coTranslateDicLists
		# modified by takeru on 2012.5.2
		# modified by takeru on 2012.5.12
		#coTranslateDicLists.create_dic_lists(sTargetTSFilePath, coTranslateSummaries) 
		
		doc = nil
		#File.open(sTSFilePath) {|xmlfile|
		#	doc = REXML::Document.new(xmlfile)
		#}
		#nTotalCount = TranslateTsLIB.traverse_count_translate_tag(doc.root)
		#nCount = traverse_install_keyword(coTranslateDicLists, sLang, doc.root, nTotalCount, 0)

		rexmlDocFr = nil
		rexmlDocEn = nil
		rexmlDocJa = nil
#		STDOUT.puts "Check2:#{sTSFilePath}"
		if File.exist?(sFrTSFilePath) == true then
			File.open(sFrTSFilePath) do |sXmlFile|
				#STDERR.puts sXmlFile
				rexmlDocFr = REXML::Document.new(sXmlFile)
			end
		else
			rexmlDocFr = REXML::Document.new("")
		end
		if File.exist?(sEnTSFilePath) == true then
			File.open(sEnTSFilePath) do |sXmlFile|
				#STDERR.puts sXmlFile
				rexmlDocEn = REXML::Document.new(sXmlFile)
			end
		else
			rexmlDocEn = REXML::Document.new("")
		end
		if File.exist?(sJaTSFilePath) == true then
			File.open(sJaTSFilePath) do |sXmlFile|
				#STDERR.puts sXmlFile
				rexmlDocJa = REXML::Document.new(sXmlFile)
			end
		else
			rexmlDocJa = REXML::Document.new("")
		end
		TranslateTsLIB.make_dic_files_from_current_version(coTranslateDicLists, rexmlDocFr, rexmlDocEn, rexmlDocJa)

		PP.pp(coTranslateDicLists, STDERR)
		#STDERR.puts coTranslateDicListC
		hQmFileBaseNamePath[sTSFileBaseName] = true

		return true

	end

	def traverse_merge_from_dic_summaries_to_crowdin_ts_file(sParentFilePath, coTranslateSummaries=TranslateSummaries.new())

		return false unless File.exist?(sParentFilePath)
		return merge_from_dic_summaries_to_crowdin_ts_file(sParentFilePath, coTranslateSummaries) unless File.stat(sParentFilePath).directory?

		aChildrenFactors = Dir.entries(sParentFilePath)
		for sChildFactor in aChildrenFactors
			next if sChildFactor =~ /\.{1,2}$/

			aChildFilePath = []
			aChildFilePath << sParentFilePath
			aChildFilePath << sChildFactor
			sChildFilePath = aChildFilePath.join("/")

			traverse_merge_from_dic_summaries_to_crowdin_ts_file(sChildFilePath, coTranslateSummaries)

		end
		return true

	end

	def merge_from_dic_summaries_to_crowdin_ts_file(sJaTSFilePath, coTranslateSummaries=TranslateSummaries.new())
		return false unless File.exist?(sJaTSFilePath)
		#return false unless sJaTSFilePath =~ /_msg_ja.ts$/
		return false unless sJaTSFilePath =~ /_ja.ts$/

		rexmlDocJa = nil
		File.open(sJaTSFilePath) do |sXmlFile|
			rexmlDocJa = REXML::Document.new(sXmlFile)
		end

		sTsFileBaseName = File.basename(sJaTSFilePath).gsub(/_ja\.ts$/, "_fr")

		STDERR.puts("#{sTsFileBaseName}:")
		rexmlGroupNamesJa = rexmlDocJa.get_elements("/TS/context")

		bRet = true
		for rexmlGroupNameJa in rexmlGroupNamesJa
			bRetOne = merge_from_dic_summaries_to_crowdin_ts_file_core(rexmlGroupNameJa, coTranslateSummaries)
			bRet = false if bRetOne == false
		end
		sBackupFilePath = merge_from_dic_summaries_to_crowdin_ts_make_backup_file_name(sJaTSFilePath)
		FileUtils.move(sJaTSFilePath, sBackupFilePath)

		fToXmlFile = File.new(sJaTSFilePath, "w")
			rexmlDocJa.write(fToXmlFile)
		fToXmlFile.close
		STDERR.puts("#{sTsFileBaseName}:#{bRet}")
	end
	
	def merge_from_dic_summaries_to_crowdin_ts_file_core(rexmlGroupNameJa, coTranslateSummaries=TranslateSummaries.new())

			bRet = false
			sGroupName = rexmlGroupNameJa.get_elements("name").first.text.to_s
			acoTranslateKeywordGroups = coTranslateSummaries.search_keyword_groups(sGroupName)

			if acoTranslateKeywordGroups.size == 0 then
				STDERR.puts("	#{sGroupName}:#{bRet}")
				STDERR.puts
				return bRet
			end
			STDERR.puts("	#{sGroupName}:")
			rexmlKeywordsJa = []
			rexmlKeywordsJa = rexmlGroupNameJa.get_elements("message") unless rexmlGroupNameJa == nil

			bRet = true
			for rexmlKeywordJa in rexmlKeywordsJa
				sSourceName = rexmlKeywordJa.get_elements("source").first.text.to_s
				#STDERR.puts("		#{sSourceName}:")
				rexmlKeywordJaTranslation = rexmlKeywordJa.get_elements("translation").first
				bRetOne = true
				for coTranslateKeywordGroup in acoTranslateKeywordGroups
					coTargetTranslateKeyword = coTranslateKeywordGroup[sSourceName]
					if coTargetTranslateKeyword == nil then
						bRetOne = false
						next
					end
					rexmlKeywordJaTranslation.text = coTargetTranslateKeyword.ja.to_s
					rexmlKeywordJaTranslation.add_attribute("change", "true")
					bRetOne = true
					break
				end
				sJa = rexmlKeywordJaTranslation.text
				STDERR.puts("		#{sSourceName}:#{sJa}:#{bRetOne}")
				if bRetOne == false then
					bRet = false
				end
			end

			STDERR.puts("	#{sGroupName}:#{bRet}")
			STDERR.puts
			return bRet
	end

	def merge_from_dic_summaries_to_crowdin_ts_make_backup_file_name(sTargetFilePath)
		sBackupFilePathBase = sTargetFilePath.clone

		dateToday = Date.today()
		sToday = dateToday.strftime("%Y%m%d")
		nCount = 0
		sBackupFilePathBase << "_backup_#{sToday}"
		while(true) do
			nCount += 1
			sCount = sprintf("_%03d", nCount)
			sBackupFilePath = sBackupFilePathBase.clone
			sBackupFilePath << sCount
			break unless File.exist?(sBackupFilePath)
		end
		return sBackupFilePath
	end

	#def list_up_make_dic_file_from_crowdin_fr_ts_file(sTargetLang="fr-FR")
	def list_up_make_dic_file_from_crowdin_fr_ts_file(sTargetLang="fr")
		sCmdLine = "find ./#{sTargetLang} -name \"*.ts\""
		sTSFileList = `#{sCmdLine}`
		aTSFileList = sTSFileList.split(/\n/)
		aTSFilesLists = []
		sTarget2Lang = sTargetLang.split("-").first
		for sTSFile in aTSFileList
			hTSFiles = Hash.new()
			hTSFiles[sTargetLang] = sTSFile

			case sTargetLang
			#when "fr-FR"
			when "fr"
				#aAddLangs = ["en-US", "ja-JP"]
				aAddLangs = ["en", "ja"]
			#when "en-US"
			when "en"
				#aAddLangs = ["fr-FR", "ja-JP"]
				aAddLangs = ["fr", "ja"]
			#when "ja-JP"
			when "ja"
				#aAddLangs = ["fr-FR", "en-JP"]
				aAddLangs = ["fr", "en"]
			end

			
			for sAddLang in aAddLangs
				#STDERR.puts "sAddLang = #{sAddLang}"
				sAdd2Lang = sAddLang.split("-").first
				sOtherTSFile = sTSFile.gsub(sTargetLang, sAddLang)
				sOtherTSFile = sOtherTSFile.gsub("_#{sTarget2Lang}.ts", "_#{sAdd2Lang}.ts")
				#STDERR.puts "#{sOtherTSFile}"
				hTSFiles[sAddLang] = sOtherTSFile if File.exist?(sOtherTSFile)
			end

			aTSFilesLists << hTSFiles
		end
		return aTSFilesLists
	end

	def import_from_crowdin_to_summaries_class(coTranslateSummaries=TranslateSummaries.new())

		aTSFilesLists = list_up_make_dic_file_from_crowdin_fr_ts_file()

		hQmFileBaseNamePath = Hash.new()
		for hTSFiles in aTSFilesLists
#			sFrTSFilePath = hTSFiles["fr-FR"]
#			sEnTSFilePath = hTSFiles["en-US"]
#			sJaTSFilePath = hTSFiles["ja-JP"]
			sFrTSFilePath = hTSFiles["fr"]
			sEnTSFilePath = hTSFiles["en"]
			sJaTSFilePath = hTSFiles["ja"]
			bOneRet = make_dic_lists_class_from_ts_from_current_version(sFrTSFilePath, sEnTSFilePath, sJaTSFilePath, hQmFileBaseNamePath, coTranslateSummaries) unless sFrTSFilePath == false
		end

		return coTranslateSummaries
	end

	def traverse_install_keyword(coTranslateDicLists, sLang, parent, nTotalCount, nCount=0)
#		STDOUT.puts "Search Tag:#{parent.size}(#{nCount}/#{nTotalCount})[#{sLang}]"
		for child in parent.elements
			nCount = traverse_install_keyword(coTranslateDicLists, sLang, child, nTotalCount, nCount)
			next unless child.name.to_s =~ /^translation$/
			sKeyword = parent.elements["source"].text.to_s
			nCount += 1
			STDOUT.puts "#{sKeyword}(#{nCount}/#{nTotalCount}):"
			coTranslateKeyword = coTranslateDicLists[sKeyword]
			coTranslateKeyword = TranslateKeyword.new([sKeyword,nil,nil,nil], coTranslateDicLists) if coTranslateKeyword == nil

			sTargetText = "#{child.text}"
			sTargetText.chomp!
			sTargetText.gsub!(/\n/, "\\n") if sTargetText =~ /\n/
			case sLang
				when "fr"
#					STDOUT.puts "Check<#{sKeyword}[#{sLang}]>:#{child.text.to_s}"
					#coTranslateKeyword.fr = child.text.to_s if coTranslateKeyword.fr == nil
					#coTranslateKeyword.fr = child.text.to_s if coTranslateKeyword.fr.size == 0
					coTranslateKeyword.fr = sTargetText if coTranslateKeyword.fr.size == 0
				when "en"
#					STDOUT.puts "Check<#{sKeyword}[#{sLang}]>:#{child.text.to_s}"
					#coTranslateKeyword.en = child.text.to_s if coTranslateKeyword.en == nil
					#coTranslateKeyword.en = child.text.to_s if coTranslateKeyword.en.size == 0
					coTranslateKeyword.en = sTargetText if coTranslateKeyword.en.size == 0
				when "ja"
#					STDOUT.puts "Check<#{sKeyword}[#{sLang}]>:#{child.text.to_s}"
					#coTranslateKeyword.ja = child.text.to_s if coTranslateKeyword.ja == nil
					#coTranslateKeyword.ja = child.text.to_s if coTranslateKeyword.ja.size == 0
					coTranslateKeyword.ja = sTargetText if coTranslateKeyword.ja.size == 0
			end
		end
		return nCount
	end

	def translate_from_class(coTranslateSummaries, coParentDicListsByFr, coParentDicListsByEn)
		nTotalCount = coTranslateSummaries.size
		bRet = true
		for sBaseName in coTranslateSummaries.keys
			coTranslateDicLists = coTranslateSummaries[sBaseName]
			nListsTotalCount = coTranslateDicLists.size
			nCount = 0
			for sKeyword in coTranslateDicLists.keys
				nCount += 1
				STDOUT.puts "#{sBaseName}:#{sKeyword}(#{nCount}/#{nListsTotalCount}/#{nTotalCount})"
				coTranslateKeyword = coTranslateDicLists[sKeyword]
				bOneRet = translate_core_to_ja(coTranslateKeyword, coParentDicListsByFr, coParentDicListsByEn)
				bRet = false if bOneRet == false
			end

		end

	end

	def translate_from_class_for_current_version(coTranslateSummaries, coParentDicListsByFr, coParentDicListsByEn)
		nTotalCount = coTranslateSummaries.size
		bRet = true
		for sBaseName in coTranslateSummaries.keys
			case sBaseName
			when /Eficas/
				bEficasFlag = true
			else
				bEficasFlag = false
			end
			coTranslateDicLists = coTranslateSummaries[sBaseName]
			nListsTotalCount = coTranslateDicLists.size
			for sKeywordGroup in coTranslateDicLists.keys
				coTranslateKeywordGroups = coTranslateDicLists[sKeywordGroup]
				nGroupsTotalCount = coTranslateKeywordGroups.size
				nCount = 0
				for sKeyword in coTranslateKeywordGroups.keys
					nCount += 1
					STDOUT.puts "#{sBaseName}:#{sKeyword}(#{nCount}/#{nGroupsTotalCount}/#{nListsTotalCount}/#{nTotalCount})"
					coTranslateKeyword = coTranslateKeywordGroups[sKeyword]
#STDERR.puts "Check(#{coTranslateKeyword}[#{coTranslateKeyword.class}])."
#coTranslateKeyword.print(STDERR)
					bOneRet = translate_core_to_ja(coTranslateKeyword, coParentDicListsByFr, coParentDicListsByEn, bEficasFlag)
					bRet = false if bOneRet == false
				end
			end

		end

	end



	def translate_core_to_ja(coTranslateKeyword, coParentDicListsByFr, coParentDicListsByEn, bEficasFlag)
		STDERR.puts
		STDERR.puts "---"
#coTranslateKeyword.print(STDERR)
#PP.pp(coParentDicListsByFr, STDERR)
#PP.pp(coParentDicListsByEn, STDERR)
		sFrRaw = coTranslateKeyword.fr.to_s
		sEnRaw = coTranslateKeyword.en.to_s
		sJaRaw = coTranslateKeyword.ja.to_s

		return true unless sJaRaw.size == 0
		sOptionText = ""
#STDOUT.puts "Check(translate_core_to_ja:initial):1[#{sFrRaw}]"
		if (sFrRaw.to_s.size == 0) || ((sFrRaw == coTranslateKeyword.keyword) && (bEficasFlag == false)) then
#STDOUT.puts "Check(translate_core_to_ja:initial):2.1"
			return false if (sEnRaw.size == 0) || (sEnRaw == coTranslateKeyword.keyword) 
			sEn, sOptionText = TranslateTsLIB.change_escape_text(sEnRaw)
STDOUT.puts "Check(En:#{sEn})"
			coTranslateKeywordEn = coParentDicListsByEn[sEn]
			coTranslateKeyword.option_text = sOptionText
			sFr = ""
			sFr = coTranslateKeywordEn.fr.to_s unless coTranslateKeywordEn == nil
			if (sFr.size == 0) || (sFr == coTranslateKeyword.keyword) then
				sFr = TranslateLIB.translate(sEn, "en", "fr")
				STDERR.puts "\"#{sFr}\" Translated by Microsoft from en to fr."
			else
				STDERR.puts "\"#{sFr}\" Translated by Old Version from #{coTranslateKeyword.keyword} to fr."
			end
			sFr.gsub!(/\n/, "\\n")
			if sFr.to_s.size == 0 then
			else
				sFrFull = "#{sFr}"
				sFrFull << sOptionText
				coTranslateKeyword.fr = sFrFull
			end
			sJa = ""
			sJa = coTranslateKeywordEn.ja.to_s unless coTranslateKeywordEn == nil
			if (sJa.size == 0) || (sJa == coTranslateKeyword.keyword) then
				sJa = TranslateLIB.translate(sEn, "en", "ja")
				STDERR.puts "\"#{sJa}\" Translated by Microsoft from en to ja."
			else
				STDERR.puts "\"#{sJa}\" Translated by Old Version from #{coTranslateKeyword.keyword} to ja."
			end
			sJa.gsub!(/\n/, "\\n")
			if sJa.to_s.size == 0 then
			else
				sJaFull = "#{sJa}"
				sJaFull << sOptionText
				coTranslateKeyword.ja = "#{sJaFull}"
				coTranslateKeyword.input_ja = "#{sJa}"
			end
		else
#STDOUT.puts "Check(translate_core_to_ja:initial):2.2"
			sFr, sOptionText = TranslateTsLIB.change_escape_text(sFrRaw)
			sEn, sOptionText = TranslateTsLIB.change_escape_text(sEnRaw) unless sEnRaw.size == 0
STDOUT.puts "Check(Fr:#{sFr})"
			coTranslateKeywordFr = coParentDicListsByFr[sFr]
			coTranslateKeyword.option_text = sOptionText
			if (sEnRaw.size == 0) || (sEn == coTranslateKeyword.keyword) then
				sEn = ""
				sEn = coTranslateKeywordFr.en.to_s unless coTranslateKeywordFr == nil
				if (sEn.size == 0) || (sEn == coTranslateKeyword.keyword) then
					sEn = TranslateLIB.translate(sFr, "fr", "en")
					STDERR.puts "\"#{sEn}\" Translated by Microsoft from fr to en."
				else
					STDERR.puts "\"#{sEn}\" Translated by Old Version from #{coTranslateKeyword.keyword} to en."
				end
				sEn.gsub!(/\n/, "\\n")
				if sEn.to_s.size == 0 then
				else	
					sEnFull = "#{sEn}"
					sEnFull << sOptionText
					coTranslateKeyword.en = "#{sEnFull}"
				end
			end
			# Change routing to transate japanese.
			# Modified by Takeru on 2012.07.29
			sJa = ""
			sJa = coTranslateKeywordFr.ja.to_s unless coTranslateKeywordFr == nil
STDOUT.puts "Check(Ja:#{sJa})"
			if (sJa.size == 0) || (sJa == coTranslateKeyword.keyword) then
				sJa = TranslateLIB.translate(sFr, "fr", "ja")
				STDERR.puts "\"#{sJa}\" Translated by Microsoft from fr to ja."
			else
				STDERR.puts "\"#{sJa}\" Translated by Old Version from #{coTranslateKeyword.keyword} to ja."
			end
			sJa.gsub!(/\n/, "\\n")
			if sJa.to_s.size == 0 then
			else
				sJaFull = "#{sJa}"
				sJaFull << sOptionText
				coTranslateKeyword.ja = "#{sJaFull}"
				coTranslateKeyword.input_ja = "#{sJa}"
			end
		end
#		if coTranslateKeyword.parent.file_basename == "YACS_msg_fr" then
#			pause()
#		end
#		if sJaFull =~ /&/ then
#		if true then
		if coTranslateKeyword.keyword.to_s =~ /MEM_DESK_/ then
			STDOUT.puts "sFr = #{sFr}"
			STDOUT.puts "sFrFull = #{sFrFull}"
			STDOUT.puts "sFrRaw = #{sFrRaw}"
			STDOUT.puts "sEn = #{sEn}"
			STDOUT.puts "sEnFull = #{sEnFull}"
			STDOUT.puts "sEnRaw = #{sEnRaw}"
			STDOUT.puts "sJa = #{sJa}"
			STDOUT.puts "sJaFull = #{sJaFull}"
			STDOUT.puts "sOptionText = #{sOptionText}"
	
#			pause()
		end
		STDERR.puts "---"
		return true
	end

	def pause(sMsg="Press Any Key, so you can continue.", oIO=STDOUT)
		oIO.puts sMsg
		sTempStr = nil
		while (sTempStr == nil) do
			sTempStr = gets()
		end
	end

	def merge_dic_files(sBaseInputFilePath, sAddInputFilePath, bForceFlag=true)
		TranslateSMLIB.init()
STDERR.puts "Check1(#{sBaseInputFilePath})"
		return false unless File.exist?(sBaseInputFilePath)
STDERR.puts "Check2(#{sBaseInputFilePath})"
		return false unless FileTest.file?(sBaseInputFilePath)
STDERR.puts "Check3(#{sAddInputFilePath})"
		return false unless File.exist?(sAddInputFilePath)
STDERR.puts "Check4(#{sAddInputFilePath})"
		return false unless FileTest.file?(sAddInputFilePath)
		sBaseBackupFilePath = "#{sBaseInputFilePath}.backup"
		nCount = 0
STDERR.puts "Check5(#{sBaseBackupFilePath})"
		while File.exist?(sBaseBackupFilePath) == true do
			nCount += 1
			sBaseBackupFilePath = "#{sBaseInputFilePath}.backup#{nCount}"
STDERR.puts "Check#{5+nCount}(#{sBaseBackupFilePath})"
		end
STDERR.puts "Check#{6+nCount}"
		FileUtils.copy(sBaseInputFilePath, sBaseBackupFilePath)
STDERR.puts "Check#{7+nCount}"
		coSummaries = TranslateSMLIB.input_dic_file(sBaseInputFilePath)
STDERR.puts "Check#{8+nCount}"
		coSummaries = TranslateSMLIB.input_dic_file(sAddInputFilePath, coSummaries, bForceFlag)
STDERR.puts "Check#{9+nCount}"
		fOutputFile = File.new(sBaseInputFilePath, "w")
			TranslateSMLIB.output_dic_summary(coSummaries, fOutputFile)
		fOutputFile.close
STDERR.puts "Check#{10+nCount}"

	end

	def input_keyword_and_ja_file(sFilePath=@dic_file, coSummaries=TranslateSummaries.new(), bForceFlag=false)
		IO.foreach(sFilePath) do |sLine|
			#STDERR.puts sLine
			sLine.chomp!
			sLine.chomp!("\\n")
			next if sLine =~ /^#/
			#STDERR.puts sLine
			#aFactors = sLine.split(/\t/)
			aFactors = sLine.split("	")
			pp aFactors,"(#{aFactors.size})"
			next if aFactors.size < 2
			sInputKeyword = aFactors[0].clone
			sJaWord = aFactors[1].clone
			#sInputKeyword, sJaWord = sLine.split(/\t/)
			#STDERR.puts sInputKeyword,"	",sJaWord
			sJaWord.gsub!(/\\t/,"	")
			sJaWord.gsub!(/\\n/,"\n")
			coSummaries.update_only_ja(sInputKeyword, sJaWord)
		end
		return coSummaries
	end

	def merge_dic_files_from_keyword_and_ja(sBaseInputFilePath, sAddInputFilePath, bForceFlag=true)
		TranslateSMLIB.init()
		return false unless File.exist?(sBaseInputFilePath)
		return false unless FileTest.file?(sBaseInputFilePath)
		return false unless File.exist?(sAddInputFilePath)
		return false unless FileTest.file?(sAddInputFilePath)
		sBaseBackupFilePath = "#{sBaseInputFilePath}.backup"
		nCount = 0
		while File.exist?(sBaseBackupFilePath) == true do
			nCount += 1
			sBaseBackupFilePath = "#{sBaseInputFilePath}.backup#{nCount}"
		end
		FileUtils.copy(sBaseInputFilePath, sBaseBackupFilePath)
		coSummaries = TranslateSMLIB.input_dic_file(sBaseInputFilePath)
		pp coSummaries
		coSummaries = input_keyword_and_ja_file(sAddInputFilePath, coSummaries)
		fOutputFile = File.new(sBaseInputFilePath, "w")
			TranslateSMLIB.output_dic_summary(coSummaries, fOutputFile)
		fOutputFile.close
	end
end

class TranslateDicListsByFr < Hash

	def install_from_fr(coKeywordItemFr, bForceFlag=false)
		self[coKeywordItemFr.fr]=coKeywordItemFr if (self[coKeywordItemFr.fr_raw] == nil) || (bForceFlag == true)
	end

	def disp(oIO=STDOUT)
		for sKey in self.keys.sort
			self[sKey].disp(oIO)
		end
	end
end

class TranslateDicListsByEn < Hash

	def install_from_en(coKeywordItemFr, bForceFlag=false)
		self[coKeywordItemFr.en]=coKeywordItemFr if (self[coKeywordItemFr.en_raw] == nil) || (bForceFlag == true)
	end

	def disp(oIO=STDOUT)
		for sKey in self.keys.sort
			oIO.puts "#{sKey}::"
			self[sKey].disp(oIO)
		end
	end
end

class TranslateKeywordFr
	attr_accessor :keyword
	attr_accessor :keyword_group_name
	attr_accessor :fr
	attr_accessor :en
	attr_accessor :ja
	attr_accessor :fr_option_text
	attr_accessor :fr_raw
	attr_accessor :en_option_text
	attr_accessor :en_raw
	attr_accessor :ja_option_text
	attr_accessor :ja_raw

	#def initialize(sKeyword="", sFrRaw="", coParentDicLIstsByFr=TranslateDicListsByFr.new())
	def initialize(aFactor=["","","","","",""], sFrRaw="", coParentDicListsByFr=TranslateDicListsByFr.new(), coParentDicListsByEn=TranslateDicListsByEn.new(), bForceFlag=false)
#		@keyword=sKeyword.to_s
#		@fr_raw=sFrRaw.to_s
		@keyword_group_name=aFactor[1].to_s
		@keyword=aFactor[2].to_s
		@fr_raw=aFactor[3].to_s
		@en_raw=aFactor[4].to_s
#		@ja_raw=aFactor[5].to_s.gsub(sOptionTextFr,"")
		@ja_raw=aFactor[5].to_s
		sToTextFr, sOptionTextFr = TranslateTsLIB.change_escape_text(@fr_raw)
		@fr=sToTextFr.to_s
		@fr_option_text=sOptionTextFr.to_s
		sToTextEn, sOptionTextEn = TranslateTsLIB.change_escape_text(@en_raw)
		@en=sToTextEn.to_s
		@en_option_text=sOptionTextEn.to_s
		sToTextJa, sOptionTextJa = TranslateTsLIB.change_escape_text_for_ja(@ja_raw)
		@ja=sToTextJa.to_s
		@ja_option_text=sOptionTextJa.to_s
		coParentDicListsByFr.install_from_fr(self, bForceFlag)
		coParentDicListsByEn.install_from_en(self, bForceFlag)
	end

	def disp(oIO=STDOUT)
		oIO.puts "Keyword: #{@keyword}"
		oIO.puts "Fr: #{@fr}"
		oIO.puts "En: #{@en}"
		oIO.puts "Ja: #{@ja}"
		oIO.puts "Fr_raw: #{@fr_raw}"
		oIO.puts "En_raw: #{@en_raw}"
		oIO.puts "Ja_raw: #{@ja_raw}"
		oIO.puts "Fr_Option_Text: #{@fr_option_text}" unless @fr_option_text.size == 0
		oIO.puts "En_Option_Text: #{@en_option_text}" unless @en_option_text.size == 0
		oIO.puts "Ja_Option_Text: #{@ja_option_text}" unless @ja_option_text.size == 0
		oIO.puts
	end
end

if $0 == __FILE__ then
	coParentDicListsByFr = TranslateDicListsByFr.new()
	coParentDicListsByEn = TranslateDicListsByEn.new()
	IO.foreach(TranslateSMsbinLIB::DIC_FILE_PATH) do |sLine|
		sLine.chomp!
		aFactor = sLine.split(/\t/)
		TranslateKeywordFr.new(aFactor, aFactor[2], coParentDicListsByFr, coParentDicListsByEn)
	end


	sTestLogFilePath = "./test.log"
	fTestOutput = File.new(sTestLogFilePath, "w")
		coParentDicListsByFr.disp(fTestOutput)
		coParentDicListsByEn.disp(fTestOutput)
	fTestOutput.close

end
