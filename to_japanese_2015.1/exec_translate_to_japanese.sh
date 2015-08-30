#!/bin/bash
sudo ./to_japanese/bin/translate_sm.rb $@
#sudo cp ./to_japanese/var/LightApp.xml ./SALOME/SALOME6/V6_3_0_public/GUI_V6_3_0_public/share/salome/resources/gui
#sudo cp ./to_japanese/var/LightApp_2012.1.xml ./SALOME/Salome-V6_4_0-x86_64/modules/GUI_V6_4_0/share/salome/resources/gui/LightApp.xml
#sudo cp ./to_japanese/var/LightApp.xml ./SALOME/Salome-V6_5_0p1-OT-LGPL-x86_64/modules/GUI_V6_5_0p1/share/salome/resources/gui/LightApp.xml
sudo cp ./to_japanese/var/LightApp.xml ./SALOME-MECA-2013.2-LGPL/modules/GUI_V6_6_0/share/salome/resources/gui/LightApp.xml
echo "done."
