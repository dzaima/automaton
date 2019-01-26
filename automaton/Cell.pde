static class Cell {
  static final int sw = 8; // sub width
  static final int sam = sw*sw; // sub amount
  static final int[] bad = {0, 1, 30, 31}; 
  final int depth; // 0 - int[]; 1+ - rec
  final int sx, sy;
  int sz, ssz;
  final Cell[] sc; // subcells
  final Cell p;
  final int[] data; // x=0: &0b1; x=31: n<0
  
  static int[] lm = new int[36];
  static int[] rm = new int[36];
  
  static int[] setMask = new int[32];
  static int[] set4Mask = new int[]{0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000};
  static int[] set8Mask = new int[]{0x0000000f, 0x000000f0, 0x00000f00, 0x0000f000, 0x000f0000, 0x00f00000, 0x0f000000, 0xf0000000};
  static int[] clrMask = new int[32];
  static int[] horizScores = new int[32];
  static int[] popc5 = new int[32];
  static {
    for (int i = 0; i < 32; i++) {
      setMask[i] =   1<<i;
      clrMask[i] = ~(1<<i);
      popc5[i] = Integer.bitCount(i);
      int sum = 0;
      for (int j = 0; j < 5; j++) {
        sum+= (((~i)>>j) & 1) * (j-2);
      }
      horizScores[31-i] = (sum+300 + 1)%3 + 2;
    }
  }
  Cell(int d) {
    depth = d;
    sz = 32;
    for(int i = 0; i < depth; i++) sz*= sw;
    ssz = sz / sw;
    sc = null;
    data = new int[32];
    sx = sy = -1;
    p = null;
  }
  Cell(int depth, int sx, int sy, Cell p) {
    this.sx = sx;
    this.sy = sy;
    sz = 32;
    this.depth = depth;
    if(depth==0) {
      data = new int[32];
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
  void set(int x, int y) {
    if (depth > 0) {
      int cx = (x-sx) / ssz;
      int cy = (y-sy) / ssz;
      int p = cy*sw + cx;
      if (sc[p] instanceof ECell) sc[p] = new Cell(depth-1, sx + cx*ssz, sy + cy*ssz, this);
      sc[p].set(x, y);
    } else {
      int cx = x-sx;
      int cy = y-sy;
      data[cy]|= setMask[cx];
    }
  }
  void clr(int x, int y) {
    if (depth > 0) {
      int cx = (x-sx) / ssz;
      int cy = (y-sy) / ssz;
      sc[cy*sw + cx].clr(x, y);
    } else {
      int cx = x-sx;
      int cy = y-sy;
      data[cy]&= clrMask[cx];
    }
  }
  
  boolean get(int x, int y) {
    if (depth > 0) {
      int cx = (x-sx) / ssz;
      int cy = (y-sy) / ssz;
      return sc[cy*sw + cx].get(x, y);
    } else {
      int cx = x-sx;
      int cy = y-sy;
      return (data[cy]&setMask[cx]) != 0;
    }
  }
  boolean getO(int x, int y) {
    if (x < sx | y < sy | x >= sx+sz | y >= sy+sz) return p.getO(x, y);
    return get(x, y);
  }
  
  Cell step(Cell np, Set<Pos> news) {
    Cell n = new Cell(depth, sx, sy, np);
    if (depth == 0) {
      long S = System.nanoTime();
      // quick case
      for (int y = 2; y < 30; y++) {
        int fln2 = data[y-1];
        int fln3 = data[y  ];
        int fln4 = data[y+1];
        if (fln2==0 & fln3==0 & fln4==0) continue;
        int fln1 = data[y-2];
        int fln5 = data[y+2];
        for (int x = 2; x < 30; x++) {
          int ln1 = (fln1 >> (x-2)) & 31;
          int ln2 = (fln2 >> (x-2)) & 31;
          int ln3 = (fln3 >> (x-2)) & 31;
          int ln4 = (fln4 >> (x-2)) & 31;
          int ln5 = (fln5 >> (x-2)) & 31;
          int ox = horizScores[ln1] + horizScores[ln2] + horizScores[ln3] + horizScores[ln4] + horizScores[ln5];
          int oy = popc5[ln1] - popc5[ln2] + popc5[ln4] - popc5[ln5];
          //int oy = -2*Integer.bitCount(ln1) - Integer.bitCount(ln2) + Integer.bitCount(ln4) + 2*Integer.bitCount(ln5);
          int fx = 1 - (ox+16)%3 + x;
          int fy = 1 - (oy+16)%3 + y;
          if ((data[fy]&setMask[fx]) != 0) n.data[y]|= setMask[x];
        }
      }
      avgs[0]+= System.nanoTime() - S;
      
      // top/bottom
      int[] uc = cellAtO(sx, sy-sz).data;
      int uu = uc[30];
      int  u = uc[31];
      int[] dc = cellAtO(sx, sy+sz).data;
      int  d = dc[0];
      int dd = dc[1];
      for (int[] is : new int[][]{
        {uu, u, data[0], data[1], data[2]         , 0},
        {    u, data[0], data[1], data[2], data[3], 1},
        {data[28], data[29], data[30], data[31], d    , 30},
        {          data[29], data[30], data[31], d, dd, 31},
      }) {
        if (is[1]==0 & is[2]==0 & is[3]==0) continue;
        for (int x = 2; x < 30; x++) {
          int ln2 = (is[1] >> (x-2)) & 31;
          int ln3 = (is[2] >> (x-2)) & 31;
          int ln4 = (is[3] >> (x-2)) & 31;
          if (ln2==0&&ln3==0&&ln4==0) continue;
          int ln1 = (is[0] >> (x-2)) & 31;
          int ln5 = (is[4] >> (x-2)) & 31;
          
          int ox = horizScores[ln1] + horizScores[ln2] + horizScores[ln3] + horizScores[ln4] + horizScores[ln5];
          int oy = -2*popc5[ln1] - popc5[ln2] + popc5[ln4] + 2*popc5[ln5];
          int fx = 1 - (ox+16)%3 + x;
          int fy = 1 - (oy+16)%3;
          if ((is[fy+2]&setMask[fx]) != 0) n.data[is[5]]|= setMask[x];
        }
      }
      avgs[1]+= System.nanoTime() - S;
      
      // left/right
      int[] lu = cellAtO(sx-sz, sy-sz).data;
      int[] lc = cellAtO(sx-sz, sy).data;
      int[] ld = cellAtO(sx-sz, sy+sz).data;
      
      int[] ru = cellAtO(sx+sz, sy-sz).data;
      int[] rc = cellAtO(sx+sz, sy).data;
      int[] rd = cellAtO(sx+sz, sy+sz).data;
      
      
      // left: take 2 LSB of L & 4 MSB of C
      
      lm[ 0] = (uc[30]&15) << 2 | lu[30]>>>30;
      lm[ 1] = (uc[31]&15) << 2 | lu[31]>>>30;
      lm[34] = (dc[ 0]&15) << 2 | ld[ 0]>>>30;
      lm[35] = (dc[ 1]&15) << 2 | ld[ 1]>>>30;
      
      // right: take 4 MSB of C &⍨ 2 LSB of R
      
      rm[ 0] = (uc[30]>>>28) | (ru[30] & 3) << 4;
      rm[ 1] = (uc[31]>>>28) | (ru[31] & 3) << 4;
      rm[34] = (dc[ 0]>>>28) | (rd[ 0] & 3) << 4;
      rm[35] = (dc[ 1]>>>28) | (rd[ 1] & 3) << 4;
        
      // top & bottom specials done. now center
      for(int i = 0; i < 32; i++) {
        lm[i+2] = (data[i]&15) << 2 | lc[i]>>>30;
        rm[i+2] = (data[i]>>>28) | (rc[i] & 3) << 4;
      }
      // quick left
      for (int y = 0; y < 32; y++) {
        int fln2 = lm[y+1];
        int fln3 = lm[y+2];
        int fln4 = lm[y+3];
        if ((fln2 | fln3 | fln4) != 0) {
          int fln1 = lm[y];
          int fln5 = lm[y+4];
          {
            int ln1 = fln1 & 31;
            int ln2 = fln2 & 31;
            int ln3 = fln3 & 31;
            int ln4 = fln4 & 31;
            int ln5 = fln5 & 31;
            int ox = horizScores[ln1]+horizScores[ln2]+horizScores[ln3]+horizScores[ln4]+horizScores[ln5];
            int oy = popc5[ln1] - popc5[ln2] + popc5[ln4] - popc5[ln5];
            int fx = 1 - (ox+16)%3;
            int fy = 1 - (oy+16)%3;
            if ((lm[y+fy+2] & setMask[fx+2]) != 0) n.data[y]|= 1;
          } {
            int ln1 = (fln1>>1) & 31;
            int ln2 = (fln2>>1) & 31;
            int ln3 = (fln3>>1) & 31;
            int ln4 = (fln4>>1) & 31;
            int ln5 = (fln5>>1) & 31;
            int ox = horizScores[ln1]+horizScores[ln2]+horizScores[ln3]+horizScores[ln4]+horizScores[ln5];
            int oy = -2*popc5[ln1] - popc5[ln2] + popc5[ln4] + 2*popc5[ln5];
            int fx = 1 - (ox+16)%3;
            int fy = 1 - (oy+16)%3;
            if ((lm[y+fy+2] & setMask[fx+3]) != 0) n.data[y]|= 2;
          }
        }
        // aand right yaay :D FINALLY YTHIS IS DONE!!
        fln2 = rm[y+1];
        fln3 = rm[y+2];
        fln4 = rm[y+3];
        if ((fln2 | fln3 | fln4) != 0) {
          int fln1 = rm[y];
          int fln5 = rm[y+4];
          {
            int ln1 = fln1 & 31;
            int ln2 = fln2 & 31;
            int ln3 = fln3 & 31;
            int ln4 = fln4 & 31;
            int ln5 = fln5 & 31;
            int ox = horizScores[ln1]+horizScores[ln2]+horizScores[ln3]+horizScores[ln4]+horizScores[ln5];
            int oy = popc5[ln1] - popc5[ln2] + popc5[ln4] - popc5[ln5];
            int fx = 1 - (ox+16)%3;
            int fy = 1 - (oy+16)%3;
            if ((rm[y+fy+2] & setMask[fx+2]) != 0) n.data[y]|= 1<<30;
          } {
            int ln1 = (fln1 >> 1) & 31;
            int ln2 = (fln2 >> 1) & 31;
            int ln3 = (fln3 >> 1) & 31;
            int ln4 = (fln4 >> 1) & 31;
            int ln5 = (fln5 >> 1) & 31;
            int ox = horizScores[ln1]+horizScores[ln2]+horizScores[ln3]+horizScores[ln4]+horizScores[ln5];
            int oy = popc5[ln1] - popc5[ln2] + popc5[ln4] - popc5[ln5];
            int fx = 1 - (ox+16)%3;
            int fy = 1 - (oy+16)%3;
            if ((rm[y+fy+2] & setMask[fx+3]) != 0) n.data[y]|= 1<<31;
          }
        }
      }
      
      avgs[2]+= System.nanoTime() - S;
      
      // post-processing
      //avgs[2]+= System.nanoTime() - S;
      
      if (data[ 0] != 0 && darkO(sx, sy-32)) news.add(new Pos(sx, sy-32));
      if (data[31] != 0 && darkO(sx, sy+32)) news.add(new Pos(sx, sy+32));
      
      if ((data[ 0]&1) == 1 && darkO(sx-32, sy-32)) news.add(new Pos(sx-32, sy-32));
      if ((data[31]&1) == 1 && darkO(sx-32, sy+32)) news.add(new Pos(sx-32, sy+32));
      if (data[ 0]      < 0 && darkO(sx+32, sy-32)) news.add(new Pos(sx+32, sy-32));
      if (data[31]      < 0 && darkO(sx+32, sy+32)) news.add(new Pos(sx+32, sy+32));
      
      boolean lf = false, rf = false, e = true; // r/l filled, empty
      for(int i : data) {
        if ((i&1)==1) lf = true;
        if (i    < 0) rf = true;
      }
      if (lf && darkO(sx-32, sy)) news.add(new Pos(sx-32, sy));
      if (rf && darkO(sx+32, sy)) news.add(new Pos(sx+32, sy));
      
      for(int i : n.data) {
        if (i != 0) {
          e = false;
          break;
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
    if (depth == 0) for (int i = 0; i < 32; i++) count+= Integer.bitCount(data[i]);
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
      if (zm < (phone? 1 : .1)) {
        optd0 = true;
        int sz4 = ceil((float) (zm*4));
        for (int y = 0; y < 32; y+= 4) {
          if (data[y] != 0 | data[y+1] != 0 | data[y+2] != 0 | data[y+3] != 0) {
            int d1 = data[y    ];
            int d2 = data[y + 1];
            int d3 = data[y + 2];
            int d4 = data[y + 3];
            for (int x = 0; x < 8; x++) {
              if ((d1&set8Mask[x]) != 0 | (d2&set8Mask[x]) != 0
                | (d3&set8Mask[x]) != 0 | (d4&set8Mask[x]) != 0
              ) g.rect((float)(zzx + (mx+x*4)*zm), (float)(zzy + (my+y)*zm), sz4, sz4);
            }
          }
        }
      } else {
        for (int y = 0; y < 32; y++) {
          if (data[y] != 0) {
            int d = data[y];
            for (int x = 0; x < 32; x++) {
              if ((d&setMask[x]) != 0) g.rect((float)(zzx + (mx+x)*zm), (float)(zzy + (my+y)*zm), sz, sz);
            }
          }
        }
      }
    }
  }
  void addTo(OutputStream s) throws IOException {
    s.write(depth);
    if (depth==0) {
      for (int y = 0; y < 32; y++) {
        for (int x = 0; x < 32; x+= 8) {
          s.write(data[y]>>>x & 0xff);
        }
      }
    } else {
      for (int i = 0; i < 64; i++) {
        sc[i].addTo(s);
      }
    }
  }
  boolean loadFrom(InputStream s) {
    try {
      int d = s.read();
      assert d%64 == depth;
      if (d >= 64) return false;
      if (d == 0) {
        for (int y = 0; y < 32; y++) {
          for (int x = 0; x < 32; x+= 8) {
            data[y]|= s.read()<<x;
          }
        }
      } else {
        for (int y = 0; y < 8; y++) {
          for (int x = 0; x < 8; x++) {
            int p = y*sw + x;
            sc[p] = new Cell(d-1, sx + x*ssz, sy + y*ssz, this);
            if (!sc[p].loadFrom(s)) sc[p] = ECell.cache[d-1];
          }
        }
      }
      return true;
    } catch(Exception e) {
      e.printStackTrace();
      return false;
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
  void set(int x, int y) {
    throw new Error("set empty");
  }
  void clr(int x, int y) {
    // pointless
  }
  boolean get(int x, int y) {
    return false;
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
