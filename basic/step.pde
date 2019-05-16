boolean[][] step(boolean[][] map, boolean vf) {
  if (vf) {
    strokeWeight(2);
  }
  boolean[][] nmap = new boolean[sz][sz];
  for (int y = 0; y < sz; y++) {
    for (int x = 0; x < sz; x++) {
      
      int sx = 0;
      int sy = 0;
      
      for (int cy = -R; cy <= R; cy++) {
        int ry = y+cy;
        if (ry <  0) ry+= sz;
        if (ry >=sz) ry-= sz;
        for (int cx = -R; cx <= R; cx++) {
          int rx = x+cx;
          if (rx <  0) rx+= sz;
          if (rx >=sz) rx-= sz;
          if (map[ry][rx]) {
            sx+= cx;
            sy+= cy;
          }
        }
      }
      int fx = 1 - Math.floorMod(sx+1,3) + x;
      int fy = 1 - Math.floorMod(sy+1,3) + y;
      
      if (vf) {
        int fxm = fx;
        int fym = fy;
        if (fxm <  0) fxm+= sz;
        if (fxm >=sz) fxm-= sz;
        
        if (fym <  0) fym+= sz;
        if (fym >=sz) fym-= sz;
        if (map[y][x] != map[fym][fxm] || x!=fxm || y!=fym) {
          if (map[y][x] == map[fym][fxm]) stroke(0x22555555);
          else stroke(#7777ff);
          float d = atan2(x-fx, y-fy);
          float dsx = csz*(x+.5);
          float dsy = csz*(y+.5);
          float dex = csz*(fx+.5);
          float dey = csz*(fy+.5);
          line(dsx, dsy, dex + sin(d)*csz/4, dey + cos(d)*csz/4);
          line(dsx, dsy, dsx + sin(d+DEG_TO_RAD* 140)*csz/4, dsy + cos(d+DEG_TO_RAD* 140)*csz/4);
          line(dsx, dsy, dsx + sin(d+DEG_TO_RAD*-140)*csz/4, dsy + cos(d+DEG_TO_RAD*-140)*csz/4);
        }
      }
      
      if (fx <  0) fx+= sz;
      if (fx >=sz) fx-= sz;
      
      if (fy <  0) fy+= sz;
      if (fy >=sz) fy-= sz;
      
      nmap[y][x] = map[fy][fx];
    }
  }
  return nmap;
}
