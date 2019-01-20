// WAVEY WAVES
// Gustav Neustadt
// Controll the waves with your Mouse | press the q key to save the current state as pdf and quit the sketch.
// You can change the the amount of lines through the maxParticles variable.

import processing.pdf.*;

Particle[] particles;
PVector mouse;
int maxParticles;
void setup() {
    maxParticles = 1000;
    particles = new Particle[maxParticles];
    colorMode(HSB, 360, 100, 100);
    // color = color(random(0, 360), random(0, 100), random(0, 100));
    mouse = new PVector(mouseX, mouseY);
    size(500, 500);
    beginRecord(PDF, "pdf.pdf");
    frameRate(100);
    for (int i = 0; i < maxParticles; i++) {
        particles[i] = new Particle();
    }
}

void draw() {
    // color = hue(map(mouseX, 0, width, 0, 360));
    strokeWeight(1);
    noFill();
    println(sin(frameCount / 360) * 180 + 180);
    mouse = new PVector(mouseX, mouseY);
    for (int i = 0; i < maxParticles; i++) {
        particles[i].display();
    }
}

void keyPressed() {
  if (key == 'q') {
    endRecord();
    exit();
  }
}

class Particle {
    PVector position;
    PVector oldPosition;
    PVector velocity;
    PVector velocityPerFrame;
    PVector acceleration;
    PVector particleColor;
    float speed;
    float brightness;

    Particle() {
        this.position = new PVector(0, 0);
        this.oldPosition = new PVector(0, 0);
        this.velocity = new PVector(0, 0);
        this.velocityPerFrame = new PVector(0, 0);
        this.acceleration = new PVector(0, 0);
        this.speed = random(1, 10);
        this.particleColor = new PVector();
        // this.particleColor = new PVector(map(this.position.x, 0, width, 0, 360), map(this.position.y, 0, height, 0, 100), 100);
        this.brightness = random(0, 100);
    }

    void display() {
        this.particleColor.x = sin(frameCount / 360.00) * 180.00 + 180;
        this.particleColor.y = map(PVector.sub(mouse, this.position).mag(), 0, width / 2, 100, 50);
        this.particleColor.z = map(this.velocity.mag(), 0, 300, 100, 70);
        this.move();
        stroke(this.particleColor.x, this.particleColor.y, this.particleColor.z);
        this.connectV(PVector.sub(this.position, this.velocityPerFrame), this.position);
    }
    void connectV(PVector p1, PVector p2) {
        line(p1.x, p1.y, p2.x, p2.y);
    }
    void move() {
        this.acceleration = PVector.sub(mouse, this.position).limit(this.speed);
        this.velocity.add(this.acceleration);
        this.velocity.limit(300);
        this.velocityPerFrame = PVector.div(this.velocity, 100);
        this.position.add(this.velocityPerFrame);
        // console.log(this.oldPosition.y, this.position.y);
        // this.oldPosition = this.position;

    }
}
