#!/usr/bin/ruby1.9.1

for aa in ARGV
  sToFile = aa.gsub(/\.org$/, "")
  cmd = "mv #{aa} #{sToFile}"
  system(cmd)
end
