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

function love.draw()
    for i,brick in ipairs(bricks) do
        love.graphics.setColor(brick.color)
        love.graphics.rectangle("fill",
                                brick.x,
                                brick.y,
                                BRICK_WIDTH,
                                BRICK_HEIGHT)
    end
end
