# /bin/bash
rm -rf wps-*
rm -rf build

hwclock -s
timedatectl set-ntp false
wget -q https://wps-linux-365.wpscdn.cn/wps/download/ep/Linux365/20327/wps-office_12.8.2.20327.AK.preload.sw_amd64.deb
wget -q https://github.com/Satxm/wps-office/releases/download/wps-fonts/wps-fonts.zip
wget -q https://github.com/Satxm/wps-office/releases/download/wps-license/wps-license.zip

date -s "$(stat -c %y wps-office_12.8.2.20327.AK.preload.sw_amd64.deb | awk -F. '{print $1}')"
mkdir wps-365
mkdir wps-365/DEBIAN
mkdir build

dpkg -x wps-office_12.8.2.20327.AK.preload.sw_amd64.deb wps-365/
dpkg -e wps-office_12.8.2.20327.AK.preload.sw_amd64.deb wps-365/DEBIAN

# remove file
rm -rf wps-365/opt/*xiezuo*
rm -rf wps-365/usr/*xiezuo*
rm -rf wps-365/usr/share/doc/*xiezuo*
rm -rf wps-365/usr/share/fonts
rm -rf wps-365/usr/share/applications/{wps-office-officeassistant.desktop,wps-office-uninstall.desktop,xiezuo.desktop}
rm -rf wps-365/usr/bin/{wps_uninstall.sh,wps_xterm}
rm -rf wps-365/usr/share/desktop-directories

# fix template path
sed -i 's|URL=.*|URL=/opt/kingsoft/wps-office/office6/mui/zh_CN/templates/newfile.docx|' \
 wps-365/usr/share/templates/wps-office-wps-template.desktop
sed -i 's|URL=.*|URL=/opt/kingsoft/wps-office/office6/mui/zh_CN/templates/newfile.xlsx|' \
 wps-365/usr/share/templates/wps-office-et-template.desktop
sed -i 's|URL=.*|URL=/opt/kingsoft/wps-office/office6/mui/zh_CN/templates/newfile.pptx|' \
 wps-365/usr/share/templates/wps-office-wpp-template.desktop

# fix menu category
sed -i 's|Categories=.*|&Office;|' wps-365/usr/share/applications/*.desktop

# fix background process
sed -i '2i [[ $(ps -ef | grep -c "office6/$(basename $0)") == 1 ]] && export gOptExt=-multiply' \
 wps-365/usr/bin/{wps,wpp,et,wpspdf}

sed -i 's|YUA..=NsbhfV4nLv_oZGENyLSVZA..|YUA..=WHfH10HHgeQrW2N48LfXrA..|' \
 wps-365/opt/kingsoft/wps-office/office6/wtool/oem.ini \
 wps-365/opt/kingsoft/wps-office/office6/cfgs/oem.ini

sed -i '/^set +e /,$d' wps-365/DEBIAN/{postinst,postrm,preinst,prerm}

sed -i -e "s/'wps-office-uninstall.desktop' //g" -e "s/'wps-office-officeassistant.desktop' //g" wps-365/DEBIAN/prerm

#sed -i '/^Recommends: ttf-mscorefonts-installer/d' wps-365/DEBIAN/control
sed -i 's/Recommends: ttf-mscorefonts-installer/Recommends: wps-office-fonts/' wps-365/DEBIAN/control

size=$(du -ks wps-365 --exclude=DEBIAN | cut -f1)
sed -ri "s/^Installed-Size.*$/Installed-Size: $size/g" wps-365/DEBIAN/control

dpkg-deb -b wps-365/ build/

mkdir wps-license
unzip -q wps-license.zip -d wps-license
size=$(du -ks wps-license --exclude=DEBIAN | cut -f1)
sed -ri "s/^Installed-Size.*$/Installed-Size: $size/g" wps-license/DEBIAN/control
dpkg-deb -b wps-license/ build/

mkdir wps-fonts
unzip -q wps-fonts.zip -d wps-fonts
size=$(du -ks wps-fonts --exclude=DEBIAN | cut -f1)
sed -ri "s/^Installed-Size.*$/Installed-Size: $size/g" wps-fonts/DEBIAN/control
dpkg-deb -b wps-fonts/ build/

timedatectl set-ntp true
hwclock -s
rm -rf wps-*
