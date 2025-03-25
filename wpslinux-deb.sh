# /bin/bash
rm -rf wps-*
rm -rf build

hwclock -s
timedatectl set-ntp false
wget -S https://wps-linux-365.wpscdn.cn/wps/download/ep/Linux365/20327/wps-office_12.8.2.20327.AK.preload.sw_amd64.deb
wget -S https://github.com/Satxm/wps-office/releases/download/wps-fonts/wps-fonts.zip
wget -S https://github.com/Satxm/wps-office/releases/download/wps-license/wps-license.zip

date -s "$(stat -c %y wps-office_12.8.2.20327.AK.preload.sw_amd64.deb | awk -F. '{print $1}')"
mkdir wps-365
mkdir wps-365/DEBIAN
mkdir build

dpkg -X wps-office_12.8.2.20327.AK.preload.sw_amd64.deb wps-365/
dpkg -e wps-office_12.8.2.20327.AK.preload.sw_amd64.deb wps-365/DEBIAN

unzip -o -d wps-365/usr/share/fonts/wps-office/ wps-fonts.zip

rm -rf wps-365/opt/xiezuo
rm -rf wps-365/usr/share/doc/*xiezuo*

rm -rf wps-365/usr/share/applications/wps-office-officeassistant.desktop
rm -rf wps-365/usr/share/applications/wps-office-uninstall.desktop
rm -rf wps-365/usr/share/applications/xiezuo.desktop

if (alias | grep -q cp); then unalias cp; fi

sed -i 's/SBsTlB8ffO_HVQHUh2-YUA..=NsbhfV4nLv_oZGENyLSVZA../SBsTlB8ffO_HVQHUh2-YUA..=WHfH10HHgeQrW2N48LfXrA../g' \
 wps-365/opt/kingsoft/wps-office/office6/wtool/oem.ini \
 wps-365/opt/kingsoft/wps-office/office6/cfgs/oem.ini

sed -i '/^Recommends: ttf-mscorefonts-installer/d' wps-365/DEBIAN/control

sed -i '/^set +e /,$d' \
 wps-365/DEBIAN/postinst \
 wps-365/DEBIAN/postrm \
 wps-365/DEBIAN/preinst \
 wps-365/DEBIAN/prerm

sed -i -e "s/'wps-office-uninstall.desktop' //g" \
 -e "s/'wps-office-officeassistant.desktop' //g" \
 wps-365/DEBIAN/prerm

dpkg-deb -b wps-365/ build/

mkdir wps-license
unzip wps-license.zip -d wps-license
dpkg-deb -b wps-license/ build/

timedatectl set-ntp true
hwclock -s
rm -rf wps-*
