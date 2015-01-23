#!/usr/bin/ruby1.9.1
#aFiles = Dir.entries("./")
exit unless ARGV.size > 0
for aa in ARGV
  next unless aa =~ /\.qm$/
  sOutputFilePath = "#{$`}.ts"
#  cmd = "qm2ts -verbose #{aa}"
  cmd = "lconvert -if qm -of ts -o #{sOutputFilePath} -verbose #{aa}"
  system(cmd)
end
