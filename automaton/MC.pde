class MainCell extends Cell {
  MainCell(int depth, int sx, int sy) {
    super(depth, sx, sy, null);
  }
  boolean getO(int x, int y) {
    if (x < sx | y < sy | x >= sx+sz | y >= sy+sz) return false;
    return get(x, y);
  }
  Cell cellAtO(int x, int y) {
    if (x < sx | y < sy | x >= sx+sz | y >= sy+sz) return ECell.cache[0];
    return cellAt(x, y);
  }
  MainCell step(Set<Pos> news) {
    MainCell n = new MainCell(depth, sx, sy);
    if (depth == 0) throw new Error("NONSENSE!");
    else {
      for (int i = 0; i < sam; i++) n.sc[i] = sc[i].step(n, news);
      return n;
    }
  }
  MainCell copy() {
    MainCell n = new MainCell(depth, sx, sy);
    for (int i = 0; i < sam; i++) n.sc[i] = sc[i].copy(this);
    return n;
  }
  boolean darkO(int x, int y) {
    if (x < sx | y < sy | x >= sx+sz | y >= sy+sz) return false;
    return dark(x, y);
  }
  boolean get(int x, int y) {
    if (x < 0 | y < 0 | x >= sz | y >= sz) return false;
    return super.get(x, y);
  }
  void set(int x, int y) {
    if (x < 0 | y < 0 | x >= sz | y >= sz) return;
    super.set(x, y);
  }
}

MainCell step(MainCell i) {
  HashSet<Pos> news = new HashSet<Pos>();
  MainCell f = i.step(news);
  //println(news.size());
  for (Pos p : news) {
    //println(p.x+" "+p.y+" is news to me");
    Cell n = i.fcellAt(p.x, p.y).step(f.pcellAt(p.x, p.y), null);
    if (!(n instanceof ECell)) f.setCell(p.x, p.y, n);
  }
  return f;
}
