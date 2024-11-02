// Last updated: <2024/11/02 23:23:12 +0900>
//
// Draw leaves and animation
//
// request library : ControlP5
//
// by mieki256
// License: CC0

import controlP5.*;

int[] fps_list = new int[]{ 24, 12, 8 };  // framerate list
int fps_kind = 0;

int leaf_max = 5000;          // leaf number max
float def_ang = -45.0;        // leaf base angle
float def_spd = 0.03;         // animation speed
float def_rot_range = 75.0;
float def_brushsize = 100;
float brushsize_max = 300.0;

boolean tint_sort = true;
// boolean tint_sort = false;

PImage img;
PImage img2;
PImage bgimg;
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
Slider slider_spd;
Slider slider_shakex;
Slider slider_shakey;
Slider slider_rotrange;
Slider slider_baseang;
Slider slider_bsize;

float dis_x0;
float dis_y0;
float dis_x1;
float dis_y1;

float shakingx = 100.0;
float shakingy = 50.0;

void setup() {
  // fullScreen(P2D);
  // size(1280, 720, P2D);
  size(1600, 900, P2D);

  scrw = width;
  scrh = height;
  // println("size=(" + scrw + ", " + scrh + ")");

  img = loadImage("./leaf.png");
  img2 = loadImage("./leaf2.png");
  bgimg = loadImage("./bg.png");
  imgkind = 0;
  pg = createGraphics(scrw, scrh, P2D);
  leaf_index = 0;
  frameRate(fps_list[fps_kind]);

  // init ControlP5 (GUI library)
  cp5 = new ControlP5(this);
  PFont myfont = createFont("Arial", 14, true);
  ControlFont cf1 = new ControlFont(myfont, 14);
  float x = 10;
  float y = 160;
  float yd = 40;
  float w = 180;

  slider_spd = cp5.addSlider("speed")
    .setRange(0.1, 2.0)
    .setValue(1.0)
    .setPosition(x, y + 0 * yd)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1);

  slider_shakex = cp5.addSlider("shaking x")
    .setRange(0.0, 300.0)
    .setValue(shakingx)
    .setPosition(x, y + 1 * yd)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1);

  slider_shakey = cp5.addSlider("shaking y")
    .setRange(0.0, 300.0)
    .setValue(shakingy)
    .setPosition(x, y + 2 * yd)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1);

  slider_rotrange = cp5.addSlider("rot range")
    .setRange(0.0, 180.0)
    .setValue(def_rot_range)
    .setPosition(x, y + 3 * yd)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1);

  slider_baseang = cp5.addSlider("set angle")
    .setRange(-90, 90)
    .setValue(def_ang)
    .setPosition(x, y + 4 * yd)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1)
    .setNumberOfTickMarks(9);

  slider_bsize = cp5.addSlider("brush size")
    .setRange(1, brushsize_max)
    .setValue(def_brushsize)
    .setPosition(x, y + 5 * yd)
    .setSize(180, 20)
    .setColorForeground(color(0, 160, 0))
    .setColorActive(color(0, 200, 0))
    .setFont(cf1);

  // Set area to disable brush
  float pad = 32;
  dis_x0 = x - pad;
  dis_y0 = y - pad;
  dis_x1 = x + w + 3 * pad;
  dis_y1 = y + 6 * yd + pad;
}

void draw() {
  boolean brush_enable = true;
  shakingx = slider_shakex.getValue();
  shakingy = slider_shakey.getValue();
  String savemes = "";

  background(56, 108, 220);

  imageMode(CORNER);
  image(bgimg, 0, 0, scrw, scrh);

  if (resetfg) {
    leaf_index = 0;
    resetfg = false;
  }

  if (keyPressed) {
    if (key == 'z') {
      // Undo
      leaf_index--;
      if (leaf_index < 0) leaf_index = 0;
      sort_leaves_tint();
    }
  }

  float mx = mouseX;
  float my = mouseY;
  if (textfg) {
    if (dis_x0 <= mx && mx <= dis_x1 && dis_y0 <= my && my <= dis_y1) brush_enable = false;
  }

  if (brush_enable && mousePressed) {
    if (mouseButton == LEFT) {
      set_leaves(mx, my, ((imgkind == 0)? img : img2));
    }
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
      savemes = "save frame : " + fn;

      pg.save(fn);  // save PGraphics to png image
      sframecount++;
    } else {
      // draw leaves to window
      for (int i = 0; i < leaf_index; i++) {
        leaves[i].draw();
      }
      savemes = "";
    }
  }

  // draw brush size
  if (brush_enable) {
    float bsize = slider_bsize.getValue();
    strokeWeight(1);
    stroke(255, 255, 255, 255);
    noFill();
    ellipse(mouseX, mouseY, bsize * 2, bsize * 2);
  }

  // draw text
  if (textfg) {
    draw_message(savemes);
    draw_brush_preview();
  }

  if (exitfg) exit();
}

