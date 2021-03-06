/*
automaton thisa = this;
void settings() {
  //fullScreen(P2D);
  noSmooth();
}
static final boolean phone = true;
void mouseActions() {
  int px = (int) (mouseX/zm + dsx);
  int py = (int) (mouseY/zm + dsy);
  if (touches.length > 0) {
    if (mouseY < 130) {
      for(Button b : btns) {
        if (mouseX >= b.x & mouseY >= b.y && b.x+b.w > mouseX && b.y+b.h > mouseY && (!pmp || b.hl)) {
          b.click();
        }
      }
    } else if (touches.length == 1) {
      if (edit) {
        
        if (drawOn) board.set(px, py);
        else board.clr(px, py);
      } else {
        dsx+= ((float)pmouseX-mouseX)/zm;
        dsy+= ((float)pmouseY-mouseY)/zm;
      }
    } else {
      float ow = dist(touches[0].x, touches[0].y, touches[1].x, touches[1].y);
      float sc = ow/fullow;
      float avgX = (touches[0].x + touches[1].x) / 2f;
      float avgY = (touches[0].y + touches[1].y) / 2f;
      if (fullow != 0) {
        double pS = zm;
        zm*= sc;
        double scalechange = 1/zm - 1/pS;
        dsx-= (avgX * scalechange);
        dsy-= (avgY * scalechange);
        dsx+= (pax-avgX)/zm;
        dsy+= (pay-avgY)/zm;
      }
      pax = avgX;
      pay = avgY;
      fullow = ow;
    }
  }
  if (touches.length != 2) fullow = 0;
}
String getClip() {
  TODO
}
/*/
automaton thisa = this;
void settings() {
  noSmooth();
  size(900, 800);
}
static final boolean phone = false;
void mouseActions() {
  if (mousePressed && mouseButton == CENTER) {
    dsx+= ((float)pmouseX-mouseX)/zm;
    dsy+= ((float)pmouseY-mouseY)/zm;
  }
  if (mousePressed && mouseButton == LEFT && !playing) {
    int px = (int) (mouseX/zm + dsx);
    int py = (int) (mouseY/zm + dsy);
    if (mousePressed && !pmp) {
      drawOn = !board.get(px, py);
    }
    if (drawOn) board.set(px, py);
    else board.clr(px, py);
    modified();
    sxS = exS = syS = eyS = 0;
  }
  if (mousePressed && mouseButton == RIGHT && !playing) {
    int px = (int) (mouseX/zm + dsx);
    int py = (int) (mouseY/zm + dsy);
    if (pmp) {
      exS = px;
      eyS = py;
    } else {
      sxS = px;
      syS = py;
    }
  }
}
void mouseWheel(MouseEvent e) {
  double sc = e.getCount()==1? .8 : 1/.8;
  double pS = zm;
  zm*= sc;
  double scalechange = 1/zm - 1/pS;
  dsx-= (mouseX * scalechange);
  dsy-= (mouseY * scalechange);
}
boolean doSpeedTest = false;
MainCell[] sv = new MainCell[10];
File last = new File(new JFileChooser().getFileSystemView().getDefaultDirectory().toString()+"/save.bin");


void keyPressed(KeyEvent e) {
  println(+key, keyCode);
  if (key >= ' ' && key <= '~' && keyCode >= '0' && keyCode <= '9') {
    if (e.isShiftDown()) {
      sv[keyCode-'0'] = board.copy();
    } else {
      if (sv[keyCode-'0'] != null) toBoard = sv[keyCode-'0'].copy();
    }
  }
  if (key == 'q') {
    fast = true;
  }
  if (key == 'z') {
    if (undo != null) toBoard = undo.copy();
  }
  if (key == ' ') {
    playing^= true;
  }
  if (key == 'f') {
    saveStrings("f.rle", new String[]{"x = 0, y = 0", getRLE(board)});
  }
  if (key == 'r') {
    String s = getClip();
    MainCell c = loadRLE(s);
    if (c != null) board = c;
  }
  if (key == 's') {
    playing = false;
    step();
  }
  if (key == 'j') {
    doSpeedTest = true;
    playing = false;
  }
  if (key == 19 && keyCode == 83 && e.isControlDown()) {
    selectOutput("Choose save location", "saveF", last);
  }
  if (key == 15 && keyCode == 79 && e.isControlDown()) {
    selectInput("Choose save location", "loadF", last);
  }
  if (key == '+') speed*= 2;
  if (key == '-') speed/= 2;
  if (speed < 1) speed = 1;
  if (speed == 2) speed = 3;
  if (speed == 6) speed = 7;
  if (speed == 14) speed = 15;
  lns = nanos();
  println(speed);
}

String getClip() {
  try {
    return (String) Toolkit.getDefaultToolkit().getSystemClipboard().getData(DataFlavor.stringFlavor);
  } catch (Throwable e) {
    e.printStackTrace();
    return "";
  }
}

void loadF(File f) {
  if (f == null) return;
  last = f;
  try {
    loadCB(new FileInputStream(f));
    modified();
  } catch (FileNotFoundException e) {
    e.printStackTrace();
  }
}
void saveF(File f) {
  if (f == null) return;
  last = f;
  try {
    saveCB(new FileOutputStream(f));
  } catch (FileNotFoundException e) {
    e.printStackTrace();
  }
}
//*/
