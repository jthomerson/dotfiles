# Taken from: https://gist.github.com/jvenator/9672772a631c117da151
curl -o ~/Downloads/pdftk_download.pkg https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.6-setup.pkg && \
pkgutil --expand ~/Downloads/pdftk_download.pkg ~/Downloads/pdftk_package && \
cd ~ && \
mkdir /usr/local/Cellar/pdftk \
      /usr/local/Cellar/pdftk/2.02 \
      /usr/local/Cellar/pdftk/2.02/bin \
      /usr/local/Cellar/pdftk/2.02/lib \
      /usr/local/Cellar/pdftk/2.02/share \
      /usr/local/Cellar/pdftk/2.02/share/man \
      /usr/local/Cellar/pdftk/2.02/share/man/man1 && \
mv ~/Downloads/pdftk_package/pdftk.pkg/Payload ~/Downloads/pdftk_package/pdftk.pkg/payload.gz && \
gunzip ~/Downloads/pdftk_package/pdftk.pkg/payload.gz && \
cd ~/Downloads/pdftk_package/pdftk.pkg/ && \
   cpio -iv < ~/Downloads/pdftk_package/pdftk.pkg/payload && \
cd ~ && \
   mv Downloads/pdftk_package/pdftk.pkg/bin/pdftk /usr/local/Cellar/pdftk/2.02/bin/pdftk && \
   mv Downloads/pdftk_package/pdftk.pkg/lib/* /usr/local/Cellar/pdftk/2.02/lib/ && \
   mv Downloads/pdftk_package/pdftk.pkg/man/pdftk.1 /usr/local/Cellar/pdftk/2.02/share/man/man1/pdftk.1 && \
brew doctor
brew link pdftk
