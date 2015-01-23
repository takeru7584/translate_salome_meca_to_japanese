#!/usr/bin/ruby1.9.1
#aFiles = Dir.entries("./")
exit unless ARGV.size > 0
for aa in ARGV
  next unless aa =~ /\.ts$/
  sOutputFilePath = "#{$`}.qm"
  cmd = "lconvert -if ts -of qm -o #{sOutputFilePath} -verbose #{aa} "
  system(cmd)
end
