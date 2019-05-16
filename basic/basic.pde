boolean[][] map;
boolean[][] peek;
boolean[][] undo;
boolean[][][] saves;
int sz, csz;
final int R = 3;
void setup() {
  size(800,800);
  saves = new boolean[10][][];
  sz = 40;
  csz = width/sz;
  map = new boolean[sz][sz];
}
int lmx, lmy;
boolean pmousePressed;
boolean drawFilled;
boolean running, peeking, highlight, vectorf;
void draw() {
  background(#222222);
  
  if (running) map = step(map, false);
  if (peeking | vectorf) peek = step(map, false);
  
  fill(#D2D2D2);
  stroke(#222222);
  strokeWeight(1);
  for (int y = 0; y < sz; y++) {
    for (int x = 0; x < sz; x++) {
      if (map[y][x]) rect(x*csz,y*csz,csz,csz);
    }
  }
  if (peeking) {
    for (int y = 0; y < sz; y++) {
      for (int x = 0; x < sz; x++) {
        if (peek[y][x] && !map[y][x]) {
          fill(0x4400ff00);
          rect(x*csz,y*csz,csz,csz);
        }
        if (!peek[y][x] && map[y][x]) {
          fill(0x44ff0000);
          rect(x*csz,y*csz,csz,csz);
        }
      }
    }
  }
  int mx = mouseX/csz;
  int my = mouseY/csz;
  if (mousePressed && (mx != lmx || my != lmy || !pmousePressed) && mx >= 0 && my >= 0 && mx < sz && my < sz) {
    if (!pmousePressed) {
      drawFilled = !map[my][mx];
    }
    map[my][mx] = drawFilled;
    lmx = mx;
    lmy = my;
  }
  
  
  if (highlight) {
    int sx = 0;
    int sy = 0;
    for (int cy = -R; cy <= R; cy++) {
      int ry = my+cy;
      if (ry <  0) ry+= sz;
      if (ry >=sz) ry-= sz;
      for (int cx = -R; cx <= R; cx++) {
        int rx = mx+cx;
        if (rx <  0) rx+= sz;
        if (rx >=sz) rx-= sz;
        if (map[ry][rx]) {
          sx+= cx;
          sy+= cy;
        }
      }
    }
    int fx = 1 - Math.floorMod(sx+1, 3) + mx;
    if (fx <  0) fx+= sz;
    if (fx >=sz) fx-= sz;
    int fy = 1 - Math.floorMod(sy+1, 3) + my;
    if (fy <  0) fy+= sz;
    if (fy >=sz) fy-= sz;
    fill(0x660000ff);
    rect(fx*csz, fy*csz, csz, csz);
  }
  
  if (vectorf) step(map, true);
  
  pmousePressed = mousePressed;
}
boolean override;
int stepc;
void keyPressed(KeyEvent e) {
  if (key == 'h') {
    highlight^= true;
  }
  if (key == 'p') {
    peeking^= true;
  }
  if (key == 'v') {
    vectorf^= true;
  }
  // playback
  if (key == 's') {
    println(stepc++); // 575 1362 2149
    running = false;
    undo = map;
    map = step(map, false);
  }
  if (key == ' ') {
    if (!running) undo = map;
    running^= true;
  }
  if (key == 'u') {
    running = false;
    if (undo==null) println("nothing to undo!");
    else for (int y = 0; y < sz; y++) for (int x = 0; x < sz; x++) map[y][x] = undo[y][x];
  }
  
  if (key == 'r') {
    undo = map;
    map = new boolean[sz][sz];
    for (int y = 0; y < sz; y++) for (int x = 0; x < sz; x++) map[y][x] = Math.random()>.5;
  }
  if (key == 'e') {
    undo = map;
    running = false;
    map = new boolean[sz][sz];
  }
  // saves
  if (key == 'o') {
    override^= true;
    if (override) println("enabled save writing");
    else println("disabled save override");
  }
  if (key >= '0' && key <= '9') {
    int s = key-'0';
    if (override) {
      override = false;
      saves[s] = new boolean[sz][sz];
      for (int y = 0; y < sz; y++) for (int x = 0; x < sz; x++) saves[s][y][x] = map[y][x];
      println("saved save "+s);
    } else if (saves[s] != null) {
      undo = map;
      running = false;
      map = new boolean[sz][sz];
      for (int y = 0; y < sz; y++) for (int x = 0; x < sz; x++) map[y][x] = saves[s][y][x];
      println("loaded save "+s+". undo with u");
    } else println("there's nothing saved in "+s);
  }
}
