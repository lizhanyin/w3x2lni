local gui = require 'yue.gui'

return function (t, data)
    local label = gui.Label.create('')
    if t.bind and t.bind.text then
        local bind_text
        bind_text = data:bind(t.bind.text, function()
            label:settext(bind_text:get())
        end)
        label:settext(bind_text:get())
    else
        label:settext(t.text or '')
    end
    if t.style then
        label:setstyle(t.style)
    end
    if t.font then
        label:setfont(Font(t.font))
    end
    if t.align then
        label:setalign(t.align)
    end
    local bind = {}
    if t.bind and t.bind.text_color then
        bind.text_color = data:bind(t.bind.text_color, function()
            label:setcolor(bind.text_color:get())
        end)
        label:setcolor(bind.text_color:get())
    else
        if t.text_color then
            label:setcolor(t.text_color)
        end
    end
    if t.bind and t.bind.color then
        bind.color = data:bind(t.bind.color, function()
            label:setbackgroundcolor(bind.color:get())
        end)
        label:setbackgroundcolor(bind.color:get())
    else
        if t.color then
            if type(t.color) == 'table' then
                label:setbackgroundcolor(t.color.normal)
                function label:onmouseleave()
                    label:setbackgroundcolor(t.color.normal)
                end
                function label:onmouseenter()
                    label:setbackgroundcolor(t.color.hover)
                end
            else
                label:setbackgroundcolor(t.color)
            end
        end
    end
    return label
end
