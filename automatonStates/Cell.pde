static final int FSZ = 32;
static class Cell {
  static final int sw = 8; // sub width
  static final int sam = sw*sw; // sub amount
  static final int[] bad = {0, 1, 30, 31}; 
  final int depth; // 0 - int[]; 1+ - rec
  final int sx, sy;
  int sz, ssz;
  final Cell[] sc; // subcells
  final Cell p;
  final byte[][] data;
  
  Cell(int d) {
    depth = d;
    sz = FSZ;
    for(int i = 0; i < depth; i++) sz*= sw;
    ssz = sz / sw;
    sc = null;
    data = new byte[FSZ][FSZ];
    sx = sy = -1;
    p = null;
  }
  Cell(int depth, int sx, int sy, Cell p) {
    this.sx = sx;
    this.sy = sy;
    sz = 32;
    this.depth = depth;
    if(depth==0) {
      data = new byte[FSZ][FSZ];
      sc = null;
      
      ssz = -1;
    } else {
      sc = new Cell[sam];
      data = null;
      for (int i = 0; i < sam; i++) sc[i] = ECell.cache[depth-1];
      for(int i = 0; i < depth; i++) sz*= sw;
      ssz = sz / sw;
    }
    this.p = p;
  }
  void set(int x, int y, byte st) {
    if (depth > 0) {
      int cx = (x-sx) / ssz;
      int cy = (y-sy) / ssz;
      int p = cy*sw + cx;
      if (sc[p] instanceof ECell) sc[p] = new Cell(depth-1, sx + cx*ssz, sy + cy*ssz, this);
      sc[p].set(x, y, st);
    } else {
      int cx = x-sx;
      int cy = y-sy;
      data[cy][cx] = st;
    }
  }
  
  byte qg(int x, int y) {
    if (x>=0 & y>=0 & x<FSZ & y<FSZ) return data[y][x];
    return getO(sx+x, sy+y);
  }
  
  byte get(int x, int y) {
    if (depth > 0) {
      int cx = (x-sx) / ssz;
      int cy = (y-sy) / ssz;
      return sc[cy*sw + cx].get(x, y);
    } else {
      int cx = x-sx;
      int cy = y-sy;
      return data[cy][cx];
    }
  }
  byte getO(int x, int y) {
    if (x < sx | y < sy | x >= sx+sz | y >= sy+sz) return p.getO(x, y);
    return get(x, y);
  }
  
