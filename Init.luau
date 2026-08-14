local downloadPath = 'https://raw.githubusercontent.com/Springs67/Kavo/refs/heads/Main/'
local downloadFile = function(path: string)
    if shared.Developer then
        return readfile(path);
    end

    path = path:gsub('Kavo/')

    local newContent = game:HttpGet(downloadPath..path)
    local oldContent = isfile('Kavo/' .. path) and readfile('Kavo/' .. path) or ''

    if newContent ~= oldContent then
        writefile(
            'Kavo/' .. path,
            game:HttpGet(downloadPath..path)
        )

        repeat task.wait(0.5) until isfile('Kavo/' .. path)

        return readfile('Kavo/' .. path)
    end

    return readfile('Kavo/' .. path)
end

shared.GuiLibrary = loadstring(downloadFile('Kavo/GuiLibrary.luau'))()
shared.downloadFile = downloadFile

local Games = loadstring(downloadFile('Kavo/Games.luau'))()

for index, value in Games do
    if typeof(value) == 'number' then
        if game.PlaceId == value then
            loadstring(downloadFile('Kavo/Games/'..index..'.luau'))()
            break
        end
    elseif typeof(value) == 'table' then
        for _, value2 in value do
            if game.PlaceId == value2 then
                loadstring(downloadFile('Kavo/Games/'..index..'.luau'))()
                break
            end
        end
    end
end