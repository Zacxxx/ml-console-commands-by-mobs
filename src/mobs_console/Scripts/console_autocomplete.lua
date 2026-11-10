-- Copyright 2026 Mobs. MIT licensed. One synchronous game-thread console data refresh.
local M={}
local directory=debug.getinfo(1,'S').source:gsub('^@',''):gsub('\\','/'):match('^(.*)/Scripts/')
local bridge
function M.install(rows,enabled)
    local console=require('UEHelpers').GetGameViewportClient().ViewportConsole
    assert(console and console:IsValid(),'Open/enable the game console first')
    assert(directory,'Cannot locate console adapter')
    local folder=directory .. '/Native/'
    if not bridge then
        local file=assert(io.open(folder .. 'ux_bridge_name.txt','r'),'Console adapter missing')
        local name=file:read('*l'); file:close()
        assert(name and name:match('^mobs_ux_%x+%.dll$'),'Invalid console adapter manifest')
        bridge=assert(package.loadlib(folder .. name,'mobs_ux_run'))
    end
    assert(#rows<=6000,'Too many autocomplete entries')
    local lines={string.format('MOBS_UX_1 %d %d %d',console:GetAddress(),enabled and 1 or 0,#rows)}
    for _,row in ipairs(rows) do
        assert(#row.command<=240 and not row.command:find('[%c]'),'Invalid completion text')
        lines[#lines+1]=row.command .. '\t' .. row.description:gsub('[%c]',' '):sub(1,700)
    end
    local file=assert(io.open(folder .. 'ux.request','wb'))
    local written,message=file:write(table.concat(lines,'\n') .. '\n'); local closed,close_error=file:close()
    assert(written and closed,message or close_error or 'Cannot write autocomplete request')
    os.remove(folder .. 'ux.response')
    bridge()
    file=assert(io.open(folder .. 'ux.response','rb'),'Console adapter did not respond')
    local response=file:read(4096); file:close()
    os.remove(folder .. 'ux.request'); os.remove(folder .. 'ux.response')
    local count=response:match('^OK (%d+)%s*$')
    assert(count,response:gsub('%s+$',''))
    return tonumber(count)
end
return M
