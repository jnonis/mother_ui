import java.io.FileFilter;

/** Returns the starting pd patch for given patch directory. */
File getMainPd(File patchDir) {
  if (patchDir.exists() && patchDir.isDirectory()) {
    File[] files = patchDir.listFiles(new FileFilter() {
      @Override
      public boolean accept(File pathname) {
        if (!pathname.isDirectory() && "main.pd".equals(pathname.getName())) {
          return true;
        }
        return false;
      }
    });
    if (files.length > 0) {
      return files[0];
    }
  }
  return null;
}

/** This function returns all the directories in a directory as an array of Files. */  
File[] listFile(String dir) {
  File file = new File(dir);
  if (file.exists() && file.isDirectory()) {
    File[] files = file.listFiles(new FileFilter() {
      @Override
      public boolean accept(File pathname) {
        return pathname.isDirectory() && !pathname.getName().startsWith(".");
      }
    });
    Arrays.sort(files, new Comparator<File>() {
      public int compare(File a, File b) { 
        return a.getName().compareTo(b.getName()); 
      } 
    });
    return files;
  } else {
    return new File[0];
  }
}

void openPatch() {
  selectInput("Select a patch:", "patchSelected");
}

void patchSelected(File selection) {
  if (selection != null) {
    sendLoadPatch(selection.getAbsolutePath());
  }
}
