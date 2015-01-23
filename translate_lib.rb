#!/usr/bin/ruby1.9.1
# -*- coding:utf-8 -*-
require 'rubygems'
require 'net/http'
require 'rexml/document'
require 'json'
#		require 'httpclient'
require 'uri'
require "socket"
 
module TranslateLIB
	DEFAULT_DIC_FILE_PATH = "./summary_translate_word.dic"
	ENGINE_SITE_MICROSOFT="microsoft"
	ENGINE_SITE_GOOGLE="google"
	ENGINE_SITE_MICROSOFT_APPID="D3A72EA7A754EA799012A5A9DB02B020111E44A2"
	MS_TRANSLATOR_CLIENT_ID = "tobylabs_app_sn_20131019_001"
	MS_TRANSLATOR_CLIENT_SECRET = "NsZjuqT3W6FEixHyROfD5T69lZhi05Y+krSoSpHCZqo="
	MS_TRANSLATOR_ACCESS_URL = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
	MS_TRANSLATOR_SCOPE = "http://api.microsofttranslator.com"
	MS_TRANSLATOR_URL = "http://api.microsofttranslator.com/v2/Http.svc/Translate"
	MS_TRANSLATOR_DETECT_URL = "http://api.microsofttranslator.com/v2/Http.svc/Detect"
	MS_TRANSLATOR_GRANT_TYPE = "client_credentials"

	URL = "http://ajax.googleapis.com/ajax/services/language"
	LANGUAGES = [
		:ar,	#アラビア語
		:bg,	#ブルガリア語
		:zh,	#中国語
		:zh_CN,	#中国語簡体
		:zh_TW,	#中国語繁体
		:ca,	#カタロニア語
		:hr,	#クロアチア語
		:cs,	#チェコ語
		:da,	#デンマーク語
		:en,	#英語
		:tl,	#フィリピノ語
		:fi,	#フィンランド語
		:fr,	#フランス語
		:de,	#ドイツ語
		:el,	#ギリシャ語
		:iw,	#ヘブライ語
		:hi,	#ヒンディー語
		:id,	#インドネシア語
		:it,	#イタリア語
		:ja,	#日本語
		:ko,	#韓国語
		:lv,	#ラトビア語
		:lt,	#リトアニア語
		:no,	#ノルウェー語
		:pl,	#ポーランド語
		:pt_PT,	#ポルトガル語
		:ro,	#ルーマニア語
		:ru,	#ロシア語
		:es,	#スペイン語
		:sr,	#セルビア語
		:sk,	#スロバキア語
		:sl,	#スロベニア語
		:sv,	#スウェーデン語
		:uk,	#ウクライナ語
		:vi,	#ベトナム語
	]
	@@proxy = ENV["http_proxy"]

	module_function
	def init()
		@timeUpdateAccessToken = nil
		@jsonResult = nil
		@expiresIn = nil
		@cache = { "en to ja" => Hash.new(), \
			   "en to fr" => Hash.new(), \
			   "fr to en" => Hash.new(), \
			   "fr to ja" => Hash.new(), \
			   "ja to fr" => Hash.new(), \
			   "ja to en" => Hash.new()}
	end

		################################################################
# translate(sFromTextOriginal, sFromLang, sToLang, sEngineSite, fAutoFlag)
	def translate(sFromTextOriginal, sFromLang="en", sToLang="ja", sEngineSite=ENGINE_SITE_MICROSOFT, fAutoFlag=false)
		sFromText = URI.escape(sFromTextOriginal)
		return sFromTextOriginal if sFromText == nil
		sFromLang = detect_google(sFromText) if fAutoFlag == true
		sFromLang = sDefaultFromLang if sFromLang == false
		return sFromTextOriginal if sFromLang == sToLang
		case sEngineSite
			when ENGINE_SITE_MICROSOFT
				return translate_microsoft(sFromText, sFromLang, sToLang)

			when ENGINE_SITE_GOOGLE
				return translate_google(sFromText, sFromLang, sToLang)

			else
				return translate_microsoft(sFromText, sFromLang, sToLang)

		end
	end

	def detect(sFromTextOriginal)
			sFromText = URI.escape(sFromTextOriginal)
			sFromLang = detect_google(sFromText)
			return sFromLang
	end

	def detect_google(sFromText)
		# 翻訳対象の文
		sIPAddress = "#{IPSocket::getaddress(Socket::gethostname)}"
		h = Net::HTTP.new("ajax.googleapis.com")
		response = h.get("/ajax/services/language/detect?v=1.0&q=#{sFromText}&userip=#{sIPAddress}")
		j = JSON.parse(response.body)
		return false if j == nil
