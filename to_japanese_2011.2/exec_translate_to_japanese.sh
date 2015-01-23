#!/bin/bash
sudo ./to_japanese/bin/translate_sm.rb
sudo cp ./to_japanese/var/LightApp.xml ./SALOME/SALOME6/V6_3_0_public/GUI_V6_3_0_public/share/salome/resources/gui
echo "done."
