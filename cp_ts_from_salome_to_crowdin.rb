#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
# Salome-Meca Ver 2013.1
require "pp"
require "fileutils"
SALOME_MODULE_BASE_PATH = "/home/takeru/salome/SALOME-MECA-2013.1-LGPL/modules"
SALOME_VERSION = "V6_6_0"
SALOME_CROWDIN = "SRC"

if $0 == __FILE__ then
	Dir.chdir(SALOME_MODULE_BASE_PATH)
	sJaTSFileList = `find ./ -name \"*_msg_ja.ts\"`
	aJaTSFileList = sJaTSFileList.split("\n")
	#STDERR.puts aJaTSFileList
	for sJaTSFilePath in aJaTSFileList.sort
		sFactorLine = sJaTSFilePath.gsub(/^\.\//,"")
		aFactors = sFactorLine.split("/")
		sTitle = aFactors.first
		sTitle.gsub!(SALOME_VERSION, SALOME_CROWDIN)
		sTsFileName = aFactors.last
		case sTsFileName
		when /^OB_/
			#sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "")
			sTsFileTitle = "ObjBrowser"
			sCopyToFilePath = "#{sTitle}/src/#{sTsFileTitle}/resources/#{sTsFileName}"
		when /^QxSceneViewer/
			sTsFileTitle = sTsFileName.gsub("Viewer_msg_ja.ts", "")
			sCopyToFilePath = "#{sTitle}/src/#{sTsFileTitle}/resources/#{sTsFileName}"
		when /^ToolsGUI_/
			sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "")
			sTsFileTitle.upcase!
			sCopyToFilePath = "#{sTitle}/src/#{sTsFileTitle}/resources/#{sTsFileName}"
		when /^BLSURFPlugin_/
			sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "")
			sCopyToFilePath = "#{sTitle}/src/GUI/#{sTsFileName}"
		when /^GEOM_/
			sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "GUI")
			sCopyToFilePath = "#{sTitle}/src/#{sTsFileTitle}/#{sTsFileName}"
		when /^GH3DPlugin_/
			sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "")
			sCopyToFilePath = "#{sTitle}/src/GUI/#{sTsFileName}"
		when /^GH3DPRLPlugin_/
			sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "")
			sCopyToFilePath = "#{sTitle}/src/gui/#{sTsFileName}"
		when /^HELLO_/
			sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "GUI")
			sCopyToFilePath = "#{sTitle}/src/#{sTsFileTitle}/#{sTsFileName}"
		when /^HEXABLOCKPLUGIN_/
			sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "")
			sTsFileTitle.upcase!
			sCopyToFilePath = "#{sTitle}/src/#{sTsFileTitle}/#{sTsFileName}"
		else
			sTsFileTitle = sTsFileName.gsub("_msg_ja.ts", "")
			sCopyToFilePath = "#{sTitle}/src/#{sTsFileTitle}/resources/#{sTsFileName}"
		end
		#STDERR.puts("#{sTitle}:#{sTsFileTitle}:#{sTsFileName}")
		STDERR.puts(sCopyToFilePath)
	end
end