  Cell step(Cell np, Set<Pos> news) {
    Cell n = new Cell(depth, sx, sy, np);
    if (depth == 0) {
      long S = System.nanoTime();
      
      // START LOGIC
      //
      for(int x = 2; x < FSZ-2; x++) {
        for(int y = 2; y < FSZ-2; y++) {
          int smx = 0;
          int smy = 0;
          for(int dy = -2; dy <= 2; dy++) {
            for(int dx = -2; dx <= 2; dx++) {
              int cx = dx+x;
              int cy = dy+y;
              byte s = data[cy][cx];
              smx+= dx*(s&3);
              smy+= dy*(s>>2);
            }
          }
          byte res = data[y + 1-(smy+666+1)%3][x + 1-(smx+666+1)%3];
          n.data[y][x] = res; // surr[(smy+666+1)%3+1][(smx+666+1)%3+1];
          
        }
      }
      
      //slow case
      for(int x : new int[]{0,1,FSZ-2,FSZ-1}) {
        for(int y = 2; y < FSZ-2; y++) {
          int smx = 0;
          int smy = 0;
          for(int dy = -2; dy <= 2; dy++) {
            for(int dx = -2; dx <= 2; dx++) {
              int cx = dx+x;
              int cy = dy+y;
              byte s = (cx>=0 & cy>=0 & cx<FSZ & cy<FSZ) ? data[cy][cx] : getO(sx+cx, sy+cy);
              smx+= dx*(s&3);
              smy+= dy*(s>>2);
            }
          }
          byte res = getO(sx + x + 1-(smx+666+1)%3, sy + y + 1-(smy+666+1)%3);
          n.data[y][x] = res; // surr[(smy+666+1)%3+1][(smx+666+1)%3+1];
          
        }
      }
      for(int x = 0; x < FSZ; x++) {
        for(int y : new int[]{0,1,FSZ-2,FSZ-1}) {
          int smx = 0;
          int smy = 0;
          for(int dy = -2; dy <= 2; dy++) {
            for(int dx = -2; dx <= 2; dx++) {
              int cx = dx+x;
              int cy = dy+y;
              byte s = (cx>=0 & cy>=0 & cx<FSZ & cy<FSZ) ? data[cy][cx] : getO(sx+cx, sy+cy);
              smx+= dx*(s&3);
              smy+= dy*(s>>2);
            }
          }
          byte res = getO(sx + x + 1-(smx+666+1)%3, sy + y + 1-(smy+666+1)%3);
          n.data[y][x] = res; // surr[(smy+666+1)%3+1][(smx+666+1)%3+1];
          
        }
      }
      
      // END LOGIC
      
      for (byte b : data[0]) if (b!=0) {
        if (darkO(sx, sy-32)) news.add(new Pos(sx, sy-32));
        break;
      }
      for (byte b : data[FSZ-1]) if (b!=0) {
        if (darkO(sx, sy+32)) news.add(new Pos(sx, sy+32));
        break;
      }
      
      if (data[0    ][0    ] != 0 && darkO(sx-32, sy-32)) news.add(new Pos(sx-32, sy-32));
      if (data[FSZ-1][0    ] != 0 && darkO(sx-32, sy+32)) news.add(new Pos(sx-32, sy+32));
      if (data[0    ][FSZ-1] != 0 && darkO(sx+32, sy-32)) news.add(new Pos(sx+32, sy-32));
      if (data[FSZ-1][FSZ-1] != 0 && darkO(sx+32, sy+32)) news.add(new Pos(sx+32, sy+32));
      
      boolean lf = false, rf = false, e = true; // r/l filled, empty
      for(byte[] i : data) {
        if (i[0]!=0) lf = true;
        if (i[FSZ-1]!=0) rf = true;
      }
      if (lf && darkO(sx-32, sy)) news.add(new Pos(sx-32, sy));
      if (rf && darkO(sx+32, sy)) news.add(new Pos(sx+32, sy));
      
      for(byte[] ln : n.data) {
        for (byte b : ln) {
          if (b != 0) {
            e = false;
            break;
          }
        }
      }
      avgs[3]+= System.nanoTime() - S;
      if (e) return ECell.cache[depth];
      return n;
    } else {
      
      for (int i = 0; i < sam; i++) n.sc[i] = sc[i].step(n, news);
      for (int i = 0; i < sam; i++) {
        if (!(n.sc[i] instanceof ECell)) return n;
      }
      return ECell.cache[depth];
    }
  }
  Cell fcellAt(int x, int y) { // forced cell at
    if (depth > 0) {
      int cx = (x-sx) / ssz;
      int cy = (y-sy) / ssz;
      int p = cy*sw + cx;
      if (sc[p] instanceof ECell) sc[p] = new Cell(depth-1, sx + cx*ssz, sy + cy*ssz, this);
      return sc[p].fcellAt(x, y);
    } else return this;
  }
  Cell cellAt(int x, int y) { // may return ECell
    if (depth > 0) {
      int cx = (x-sx) / ssz;
      int cy = (y-sy) / ssz;
      int p = cy*sw + cx;
      return sc[p].cellAt(x, y);
    } else return this;
  }
  Cell cellAtO(int x, int y) { // may return ECell
    if (x < sx | y < sy | x >= sx+sz | y >= sy+sz) return p.cellAtO(x, y);
    return cellAt(x, y);
  }
  Cell pcellAt(int x, int y) {
    if (depth > 1) {
      int cx = (x-sx) / ssz;
      int cy = (y-sy) / ssz;
      int p = cy*sw + cx;
      if (sc[p] instanceof ECell) sc[p] = new Cell(depth-1, sx + cx*ssz, sy + cy*ssz, this);
      return sc[p].pcellAt(x, y);
    } else return this;
  }
  void setCell(int x, int y, Cell c) {
    int cx = (x-sx) / ssz;
    int cy = (y-sy) / ssz;
    int p = cy*sw + cx;
    if (depth > 1) {
      if (sc[p] instanceof ECell) sc[p] = new Cell(depth-1, sx + cx*ssz, sy + cy*ssz, this);
      sc[p].setCell(x, y, c);
    } else sc[p] = c;
  }
  boolean dark(int x, int y) {
    //println(x, y, this, depth);
    if (depth == 0) return false;
    int cx = (x-sx) / ssz;
    int cy = (y-sy) / ssz;
    return sc[cy*sw + cx].dark(x, y);
  }
  boolean darkO(int x, int y) {
    if (x < sx | y < sy | x >= sx+sz | y >= sy+sz) return p.darkO(x, y);
    return dark(x, y);
  }
  int count() {
    int count = 0;
    if (depth == 0) for (byte[] ln : data) for (byte b : ln) if (b!=0) count+= 1;
    else for (int i = 0; i < sam; i++) count+= sc[i].count();
    return count;
  }
  int count1() {
    int count = 0;
    if (depth == 1) for (int i = 0; i < sam; i++) count+= sc[i] instanceof ECell? 0 : 1;
    else for (int i = 0; i < sam; i++) count+= sc[i].count1();
    return count;
  }
  void draw(PGraphics g, int mx, int my, double zzx, double zzy) {
    if (mx > dex | my > dey | mx+sz < dsx | my+sz < dsy) return;
    dot++;
    if (zm*sz < (phone? 4 : 1)) {
      doc++;
      g.fill(210);
      g.noStroke();
      g.rect((float)(zzx + mx*zm), (float)(zzy + my*zm), (float)Math.ceil(zm*sz), (float)Math.ceil(zm*sz));
      return;
    }
    if (depth > 0) {
      for (int y = 0; y < sw; y++)
        for (int x = 0; x < sw; x++)
          sc[y*sw + x].draw(g, mx + x*ssz, my + y*ssz, zzx, zzy);
    } else {
      d0c++;
      if (zm>5) g.stroke(34);
      else g.noStroke();
      g.fill(210);
      float sz = max((float) zm, 1);
      for (int y = 0; y < 32; y++) {
        byte[] ln = data[y];
        //println(Arrays.toString(ln));
        for (int x = 0; x < 32; x++) {
          if (ln[x] != 0) {
            g.fill(COLORS[ln[x]]);
            g.rect((float)(zzx + (mx+x)*zm), (float)(zzy + (my+y)*zm), sz, sz);
          }
        }
      }
    }
  }
}

