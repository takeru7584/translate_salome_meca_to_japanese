#!/usr/bin/ruby
# -*- coding:utf-8 -*-
    require 'net/http'
    require 'rexml/document'
    require 'json'
     
    # 引数が無い場合はエラー
    if !ARGV.length
      raise "1 argument is needed"
    end
     
    # 翻訳対象の文
    text = URI.escape(ARGV[0])
     
    h = Net::HTTP.new("api.microsofttranslator.com")
    response = h.get("/V2/Http.svc/Translate?appid=AD697D10EC7A3751BB125AB58715693EBCB224E2&from=en&to=ja&text=#{text}")
     
    if response.message == 'OK'
      doc = REXML::Document.new(response.body)
      puts sprintf("Microsoft API : %s", doc.root.text)
    end
     
    h2 = Net::HTTP.new("ajax.googleapis.com")
    response2 = h2.get("/ajax/services/language/translate?v=1.0&q=#{text}&langpair=en|ja")
     
    if response2.message == 'OK'
      j = JSON.parse(response2.body)
      puts sprintf("Google    API : %s", j["responseData"]["translatedText"])
    end
