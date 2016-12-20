(function()
	local exepath = package.cpath:sub(1, (package.cpath:find(';') or 0)-6)
	package.path = package.path .. ';' .. exepath .. '..\\script\\?.lua'
end)()

require 'filesystem'
require 'utility'
local uni = require 'ffi.unicode'
local w2l = require 'w3x2lni'
local progress = require 'progress'
local archive = require 'archive'
w2l:initialize()

function message(...)
	local t = {...}
	for i = 1, select('#', ...) do
		t[i] = tostring(t[i])
	end
	print(table.concat(t, ' '))
end

local input = fs.path(uni.a2u(arg[1]))

message('正在打开地图...')
local slk = {}
local input_ar = archive(input)
if not input_ar then
    message('地图打开失败')
    return
end
message('正在读取物编...')
w2l:frontend(input_ar, slk)
message('正在转换...')
w2l:backend_processing(slk)
w2l:backend(input_ar, slk)
local output
if w2l.config.target_storage == 'dir' then
    message('正在导出文件...')
    output = input:parent_path() / input:stem()
elseif w2l.config.target_storage == 'map' then
    message('正在打包地图...')
    output = input:parent_path() / (input:stem():string() .. '_slk.w3x')
end
local output_ar = archive(output, 'w')
for name, buf in pairs(input_ar) do
    output_ar:set(name, buf)
end
progress:target(100)
output_ar:save(w2l.info, slk)
output_ar:close()
input_ar:close()
progress:target(100)
message('转换完毕,用时 ' .. os.clock() .. ' 秒') 