static class Pos {
  int x, y;
  Pos(int x, int y) {
    this.x = x;
    this.y = y;
  }
  public boolean equals(Object o) {
    Pos p = (Pos) o;
    return p.x==x && p.y==y;
  }
  public int hashCode() {
    return x*31+y;
  }
}


static class ECell extends Cell {
  public static final ECell[] cache = new ECell[10];
  static {
    for(int i = 0; i < 10; i++) cache[i] = new ECell(i);
  }
  private ECell(int depth) {
    super(depth);
  }
  void set(int x, int y, byte st) {
    throw new Error("set empty");
  }
  byte get(int x, int y) {
    return 0;
  }
  Cell step(Cell np, Set<Pos> news) {
    return this;
  }
  boolean dark(int x, int y) {
    return true;
  }
  Cell cellAt(int x, int y) { // may return ECell
    return this;
  }
  Cell fcellAt(int x, int y) {
    throw new Error("qyfuf");
  }
  int count() {
    return 0;
  }
  int count1() {
    return 0;
  }
  void draw(PGraphics g, int mx, int my, double zzx, double zzy) {
    if (mx > dex | my > dey | mx+sz < dsx | my+sz < dsy) return;
    if (zm*sz-2 < 7) return;
    doc++;
    g.fill(#1f1f26);
    g.rect((float)(zzx + mx*zm + 3), (float)(zzy + my*zm + 3), (float)(zm*sz - 6), (float)(zm*sz - 6));
  }
  void addTo(OutputStream s) {
    try {
      s.write(depth+64);
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
}
