
void patchListMode() {
  println("patchListMode");
  patchList = true;
  selectPressed = false;
  oled.setPage(Oled.MAIN);
  drawPatches();
}

void drawPatches() {
  oled.clearOled();
  if (patchLoadedIndex >= 0) {
    oled.drawLine(0, "> " + patches[patchLoadedIndex].getName());
  }
  for (int i = 0; i < 5; i++) {
    oled.drawLine(i + 1, patches[patchIndex + i].getName());
  }
  oled.drawInvertLine(patchSelected - patchIndex + 1);
}

void previousPatch() {
  patchSelected--;
  if (patchSelected < 0) {
    patchSelected = 0;
  }
  if (patchSelected < patchIndex) {
    patchIndex--;
  }
  drawPatches();
}

void nextPatch() {
  patchSelected++;
  if (patchSelected >= patches.length) {
    patchSelected = patches.length - 1;
  }
  if (patchSelected > patchIndex + 4) {
    patchIndex++;
  }
  drawPatches();
}

void selectPatch() {
  patchList = false;
  oled.setPage(Oled.PATCH);
  controlMode = CONTROL_MODE_KNOBS;
  if (patchSelected != patchLoadedIndex) {
    oled.clearOled();
    patchLoadedIndex = patchSelected;
    if (patches.length > 0) {
      File mainPd = getMainPd(patches[patchLoadedIndex]);
      if (mainPd != null) {
        showInfoBar = true;
        enablePatchSub = false;
        patchLoaded = false;
        loadPatch(mainPd.getAbsolutePath());
      }
    }
  }
}
