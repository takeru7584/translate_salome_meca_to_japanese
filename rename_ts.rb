#!/usr/bin/ruby1.9.1

aFiles = Dir.entries("./")
for aa in aFiles
  next if aa !~ /^(.*?)_ja\.ts$/
  sToName = "#{$1}_en.ts"
  puts "#{aa} >> #{sToName}"
end
