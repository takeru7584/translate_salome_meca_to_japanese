#!/usr/bin/ruby1.9.1
#aFiles = Dir.entries("./")
require "optparse"
opt = OptionParser.new

opt.on('-r') {|v| OPTS[:r] = v}
opt.parse!(ARGV)

exit unless ARGV.size > 0

def reflexive_exec(sTargetPath)
  aFactors = Dir.entries(sTargetPath)
  for aa in aFactors
    if File.stat(aa).directory? == true then
      if OPTS[:r] == true then
        reflexive_exec("#{sTargetPath}/#{aa}")
      end
    end
    STDERR.puts "#{File.basename(aa)}(#{exec_core(aa)})"
  end
end

def exec_core(sTargetPath, sFromLang="fr")
  return false unless sTargetPath =~ /\.qm$/
  sOutputFilePath = "#{$`}.ts"
#  cmd = "qm2ts -verbose #{sTargetPath}"
  case sFromLang
    when "fr"
      sFromLangLong = "fr_FR"
    when "en"
      sFromLangLong = "en_US"
    when "ja"
      sFromLangLong = "ja_JP"

  end

  cmd = "lconvert -if qm -of ts --source-language #{sFromLangLong} --target-language ja_JP -o #{sOutputFilePath} -verbose #{sTargetPath}"
  system(cmd)
  return true
end

#sPwd = Dir.pwd()

for aa in ARGV
  next unless File.exist?(aa)
#STDERR.puts aa
  if File.stat(aa).directory? == true then
    reflexive_exec(aa) if OPTS[:r] == true
    next
  end
    next unless aa =~ /_(\w\w)\.qm$/
    sFromLang = "#{$1}"
    sPrefix = "#{$`}"
    case sFromLang
      when "fr"
        STDERR.puts "#{File.basename(aa)}(#{exec_core(aa, "fr")})"
        next

      when "en"
#STDERR.puts aa
        next if File.exist?("#{sPrefix}_fr.ts")
        STDERR.puts "#{File.basename(aa)}(#{exec_core(aa, "en")})"
        next

    end
end
