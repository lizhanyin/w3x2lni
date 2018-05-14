local gui = require 'yue.gui'
local lang = require 'share.lang'
local ui = require 'gui.new.template'
local ev = require 'gui.event'

local template = ui.container {
    style = { FlexGrow = 1 },
    font = { size = 16 },
    ui.container {
        style = { FlexGrow = 1 },
        ui.label {
            text = lang.ui.AUTHOR,
            text_color = '#000',
            style = { MarginTop = 20, Height = 28, Width = 240 },
            bind = {
                color = 'theme'
            }
        },
        ui.label {
            text = lang.ui.FRONTEND .. 'actboy168',
            text_color = '#AAA',
            style = { MarginTop = 5, Height = 28, Width = 240 }
        },
        ui.label {
            text = lang.ui.BACKEND .. lang.ui.SUMNEKO,
            text_color = '#AAA',
            style = { Height = 28, Width = 240 }
        },
        ui.label {
            text = lang.ui.CHANGE_LOG,
            text_color = '#000',
            style = { Height = 28, Width = 240 },
            bind = {
                color = 'theme'
            }
        },
        ui.scroll {
            style = { FlexGrow = 1 },
            hpolicy = 'never',
            vpolicy = 'never',
            width = 0,
            bind = {
                height = 'height'
            },
            ui.container {
                id = 'changelog',
            }
        },
    },
    ui.button {
        title = lang.ui.BACK,
        style = { Bottom = 0, Height = 28, Margin = 5 },
        on = {
            click = function()
                window:show_page('index')
            end
        }
    }
}

local view, data, element = ui.create(template, {
    theme = window._color,
    height = 0
})

ev.on('update theme', function()
    data.theme = window._color
end)

local log = element.changelog

local color  = {
    NEW = gui.Color.rgb(0, 173, 60),
    CHG = gui.Color.rgb(217, 163, 60),
    FIX = gui.Color.rgb(200, 30, 30),
    UI =  gui.Color.rgb(111, 77, 150),
}

local template_version = ui.label {
    style = { Margin = 3, Height = 25 },
    color = '#444',
    text_color = '#AAA',
    font = { size = 16 },
    bind = {
        text = 'version'
    }
}

local template_changlog = ui.container {
    style = { Height = 31, FlexDirection = 'row' },
    color = { normal = '#222', hover = '#444' },
    ui.label {
        style = { Margin = 3, Width = 40 },
        font = { name = 'Consolas', size = 18 },
        bind = {
            text = 'type.text',
            color = 'type.color'
        }
    },
    ui.label {
        style = { Margin = 3, Width = 360, FlexGlow = 1 },
        text_color = '#AAA',
        font = { size = 16 },
        align = 'start',
        bind = {
            text = 'text'
        }
    }
}

local height = 0
for _, v in ipairs(require 'share.changelog') do
    local label = ui.create(template_version, {
        version = v.version
    })
    log:addchildview(label)

    height = height + 31

    for _, l in ipairs(v) do
        local line = ui.create(template_changlog, {
            type = {
                text = l[1],
                color = color[l[1]]
            },
            text = l[2]
        })
        log:addchildview(line)

        height = height + 31
    end
end

data.height = height

return view
