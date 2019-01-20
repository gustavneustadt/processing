// Blood, simulating blood clumbing and resulting heart attack
// Gustav Neustadt
// you can change the amount of bloodcells via variable bloodParticle

Particles particles;
int bloodParticle = 500;

void setup() {
	size(100, 600);
	particles = new Particles(bloodParticle);
	frameRate(500);
}

void draw() {
	background(255);
	// ellipse(width / 2, height / 2, 50, 50);
	fill(0);
	// text(frameRate, 20, 20);
	particles.display();
}

class Particles {
	int maxParticles;
	Particle[] particles;
	PVector spacing;
	PVector massRandom;
	float attractionConst;
	Particles(int amount) {
		spacing = new PVector(10, 12);
		maxParticles = amount;
		particles = new Particle[(maxParticles+1)];
		attractionConst = 0.5;
		massRandom = new PVector(5, 10);

		for(int i = 0; i < maxParticles; i++) {
			particles[i] = new Particle(spacing.x + (i * spacing.x) % width, spacing.y + floor(i / (width / spacing.x)) * spacing.y, i, random(massRandom.x, massRandom.y), false);
		}
		particles[maxParticles] = new Particle(width / 2, height / 2, maxParticles, 5000, true);
	}

	void display() {
		for(Particle particle : particles) {
			particle.display();
		}
	}

	class Particle {
		PVector massRandom;
		PVector location;
		PVector velocity;
		PVector acceleration;
		PVector velocityPerFrame;

		int particleIndex;
		float radius;
		float mass;
		boolean bounceOff;
		boolean freeze;
		Particle(float x, float y, int particleId, float massSet, boolean stay) {
			freeze = stay;
			mass = massSet;
			location = new PVector(x, y);
			velocity = new PVector(random(-20, 20), 50);
			acceleration = new PVector();
			particleIndex = particleId;

			// velocity = new PVector(random(-100, 100), random(-100, 100));
		}
		void attraction() {
			acceleration = new PVector();
			for(int i = 0; i < maxParticles + 1; i++) {
				if(i != particleIndex) {
					float attracting = attractionConst * ((this.mass * particles[i].mass) / sq(PVector.dist(this.location, particles[i].location)));
					PVector distVect = PVector.sub(this.location, particles[i].location);
					float distVectMag = distVect.mag();
					float minDist = this.radius + particles[i].radius;

					if(distVectMag < this.radius + particles[i].radius) {
						// checkCollision(particles[i]);
						particles[i].location.sub(bounceOff(this.radius + particles[i].radius, distVect));
						this.location.add(bounceOff(this.radius + particles[i].radius, distVect));
						velocity.add(PVector.sub(particles[i].location, this.location).setMag(attracting).mult(-1)); 
					} 
					acceleration.add(PVector.sub(particles[i].location, this.location).setMag(attracting));
					// println(PVector.sub(this.location, particles[i].location).setMag(attracting));
					// line(this.location.x, this.location.y, particles[i].location.x, particles[i].location.y);
				}
			}
		}
		PVector bounceOff(float minDist, PVector dist) {
			float distanceCorrection = (minDist-dist.mag())/2;
			PVector d = dist.copy();
			PVector correctionVector = d.setMag(distanceCorrection);
			return correctionVector;
		}
		void move() {
			
				checkBoundaryCollision();
			if(!freeze) { 
				attraction(); 
				acceleration.add(new PVector(0, 50));
				velocity.add(acceleration);
				velocityPerFrame = PVector.div(velocity, frameRate);
				location.add(velocityPerFrame);
			} else {
				location.x = width/2;
				location.y = height/2;
			}
			velocity.limit(60);
			// println(location);
		}
		void display() {
			// stroke(255, 0, 0);
			// arrow(location, PVector.add(location, velocity));
			// stroke(0);
			// arrow(location, PVector.add(location, acceleration.mult(500)));
			if(freeze) {
				// fill(255, 0, 0);
				println(mass);

				mass = mass < 49848 ? mass * (1 + (0.1 / frameRate)) : 49848;
				radius = 5;
			} else {
				fill(255, 0, 0);
				noStroke();
				radius = map(mass, 5, 10, 2, 4);
			}
			move();
			ellipse(location.x, location.y, radius * 2, radius * 2);
		}
		void arrow(PVector v1, PVector v2) {
			float x1 = v1.x;
			float y1 = v1.y;
			float x2 = v2.x;
			float y2 = v2.y;
			line(x1, y1, x2, y2);
			pushMatrix();
			translate(x2, y2);
			float a = atan2(x1-x2, y2-y1);
			rotate(a);
			line(0, 0, -5, -5);
			line(0, 0, 5, -5);
			popMatrix();
		}
		void checkBoundaryCollision() {
			if (location.x > width-radius) {
				location.x = width-radius;
				velocity.x *= -1;
			} else if (location.x < radius) {
				location.x = radius;
				velocity.x *= -1;
			} else if (location.y > height-radius) {
				location.y = 1;
				// velocity.y *= -1;
			} else if (location.y < radius) {
				location.y = radius;
				velocity.y *= -1;
			}
		} 
	}
}