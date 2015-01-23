#!/usr/bin/ruby1.9.1
#aFiles = Dir.entries("./")
exit unless ARGV.size > 0
for aa in ARGV
  next unless aa =~ /\.py$/
  sOutputFilePath = "#{$`}_msg_fr.ts"
  cmd = "lupdate -noobsolete -verbose #{aa} -ts #{sOutputFilePath}"
  system(cmd)
end
