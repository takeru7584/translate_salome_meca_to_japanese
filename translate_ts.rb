#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
require "#{File.dirname(File.expand_path(__FILE__))}/translate_lib.rb"
require "rexml/document"

module TranslateTsLIB
	module_function
	def translate(sFilePath, sFromLang="fr", sToLang="ja")
		STDERR.puts "#{sFilePath}:"
		sDatabaseFilePath = sFilePath.gsub(/_\w\w\.ts$/, "_fr.dat")
		sOutputFilePath = sFilePath.gsub("_#{sFromLang}.ts", "_#{sToLang}.ts")
		unless File.exist?(sDatabaseFilePath) then
			cmd = "touch #{sDatabaseFilePath}"
			system(cmd)
		end
		fDatabase = File.open(sDatabaseFilePath)
		hDatabase = input_database(fDatabase)
		fDatabase.close
		# 入力XMLファイルを読み込んでREXML::Documentを生成
		doc = nil
		File.open(sFilePath) {|xmlfile|
		doc = REXML::Document.new(xmlfile)
		}
		nTotalCount = traverse_count_translate_tag(doc.root)
		hDatabase, nCount = traverse_translation(doc.root, nTotalCount, 0, sFromLang, sToLang, hDatabase)
#		STDERR.puts doc
		STDERR.puts
		fOutputDatabase = File.new(sDatabaseFilePath, "w")
#		output_database(STDERR, hDatabase)
		output_database(fOutputDatabase, hDatabase)
		fOutputXmlFile = File.new(sOutputFilePath, "w")
#			doc.write(fOutputXmlFile, -1, true)
			doc.write(fOutputXmlFile)
		fOutputXmlFile.close
	end
	
	def merge_from_en_to_database(sFilePath)
		STDERR.puts "#{sFilePath}:"
		sDatabaseFilePath = sFilePath.gsub(/\_en.ts$/, "_fr.dat")
		unless File.exist?(sDatabaseFilePath) then
			cmd = "touch #{sDatabaseFilePath}"
			system(cmd)
		end
		fDatabase = File.open(sDatabaseFilePath)
		hDatabase = input_database(fDatabase)
		fDatabase.close
		# 入力XMLファイルを読み込んでREXML::Documentを生成
		doc = nil
		File.open(sFilePath) {|xmlfile|
		doc = REXML::Document.new(xmlfile)
		}
		hDatabase = traverse_merge_from_en(doc.root, hDatabase)
#		STDERR.puts doc
		STDERR.puts
		fOutputDatabase = File.new(sDatabaseFilePath, "w")
#			output_database(STDERR, hDatabase)
			output_database(fOutputDatabase, hDatabase)
		fOutputDatabase.close
	end

	def traverse_translation(parent, nTotalCount, nCount=0, sFromLang="fr", sToLang="ja", hDatabase=Hash.new())
		for child in parent.elements
			hDatabase, nCount = traverse_translation(child, nTotalCount, nCount, sFromLang, sToLang, hDatabase)
			next unless child.name.to_s =~ /^translation$/
			sKeyword = parent.elements["source"].text.to_s
			nCount += 1
			STDERR.puts "#{sKeyword}(#{nCount}/#{nTotalCount}):"
			if hDatabase[sKeyword] != nil then
				sFromText = hDatabase[sKeyword][sFromLang]
				sFromText.strip!
				sToTextfr = hDatabase[sKeyword]["fr"]
				sToTextfr.strip!
				sToTexten = hDatabase[sKeyword]["en"]
				sToTexten.strip!
				sToTextja = hDatabase[sKeyword]["ja"]
#				sToTextja.gsub!(/\d\%/, '')
				sToTextja.strip!
			else
				sFromOriginalText = child.text.to_s
				sFromText, sOptionText = change_escape_text(sFromOriginalText)
#				sFromLang = TranslateLIB.detect(sFromText)
				sToTextfr = TranslateLIB.translate(sFromText, sFromLang, "fr")
				sToTextfr << sOptionText
				sToTextfr.strip!
				sToTexten = TranslateLIB.translate(sFromText, sFromLang, "en")
				sToTexten << sOptionText
				sToTexten.strip!
				sToTextja = TranslateLIB.translate(sFromText, sFromLang, "ja")
				sToTextja << sOptionText
				sToTextja.strip!
				STDERR.puts "#{sFromLang}(org): #{sFromOriginalText}"
				hWord = Hash.new()
				hWord["fr"] = sToTextfr
				hWord["en"] = sToTexten
				hWord["ja"] = sToTextja
				hDatabase[sKeyword] = hWord
			end
			STDERR.puts "#{sFromLang}(escape): #{sFromText}"
			STDERR.puts "fr: #{sToTextfr}"
			STDERR.puts "en: #{sToTexten}"
			STDERR.puts "ja: #{sToTextja}"
			STDERR.puts
			case sToLang
				when "fr"
					child.text = sToTextfr

				when "en"
					child.text = sToTexten

				when "ja"
					child.text = sToTextja
			end
		end
