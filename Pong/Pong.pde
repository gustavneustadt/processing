// P0NG, Safe the Muffins!
// Gustav Neustadt
// Safe the muffins or die!
// Controll the shield with your mouse

import processing.sound.*;

SoundFile bounce;
Player playerOne;
Ball ball;
int framesPerSec = 500;
Friends friends;
float score;
float highScore;
float lastTime;
PFont font;
PImage backgroundImage;

void setup() {

	backgroundImage = new PImage();
	backgroundImage = loadImage("Earth.png");

	size(800, 500);
	frameRate(framesPerSec);
	playerOne = new Player();
	ball = new Ball();
	bounce = new SoundFile(this, "ballCollide.mp3");
	friends = new Friends();
	font = createFont("Nasalization.ttf", 20);
}

void draw() {
	textFont(font);
	background(33, 31, 27);
	image(backgroundImage, width / 2, height / 2, (backgroundImage.width / backgroundImage.height) * height, height);

	if(score < 0) {
		text("GAME OVER!", ((width - textWidth("GAME OVER!")) / 2), height / 2);
		noLoop();
	}
	playerOne.display();
	ball.display();
	friends.display();
	collidePlayer();

	fill(255);
	// text(int(frameRate), 0, 20);
	score += (millis() - lastTime) / 10;
	highScore = (score > highScore) ? score : highScore;
	text("Highscore: " + int(highScore), 20, 20);
	text("Score: " + int(score), width - 200, 20);
	collideFriends();
	lastTime = millis();

}
void collideFriends() {
	for(int i = 0; i < friends.friends.length; i++) {
		float dist = PVector.dist(friends.friends[i].location, ball.location);
		if(dist <= friends.friends[i].radius + ball.radius) {

			friends.friends[i].kill();
		}

	}
}

void collidePlayer() {
	PVector test = new PVector();
	if(ball.location.y >= playerOne.location.y + playerOne.size.y / 2) 		{ test.y = (playerOne.location.y + playerOne.size.y / 2); } // check edge bottom
	else if(ball.location.y < playerOne.location.y - playerOne.size.y / 2) { test.y = (playerOne.location.y - playerOne.size.y / 2); } // check edge top
	if(ball.location.x >= playerOne.location.x + playerOne.size.x / 2) 		{ test.x = (playerOne.location.x + playerOne.size.x / 2); } // check edge right
	else if(ball.location.x < playerOne.location.x - playerOne.size.x / 2)	{ test.x = (playerOne.location.x - playerOne.size.x / 2); } // check edge left 

	PVector dist = new PVector();
	dist.x = (test.x > 0) ? ball.location.x - test.x : 0;
	dist.y = (test.y > 0) ? ball.location.y - test.y : 0;

	if(dist.mag() <= ball.radius ) {
		playerOne.hitCount += 1;
		float yDiff = ball.location.y - playerOne.location.y;
		ball.velocity.setMag(ball.velocity.mag()*1.01);
		ball.collide("VERTICAL", map(yDiff, -50, 50, -20, 20));

	} else {
		ball.enteredCollision = false;
	}
}

class Player {
	PVector location;
	PVector velocity;
	PVector size;
	int hitCount;

	PImage playerImg = new PImage();
	Player() {
		playerImg = loadImage("player.png");
		velocity = new PVector(200, 250);
		location = new PVector(width/2, height / 2);
		size = new PVector(10, 50);
	}
	void move() {           
		PVector velocityPerFrame = new PVector();
		PVector mouseLocation = new PVector(mouseX, mouseY);
		PVector mousePlayer = PVector.sub(mouseLocation, location);
		velocityPerFrame = PVector.div(velocity, frameRate);

		if( abs(mousePlayer.x) > abs(velocityPerFrame.x)) {
			location.x += normNum(mousePlayer.x) * velocityPerFrame.x;
		}
		if( abs(mousePlayer.y) > abs(velocityPerFrame.y)) {
			location.y += normNum(mousePlayer.y) * velocityPerFrame.y;
		}
	}
	void display() {
		move();
		rectMode(CENTER);
		imageParams(playerImg, location.x, location.y, 0, size.x, size.y);
		// rect(location.x, location.y, size.x, size.y);
	}

}
int normNum (float number) {
	if(number > 0) {
		return 1;
	} else if( number < 0 ) {
		return -1;
	}
	return 0;
}

