#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
require "~tempuser/bin/translate_ts.rb"

exit if ARGV.size == 0
for aa in ARGV
  TranslateTsLIB.merge_from_en_to_database(aa)
end

