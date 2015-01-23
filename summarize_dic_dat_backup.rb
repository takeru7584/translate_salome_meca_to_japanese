#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
#module TranslateLIB
module TranslateLIB
	module_function

	def summarize_recursively(coDicSummaries=TranslateSummaries.new(), sFilePath=nil)
		sFilePath = Dir.getwd() if sFilePath == nil
		return coDicSummaries unless File.exist?(sFilePath)
		if FileTest.directory?(sFilePath) == false then
			return register_dic_from_dat(coDicSummaries, sFilePath)
		end
STDERR.puts sFilePath
		aFileChildren = Dir.entries(sFilePath)
		for sFileChild in aFileChildren
			next if sFileChild =~ /^\./
			sChildFilePath = File.expand_path("#{sFilePath}/#{sFileChild}")
			coDicSummaries = summarize_recursively(coDicSummaries, sChildFilePath)	
		end
		return coDicSummaries
	end

	def register_dic_from_dat(coDicSummaries=TranslateSummaries.new(), sCheckFilePath)
		return coDicSummaries unless File.exist?(sCheckFilePath)
		return coDicSummaries unless FileTest.file?(sCheckFilePath)
		sFileDir, sTSFileName = File.split(sCheckFilePath)
		return coDicSummaries unless sTSFileName =~ /(.+?_msg_fr).ts$/
		sTargetBaseName=$1.to_s
		sFilePath = sCheckFilePath.gsub(/\.ts$/,".dat")
		return coDicSummaries unless File.exist?(sFilePath)
		return coDicSummaries unless FileTest.file?(sFilePath)
STDERR.puts sFilePath
		coDicLists = TranslateDicLists.new()
		coDicLists.create_dic_lists(sTargetBaseName, coDicSummaries)
#puts coDicLists.type
		IO.foreach(sFilePath) do |sLine|
			sLine.chomp!
#puts sLine
			aFactor = sLine.split(/\t/)
			coKeywordItem = TranslateKeyword.new(aFactor)
			coDicLists.install(coKeywordItem)
		end
		coDicSummaries.install(coDicLists)
		return coDicSummaries
	end

	def output_dic_summary(coDicSummaries=TranslateSummaries.new(), oIO=STDOUT)
		for sFileBaseName in coDicSummaries.keys.sort
			coDicLists = coDicSummaries[sFileBaseName]
			for sKeyword in coDicLists.keys.sort
				coKeywordItem = coDicLists[sKeyword]
				aLine = []
				aLine << sFileBaseName
				aLine << sKeyword
				aLine << coKeywordItem.fr
				aLine << coKeywordItem.en
				aLine << coKeywordItem.ja
				sLine = aLine.join("\t")
				oIO.puts sLine
			end
		end
	end
end

class TranslateKeyword
	attr_accessor :keyword
	attr_accessor :fr
	attr_accessor :en
	attr_accessor :ja
	attr_accessor :raw
	def initialize(aFactor=["","",""],coParentDicLists=TranslateDicLists.new())
		@keyword = aFactor[0]
		@fr = aFactor[1]
		@en = aFactor[2]
		@ja = aFactor[3]
		@raw = Array.new(aFactor)
		@parent_dic_lists = coParentDicLists
	end
	
	def parent()
		return coParentDicLists
	end
end

class TranslateDicLists < Hash
	def create_dic_lists(sListsFileBaseName="", coParentSummaries=TranslateSummaries.new())
		@file_basename = sListsFileBaseName
		@parent_summaries = coParentSummaries
	end

	def file_basename()
		return @file_basename
	end

	def parent()
		return @parent_summaries
	end

	def install(coKeywordItem)
		self[coKeywordItem.keyword]=coKeywordItem
	end
end

class TranslateSummaries < Hash
	def install(coDicLists)
		self[coDicLists.file_basename]=coDicLists
	end
end

if $0 == __FILE__ then
	aStartFilePathes = [Dir.getwd()]
	aStartFilePathes = Array.new(ARGV) if ARGV.size != 0
	coDicSummaries = TranslateSummaries.new()
	for sStartFilePath in aStartFilePathes
		coDicSummaries = TranslateLIB.summarize_recursively(coDicSummaries, sStartFilePath)
	end
	sOutputFilePath = "summary_translate_word.dic"
	fOutputFile = File.new(sOutputFilePath,"w")
#		TranslateLIB.output_dic_summary(coDicSummaries, STDOUT)
		TranslateLIB.output_dic_summary(coDicSummaries, fOutputFile)
	fOutputFile.close
end

