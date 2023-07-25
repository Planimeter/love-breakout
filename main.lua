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
local bricks           = {}
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

function love.load()
    for y=1,BRICK_ROWS do
        local color = colors.yellow
        if     y == 1 or y == 2 then
              color = colors.red
        elseif y == 3 or y == 4 then
              color = colors.orange
        elseif y == 5 or y == 6 then
              color = colors.green
        end
        for x=1,BRICK_COLUMNS do
            local brick = {x=(x-1)*BRICK_WIDTH +(x-1)*BRICK_GUTTER_X,
                           y=BRICK_MARGIN_TOP
                            +(y-1)*BRICK_HEIGHT+(y-1)*BRICK_GUTTER_Y,
                           color=color}
            table.insert(bricks, brick)
        end
    end
end

function love.update(dt)
    paddle.x = love.mouse.getX()-paddle.width/2

    ball.x = ball.x+ball.velocity[1]*dt
    ball.y = ball.y+ball.velocity[2]*dt

    if ball.y+ball.height >= paddle.y then
        ball.velocity[2] = -ball.velocity[2]
        ball.y = paddle.y-ball.height
    end

    if ball.x+ball.width >= love.graphics.getWidth() then
        ball.velocity[1] = -ball.velocity[1]
        ball.x = love.graphics.getWidth()-ball.width
    end

    if ball.y <= 0 then
        ball.velocity[2] = -ball.velocity[2]
        ball.y = 0
    end

    if ball.x <= 0 then
        ball.velocity[1] = -ball.velocity[1]
        ball.x = 0
    end
end

function love.draw()
    for i,brick in ipairs(bricks) do
        love.graphics.setColor(brick.color)
        love.graphics.rectangle("fill",
                                brick.x,
                                brick.y,
                                BRICK_WIDTH,
                                BRICK_HEIGHT)
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
end
