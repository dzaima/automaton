abstract class Button {
  int x, y, w, h;
  String t;
  boolean hl;
  Button(int x, int y, int w, int h, String t) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.t=t;
  }
  Button(int x, int y, int w, int h, String t, boolean hl) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.t=t;
    this.hl=hl;
  }
  void draw() {
    fill(#333333);
    noStroke();
    textSize(70);
    rect(x, y, w, h);
    textAlign(CENTER, CENTER);
    fill(#D2D2D2);
    text(t, x+w/2, y+h/2);
  }
  abstract void click();
}