class Ball {
	PVector location;
	PVector velocity;
	float radius;
	PImage ballImg = new PImage();
	boolean enteredCollision;
	Ball() {
		ballImg = loadImage("projectile.png");
		radius = 20;
		location = new PVector(width - 4 * radius, height/2);
		velocity = new PVector(100, 20);
	}
	void collide(String collideType, float angleRot) {
		if(!enteredCollision) {
			bounce.play();
			switch(collideType) {
				case "HORIZONTAL":
					velocity.y *= -1;
					break;
				case "VERTICAL":
					velocity.x *= -1;
					break;
			}
			velocity.rotate(radians(angleRot));
		}
		enteredCollision = true;
	}
	void move() {
		if(location.x + radius > width || location.x - radius < 0) {
			collide("VERTICAL", 0);
		} else if ( location.y + radius > height || location.y - radius < 0 ) {
			collide("HORIZONTAL", 0);
		}

		PVector velocityPerFrame = new PVector();
		velocityPerFrame = PVector.div(velocity, frameRate);
		location.add(velocityPerFrame);
		velocity.mult(1.00004);
		// velocity.mult(1.0001);
	}
	void display() {
		move();
		ellipseMode(CENTER);
		fill(255, 255, 255);
		stroke(255, 0, 0);
		// line(location.x, location.y, location.x + velocity.x, location.y + velocity.y);

		imageParams(ballImg, location.x, location.y, velocity.heading() + radians(90), radius * 2, radius * 2);
	}
}

class Friends {
	int maxFriends;
	float friendsPerTime;
	int friendSpawned;
	PImage friendImage = new PImage();
	Friend[] friends;
	int lastFriendSpawned;
	Friends() {
		friendImage = loadImage("friend.png");
		maxFriends = 200;
		friendsPerTime = 0.7;
		friends = new Friend[maxFriends];
		for(int i = 0; i < maxFriends; i++) {
			friends[i] = new Friend();
		}
	}
	void display() {
		if((frameCount - lastFriendSpawned) > frameRate / friendsPerTime) {
			friends[friendSpawned % maxFriends] = new Friend();
			friends[friendSpawned % maxFriends].displayed = true;
			friendSpawned++;
			lastFriendSpawned = frameCount;
		}
		for(Friend friend : friends) {
			friend.display();
		}
	}
	class Friend {
		PVector location;
		float lifetime;
		int aliveAfterLifetime;
		boolean alive;
		boolean displayed;
		float radius;
		float value;

		Friend() {
			location = new PVector(random(radius, width), random(radius, height));
			alive = false;
			displayed = false;
			radius = 10;
			aliveAfterLifetime = 3;
			lifetime = 0;
			value = 0;
		}
		void kill() {
			if(alive) {
				alive = false;
				displayed = false;
				score -= value;	
				lifetime = 0;
			}
		}
		void display() {
	
			if(displayed) {
				lifetime += (1.00 / frameRate);
				if(lifetime >= aliveAfterLifetime) {
					alive = true;
				}
				if(alive) {
					// ellipse(location.x, location.y, radius * 2, radius * 2);
					imageParams(friendImage, location.x, location.y, random(0, 0.1), radius * 2, radius * 2);
					// text(value, location.x, location.y);
					value += (millis() - lastTime) / 10;
					this.radius = this.radius < 35 ? this.radius * 1.0005 : this.radius ;
				} else {
					noFill();
					ellipse(location.x, location.y, 10, 10);
				}
			}
		}
	}
}

void imageParams (PImage pimage, float x, float y, float angle, float w, float h) {
  pushMatrix();
  imageMode(CENTER);
  translate(x, y);
  rotate(angle);
  image(pimage, 0, 0, w, h);
  popMatrix();
}