#STDERR.puts hDatabase
		return hDatabase, nCount
	end

	def traverse_merge_from_en(parent, hDatabase=Hash.new())
		for child in parent.elements
			hDatabase = traverse_merge_from_en(child, hDatabase)
			next unless child.name.to_s =~ /^translation$/
			sKeyword = parent.elements["source"].text.to_s
			STDERR.puts "#{sKeyword}:"
			if hDatabase[sKeyword] != nil then
				hDatabase[sKeyword]["en"]=child.text.to_s
			else
				sFromOriginalText = child.text.to_s
				sFromText, sOptionText = change_escape_text(sFromOriginalText)
				sToTextja = TranslateLIB.translate(sFromText, "en", "ja")
				sToTextja << sOptionText
				hWord = Hash.new()
				hWord["fr"] = ""
				hWord["en"] = sFromOriginalText
				hWord["ja"] = sToTextja
				hDatabase[sKeyword]=hWord
			end
		end
#STDERR.puts hDatabase
		return hDatabase
	end

	def change_escape_text(sFromText)
#		if sFromText =~ /\&amp\;(\w)/ then
#		if sFromText =~ /\&(\w)/ then
		if sFromText =~ /&(\w)/ then
#			sToText = "#{$`}#{$1}#{$'} (#{$&})"
			sToText = "#{$`}#{$1}#{$'}"
			sOptionText = "(#{$&})"
		else
			sToText = sFromText.to_s
			sOptionText = ""
		end
		return sToText,sOptionText
	end

	def change_escape_text_for_ja(sFromText)
#		if sFromText =~ /\(\&amp\;(\w)\)$/ then
#		if sFromText =~ /\(\&(\w)\)$/ then
		if sFromText =~ /\(&(\w)\)$/ then
