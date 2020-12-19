-- title:  Spacinvaders
-- author: Rodrigo Vieira
-- desc:   Yet another Space Invaders variation
-- script: lua

function coll(o1, o2)
	return 
		math.abs(o1.x - o2.x) <= game.sprite_w
		and 
		math.abs(o1.y - o2.y) <= game.sprite_w
end

sounds = {
	enabled = true,
	toggle = function(self)
		self.enabled = not self.enabled
	end,
	play = function(self,s)
		if not self.enabled then return end
		if s == 'shoot' then
				sfx(0,'D-4',20,1,10)
		elseif s == 'step' then
				sfx(4,1,2)
		elseif s == 'hit' then
				sfx(0,'D-5',20,1,10)
		end
	end,
}

game = {
 started = false,
	res_x = 240,
	res_y = 136,
	sprite_w = 8,
	tics = 0,
	last_shot = math.huge,
	press = function(self)
		if btn(4) then
		  self.started = true
		end
	end,
	spawn_alien = function(ax, ay, asprite)
		return {
			x = ax,
			y = ay,
			sprite = asprite
		}
	end,
	tic = function(self)
		self.tics = self.tics + 1		
	end,
	shoot = function(self)
		game.last_shot = game.last_shot + 1
		if game.last_shot < 20 then 
			return 
		end
		
		local shooting = 
					btnp(4,20,20) or btnp(0,20,20)
		
		if shooting then
			game.last_shot = 0
			sounds:play('shoot')
			table.insert(
				shots,
				{ 
					x = ship.x, 
					y = ship.y-game.sprite_w/2, 
				}
			)
		end
	end,
	check_hit = function(self)
		for ai,a in ipairs(aliens) do
			for si,s in ipairs(shots) do
				if coll(a,s) then
					table.remove(aliens,ai)
					table.remove(shots,si)
					sounds:play('hit')
				end
			end
		end
	end,
	init = function(self)
		for row = 1, 6 do
			for col=1,6 do
			 table.insert(
					aliens,
					self.spawn_alien(
						self.res_x // 8 * (col + 1/3),
						row * 10,
						sprites.aliens[math.random(1,3)]
					)
				)
			end
		end
	end,
}

sprites = {
	ship = 257,
	aliens = {256,258,261},
	black_hole = {259},
	boss = {260},
	laser = {263,264},
}

shots = {
	move = function(self)
		for _,s in ipairs(self) do
			s.y = s.y-1
		end
	end,
	draw = function(self)
		for i,s in ipairs(self) do
			if s.y < 0 then
				table.remove(self, i)
			else
				local laser = 
					game.tics%20<10 and 263 or 264 						
				spr(laser,s.x,s.y,0)
			end
		end
	end,
}

aliens = {
	moves = 6,
	direction = 1,
	draw = function(self)
		for i, a in ipairs(self) do
			spr(a.sprite,a.x,a.y)
		end
	end,
	move = function(self)
		if game.tics%(60) == 0 then
			sounds:play('step')
			self.moves = self.moves + 1
			if (self.moves == 13) then
				self.direction = self.direction * -1
				self.moves = 1
			end
			for _, a in ipairs(self) do
				a.x = a.x + (6 * self.direction)
			end
		end
	end,
}

ship = {
	x = game.res_x // 2,
	y = game.res_y * 0.9,
	move = function(self)
		local LEFT = 2
		local RIGHT = 3
		if 
			btn(LEFT) and self.x > 0 
		then 
			self.x=self.x-1 
		end
		if 
			btn(RIGHT) and self.x < game.res_x - game.sprite_w 
		then 
			self.x=self.x+1 
		end
	end,
	draw = function(self)
		spr(sprites.ship,self.x, self.y)
	end
}

game:init()

function TIC()
	cls()
	if not game.started then
		print("Press Z to start",80, 50, 3)
		game:press()
	 return
	end
	
	game:tic()
	ship:move()
	ship:draw()
	aliens:move()
	aliens:draw()
	game:shoot()
	shots:move()
	shots:draw()
	game:check_hit()
end

-- <SPRITES>
-- 000:0000d00000dddd0005c0c050ddd55cdd0dd55dd000d55d000005000000005000
-- 001:000bb000000aa000000aa00080acda0880acca0880aeea080aaaaaa043222234
-- 002:00200030223003300223d300022dddd000dddddd0ddddd00000dd00000dddd00
-- 003:001ff1000100001010f00f01f00ff00ff00ff00f10f00f0101000010001ff100
-- 004:00b000b00b08880b0b08b80b0b08880b00b000b0000b0b00000b0b000000b000
-- 005:0066600006666600060606006677770607777776006666600006600000066600
-- 006:000330000003b000000b30000003b000000b30000003b000000b30000003b000
-- 007:0002200000022000000220000002200000022000000220000002200000022000
-- 008:0004400000044000000440000004400000044000000440000004400000044000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:010001008100810081009100010091009100a100a100a100a100b100b100b1000100b100b100b100e100b10071007100710051004100010001000100050000000000
-- 002:000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000034000000000
-- 003:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

