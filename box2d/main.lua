-- https://en.wikipedia.org/wiki/Breakout_(video_game)#/media/File:Breakout_game_screenshot.png
-- https://www.arcade-history.com/?n=breakout&page=detail&id=3397
local WIDTH            = 672
local HEIGHT           = 970

local BRICK_ROWS       = 8
local BRICK_COLUMNS    = 14
local BRICK_MARGIN_TOP = math.floor(131*(love.graphics.getHeight()/HEIGHT))
local BRICK_GUTTER_X   = 6
local BRICK_GUTTER_Y   = 5
local BRICK_WIDTH      = love.graphics.getWidth()/BRICK_COLUMNS-BRICK_GUTTER_X
                         +BRICK_GUTTER_X/BRICK_COLUMNS
local BRICK_HEIGHT     = 12
local bricks
local colors           = {red   ={150/255,  44/255, 25/255},
                          orange={185/255, 136/255, 47/255},
                          green ={ 59/255, 131/255, 61/255},
                          yellow={194/255, 194/255, 74/255}}

local PADDLE_WIDTH     = 41
local PADDLE_X         = love.graphics.getWidth()/2-PADDLE_WIDTH/2
local PADDLE_Y         = (858/HEIGHT)*love.graphics.getHeight()
local paddle           = {x=PADDLE_X, y=PADDLE_Y, width=PADDLE_WIDTH, height=16,
                          color={59/255, 131/255, 189/255}}

local BALL_SPEED       = 225
local ball             = {x=love.graphics.getWidth()/2,
                          y=love.graphics.getHeight()/2,
                          width=12, height=10,
                          color={215/255, 215/255, 215/255},
                          velocity={BALL_SPEED, BALL_SPEED}}

local score            = 0
local hits             = 0
local lives            = 1

local world

local function shouldCollide(a, b)
    return a.x < b.x+b.width  and a.x+a.width  > b.x
       and a.y < b.y+b.height and a.y+a.height > b.y
end

local function setVelocity(a, velocity)
    local length  = math.sqrt(a.velocity[1]^2+a.velocity[2]^2)
    a.velocity[1] = a.velocity[1]/length
    a.velocity[2] = a.velocity[2]/length
    a.velocity[1] = a.velocity[1]*velocity
    a.velocity[2] = a.velocity[2]*velocity
end

local function serve()
    paddle.width  = PADDLE_WIDTH
    ball.x        = love.graphics.getWidth()/2
    ball.y        = love.graphics.getHeight()/2
    ball.velocity = {BALL_SPEED, BALL_SPEED}
    hits          = 0
end

local function onBallHitPaddle()
    hits = hits+1
    if hits == 4 then
        setVelocity(ball, 2*BALL_SPEED)
    end
    if hits == 12 then
        setVelocity(ball, 3*BALL_SPEED)
    end
    local position   =  ball.x+ball.width/2-paddle.x
    local normal     =  math.max(0, math.min(position/paddle.width, 1))
    normal           =  (2*normal) - 1 -- [0,1] to [-1,1]
    local angle      =  normal*math.rad(60)
    local velocity   =  math.sqrt(ball.velocity[1]^2+ball.velocity[2]^2)
    ball.velocity[1] =  math.sin(angle)*velocity
    ball.velocity[2] = -math.cos(angle)*velocity
end

local function onPlayerHitBrick(brick, i)
    table.remove(bricks, i)
    brick.body:destroy()
    brick.body = nil
    score = score + brick.points
    if score == 448 then
        love.load()
        serve()
    end
end

function love.load()
    bricks = {}
    world  = love.physics.newWorld()

    for y=1,BRICK_ROWS do
        local color  = colors.yellow
        local points = 1
        if     y == 1 or y == 2 then
              color  = colors.red
              points = 7
        elseif y == 3 or y == 4 then
              color  = colors.orange
              points = 5
        elseif y == 5 or y == 6 then
              color  = colors.green
              points = 3
        end
        for x=1,BRICK_COLUMNS do
            local brick   = {x=(x-1)*BRICK_WIDTH +(x-1)*BRICK_GUTTER_X,
                             y=BRICK_MARGIN_TOP
                              +(y-1)*BRICK_HEIGHT+(y-1)*BRICK_GUTTER_Y,
                             width=BRICK_WIDTH, height=BRICK_HEIGHT,
                             color=color, points=points}
            brick.body    = love.physics.newBody(world, brick.x+brick.width /2,
                                                        brick.y+brick.height/2)
            brick.shape   = love.physics.newRectangleShape(brick.width,
                                                           brick.height)
            brick.fixture = love.physics.newFixture(brick.body, brick.shape)
            table.insert(bricks, brick)
        end
    end
end

function love.update(dt)
    paddle.x = love.mouse.getX()-paddle.width/2

    if ball.y >= love.graphics.getHeight() then
        world:update(dt)
        return
    end

    ball.x = ball.x+ball.velocity[1]*dt
    ball.y = ball.y+ball.velocity[2]*dt

    if shouldCollide(ball, paddle) then
        ball.y = paddle.y-ball.height
        onBallHitPaddle()
    end

    if ball.x+ball.width >= love.graphics.getWidth() then
        ball.velocity[1] = -ball.velocity[1]
        ball.x = love.graphics.getWidth()-ball.width
    end

    for i,brick in ipairs(bricks) do
        if shouldCollide(ball, brick) then
            ball.velocity[2] = -ball.velocity[2]
            onPlayerHitBrick(brick, i)
            break
        end
    end

    if ball.y <= 0 then
        ball.velocity[2] = -ball.velocity[2]
        ball.y = 0
        paddle.width = PADDLE_WIDTH/2
    end

    if ball.x <= 0 then
        ball.velocity[1] = -ball.velocity[1]
        ball.x = 0
    end

    if ball.y >= love.graphics.getHeight() then
        lives = lives + 1
    end

    if score >= 896 and ball.y+ball.height >= love.graphics.getHeight() then
        ball.velocity[2] = -ball.velocity[2]
        ball.y = love.graphics.getHeight()-ball.height
    end

    world:update(dt)
end

function love.draw()
    for i,brick in ipairs(bricks) do
        love.graphics.setColor(brick.color)
        love.graphics.polygon("fill",
                              brick.body:getWorldPoints(brick.shape:getPoints()))
    end

    do
        love.graphics.setColor(paddle.color)
        love.graphics.rectangle("fill",
                                paddle.x,
                                paddle.y,
                                paddle.width,
                                paddle.height)
    end

    do
        love.graphics.setColor(ball.color)
        love.graphics.rectangle("fill",
                                ball.x,
                                ball.y,
                                ball.width,
                                ball.height)
    end

    love.graphics.print(lives)
    local font = love.graphics.getFont()
    local y    = font:getHeight()
    love.graphics.print(score, 0, y)
end

function love.keypressed(key)
    if key == "s" then
        if ball.y < love.graphics.getHeight() then
            return
        end

        if lives > 3 then
            score = 0
            lives = 1
            love.load()
        end

        serve()
    end
end
