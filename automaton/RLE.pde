class RLE {
  int cl;
  boolean cm = false;
  ArrayList<Integer> ln = new ArrayList();
  StringBuilder res = new StringBuilder();
  void on(int len) {
    if (cm) cl+= len;
    else {
      ln.add(cl);
      cl = len;
      cm = true;
    }
  }
  void off(int len) {
    if (!cm) cl+= len;
    else {
      ln.add(cl);
      cl = len;
      cm = false;
    }
  }
  void ln() {
    if (cl != 0) ln.add(cl);
    if (ln.size() > 1) {
      for (int i = 0; i < ln.size(); i++) {
        int c = ln.get(i);
        if (c != 1) res.append(c);
        res.append(i%2==0? 'b' : 'o');
      }
    }
    res.append("$");
    
    cm = false;
    ln.clear();
    cl = 0;
  }
}
