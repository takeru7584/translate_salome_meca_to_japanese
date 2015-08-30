#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
require "pp"
require "fileutils"

module ExtractJapaneseUntranslationQmFile
	LANGUAGE_FR="fr"
	LANGUAGE_EN="en"
	LANGUAGE_JA="ja"

	DEFAULT_COPY_TO_PATH = "/home/takeru/salome_work/translate_to_japanese_2015.1/"

	module_function
	def usage()
	end

	def get_qm_file_list(sLanguage=LANGUAGE_FR)
		sLists = `find ./ -name \"*_#{sLanguage}.qm\"`
		aLists = sLists.split("\n")
		hLists = Hash.new()
		for sQMFilePath in aLists
			hLists[sQMFilePath] = 1
		end
		return hLists
	end

	def get_fr_qm_file_list()
		return get_qm_file_list(LANGUAGE_FR)
	end

	def get_en_qm_file_list()
		return get_qm_file_list(LANGUAGE_EN)
	end

	def get_ja_qm_file_list()
		return get_qm_file_list(LANGUAGE_JA)
	end

	def extract_qm_file_list_without_ja(hLists=get_fr_qm_file_list())
		hJaLists = get_ja_qm_file_list()
		hExtractLists = Hash.new()
		for sQMFile in hLists.keys
			sTempQMFile = sQMFile.gsub(/_\w{2}\.qm/, "_ja.qm")
			hExtractLists[sQMFile] = 1 unless hJaLists[sTempQMFile]
		end
		return hExtractLists
	end

	def extract_fr_qm_file_list_without_ja()
		return extract_qm_file_list_without_ja(get_fr_qm_file_list())
	end

	def extract_en_qm_file_list_without_ja()
		return extract_qm_file_list_without_ja(get_en_qm_file_list())
	end

	def exec_extract_qm_file_list()
		hExtractFrLists = extract_fr_qm_file_list_without_ja()
		hExtractEnLists = extract_en_qm_file_list_without_ja()

		aExtractLists = hExtractFrLists.keys + hExtractEnLists.keys
		return aExtractLists.sort
	end

	def exec_extract_and_copy_qm_file(sCopyToDir=DEFAULT_COPY_TO_PATH)
		aExtractLists = exec_extract_qm_file_list()

		FileUtils.mkdir_p(sCopyToDir) unless File.exist?(sCopyToDir)
		for sTargetFile in aExtractLists
			sDestinationFilePath = File.expand_path("#{sCopyToDir}/#{sTargetFile}")
			STDERR.puts "#{sTargetFile} => #{sDestinationFilePath}"
			sDestinationFileDir = File.dirname(sDestinationFilePath)
			FileUtils.mkdir_p(sDestinationFileDir) unless File.exist?(sDestinationFileDir)
			FileUtils.copy_file(sTargetFile, sDestinationFilePath)
		end
	end

	def exec_test()

		exec_extract_and_copy_qm_file(DEFAULT_COPY_TO_PATH)

	end
end

if $0==__FILE__ then
	ExtractJapaneseUntranslationQmFile.exec_test()
end

