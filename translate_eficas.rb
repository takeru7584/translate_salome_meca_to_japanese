#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
    require '~tempuser/bin/translate_ts'
    
    def exec_translate(sFile, sToLang="ja")
        return false unless File.exist?(sFile)
        sDatabaseFilePath = sFile.gsub(/\.py$/,"_translate.dat")
        sBackupFilePath = "#{sFile}"
        sBackupFilePath << ".org"
        
        unless File.exist?(sDatabaseFilePath) then
          cmd = "touch #{sDatabaseFilePath}"
          system(cmd)
        end
        unless File.exist?(sBackupFilePath) then
          cmd = "cp #{sFile} #{sBackupFilePath}"
          system(cmd)
        end

        fDatabase = File.open(sDatabaseFilePath)
          hDatabase = TranslateTsLIB.input_database(fDatabase)
        fDatabase.close
        #hDatabase=Hash.new()

        aLines = []
        IO.foreach(sFile) do |line|
          line.chomp!
          begin
            case line
              when /(set(Text|Title)\(QtGui\.QApplication\.translate\(\".+?[^\\]\"\, \")(.+?[^\\])(\")/m
                sPrefix="#{$`}#{$1}"
                sKeyword_fr="#{$3}"
                sSuffix="#{$4}#{$'}"

              when /(appliEficas.trUtf8\(\")(.+?[^\\])(\")/m
                sPrefix="#{$`}#{$1}"
                sKeyword_fr="#{$2}"
                sSuffix="#{$3}#{$'}"

              else
                aLines << line
#STDERR.puts line
STDERR.puts "Check1: #{line}"
                next
            end
            #unless line =~ /(set(Text|Title)\(QtGui\.QApplication\.translate\(\".+?\"\, \")(.+?)(\")/ then
            #  aLines << line
#STDERR.puts line
            #  next
            #end
          rescue
            aLines << line
#STDERR.puts line
STDERR.puts "Check2: #{line}"
            next
          end
#          if sKeyword_fr =~ /html/i then
#            aLines << line
##STDERR.puts line
#STDERR.puts "Check3: #{line}"
#            next
#          end
          sPrefixK = ""
          sSuffixK = ""
          sKeyword_core_fr = sKeyword_fr.to_s
#STDERR.puts sKeyword_fr
          if sKeyword_fr =~ />([^<]+)</m then
            sPrefixK = "#{$`}>"
            sSuffixK = "<#{$'}"
            sKeyword_core_fr = "#{$1}"
          elsif sKeyword_fr =~ /<.*?>/m then
            aLines << line
#STDERR.puts line
STDERR.puts "Check4: #{line}"
            next
          end
          unless hDatabase[sKeyword_fr] == nil then
            sToKeyword_fr = hDatabase[sKeyword_fr]["fr"].to_s.strip
            sToKeyword_en = hDatabase[sKeyword_fr]["en"].to_s.strip
            sToKeyword_ja = hDatabase[sKeyword_fr]["ja"].to_s.strip
          else
            hDatabaseOne=Hash.new()
            sKeywordEscape_fr, sOptionText=TranslateTsLIB.change_escape_text(sKeyword_core_fr)
            sToKeyword_fr = sKeyword_fr.to_s.strip
            sToKeyword_en = TranslateLIB.translate(sKeywordEscape_fr, "fr", "en").strip
            sToKeyword_en.gsub!(/(\\)\s*(.)/m,'\1\2')
            sToKeyword_en << sOptionText.strip
            sToKeyword_ja = TranslateLIB.translate(sKeywordEscape_fr, "fr", "ja").strip
            sToKeyword_ja.gsub!(/(\\)\s*(.)/m,'\1\2')
            sToKeyword_ja << sOptionText.strip
            sToKeywordAll_fr=sKeyword_fr.strip
            sToKeywordAll_en="#{sPrefixK}#{sToKeyword_en.strip}#{sSuffixK}".strip!
            sToKeywordAll_ja="#{sPrefixK}#{sToKeyword_ja.strip}#{sSuffixK}".strip!
            hDatabaseOne["fr"]=sToKeywordAll_fr
            hDatabaseOne["en"]=sToKeywordAll_fr
            hDatabaseOne["ja"]=sToKeywordAll_fr
            hDatabase[sKeyword_fr]=hDatabaseOne
          end
          sToLine = sPrefix.to_s
          case sToLang
            when "en"
              sToLine << sToKeyword_en

            when "ja"
              sToLine << sToKeyword_ja

            else
              sToLine << sToKeyword_ja
          end
          sToLine << sSuffix
          aLines << sToLine
STDERR.puts sToLine
#STDERR.puts "Check!"
        end
 
        fOutputFile = File.new(sFile, "w")
          for sLine in aLines
            fOutputFile.puts sLine
          end
        fOutputFile.close

        fDatabase = File.new(sDatabaseFilePath, "w")
          TranslateTsLIB.output_database(fDatabase, hDatabase)
        fDatabase.close
        return true
    end

exit 1 unless ARGV.size > 0

for sFile in ARGV
    STDERR.puts "#{sFile}:"
    STDERR.puts "#{sFile}(#{exec_translate(sFile)})"
end
