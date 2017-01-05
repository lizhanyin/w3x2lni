
local key_cache = {}
local function get_key(w2l, type, id)
    if not key_cache[type] then
        local t = {}
        for key, meta in pairs(w2l:metadata()[type]) do
            t[meta.id] = key
        end
        key_cache[type] = t
    end
    return key_cache[type][id]
end

local function get_key2(w2l, type, code, id)
    local key = get_key(w2l, type, id)
    if key ~= nil then
        return key
    end
    for key, meta in pairs(w2l:metadata()[code]) do
        if meta.id == id then
            return key
        end
    end
end

local codemapped
local function get_codemapped(w2l, id)
    if not codemapped then
        codemapped = w2l:parse_lni(io.load(w2l.defined / 'codemapped.ini'))
    end
    return codemapped[id] or id
end

local enable_type = {
    abilCode = 'ability',
    abilityID = 'ability',
    abilityList = 'ability',
    heroAbilityList = 'ability',
    buffList = 'buff',
    effectList = 'buff',
    unitCode = 'unit',
    unitList = 'unit',
    itemList = 'item',
    techList = 'upgrade,unit',
    upgradeList = 'upgrade',
    upgradeCode = 'upgrade',
}

local function fixsearch(t)
    t.item.common.cooldownid = nil
    t.unit.common.upgrades = nil
    t.unit.common.auto = nil
    t.unit.common.dependencyor = nil
    t.unit.common.reviveat = nil
    -- 复活死尸科技限制单位
    t.ability.Arai.unitid = nil
    t.ability.ACrd.unitid = nil
    t.ability.AIrd.unitid = nil
    t.ability.Avng.unitid = nil
    -- 地洞战备状态允许单位
    t.ability.Abtl.unitid = nil
    t.ability.Sbtl.unitid = nil
    -- 装载允许目标单位
    t.ability.Aloa.unitid = nil
    t.ability.Sloa.unitid = nil
    t.ability.Slo2.unitid = nil
    t.ability.Slo3.unitid = nil
    -- 灵魂保存目标单位
    t.ability.ANsl.unitid = nil
    -- 地洞装载允许目标单位
    t.ability.Achl.unitid = nil
    -- 火山爆发召唤可破坏物
    t.ability.ANvc.unitid = 'destructable'
     -- 战斗号召允许单位
    t.ability.Amil.dataa = nil
    -- 骑乘角鹰兽指定单位类型
    t.ability.Acoa.dataa = nil
    t.ability.Acoh.dataa = nil
    t.ability.Aco2.dataa = nil
    t.ability.Aco3.dataa = nil
end

local function sortpairs(t)
    local sort = {}
    for k, v in pairs(t) do
        sort[#sort+1] = {k, v}
    end
    table.sort(sort, function (a, b)
        return a[1] < b[1]
    end)
    local n = 1
    return function()
        local v = sort[n]
        if not v then
            return
        end
        n = n + 1
        return v[1], v[2]
    end
end

local function fmtstring(s)
    if s:find '[^%w_]' then
        return ('%q'):format(s)
    end
    return s
end

local function stringify(inf, outf)
    for name, obj in sortpairs(inf) do
        if next(obj) then
            outf[#outf+1] = ('[%s]'):format(fmtstring(name))
            for k, v in sortpairs(obj) do
                outf[#outf+1] = ('%s = %s'):format(fmtstring(k), v)
            end
            outf[#outf+1] = ''
        end
    end
end

local function stringify_ex(inf)
    local f = {}
    stringify({common=inf.common}, f)
    inf.common = nil
    stringify(inf, f)
    return table.concat(f, '\r\n')
end

local function copy_code(t, template)
    for name, d in pairs(template) do
        local code = d.code
        local data = t[name]
        if data then
            t[name] = nil
            if t[code] then
                for k, v in pairs(data) do
                    local dest = t[code][k]
                    if dest then
                        if v[1] ~= dest[1] then
                            message('id不同:', k, 'skill:', name, v[1], 'code:', code, dest[1])
                        end
                        if v[2] ~= dest[2] then
                            message('type不同:', k, 'skill:', name, v[2], 'code:', code, dest[2])
                        end
                    else
                        t[code][k] = v
                    end
                end
            else
                t[code] = {}
                for k, v in pairs(data) do
                    t[code][k] = v
                end
            end
        end
    end
end

local function is_enable(meta, type)
    if type == 'unit' then
        if meta.usehero == 1 or meta.useunit == 1 or meta.usebuilding == 1 or meta.usecreep == 1 then
            return true
        else
            return false
        end
    end
    if type == 'item' then
        if meta['useitem'] == 1 then
            return true
        else
            return false
        end
    end
    return true
end

local function create_search(w2l, type, tsearch)
    local metadata = w2l:parse_slk(io.load(w2l.mpq / w2l.info.metadata[type]))
    tsearch[type] = {common = {}}
    local tsearch = tsearch[type]
    for id, meta in pairs(metadata) do
        if is_enable(meta, type) then
            local objs = meta.usespecific or meta.section
            if objs then
                for name in objs:gmatch '%w+' do
                    if not tsearch[name] then
                        tsearch[name] = {}
                    end
                    local key = get_key2(w2l, type, get_codemapped(w2l, name), id)
                    tsearch[name][key] = enable_type[meta.type]
                end
            else
                local key = get_key(w2l, type, id)
                tsearch.common[key] = enable_type[meta.type]
            end
        end
    end
end

return function(w2l)
    message('正在生成search')
    local tsearch = {}
    for _, type in ipairs {'ability', 'buff', 'unit', 'item', 'upgrade', 'doodad', 'destructable'} do
        create_search(w2l, type, tsearch)
    end
    fixsearch(tsearch)
    local template = w2l:parse_slk(io.load(w2l.mpq / w2l.info.slk.ability[1]))
    copy_code(tsearch.ability, template)
    for _, type in ipairs {'ability', 'buff', 'unit', 'item', 'upgrade', 'doodad', 'destructable'} do
        io.save(w2l.prebuilt / 'search' / (type .. '.ini'), stringify_ex(tsearch[type]))
    end
end