#STDERR.puts j
		sFromLang = "#{j["responseData"]["language"]}"
		return sFromLang
	end

	def get_json_of_access_token(sClientID=MS_TRANSLATOR_CLIENT_ID, sClientSecret=MS_TRANSLATOR_CLIENT_SECRET)
		#https = Net::HTTP.new('secure.nicovideo.jp', 443)
		#https.use_ssl = true
		#https.ca_file = 'GTE_CyberTrust_Global_Root.pem'
		#https.verify_mode = OpenSSL::SSL::VERIFY_PEER
		#https.verify_depth = 5
		#netHttpsAPIDatamarketAzureCom = Net::HTTP.new("api.datamarket.azure.com", 443)
		Net::HTTP.version_1_2
		
		uriHttpsAPIDatamarketAzureCom = URI.parse(MS_TRANSLATOR_ACCESS_URL)
		netHttpsAPIDatamarketAzureCom = Net::HTTP.new(uriHttpsAPIDatamarketAzureCom.host, uriHttpsAPIDatamarketAzureCom.port)
		netHttpsAPIDatamarketAzureCom.use_ssl = true
		netHttpsAPIDatamarketAzureCom.verify_mode = OpenSSL::SSL::VERIFY_NONE
		#sPostPath = "/Bing/MicrosoftTranslator/v1/Translate"
		#sPostPath = "Data.ashx/Bing/MicrosoftTranslator/v1/Translate"
		netHttpPostRequest = Net::HTTP::Post.new(uriHttpsAPIDatamarketAzureCom.path)
		netHttpPostRequest.set_content_type("application/x-www-form-urlencoded")
		netHttpPostRequest["Transfer-Encoding"] = "chunked"
		netHttpPostRequest.set_form_data({
			:client_id => MS_TRANSLATOR_CLIENT_ID,
			:client_secret => MS_TRANSLATOR_CLIENT_SECRET,
			:scope => MS_TRANSLATOR_SCOPE,
			:grant_type => MS_TRANSLATOR_GRANT_TYPE})

		#grant_type
		#	client_credentials
		#client_id
		#	アプリケーションの登録時に指定したクライアント ID
		#client_secret
		#	アプリケーションの登録時に取得した顧客の秘密
		#scope
		#	http://api.microsofttranslator.com
		#POSTするときはcontent-type=application/x-www-form-urlencoded で送ること。 multipart/form-dataで送るとは受信できないというエラーになる。
		#aPostData = []
		#aPostData << "grant_type=client_credentials"
		#aPostData << "client_id=#{URI.encode(MICROSOFT_CLIENT_ID)}"
		#aPostData << "client_secret=#{URI.encode(MICROSOFT_CLIENT_SECRET)}"
		#aPostData << "scope=http://api.microsofttranslator.com"
		#sPostData = aPostData.join("&")

		#nContentLength = sPostData.size
		#netHttpPostRequest["Content-Length"] = nContentLength.to_s
		
		#netHttpPostRequest.body = sPostData
		#netHttpPostRequest.body = URI.escape(sPostData)

		#STDERR.puts netHttpPostRequest.method 
		#STDERR.puts netHttpPostRequest.body 
		#STDERR.puts netHttpPostRequest["content-type"] 
		#STDERR.puts netHttpPostRequest.path 
		
		#netHttpsAPIDatamarketAzureCom.set_debug_output(STDERR)
		httpResponse = netHttpsAPIDatamarketAzureCom.request(netHttpPostRequest)

		#STDERR.puts "JSON_REQUEST:\n	#{httpResponse.body}"

		if httpResponse.message == "OK" then
			@timeUpdateAccessToken = Time.now()
			jsonResponse = JSON.parse(httpResponse.body)
		else
			@timeUpdateAccessToken = false
			jsonResponse = false
		end

		return jsonResponse
	end

	def get_access_token(bRenewFlag = false)
		bRenewJsonFlag = true
		if(@timeUpdateAccessToken && @expiresIn)
			delta = Time.now - @timeUpdateAccessToken
			if(delta <= @expiresIn.to_i - 10)
				bRenewJsonFlag = false
			end
		end

		bRenewJsonFlag = true if bRenewFlag == true

		@jsonResult = get_json_of_access_token() if bRenewJsonFlag == true
		@accessToken = @jsonResult["access_token"]
		@expiresIn = @jsonResult["expires_in"]

		return @accessToken
	end

	def exist_cache(sFromLang, sFromText, sToLang)
		sLangKey = "#{sFromLang} to #{sToLang}" 
		return false unless @cache.has_key?(sLangKey)
		return @cache[sLangKey].has_key?(sFromText)
	end

	def set_cache(sFromLang, sFromText, sToLang, sToText)
		sToText.chomp!
		sToText.strip!
		return false if sToText.to_s.size == 0
		sLangKey = "#{sFromLang} to #{sToLang}" 
		return false unless @cache.has_key?(sLangKey)
		@cache[sLangKey][sFromText] = sToText unless exist_cache(sFromLang, sFromText, sToLang)
		return true
	end

	def get_cache(sFromLang, sFromText, sToLang)
		sLangKey = "#{sFromLang} to #{sToLang}" 
		return false unless @cache.has_key?(sLangKey)
		return @cache[sLangKey][sFromText]
	end

	def detect_microsoft(sFromText, sAppID=ENGINE_SITE_MICROSOFT_APPID)

		#return get_cache(sFromText) if exist_cache(sFromText) 
		sAccessToken = get_access_token()
		#STDERR.puts "Access Token = <#{sAccessToken}>"
		# 翻訳対象の文
		#h = Net::HTTP.new("api.microsofttranslator.com")
		uri = URI.parse(MS_TRANSLATOR_DETECT_URL)
		Net::HTTP.version_1_2
		h = Net::HTTP.new(uri.host, uri.port)
		#h.set_debug_output(STDERR)
		#sGetPath = "/V2/Http.svc/Translate"
		#aGetData = []
		#aGetData << "from=#{sFromLang}"
		#aGetData << "to=#{sToLang}"
		#aGetData << "text=#{sFromText}"
		#sGetData = aGetData.join("&")
		#netHttpGetRequest.body = sGetData
		hGetParams = {
			:text => sFromText
		}
		#sQueryStr = hGetParams.map{ |k,v|
		#	URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
		#}.join("&")
		sQueryStr = hGetParams.map{ |k,v|
			k.to_s + "=" + v.to_s
		}.join("&")
		netHttpGetRequest = Net::HTTP::Get.new(uri.path + "?" + sQueryStr)
		netHttpGetRequest["Authorization"] = "Bearer #{sAccessToken}"
		#netHttpGetRequest["Transfer-Encoding"] = "chunked"
		#h = Net::HTTP.new("api.datamarket.azure.com")
		#STDERR.puts
		while true do
			begin
				#response = h.get("/V2/Http.svc/Translate?appid=#{sAppID}&from=#{sFromLang}&to=#{sToLang}&text=#{sFromText}")
				#response = h.get("/Bing/MicrosoftTranslator/v1/Translate?&client_id=#{sAppID}&from=#{sFromLang}&to=#{sToLang}&text=#{sFromText}")
				response = h.request(netHttpGetRequest)
				break
			rescue
			end
			# Added by Takeru on 2012.07.29
			#STDERR.print "Looping translate by Microsoft.(#{response})\r"
		end
		#STDERR.puts
		sToText = "#{sFromText}" unless response.message == 'OK'
		#STDERR.puts response.body
		doc = REXML::Document.new(response.body)
		sDetectLangTemp = "#{doc.root.text}"
		sDetectLang = URI.decode(sDetectLangTemp)
		sDetectLang.strip!
		#sToText.gsub(/\)$/, "")
		#sleep(0.5)
		return sDetectLang
	end

	def translate_microsoft(sFromText, sInputFromLang="en", sToLang="ja", sAppID=ENGINE_SITE_MICROSOFT_APPID)

		sAccessToken = get_access_token()
		#STDERR.puts "Access Token = <#{sAccessToken}>"
		# 翻訳対象の文
		#h = Net::HTTP.new("api.microsofttranslator.com")
		uri = URI.parse(MS_TRANSLATOR_URL)
		Net::HTTP.version_1_2
		h = Net::HTTP.new(uri.host, uri.port)
		#h.set_debug_output(STDERR)
		#sGetPath = "/V2/Http.svc/Translate"
		#aGetData = []
		#aGetData << "from=#{sFromLang}"
		#aGetData << "to=#{sToLang}"
		#aGetData << "text=#{sFromText}"
		#sGetData = aGetData.join("&")
		#netHttpGetRequest.body = sGetData
		begin
			sFromLang = detect_microsoft(sFromText, sAppID)
			STDERR.print "#{sFromLang} is detected."
			case sFromLang
			when "en", "fr", "ja"
			else
				STDERR.print "but set is #{sInputFromLang} because #{sFromLang} is unused."
				sFromLang = sInputFromLang
			end
		rescue
			sFromLang = sInputFromLang
			STDERR.print "Undetected. Lang is #{sFromLang}."
		end
		STDERR.puts "to #{sToLang}."
		return get_cache(sFromLang, sFromText, sToLang) if exist_cache(sFromLang, sFromText, sToLang) 
		hGetParams = {
			:from => sFromLang,
			:to => sToLang,
			:text => sFromText
		}
		#sQueryStr = hGetParams.map{ |k,v|
		#	URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
		#}.join("&")
		sQueryStr = hGetParams.map{ |k,v|
			k.to_s + "=" + v.to_s
		}.join("&")
		netHttpGetRequest = Net::HTTP::Get.new(uri.path + "?" + sQueryStr)
		netHttpGetRequest["Authorization"] = "Bearer #{sAccessToken}"
		#netHttpGetRequest["Transfer-Encoding"] = "chunked"
		#h = Net::HTTP.new("api.datamarket.azure.com")
		#STDERR.puts
		while true do
			begin
				#response = h.get("/V2/Http.svc/Translate?appid=#{sAppID}&from=#{sFromLang}&to=#{sToLang}&text=#{sFromText}")
				#response = h.get("/Bing/MicrosoftTranslator/v1/Translate?&client_id=#{sAppID}&from=#{sFromLang}&to=#{sToLang}&text=#{sFromText}")
				response = h.request(netHttpGetRequest)
				break
			rescue
			end
			# Added by Takeru on 2012.07.29
			#STDERR.print "Looping translate by Microsoft.(#{response})\r"
		end
		#STDERR.puts
		sToText = "#{sFromText}" unless response.message == 'OK'
		#STDERR.puts response.body
		doc = REXML::Document.new(response.body)
		sToTextTemp = "#{doc.root.text}"
		sToText = URI.decode(sToTextTemp)
		sToText.strip!
		#sToText.gsub(/\)$/, "")
		#sleep(0.5)
		set_cache(sFromLang, sFromText, sToLang, sToText)
		return sToText
	end

	def translate_google(sFromText, sFromLang="en", sToLang="ja")
		# 翻訳対象の文
		sIPAddress = "#{IPSocket::getaddress(Socket::gethostname)}"
		h = Net::HTTP.new("ajax.googleapis.com")
		response = h.get("/ajax/services/language/translate?v=1.0&q=#{sFromText}&langpair=#{sFromLang}|#{sToLang}&userip=#{sIPAddress}")
