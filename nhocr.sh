#! /bin/sh


# 画像ファイルをpbm形式に変換した後、nhocrにてテキストファイルに出力する。
# pdfも試験的に含めているが、出力pbmファイルがかなり大きくなる傾向がある。
# テキストファイルは画像ファイルの拡張子を"-OCR.txt"に置き換えられる。

picfile="___temp___.pbm"
srcfile=$(zenity --file-selection 						\
	--file-filter="*.bmp *.png *.gif *.jpg *.jpeg *.tif *.tiff *.pdf" 	\
	--title="日本語OCR : 入力画像ファイルを選択して下さい")
if test -z $srcfile; then 
  return 1
fi

dstfile=$(echo $srcfile | sed -e "s/\.[^.]*$/-OCR.txt/")
convert -density 300 -monochrome $srcfile $picfile
nhocr -block -o $dstfile $picfile
a=$?
if [ $a -eq 1 ] ; then 
  zenity --error --title "エラー発生" --text 			\
		"現行のnhocrでは未サポートの機能のようです。\nスクリプト側の記述ミスも考えられます。\n\n異常終了します。"
  return 1
fi
if [ $a -eq 2 ] ; then 
  zenity --error --title "エラー発生" --text 			\
		"nhocrにてファイル操作に失敗しました。\n入力pbmファイルが大きすぎる場合があります。\n\n異常終了します。"
  return 1
fi
rm -f $picfile
gedit $dstfile &

