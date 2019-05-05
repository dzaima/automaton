AtomicInteger askedSteps = new AtomicInteger();
void runThread() {
  while(true) {
    long ns = nanos();
    if (toBoard != null) {
      board = toBoard;
      toBoard = null;
      playing = false;
      doSpeedTest = false;
      fast = false;
      askedSteps.set(0);
    }
    try {
      while (askedSteps.get() > 0) {
        actualStep();
        askedSteps.decrementAndGet();
        //if (askedSteps.get() > 10) askedSteps.set(10);
      }
      
      if (fast) {
        while (nanos()-ns < 300*1000000L) actualStep();
        fast = false;
      }
      
      if (doSpeedTest) {
        while(gen < 3000) {
          actualStep();
        }
        ns = nanos();
        avgavg = new long[5];
        for(int i = 0; i < 3000; i++) {
          actualStep();
        }
        doSpeedTest = false;
        println("SPEED TEST: " + (System.nanoTime() - ns));
        println(Arrays.toString(avgavg));
        //11266225296
        //11324779169
        //
      }
      
      if (playing) {
        long frame = (long) (1000000000L/speed);
        while (ns > lns + frame && nanos() <= ns+100*1000000L) {
          actualStep();
          lns+= frame;
        }
        if (nanos() > ns+100*1000000L) {
          lns = ns;
        }
      } else lns = ns;
    } catch (Exception e) {
      e.printStackTrace();
      info3 = e.toString();
      askedSteps.set(0);
      playing = false;
      fast = false;
      delay(1000);
    }
    delay(1);
  }
}

long[] avgavg = new long[5];
void actualStep() {
  avgs = new long[5];
  long ns = System.nanoTime();
  board = step(board);
  ns = System.nanoTime() - ns;
  
  int c1 = board.count1();
  float cps = 32*32*c1*(1000000000f/ns); // cells per second
  if(c1==0)return;
  avgs[4]-= avgs[3];
  avgs[3]-= avgs[2];
  avgs[2]-= avgs[1];
  avgs[1]-= avgs[0];
  info3 = "gen="+gen+"    pop="+board.count()+"    D1pop="+c1+"    "+int(cps)+" cells/s     "+String.format("%.2f", ns/1000000f)+"ms\n" + String.format("%.2f", 1000000000f/ns) + "ups    "+(String.format("%.2f", 1000000000d / cps))+" ns/cell";
  int[] acc = new int[]{28*28, 28*4, 32*4, 32*32};
  info1 = info2 = "";
  for(int i = 0; i < 4; i++) {
    long p100 = avgs[i]*100 / c1;
    avgavg[i]+= p100;
    info1+= p100 + "\n";
    info2+= p100/acc[i] + "\n";
  }
  gen++;
}



static int gen = 0;
static long[] avgs = new long[5];
String info1 = "", info2 = "", info3 = "";
void step() {
  askedSteps.incrementAndGet();
}