#STDERR.puts response
		sToText = "#{sFromText}" unless response.message == 'OK'
		j = JSON.parse(response.body)
		sToText = "#{j["responseData"]["translatedText"]}"
		sToText.strip!
		return sToText
	end
end
 


if $0 == __FILE__ then
	# 引数が無い場合はエラー
	TranslateLIB.init()
	if ARGV.length == 0 then
#				raise "1 argument is needed"
	#	sFromTextOriginal = "Uruguay were forced to play the final nine minutes of the match in Cape Town with 10 men following the dismissal of substitute Nicolas Lodeiro for a second bookable offence. Substitute Thierry Henry had a late penalty shout for handball dismissed as lacklustre France finally took the game to their opponents, but failure to capitalise on their numerical advantage ended in a disappointing stalemate."
	sFromTextOriginal = "I translate to Japanese. \nAre you OK?"
#		sFromTextOriginal = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\np, li { white-space: pre-wrap; }\n</style></head><body style=\" font-family:'Sans Serif'; font-size:9pt; font-weight:400; font-style:normal;\">\n<table style=\"-qt-table-type: root; margin-top:4px; margin-bottom:4px; margin-left:4px; margin-right:4px;\">\n<tr>\n<td style=\"border: none;\">\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-size:large;\">Veuillez choisir celle avec laquelle</span></p>\n<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"><span style=\" font-size:large;\"> vous souhaitez travailler</span></p></td></tr></table></body></html>"
		STDERR.puts "<#{sFromTextOriginal}>"
	else
		sFromTextOriginal = ARGV[0]
	end

	

#	sFromLang = TranslateLIB.detect(sFromTextOriginal)
	sFromLang = "en"

	sToTextMicrosoft = TranslateLIB.translate(sFromTextOriginal, sFromLang, "ja", TranslateLIB::ENGINE_SITE_MICROSOFT)
#	sToTextGoogle = TranslateLIB.translate(sFromTextOriginal, sFromLang, "ja", TranslateLIB::ENGINE_SITE_GOOGLE)
	sToTextGoogle = ""

	puts "Original Sentense: \n#{sFromTextOriginal}\n"
	puts
	puts "Original Sentense Language: \n#{sFromLang}\n"
	puts
	puts "Translate Sentense powered by Microsoft: \n#{sToTextMicrosoft}\n"
	puts
	puts "Translate Sentense powered by Google: \n#{sToTextGoogle}\n"
	puts
end
