#!/bin/sh
find ./ -name "Eficas_msg_fr.qm" -exec tar -uvf $1.tar "{}" \;
find ./ -name "*_msg_ja.qm" -exec tar -uvf $1.tar "{}" \;
find ./ -name "LightApp.xml" -exec tar -uvf $1.tar "{}" \;
gzip $1.tar
mv $1.tar.gz $1.tgz