#			sToText = "#{$`}#{$1}#{$'} (#{$&})"
#			sToText = "#{$`}#{$1}#{$'}"
			sToText = "#{$`}"
			sOptionText = "#{$&}"
		else
			sToText = sFromText.to_s
			sOptionText = ""
		end
		return sToText,sOptionText
	end

	def input_database(f, hDatabase=Hash.new())
		return hDatabase if f == nil
		f.each do |line|
			aWords = line.split(/\t/)
			hWord = Hash.new()
			hWord["fr"] = aWords[1].gsub("\\n", "\n")
			hWord["en"] = aWords[2].gsub("\\n", "\n")
			hWord["ja"] = aWords[3].gsub("\\n", "\n")
			hDatabase[aWords[0].gsub("\\n", "\n")] = hWord
		end
		return hDatabase
	end

	def output_database(f, hDatabase)
		for sKeyword in hDatabase.keys.sort
			f.puts "#{sKeyword.gsub("\n", "\\n")}	#{hDatabase[sKeyword]["fr"].gsub("\n", "\\n")}	#{hDatabase[sKeyword]["en"].gsub("\n", "\\n")}	#{hDatabase[sKeyword]["ja"].gsub("\n", "\\n")}"
		end
	end

	def traverse_count_translate_tag(parent, count=0)
		for child in parent.elements
			count = traverse_count_translate_tag(child, count)
			next unless child.name.to_s =~ /^translation$/
			count += 1
		end
		return count
	end

	def make_dic_files_from_current_version(coDicLists, rexmlDocFr, rexmlDocEn, rexmlDocJa, bForceFlag=false)

		rexmlGroupNamesFr = rexmlDocFr.get_elements("/TS/context")
		rexmlGroupNamesEn = rexmlDocEn.get_elements("/TS/context")
		rexmlGroupNamesJa = rexmlDocJa.get_elements("/TS/context")
		
		#STDERR.puts rexmlGroupNamesFr
		#STDERR.puts rexmlGroupNamesEn
		#STDERR.puts rexmlGroupNamesJa

		hGroupFr = Hash.new()
		hGroupEn = Hash.new()
		hGroupJa = Hash.new()

		for rexmlGroupNameFr in rexmlGroupNamesFr
			sGroupName = rexmlGroupNameFr.get_elements("name").first.text.to_s
			hGroupFr[sGroupName] = rexmlGroupNameFr
		end

		for rexmlGroupNameEn in rexmlGroupNamesEn
			sGroupName = rexmlGroupNameEn.get_elements("name").first.text.to_s
			hGroupEn[sGroupName] = rexmlGroupNameEn
		end

		for rexmlGroupNameJa in rexmlGroupNamesJa
			sGroupName = rexmlGroupNameJa.get_elements("name").first.text.to_s
			hGroupJa[sGroupName] = rexmlGroupNameJa
		end

		#PP.pp(hGroupFr, STDERR)
		#PP.pp(hGroupEn, STDERR)
		#PP.pp(hGroupJa, STDERR)

		if rexmlGroupNamesFr.size != 0 then
			for rexmlGroupNameFr in rexmlGroupNamesFr
				sGroupName = rexmlGroupNameFr.get_elements("name").first.text.to_s
				rexmlGroupNameEn = hGroupEn[sGroupName]
				rexmlGroupNameJa = hGroupJa[sGroupName]
				coKeywordGroup = coDicLists[sGroupName]
				coKeywordGroup = TranslateKeywordGroup.new(sGroupName, coDicLists) unless coKeywordGroup
				make_dic_files_from_current_version_core_keywords(coKeywordGroup, rexmlGroupNameFr, rexmlGroupNameEn, rexmlGroupNameJa, bForceFlag)
			end
		elsif rexmlGroupNamesEn.size != 0 then
			for rexmlGroupNameEn in rexmlGroupNamesEn
				sGroupName = rexmlGroupNameEn.get_elements("name").first.text.to_s
				rexmlGroupNameFr = nil
				rexmlGroupNameJa = hGroupJa[sGroupName]
				coKeywordGroup = coDicLists[sGroupName]
				coKeywordGroup = TranslateKeywordGroup.new(sGroupName, coDicLists) unless coKeywordGroup
				make_dic_files_from_current_version_core_keywords(coKeywordGroup, rexmlGroupNameFr, rexmlGroupNameEn, rexmlGroupNameJa, bForceFlag)
			end
		else
			for rexmlGroupNameJa in rexmlGroupNamesJa
				sGroupName = rexmlGroupNameJa.get_elements("name").first.text.to_s
				rexmlGroupNameFr = nil
				rexmlGroupNameEn = nil
				coKeywordGroup = coDicLists[sGroupName]
				coKeywordGroup = TranslateKeywordGroup.new(sGroupName, coDicLists) unless coKeywordGroup
				make_dic_files_from_current_version_core_keywords(coKeywordGroup, rexmlGroupNameFr, rexmlGroupNameEn, rexmlGroupNameJa, bForceFlag)
			end
		end

		#PP.pp(coDicLists,STDERR)
	end

	def make_dic_files_from_current_version_core_keywords(coKeywordGroup, rexmlGroupNameFr, rexmlGroupNameEn, rexmlGroupNameJa, bForceFlag=false)

		#STDERR.puts "Check Takeru keywords <#{rexmlGroupNameFr.xpath()}>"

		rexmlKeywordsFr = []
		rexmlKeywordsEn = []
		rexmlKeywordsJa = []
		rexmlKeywordsFr = rexmlGroupNameFr.get_elements("message") unless rexmlGroupNameFr == nil
		rexmlKeywordsEn = rexmlGroupNameEn.get_elements("message") unless rexmlGroupNameEn == nil
		rexmlKeywordsJa = rexmlGroupNameJa.get_elements("message") unless rexmlGroupNameJa == nil
		hKeywordFr = Hash.new()
		hKeywordEn = Hash.new()
		hKeywordJa = Hash.new()

		for rexmlKeywordFr in rexmlKeywordsFr
			next if rexmlKeywordFr.get_elements("source").size == 0
			sSourceName = rexmlKeywordFr.get_elements("source").first.text.to_s
			hKeywordFr[sSourceName] = rexmlKeywordFr
		end
		for rexmlKeywordEn in rexmlKeywordsEn
			next if rexmlKeywordEn.get_elements("source").size == 0
			sSourceName = rexmlKeywordEn.get_elements("source").first.text.to_s
			hKeywordEn[sSourceName] = rexmlKeywordEn
		end
		for rexmlKeywordJa in rexmlKeywordsJa
			next if rexmlKeywordJa.get_elements("source").size == 0
			sSourceName = rexmlKeywordJa.get_elements("source").first.text.to_s
			hKeywordJa[sSourceName] = rexmlKeywordJa
		end

		if rexmlKeywordsFr.size != 0 then
			for rexmlKeywordFr in rexmlKeywordsFr
				next if rexmlKeywordFr.get_elements("source").size == 0
				sSourceName = rexmlKeywordFr.get_elements("source").first.text.to_s
				STDERR.puts "Check Takeru keyword <#{sSourceName}>"
				rexmlKeywordEn = hKeywordEn[sSourceName]
				rexmlKeywordJa = hKeywordJa[sSourceName]
				sFrRaw = ""
				sEnRaw = ""
				sJaRaw = ""
				sFrRaw = rexmlKeywordFr.get_elements("translation").first.text.to_s
				sEnRaw = rexmlKeywordEn.get_elements("translation").first.text.to_s unless rexmlKeywordEn.to_a.size == 0
				sJaRaw = rexmlKeywordJa.get_elements("translation").first.text.to_s unless rexmlKeywordJa.to_a.size == 0
				STDERR.puts "Check Takeru sFrRaw:#{sFrRaw}"
				sFr, sOptionTextTemp = change_escape_text(sFrRaw)
				sEn, sOptionTextTemp = change_escape_text(sEnRaw)
				sJa, sOptionText = change_escape_text_for_ja(sJaRaw)
				STDERR.puts "Check Takeru sFr:#{sFr}"
				aFactor = []
				aFactor << sSourceName
				aFactor << sFrRaw
				aFactor << sEnRaw
				aFactor << sJaRaw
				#aFactor << sFr
				#aFactor << sEn
				#aFactor << sJa
				PP.pp(aFactor, STDERR)
				coTranslateKeyword = TranslateKeyword.new(aFactor, coKeywordGroup.parent(), bForceFlag, coKeywordGroup)
				coTranslateKeyword.fr_raw = sFrRaw
				coTranslateKeyword.en_raw = sEnRaw
				coTranslateKeyword.ja_raw = sJaRaw
				coTranslateKeyword.option_text = sOptionText
			end
		elsif rexmlKeywordsEn.size != 0 then
			for rexmlKeywordEn in rexmlKeywordsEn
				next if rexmlKeywordEn.get_elements("source").size == 0
				sSourceName = rexmlKeywordEn.get_elements("source").first.text.to_s
				#STDERR.puts "Check Takeru keyword <#{sSourceName}>"
				rexmlKeywordJa = hKeywordJa[sSourceName]
				sFrRaw = ""
				sEnRaw = ""
				sJaRaw = ""
				sEnRaw = rexmlKeywordEn.get_elements("translation").first.text.to_s
				sJaRaw = rexmlKeywordJa.get_elements("translation").first.text.to_s unless rexmlKeywordJa == nil
				sFr, sOptionTextTemp = change_escape_text(sFrRaw)
				sEn, sOptionTextTemp = change_escape_text(sEnRaw)
				sJa, sOptionText = change_escape_text_for_ja(sJaRaw)
				aFactor = []
				aFactor << sSourceName
				aFactor << sFrRaw
				aFactor << sEnRaw
				aFactor << sJaRaw
				#aFactor << sFr
				#aFactor << sEn
				#aFactor << sJa
				coTranslateKeyword = TranslateKeyword.new(aFactor, coKeywordGroup.parent(), bForceFlag, coKeywordGroup)
				coTranslateKeyword.fr_raw = sFrRaw
				coTranslateKeyword.en_raw = sEnRaw
				coTranslateKeyword.ja_raw = sJaRaw
				coTranslateKeyword.option_text = sOptionText
			end
		else
			for rexmlKeywordJa in rexmlKeywordsJa
				next if rexmlKeywordJa.get_elements("source").size == 0
				sSourceName = rexmlKeywordJa.get_elements("source").first.text.to_s
				#STDERR.puts "Check Takeru keyword <#{sSourceName}>"
				rexmlKeywordJa = hKeywordJa[sSourceName]
				sFrRaw = ""
				sEnRaw = ""
				sJaRaw = ""
				sJaRaw = rexmlKeywordJa.get_elements("translation").first.text.to_s
				sFr, sOptionTextTemp = change_escape_text(sFrRaw)
				sEn, sOptionTextTemp = change_escape_text(sEnRaw)
				sJa, sOptionText = change_escape_text_for_ja(sJaRaw)
				aFactor = []
				aFactor << sSourceName
				aFactor << sFr
				aFactor << sEn
				aFactor << sJa
				coTranslateKeyword = TranslateKeyword.new(aFactor, coKeywordGroup.parent(), bForceFlag, coKeywordGroup)
				coTranslateKeyword.fr_raw = sFrRaw
				coTranslateKeyword.en_raw = sEnRaw
				coTranslateKeyword.ja_raw = sJaRaw
				coTranslateKeyword.option_text = sOptionText
			end
		end
	end
end

if $0==__FILE__ then
	exit if ARGV.size == 0
	for aa in ARGV
		next unless aa =~ /_(\w\w)\.ts$/
		sFromLang = "#{$1}"
		sPrefix = "#{$`}"
		case sFromLang
			when "fr"
				TranslateTsLIB.translate(aa, "fr")
				next

			when "en"
				next if File.exist?("#{sPrefix}_fr.ts")
				TranslateTsLIB.translate(aa, "en")
				next
		end
	end
end

