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

def exec_core(sTargetPath)
  return false unless sTargetPath =~ /\.qm$/
  sOutputFilePath = "#{$`}.ts"
#  cmd = "qm2ts -verbose #{sTargetPath}"
  cmd = "lconvert -if qm -of ts --source-language fr_FR --target-language ja_JP -o #{sOutputFilePath} -verbose #{sTargetPath}"
  system(cmd)
  return true
end

#sPwd = Dir.pwd()

for aa in ARGV
  next unless File.exist?(aa)
  if File.stat(aa).directory? == true then
    reflexive_exec(aa) if OPTS[:r] == true
    next
  end
  STDERR.puts "#{File.basename(aa)}(#{exec_core(aa)})"
end
