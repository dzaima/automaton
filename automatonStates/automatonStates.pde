import java.util.concurrent.atomic.AtomicInteger;
import java.text.DecimalFormat;
import java.util.*;
MainCell board;
Button[] btns = new Button[8];
static final int POWER = 5;
static int SZ = 32;
static {
  for (int i = 0; i < POWER; i++) SZ*= Cell.sw;
}
static final int HSZ = SZ/2;
static double dsx = HSZ, dsy = HSZ; // top left of screen; drawing start x/y
void setup() {
  board = new MainCell(POWER, 0, 0);
  
  btns[0] = new Button(20,20,100,100,"→") {
    public void click() {
      playing^= true;
    }
  };
  btns[1] = new Button(130,20,100,100,"g") {
    public void click() {
      step();
    }
  };
  btns[2] = new Button(240,20,100,100,"F",true) {
    public void click() {
      fast = true;
    }
  };
  btns[3] = new Button(350,20,100,100,"E") {
    public void click() {
      edit^= true;
      t = edit? "M" : "E";
    }
  };
  btns[4] = new Button(460,20,100,100,"+") {
    public void click() {
      speed*= 2;
      if (speed < 1) speed = 1;
      if (speed == 2) speed = 3;
      if (speed == 6) speed = 7;
      if (speed == 14) speed = 15;
    }
  };
  btns[5] = new Button(570,20,100,100,"-") {
    public void click() {
      speed/= 2;
    }
  };
  
  for(int x = 0; x < 256; x++) {
    for(int y = 0; y < 256; y++) {
      if(random(2)>1) board.set(HSZ+x,HSZ+y, (byte)(1+random(7)));
    }
  }
  thread("runThread");
}




static int dex, dey;
static double zm = 30; // pixels per block
boolean pmp;
boolean drawOn, playing, fast, edit;
long lns;
float fullow;
double pax, pay;
long speed = 60;
long nanos() {
  return System.nanoTime();
}
static int[] COLORS = {0, #ffffff, #ff0000, #00ff00, #0000ff, #ffff00, #00ffff, #ff00ff};


static int d0c, doc, dot; // depth 0 count, depth other count, depth others touched
static boolean optd0; // optimized depth 0
void draw() {
  mouseActions();
  
  background(34);
  if (zm>5) strokeWeight(phone? 2 : 1);
  else noStroke();
  dex = min((int) Math.ceil(dsx + width/zm), board.sz);
  dey = min((int) Math.ceil(dsy + height/zm), board.sz);
  double zzx = -dsx*zm;
  double zzy = -dsy*zm;
  
  
  d0c = doc = dot = 0;
  optd0 = false; // optimized depth 0
  board.draw(g, 0, 0, zzx, zzy);
  
  
  if (phone) for (Button b : btns) b.draw();
  fill(#D2D2D2);
  textSize(phone? 30 : 15);
  textAlign(RIGHT, TOP);
  text(info2, width-20, 20);
  text(info1, width-150, 20);
  textAlign(LEFT, BOTTOM);
  text(info3, 20, height-20);
  text("d0c "+d0c+"   doc "+doc+"   dot "+dot + (optd0? " O" : ""), width*.4, height-20);
  textAlign(RIGHT, BOTTOM);
  text(frameRate, width-20, height-20);
  pmp = mousePressed;
}
