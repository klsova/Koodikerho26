module orm;
import std::io;
import std::collections::list;
import std::math::random;
import raylib5;

const int SCREENSIZE = 600;
const int CELLCOUNT  = 20;
const int CELLSIZE	 = SCREENSIZE / CELLCOUNT;
const float TICKRATE = 10;


enum Direction
{
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

alias Vec2 = int[<2>];
alias Body = List {Vec2};

struct Snake
{
	Direction dir;
	Body	  body;
}

struct Food
{
	Vec2 pos;
	int index;
}

Food food = {
	.pos = {10, 10},
	.index = 0
};

float time_since_tick;
Direction new_dir;

struct Assets
{
	Texture2D[4] fruits;
	Texture2D    tile;
}

fn int main(String[] args)
{
	rl::initWindow(SCREENSIZE, SCREENSIZE, "ORM");
	rl::setTargetFPS(240);

	Snake snake;
	snake.body.init_with_array(mem, {
		{4, 10},
		{5, 10},
		{6, 10},
	});
	snake.dir = LEFT;

	Assets assets;
	assets.fruits[0] = rl::loadTexture("resources/apple.png");
	assets.fruits[1] = rl::loadTexture("resources/banana.png");
	assets.fruits[2] = rl::loadTexture("resources/grape.png");
	assets.fruits[3] = rl::loadTexture("resources/orange.png");
	assets.tile      = rl::loadTexture("resources/greytile.png");

	while (!rl::windowShouldClose())
	{
		time_since_tick += rl::getFrameTime();
		if (!update(&snake)) break;
		draw(snake, assets);
	}
	io::printn("Game over");
	return 0;
}

// returns: boolean indicating if game should continue
fn bool update(Snake* snake)
{
	if (rl::isKeyDown(rl::KEY_W) && snake.dir != DOWN)  new_dir = UP;
	if (rl::isKeyDown(rl::KEY_S) && snake.dir != UP)    new_dir = DOWN;
	if (rl::isKeyDown(rl::KEY_A) && snake.dir != RIGHT) new_dir = LEFT;
	if (rl::isKeyDown(rl::KEY_D) && snake.dir != LEFT)  new_dir = RIGHT;

	if (time_since_tick < 1/TICKRATE)
	{
		return true;
	} else {
		time_since_tick = 0;
	}

	snake.dir = new_dir;
	Vec2 next_head = snake.body[0];
	switch (snake.dir)
	{
		case UP:
			next_head.y -= 1;
			if (next_head.y < 0) next_head.y = CELLCOUNT-1;
		case DOWN:
			next_head.y += 1;
			if (next_head.y == CELLCOUNT) next_head.y = 0;
		case LEFT:
			next_head.x -= 1;
			if (next_head.x < 0) next_head.x = CELLCOUNT-1;
		case RIGHT:
			next_head.x += 1;
			if (next_head.x == CELLCOUNT) next_head.x = 0;
	}


	snake.body.push_front(next_head);
	if (next_head != food.pos) 
	{
		snake.body.pop()!!;
	} else {
		while (food.pos == next_head)
		{
			food.pos = {rand(CELLCOUNT-1), rand(CELLCOUNT-1)};
			food.index = rand(4);
		}
	}

	// Tarkasta, osuuko käärmeen pää johonkin ruumiin osaan
	foreach (index, body_segment : snake.body)
	{
		if (index == 0) continue;
		if (body_segment == snake.body[0]) // jos osan sijainti on sama kuin pään sijainti
		{
			return false; // Käärme törmäsi itseensä -> palauta false -> peli loppuu
		}
	}
	return true;
}

fn void draw(Snake snake, Assets assets)
{
	rl::beginDrawing();
	rl::clearBackground(rl::GRAY);

	for (int i = 0; i < CELLCOUNT; i += 2)
	{
		for (int j = 0; j < CELLCOUNT; j += 2)
		{
			rl::drawTexture(
				assets.tile,
				i * CELLSIZE, 
				j * CELLSIZE,
				rl::WHITE
			);
		}
	}

	// Piirretään käärme
	foreach (index, body_segment : snake.body)
	{
		rl::Color color = rl::GREEN;
		if (index == 0) color = rl::RED;

		rl::drawRectangle(
			body_segment.x * CELLSIZE,
			body_segment.y * CELLSIZE,
			CELLSIZE,
			CELLSIZE,
			color
		);
	}

	float offset = CELLSIZE * 1/2;
	rl::drawTextureEx(
		assets.fruits[food.index],
		{(float)food.pos.x * CELLSIZE-offset, (float)food.pos.y * CELLSIZE-offset},
		0, 2,
		rl::WHITE
	);
	rl::drawFPS(10, 10);
	rl::endDrawing();
}