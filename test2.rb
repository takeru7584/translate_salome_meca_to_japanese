#!/usr/bin/ruby1.9.1
require "./translate_sm_lib.rb"
require "./translate_ts.rb"
require "pp"

FR_TS_FILE_PATH = "../salome/SALOME-MECA-2013.1-LGPL/modules/GUI_V6_6_0/share/salome/resources/gui/LightApp_msg_fr.ts"
EN_TS_FILE_PATH = "../salome/SALOME-MECA-2013.1-LGPL/modules/GUI_V6_6_0/share/salome/resources/gui/LightApp_msg_en.ts"
JA_TS_FILE_PATH = "../salome/SALOME-MECA-2013.1-LGPL/modules/GUI_V6_6_0/share/salome/resources/gui/LightApp_msg_ja.ts"


if $0 == __FILE__ then
	TranslateSMLIB.init()
	rexmlDocFr = nil
	rexmlDocEn = nil
	rexmlDocJa = nil
	sFileBaseNameWithLang = File.basename(FR_TS_FILE_PATH)
	sFileBaseNameWithLang =~ /_(\w\w\.ts)$/
	sFileBaseName = $`
	coDicLists = TranslateDicLists.new()
	coDicLists.create_dic_lists(sFileBaseName)
	File.open(FR_TS_FILE_PATH) do |sXmlFile|
		#STDERR.puts sXmlFile
		rexmlDocFr = REXML::Document.new(sXmlFile)
	end
	File.open(EN_TS_FILE_PATH) do |sXmlFile|
		#STDERR.puts sXmlFile
		rexmlDocEn = REXML::Document.new(sXmlFile)
	end
	File.open(JA_TS_FILE_PATH) do |sXmlFile|
		#STDERR.puts sXmlFile
		rexmlDocJa = REXML::Document.new(sXmlFile)
	end

	#STDERR.print rexmlDocFr
	#STDERR.print rexmlDocEn
	#STDERR.print rexmlDocJa
	#PP.pp(rexmlDocFr, STDERR)
	#PP.pp(rexmlDocEn, STDERR)
	#PP.pp(rexmlDocJa, STDERR)
	TranslateTsLIB.make_dic_files_from_current_version(coDicLists, rexmlDocFr, rexmlDocEn, rexmlDocJa)

#	PP.pp(coDicLists, STDERR)
	coDicLists.print()

end
