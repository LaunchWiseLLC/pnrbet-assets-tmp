#!/usr/bin/env bash
RAW="https://raw.githubusercontent.com/LaunchWiseLLC/pnrbet-assets-tmp/master"
cd /app 2>/dev/null || { echo "NO_APP_DIR"; exit 9; }
echo "===== PNRBET logo transfer ====="
echo "--- git HEAD / dirty ---"
git -C /app rev-parse --short HEAD 2>&1
git -C /app status --porcelain=v1 2>&1 | head -30
echo "--- fetch text patch ---"
curl -sSL "$RAW/logo-text.patch" -o /tmp/lt.patch
echo "patch md5: $(md5sum /tmp/lt.patch | cut -d' ' -f1)  (expect a66ccab0f2e56774eb88c45162cb49ea)"
echo "--- git apply --check ---"
if git -C /app apply --check /tmp/lt.patch 2>/tmp/ae.txt; then
  echo "APPLY_CHECK_OK"
  if git -C /app apply --whitespace=nowarn /tmp/lt.patch; then echo "APPLY_DONE_OK"; else echo "APPLY_DONE_FAIL"; fi
else
  echo "APPLY_CHECK_FAILED"; cat /tmp/ae.txt
  echo "--- trying --reject (partial) ---"
  git -C /app apply --reject --whitespace=nowarn /tmp/lt.patch 2>&1 | tail -40
  echo "REJ_FILES:"; find /app/frontend -name '*.rej' 2>/dev/null
fi
echo "--- fetch 9 PNGs ---"
mkdir -p /app/frontend/src/assets
fetch(){ curl -sSL "$RAW/$1" -o "$2/$1"; local sz=$(stat -c%s "$2/$1" 2>/dev/null); local m=$(md5sum "$2/$1"|cut -d' ' -f1); echo "$m  ${sz}b  $2/$1  EXP:$3"; }
fetch apple-touch-icon.png /app/frontend/public c1292ec0e7440d08cce29e9ce0001d62
fetch favicon.png          /app/frontend/public 960b80c3f9a5659738ab0169b3e172bb
fetch logo192.png          /app/frontend/public 117562e42b8b33a1b3d29411bf08cc06
fetch logo512.png          /app/frontend/public 0d8c358d527169031f4953a0165d7a43
fetch og-image.png         /app/frontend/public d60834a243d449150fb5cbd150fb5392
fetch pnrbet-horizontal.png /app/frontend/src/assets f1b6c6adb4e6326530e93258c2f766b7
fetch pnrbet-icon.png       /app/frontend/src/assets 6fee070e801111a982b9d10383dbf582
fetch pnrbet-primary.png    /app/frontend/src/assets c951a2c388a6554847db65343a479390
fetch pnrbet-stacked.png    /app/frontend/src/assets 841451a399ee8ebbde6b92f0515d325d
echo "===== TRANSFER SCRIPT END ====="