void draw_message(String savemes) {
  float tx = 8;
  float td = 20;
  noStroke();
  fill(255);
  textSize(16);

  String mes = "Leaf: " + leaf_index;
  if (leaf_index == 0) mes += " ... Please mouse button press";
  text(mes, tx, 1 * td);
  text(savemes, tx, 2 * td);
  text("Q,ESC: Exit / R: Reset / Z: Undo / T: Text on/off / S: Save frames", tx, 4 * td);
  text("C: Change image [" + imgkind + "] / F: Framerate [" + fps_list[fps_kind] + " fps]", tx, 5 * td);
  text("Wheel: Brush size", tx, 6 * td);
}

void draw_brush_preview() {
  float w = 128;
  float x = 0;
  float y = scrh - w - 1;

  // fill background
  rectMode(CORNER);
  noStroke();
  fill(0, 64);
  rect(x, y, w, w);

  // draw brush image
  imageMode(CORNER);
  noTint();
  image((imgkind == 0)? img : img2, x, y, w, w);

  // draw border
  rectMode(CORNER);
  stroke(255);
  strokeWeight(1);
  noFill();
  rect(x, y, w, w);

  // draw text
  noStroke();
  fill(255);
  text("Brush image", x, y - 6);
}

void mouseWheel(MouseEvent ev) {
  float f = ev.getCount();
  f *= -1.0;
  change_brush_size(f);
}

void change_brush_size(float f) {
  float bsize = slider_bsize.getValue();
  if ( f < 0) {
    bsize -= 10.0;
  } else if (f > 0.0) {
    bsize += 10.0;
  }
  if (bsize < 1.0) bsize = 1.0;
  if (bsize >= brushsize_max) bsize = brushsize_max;
  slider_bsize.setValue(bsize);
}

void keyPressed() {
  if (key == CODED) {
  } else {
    switch (key) {
    case 'c':  // change image
      imgkind = (imgkind + 1) % 2;
      break;
    case 'f': // change framerate
      fps_kind = (fps_kind + 1) % 3;
      frameRate(fps_list[fps_kind]);
      break;
    case 's':  // fave frames
      saveframe_enable = !saveframe_enable;
      sframecount = 0;
      break;
    case 'r':  // reset
      resetfg = true;
      break;
    case 't':  // text on/off
      textfg = !textfg;
      if (textfg) cp5.show();
      else cp5.hide();
      break;
    case 'q':  // exit
      exitfg = true;
      break;
    }
  }
}

void set_leaves(float bx, float by, PImage img) {
  if (leaf_index >= leaf_max) return;

  float tintv = 255;
  float ang = -1.0 * slider_baseang.getValue();
  set_leaf(leaf_index, img, bx, by, tintv, ang);
  leaf_index++;

  if (tint_sort) sort_leaves_tint();
}

void set_leaf(int i, PImage img, float bx, float by, float tintv, float ang) {
  float bsize = slider_bsize.getValue();
  float r = random(bsize);
  float a = random(360.0);
  float x = bx + r * cos(radians(a));
  float y = by + r * sin(radians(a));
  float rv = random(65536);
  float spd = def_spd;
  float base_ang = ang;
  leaves[i] = new Leaf(img, x, y, rv, spd, tintv, base_ang);
}

void sort_leaves_tint() {
  if (leaf_index > 0) {
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
    float n0 = noise(tm * spd * speed);
    float a = slider_rotrange.getValue();
    ang = base_ang + (a * n0) - (a / 2);

    float n1 = noise(tm * spd * speed * 0.8);
    float n2 = noise(tm * spd * speed * 0.6);
    if (false) {
      float dx = -1.0 * shakingx * (n1 - 0.5);
      float dy = shakingy * (n2 - 0.5);
      float ra = radians(base_ang);
      x = dx * cos(ra) - dy * sin(ra);
      y = dx * sin(ra) + dy * cos(ra);
    } else {
      x = -1.0 * shakingx * (n1 - 0.5);
      y = shakingy * (n2 - 0.5);
    }

    tm += 1.0;
  }

  void draw() {
    push();
    imageMode(CORNER);
    translate(bx + x, by + y);
    rotate(radians(ang));
    tint(tintv);
    image(img, -img.width / 2, 0);
    pop();
  }

  void draw2pg(PGraphics pg) {
    pg.push();
    pg.imageMode(CORNER);
    pg.translate(bx + x, by + y);
    pg.rotate(radians(ang));
    pg.tint(tintv);
    pg.image(img, -img.width / 2, 0);
    pg.pop();
  }
}
