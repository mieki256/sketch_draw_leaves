// Last updated: <2024/11/01 20:10:08 +0900>
//
// Draw leaves
//
// request library : ControlP5
//
// by mieki256
// License: CC0

import controlP5.*;

int[] fps_list = new int[]{ 24, 12, 8 };  // framerate list
int fps_kind = 0;

int leaf_max = 5000;             // leaf number max
float def_base_ang = 90 + 45;    // leaf base angle
float def_spd = 0.03;            // animation speed

int leaf_oneshot_max = 10;
float rmax = 100;

boolean tint_sort = true;
// boolean tint_sort = false;

PImage img;
PImage img2;
PGraphics pg;

boolean resetfg = false;
boolean exitfg = false;
boolean textfg = true;
boolean saveframe_enable =  false;

int imgkind = 0;
int leaf_index = 0;
int sframecount = 0;
int scrw;
int scrh;

Leaf[] leaves = new Leaf[leaf_max];

ControlP5 cp5;
Slider slider_ba;
Slider slider_spd;
Slider slider_omax;

void setup() {
  fullScreen(P2D);
  // size(1280, 720, P2D);
  // size(1600, 900, P2D);

  scrw = width;
  scrh = height;
  // println("size=(" + scrw + ", " + scrh + ")");

  img = loadImage("./leaf.png");
  img2 = loadImage("./leaf2.png");
  imgkind = 0;
  pg = createGraphics(scrw, scrh, P2D);
  leaf_index = 0;
  frameRate(fps_list[fps_kind]);

  // init ControlP5 (GUI library)
  cp5 = new ControlP5(this);
  PFont myfont = createFont("Arial", 14, true);
  ControlFont cf1 = new ControlFont(myfont, 14);
  float y = 160;

  slider_spd = cp5.addSlider("speed")
    .setRange(0.1, 2.0)
    .setValue(1.0)
    .setPosition(10, y)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1);

  slider_ba = cp5.addSlider("angle")
    .setRange(0, 180)
    .setValue(def_base_ang)
    .setPosition(10, y + 40)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1)
    .setNumberOfTickMarks(9);

  slider_omax = cp5.addSlider("number of")
    .setRange(1, 50)
    .setValue(leaf_oneshot_max)
    .setPosition(10, y + 80)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1);
}

void draw() {
  float tx = 8;
  float td = 20;
  
  background(56, 108, 220);

  if (resetfg) {
    leaf_index = 0;
    resetfg = false;
  }

  if (leaf_index > 0) {
    float speed = slider_spd.getValue();
    for (int i = 0; i < leaf_index; i++) {
      leaves[i].update(speed);
    }

    if (saveframe_enable) {
      // draw leaves to PGraphics
      pg.beginDraw();
      pg.clear();
      for (int i = 0; i < leaf_index; i++) {
        leaves[i].draw2pg(pg);
      }
      pg.endDraw();

      image(pg, 0, 0);  // draw PGraphics to window

      String fn = "frames/" + get_consecutive(sframecount, 8) + ".png";

      // draw capture message
      noStroke();
      fill(255);
      text("save frame : " + fn, tx, 2 * td);

      pg.save(fn);  // save PGraphics to png image
      sframecount++;
    } else {
      // draw leaves to window
      for (int i = 0; i < leaf_index; i++) {
        leaves[i].draw();
      }
    }
  }

  // draw text
  if (textfg) {
    noStroke();
    fill(255);
    textSize(16);
    if (leaf_index == 0) {
      text("Leaf: " + leaf_index + ". Please click", tx, 1 * td);
    } else {
      text("Leaf: " + leaf_index, tx, 1 * td);
    }
    text("Q,ESC: Exit / R: Reset / T: Text on/off / S: Save frames", tx, 4 * td);
    text("C: Change image [" + imgkind + "] / F: Framerate [" + fps_list[fps_kind] + " fps]", tx, 5 * td);
  }

  if (exitfg) exit();
}

void mouseClicked() {
  set_leaves(mouseX, mouseY, ((imgkind == 0)? img : img2));
}

void keyPressed() {
  if (key == CODED) {
  } else {
    switch (key) {
    case 'r':  // reset
      resetfg = true;
      break;
    case 'c':  // change image
      imgkind = (imgkind + 1) % 2;
      break;
    case 't':  // text on/off
      textfg = !textfg;
      if (textfg) {
        cp5.show();
      } else {
        cp5.hide();
      }
      break;
    case 'f': // change framerate
      fps_kind = (fps_kind + 1) % 3;
      frameRate(fps_list[fps_kind]);
      break;
    case 's':  // fave frames
      saveframe_enable = !saveframe_enable;
      sframecount = 0;
      break;
    case 'q':  // exit
      exitfg = true;
      break;
    }
  }
}

void set_leaf(int i, PImage img, float bx, float by, float tintv) {
  float r = random(rmax);
  float ang = random(360.0);
  float x = bx + r * cos(radians(ang));
  float y = by + r * sin(radians(ang));
  float rv = random(65536);
  float spd = def_spd;
  float base_ang = slider_ba.getValue();
  leaves[i] = new Leaf(img, x, y, rv, spd, tintv, base_ang);
}

void set_leaves(float bx, float by, PImage img) {
  int n = int(slider_omax.getValue());
  for (int i = 0; i < n; i++) {
    float tintv = 255 - (180 * (n - i) / n);
    if (leaf_index >= leaf_max) break;
    set_leaf(leaf_index, img, bx, by, tintv);
    leaf_index++;
  }

  if (tint_sort) {
    // leaves tint sort
    for (int i = 0; i < leaf_index; i++) {
      leaves[i].set_tintv(255.0 - 180.0 * (leaf_index - i) / leaf_index);
    }
  }
}

String get_consecutive(int n, int k) {
  String s = "000000000000" + n;
  return s.substring(s.length() - k);
}

// ----------------------------------------
// leaf class

class Leaf {
  PImage img;
  float bx;
  float by;
  float tm;
  float spd;
  float tintv;
  float base_ang;
  float x;
  float y;
  float ang;

  Leaf(PImage src_img, float basex, float basey, float tm0, float speed, float tv0, float bs_ang) {
    img = src_img;
    bx = basex;
    by = basey;
    tm = tm0;
    spd = speed;
    tintv = tv0;
    base_ang = bs_ang;
    x = 0.0;
    y = 0.0;
    ang = 0.0;
  }

  void set_tintv(float v) {
    tintv = v;
  }

  void update(float speed) {
    x = -(100.0 * noise(tm * spd * speed));
    y = -(50.0 * noise(tm * spd * speed));
    float a = 75.0;
    ang = base_ang + a * noise(tm * spd * speed) - (a / 2);
    tm += 1.0;
  }

  void draw() {
    push();
    translate(bx, by);
    translate(x, y);
    rotate(radians(ang));
    tint(tintv);
    image(img, 0, -img.height / 2);
    pop();
  }

  void draw2pg(PGraphics pg) {
    pg.push();
    pg.translate(bx, by);
    pg.translate(x, y);
    pg.rotate(radians(ang));
    pg.tint(tintv);
    pg.image(img, 0, -img.height / 2);
    pg.pop();
  }
}
