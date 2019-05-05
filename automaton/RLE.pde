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

String getRLE(MainCell c) {
  RLE r = new RLE();
  int maxY = c.maxY();
  for (int y = c.minY(); y < maxY; y++) {
    c.writeRle(r, y);
    r.ln();
  }
  r.res.append("!");
  return r.res.toString();
}

MainCell loadRLE(String s) {
  while (!s.startsWith("x") && s.contains("\n")) s = s.substring(s.indexOf("\n")+1);
  s = s.substring(s.indexOf("\n")+1);
  if (s.length() == 0) return null;
  String[] lns = s.split("\\$");
  ArrayList<Integer>[] parsed = new ArrayList[lns.length];
  int min = Integer.MAX_VALUE;
  int max = Integer.MIN_VALUE;
  for (int i = 0; i < lns.length; i++) {
    ArrayList<Integer> a = new ArrayList();
    parsed[i] = a;
    String c = lns[i];
    int ci = 0;
    char last = 'b';
    a.add(0);
    for (int j = 0; j < c.length(); j++) {
      char ch = c.charAt(j);
      if (ch == 'o' || ch == 'b') {
        if (last == ch) a.set(a.size()-1, a.get(a.size()-1) + (ci==0? 1 : ci));
        else a.add(ci==0? 1 : ci);
        last = ch;
        ci = 0;
      } else if (ch >= '0' && ch <= '9') ci = ci*10 + ch-'0';
      else if (ch == '!') break;
    }
    int sum = 0;
    if (a.size()%2 == 1) a.remove(a.size()-1);
    for (int j = 0; j < a.size(); j++) sum+= a.get(j);
    if (a.size() > 0) min = min(min, a.get(0));
    max = max(max, sum);
  }
  MainCell c = new MainCell(POWER, 0, 0);
  int w = max - min;
  int h = parsed.length;
  for (int i = 0; i < parsed.length; i++) {
    ArrayList<Integer> a = parsed[i];
    int cp = HSZ - w/2 - min;
    for (int j = 0; j < a.size(); j+= 2) {
      int off = a.get(j);
      int on = a.get(j+1);
      for (int k = 0; k < on; k++) {
        c.set(cp+off+k, i+HSZ-h/2);
      }
      cp+= off+on;
    }
  }
  return c;
}
