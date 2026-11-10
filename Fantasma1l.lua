-- ================================================================
--  FANTASMA1L HUB v54
--  Brookhaven Edition carregado separado (sem código visível aqui)
--  → executa primeiro, depois sobe o painel admin
-- ================================================================
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/feijaocomfarinha869-collab/Fantasma1l-hub/refs/heads/main/hub2.lua"))()
end)
--[[
    ==========================================================
    FANTASMA1L HUB - COMPLETO UNIFICADO v51
    (+ LOCUST COM REDE | POOLROOMS | PREFIXO ; | TORNADO EF5
     | IMAGENS CORRIGIDAS | EXPANSAO DE DOMINIO DO GOJO)
    ==========================================================
]]--

local Players            = game:GetService("Players")
local TextChatService    = game:GetService("TextChatService")
local StarterGui         = game:GetService("StarterGui")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Lighting           = game:GetService("Lighting")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer        = Players.LocalPlayer

-- ================== WHITELIST ==================
local WHITELIST = {
    -- DONO
    ["renegado6661l"]             = { Role = "DONO" },
    
    -- SUB DONO (2 VAGAS)
    ["BaconSigmaaura67420"]  = { Role = "SUB DONO" },
    ["darkADM_ofc"]  = { Role = "SUB DONO" },
    
    -- ADMS (9 VAGAS)
    ["Fantasma1l40"]       = { Role = "ADM" },
    ["oooooe"]       = { Role = "ADM" },
    ["pro2229208"]       = { Role = "ADM" },
    ["PREENCHA_AQUI_ADM_4"]       = { Role = "ADM" },
    ["PREENCHA_AQUI_ADM_5"]       = { Role = "ADM" },
    ["PREENCHA_AQUI_ADM_6"]       = { Role = "ADM" },
    ["PREENCHA_AQUI_ADM_7"]       = { Role = "ADM" },
    ["PREENCHA_AQUI_ADM_8"]       = { Role = "ADM" },
    ["PREENCHA_AQUI_ADM_9"]       = { Role = "ADM" },
}

local NETWORK_ROLES = {}
local REQUIRE_WHITELIST = true
local IS_ADMIN, MY_ROLE = false, "USER"

-- Verifica o nome ignorando maiúsculas e minúsculas
local myNameLower = string.lower(LocalPlayer.Name)
local entry = nil

for name, data in pairs(WHITELIST) do
    if string.lower(name) == myNameLower then
        entry = data
        break
    end
end

if entry then
    IS_ADMIN = true
    MY_ROLE = entry.Role
end

if IS_ADMIN then print("[Fantasma1l Hub] Modo: ADMIN - " .. MY_ROLE) end

-- ================== IDs ==================
local ICON_ID          = "rbxassetid://72455921762458"
local AK47_MODEL_ID    = 255662618
local YORU_MODEL_ID    = 79128297434634
local CUSTOM_ANIM_ID   = "rbxassetid://15489784732"
local SKYLINE_MODEL_ID = 96341548276150
local AURA_ANIM_ID     = "rbxassetid://106708015414624"
local SUK_SHRINE       = "18726352770"
local SUK_CUTS         = "17225837968"
local SUK_AUDIO        = "rbxassetid://6590147536"
local SHRINE_Y         = 13
local WINGS_ID         = "123746248186771"
local HALO1_ID         = "75992910653222"
local HALO2_ID         = "105905055095426"
local FLY_IDLE         = "rbxassetid://98353973763565"
local FLY_MOVE         = "rbxassetid://134861929761233"
local KAMUI_IMG        = "rbxassetid://110456504694881"
local KAMUI_SND        = "rbxassetid://997057912"
local TACO_ID          = "5132229429"
local OUTLET_MODEL_ID  = "112967019690019"

local LIFEFORM_IMG     = "rbxassetid://92640402847884"
local LIFEFORM_SOUND   = "rbxassetid://1840320106"
local BACKROOMS_MUSIC  = "rbxassetid://7009793551"

local DRAWING_IDS = {
    "rbxassetid://124381749642171",
    "rbxassetid://92443187697064",
    "rbxassetid://73774479856131",
    "rbxassetid://102128184178316",
}

local JUMPS = {
    ["JUMPSCARE_1"] = { Img = "rbxassetid://80832692858099",  Snd = "rbxassetid://6754147732" },
    ["JUMPSCARE_2"] = { Img = "rbxassetid://73907265132523",  Snd = "rbxassetid://8819324666" },
    ["JUMPSCARE_3"] = { Img = "rbxassetid://129901898312338", Snd = "rbxassetid://5410084802" },
}

local MEMES = {
    MEME1 = "4710801040", MEME2 = "6090344677", MEME3 = "1107231023",
    MEME4 = "1159595282", MEME5 = "8373881918",
}

local TEX_WALL        = "rbxassetid://133566929836216"
local TEX_CEILING     = "rbxassetid://81871305628274"
local TEX_FLOOR       = "rbxassetid://129329284263154"

-- ================== ESTADO ==================
local kamuiEnabled       = false
local kamuiFolder        = nil
local kamuiSize          = Vector3.new(700, 400, 700)
local activeScriptUsers  = { [LocalPlayer.Name] = true }
local selectedPlayerName = LocalPlayer.Name
local customChatText     = ""
local isControlling      = false
local auraTrack          = nil
local flyWingsActive     = false
local flyConnections     = {}
local wingsModel, halo1Model, halo2Model
local lifeformState      = { model = nil, active = false }

-- ================== HELPERS ==================
local function notify(t, txt)
    pcall(function() StarterGui:SetCore("SendNotification", { Title = t, Text = txt, Duration = 5 }) end)
end

local function getRealImageIdDelta(id)
    local cleanId = tostring(id):match("%d+")
    if not cleanId then return "rbxassetid://" .. id end
    return "rbxassetid://" .. cleanId
end

-- >>> CORREÇÃO DAS IMAGENS: converte ID de Decal em textura de imagem <<<
local imageCache = {}
local function resolveImage(id)
    local clean = tostring(id):match("%d+")
    if not clean then return tostring(id) end
    if imageCache[clean] then return imageCache[clean] end

    local fallback = "rbxassetid://" .. clean
    local result = fallback
    local objs
    local ok, r = pcall(function() return game:GetObjects(fallback) end)
    if ok and r and r[1] then objs = r end
    if not objs then
        local ok2, m = pcall(function() return game:GetService("InsertService"):LoadAsset(tonumber(clean)) end)
        if ok2 and m then objs = m:GetChildren() end
    end
    if objs and objs[1] then
        local o = objs[1]
        local tex
        if o:IsA("Decal") or o:IsA("Texture") then
            tex = o.Texture
        elseif o:IsA("ImageLabel") or o:IsA("ImageButton") then
            tex = o.Image
        else
            local d = o:FindFirstChildWhichIsA("Decal", true) or o:FindFirstChildWhichIsA("Texture", true)
            if d then tex = d.Texture end
        end
        if tex and tex ~= "" then result = tex end
        pcall(function() o:Destroy() end)
    end

    imageCache[clean] = result
    return result
end

-- pré-carrega as imagens (evita atraso no jumpscare/kamui)
task.spawn(function()
    for _, id in ipairs({ KAMUI_IMG, LIFEFORM_IMG, ICON_ID }) do pcall(resolveImage, id) end
    for _, j in pairs(JUMPS) do pcall(resolveImage, j.Img) end
end)

local function safePlayAnimation(character, animId)
    if not character then return nil end
    local hum = character:FindFirstChild("Humanoid")
    local anim = hum and hum:FindFirstChild("Animator")
    if not anim then return nil end
    local a = Instance.new("Animation")
    a.AnimationId = animId
    local ok, track = pcall(function() return anim:LoadAnimation(a) end)
    if ok and track then track:Play() return track end
    return nil
end

local function fetchAssetAsModel(id)
    local s, objs = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
    if s and objs and #objs > 0 then
        local m = Instance.new("Model")
        for _, o in ipairs(objs) do o.Parent = m end
        if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildWhichIsA("BasePart", true) end
        return m
    end
    return nil
end

local function makeModelFallSlowly(model)
    task.spawn(function()
        while model and model.Parent do
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") and not p.Anchored then
                    p.AssemblyLinearVelocity = Vector3.new(0, -7, 0)
                end
            end
            task.wait(0.1)
        end
    end)
end

local function sendNetCmd(cmd)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(cmd) end
        else
            local sayReq = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
            if sayReq then sayReq:FireServer(cmd, "All") end
        end
    end)
end

-- ================== TAG ==================
-- Regras:
--  * usuário comum NÃO vê a própria tag e não recebe mensagem nenhuma ao abrir o hub
--    (só recebe aviso se tiver DONO / SUB DONO / ADM no servidor);
--  * usuário vê a tag dos admins; admin vê a tag de todo mundo que usa o hub (e a própria).
FantasmaTag = { enabled = true, colorIdx = nil, peers = {}, hooked = {}, aliases = {}, usedAlias = {}, wl = {}, lastAnnounce = 0 }
for name, data in pairs(WHITELIST) do FantasmaTag.wl[string.lower(name)] = data.Role end

FantasmaTag.PRESETS = {
    { name = "Roxo → Azul",        a = Color3.fromRGB(168, 85, 247), b = Color3.fromRGB(59, 130, 246) },
    { name = "Dourado brilhante",  gold = true },
    { name = "Vermelho → Laranja", a = Color3.fromRGB(239, 68, 68),  b = Color3.fromRGB(251, 146, 60) },
    { name = "Verde → Ciano",      a = Color3.fromRGB(34, 197, 94),  b = Color3.fromRGB(6, 182, 212) },
    { name = "Rosa → Roxo",        a = Color3.fromRGB(236, 72, 153), b = Color3.fromRGB(139, 92, 246) },
    { name = "Azul → Ciano",       a = Color3.fromRGB(37, 99, 235),  b = Color3.fromRGB(34, 211, 238) },
    { name = "Branco → Cinza",     a = Color3.fromRGB(255, 255, 255), b = Color3.fromRGB(148, 163, 184) },
}

function FantasmaTag.presetNames()
    local t = {}
    for _, pr in ipairs(FantasmaTag.PRESETS) do table.insert(t, pr.name) end
    return t
end
function FantasmaTag.indexOf(name)
    for i, pr in ipairs(FantasmaTag.PRESETS) do if pr.name == name then return i end end
    return 1
end
function FantasmaTag.roleOf(name) return FantasmaTag.wl[string.lower(name or "")] end
function FantasmaTag.myColor() return FantasmaTag.colorIdx or (IS_ADMIN and 2 or 1) end
function FantasmaTag.colorOf(player)
    if player == LocalPlayer then return FantasmaTag.myColor() end
    local peer = FantasmaTag.peers[player.Name]
    if peer and peer.color and FantasmaTag.PRESETS[peer.color] then return peer.color end
    return FantasmaTag.roleOf(player.Name) and 2 or 1
end

function FantasmaTag.shouldShow(player)
    if not FantasmaTag.enabled then return false end
    if player == LocalPlayer then return IS_ADMIN end          -- usuário não vê a própria tag
    if not activeScriptUsers[player.Name] then return false end
    local peer = FantasmaTag.peers[player.Name]
    if peer and peer.off then return false end                 -- a pessoa desligou a tag dela
    if IS_ADMIN then return true end                           -- admin vê todos
    return FantasmaTag.roleOf(player.Name) ~= nil              -- usuário só vê admins
end

function FantasmaTag.remove(player)
    local ch = player and player.Character
    local head = ch and ch:FindFirstChild("Head")
    local old = head and head:FindFirstChild("FantasmaOverhead")
    if old then old:Destroy() end
end

function FantasmaTag.seq(...)
    local kp = {}
    for _, v in ipairs({ ... }) do table.insert(kp, ColorSequenceKeypoint.new(v[1], v[2])) end
    return ColorSequence.new(kp)
end

function FantasmaTag.build(player)
    pcall(function()
        local ch = player.Character
        local head = ch and (ch:FindFirstChild("Head") or ch:WaitForChild("Head", 3))
        if not head then return end
        local old = head:FindFirstChild("FantasmaOverhead")
        if old then old:Destroy() end

        local pr = FantasmaTag.PRESETS[FantasmaTag.colorOf(player)] or FantasmaTag.PRESETS[1]
        local role = (player == LocalPlayer and IS_ADMIN) and MY_ROLE or FantasmaTag.roleOf(player.Name)
        local text = role and ("FANTASMA1L • " .. role) or "Fantasma1l usuário"

        -- cores (dourado = preto + ouro brilhante | demais = degradê)
        local fillSeq, edgeSeq, textSeq, glow
        if pr.gold then
            fillSeq = FantasmaTag.seq({ 0, Color3.fromRGB(0, 0, 0) }, { 0.5, Color3.fromRGB(34, 26, 6) }, { 1, Color3.fromRGB(0, 0, 0) })
            edgeSeq = FantasmaTag.seq({ 0, Color3.fromRGB(184, 134, 11) }, { 0.35, Color3.fromRGB(255, 215, 0) },
                { 0.5, Color3.fromRGB(255, 250, 200) }, { 0.65, Color3.fromRGB(255, 215, 0) }, { 1, Color3.fromRGB(184, 134, 11) })
            textSeq = edgeSeq
            glow = Color3.fromRGB(255, 200, 40)
        else
            fillSeq = FantasmaTag.seq({ 0, pr.a:Lerp(Color3.new(0, 0, 0), 0.62) }, { 1, pr.b:Lerp(Color3.new(0, 0, 0), 0.62) })
            edgeSeq = FantasmaTag.seq({ 0, pr.a }, { 1, pr.b })
            textSeq = FantasmaTag.seq({ 0, pr.a:Lerp(Color3.new(1, 1, 1), 0.35) }, { 1, pr.b:Lerp(Color3.new(1, 1, 1), 0.35) })
            glow = pr.a
        end

        local bb = Instance.new("BillboardGui")
        bb.Name, bb.Adornee = "FantasmaOverhead", head
        bb.Size, bb.StudsOffset = UDim2.new(0, 268, 0, 62), Vector3.new(0, 3.4, 0)
        bb.AlwaysOnTop, bb.MaxDistance, bb.LightInfluence = true, 160, 0

        -- brilho (glow) atrás do cartão
        local gl = Instance.new("Frame", bb)
        gl.Size, gl.BackgroundTransparency = UDim2.fromScale(1, 1), 1
        Instance.new("UICorner", gl).CornerRadius = UDim.new(0, 18)
        local gs = Instance.new("UIStroke", gl)
        gs.Color, gs.Thickness, gs.Transparency = glow, 5, 0.72

        local fr = Instance.new("Frame", bb)
        fr.Position, fr.Size = UDim2.new(0, 6, 0, 6), UDim2.new(1, -12, 1, -12)
        fr.BackgroundColor3, fr.BackgroundTransparency, fr.BorderSizePixel = Color3.new(1, 1, 1), 0.05, 0
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 14)
        local fg = Instance.new("UIGradient", fr)
        fg.Color, fg.Rotation = fillSeq, 20

        local st = Instance.new("UIStroke", fr)
        st.Thickness, st.Color = 2.2, Color3.new(1, 1, 1)
        local sg = Instance.new("UIGradient", st)
        sg.Color = edgeSeq

        -- foto de perfil do jogador
        local av = Instance.new("ImageLabel", fr)
        av.Size, av.Position, av.BackgroundColor3 = UDim2.new(0, 36, 0, 36), UDim2.new(0, 8, 0.5, -18), Color3.fromRGB(20, 20, 28)
        av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
        Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
        local avs = Instance.new("UIStroke", av)
        avs.Thickness, avs.Color = 1.8, Color3.new(1, 1, 1)
        Instance.new("UIGradient", avs).Color = edgeSeq

        local lbl = Instance.new("TextLabel", fr)
        lbl.Size, lbl.Position, lbl.BackgroundTransparency = UDim2.new(1, -58, 1, 0), UDim2.new(0, 52, 0, 0), 1
        lbl.Text, lbl.TextColor3, lbl.TextSize = text, Color3.new(1, 1, 1), role and 15 or 16
        lbl.Font, lbl.TextXAlignment, lbl.TextTruncate = Enum.Font.GothamBlack, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd
        local lg = Instance.new("UIGradient", lbl)
        lg.Color = textSeq

        -- brilho correndo (só no dourado, leve: 2 tweens por tag)
        if pr.gold then
            local TS = game:GetService("TweenService")
            local info = TweenInfo.new(2.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1)
            sg.Offset, lg.Offset = Vector2.new(-1, 0), Vector2.new(-1, 0)
            TS:Create(sg, info, { Offset = Vector2.new(1, 0) }):Play()
            TS:Create(lg, info, { Offset = Vector2.new(1, 0) }):Play()
        end

        bb.Parent = head
    end)
end

function FantasmaTag.refresh(player)
    if not player then return end
    if FantasmaTag.shouldShow(player) then FantasmaTag.build(player) else FantasmaTag.remove(player) end
end
function FantasmaTag.refreshByName(name)
    local p = Players:FindFirstChild(name)
    if p then FantasmaTag.refresh(p) end
end
function FantasmaTag.refreshAll()
    for _, p in ipairs(Players:GetPlayers()) do FantasmaTag.refresh(p) end
end

function FantasmaTag.hook(player)
    if FantasmaTag.hooked[player] then return end
    FantasmaTag.hooked[player] = true
    player.CharacterAdded:Connect(function()
        task.wait(1.2)
        FantasmaTag.refresh(player)
    end)
    if player.Character then FantasmaTag.refresh(player) end
end

-- avisa a rede (cargo é conferido pelo NOME de quem enviou, então não dá para forjar)
function FantasmaTag.announce(force)
    local now = os.clock()
    if not force and now - FantasmaTag.lastAnnounce < 2 then return end
    FantasmaTag.lastAnnounce = now
    sendNetCmd(";PONG " .. LocalPlayer.Name .. " COL_" .. FantasmaTag.myColor() .. " TAG_" .. (FantasmaTag.enabled and 1 or 0))
end

function FantasmaTag.setEnabled(v)
    FantasmaTag.enabled = v and true or false
    FantasmaTag.refreshAll()
    FantasmaTag.announce(true)
end
function FantasmaTag.setColor(idx)
    if not FantasmaTag.PRESETS[idx] then return end
    FantasmaTag.colorIdx = idx
    FantasmaTag.refreshAll()
    FantasmaTag.announce(true)
end

-- nome falso fixo por jogador: Fantasma1lhub_1234
function FantasmaTag.alias(name)
    if FantasmaTag.aliases[name] then return FantasmaTag.aliases[name] end
    local n
    repeat n = math.random(1000, 9999) until not FantasmaTag.usedAlias[n]
    FantasmaTag.usedAlias[n] = true
    FantasmaTag.aliases[name] = "Fantasma1lhub_" .. n
    return FantasmaTag.aliases[name]
end

-- ;verificar -> lista só os apelidos de quem está usando o hub
function FantasmaTag.verify()
    sendNetCmd(";PING ALL")
    task.wait(2.5)
    local list = {}
    for n in pairs(activeScriptUsers) do
        if Players:FindFirstChild(n) then table.insert(list, FantasmaTag.alias(n)) end
    end
    table.sort(list)
    notify("Hub", table.concat(list, "\n"))
end

-- aviso de início: usuário comum só recebe se houver DONO / SUB DONO / ADM no servidor
function FantasmaTag.notice(text)
    pcall(function() StarterGui:SetCore("SendNotification", { Title = "Fantasma1l Hub", Text = text, Duration = 5 }) end)
end
task.spawn(function()
    if IS_ADMIN then FantasmaTag.notice(MY_ROLE) return end
    task.wait(2)
    for _, p in ipairs(Players:GetPlayers()) do
        local r = p ~= LocalPlayer and FantasmaTag.roleOf(p.Name)
        if r then FantasmaTag.notice("Hub ativo • " .. r .. " no servidor") break end
    end
end)
Players.PlayerAdded:Connect(function(p)
    FantasmaTag.hook(p)
    if not IS_ADMIN then
        local r = FantasmaTag.roleOf(p.Name)
        if r then task.wait(1.5) FantasmaTag.notice("Hub ativo • " .. r .. " entrou no servidor") end
    end
end)
Players.PlayerRemoving:Connect(function(p)
    FantasmaTag.peers[p.Name] = nil
    FantasmaTag.hooked[p] = nil
    activeScriptUsers[p.Name] = nil
end)
for _, p in ipairs(Players:GetPlayers()) do FantasmaTag.hook(p) end

-- ================== ANTI-LAG (desempenho) ==================
FantasmaPerf = { level = "Desligado", saved = nil }
function FantasmaPerf.save()
    if FantasmaPerf.saved then return end
    local sv = { shadows = Lighting.GlobalShadows, fx = {} }
    pcall(function() sv.quality = settings().Rendering.QualityLevel end)
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") then
            sv.fx[e] = e.Enabled
        end
    end
    local t = workspace:FindFirstChildOfClass("Terrain")
    if t then sv.deco = t.Decoration end
    FantasmaPerf.saved = sv
end
function FantasmaPerf.set(level)
    FantasmaPerf.save()
    local sv = FantasmaPerf.saved
    FantasmaPerf.level = level
    local t = workspace:FindFirstChildOfClass("Terrain")
    if level == "Desligado" then
        pcall(function() Lighting.GlobalShadows = sv.shadows end)
        for e, v in pairs(sv.fx) do if e.Parent then e.Enabled = v end end
        if t and sv.deco ~= nil then pcall(function() t.Decoration = sv.deco end) end
        if sv.quality then pcall(function() settings().Rendering.QualityLevel = sv.quality end) end
        return
    end
    -- Leve / Forte: só reduz gráficos do mapa (nenhuma função do hub é removida)
    pcall(function() Lighting.GlobalShadows = false end)
    for e in pairs(sv.fx) do if e.Parent then e.Enabled = false end end
    if level == "Forte" then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        if t then pcall(function() t.Decoration = false end) end
    else
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level05 end)
    end
end

-- ================== C00LKIDD EFFECT ==================
local function executeCoolkidEffect()
    pcall(function()
        local oldSky = Lighting:FindFirstChild("CoolkidSky")
        if oldSky then oldSky:Destroy() end
        local s = Instance.new("Sky", Lighting)
        s.Name = "CoolkidSky"
        s.SkyboxBk = "http://www.roblox.com/asset/?id=8408806737"
        s.SkyboxDn = "http://www.roblox.com/asset/?id=8408806737"
        s.SkyboxFt = "http://www.roblox.com/asset/?id=8408806737"
        s.SkyboxLf = "http://www.roblox.com/asset/?id=8408806737"
        s.SkyboxRt = "http://www.roblox.com/asset/?id=8408806737"
        s.SkyboxUp = "http://www.roblox.com/asset/?id=8408806737"
        Lighting.TimeOfDay = 12
    end)
    notify("c00lkidd Effect", "Skybox aplicada com sucesso!")
end

-- ================== KAMUI ==================
local function toggleKamuiDimensionLocal(state)
    kamuiEnabled = state
    if kamuiEnabled then
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)
        Lighting.FogStart, Lighting.FogEnd = 0, 300
        Lighting.Ambient, Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 20), Color3.fromRGB(15, 15, 20)

        kamuiFolder = Instance.new("Folder", workspace)
        kamuiFolder.Name = "KamuiDimensionBox"

        local c = Vector3.new(0, 500, 0)
        local hx, hy, hz = kamuiSize.X / 2, kamuiSize.Y / 2, kamuiSize.Z / 2
        local wt = 12

        local function wall(sz, pos)
            local p = Instance.new("Part", kamuiFolder)
            p.Size, p.Position, p.Anchored, p.CanCollide, p.CastShadow = sz, c + pos, true, true, false
            p.Material, p.Color = Enum.Material.SmoothPlastic, Color3.fromRGB(10, 10, 10)
        end
        wall(Vector3.new(kamuiSize.X, wt, kamuiSize.Z), Vector3.new(0, -hy, 0))
        wall(Vector3.new(kamuiSize.X, wt, kamuiSize.Z), Vector3.new(0, hy, 0))
        wall(Vector3.new(wt, kamuiSize.Y, kamuiSize.Z), Vector3.new(-hx, 0, 0))
        wall(Vector3.new(wt, kamuiSize.Y, kamuiSize.Z), Vector3.new(hx, 0, 0))
        wall(Vector3.new(kamuiSize.X, kamuiSize.Y, wt), Vector3.new(0, 0, -hz))
        wall(Vector3.new(kamuiSize.X, kamuiSize.Y, wt), Vector3.new(0, 0, hz))

        local cx, cz = hx - 15, hz - 15
        local lh = kamuiSize.Y - 40
        for _, pos in ipairs({Vector3.new(-cx,0,-cz), Vector3.new(cx,0,-cz), Vector3.new(-cx,0,cz), Vector3.new(cx,0,cz)}) do
            local l = Instance.new("Part", kamuiFolder)
            l.Size, l.Position, l.Anchored, l.CanCollide = Vector3.new(6, lh, 6), c + pos, true, false
            l.Material, l.Color = Enum.Material.Neon, Color3.fromRGB(200, 220, 255)
            local pl = Instance.new("PointLight", l)
            pl.Color, pl.Range, pl.Brightness = Color3.fromRGB(200, 220, 255), 250, 3
        end

        local bs, sp, gr = 18, 6, 12
        local fy = c.Y - hy + wt / 2
        for x = -gr, gr do
            for z = -gr, gr do
                if math.abs(x) > 2 or math.abs(z) > 2 then
                    local h = math.random(25, 140)
                    local b = Instance.new("Part", kamuiFolder)
                    b.Size = Vector3.new(bs, h, bs)
                    b.Position = Vector3.new(c.X + x * (bs + sp), fy + h / 2, c.Z + z * (bs + sp))
                    b.Anchored, b.Material, b.Color = true, Enum.Material.Concrete, Color3.fromRGB(115, 125, 135)
                end
            end
        end

        local pf = Instance.new("Part", kamuiFolder)
        pf.Name, pf.Size = "KamuiTargetPlatform", Vector3.new(70, 4, 70)
        pf.Position, pf.Anchored = Vector3.new(c.X, fy + 85, c.Z), true
        pf.Material, pf.Color = Enum.Material.Slate, Color3.fromRGB(190, 200, 210)

        task.spawn(function()
            task.wait(0.1)
            local chr = LocalPlayer.Character
            local h = chr and chr:FindFirstChild("HumanoidRootPart")
            if h then h.CFrame = pf.CFrame + Vector3.new(0, 6, 0) end
        end)
        notify("Kamui", "Dimensão gerada com sucesso!")
    else
        if kamuiFolder then kamuiFolder:Destroy() kamuiFolder = nil end
        Lighting.FogEnd = 100000
        notify("Kamui", "Dimensão fechada!")
    end
end

-- ================== THE LIFEFORM ==================
local function spawnLifeform(spawnPos, folder, targetPlayerName)
    if lifeformState.model and lifeformState.model.Parent then
        lifeformState.model:Destroy()
    end

    local targetFolder = folder or workspace:FindFirstChild("Backrooms_Level0") or workspace

    local model = Instance.new("Model", targetFolder)
    model.Name = "TheLifeform"

    local body = Instance.new("Part", model)
    body.Name = "Body"
    body.Size = Vector3.new(2, 5, 1)
    body.CFrame = CFrame.new(spawnPos)
    body.Anchored = true
    body.CanCollide = false
    body.Transparency = 1
    body.Material = Enum.Material.SmoothPlastic
    body.CastShadow = false
    body.Massless = true
    model.PrimaryPart = body

    local bb = Instance.new("BillboardGui", body)
    bb.Name = "LifeformImage"
    bb.Size = UDim2.new(0, 170, 0, 240)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = false
    bb.LightInfluence = 0
    bb.MaxDistance = 250

    local img = Instance.new("ImageLabel", bb)
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = getRealImageIdDelta(LIFEFORM_IMG)
    img.ScaleType = Enum.ScaleType.Fit
    task.spawn(function()
        local r = resolveImage(LIFEFORM_IMG)
        if img.Parent then img.Image = r end
    end)

    local snd = Instance.new("Sound", body)
    snd.Name = "ChaseSound"
    snd.SoundId = LIFEFORM_SOUND
    snd.Looped = true
    snd.Volume = 4
    snd.RollOffMaxDistance = 200
    snd.RollOffMode = Enum.RollOffMode.InverseTapered

    local light = Instance.new("PointLight", body)
    light.Color = Color3.fromRGB(180, 0, 0)
    light.Brightness = 3
    light.Range = 30
    light.Shadows = true

    lifeformState.model = model
    lifeformState.active = true

    task.spawn(function()
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = false,
            AgentMaxSlope = 45,
        })

        local waypoints = {}
        local wpi = 1
        local cooldown = 0
        local SPEED = 22
        local DETECT_RANGE = 500

        while lifeformState.active and model.Parent do
            local targetPlr = Players:FindFirstChild(targetPlayerName) or LocalPlayer
            local chr = targetPlr and targetPlr.Character
            local th = chr and chr:FindFirstChild("HumanoidRootPart")
            local thum = chr and chr:FindFirstChildOfClass("Humanoid")

            if th and thum and thum.Health > 0 then
                local myPos = body.Position
                local targetPos = th.Position
                local dist = (targetPos - myPos).Magnitude

                if dist <= DETECT_RANGE then
                    if not snd.IsPlaying then
                        pcall(function() snd:Play() end)
                    end

                    if tick() - cooldown > 0.4 then
                        cooldown = tick()
                        pcall(function() path:ComputeAsync(myPos, targetPos) end)
                        if path.Status == Enum.PathStatus.Success then
                            waypoints = path:GetWaypoints()
                            wpi = 2
                        end
                    end

                    local moveTarget
                    if wpi <= #waypoints then
                        local wp = waypoints[wpi]
                        moveTarget = wp.Position
                        if (Vector3.new(myPos.X, 0, myPos.Z) - Vector3.new(wp.Position.X, 0, wp.Position.Z)).Magnitude < 3 then
                            wpi = wpi + 1
                        end
                    else
                        moveTarget = targetPos
                    end

                    local dir = moveTarget - myPos
                    dir = Vector3.new(dir.X, 0, dir.Z)
                    if dir.Magnitude > 0.5 then
                        dir = dir.Unit
                        local newPos = myPos + dir * SPEED * 0.05
                        newPos = Vector3.new(newPos.X, myPos.Y, newPos.Z)
                        body.CFrame = CFrame.lookAt(newPos, Vector3.new(targetPos.X, newPos.Y, targetPos.Z))
                    end

                    if dist < 4 then
                        thum.Health = 0
                        task.wait(2)
                    end
                else
                    if snd.IsPlaying then
                        pcall(function() snd:Stop() end)
                    end
                end
            else
                if snd.IsPlaying then
                    pcall(function() snd:Stop() end)
                end
            end

            task.wait(0.05)
        end
    end)

    notify("The Lifeform", "Ele acordou perseguindo " .. targetPlayerName .. ".")
    return model
end

local function clearLifeform()
    lifeformState.active = false
    if lifeformState.model then
        pcall(function() lifeformState.model:Destroy() end)
        lifeformState.model = nil
    end
end

-- ================== BACKROOMS LEVEL 0 ==================
local backroomsSaved = nil
local backroomsToken = 0

local function salvarLighting()
    if backroomsSaved then return end
    backroomsSaved = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor,
        GlobalShadows = Lighting.GlobalShadows,
        ExposureCompensation = Lighting.ExposureCompensation,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
end

local function restaurarLighting()
    if not backroomsSaved then return end
    for k, v in pairs(backroomsSaved) do
        pcall(function() Lighting[k] = v end)
    end
    backroomsSaved = nil
end

local function limparEfeitosLighting()
    for _, n in ipairs({ "Backrooms_CC", "Backrooms_Bloom", "BackroomsAtmosphere" }) do
        local o = Lighting:FindFirstChild(n)
        if o then o:Destroy() end
    end
    local a = workspace:FindFirstChild("BackroomsAtmosphere")
    if a then a:Destroy() end
end

local function spawnBackrooms(targetPartnerName)
    notify("Backrooms", "Gerando Level 0...")

    backroomsToken += 1
    local myToken = backroomsToken

    local old = workspace:FindFirstChild("Backrooms_Level0")
    if old then old:Destroy() end
    limparEfeitosLighting()
    clearLifeform()

    local folder = Instance.new("Folder")
    folder.Name = "Backrooms_Level0"
    folder.Parent = workspace

    local GRID = 24
    local CELL = 16
    local WALL_H = 14
    local T = 1.2
    local BASE = Vector3.new(0, 200, 0)
    local LIGHT_EVERY = 3

    local ROOM_SIZE = GRID * CELL
    local half = ROOM_SIZE / 2
    local floorY = BASE.Y
    local ceilY = floorY + WALL_H
    local ox, oz = BASE.X - half, BASE.Z - half

    local WALL_COLOR = Color3.fromRGB(238, 208, 86)
    local TRIM_COLOR = Color3.fromRGB(238, 226, 190)
    local WOOD_COLOR = Color3.fromRGB(96, 62, 36)
    local CARPET_COLOR = Color3.fromRGB(168, 130, 58)
    local CEIL_COLOR = Color3.fromRGB(232, 226, 190)
    local PANEL_COLOR = Color3.fromRGB(255, 252, 228)

    notify("Backrooms", "Carregando texturas...")
    local resolved, pending = {}, 0
    local function resolveAsync(key, id)
        pending += 1
        task.spawn(function()
            pcall(function() resolved[key] = resolveImage(id) end)
            pending -= 1
        end)
    end
    resolveAsync("wall", TEX_WALL)
    resolveAsync("floor", TEX_FLOOR)
    resolveAsync("ceil", TEX_CEILING)
    for i, id in ipairs(DRAWING_IDS) do resolveAsync("d" .. i, id) end

    local t0 = os.clock()
    while pending > 0 and os.clock() - t0 < 8 do task.wait(0.1) end
    if backroomsToken ~= myToken then error("backrooms cancelada") end

    local texWall = resolved.wall or TEX_WALL
    local texFloor = resolved.floor or TEX_FLOOR
    local texCeil = resolved.ceil or TEX_CEILING
    local drawImgs = {}
    for i, id in ipairs(DRAWING_IDS) do
        drawImgs[i] = resolved["d" .. i] or getRealImageIdDelta(id)
    end

    local built = 0
    local function mk(size, cf, color, mat, collide)
        local p = Instance.new("Part")
        p.Anchored = true
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = mat or Enum.Material.SmoothPlastic
        p.CanCollide = collide and true or false
        p.CanQuery = collide and true or false
        p.CanTouch = false
        p.CastShadow = collide and true or false
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent = folder
        built += 1
        if built % 150 == 0 then
            task.wait()
            if backroomsToken ~= myToken then error("backrooms cancelada") end
        end
        return p
    end

    local function addTextures(part, faces, tile, texture)
        pcall(function()
            for _, f in ipairs(faces) do
                local tex = Instance.new("Texture")
                tex.Texture = texture
                tex.Face = f
                tex.StudsPerTileU = tile
                tex.StudsPerTileV = tile
                tex.Parent = part
            end
        end)
    end

    local floor = mk(Vector3.new(ROOM_SIZE + T * 2, 2, ROOM_SIZE + T * 2), CFrame.new(BASE.X, floorY - 1, BASE.Z), CARPET_COLOR, Enum.Material.Fabric, true)
    floor.Name = "Floor"
    addTextures(floor, { Enum.NormalId.Top }, 5, texFloor)

    local ceil = mk(Vector3.new(ROOM_SIZE + T * 2, 2, ROOM_SIZE + T * 2), CFrame.new(BASE.X, ceilY + 1, BASE.Z), CEIL_COLOR, Enum.Material.SmoothPlastic, true)
    ceil.Name = "Ceiling"
    addTextures(ceil, { Enum.NormalId.Bottom }, 5, texCeil)

    local hW, vW = {}, {}
    for y = 0, GRID do
        hW[y] = {}
        for x = 1, GRID do hW[y][x] = true end
    end
    for y = 1, GRID do
        vW[y] = {}
        for x = 0, GRID do vW[y][x] = true end
    end

    local visited = {}
    for y = 1, GRID do visited[y] = {} end
    local stack = { { 1, 1 } }
    visited[1][1] = true
    while #stack > 0 do
        local cur = stack[#stack]
        local cx, cy = cur[1], cur[2]
        local nbs = {}
        if cx > 1 and not visited[cy][cx - 1] then table.insert(nbs, { cx - 1, cy }) end
        if cx < GRID and not visited[cy][cx + 1] then table.insert(nbs, { cx + 1, cy }) end
        if cy > 1 and not visited[cy - 1][cx] then table.insert(nbs, { cx, cy - 1 }) end
        if cy < GRID and not visited[cy + 1][cx] then table.insert(nbs, { cx, cy + 1 }) end
        if #nbs == 0 then
            table.remove(stack)
        else
            local n = nbs[math.random(#nbs)]
            local nx, ny = n[1], n[2]
            if nx == cx + 1 then vW[cy][cx] = false
            elseif nx == cx - 1 then vW[cy][cx - 1] = false
            elseif ny == cy + 1 then hW[cy][cx] = false
            else hW[cy - 1][cx] = false end
            visited[ny][nx] = true
            table.insert(stack, { nx, ny })
        end
    end

    for y = 1, GRID - 1 do
        for x = 1, GRID do
            if hW[y][x] and math.random() < 0.22 then hW[y][x] = false end
        end
    end
    for y = 1, GRID do
        for x = 1, GRID - 1 do
            if vW[y][x] and math.random() < 0.22 then vW[y][x] = false end
        end
    end

    local pillarSpots = {}
    local function abrirSala(rx, ry, rw, rh, comPilares)
        for y = ry, ry + rh - 1 do
            for x = rx, rx + rw - 2 do vW[y][x] = false end
        end
        for y = ry, ry + rh - 2 do
            for x = rx, rx + rw - 1 do hW[y][x] = false end
        end
        if comPilares then
            for yi = ry, ry + rh - 2 do
                for xi = rx, rx + rw - 2 do
                    if (xi - rx) % 2 == 0 and (yi - ry) % 2 == 0 and math.random() > 0.15 then
                        table.insert(pillarSpots, { xi, yi })
                    end
                end
            end
        end
    end

    for _ = 1, 9 do
        local rw, rh = math.random(3, 6), math.random(3, 6)
        local rx = math.random(1, GRID - rw + 1)
        local ry = math.random(1, GRID - rh + 1)
        abrirSala(rx, ry, rw, rh, true)
    end

    local scx = math.floor(GRID / 2)
    abrirSala(scx - 1, scx - 1, 3, 3, false)
    local startPos = Vector3.new(ox + (scx - 0.5) * CELL, floorY + 5, oz + (scx - 0.5) * CELL)

    local runs = {}
    local function wallRun(isH, cx, cz, length)
        local size = isH and Vector3.new(length + T, WALL_H, T) or Vector3.new(T, WALL_H, length + T)
        local wall = mk(size, CFrame.new(cx, floorY + WALL_H / 2, cz), WALL_COLOR, Enum.Material.SmoothPlastic, true)
        wall.Name = "Wall"
        addTextures(wall, isH and { Enum.NormalId.Front, Enum.NormalId.Back } or { Enum.NormalId.Left, Enum.NormalId.Right }, 5, texWall)

        local railOn = math.random() < 0.3
        local lenV = length + T
        for _, s in ipairs({ -1, 1 }) do
            local nrm = isH and Vector3.new(0, 0, s) or Vector3.new(s, 0, 0)
            local function strip(h, thick, y, col)
                local sz = isH and Vector3.new(lenV, h, thick) or Vector3.new(thick, h, lenV)
                return mk(sz, CFrame.new(cx, y, cz) + nrm * (T / 2 + thick / 2), col, Enum.Material.SmoothPlastic, false)
            end
            strip(0.9, 0.3, floorY + 0.45, TRIM_COLOR)
            strip(0.5, 0.25, floorY + WALL_H - 0.25, TRIM_COLOR)
            if railOn then strip(0.25, 0.4, floorY + 1.7, WOOD_COLOR) end
        end

        table.insert(runs, { isH = isH, cx = cx, cz = cz, length = length })
    end

    for y = 0, GRID do
        local x = 1
        while x <= GRID do
            if hW[y][x] then
                local s = x
                while x <= GRID and hW[y][x] do x += 1 end
                local len = (x - s) * CELL
                wallRun(true, ox + (s - 1) * CELL + len / 2, oz + y * CELL, len)
            else
                x += 1
            end
        end
    end
    for x = 0, GRID do
        local y = 1
        while y <= GRID do
            if vW[y][x] then
                local s = y
                while y <= GRID and vW[y][x] do y += 1 end
                local len = (y - s) * CELL
                wallRun(false, ox + x * CELL, oz + (s - 1) * CELL + len / 2, len)
            else
                y += 1
            end
        end
    end

    for _, sp in ipairs(pillarSpots) do
        if not (math.abs(sp[1] - scx) <= 3 and math.abs(sp[2] - scx) <= 3) then
            local px, pz = ox + sp[1] * CELL, oz + sp[2] * CELL
            local pil = mk(Vector3.new(5, WALL_H, 5), CFrame.new(px, floorY + WALL_H / 2, pz), WALL_COLOR, Enum.Material.SmoothPlastic, true)
            pil.Name = "Pillar"
            addTextures(pil, { Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right }, 5, texWall)
            mk(Vector3.new(5.6, 0.9, 5.6), CFrame.new(px, floorY + 0.45, pz), TRIM_COLOR, Enum.Material.SmoothPlastic, false)
            mk(Vector3.new(5.5, 0.5, 5.5), CFrame.new(px, floorY + WALL_H - 0.25, pz), TRIM_COLOR, Enum.Material.SmoothPlastic, false)
        end
    end

    local panels = {}
    for y = 1, GRID do
        for x = 1, GRID do
            local px, pz = ox + (x - 0.5) * CELL, oz + (y - 0.5) * CELL
            local panel = mk(Vector3.new(7, 0.25, 3.4), CFrame.new(px, ceilY - 0.13, pz), PANEL_COLOR, Enum.Material.Neon, false)
            panel.Name = "Lamp"
            local light
            if x % LIGHT_EVERY == 0 and y % LIGHT_EVERY == 0 then
                light = Instance.new("SurfaceLight")
                light.Face = Enum.NormalId.Bottom
                light.Brightness = 2.6
                light.Range = 42
                light.Angle = 130
                light.Color = Color3.fromRGB(255, 243, 200)
                light.Shadows = false
                light.Parent = panel
            end
            panels[#panels + 1] = { part = panel, light = light }
        end
    end

    task.spawn(function()
        while backroomsToken == myToken and folder.Parent do
            task.wait(math.random(15, 50) / 10)
            local item = panels[math.random(#panels)]
            for _ = 1, math.random(3, 8) do
                if backroomsToken ~= myToken or not item.part.Parent then break end
                local on = math.random() > 0.45
                item.part.Material = on and Enum.Material.Neon or Enum.Material.SmoothPlastic
                item.part.Color = on and PANEL_COLOR or Color3.fromRGB(150, 148, 125)
                if item.light then item.light.Enabled = on end
                task.wait(0.05 + math.random() * 0.08)
            end
            if item.part.Parent then
                item.part.Material = Enum.Material.Neon
                item.part.Color = PANEL_COLOR
                if item.light then item.light.Enabled = true end
            end
        end
    end)

    for _ = 1, 70 do
        local d = math.random(4, 14)
        local px = ox + 10 + math.random() * (ROOM_SIZE - 20)
        local pz = oz + 10 + math.random() * (ROOM_SIZE - 20)
        local st = mk(Vector3.new(0.05, d, d * (0.7 + math.random() * 0.5)),
            CFrame.new(px, floorY + 0.03, pz) * CFrame.Angles(0, math.rad(math.random(360)), 0) * CFrame.Angles(0, 0, math.rad(90)),
            Color3.fromRGB(88, 66, 28), Enum.Material.SmoothPlastic, false)
        st.Shape = Enum.PartType.Cylinder
        st.Transparency = 0.5 + math.random() * 0.15
        st.Name = "Stain"
    end

    local function wallPoint(run, dist)
        local s = math.random() < 0.5 and -1 or 1
        local nrm = run.isH and Vector3.new(0, 0, s) or Vector3.new(s, 0, 0)
        local along = (math.random() - 0.5) * math.max(run.length - 8, 0)
        local base = run.isH and Vector3.new(run.cx + along, 0, run.cz) or Vector3.new(run.cx, 0, run.cz + along)
        local pos = base + nrm * (T / 2 + dist)
        return Vector3.new(pos.X, floorY, pos.Z), nrm
    end

    local drawIdx = 0
    for _ = 1, 32 do
        local run = runs[math.random(#runs)]
        if run.length >= 10 and #DRAWING_IDS > 0 then
            local pos, nrm = wallPoint(run, 0.04)
            drawIdx = drawIdx % #DRAWING_IDS + 1
            local canvas = mk(Vector3.new(9, 9, 0.05), CFrame.lookAt(pos + Vector3.new(0, 6.5, 0), pos + Vector3.new(0, 6.5, 0) + nrm), WALL_COLOR, Enum.Material.SmoothPlastic, false)
            canvas.Name = "WallDrawing"
            canvas.Transparency = 1
            local sg = Instance.new("SurfaceGui")
            sg.Face = Enum.NormalId.Front
            sg.AlwaysOnTop = false
            sg.LightInfluence = 1
            sg.Parent = canvas
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(1, 0, 1, 0)
            img.BackgroundTransparency = 1
            img.Image = drawImgs[drawIdx]
            img.ImageTransparency = 0.08
            img.ScaleType = Enum.ScaleType.Fit
            img.Parent = sg
        end
    end

    for _ = 1, 35 do
        local run = runs[math.random(#runs)]
        if run.length >= 8 then
            local pos, nrm = wallPoint(run, 0.07)
            local cf = CFrame.lookAt(pos + Vector3.new(0, 1.6, 0), pos + Vector3.new(0, 1.6, 0) + nrm)
            mk(Vector3.new(0.9, 1.3, 0.12), cf, TRIM_COLOR, Enum.Material.SmoothPlastic, false)
            mk(Vector3.new(0.18, 0.3, 0.05), cf * CFrame.new(-0.2, 0.2, -0.08), Color3.fromRGB(40, 35, 25), Enum.Material.SmoothPlastic, false)
            mk(Vector3.new(0.18, 0.3, 0.05), cf * CFrame.new(0.2, 0.2, -0.08), Color3.fromRGB(40, 35, 25), Enum.Material.SmoothPlastic, false)
            mk(Vector3.new(0.18, 0.3, 0.05), cf * CFrame.new(-0.2, -0.2, -0.08), Color3.fromRGB(40, 35, 25), Enum.Material.SmoothPlastic, false)
            mk(Vector3.new(0.18, 0.3, 0.05), cf * CFrame.new(0.2, -0.2, -0.08), Color3.fromRGB(40, 35, 25), Enum.Material.SmoothPlastic, false)
        end
    end

    for _ = 1, 12 do
        pcall(function()
            local run = runs[math.random(#runs)]
            if run.length < 12 then return end
            local pos, nrm = wallPoint(run, 1.3)
            local center = pos + Vector3.new(0, 3.1, 0)
            local cf = CFrame.lookAt(center, center + nrm)
            local body = mk(Vector3.new(2.6, 6.2, 2.2), cf, Color3.fromRGB(112, 58, 38), Enum.Material.Metal, true)
            body.Name = "Locker"
            for i = 0, 2 do
                mk(Vector3.new(1.6, 0.14, 0.06), cf * CFrame.new(0, 1.4 + i * 0.3, -1.13), Color3.fromRGB(30, 20, 15), Enum.Material.Metal, false)
            end
        end)
    end

    for _ = 1, 10 do
        pcall(function()
            local run = runs[math.random(#runs)]
            if run.length < 10 then return end
            local pos = wallPoint(run, 1.6)
            local dark = Color3.fromRGB(45, 38, 30)
            mk(Vector3.new(1.4, 0.2, 1.4), CFrame.new(pos + Vector3.new(0, 0.1, 0)), dark, Enum.Material.Metal, false)
            mk(Vector3.new(0.2, 5.2, 0.2), CFrame.new(pos + Vector3.new(0, 2.7, 0)), dark, Enum.Material.Metal, false)
            local shade = mk(Vector3.new(1.8, 2.2, 2.2), CFrame.new(pos + Vector3.new(0, 5.6, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(240, 200, 100), Enum.Material.Neon, false)
            shade.Shape = Enum.PartType.Cylinder
            shade.Transparency = 0.15
            local pl = Instance.new("PointLight")
            pl.Color = Color3.fromRGB(255, 214, 120)
            pl.Brightness = 1.4
            pl.Range = 16
            pl.Shadows = false
            pl.Parent = shade
        end)
    end

    for _ = 1, 8 do
        pcall(function()
            local run = runs[math.random(#runs)]
            if run.length < 10 then return end
            local pos, nrm = wallPoint(run, 2.8)
            local center = pos + Vector3.new(0, 2.6, 0)
            local cf = CFrame.lookAt(center, center + nrm)
            local wood = Color3.fromRGB(110, 70, 40)
            mk(Vector3.new(5, 0.3, 2.4), cf, wood, Enum.Material.Wood, true)
            for _, sx in ipairs({ -1, 1 }) do
                for _, sz in ipairs({ -1, 1 }) do
                    mk(Vector3.new(0.3, 2.5, 0.3), cf * CFrame.new(sx * 2.2, -1.3, sz * 1.0), wood, Enum.Material.Wood, true)
                end
            end
        end)
    end

    salvarLighting()
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(125, 108, 58)
        Lighting.OutdoorAmbient = Color3.fromRGB(110, 95, 50)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
        Lighting.ExposureCompensation = 0.15
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.FogColor = Color3.fromRGB(70, 58, 25)
        Lighting.FogStart = 60
        Lighting.FogEnd = 650
    end)

    pcall(function()
        local cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "Backrooms_CC"
        cc.TintColor = Color3.fromRGB(255, 243, 175)
        cc.Saturation = 0.08
        cc.Contrast = 0.08
        cc.Brightness = -0.01
        cc.Parent = Lighting

        local bl = Instance.new("BloomEffect")
        bl.Name = "Backrooms_Bloom"
        bl.Intensity = 0.35
        bl.Size = 22
        bl.Threshold = 0.92
        bl.Parent = Lighting

        local atm = Instance.new("Atmosphere")
        atm.Name = "BackroomsAtmosphere"
        atm.Density = 0.28
        atm.Offset = 0
        atm.Color = Color3.fromRGB(200, 175, 95)
        atm.Decay = Color3.fromRGB(70, 55, 20)
        atm.Glare = 0
        atm.Haze = 0
        atm.Parent = Lighting
    end)

    pcall(function()
        local sndPart = mk(Vector3.new(1, 1, 1), CFrame.new(startPos), Color3.new(0, 0, 0), Enum.Material.SmoothPlastic, false)
        sndPart.Name = "BackroomsMusicEmitter"
        sndPart.Transparency = 1

        local sound = Instance.new("Sound")
        sound.SoundId = BACKROOMS_MUSIC
        sound.Looped = true
        sound.Volume = 2.5
        sound.RollOffMaxDistance = 10000
        sound.Parent = sndPart
        sound:Play()
    end)

    task.spawn(function()
        task.wait(1)
        local targetCFrame = CFrame.new(startPos)
        local chr = LocalPlayer.Character
        local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = true
            hrp.CFrame = targetCFrame
            task.wait(0.3)
            hrp.Anchored = false
        end

        if targetPartnerName and targetPartnerName ~= "" then
            local partner = Players:FindFirstChild(targetPartnerName)
            if partner and partner.Character and partner.Character:FindFirstChild("HumanoidRootPart") then
                partner.Character.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(3, 0, 3)
            end
        end

        notify("Backrooms", "Level 0 pronto!")
    end)

    return true
end

local function clearBackrooms()
    backroomsToken += 1
    clearLifeform()
    local f = workspace:FindFirstChild("Backrooms_Level0")
    if f then f:Destroy() end
    limparEfeitosLighting()
    restaurarLighting()
    notify("Backrooms", "Backrooms removidas.")
    return true
end

-- ================== POOLROOMS (LEVEL 37 - SALÃO INFINITO) ==================
local POOL = { token = 0, saved = nil, S = nil, hidden = {} }

do
    local TweenService = game:GetService("TweenService")
    local Debris       = game:GetService("Debris")

    local CH           = 64
    local OFFS         = { -24, -8, 8, 24 }
    local PANEL_OFFS   = { -32, -16, 0, 16 }
    local COL_W        = 3.6
    local WALL_H       = 24
    local POOL_Y       = 1000
    local WATER_H      = 1.6
    local RADIUS       = 2
    local TILE         = 4
    local LIGHT_COUNT  = 36
    local SHADOW_COUNT = 10
    local WALL_TEX     = "rbxassetid://122349893272800"

    local C_TILE  = Color3.fromRGB(246, 248, 248)
    local C_FLOOR = Color3.fromRGB(222, 238, 236)
    local C_WATER = Color3.fromRGB(70, 205, 198)
    local C_WET   = Color3.fromRGB(60, 190, 185)
    local C_TRIM  = Color3.fromRGB(170, 178, 180)
    local C_CEIL  = Color3.fromRGB(244, 246, 248)
    local C_FRAME = Color3.fromRGB(150, 155, 160)
    local C_PANEL = Color3.fromRGB(232, 244, 255)
    local C_LIGHT = Color3.fromRGB(214, 232, 255)

    local FACES_FB    = { Enum.NormalId.Front, Enum.NormalId.Back }
    local FACES_LR    = { Enum.NormalId.Left, Enum.NormalId.Right }
    local FACES_TOP   = { Enum.NormalId.Top }
    local FACES_SIDES = { Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right }

    local function mkPart(parent, size, cf, color, mat, collide)
        local p = Instance.new("Part")
        p.Anchored = true
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = mat or Enum.Material.SmoothPlastic
        p.CanCollide = collide and true or false
        p.CanQuery = collide and true or false
        p.CanTouch = false
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent = parent
        return p
    end

    local function slab(S, parent, size, cf, faces, color, collide)
        local p = mkPart(parent, size, cf, color or C_TILE, Enum.Material.SmoothPlastic, collide ~= false)
        p.Reflectance = 0.12
        for _, f in ipairs(faces or FACES_FB) do
            local t = Instance.new("Texture")
            t.Texture = S.tex
            t.Face = f
            t.StudsPerTileU = TILE
            t.StudsPerTileV = TILE
            t.Parent = p
        end
        S.count += 1
        if S.count % 70 == 0 then task.wait() end
        return p
    end

    local function wetBand(parent, w, d, x, z)
        local b = mkPart(parent, Vector3.new(w, 3, d), CFrame.new(x, POOL_Y + 1.5, z), C_WET, Enum.Material.SmoothPlastic, false)
        b.Transparency = 0.6
        b.Reflectance = 0.1
        b.CastShadow = false
        return b
    end

    local function buildChunk(S, cx, cz)
        if POOL.token ~= S.token then return end
        local key = cx .. "," .. cz
        if S.chunks[key] then return end

        local folder = Instance.new("Folder")
        folder.Name = "Chunk_" .. key
        folder.Parent = S.folder
        local chunk = { folder = folder, cx = cx, cz = cz, panels = {} }
        S.chunks[key] = chunk

        local rng = Random.new(cx * 7349 + cz * 9157 + 11)
        local wx, wz = cx * CH, cz * CH
        local ceilBottom = POOL_Y + WALL_H

        local ok, err = pcall(function()
            slab(S, folder, Vector3.new(CH, 2, CH), CFrame.new(wx, POOL_Y - 1, wz), FACES_TOP, C_FLOOR)

            local w = mkPart(folder, Vector3.new(CH, WATER_H, CH), CFrame.new(wx, POOL_Y + WATER_H / 2, wz), C_WATER, Enum.Material.Glass, false)
            w.Name = "PoolWater"
            w.Transparency = 0.55
            w.Reflectance = 0.22
            w.CastShadow = false

            local ceil = mkPart(folder, Vector3.new(CH, 2, CH), CFrame.new(wx, ceilBottom + 1, wz), C_CEIL, Enum.Material.SmoothPlastic, true)
            ceil.Name = "Ceiling"
            ceil.Reflectance = 0.04

            for _, dx in ipairs(OFFS) do
                for _, dz in ipairs(OFFS) do
                    local x, z = wx + dx, wz + dz
                    slab(S, folder, Vector3.new(COL_W, WALL_H, COL_W), CFrame.new(x, POOL_Y + WALL_H / 2, z), FACES_SIDES, C_TILE)
                    wetBand(folder, COL_W + 0.14, COL_W + 0.14, x, z)
                    local cap = mkPart(folder, Vector3.new(COL_W + 0.9, 0.8, COL_W + 0.9), CFrame.new(x, ceilBottom - 0.4, z), C_TRIM, Enum.Material.SmoothPlastic, false)
                    cap.Reflectance = 0.05
                end
            end

            local gap = (OFFS[2] - OFFS[1]) - COL_W
            for i = 1, #OFFS - 1 do
                for j = 1, #OFFS do
                    if rng:NextNumber() < 0.16 then
                        local x, z = wx + (OFFS[i] + OFFS[i + 1]) / 2, wz + OFFS[j]
                        slab(S, folder, Vector3.new(gap, WALL_H, 1.2), CFrame.new(x, POOL_Y + WALL_H / 2, z), FACES_FB, C_TILE)
                        wetBand(folder, gap + 0.02, 1.34, x, z)
                    end
                end
            end
            for i = 1, #OFFS do
                for j = 1, #OFFS - 1 do
                    if rng:NextNumber() < 0.16 then
                        local x, z = wx + OFFS[i], wz + (OFFS[j] + OFFS[j + 1]) / 2
                        slab(S, folder, Vector3.new(1.2, WALL_H, gap), CFrame.new(x, POOL_Y + WALL_H / 2, z), FACES_LR, C_TILE)
                        wetBand(folder, 1.34, gap + 0.02, x, z)
                    end
                end
            end

            for _, u in ipairs(PANEL_OFFS) do
                for _, v in ipairs(PANEL_OFFS) do
                    local x, z = wx + u, wz + v
                    local frame = mkPart(folder, Vector3.new(10.4, 0.5, 4.4), CFrame.new(x, ceilBottom - 0.25, z), C_FRAME, Enum.Material.Metal, false)
                    frame.CastShadow = false
                    local pan = mkPart(folder, Vector3.new(9.6, 0.3, 3.6), CFrame.new(x, ceilBottom - 0.55, z), C_PANEL, Enum.Material.Neon, false)
                    pan.Name = "LightPanel"
                    pan.CastShadow = false
                    table.insert(chunk.panels, { part = pan, light = nil, d = 0 })
                end
            end
        end)
        if not ok then warn("[Poolrooms] chunk " .. key .. ": " .. tostring(err)) end
    end

    local function unloadChunk(S, key)
        local ch = S.chunks[key]
        if not ch then return end
        S.chunks[key] = nil
        pcall(function() ch.folder:Destroy() end)
    end

    local function streamStep(S, pcx, pcz, radius)
        for ring = 0, radius do
            for dx = -ring, ring do
                for dz = -ring, ring do
                    if POOL.token ~= S.token then return end
                    if math.max(math.abs(dx), math.abs(dz)) == ring then
                        buildChunk(S, pcx + dx, pcz + dz)
                    end
                end
            end
        end
        for key, ch in pairs(S.chunks) do
            if math.max(math.abs(ch.cx - pcx), math.abs(ch.cz - pcz)) > RADIUS + 1 then
                unloadChunk(S, key)
            end
        end
    end

    local function updateLights(S, pos)
        local list = {}
        for _, ch in pairs(S.chunks) do
            for _, pn in ipairs(ch.panels) do
                if pn.part.Parent then
                    pn.d = (pn.part.Position - pos).Magnitude
                    list[#list + 1] = pn
                end
            end
        end
        table.sort(list, function(a, b) return a.d < b.d end)
        for i, pn in ipairs(list) do
            if i <= LIGHT_COUNT then
                if not (pn.light and pn.light.Parent) then
                    local l = Instance.new("SurfaceLight")
                    l.Face = Enum.NormalId.Bottom
                    l.Angle = 170
                    l.Range = 58
                    l.Brightness = 1.7
                    l.Color = C_LIGHT
                    l.Shadows = false
                    l.Parent = pn.part
                    pn.light = l
                end
                pn.light.Shadows = i <= SHADOW_COUNT
            elseif pn.light then
                pn.light:Destroy()
                pn.light = nil
            end
        end
    end

    local LIGHT_PROPS = {
        "Ambient", "OutdoorAmbient", "Brightness", "ColorShift_Top", "ColorShift_Bottom",
        "ExposureCompensation", "ClockTime", "FogColor", "FogStart", "FogEnd", "GlobalShadows",
        "ShadowSoftness", "EnvironmentDiffuseScale", "EnvironmentSpecularScale",
    }

    local function envSave()
        local s = {}
        for _, k in ipairs(LIGHT_PROPS) do
            pcall(function() s[k] = Lighting[k] end)
        end
        pcall(function() s.Technology = gethiddenproperty(Lighting, "Technology") end)
        return s
    end

    local function envApply()
        local function set(k, v) pcall(function() Lighting[k] = v end) end
        set("ClockTime", 14)
        set("Brightness", 2.2)
        set("Ambient", Color3.fromRGB(125, 148, 156))
        set("OutdoorAmbient", Color3.fromRGB(140, 160, 168))
        set("ColorShift_Top", Color3.fromRGB(230, 245, 255))
        set("ColorShift_Bottom", Color3.fromRGB(90, 190, 185))
        set("ExposureCompensation", 0.25)
        set("GlobalShadows", true)
        set("ShadowSoftness", 0.35)
        set("EnvironmentDiffuseScale", 0.6)
        set("EnvironmentSpecularScale", 1)
        set("FogColor", Color3.fromRGB(205, 228, 236))
        set("FogStart", 70)
        set("FogEnd", 250)
        pcall(function() sethiddenproperty(Lighting, "Technology", Enum.Technology.Future) end)

        pcall(function()
            for _, c in ipairs(Lighting:GetChildren()) do
                if c:IsA("Atmosphere") then
                    table.insert(POOL.hidden, c)
                    c.Parent = nil
                end
            end
        end)

        pcall(function()
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "Pool_CC"
            cc.TintColor = Color3.fromRGB(235, 248, 255)
            cc.Saturation = 0.1
            cc.Contrast = 0.08
            cc.Brightness = 0.02
            cc.Parent = Lighting

            local bl = Instance.new("BloomEffect")
            bl.Name = "Pool_Bloom"
            bl.Intensity = 0.35
            bl.Size = 24
            bl.Threshold = 0.95
            bl.Parent = Lighting

            local at = Instance.new("Atmosphere")
            at.Name = "Pool_Atmosphere"
            at.Density = 0.22
            at.Offset = 0
            at.Color = Color3.fromRGB(210, 230, 238)
            at.Decay = Color3.fromRGB(150, 180, 190)
            at.Glare = 0
            at.Haze = 0.9
            at.Parent = Lighting
        end)
    end

    local function envRestore()
        local s = POOL.saved
        if not s then return end
        POOL.saved = nil
        for _, k in ipairs(LIGHT_PROPS) do
            if s[k] ~= nil then pcall(function() Lighting[k] = s[k] end) end
        end
        if s.Technology ~= nil then
            pcall(function() sethiddenproperty(Lighting, "Technology", s.Technology) end)
        end
    end

    function POOL.clear(silent)
        POOL.token += 1
        local S = POOL.S
        POOL.S = nil
        if S then
            if S.conn then pcall(function() S.conn:Disconnect() end) end
            if S.folder then pcall(function() S.folder:Destroy() end) end
        end
        for _, n in ipairs({ "Pool_CC", "Pool_Bloom", "Pool_Rays", "Pool_Atmosphere" }) do
            local o = Lighting:FindFirstChild(n)
            if o then o:Destroy() end
        end
        for _, a in ipairs(POOL.hidden) do
            pcall(function() a.Parent = Lighting end)
        end
        POOL.hidden = {}
        envRestore()
        if S and not silent then notify("Poolrooms", "Poolrooms removidas.") end
        return true
    end

    function POOL.spawn(partnerName)
        notify("Poolrooms", "Gerando Poolrooms infinitas...")
        POOL.clear(true)
        if workspace:FindFirstChild("Backrooms_Level0") then pcall(clearBackrooms) end
        local myToken = POOL.token

        local S = { chunks = {}, count = 0, tex = WALL_TEX, token = myToken }
        POOL.S = S
        local folder = Instance.new("Folder")
        folder.Name = "Poolrooms_Level"
        folder.Parent = workspace
        S.folder = folder

        pcall(function() S.tex = resolveImage(WALL_TEX) end)
        if POOL.token ~= myToken then return end

        POOL.saved = envSave()
        envApply()

        streamStep(S, 0, 0, 1)
        if POOL.token ~= myToken then return end

        local spawnCF = CFrame.new(16, POOL_Y + 6, 16)
        local function teleportMe()
            local chr = LocalPlayer.Character
            local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Anchored = true
                hrp.CFrame = spawnCF
                task.wait(0.3)
                hrp.Anchored = false
            end
        end
        teleportMe()
        if partnerName and partnerName ~= "" then
            local partner = Players:FindFirstChild(partnerName)
            if partner and partner.Character and partner.Character:FindFirstChild("HumanoidRootPart") then
                partner.Character.HumanoidRootPart.CFrame = spawnCF + Vector3.new(3, 0, 3)
            end
        end

        S.conn = LocalPlayer.CharacterAdded:Connect(function(c)
            local h = c:WaitForChild("HumanoidRootPart", 10)
            if h and POOL.token == myToken then
                task.wait(0.5)
                pcall(streamStep, S, 0, 0, 1)
                if POOL.token ~= myToken then return end
                h.AssemblyLinearVelocity = Vector3.zero
                h.CFrame = spawnCF
            end
        end)

        task.spawn(function()
            while POOL.token == myToken do
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h then
                    local y = h.Position.Y
                    local inPool = y > POOL_Y - 40 and y < POOL_Y + 300
                    local pcx, pcz = 0, 0
                    if inPool then
                        pcx = math.floor((h.Position.X + CH / 2) / CH)
                        pcz = math.floor((h.Position.Z + CH / 2) / CH)
                    end
                    pcall(streamStep, S, pcx, pcz, RADIUS)
                    pcall(updateLights, S, inPool and h.Position or spawnCF.Position)
                    if y < POOL_Y - 20 and y > POOL_Y - 600 then
                        pcall(streamStep, S, 0, 0, 1)
                        h.AssemblyLinearVelocity = Vector3.zero
                        h.CFrame = spawnCF
                    end
                end
                task.wait(0.35)
            end
        end)

        task.spawn(function()
            local fx = Instance.new("Folder")
            fx.Name = "Ripples"
            fx.Parent = folder
            local function ring(x, z, size, life)
                local r = Instance.new("Part")
                r.Shape = Enum.PartType.Cylinder
                r.Anchored, r.CanCollide, r.CanQuery, r.CanTouch, r.CastShadow = true, false, false, false, false
                r.Material = Enum.Material.SmoothPlastic
                r.Color = Color3.fromRGB(225, 250, 248)
                r.Transparency = 0.55
                r.Size = Vector3.new(0.05, 0.6, 0.6)
                r.CFrame = CFrame.new(x, POOL_Y + WATER_H + 0.04, z) * CFrame.Angles(0, 0, math.rad(90))
                r.Parent = fx
                TweenService:Create(r, TweenInfo.new(life, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Size = Vector3.new(0.05, size, size),
                    Transparency = 1,
                }):Play()
                Debris:AddItem(r, life + 0.1)
            end
            local lastDrop = 0
            while POOL.token == myToken do
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h and h.Position.Y < POOL_Y + WATER_H + 5 then
                    local p = h.Position
                    local sp = Vector3.new(h.AssemblyLinearVelocity.X, 0, h.AssemblyLinearVelocity.Z).Magnitude
                    if sp > 4 then ring(p.X, p.Z, 4.5, 1.1) end
                    if os.clock() - lastDrop > 0.9 then
                        lastDrop = os.clock()
                        ring(p.X + math.random(-30, 30), p.Z + math.random(-30, 30), 5, 2.2)
                    end
                end
                task.wait(0.3)
            end
        end)

        notify("Poolrooms", "Pronto! Poolrooms infinitas.")
        return true
    end
end

-- ================== FLASH & AURA (REDE) ==================
local FXNET = {
    flash = {},
    aura  = {},
    actions = { FLASH_ON = true, FLASH_OFF = true, AURA_ON = true, AURA_OFF = true },
}

do
    local Debris         = game:GetService("Debris")
    local TweenService   = game:GetService("TweenService")
    local rand           = math.random
    local function rr(a, b) return a + (b - a) * rand() end

    local GOLD   = Color3.fromRGB(255, 200, 0)
    local BRIGHT = Color3.fromRGB(255, 235, 110)
    local CORE   = Color3.fromRGB(255, 248, 200)
    local ORANGE = Color3.fromRGB(255, 140, 0)

    local function fxFolder()
        local cam = workspace.CurrentCamera
        local f = cam:FindFirstChild("F1L_FX")
        if not f then
            f = Instance.new("Folder")
            f.Name = "F1L_FX"
            f.Parent = cam
        end
        return f
    end

    local function clearObjs(st)
        for _, o in ipairs(st.objs) do pcall(function() o:Destroy() end) end
        st.objs = {}
    end

    local function bolt(p0, p1, thick, straight)
        local dist = (p1 - p0).Magnitude
        if dist < 0.5 then return end
        local segs = math.clamp(math.floor(dist * 1.6), 5, 24)
        local cf = CFrame.lookAt(p0, p1)
        local jit = dist * (straight and 0.01 or 0.075)

        local part = Instance.new("Part")
        part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
        part.Transparency = 1
        part.Size = Vector3.new(0.1, 0.1, 0.1)
        part.CFrame = CFrame.new(p0)
        part.Parent = fxFolder()

        local atts = {}
        for i = 0, segs do
            local j = (i == 0 or i == segs) and 0 or jit
            local a = Instance.new("Attachment")
            a.Parent = part
            a.WorldPosition = p0:Lerp(p1, i / segs)
                + cf.RightVector * (rand() - 0.5) * 2 * j
                + cf.UpVector * (rand() - 0.5) * 2 * j
            atts[i + 1] = a
        end

        for i = 1, segs do
            for _, L in ipairs({
                { Color3.fromRGB(255, 215, 40), 0.55 * thick, 0.6 },
                { Color3.new(1, 1, 1),          0.14 * thick, 0   },
            }) do
                local b = Instance.new("Beam")
                b.Attachment0, b.Attachment1 = atts[i], atts[i + 1]
                b.Segments, b.FaceCamera = 1, true
                b.Color = ColorSequence.new(L[1])
                b.LightEmission, b.LightInfluence = 1, 0
                b.Width0, b.Width1 = L[2], L[2]
                b.Transparency = NumberSequence.new(L[3])
                b.Parent = part
            end
        end
        Debris:AddItem(part, rr(0.07, 0.13))
    end

    local function flashApply(plr, st)
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not root then return end

        clearObjs(st)
        st.char = char
        local function keep(o) table.insert(st.objs, o) return o end

        if plr == LocalPlayer and hum then hum.WalkSpeed = 200 end

        local att = keep(Instance.new("Attachment"))
        att.Parent = root
        local em = Instance.new("ParticleEmitter")
        em.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 230, 60)),
            ColorSequenceKeypoint.new(1, ORANGE),
        })
        em.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
        em.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
        em.Rate, em.Lifetime, em.Speed = 60, NumberRange.new(0.1, 0.3), NumberRange.new(8, 20)
        em.SpreadAngle = Vector2.new(360, 360)
        em.LightEmission = 1
        em.Parent = att

        local top = keep(Instance.new("Attachment"))
        top.Position = Vector3.new(0, 2, 0)
        top.Parent = root
        local bot = keep(Instance.new("Attachment"))
        bot.Position = Vector3.new(0, -2, 0)
        bot.Parent = root
        local trail = keep(Instance.new("Trail"))
        trail.Attachment0, trail.Attachment1 = top, bot
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 220, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 0)),
        })
        trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
        trail.LightEmission, trail.Lifetime, trail.MinLength = 1, 0.3, 0.01
        trail.Parent = root

        local light = keep(Instance.new("PointLight"))
        light.Color, light.Brightness, light.Range = Color3.fromRGB(255, 220, 60), 3, 14
        light.Parent = root

        local hl = keep(Instance.new("Highlight"))
        hl.FillColor, hl.OutlineColor = Color3.fromRGB(255, 220, 40), Color3.new(1, 1, 1)
        hl.FillTransparency, hl.OutlineTransparency = 0.88, 0.3
        hl.DepthMode = Enum.HighlightDepthMode.Occluded
        hl.Parent = char

        task.spawn(function()
            while FXNET.flash[plr.Name] == st and st.char == char and root.Parent do
                local vel = root.AssemblyLinearVelocity
                local speed = vel.Magnitude
                local qtd = speed > 25 and 3 or (speed > 5 and 2 or 1)

                for _ = 1, qtd do
                    local origem = root.Position + Vector3.new(rr(-1.3, 1.3), rr(-2.6, 2.2), rr(-1.3, 1.3))
                    local rnd = Vector3.new(rand() - 0.5, rand() - 0.5, rand() - 0.5)
                    if rnd.Magnitude < 0.01 then rnd = Vector3.new(0, 1, 0) end
                    local velH = Vector3.new(vel.X, 0, vel.Z)

                    if velH.Magnitude > 20 then
                        local dir = (-velH.Unit + rnd.Unit * 0.06).Unit
                        bolt(origem, origem + dir * rr(18, 36), rr(0.9, 1.3), true)
                    else
                        local dir = rnd.Unit
                        if speed > 5 then dir = (dir * 0.8 - vel.Unit * 0.9).Unit end
                        bolt(origem, origem + dir * rr(10, 20), rr(0.8, 1.3), false)
                    end
                end

                light.Brightness = rr(2, 6)
                hl.FillTransparency = rr(0.78, 0.93)
                task.wait(rr(0.03, 0.07))
            end
        end)
    end

    function FXNET.flashOn(plr)
        if not plr or FXNET.flash[plr.Name] then return end
        local st = { objs = {} }
        FXNET.flash[plr.Name] = st
        st.conn = plr.CharacterAdded:Connect(function(c)
            c:WaitForChild("HumanoidRootPart", 10)
            task.wait(0.5)
            if FXNET.flash[plr.Name] == st then flashApply(plr, st) end
        end)
        flashApply(plr, st)
    end

    function FXNET.flashOff(name)
        local st = FXNET.flash[name]
        if not st then return end
        FXNET.flash[name] = nil
        if st.conn then st.conn:Disconnect() end
        clearObjs(st)
        local plr = Players:FindFirstChild(name)
        if plr == LocalPlayer then
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end

    local function column(groundPos, height, thick)
        local part = Instance.new("Part")
        part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
        part.Transparency = 1
        part.Size = Vector3.new(0.1, 0.1, 0.1)
        part.CFrame = CFrame.new(groundPos)
        part.Parent = fxFolder()

        local a0 = Instance.new("Attachment")
        a0.Parent = part
        local a1 = Instance.new("Attachment")
        a1.Position = Vector3.new(rr(-0.7, 0.7), height, rr(-0.7, 0.7))
        a1.Parent = part

        for _, L in ipairs({
            { GOLD, 0.55 * thick, 0.05, 0.5, 1 },
            { CORE, 0.16 * thick, 0,    0,   0.8 },
        }) do
            local b = Instance.new("Beam")
            b.Attachment0, b.Attachment1 = a0, a1
            b.Segments, b.FaceCamera = 1, true
            b.Color = ColorSequence.new(L[1])
            b.LightEmission, b.LightInfluence = 1, 0
            b.Width0, b.Width1 = L[2], L[3]
            b.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, L[4]), NumberSequenceKeypoint.new(1, L[5]) })
            b.Parent = part
        end
        Debris:AddItem(part, 0.35)
    end

    local function wave(groundPos, finalSize)
        local w = Instance.new("Part")
        w.Shape = Enum.PartType.Cylinder
        w.Anchored, w.CanCollide, w.CanQuery, w.CanTouch = true, false, false, false
        w.Material, w.Color, w.Transparency = Enum.Material.Neon, GOLD, 0.3
        w.Size = Vector3.new(0.2, 4, 4)
        w.CFrame = CFrame.new(groundPos + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.rad(90))
        w.Parent = fxFolder()
        TweenService:Create(w, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.2, finalSize, finalSize),
            Transparency = 1,
        }):Play()
        Debris:AddItem(w, 1)
    end

    local function auraApply(plr, st)
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        clearObjs(st)
        st.char = char
        local function keep(o) table.insert(st.objs, o) return o end

        local groundDist = hum.RigType == Enum.HumanoidRigType.R6 and 3 or (hum.HipHeight + root.Size.Y / 2)

        local hl = keep(Instance.new("Highlight"))
        hl.FillColor, hl.OutlineColor = GOLD, BRIGHT
        hl.FillTransparency, hl.OutlineTransparency = 0.8, 0.1
        hl.DepthMode = Enum.HighlightDepthMode.Occluded
        hl.Parent = char

        local light = keep(Instance.new("PointLight"))
        light.Color, light.Brightness, light.Range = GOLD, 4, 24
        light.Parent = root

        local parts = {}
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then table.insert(parts, p) end
        end
        local n = math.max(#parts, 1)
        for _, p in ipairs(parts) do
            local att = keep(Instance.new("Attachment"))
            att.Parent = p
            local s = math.clamp(p.Size.Magnitude * 0.9, 1.2, 3)
            local fl = Instance.new("ParticleEmitter")
            fl.Texture = "rbxasset://textures/particles/fire_main.dds"
            fl.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CORE),
                ColorSequenceKeypoint.new(0.35, GOLD),
                ColorSequenceKeypoint.new(1, ORANGE),
            })
            fl.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, s), NumberSequenceKeypoint.new(1, 0) })
            fl.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
            fl.Lifetime = NumberRange.new(0.5, 0.9)
            fl.Rate = math.max(2, 130 / n)
            fl.Speed = NumberRange.new(1, 3)
            fl.SpreadAngle = Vector2.new(12, 12)
            fl.EmissionDirection = Enum.NormalId.Top
            fl.Acceleration = Vector3.new(0, 7, 0)
            fl.Rotation, fl.RotSpeed = NumberRange.new(0, 360), NumberRange.new(-30, 30)
            fl.LightEmission = 1
            fl.LockedToPart = false
            fl.Parent = att
        end

        local attRoot = keep(Instance.new("Attachment"))
        attRoot.Parent = root

        local fog = Instance.new("ParticleEmitter")
        fog.Texture = "rbxasset://textures/particles/smoke_main.dds"
        fog.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, BRIGHT),
            ColorSequenceKeypoint.new(0.5, GOLD),
            ColorSequenceKeypoint.new(1, ORANGE),
        })
        fog.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 9) })
        fog.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1) })
        fog.Lifetime, fog.Rate, fog.Speed = NumberRange.new(0.7, 1.2), 34, NumberRange.new(2, 5)
        fog.SpreadAngle = Vector2.new(30, 30)
        fog.EmissionDirection = Enum.NormalId.Top
        fog.LightEmission = 1
        fog.Rotation, fog.RotSpeed = NumberRange.new(0, 360), NumberRange.new(-40, 40)
        fog.Parent = attRoot

        local sp = Instance.new("ParticleEmitter")
        sp.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.4, GOLD),
            ColorSequenceKeypoint.new(1, ORANGE),
        })
        sp.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0) })
        sp.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
        sp.Lifetime, sp.Rate, sp.Speed = NumberRange.new(0.9, 1.8), 55, NumberRange.new(5, 14)
        sp.SpreadAngle = Vector2.new(40, 40)
        sp.EmissionDirection = Enum.NormalId.Top
        sp.Acceleration = Vector3.new(0, 5, 0)
        sp.LightEmission = 1
        sp.Parent = attRoot

        local function ring(d, t, off)
            local a = keep(Instance.new("Part"))
            a.Shape = Enum.PartType.Cylinder
            a.Size = Vector3.new(0.2, d, d)
            a.Material, a.Color, a.Transparency = Enum.Material.Neon, GOLD, t
            a.CanCollide, a.CanQuery, a.CanTouch, a.Massless = false, false, false, true
            a.CFrame = root.CFrame * CFrame.new(0, -(groundDist - off), 0) * CFrame.Angles(0, 0, math.rad(90))
            a.Parent = char
            local w = Instance.new("WeldConstraint")
            w.Part0, w.Part1, w.Parent = root, a, a
            return a
        end
        local r1, r2 = ring(6, 0.5, 0), ring(9, 0.7, 0.05)

        if plr == LocalPlayer then
            local bloom = keep(Instance.new("BloomEffect"))
            bloom.Intensity, bloom.Size, bloom.Threshold = 0.8, 28, 0.85
            bloom.Parent = Lighting
        end

        task.spawn(function()
            local tc, tw = 0, 0
            while FXNET.aura[plr.Name] == st and st.char == char and root.Parent do
                local dt = task.wait()
                local pulse = (math.sin(os.clock() * 4) + 1) / 2

                hl.FillTransparency = 0.7 + 0.2 * pulse
                light.Brightness = 3 + 3 * pulse
                local d1, d2 = 6 + 1.2 * pulse, 9 + 1.5 * (1 - pulse)
                r1.Size, r2.Size = Vector3.new(0.2, d1, d1), Vector3.new(0.2, d2, d2)
                r1.Transparency, r2.Transparency = 0.4 + 0.35 * pulse, 0.6 + 0.3 * (1 - pulse)

                local ground = root.Position - Vector3.new(0, groundDist, 0)

                tc += dt
                if tc >= 0.05 then
                    tc = 0
                    for _ = 1, 3 do
                        local ang, rad = rand() * math.pi * 2, rr(1.8, 3.8)
                        column(ground + Vector3.new(math.cos(ang) * rad, 0, math.sin(ang) * rad), rr(7, 16) * 1.4, rr(0.8, 1.3))
                    end
                end

                tw += dt
                if tw >= 1.1 then
                    tw = 0
                    wave(ground, 34)
                end
            end
        end)
    end

    function FXNET.auraOn(plr)
        if not plr or FXNET.aura[plr.Name] then return end
        local st = { objs = {} }
        FXNET.aura[plr.Name] = st
        st.conn = plr.CharacterAdded:Connect(function(c)
            c:WaitForChild("HumanoidRootPart", 10)
            c:WaitForChild("Humanoid", 10)
            task.wait(0.6)
            if FXNET.aura[plr.Name] == st then auraApply(plr, st) end
        end)
        auraApply(plr, st)
    end

    function FXNET.auraOff(name)
        local st = FXNET.aura[name]
        if not st then return end
        FXNET.aura[name] = nil
        if st.conn then st.conn:Disconnect() end
        clearObjs(st)
    end

    function FXNET.run(action, name)
        if not name or name == "" then return end
        local isOn = action:sub(-3) == "_ON"
        local kind = action:sub(1, 5) == "FLASH" and "flash" or "aura"

        local targets = {}
        if name == "ALL" then
            if isOn then
                for n in pairs(activeScriptUsers) do table.insert(targets, n) end
            else
                for n in pairs(FXNET[kind]) do table.insert(targets, n) end
            end
        else
            targets = { name }
        end

        for _, n in ipairs(targets) do
            if isOn then
                local plr = Players:FindFirstChild(n)
                if plr then FXNET[kind .. "On"](plr) end
            else
                FXNET[kind .. "Off"](n)
            end
        end
    end

    function FXNET.send(action, name)
        if not name or name == "" then return end
        FXNET.run(action, name)
        sendNetCmd(";" .. action .. " " .. name)
        notify("Hub", action .. " → " .. name)
    end

    Players.PlayerRemoving:Connect(function(p)
        FXNET.flashOff(p.Name)
        FXNET.auraOff(p.Name)
    end)
end

-- ================== BRAINROT + PATCH v37 ==================
local BRAIN = { token = 0, S = nil, saved = nil, hidden = {}, count = 0, cache = {} }

do
    local Debris = game:GetService("Debris")

    local GY, W, L           = 3000, 320, 460
    local FEET               = GY + 0.4
    local WALL_T, WALL_H     = 8, 34
    local GATE, CARPET_W     = 34, 26
    local BASE_W, BASE_D     = 62, 64
    local BASE_X             = 100
    local BASE_Z             = { 150, 50, -50, -150 }
    local WALK_SPEED         = 11
    local START_MONEY        = 2e12

    local C_GRASS  = Color3.fromRGB(58, 196, 72)
    local C_CARPET = Color3.fromRGB(226, 62, 62)
    local C_DIRT   = Color3.fromRGB(118, 78, 48)
    local C_STONE  = Color3.fromRGB(112, 116, 122)
    local C_GRAY   = Color3.fromRGB(125, 132, 142)
    local C_FLOOR  = Color3.fromRGB(70, 76, 84)
    local C_NAVY   = Color3.fromRGB(36, 46, 60)
    local C_BROWN  = Color3.fromRGB(118, 80, 48)
    local C_TAN    = Color3.fromRGB(222, 152, 96)
    local C_WHITE  = Color3.fromRGB(245, 245, 245)
    local C_WOOD   = Color3.fromRGB(150, 100, 60)
    local C_GLASS  = Color3.fromRGB(150, 205, 235)

    local BRAINROTS = {
        { name = "Noobini Pizzanini", rarity = "Common", rc = Color3.fromRGB(90, 230, 90), inc = 1, price = 25, w = 55,
          asset = 88544724314302, sound = 110659131769092, yaw = 0, col = Color3.fromRGB(240, 225, 70), col2 = Color3.fromRGB(70, 160, 255) },
        { name = "67", rarity = "Secret", rc = Color3.fromRGB(255, 70, 200), inc = 7.5e6, price = 1.25e9, w = 30,
          asset = 189020661701506, sound = 106000088638410, yaw = 0, col = Color3.fromRGB(60, 60, 70), col2 = Color3.fromRGB(240, 240, 240) },
        { name = "Strawberry Elephant", rarity = "Secret", rc = Color3.fromRGB(255, 70, 200), inc = 7.5e8, price = 7.5e11, w = 15,
          asset = 248295212434663, sound = 89155583651513, yaw = 0, col = Color3.fromRGB(255, 120, 150), col2 = Color3.fromRGB(255, 190, 205) },
    }
    local NPC_NAMES = { "ttpitd", "Kaio_9", "Mimi", "Rafa2k", "Lunna", "Dudu", "Zeca" }
    local LIGHT_PROPS = {
        "Ambient", "OutdoorAmbient", "Brightness", "ClockTime", "FogStart", "FogEnd", "FogColor",
        "GlobalShadows", "ExposureCompensation", "ColorShift_Top", "ColorShift_Bottom",
        "EnvironmentDiffuseScale", "EnvironmentSpecularScale",
    }

    local function fmt(n)
        local units = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
        for _, u in ipairs(units) do
            if n >= u[1] then
                local s = string.format("%.2f", n / u[1])
                s = (s:gsub("(%..-)0+$", "%1"))
                s = (s:gsub("%.$", ""))
                return s .. u[2]
            end
        end
        return tostring(math.floor(n))
    end

    local function pickDef(maxTier)
        local pool, total = {}, 0
        for i, d in ipairs(BRAINROTS) do
            if not maxTier or i <= maxTier then
                table.insert(pool, d)
                total += d.w
            end
        end
        local r = math.random() * total
        for _, d in ipairs(pool) do
            r -= d.w
            if r <= 0 then return d end
        end
        return pool[1]
    end

    local function mk(parent, size, cf, color, mat, collide)
        local p = Instance.new("Part")
        p.Anchored = true
        p.Size = size
        p.CFrame = cf
        p.Color = color
        p.Material = mat or Enum.Material.SmoothPlastic
        p.CanCollide = collide ~= false
        p.TopSurface = Enum.SurfaceType.Smooth
        p.BottomSurface = Enum.SurfaceType.Smooth
        p.Parent = parent
        BRAIN.count += 1
        if BRAIN.count % 60 == 0 then task.wait() end
        return p
    end

    local function textSurface(part, face, lines, color)
        local sg = Instance.new("SurfaceGui")
        sg.Face = face
        sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        sg.PixelsPerStud = 24
        sg.Parent = part
        local n = #lines
        for i, t in ipairs(lines) do
            local lb = Instance.new("TextLabel")
            lb.BackgroundTransparency = 1
            lb.Size = UDim2.new(1, 0, 1 / n, 0)
            lb.Position = UDim2.new(0, 0, (i - 1) / n, 0)
            lb.Text = t
            lb.TextScaled = true
            lb.Font = Enum.Font.GothamBold
            lb.TextColor3 = color
            lb.Parent = sg
        end
    end

    local function billboardText(parent, adornee, offset, lines, size)
        local bb = Instance.new("BillboardGui")
        bb.Size = size or UDim2.new(0, 190, 0, 60)
        bb.StudsOffset = offset
        bb.AlwaysOnTop = false
        bb.MaxDistance = 220
        bb.Adornee = adornee
        bb.Parent = parent
        local n = #lines
        for i, ln in ipairs(lines) do
            local lb = Instance.new("TextLabel")
            lb.BackgroundTransparency = 1
            lb.Size = UDim2.new(1, 0, 1 / n, 0)
            lb.Position = UDim2.new(0, 0, (i - 1) / n, 0)
            lb.Text = ln[1]
            lb.TextColor3 = ln[2]
            lb.TextStrokeTransparency = 0
            lb.Font = Enum.Font.GothamBold
            lb.TextScaled = true
            lb.Parent = bb
        end
    end

    local function buildTerrain(f)
        local ground = mk(f, Vector3.new(W, 4, L), CFrame.new(0, GY - 2, 0), C_GRASS, Enum.Material.Plastic)
        ground.TopSurface = Enum.SurfaceType.Studs
        ground.Name = "Ground"
        local carpet = mk(f, Vector3.new(CARPET_W, 0.4, L), CFrame.new(0, GY + 0.2, 0), C_CARPET, Enum.Material.Plastic)
        carpet.TopSurface = Enum.SurfaceType.Studs
        carpet.Name = "RedCarpet"

        local function wallBox(sx, sz, cx, cz)
            mk(f, Vector3.new(sx, 8, sz), CFrame.new(cx, GY + 4, cz), C_STONE, Enum.Material.Slate)
            mk(f, Vector3.new(sx, WALL_H - 8, sz), CFrame.new(cx, GY + 8 + (WALL_H - 8) / 2, cz), C_DIRT, Enum.Material.Ground)
        end

        local EW = L + WALL_T * 2
        wallBox(WALL_T, EW, -(W / 2 + WALL_T / 2), 0)
        wallBox(WALL_T, EW, (W / 2 + WALL_T / 2), 0)

        local seg = (W - GATE) / 2
        for _, zs in ipairs({ -1, 1 }) do
            local cz = zs * (L / 2 + WALL_T / 2)
            wallBox(seg, WALL_T, -(GATE / 2 + seg / 2), cz)
            wallBox(seg, WALL_T, (GATE / 2 + seg / 2), cz)
            mk(f, Vector3.new(GATE, WALL_H - 16, WALL_T), CFrame.new(0, GY + 16 + (WALL_H - 16) / 2, cz), C_STONE, Enum.Material.Slate)
            for _, sx in ipairs({ -1, 1 }) do
                mk(f, Vector3.new(3, 16, WALL_T + 2), CFrame.new(sx * (GATE / 2 + 1.5), GY + 8, cz), Color3.fromRGB(78, 82, 88), Enum.Material.Slate)
            end
            local tz = zs * (L / 2 + WALL_T + 8)
            local dark = Color3.fromRGB(14, 14, 16)
            mk(f, Vector3.new(GATE, 1, 16), CFrame.new(0, GY - 0.5, tz), dark, Enum.Material.SmoothPlastic)
            mk(f, Vector3.new(GATE + 6, 2, 16), CFrame.new(0, GY + 16, tz), dark, Enum.Material.SmoothPlastic)
            for _, sx in ipairs({ -1, 1 }) do
                mk(f, Vector3.new(2, 16, 16), CFrame.new(sx * (GATE / 2 + 1), GY + 8, tz), dark, Enum.Material.SmoothPlastic)
            end
            mk(f, Vector3.new(GATE + 6, 18, 2), CFrame.new(0, GY + 8, zs * (L / 2 + WALL_T + 16)), Color3.fromRGB(4, 4, 5), Enum.Material.SmoothPlastic)
        end

        local capT = WALL_T + 20
        local capY = GY + WALL_H + 1
        for _, xs in ipairs({ -1, 1 }) do
            local cap = mk(f, Vector3.new(capT, 2, EW + 40), CFrame.new(xs * (W / 2 + capT / 2), capY, 0), C_GRASS, Enum.Material.Plastic)
            cap.TopSurface = Enum.SurfaceType.Studs
        end
        for _, zs in ipairs({ -1, 1 }) do
            local cap = mk(f, Vector3.new(W, 2, capT), CFrame.new(0, capY, zs * (L / 2 + capT / 2)), C_GRASS, Enum.Material.Plastic)
            cap.TopSurface = Enum.SurfaceType.Studs
        end

        local bz = -L / 2 + 1.2
        for _, sx in ipairs({ -1, 1 }) do
            local bx = sx * (GATE / 2 + 16)
            mk(f, Vector3.new(26, 18, 1), CFrame.new(bx, GY + 12, bz - 0.3), C_STONE, Enum.Material.Slate, false)
            local board = mk(f, Vector3.new(24, 16, 1), CFrame.new(bx, GY + 12, bz), Color3.fromRGB(26, 31, 36), Enum.Material.SmoothPlastic, false)
            if sx < 0 then
                textSurface(board, Enum.NormalId.Back, { "TOP BRAINROTS", "1. Bandito Bobrito", "2. Trippi Troppi", "3. Tric Trac Baraboom", "4. Gangster Footera" }, Color3.fromRGB(235, 235, 235))
            else
                textSurface(board, Enum.NormalId.Back, { "COMO JOGAR", "Segure E no brainrot", "para COMPRAR.", "Nas bases dos outros:", "segure E para ROUBAR!" }, Color3.fromRGB(235, 235, 235))
            end
        end

        local pink = Color3.fromRGB(255, 120, 200)
        local az = -L / 2 + 70
        for _, sx in ipairs({ -1, 1 }) do
            mk(f, Vector3.new(3, 20, 3), CFrame.new(sx * (CARPET_W / 2 + 2), GY + 10, az), pink, Enum.Material.SmoothPlastic, false)
        end
        mk(f, Vector3.new(CARPET_W + 7, 3, 3), CFrame.new(0, GY + 21, az), pink, Enum.Material.SmoothPlastic, false)

        local function stall(x, z, yaw)
            local F = CFrame.new(x, GY, z) * CFrame.Angles(0, yaw, 0)
            local function P(size, lx, ly, lz, color, mat)
                return mk(f, size, F * CFrame.new(lx, ly, lz), color, mat, false)
            end
            P(Vector3.new(22, 1, 14), 0, 0.5, 0, Color3.fromRGB(170, 172, 176), Enum.Material.Concrete)
            P(Vector3.new(14, 3, 4), 0, 2.5, 0, C_WOOD, Enum.Material.Wood)
            for _, sx in ipairs({ -1, 1 }) do
                for _, sz in ipairs({ -1, 1 }) do
                    P(Vector3.new(0.6, 9, 0.6), sx * 8, 5.5, sz * 5, C_WOOD, Enum.Material.Wood)
                end
            end
            for i = 0, 7 do
                local c = (i % 2 == 0) and Color3.fromRGB(220, 50, 50) or C_WHITE
                P(Vector3.new(2.2, 0.6, 14), -8.8 + i * 2.5, 10.2, 0, c, Enum.Material.SmoothPlastic)
            end
        end
        stall(-(CARPET_W / 2 + 28), -60, math.pi / 2)
        stall((CARPET_W / 2 + 28), 20, -math.pi / 2)

        local sx0, sz0 = -(CARPET_W / 2 + 22), L / 2 - 120
        local center = Vector3.new(sx0, GY + 9, sz0)
        for i = 0, 15 do
            local a = i * math.pi * 2 / 16
            mk(f, Vector3.new(2, 2, 2), CFrame.new(center + Vector3.new(0, math.sin(a) * 6.5, math.cos(a) * 6.5)), Color3.fromRGB(255, 90, 190), Enum.Material.Neon, false)
        end
        local post = mk(f, Vector3.new(1.4, 9, 1.4), CFrame.new(sx0, GY + 4.5, sz0), C_STONE, Enum.Material.Slate, false)
        billboardText(post, post, Vector3.new(0, 14, 0), {
            { "Candy Spin", Color3.fromRGB(255, 130, 220) },
            { "Free Spin in 2h 56m 20s", Color3.fromRGB(255, 255, 255) },
            { "Robux Shop", Color3.fromRGB(200, 120, 255) },
        }, UDim2.new(0, 230, 0, 70))
    end

    local function studs(p)
        p.TopSurface = Enum.SurfaceType.Studs
        p.FrontSurface = Enum.SurfaceType.Studs
        p.BackSurface = Enum.SurfaceType.Studs
        p.LeftSurface = Enum.SurfaceType.Studs
        p.RightSurface = Enum.SurfaceType.Studs
        return p
    end

    local function buildBase(f, cx, cz, side, label, mine)
        local ang = (side < 0) and math.pi / 2 or -math.pi / 2
        local F = CFrame.new(cx, GY, cz) * CFrame.Angles(0, ang, 0)
        local function P(size, lx, ly, lz, color, mat, collide)
            return mk(f, size, F * CFrame.new(lx, ly, lz), color, mat, collide)
        end
        local halfW, halfD, H = BASE_W / 2, BASE_D / 2, 18
        local PL, SM = Enum.Material.Plastic, Enum.Material.SmoothPlastic

        studs(P(Vector3.new(BASE_W + 4, 1, BASE_D + 4), 0, 0.5, 0, C_GRAY, PL))
        P(Vector3.new(BASE_W - 6, 0.4, BASE_D - 6), 0, 1.2, 0, C_FLOOR, SM)

        for _, sx in ipairs({ -1, 1 }) do
            for _, sz in ipairs({ -1, 1 }) do
                studs(P(Vector3.new(5, H, 5), sx * (halfW - 2.5), 1 + H / 2, sz * (halfD - 2.5), C_GRAY, PL))
            end
        end
        studs(P(Vector3.new(BASE_W + 4, 2, BASE_D + 4), 0, 1 + H + 1, 0, C_GRAY, PL))

        P(Vector3.new(BASE_W - 10, H, 2), 0, 1 + H / 2, -halfD + 1, C_NAVY, SM)
        local wy, ww, wh, th = 1 + 9.5, 34, 11, 1.2
        P(Vector3.new(ww - th * 2, wh - th * 2, 0.3), 0, wy, -halfD + 2.2, C_BROWN, Enum.Material.Wood, false)
        P(Vector3.new(ww, th, 1.4), 0, wy + wh / 2 - th / 2, -halfD + 2.6, C_WHITE, SM, false)
        P(Vector3.new(ww, th, 1.4), 0, wy - wh / 2 + th / 2, -halfD + 2.6, C_WHITE, SM, false)
        for _, sx in ipairs({ -1, 1 }) do
            P(Vector3.new(th, wh, 1.4), sx * (ww / 2 - th / 2), wy, -halfD + 2.6, C_WHITE, SM, false)
        end

        local sideLen = BASE_D - 10
        for _, sx in ipairs({ -1, 1 }) do
            local x = sx * (halfW - 1)
            studs(P(Vector3.new(2, 3, sideLen), x, 1 + 1.5, 0, C_GRAY, PL))
            studs(P(Vector3.new(2, 3, sideLen), x, 1 + H - 1.5, 0, C_GRAY, PL))
            local glass = P(Vector3.new(0.4, H - 6, sideLen - 2.4), x, 1 + 3 + (H - 6) / 2, 0, C_GLASS, Enum.Material.Glass, false)
            glass.Transparency = 0.75
            P(Vector3.new(1.4, 1.2, sideLen), x, 1 + 3 + 0.6, 0, C_WHITE, SM, false)
            P(Vector3.new(1.4, 1.2, sideLen), x, 1 + H - 3 - 0.6, 0, C_WHITE, SM, false)
            for _, sz in ipairs({ -1, 1 }) do
                P(Vector3.new(1.4, H - 6, 1.2), x, 1 + 3 + (H - 6) / 2, sz * (sideLen / 2 - 0.6), C_WHITE, SM, false)
            end
        end

        local gate = 16
        local segW = (BASE_W - 10 - gate) / 2
        for _, sx in ipairs({ -1, 1 }) do
            studs(P(Vector3.new(segW, 3, 2), sx * (gate / 2 + segW / 2), 1 + 1.5, halfD - 1, C_GRAY, PL))
        end

        local c1 = P(Vector3.new(12, 0.3, BASE_D + 2), 0, 1.55, 1, C_CARPET, PL)
        c1.TopSurface = Enum.SurfaceType.Studs
        local c2 = P(Vector3.new(12, 0.4, 9), 0, 0.4, halfD + 6.5, C_CARPET, PL)
        c2.TopSurface = Enum.SurfaceType.Studs

        local cz0 = halfD + 15
        P(Vector3.new(16, 0.2, 16), 0, 0.1, cz0, C_WHITE, SM, false)
        local pad = P(Vector3.new(14, 0.2, 14), 0, 0.3, cz0, Color3.fromRGB(40, 220, 70), SM, false)
        textSurface(pad, Enum.NormalId.Top, { "COLLECT", "ZONE" }, C_WHITE)

        local slots = {}
        local look = F:VectorToWorldSpace(Vector3.new(0, 0, 1))
        for _, lz in ipairs({ 18, 6, -6, -18 }) do
            for _, sx in ipairs({ -1, 1 }) do
                P(Vector3.new(8, 0.3, 8), sx * 12, 1.55, lz, Color3.fromRGB(46, 214, 76), SM, false)
                P(Vector3.new(8, 0.3, 8), sx * 23, 1.55, lz, Color3.fromRGB(122, 128, 136), SM, false)
                table.insert(slots, { pos = (F * CFrame.new(sx * 12, 1.7, lz)).Position, look = look, model = nil })
            end
        end

        for _, lx in ipairs({ -12, 12 }) do
            for _, lz in ipairs({ -16, 0, 16 }) do
                P(Vector3.new(5, 0.8, 2.6), lx, 1 + H - 0.4, lz, Color3.fromRGB(40, 44, 50), SM, false)
                P(Vector3.new(4.2, 0.2, 2), lx, 1 + H - 0.9, lz, C_WHITE, Enum.Material.Neon, false)
            end
        end

        P(Vector3.new(0.3, 6, 0.3), 0, 1 + H - 3, -halfD + 8, Color3.fromRGB(40, 44, 50), SM, false)
        local orb = P(Vector3.new(3, 3, 3), 0, 1 + H - 6.5, -halfD + 8, Color3.fromRGB(255, 214, 64), Enum.Material.Neon, false)
        orb.Shape = Enum.PartType.Ball
        local pl = Instance.new("PointLight")
        pl.Color = Color3.fromRGB(255, 214, 64)
        pl.Range = 18
        pl.Brightness = 1.5
        pl.Parent = orb

        local mp = P(Vector3.new(0.2, 0.2, 0.2), 0, 8, -halfD + 12, C_WHITE, SM, false)
        mp.Transparency = 1
        billboardText(mp, mp, Vector3.new(0, 0, 0), { { "MULTI: 1", C_WHITE } }, UDim2.new(0, 160, 0, 36))

        local sy = 1 + H - 3
        local sign = P(Vector3.new(44, 7, 1.2), 0, sy, halfD + 1.4, C_TAN, PL, false)
        textSurface(sign, Enum.NormalId.Back, { "Base de " .. label }, Color3.fromRGB(255, 244, 228))
        local border = Color3.fromRGB(160, 66, 48)
        studs(P(Vector3.new(45.6, 1.2, 1.8), 0, sy + 4.1, halfD + 1.4, border, PL, false))
        studs(P(Vector3.new(45.6, 1.2, 1.8), 0, sy - 4.1, halfD + 1.4, border, PL, false))
        for _, sx in ipairs({ -1, 1 }) do
            studs(P(Vector3.new(1.2, 9.4, 1.8), sx * 22.8, sy, halfD + 1.4, border, PL, false))
        end

        local result = { slots = slots, label = label }

        if mine then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 360, 0, 150)
            bb.StudsOffset = Vector3.new(0, 11, 0)
            bb.AlwaysOnTop = true
            bb.MaxDistance = 500
            bb.Adornee = sign
            bb.Parent = sign
            local function t(text, y, h)
                local l = Instance.new("TextLabel")
                l.BackgroundTransparency = 1
                l.Size = UDim2.new(1, 0, h, 0)
                l.Position = UDim2.new(0, 0, y, 0)
                l.Text = text
                l.TextScaled = true
                l.Font = Enum.Font.GothamBlack
                l.TextColor3 = C_WHITE
                l.TextStrokeTransparency = 0
                l.Parent = bb
            end
            t("SUA BASE", 0, 0.62)
            t("▼", 0.6, 0.4)

            local gui = Instance.new("BillboardGui")
            gui.Size = UDim2.new(0, 220, 0, 50)
            gui.StudsOffset = Vector3.new(0, 5, 0)
            gui.MaxDistance = 200
            gui.Adornee = pad
            gui.Parent = pad
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.Text = "$0"
            lbl.TextScaled = true
            lbl.Font = Enum.Font.GothamBlack
            lbl.TextColor3 = Color3.fromRGB(255, 225, 80)
            lbl.TextStrokeTransparency = 0
            lbl.Parent = gui
            result.collectLabel = lbl
            result.collectPos = pad.Position
        end
        return result
    end

    local function playSound(id)
        if not id then return end
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://" .. id
            s.Volume = 2
            s.Parent = workspace
            s:Play()
            Debris:AddItem(s, 20)
        end)
    end

    -- >>> PATCH v37 - PASSO 1: substituído loadTemplate <<<
    local function fetchObjects(id)
        local lastErr = "desconhecido"
        for _ = 1, 2 do
            for _, url in ipairs({ "rbxassetid://" .. id, "http://www.roblox.com/asset/?id=" .. id }) do
                local ok, objs = pcall(function() return game:GetObjects(url) end)
                if ok and objs and #objs > 0 then return objs end
                lastErr = ok and "retornou vazio" or tostring(objs)
            end
            local ok2, mdl = pcall(function() return game:GetService("InsertService"):LoadAsset(tonumber(id)) end)
            if ok2 and mdl then
                local kids = mdl:GetChildren()
                if #kids > 0 then return kids end
            end
            task.wait(0.6)
        end
        return nil, lastErr
    end

    local function loadTemplate(def)
        local c = BRAIN.cache[def.asset]
        if c ~= nil then return c or nil end

        local ids = { def.asset }
        for _, a in ipairs(def.alt or {}) do table.insert(ids, a) end

        local tpl, reason
        for _, id in ipairs(ids) do
            local objs, err = fetchObjects(id)
            if objs then
                local m = Instance.new("Model")
                for _, o in ipairs(objs) do o.Parent = m end
                for _, d in ipairs(m:GetDescendants()) do
                    if d:IsA("LuaSourceContainer") or d:IsA("Humanoid") or d:IsA("ProximityPrompt") then
                        pcall(function() d:Destroy() end)
                    end
                end
                for _, d in ipairs(m:GetDescendants()) do
                    if d:IsA("BasePart") then tpl = m break end
                end
                if tpl then break end
                reason = "asset " .. id .. " carregou mas não tem nenhuma peça (BasePart)"
            else
                reason = "asset " .. id .. ": " .. tostring(err)
            end
        end

        if not tpl then
            warn("[Brainrot] " .. def.name .. " -> " .. tostring(reason))
            notify("Brainrot", def.name .. " não carregou (" .. tostring(reason):sub(1, 70) .. "). Veja o F9.")
        end
        BRAIN.cache[def.asset] = tpl or false
        return tpl
    end

    local function makeBrainrot(def, parent)
        local tpl = loadTemplate(def)
        local m = Instance.new("Model")
        m.Name = def.name
        local root = Instance.new("Part")
        root.Name = "Root"
        root.Size = Vector3.new(1, 1, 1)
        root.Transparency = 1
        root.Anchored = true
        root.CanCollide = false
        root.CanTouch = false
        root.Parent = m
        m.PrimaryPart = root

        local height
        if tpl then
            local clone = tpl:Clone()
            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Anchored = true
                    d.CanCollide = false
                end
            end
            clone.Parent = m
            local cf, size = clone:GetBoundingBox()
            root.CFrame = CFrame.new(cf.Position.X, cf.Position.Y - size.Y / 2, cf.Position.Z)
            height = size.Y
        else
            local function part(sz, off, col)
                local p = Instance.new("Part")
                p.Anchored = true
                p.CanCollide = false
                p.Size = sz
                p.Color = col
                p.Material = Enum.Material.SmoothPlastic
                p.TopSurface = Enum.SurfaceType.Smooth
                p.BottomSurface = Enum.SurfaceType.Smooth
                p.CFrame = CFrame.new(off)
                p.Parent = m
                return p
            end
            part(Vector3.new(3.2, 3.6, 2.2), Vector3.new(0, 3.2, 0), def.col)
            part(Vector3.new(3.4, 3, 3), Vector3.new(0, 5.9, 0), def.col2)
            for _, sx in ipairs({ -0.8, 0.8 }) do
                part(Vector3.new(0.9, 0.9, 0.4), Vector3.new(sx, 6.2, -1.5), Color3.new(1, 1, 1))
                part(Vector3.new(0.4, 0.4, 0.2), Vector3.new(sx, 6.2, -1.78), Color3.new(0, 0, 0))
                part(Vector3.new(1, 2, 1), Vector3.new(sx, 1, 0), def.col2)
            end
            root.CFrame = CFrame.new(0, 0, 0)
            height = 7.5
        end

        local anchor = Instance.new("Attachment")
        anchor.Name = "PromptAnchor"
        anchor.Position = Vector3.new(0, height / 2, 0)
        anchor.Parent = root

        local bb = Instance.new("BillboardGui")
        bb.Name = "Info"
        bb.Size = UDim2.new(0, 170, 0, 76)
        bb.StudsOffset = Vector3.new(0, height + 2.5, 0)
        bb.MaxDistance = 160
        bb.Adornee = root
        bb.Parent = root
        local function lab(name, text, color, y)
            local l = Instance.new("TextLabel")
            l.Name = name
            l.BackgroundTransparency = 1
            l.Size = UDim2.new(1, 0, 0.25, 0)
            l.Position = UDim2.new(0, 0, y, 0)
            l.Text = text
            l.TextColor3 = color
            l.TextStrokeTransparency = 0
            l.Font = Enum.Font.GothamBold
            l.TextScaled = true
            l.Parent = bb
        end
        lab("Name", def.name, Color3.new(1, 1, 1), 0)
        lab("Rarity", def.rarity, def.rc, 0.25)
        lab("Inc", "$" .. fmt(def.inc) .. "/s", Color3.fromRGB(90, 255, 110), 0.5)
        lab("Price", "$" .. fmt(def.price), Color3.fromRGB(255, 225, 80), 0.75)
        m.Parent = parent
        return m
    end

    local function setPrompt(model, action, hold, cb)
        local root = model.PrimaryPart
        local anchor = root:FindFirstChild("PromptAnchor") or root
        local old = anchor:FindFirstChildOfClass("ProximityPrompt")
        if old then old:Destroy() end
        local pp = Instance.new("ProximityPrompt")
        pp.ActionText = action
        pp.ObjectText = model.Name
        pp.HoldDuration = hold
        pp.MaxActivationDistance = 14
        pp.RequiresLineOfSight = false
        pp.Parent = anchor
        pp.Triggered:Connect(cb)
        return pp
    end

    local function setPriceText(model, text)
        local info = model.PrimaryPart and model.PrimaryPart:FindFirstChild("Info")
        local l = info and info:FindFirstChild("Price")
        if l then l.Text = text end
    end

    local function setMoney(S)
        if S.hudMoney then S.hudMoney.Text = "  $" .. fmt(S.money) end
        if S.hudInc then S.hudInc.Text = "  +$" .. fmt(S.income) .. "/s" end
    end

    local function updateCollect(S)
        if S.collectLabel then S.collectLabel.Text = "$" .. fmt(S.pending) end
    end

    local function freeSlot(slots)
        for _, s in ipairs(slots) do
            if not s.model then return s end
        end
    end

    local function placeModel(model, slot, def)
        local p = slot.pos
        model:PivotTo(CFrame.lookAt(p, p + slot.look) * CFrame.Angles(0, math.rad(def.yaw or 0), 0))
    end

    local function claimMine(S, model, def, slot)
        slot.model = model
        slot.def = def
        placeModel(model, slot, def)
        S.income += def.inc
        setPriceText(model, "Seu  |  vender $" .. fmt(math.floor(def.price / 2)))
        setMoney(S)
        playSound(def.sound)
        setPrompt(model, "Vender", 0.8, function()
            if slot.model ~= model then return end
            slot.model, slot.def = nil, nil
            S.money += math.floor(def.price / 2)
            S.income -= def.inc
            setMoney(S)
            model:Destroy()
        end)
    end

    local function putNpc(S, base, def, slot)
        local model = makeBrainrot(def, S.folder)
        slot.model = model
        slot.def = def
        placeModel(model, slot, def)
        setPriceText(model, "Base de " .. base.label)
        setPrompt(model, "Roubar", 1.4, function()
            if slot.model ~= model then return end
            local mine = freeSlot(S.mySlots)
            if not mine then notify("Brainrot", "Sua base está cheia!") return end
            slot.model, slot.def = nil, nil
            claimMine(S, model, def, mine)
            notify("Brainrot", "Você roubou " .. def.name .. " de " .. base.label .. "!")
        end)
    end

    local function addWalker(S, z, forced)
        local def = forced or pickDef()
        local model = makeBrainrot(def, S.folder)
        local w = { model = model, def = def, x = math.random(-8, 8), z = z, t = math.random() * 10, gone = false }
        table.insert(S.walkers, w)
        setPrompt(model, "Comprar", 0.4, function()
            if w.gone then return end
            if S.money < def.price then
                notify("Brainrot", "Dinheiro insuficiente ($" .. fmt(def.price) .. ")")
                return
            end
            local slot = freeSlot(S.mySlots)
            if not slot then notify("Brainrot", "Sua base está cheia!") return end
            S.money -= def.price
            w.gone = true
            claimMine(S, model, def, slot)
        end)
    end

    local function makeHud(S)
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "BrainrotHUD"
        sg.ResetOnSpawn = false
        sg.Parent = pg
        local function box(y, size, color)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0, 260, 0, y == 70 and 40 or 26)
            l.Position = UDim2.new(0, 12, 0, y)
            l.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            l.BackgroundTransparency = 0.3
            l.TextColor3 = color
            l.Font = Enum.Font.GothamBlack
            l.TextSize = size
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = sg
            Instance.new("UICorner", l).CornerRadius = UDim.new(0, 8)
            return l
        end
        S.hudMoney = box(70, 24, Color3.fromRGB(90, 255, 110))
        S.hudInc = box(114, 16, Color3.fromRGB(255, 225, 80))
        S.gui = sg
        setMoney(S)
    end

    function BRAIN.clear(silent)
        BRAIN.token += 1
        local S = BRAIN.S
        BRAIN.S = nil
        if S then
            if S.conn then pcall(function() S.conn:Disconnect() end) end
            if S.charConn then pcall(function() S.charConn:Disconnect() end) end
            if S.folder then pcall(function() S.folder:Destroy() end) end
            if S.gui then pcall(function() S.gui:Destroy() end) end
        end
        for _, n in ipairs({ "BR_Sky", "BR_CC" }) do
            local o = Lighting:FindFirstChild(n)
            if o then o:Destroy() end
        end
        for _, a in ipairs(BRAIN.hidden) do
            pcall(function() a.Parent = Lighting end)
        end
        BRAIN.hidden = {}
        local sv = BRAIN.saved
        BRAIN.saved = nil
        if sv then
            for k, v in pairs(sv) do pcall(function() Lighting[k] = v end) end
        end
        if S and not silent then notify("Brainrot", "Mundo removido.") end
        return true
    end

    function BRAIN.spawn()
        notify("Brainrot", "Gerando o mundo...")
        BRAIN.clear(true)
        pcall(POOL.clear, true)
        if workspace:FindFirstChild("Backrooms_Level0") then pcall(clearBackrooms) end
        BRAIN.count = 0
        local myToken = BRAIN.token

        local S = { money = START_MONEY, pending = 0, income = 0, walkers = {}, mySlots = {}, npcBases = {} }
        BRAIN.S = S
        local f = Instance.new("Folder")
        f.Name = "RoubeUmBrainrot_World"
        f.Parent = workspace
        S.folder = f

        BRAIN.saved = {}
        for _, k in ipairs(LIGHT_PROPS) do pcall(function() BRAIN.saved[k] = Lighting[k] end) end
        local function set(k, v) pcall(function() Lighting[k] = v end) end
        set("ClockTime", 14)
        set("Brightness", 2.4)
        set("Ambient", Color3.fromRGB(150, 150, 150))
        set("OutdoorAmbient", Color3.fromRGB(160, 160, 160))
        set("FogStart", 0)
        set("FogEnd", 100000)
        set("GlobalShadows", true)
        set("ExposureCompensation", 0)
        pcall(function()
            for _, c in ipairs(Lighting:GetChildren()) do
                if c:IsA("Atmosphere") or c:IsA("Sky") then
                    table.insert(BRAIN.hidden, c)
                    c.Parent = nil
                end
            end
        end)
        pcall(function()
            local sky = Instance.new("Sky")
            sky.Name = "BR_Sky"
            sky.Parent = Lighting
            local cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "BR_CC"
            cc.Saturation = 0.12
            cc.Contrast = 0.04
            cc.Parent = Lighting
        end)

        buildTerrain(f)
        if BRAIN.token ~= myToken then return end

        local safety = mk(f, Vector3.new(W + 600, 4, L + 600), CFrame.new(0, GY - 70, 0), C_GRASS, Enum.Material.Plastic)
        safety.Transparency = 1
        safety.Name = "SafetyNet"

        for _, d in ipairs(BRAINROTS) do pcall(loadTemplate, d) end
        if BRAIN.token ~= myToken then return end

        local ni, idx = 0, 0
        for _, side in ipairs({ -1, 1 }) do
            for _, bz in ipairs(BASE_Z) do
                idx += 1
                local label
                if idx == 1 then
                    label = LocalPlayer.DisplayName
                else
                    ni += 1
                    label = NPC_NAMES[ni] or ("Player" .. ni)
                end
                local base = buildBase(f, side * BASE_X, bz, side, label, idx == 1)
                if idx == 1 then
                    S.mySlots = base.slots
                    S.collectLabel = base.collectLabel
                    S.collectPos = base.collectPos
                else
                    table.insert(S.npcBases, base)
                end
                if BRAIN.token ~= myToken then return end
            end
        end

        makeHud(S)

        for _, base in ipairs(S.npcBases) do
            for i = 1, math.random(2, 3) do
                local slot = freeSlot(base.slots)
                if slot then putNpc(S, base, pickDef(2), slot) end
            end
        end

        addWalker(S, L / 2 - 150, BRAINROTS[1])
        addWalker(S, L / 2 - 105, BRAINROTS[2])
        addWalker(S, L / 2 - 60, BRAINROTS[3])
        for i = 0, 2 do
            addWalker(S, -L / 2 + 30 + i * 70)
        end

        local startPos = Vector3.new(0, GY + 4, L / 2 - 20)
        local startCF = CFrame.lookAt(startPos, Vector3.new(0, GY + 4, 0))
        local function teleportMe()
            local chr = LocalPlayer.Character
            local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Anchored = true
                hrp.CFrame = startCF
                task.wait(0.3)
                hrp.Anchored = false
            end
        end
        teleportMe()
        S.charConn = LocalPlayer.CharacterAdded:Connect(function(c)
            local h = c:WaitForChild("HumanoidRootPart", 10)
            if h and BRAIN.token == myToken then
                task.wait(0.5)
                h.AssemblyLinearVelocity = Vector3.zero
                h.CFrame = startCF
            end
        end)

        S.conn = RunService.Heartbeat:Connect(function(dt)
            local pc = LocalPlayer.Character
            local ph = pc and pc:FindFirstChild("HumanoidRootPart")
            if ph then
                if ph.Position.Y < GY - 40 and ph.Position.Y > GY - 400 then
                    ph.AssemblyLinearVelocity = Vector3.zero
                    ph.CFrame = startCF
                end
                if S.collectPos and S.pending > 0 then
                    local d = ph.Position - S.collectPos
                    if math.abs(d.X) < 8 and math.abs(d.Z) < 8 and math.abs(d.Y) < 8 then
                        S.money += S.pending
                        notify("Brainrot", "Coletou $" .. fmt(S.pending))
                        S.pending = 0
                        updateCollect(S)
                        setMoney(S)
                    end
                end
            end
            for i = #S.walkers, 1, -1 do
                local w = S.walkers[i]
                if w.gone then
                    table.remove(S.walkers, i)
                else
                    w.z += WALK_SPEED * dt
                    w.t += dt
                    if w.z > L / 2 - 10 then
                        w.gone = true
                        w.model:Destroy()
                        table.remove(S.walkers, i)
                    else
                        local bob = math.abs(math.sin(w.t * 8)) * 0.4
                        local p = Vector3.new(w.x, FEET + bob, w.z)
                        w.model:PivotTo(CFrame.lookAt(p, p + Vector3.new(0, 0, 1)) * CFrame.Angles(0, math.rad(w.def.yaw or 0), 0))
                    end
                end
            end
        end)

        task.spawn(function()
            local t2, t3 = 0, 0
            while BRAIN.token == myToken do
                task.wait(1)
                t2 += 1
                t3 += 1
                S.pending += S.income
                updateCollect(S)
                if t2 >= 4 then
                    t2 = 0
                    if #S.walkers < 10 then addWalker(S, -L / 2 + 14) end
                end
                if t3 >= 20 then
                    t3 = 0
                    local base = S.npcBases[math.random(#S.npcBases)]
                    local slot = base and freeSlot(base.slots)
                    if slot then putNpc(S, base, pickDef(2), slot) end
                end
            end
        end)

        notify("Brainrot", "Pronto! Segure E nos brainrots. Fique na ZONA DE COLETA pra pegar o dinheiro.")
        return true
    end
end

local function roubeUmBrainrot(modo)
    modo = modo and string.upper(modo) or (BRAIN.S and "OFF" or "ON")
    if modo == "OFF" then BRAIN.clear() else BRAIN.spawn() end
end

-- TORNADO isolado em "do ... end" (evita estourar o limite de 200 locals do Lua)
local TORNADO = { token = 0, S = nil }
do

--==============================================================
-- TORNADO HIPER-REALISTA ULTRA EF-5 (V4 - SEM GUI, COM NUVENS E RELÂMPAGOS)
-- Comandos: tornado("OFF") / tornado("ON") / tornado()
-- Sem GUI. Relâmpagos dentro das nuvens (som 6955233353)
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

--==============================================================
-- CONFIG
--==============================================================
local HEIGHT = 1400
local FUNNEL_LAYERS = 42
local OUTER_POINTS = 8      -- camada externa (clara)
local CORE_POINTS  = 4      -- núcleo interno (escuro)
local EYE_RINGS = 5
local EYE_RING_POINTS = 14

local DEBRIS_SKIRT = 24
local DEBRIS_PLUME = 30
local DEBRIS_GRIT  = 20

local START_DISTANCE = 520
local MOVE_SPEED = 14
local MAX_KMH = 580

local PULL_PLAYER = true
local PULL_PARTS  = true
local MAX_PULLED_PARTS = 350   -- máximo de peças soltas ao mesmo tempo

-- 💥 DESTRUIÇÃO + 🌬️ VENTO
local DESTROY_FROM_AFAR = true   -- destrói/solta casas e blocos de longe
local WIND_ENABLED = true        -- vento empurra você, peças e cria rajadas na tela
local MAX_PART_SIZE = 220        -- maior peça que o tornado consegue arrancar

-- 🔊 ÁUDIO DO VENTO (mais perto = mais alto / mais longe = mais baixo)
local WIND_SOUND_ID   = "rbxassetid://1102548016"
local WIND_MAX_VOLUME = 3.5      -- volume máximo (colado/dentro do tornado)
local WIND_HEAR_RANGE = 1600   -- distância (studs) em que o som some por completo

local LIGHTNING_SOUND_ID = "rbxassetid://6955233353"

-- ☁️ NUVENS DA SUPERCÉLULA + ⚡ RELÂMPAGOS
local LIGHTNING_ENABLED = true
local DECK_POINTS = { 12, 16, 20, 24 }   -- quantidade de nuvens por anel da camada de tempestade
local SMOKE_TEXTURE = "rbxasset://textures/particles/smoke_main.dds"

local FUNNEL_BOTTOM = Color3.fromRGB(85, 90, 98)
local FUNNEL_MID    = Color3.fromRGB(130, 138, 148)
local FUNNEL_TOP    = Color3.fromRGB(195, 204, 215)
local CLOUD_COLOR   = Color3.fromRGB(110, 118, 128)
local CLOUD_DARK    = Color3.fromRGB(52, 57, 66)
local EYE_COLOR     = Color3.fromRGB(245, 248, 252)

local DIRT_DARK  = Color3.fromRGB(42, 32, 22)
local DIRT_MID   = Color3.fromRGB(75, 58, 40)
local DIRT_LIGHT = Color3.fromRGB(115, 90, 65)

--==============================================================
-- UTIL
--==============================================================
local function randf(a, b) return a + (b - a) * math.random() end
local function lerp(a, b, t) return a + (b - a) * t end
local function smooth(t) t = math.clamp(t, 0, 1) return t * t * (3 - 2 * t) end

-- formato clássico: corda fina embaixo, abrindo em corneta
local function funnelRadius(S, height)
    local n = math.clamp(height / HEIGHT, 0, 1)
    return S.groundRadius + (S.topRadius - S.groundRadius) * (n ^ 1.35)
end

-- inclinação + ondulação do funil (curva S)
local function funnelOffset(S, height)
    local n = math.clamp(height / HEIGHT, 0, 1)
    local forward = -S.direction * 220 * (n ^ 1.25)
    local sideDir = Vector3.new(-S.direction.Z, 0, S.direction.X)
    local side = sideDir * (math.sin(S.time * 0.4 + n * 4.5) * 55 * n
        + math.sin(S.time * 1.1 + n * 11) * 14 * (1 - n) * S.intensity)
    return forward + side
end

-- eixo do tornado na altura y
local function axisAt(S, y)
    local h = math.clamp(y - S.groundY, 0, HEIGHT)
    local off = funnelOffset(S, h)
    return Vector3.new(S.center.X + off.X, y, S.center.Z + off.Z), h
end

-- força do vento (0 a 1) a uma distância d do eixo; mult>1 = alcance maior (brisa)
local function windStrength(S, d, R, mult)
    if not S.touched then return 0 end
    local zone = (R * 2.8 + 180) * (0.4 + 0.6 * S.intensity) * (mult or 1)
    return (math.clamp(1 - d / zone, 0, 1) ^ 0.75) * (0.2 + 0.8 * S.intensity)
end

-- direção do vento: gira em volta + entra em direção ao centro
local function windDirection(rel, d)
    local out = rel / d
    local tangent = Vector3.new(-out.Z, 0, out.X)
    return (tangent * 0.9 - out * 0.45).Unit
end

local function funnelColor(n, core)
    local c = (n < 0.45) and FUNNEL_BOTTOM:Lerp(FUNNEL_MID, n / 0.45)
        or FUNNEL_MID:Lerp(FUNNEL_TOP, (n - 0.45) / 0.55)
    if n < 0.35 then
        c = c:Lerp(DIRT_MID:Lerp(FUNNEL_BOTTOM, 0.4), ((0.35 - n) / 0.35) * 0.7)
    end
    if core then c = Color3.new(c.R * 0.45, c.G * 0.45, c.B * 0.48) end
    return c
end

--==============================================================
-- PONTOS DE PARTÍCULA
--==============================================================
local function newPoint(S)
    local part = Instance.new("Part")
    part.Name = "TornadoParticlePoint"
    part.Size = Vector3.new(1, 1, 1)
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Parent = S.folder
    return part
end

local function createFunnelPoint(S, core)
    local part = newPoint(S)
    local e = Instance.new("ParticleEmitter")
    e.Texture = SMOKE_TEXTURE
    e.Rate = 0
    e.Enabled = false
    e.Speed = core and NumberRange.new(14, 26) or NumberRange.new(8, 16)
    e.SpreadAngle = Vector2.new(40, 40)
    e.Lifetime = core and NumberRange.new(1.8, 2.8) or NumberRange.new(2.4, 3.8)
    e.Rotation = NumberRange.new(0, 360)
    e.RotSpeed = NumberRange.new(-65, 65)
    e.Acceleration = Vector3.new(0, 7, 0)
    e.Drag = 0.5
    e.LightInfluence = 0.85
    e.Transparency = core and NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.45),
        NumberSequenceKeypoint.new(1, 1) })
        or NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.45, 0.6),
        NumberSequenceKeypoint.new(1, 1) })
    e.Parent = part
    return { part = part, emitter = e, core = core }
end

local function createCloudPoint(S)
    local part = newPoint(S)
    local e = Instance.new("ParticleEmitter")
    e.Texture = SMOKE_TEXTURE
    e.Rate = 0
    e.Enabled = false
    e.Speed = NumberRange.new(1, 5)
    e.SpreadAngle = Vector2.new(180, 180)
    e.Lifetime = NumberRange.new(4, 7)
    e.Rotation = NumberRange.new(0, 360)
    e.RotSpeed = NumberRange.new(-20, 20)
    e.Drag = 0.8
    e.LightInfluence = 1
    e.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.55),
        NumberSequenceKeypoint.new(0.5, 0.65),
        NumberSequenceKeypoint.new(1, 1) })
    e.Parent = part
    return { part = part, emitter = e }
end

--==============================================================
-- FUNIL 3D (casca externa + núcleo escuro, partículas em espiral)
--==============================================================
local function updateFunnel(S, dt, refresh)
    for li, layer in ipairs(S.funnel) do
        local height = S.baseHeight + (HEIGHT - S.baseHeight) * layer.nh
        local baseRadius = funnelRadius(S, height)
        local off = funnelOffset(S, height)
        local n = math.clamp(height / HEIGHT, 0, 1)

        local wob = 1 + 0.09 * math.sin(S.time * 1.6 + li * 0.6)
        local radius = baseRadius * wob

        layer.angle += (75 / math.max(radius, 20)) * (1 + 0.6 * S.intensity) * dt

        local cx = S.center.X + off.X
        local cz = S.center.Z + off.Z

        for _, pt in ipairs(layer.points) do
            local rm = pt.core and 0.58 or 1.02
            local sp = pt.core and 1.4 or 1.0
            local a = layer.angle * sp + pt.offset
            local r = radius * rm
            local pos = Vector3.new(cx + math.cos(a) * r, S.groundY + height, cz + math.sin(a) * r)

            local tangent = Vector3.new(-math.sin(a), 0, math.cos(a))
            pt.part.CFrame = CFrame.fromMatrix(pos, Vector3.yAxis, tangent)

            if refresh then
                local e = pt.emitter
                e.Enabled = true
                e.Color = ColorSequence.new(funnelColor(n, pt.core))
                local sz = pt.core and math.clamp(radius * 0.65, 20, 150)
                    or math.clamp(radius * 0.95, 28, 220)
                e.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, sz * 0.5),
                    NumberSequenceKeypoint.new(1, sz * 1.45) })
                e.Rate = pt.core and (6 + 10 * S.intensity) or (10 + 18 * S.intensity)
            end
        end
    end
end

--==============================================================
-- TOPO COM OLHO (anel de nuvens com centro vazio)
--==============================================================
local function updateClouds(S, dt, refresh)
    for k, ring in ipairs(S.cloudLayers) do
        local frac = 0.42 + (k - 1) * (0.68 / math.max(EYE_RINGS - 1, 1))
        local height = HEIGHT + 20 + k * 35
        local radius = S.topRadius * frac
        ring.angle += (0.3 + 0.05 * k) * dt
        local off = funnelOffset(S, HEIGHT)
        for i, pt in ipairs(ring.points) do
            local a = ring.angle + (i - 1) * math.pi * 2 / #ring.points
            pt.part.Position = Vector3.new(
                S.center.X + off.X + math.cos(a) * radius,
                S.groundY + height,
                S.center.Z + off.Z + math.sin(a) * radius)
            if refresh then
                local e = pt.emitter
                e.Enabled = true
                -- anel interno (parede do olho) mais claro; externos escuros de tempestade
                e.Color = ColorSequence.new(k == 1 and EYE_COLOR
                    or CLOUD_COLOR:Lerp(EYE_COLOR, 0.2 * (EYE_RINGS - k) / math.max(EYE_RINGS - 1, 1)))
                local size = math.clamp(S.topRadius * 0.2, 30, 220)
                e.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, size * 0.7),
                    NumberSequenceKeypoint.new(1, size * 1.4) })
                e.Rate = 3 + S.intensity * 4
            end
        end
    end
end

--==============================================================
-- DEBRIS CLOUD MARROM
--==============================================================
local function mkDebrisPoint(S, kind)
    local p = Instance.new("Part")
    p.Name = "TornadoSand"
    p.Size = Vector3.new(1, 1, 1)
    p.Transparency = 1
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Parent = S.debrisFolder

    local e = Instance.new("ParticleEmitter")
    e.Texture = SMOKE_TEXTURE
    e.Rate = 0
    e.Enabled = false
    e.SpreadAngle = Vector2.new(180, 180)
    e.Rotation = NumberRange.new(0, 360)
    e.LightEmission = 0
    e.LightInfluence = 1
    e.Drag = 1.2

    if kind == "skirt" then
        e.Speed = NumberRange.new(2, 9)
        e.Lifetime = NumberRange.new(5, 8)
        e.RotSpeed = NumberRange.new(-20, 20)
        e.Acceleration = Vector3.new(0, 2.5, 0)
        e.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DIRT_DARK),
            ColorSequenceKeypoint.new(0.5, DIRT_MID),
            ColorSequenceKeypoint.new(1, DIRT_MID:Lerp(DIRT_LIGHT, 0.6)) })
        e.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.55),
            NumberSequenceKeypoint.new(0.2, 0.3),
            NumberSequenceKeypoint.new(0.7, 0.55),
            NumberSequenceKeypoint.new(1, 1) })
    elseif kind == "plume" then
        e.Speed = NumberRange.new(3, 12)
        e.Lifetime = NumberRange.new(3.5, 6)
        e.RotSpeed = NumberRange.new(-35, 35)
        e.Acceleration = Vector3.new(0, 6, 0)
        e.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DIRT_DARK:Lerp(DIRT_MID, 0.4)),
            ColorSequenceKeypoint.new(0.6, DIRT_MID),
            ColorSequenceKeypoint.new(1, DIRT_LIGHT) })
        e.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(0.35, 0.42),
            NumberSequenceKeypoint.new(0.75, 0.7),
            NumberSequenceKeypoint.new(1, 1) })
    else
        e.Speed = NumberRange.new(25, 70)
        e.Lifetime = NumberRange.new(0.8, 1.8)
        e.RotSpeed = NumberRange.new(-200, 200)
        e.Acceleration = Vector3.new(0, -4, 0)
        e.Drag = 0.4
        e.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, DIRT_MID),
            ColorSequenceKeypoint.new(1, DIRT_DARK) })
        e.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.25),
            NumberSequenceKeypoint.new(0.6, 0.45),
            NumberSequenceKeypoint.new(1, 1) })
    end

    e.Size = NumberSequence.new(4)
    e.Parent = p

    table.insert(S.dust, {
        kind = kind, part = p, emitter = e,
        angle = math.random() * math.pi * 2,
        rm = (kind == "skirt" and randf(1.0, 1.9))
            or (kind == "plume" and randf(0.55, 1.25)) or randf(0.6, 1.6),
        h = (kind == "skirt" and randf(1, 10))
            or (kind == "plume" and randf(0, 260)) or randf(1, 30),
        speed = randf(0.8, 1.4),
        rise = randf(18, 42),
        phase = math.random() * 6.28,
    })
end

local function createSandCloud(S)
    for _ = 1, DEBRIS_SKIRT do mkDebrisPoint(S, "skirt") end
    for _ = 1, DEBRIS_PLUME do mkDebrisPoint(S, "plume") end
    for _ = 1, DEBRIS_GRIT  do mkDebrisPoint(S, "grit")  end
end

local function updateSandCloud(S, dt, refresh)
    local I = S.intensity
    local gr = math.max(S.groundRadius, 14)
    local active = S.touched
    local dens = active and (0.3 + 0.7 * I) or 0

    for _, d in ipairs(S.dust) do
        local e = d.emitter
        local pos

        if d.kind == "skirt" then
            local r = gr * d.rm + math.sin(S.time * 1.3 + d.phase) * gr * 0.12
            d.angle += d.speed * (60 / math.max(r, 20)) * (0.6 + I) * dt
            local h = d.h + math.sin(S.time * 2 + d.phase) * 2
            pos = Vector3.new(S.center.X + math.cos(d.angle) * r, S.groundY + h,
                S.center.Z + math.sin(d.angle) * r)
            e.Rate = (4 + 12 * I) * dens
            if refresh then
                local s = math.clamp(gr * 0.5, 25, 110)
                e.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, s * 0.6),
                    NumberSequenceKeypoint.new(1, s * 1.5) })
            end

        elseif d.kind == "plume" then
            d.h = (d.h + d.rise * (0.5 + I) * dt) % 280
            local h = d.h
            local r = gr * d.rm * (1 + h / 170)
            d.angle += d.speed * (55 / math.max(r, 20)) * (0.6 + I) * dt
            local off = funnelOffset(S, h)
            pos = Vector3.new(S.center.X + off.X + math.cos(d.angle) * r, S.groundY + h,
                S.center.Z + off.Z + math.sin(d.angle) * r)
            e.Rate = (3 + 9 * I) * dens * (1 - math.clamp(h / 300, 0, 0.7))
            if refresh then
                local s = math.clamp(gr * 0.35 + h * 0.15, 18, 90)
                e.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, s * 0.5),
                    NumberSequenceKeypoint.new(1, s * 1.4) })
            end

        else
            local r = gr * d.rm
            d.angle += d.speed * 2.2 * (60 / math.max(r, 20)) * (0.7 + I) * dt
            local h = d.h + math.sin(S.time * 3 + d.phase) * 6
            pos = Vector3.new(S.center.X + math.cos(d.angle) * r, S.groundY + math.max(h, 1),
                S.center.Z + math.sin(d.angle) * r)
            e.Rate = (15 + 55 * I) * dens
            if refresh then
                e.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.7),
                    NumberSequenceKeypoint.new(0.5, 1.4),
                    NumberSequenceKeypoint.new(1, 0.2) })
            end
        end

        d.part.Position = pos
        e.Enabled = active
    end
end

--==============================================================
-- 🌪️ SUCÇÃO: arrasta, gira em volta e levanta (funciona em qualquer altura)
--==============================================================
local function releasePlayer(S, hum)
    if S.playerPulled then
        S.playerPulled = false
        pcall(function()
            if hum then
                hum.PlatformStand = false
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end

local function updatePlayer(S, dt)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        S.playerPulled = false
        S.playerDist = nil
        return
    end

    local pos = hrp.Position
    local axis, h = axisAt(S, pos.Y)
    local rel = Vector3.new(pos.X - axis.X, 0, pos.Z - axis.Z)
    local d = math.max(rel.Magnitude, 0.5)
    local R = funnelRadius(S, h)
    S.playerDist = d

    local pullR = R * 1.75 + 50
    local inRange = S.touched and d < (S.playerPulled and pullR * 1.3 or pullR)

    if not inRange then
        releasePlayer(S, hum)
        if WIND_ENABLED then
            local f = windStrength(S, d, R, 1)
            if f > 0.02 then
                local push = windDirection(rel, d) * (180 * f) * dt
                hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity
                    + Vector3.new(push.X, 0, push.Z)
            end
        end
        return
    end

    if not S.playerPulled then
        S.playerPulled = true
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
    end
    hum.PlatformStand = true

    local I = S.intensity
    local eyeR = R * 0.35
    local targetVel

    if d < eyeR then
        -- OLHO: calmo, acompanha o centro
        targetVel = Vector3.new(-rel.X * 1.5, 0, -rel.Z * 1.5) + S.direction * MOVE_SPEED
    else
        local out = rel / d
        local tan = Vector3.new(-out.Z, 0, out.X)
        local orbitR = math.max(R * 0.9, 15)
        local radial = math.clamp((orbitR - d) * 0.85, -80, 50)
        local tanSp = 50 + 95 * I
        local upSp = (h < 500) and (28 + 32 * I) or -10
        targetVel = out * radial + tan * tanSp + Vector3.new(0, upSp, 0)
    end

    hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity:Lerp(targetVel, 1 - math.exp(-6 * dt))
    hrp.AssemblyAngularVelocity = Vector3.new(
        math.sin(S.time * 4) * 4, 8 + 12 * I, math.cos(S.time * 3.5) * 4)
end

-- 📷 tremor de câmera perto do tornado
local function updateCameraShake(S, dt)
    local cam = workspace.CurrentCamera
    if not cam or not S.touched then return end
    local cp = cam.CFrame.Position
    local axis, h = axisAt(S, cp.Y)
    local d = (Vector3.new(cp.X, 0, cp.Z) - Vector3.new(axis.X, 0, axis.Z)).Magnitude
    local R = funnelRadius(S, h)

    local danger = R * 3.5 + 160
    if d < danger then
        local f = (1 - d / danger) ^ 1.8 * S.intensity
        local sx = math.sin(S.time * 38) * 0.35 * f
        local sy = math.cos(S.time * 44) * 0.30 * f
        local sz = math.sin(S.time * 50) * 0.25 * f
        local rz = math.sin(S.time * 32) * 0.015 * f
        cam.CFrame = cam.CFrame * CFrame.Angles(sx * 0.05, sy * 0.05, rz) + Vector3.new(sx, sy, sz)
    end
end

local function eligiblePart(p)
    if not p:IsA("BasePart") or p:IsA("Terrain") or p:IsA("SpawnLocation") then return false end
    if p.Name == "TornadoParticlePoint" or p.Name == "TornadoSand" then return false end
    local sz = p.Size
    if math.max(sz.X, sz.Y, sz.Z) > MAX_PART_SIZE then return false end
    -- ignora chão/baseplate (placas finas e enormes)
    if sz.Y < 6 and math.max(sz.X, sz.Z) > 60 then return false end
    if p.Parent and p.Parent:FindFirstChildOfClass("Humanoid") then return false end
    return true
end

-- 1 = peça leve (bloco pequeno) ... perto de 0 = pesada (laje/parede enorme)
local function partLight(p)
    local sz = p.Size
    return 1 / (1 + (sz.X * sz.Y * sz.Z) / 2500)
end

-- nuvenzinha de poeira/lascas quando uma peça se rompe
local function breakPuff(S, p)
    if not S.puffPart or not S.puffEmitter then return end
    local sz = p.Size
    local m = math.max(sz.X, sz.Y, sz.Z)
    if m < 5 then return end
    S.puffPart.Position = p.Position
    S.puffEmitter:Emit(math.clamp(math.floor(m / 4), 2, 8))
end

-- solta a peça da construção (quebra soldas) e destrava
local function loosen(S, p, puff)
    if puff then breakPuff(S, p) end
    pcall(function()
        for _, j in ipairs(p:GetJoints()) do
            if j:IsA("JointInstance") or j:IsA("WeldConstraint") then j:Destroy() end
        end
        p:BreakJoints()
    end)
    p.Anchored = false
end

local function countLoose(S)
    local c = 0
    for _ in pairs(S.pulledSet) do c += 1 end
    return c
end

-- procura peças no alcance do vento e arranca (quanto mais perto, mais rápido)
local function scanParts(S)
    local I = S.intensity
    if I < 0.03 then return end

    local scanR = (funnelRadius(S, 40) * 2.8 + 180) * (0.4 + 0.6 * I)

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ex = { S.folder }
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then table.insert(ex, plr.Character) end
    end
    params.FilterDescendantsInstances = ex
    params.MaxParts = 500

    local parts = workspace:GetPartBoundsInRadius(
        Vector3.new(S.center.X, S.groundY + 40, S.center.Z), scanR, params)

    local count = countLoose(S)
    local added, puffs = 0, 0

    for _, p in ipairs(parts) do
        if added >= 30 or count >= MAX_PULLED_PARTS then break end
        if not S.pulledSet[p] and not (S.ignore[p] and S.ignore[p] > S.time) and eligiblePart(p) then
            local pos = p.Position
            local axis, h = axisAt(S, pos.Y)
            local rel = Vector3.new(pos.X - axis.X, 0, pos.Z - axis.Z)
            local d = math.max(rel.Magnitude, 0.5)
            local R = funnelRadius(S, h)
            local pullR = R * 1.75 + 50
            local f = windStrength(S, d, R, 1)

            local light = partLight(p)
            local structural = p.Anchored
                or (p.AssemblyRootPart ~= nil and p.AssemblyRootPart.Anchored)

            local chance = 0
            if d < pullR then
                chance = 1
            elseif DESTROY_FROM_AFAR and f > 0 then
                -- telhados/partes altas cedem primeiro; peças leves cedem mais fácil
                local relH = math.max(pos.Y - S.groundY, 0)
                local susc = (1 + math.clamp(relH, 0, 60) * 0.015) * (0.55 + 0.45 * light)
                local resist = structural and (0.10 + 0.30 * (1 - light)) or 0.03
                local load = f * susc
                if load > resist then
                    chance = math.min(1, (load - resist) * 1.8)
                end
            end

            if math.random() < chance then
                loosen(S, p, puffs < 12)
                puffs += 1
                S.pulledSet[p] = {
                    om = randf(0.6, 1.3),
                    lift = randf(0.8, 1.4),
                    spin = Vector3.new(randf(-5, 5), randf(-5, 5), randf(-5, 5)),
                    fling = randf(180, 520),
                    light = light,
                    -- peças presas à construção tremem um instante antes de soltar
                    releaseAt = structural and (S.time + randf(0.4, 1.2)) or S.time,
                    mode = nil,
                }
                added += 1
                count += 1
            end
        end
    end
end

local function updateParts(S, dt)
    local I = S.intensity
    if I < 0.03 then return end

    S.scanTimer += dt
    if S.scanTimer >= 0.3 then
        S.scanTimer = 0
        scanParts(S)
    end

    for p, info in pairs(S.pulledSet) do
        if p and p.Parent then
            if S.time < info.releaseAt then
                -- 🔩 rangendo / tremendo antes de ceder
                local j = 3 * (0.4 + I)
                p.AssemblyLinearVelocity = Vector3.new(randf(-j, j), randf(0, j * 0.4), randf(-j, j))
                p.AssemblyAngularVelocity = Vector3.new(randf(-1, 1), randf(-1, 1), randf(-1, 1)) * (0.6 + I)
            else
                local pos = p.Position
                local axis, h = axisAt(S, pos.Y)
                local rel = Vector3.new(pos.X - axis.X, 0, pos.Z - axis.Z)
                local d = math.max(rel.Magnitude, 0.5)
                local R = funnelRadius(S, h)
                local zone = (R * 2.8 + 180) * (0.4 + 0.6 * I)
                local pullR = R * 1.75 + 50
                local outward = rel / d
                local tangent = Vector3.new(-outward.Z, 0, outward.X)
                local light = info.light

                if d > zone * 1.15 then
                    -- saiu do alcance: cai
                    pcall(function() p.CanCollide = true end)
                    S.pulledSet[p] = nil

                elseif d < pullR then
                    -- DENTRO DA SUCÇÃO: puxa pra dentro, gira em órbita e sobe
                    if info.mode ~= "orbit" then
                        info.mode = "orbit"
                        p.CanCollide = false
                    end

                    if h > info.fling * (0.5 + I) then
                        -- arremessada pra fora do vórtice como projétil
                        p.AssemblyLinearVelocity = outward * (90 + 120 * I)
                            + tangent * (60 + 80 * I) + Vector3.new(0, 20, 0)
                        p.CanCollide = true
                        S.ignore[p] = S.time + 8
                        S.pulledSet[p] = nil
                    else
                        local orbitR = math.max(R * 0.9 * info.om, 12)
                        local radial = math.clamp((orbitR - d) * 0.7, -60, 40)
                        local target = outward * radial
                            + tangent * (35 + 70 * I) * info.om * (0.55 + 0.45 * light)
                            + Vector3.new(0, (15 + 25 * I) * info.lift * (0.4 + 0.6 * light), 0)
                        local resp = 1.2 + 3.3 * light   -- peça pesada reage mais devagar
                        p.AssemblyLinearVelocity = p.AssemblyLinearVelocity:Lerp(target, 1 - math.exp(-resp * dt))
                        p.AssemblyAngularVelocity = info.spin * (0.6 + I)
                    end

                else
                    -- ZONA DE VENTO: empurra, arrasta e levanta (casas desmontando)
                    if info.mode ~= "wind" then
                        info.mode = "wind"
                        p.CanCollide = true
                    end
                    local f = windStrength(S, d, R, 1)
                    local dir = windDirection(rel, d)
                    local target = dir * (25 + 95 * I) * f * (0.45 + 0.55 * light)
                        + Vector3.new(0, (6 + 30 * I) * f * info.lift * light, 0)
                    p.AssemblyLinearVelocity = p.AssemblyLinearVelocity:Lerp(target, 1 - math.exp(-(0.8 + 2.2 * light) * dt))
                    p.AssemblyAngularVelocity = info.spin * f
                end
            end
        else
            S.pulledSet[p] = nil
        end
    end
end

local function updateSuction(S, dt)
    if PULL_PLAYER then updatePlayer(S, dt) end
    if PULL_PARTS then updateParts(S, dt) end
end

--==============================================================
-- ☁️ CAMADA DE TEMPESTADE (nuvens escuras girando em volta do tornado)
--==============================================================
local DECK_FRACS = { 1.25, 1.7, 2.2, 2.8 }

local function createDeckPoint(S)
    local part = newPoint(S)
    local e = Instance.new("ParticleEmitter")
    e.Texture = SMOKE_TEXTURE
    e.Rate = 0
    e.Enabled = false
    e.Speed = NumberRange.new(2, 8)
    e.SpreadAngle = Vector2.new(180, 180)
    e.Lifetime = NumberRange.new(6, 9)
    e.Rotation = NumberRange.new(0, 360)
    e.RotSpeed = NumberRange.new(-8, 8)
    e.Drag = 1
    e.LightInfluence = 1
    e.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.4, 0.38),
        NumberSequenceKeypoint.new(0.8, 0.6),
        NumberSequenceKeypoint.new(1, 1) })
    e.Parent = part
    return { part = part, emitter = e }
end

local function updateDeck(S, dt, refresh)
    local off = funnelOffset(S, HEIGHT)
    for k, ring in ipairs(S.deck) do
        local frac = DECK_FRACS[k]
        ring.angle += (0.12 + 0.03 * k) * dt
        for i, pt in ipairs(ring.points) do
            local a = ring.angle + (i - 1) * math.pi * 2 / #ring.points + pt.jit
            local r = S.topRadius * frac * pt.rm
            pt.part.Position = Vector3.new(
                S.center.X + off.X + math.cos(a) * r,
                S.groundY + pt.alt,
                S.center.Z + off.Z + math.sin(a) * r)
            if refresh then
                local e = pt.emitter
                e.Enabled = true
                e.Color = ColorSequence.new(CLOUD_DARK:Lerp(CLOUD_COLOR, ((k - 1) / (#DECK_FRACS - 1)) * 0.6))
                local size = math.clamp(S.topRadius * 0.4, 140, 420)
                e.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, size * 0.7),
                    NumberSequenceKeypoint.new(1, size * 1.3) })
                e.Rate = (1.2 + 2.2 * S.intensity) * (S.formation or 0)
            end
        end
    end
end

--==============================================================
-- ⚡ RELÂMPAGOS NAS NUVENS (ramificados, com clarão interno e trovão 3D)
--==============================================================
local BOLT_CORE = Color3.fromRGB(240, 244, 255)
local BOLT_GLOW = Color3.fromRGB(150, 175, 255)

-- ponto aleatório dentro da camada de nuvens
local function lightningPoint(S, low)
    local off = funnelOffset(S, HEIGHT)
    local a = math.random() * math.pi * 2
    local r = S.topRadius * randf(0.9, 2.6)
    local alt = HEIGHT * 0.86 + (low and randf(0, 60) or randf(0, 280))
    return Vector3.new(
        S.center.X + off.X + math.cos(a) * r,
        S.groundY + alt,
        S.center.Z + off.Z + math.sin(a) * r)
end

local function boltSegment(parent, a, b, thick, color)
    local len = (b - a).Magnitude
    if len < 0.05 then return nil end
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Material = Enum.Material.Neon
    p.Color = color
    p.Transparency = 1
    p.Size = Vector3.new(thick, thick, len + thick * 0.8)
    p.CFrame = CFrame.lookAt((a + b) * 0.5, b)
    p.Parent = parent
    return p
end

-- caminho em zigue-zague natural (passeio aleatório amortecido)
local function boltPath(a, b, segs, jitterMul)
    local pts = { a }
    local dir = b - a
    local len = dir.Magnitude
    local fwd = dir.Unit
    local up = (math.abs(fwd.Y) > 0.9) and Vector3.xAxis or Vector3.yAxis
    local right = fwd:Cross(up).Unit
    local up2 = right:Cross(fwd).Unit
    local step = len / segs
    local jit = step * jitterMul
    local lateral = Vector3.zero
    for i = 1, segs - 1 do
        lateral = lateral * 0.55 + (right * randf(-1, 1) + up2 * randf(-1, 1)) * jit
        pts[#pts + 1] = a + fwd * (step * i) + lateral
    end
    pts[#pts + 1] = b
    return pts
end

local function drawPath(parent, pts, thick, core, glow)
    for i = 1, #pts - 1 do
        local g = boltSegment(parent, pts[i], pts[i + 1], thick * 3.2, BOLT_GLOW)
        local c = boltSegment(parent, pts[i], pts[i + 1], thick, BOLT_CORE)
        if g then table.insert(glow, g) end
        if c then table.insert(core, c) end
    end
end

-- clarão dentro da nuvem (a nuvem "acende" por dentro)
local function cloudFlash(S, pos, size, power)
    local part = newPoint(S)
    part.Name = "TornadoCloudFlash"
    part.Position = pos

    local light = Instance.new("PointLight")
    light.Range = 60
    light.Brightness = 4 * power
    light.Color = Color3.fromRGB(190, 205, 255)
    light.Parent = part

    local e = Instance.new("ParticleEmitter")
    e.Texture = SMOKE_TEXTURE
    e.Rate = 0
    e.Lifetime = NumberRange.new(0.35, 0.75)
    e.Speed = NumberRange.new(0, 4)
    e.SpreadAngle = Vector2.new(180, 180)
    e.Rotation = NumberRange.new(0, 360)
    e.LightEmission = 1
    e.LightInfluence = 0
    e.Color = ColorSequence.new(Color3.fromRGB(215, 225, 255), Color3.fromRGB(140, 160, 230))
    e.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, size * 0.6),
        NumberSequenceKeypoint.new(1, size * 1.2) })
    e.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.3, 0.5),
        NumberSequenceKeypoint.new(1, 1) })
    e.Parent = part
    e:Emit(math.floor(5 * power) + 3)

    task.delay(0.12, function() if light.Parent then light.Brightness = 0 end end)
    Debris:AddItem(part, 1.5)
end

-- luz no ponto onde o raio atinge o chão
local function groundLight(S, pos)
    local part = newPoint(S)
    part.Name = "TornadoStrikeLight"
    part.Position = pos + Vector3.new(0, 6, 0)
    local light = Instance.new("PointLight")
    light.Range = 60
    light.Brightness = 8
    light.Color = Color3.fromRGB(200, 215, 255)
    light.Parent = part
    task.delay(0.15, function() if light.Parent then light.Brightness = 2 end end)
    Debris:AddItem(part, 0.4)
end

-- trovão 3D: chega depois do clarão, conforme a distância
local function thunder(S, pos, power)
    local cam = workspace.CurrentCamera
    local dist = cam and (cam.CFrame.Position - pos).Magnitude or 500
    local delay = math.min(dist / 1100, 4)

    local part = newPoint(S)
    part.Name = "TornadoThunderEmitter"
    part.Position = pos

    local snd = Instance.new("Sound")
    snd.SoundId = LIGHTNING_SOUND_ID
    snd.Volume = math.clamp(2.2 * power, 0.6, 6)
    snd.PlaybackSpeed = randf(0.82, 1.12)
    snd.RollOffMode = Enum.RollOffMode.InverseTapered
    snd.RollOffMinDistance = 250
    snd.RollOffMaxDistance = 5000
    snd.Parent = part

    task.delay(delay, function()
        if snd.Parent then snd:Play() end
    end)
    Debris:AddItem(part, delay + 15)
end

local function makeBolt(S, a, b, opts)
    opts = opts or {}
    local len = (b - a).Magnitude
    if len < 5 then return end

    local folder = Instance.new("Folder")
    folder.Name = "TornadoBolt"
    folder.Parent = S.folder

    local core, glow = {}, {}
    local thick = math.clamp(len * 0.0035, 0.5, 4.2) * (opts.thin or 1)
    local segs = opts.segs or math.clamp(math.floor(len / 40), 8, 30)
    local main = boltPath(a, b, segs, opts.jitter or 0.55)
    drawPath(folder, main, thick, core, glow)

    -- ramificações (e sub-ramificações)
    local fwd = (b - a).Unit
    local branchChance = opts.branch or 0.3
    for i = 3, #main - 2 do
        if #core > 240 then break end
        if math.random() < branchChance then
            local start = main[i]
            local bdir = (fwd * randf(0.3, 1)
                + Vector3.new(randf(-1, 1), randf(-1, 0.3), randf(-1, 1)) * 0.8).Unit
            local blen = len * randf(0.08, 0.28)
            local bpath = boltPath(start, start + bdir * blen, math.max(4, math.floor(blen / 35)), 0.6)
            drawPath(folder, bpath, thick * 0.55, core, glow)
            if math.random() < 0.35 and #bpath > 3 then
                local sp = bpath[math.random(2, #bpath - 1)]
                local sdir = (bdir + Vector3.new(randf(-1, 1), randf(-0.5, 0.5), randf(-1, 1))).Unit
                drawPath(folder, boltPath(sp, sp + sdir * blen * 0.4, 4, 0.6), thick * 0.3, core, glow)
            end
        end
    end

    -- cintilação realista: clarão, apaga, retorno mais forte, some
    task.spawn(function()
        local function setT(tc, tg)
            for _, p in ipairs(core) do p.Transparency = tc end
            for _, p in ipairs(glow) do p.Transparency = tg end
        end
        setT(0, 0.5);      task.wait(0.05)
        setT(1, 1);        task.wait(0.05)
        setT(0, 0.35);     task.wait(0.10)
        setT(0.5, 0.8);    task.wait(0.04)
        setT(1, 1);        task.wait(0.07)
        if math.random() < 0.5 then
            setT(0.1, 0.55); task.wait(0.05)
        end
        for i = 1, 6 do
            local t = i / 6
            setT(t, 0.55 + 0.45 * t)
            task.wait(0.035)
        end
        pcall(function() folder:Destroy() end)
    end)

    return main
end

local function spawnLightning(S)
    local size = math.clamp(S.topRadius * 0.5, 160, 380)
    local r = math.random()

    if r < 0.18 then
        -- ⚡ nuvem -> chão
        local a = lightningPoint(S, true)
        local gx = a.X + randf(-120, 120)
        local gz = a.Z + randf(-120, 120)
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local ex = { S.folder }
        if LocalPlayer.Character then table.insert(ex, LocalPlayer.Character) end
        rp.FilterDescendantsInstances = ex
        local res = workspace:Raycast(Vector3.new(gx, a.Y - 40, gz), Vector3.new(0, -2400, 0), rp)
        local b = Vector3.new(gx, res and res.Position.Y or S.groundY, gz)

        makeBolt(S, a, b, { branch = 0.4, jitter = 0.6 })
        cloudFlash(S, a, size, 1.2)
        task.delay(0.12, function()
            if TORNADO.S == S then cloudFlash(S, a + Vector3.new(0, -40, 0), size * 0.8, 1) end
        end)
        groundLight(S, b)
        thunder(S, b, 1.6)

    elseif r < 0.60 then
        -- ⚡ dentro da nuvem
        local a = lightningPoint(S)
        local dir = Vector3.new(randf(-1, 1), randf(-0.25, 0.25), randf(-1, 1)).Unit
        local b = a + dir * randf(200, 550)
        makeBolt(S, a, b, { branch = 0.35 })
        cloudFlash(S, a, size, 1)
        cloudFlash(S, (a + b) * 0.5, size, 0.9)
        cloudFlash(S, b, size * 0.8, 0.8)
        thunder(S, (a + b) * 0.5, 1.1)

    elseif r < 0.78 then
        -- ⚡ rastejante: longo, fino, correndo pela base da nuvem
        local a = lightningPoint(S)
        local dir = Vector3.new(randf(-1, 1), randf(-0.1, 0.1), randf(-1, 1)).Unit
        local b = a + dir * randf(600, 1300)
        makeBolt(S, a, b, { branch = 0.2, thin = 0.7, jitter = 0.45 })
        for i = 0, 2 do
            cloudFlash(S, a:Lerp(b, i / 2), size, 0.8)
        end
        thunder(S, (a + b) * 0.5, 1.3)

    else
        -- clarão difuso (a nuvem acende por dentro, sem raio visível)
        local a = lightningPoint(S)
        cloudFlash(S, a, size * 1.4, 0.9)
        task.delay(0.09, function()
            if TORNADO.S == S then cloudFlash(S, a + Vector3.new(randf(-80, 80), 0, randf(-80, 80)), size * 1.2, 0.8) end
        end)
        thunder(S, a, 0.7)
    end
end

--==============================================================
-- LUZ
--==============================================================
local function updateLighting(S, amount)
    if not S.saved then return end
    local stormGray = Color3.fromRGB(120, 130, 142)
    pcall(function()
        Lighting.Ambient = S.saved.Ambient:Lerp(stormGray, amount)
        Lighting.OutdoorAmbient = S.saved.OutdoorAmbient:Lerp(stormGray, amount)
        Lighting.Brightness = lerp(S.saved.Brightness, 1.4, amount)
        Lighting.FogColor = S.saved.FogColor:Lerp(stormGray, amount)
        Lighting.FogStart = lerp(S.saved.FogStart, 80, amount)
        Lighting.FogEnd = lerp(S.saved.FogEnd, 4500, amount)
        Lighting.ExposureCompensation = lerp(S.saved.ExposureCompensation, 0.05, amount)
    end)
    if S.colorCorrection then
        S.colorCorrection.Saturation = -0.3 * amount
        S.colorCorrection.Contrast = 0.25 * amount
        S.colorCorrection.TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(200, 215, 230), amount)
        S.colorCorrection.Brightness = 0.02 * amount
    end
    if S.atmosphere then
        S.atmosphere.Density = 0.1 + amount * 0.3
        S.atmosphere.Haze = amount * 2.2
        S.atmosphere.Color = Color3.fromRGB(180, 188, 198):Lerp(Color3.fromRGB(110, 120, 130), amount)
    end
end

local function getRating(kmh)
    if kmh < 105 then return "--"
    elseif kmh < 138 then return "EF0"
    elseif kmh < 178 then return "EF1"
    elseif kmh < 218 then return "EF2"
    elseif kmh < 267 then return "EF3"
    elseif kmh < 322 then return "EF4"
    else return "EF5" end
end

--==============================================================
-- CLEAR
--==============================================================
function TORNADO.clear(silent)
    TORNADO.token += 1
    local S = TORNADO.S
    TORNADO.S = nil
    if not S then return end

    if S.connection then pcall(function() S.connection:Disconnect() end) end
    if S.shakeName then pcall(function() RunService:UnbindFromRenderStep(S.shakeName) end) end

    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        releasePlayer(S, hum)
        if hum then hum.PlatformStand = false end
    end)

    if S.pulledSet then
        for p, _ in pairs(S.pulledSet) do
            pcall(function()
                p.CanCollide = true
                p.AssemblyLinearVelocity = Vector3.zero
                p.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        S.pulledSet = nil
    end

    if S.folder then pcall(function() S.folder:Destroy() end) end
    if S.gui then pcall(function() S.gui:Destroy() end) end
    if S.colorCorrection then pcall(function() S.colorCorrection:Destroy() end) end
    if S.atmosphere then pcall(function() S.atmosphere:Destroy() end) end

    if S.clouds then
        if S.cloudsNew then
            pcall(function() S.clouds:Destroy() end)
        elseif S.cloudsSaved then
            pcall(function() for k, v in pairs(S.cloudsSaved) do S.clouds[k] = v end end)
        end
    end

    if S.saved then
        for key, value in pairs(S.saved) do
            pcall(function() Lighting[key] = value end)
        end
    end

    if not silent then notify("Tornado", "O tornado dissipou.") end
end

--==============================================================
-- TELEPORTES (botões)
--==============================================================
local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function teleportNear(S)
    local hrp = getHRP()
    if not hrp then return end
    local dist = math.max(S.groundRadius * 1.8, 60) + 110
    local p = S.center + S.direction * dist
    local pos = Vector3.new(p.X, S.groundY + 5, p.Z)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = CFrame.lookAt(pos, Vector3.new(S.center.X, pos.Y, S.center.Z))
end

local function teleportEye(S)
    local hrp = getHRP()
    if not hrp then return end
    local axis = axisAt(S, S.groundY + HEIGHT * 0.8)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(axis)
end

--==============================================================
-- SPAWN
--==============================================================
-- refName: nome de quem enviou o comando (rede) -> o tornado nasce na frente dele,
-- assim todo mundo vê o tornado no mesmo lugar. Sem refName: nasce na sua frente.
function TORNADO.spawn(refName)
    TORNADO.clear(true)

    local refPlayer = (refName and refName ~= LocalPlayer.Name) and Players:FindFirstChild(refName) or nil
    local character = refPlayer and refPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        hrp = character:WaitForChild("HumanoidRootPart", 10)
    end
    if not hrp then
        notify("Tornado", "Personagem não encontrado.")
        return
    end

    local look = hrp.CFrame.LookVector
    look = Vector3.new(look.X, 0, look.Z)
    look = look.Magnitude > 0.1 and look.Unit or Vector3.new(0, 0, -1)
    local startPosition = hrp.Position + look * START_DISTANCE

    local S = {
        time = 0,
        center = Vector3.new(startPosition.X, 0, startPosition.Z),
        groundY = hrp.Position.Y - 2,
        direction = -look,
        intensity = 0,
        topRadius = 110,
        groundRadius = 12,
        baseHeight = 5,
        kmh = 0,
        touched = false,
        flash = 0,
        nextFlash = 4,
        funnel = {},
        cloudLayers = {},
        deck = {},
        nextBolt = 3,
        formation = 0,
        dust = {},
        pulledSet = {},
        saved = {},
        playerPulled = false,
        refreshTimer = 0,
        scanTimer = 0,
        ignore = setmetatable({}, { __mode = "k" }),
        windF = 0,
    }
    TORNADO.S = S

    S.folder = Instance.new("Folder")
    S.folder.Name = "REALISTIC_TORNADO"
    S.folder.Parent = workspace

    S.debrisFolder = Instance.new("Folder")
    S.debrisFolder.Name = "TORNADO_SAND"
    S.debrisFolder.Parent = S.folder

    for _, property in ipairs({ "Ambient", "OutdoorAmbient", "Brightness", "FogColor",
        "FogStart", "FogEnd", "ExposureCompensation", "ClockTime" }) do
        pcall(function() S.saved[property] = Lighting[property] end)
    end

    pcall(function()
        local cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "TornadoColorCorrection"
        cc.Parent = Lighting
        S.colorCorrection = cc
    end)

    pcall(function()
        local a = Instance.new("Atmosphere")
        a.Name = "TornadoAtmosphere"
        a.Color = Color3.fromRGB(180, 188, 198)
        a.Decay = Color3.fromRGB(125, 130, 138)
        a.Density = 0.1
        a.Haze = 0
        a.Glare = 0
        a.Offset = 0.25
        a.Parent = Lighting
        S.atmosphere = a
    end)

    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            local cl = terrain:FindFirstChildOfClass("Clouds")
            if cl then
                S.cloudsSaved = { Cover = cl.Cover, Density = cl.Density, Color = cl.Color, Enabled = cl.Enabled }
            else
                cl = Instance.new("Clouds")
                cl.Parent = terrain
                S.cloudsNew = true
            end
            cl.Enabled = true
            cl.Color = Color3.fromRGB(215, 220, 228)
            cl.Cover, cl.Density = 0, 0
            S.clouds = cl
        end
    end)

    -- funil
    for i = 1, FUNNEL_LAYERS do
        local layer = {
            nh = (i - 1) / (FUNNEL_LAYERS - 1),
            angle = math.random() * math.pi * 2,
            points = {}
        }
        for j = 1, OUTER_POINTS do
            local pt = createFunnelPoint(S, false)
            pt.offset = (j - 1) * math.pi * 2 / OUTER_POINTS
            table.insert(layer.points, pt)
        end
        for j = 1, CORE_POINTS do
            local pt = createFunnelPoint(S, true)
            pt.offset = (j - 1) * math.pi * 2 / CORE_POINTS + 0.5
            table.insert(layer.points, pt)
        end
        table.insert(S.funnel, layer)
    end

    -- topo / olho
    for k = 1, EYE_RINGS do
        local ring = { angle = math.random() * math.pi * 2, points = {} }
        for _ = 1, EYE_RING_POINTS do table.insert(ring.points, createCloudPoint(S)) end
        table.insert(S.cloudLayers, ring)
    end

    createSandCloud(S)

    -- camada de tempestade (nuvens escuras girando)
    for k = 1, #DECK_FRACS do
        local ring = { angle = math.random() * math.pi * 2, points = {} }
        for _ = 1, DECK_POINTS[k] do
            local pt = createDeckPoint(S)
            pt.alt = HEIGHT * 0.86 + randf(0, 300)
            pt.rm = randf(0.85, 1.15)
            pt.jit = randf(-0.12, 0.12)
            table.insert(ring.points, pt)
        end
        table.insert(S.deck, ring)
    end

    -- poeira/lascas quando uma construção se rompe
    pcall(function()
        local pp = newPoint(S)
        pp.Name = "TornadoBreakPuff"
        local pe = Instance.new("ParticleEmitter")
        pe.Texture = SMOKE_TEXTURE
        pe.Rate = 0
        pe.Lifetime = NumberRange.new(1.5, 3)
        pe.Speed = NumberRange.new(10, 30)
        pe.SpreadAngle = Vector2.new(180, 180)
        pe.Rotation = NumberRange.new(0, 360)
        pe.Drag = 1.5
        pe.Acceleration = Vector3.new(0, 3, 0)
        pe.LightInfluence = 1
        pe.Color = ColorSequence.new(DIRT_MID, DIRT_LIGHT)
        pe.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 6),
            NumberSequenceKeypoint.new(1, 22) })
        pe.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.35),
            NumberSequenceKeypoint.new(1, 1) })
        pe.Parent = pp
        S.puffPart = pp
        S.puffEmitter = pe
    end)

    -- chuva
    local rainPart = Instance.new("Part")
    rainPart.Name = "TornadoRain"
    rainPart.Anchored = true
    rainPart.CanCollide = false
    rainPart.CanTouch = false
    rainPart.CanQuery = false
    rainPart.Transparency = 1
    rainPart.Size = Vector3.new(180, 1, 180)
    rainPart.Parent = S.folder

    local rain = Instance.new("ParticleEmitter")
    rain.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    rain.Rate = 0
    rain.Lifetime = NumberRange.new(0.5, 0.8)
    rain.Speed = NumberRange.new(130, 190)
    rain.SpreadAngle = Vector2.new(8, 8)
    rain.Size = NumberSequence.new(0.12)
    rain.Transparency = NumberSequence.new(0.65)
    rain.Color = ColorSequence.new(Color3.fromRGB(200, 215, 230))
    rain.Parent = rainPart
    S.rainPart = rainPart
    S.rain = rain

    -- 🌬️ vento: rajadas e poeira voando ao redor da câmera
    local windPart = Instance.new("Part")
    windPart.Name = "TornadoWindPart"
    windPart.Size = Vector3.new(110, 60, 110)
    windPart.Transparency = 1
    windPart.Anchored = true
    windPart.CanCollide = false
    windPart.CanTouch = false
    windPart.CanQuery = false
    windPart.CastShadow = false
    windPart.Parent = S.folder

    local streak = Instance.new("ParticleEmitter")
    streak.Texture = SMOKE_TEXTURE
    streak.Rate = 0
    streak.Lifetime = NumberRange.new(0.6, 1.1)
    streak.Speed = NumberRange.new(90, 160)
    streak.SpreadAngle = Vector2.new(4, 4)
    streak.Orientation = Enum.ParticleOrientation.VelocityParallel
    streak.Size = NumberSequence.new(2.2)
    streak.LightInfluence = 1
    streak.Color = ColorSequence.new(Color3.fromRGB(205, 210, 218))
    streak.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0.8),
        NumberSequenceKeypoint.new(0.8, 0.8),
        NumberSequenceKeypoint.new(1, 1) })
    streak.Parent = windPart

    local specks = Instance.new("ParticleEmitter")
    specks.Texture = SMOKE_TEXTURE
    specks.Rate = 0
    specks.Lifetime = NumberRange.new(0.5, 1.0)
    specks.Speed = NumberRange.new(80, 150)
    specks.SpreadAngle = Vector2.new(6, 6)
    specks.Orientation = Enum.ParticleOrientation.VelocityParallel
    specks.Size = NumberSequence.new(0.7)
    specks.LightInfluence = 1
    specks.Color = ColorSequence.new(DIRT_MID, DIRT_LIGHT)
    specks.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.7, 0.4),
        NumberSequenceKeypoint.new(1, 1) })
    specks.Parent = windPart

    S.windPart = windPart
    S.windStreak = streak
    S.windSpecks = specks

    pcall(function()
        local wind = Instance.new("Sound")
        wind.Name = "TornadoWindSound"
        wind.SoundId = WIND_SOUND_ID
        wind.Looped = true
        wind.Volume = 0
        wind.Parent = S.folder

        -- longe = som abafado (menos agudo)
        pcall(function()
            local eq = Instance.new("EqualizerSoundEffect")
            eq.HighGain = -25
            eq.MidGain = -6
            eq.LowGain = 0
            eq.Parent = wind
            S.windEQ = eq
        end)

        wind:Play()
        S.wind = wind
    end)

    local token = TORNADO.token

    S.connection = RunService.RenderStepped:Connect(function(dt)
        if TORNADO.S ~= S or TORNADO.token ~= token then return end

        dt = math.min(dt, 0.1)
        S.time += dt
        local t = S.time

        local formation = math.clamp(t / 8, 0, 1)
        S.formation = formation
        S.intensity = math.clamp((t - 6) / 35, 0, 1)
        S.touched = t > 3

        S.topRadius = lerp(110, 620, smooth(math.clamp(t / 40, 0, 1)))
        S.groundRadius = lerp(12, 240, smooth(S.intensity))
        S.kmh = S.touched and lerp(120, MAX_KMH, smooth(S.intensity)) or 0

        S.center += S.direction * MOVE_SPEED * dt

        -- ⚡ relâmpagos nas nuvens (som 3D com atraso pela distância)
        if LIGHTNING_ENABLED and t > 2 and t >= S.nextBolt then
            spawnLightning(S)
            S.nextBolt = t + lerp(4.5, 0.7, S.intensity) * randf(0.5, 1.5)
            if math.random() < 0.3 then S.nextBolt = t + randf(0.1, 0.35) end  -- raios em sequência
        end

        local camera = workspace.CurrentCamera
        if camera then
            S.rainPart.CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(0, 75, 0))
        end
        S.rain.Rate = 100 + 500 * formation

        if S.wind then
            local near = 0
            if camera then
                local cp = camera.CFrame.Position
                local axis, h = axisAt(S, cp.Y)
                local dx, dz = cp.X - axis.X, cp.Z - axis.Z
                local dd = math.sqrt(dx * dx + dz * dz)
                local edge = math.max(dd - funnelRadius(S, h), 0)  -- distância até a parede do funil
                near = (1 - math.clamp(edge / WIND_HEAR_RANGE, 0, 1)) ^ 1.6
            end
            local targetVol = WIND_MAX_VOLUME * near
            S.windVol = lerp(S.windVol or 0, targetVol, math.clamp(dt * 3, 0, 1))
            S.wind.Volume = S.windVol
            S.wind.PlaybackSpeed = 0.85 + S.intensity * 0.35
            if S.windEQ then
                S.windEQ.HighGain = -25 * (1 - near)
                S.windEQ.MidGain = -6 * (1 - near)
            end
        end

        -- atualiza cor/tamanho/rate só a cada 0.2s (performance)
        S.refreshTimer += dt
        local refresh = S.refreshTimer >= 0.2
        if refresh then S.refreshTimer = 0 end

        -- 🌬️ vento na câmera (rajadas + som)
        if WIND_ENABLED and camera and S.windPart then
            local cp = camera.CFrame.Position
            local axis, h = axisAt(S, cp.Y)
            local rel = Vector3.new(cp.X - axis.X, 0, cp.Z - axis.Z)
            local d = math.max(rel.Magnitude, 0.5)
            local R = funnelRadius(S, h)
            local f = windStrength(S, d, R, 3)
            local dir = windDirection(rel, d)
            S.windPart.CFrame = CFrame.fromMatrix(cp, Vector3.yAxis, dir)
            S.windStreak.Rate = 170 * f
            S.windSpecks.Rate = 130 * f
            S.windF = f
        end

        updateFunnel(S, dt, refresh)
        updateClouds(S, dt, refresh)
        updateDeck(S, dt, refresh)
        updateSandCloud(S, dt, refresh)
        updateSuction(S, dt)
        updateLighting(S, formation)

        if S.clouds then
            S.clouds.Cover = 0.9 * formation
            S.clouds.Density = 0.85 * formation
        end

    end)

    S.shakeName = "TornadoShake" .. tostring(token)
    RunService:BindToRenderStep(S.shakeName, Enum.RenderPriority.Camera.Value + 1, function(dt)
        if TORNADO.S == S and TORNADO.token == token then
            updateCameraShake(S, dt)
        end
    end)

    notify("Tornado", "Supercélula EF-5 formando... cuidado com os raios!")
end

--==============================================================
-- 🌐 REDE (via chat)
--   ;TORNADO_SPAWN <alvo|ALL>     ;TORNADO_CLEAR <alvo|ALL>
-- Quem estiver com este script rodando reage ao comando:
--   ALL  -> todos veem o tornado no mesmo lugar (na frente de quem enviou)
--   nome -> só esse jogador (nome ou apelido, aceita começo do nome)
--==============================================================
local NET_ENABLED = true
local NET_ACCEPT_FROM_ALL = true   -- false = só aceita de quem estiver em NET_TRUSTED
local NET_TRUSTED = {              -- ex: NET_TRUSTED["SeuNome"] = true
}

local netSeen = {}

local function matchesTarget(arg)
    arg = string.lower(arg or "")
    if arg == "" or arg == "all" or arg == "todos" then return true, true end
    local n = string.lower(LocalPlayer.Name)
    local dn = string.lower(LocalPlayer.DisplayName)
    if string.sub(n, 1, #arg) == arg or string.sub(dn, 1, #arg) == arg then
        return true, false
    end
    return false, false
end

local function handleNet(senderName, msg)
    if not NET_ENABLED or type(msg) ~= "string" then return end
    local cmd, arg = string.match(msg, "^;%s*(%S+)%s*(.-)%s*$")
    if not cmd then return end
    cmd = string.upper(cmd)
    if cmd ~= "TORNADO_SPAWN" and cmd ~= "TORNADO_CLEAR" and cmd ~= "GONER_TURN" and cmd ~= "COOLKIDP_TURN" then return end

    -- evita executar 2x a mesma mensagem (chat antigo + novo)
    local key = senderName .. "|" .. msg
    local now = os.clock()
    if netSeen[key] and now - netSeen[key] < 1.5 then return end
    netSeen[key] = now

    if senderName ~= LocalPlayer.Name and not NET_ACCEPT_FROM_ALL and not NET_TRUSTED[senderName] then
        return
    end

    local ok, isAll = matchesTarget(arg)
    if not ok then return end

    if cmd == "GONER_TURN" then
        if not isAll and FantasmaGoner then task.spawn(FantasmaGoner.turnSelf) end
        return
    end
    if cmd == "COOLKIDP_TURN" then
        if not isAll and FantasmaCoolkid then task.spawn(FantasmaCoolkid.turnSelf) end
        return
    end
    if cmd == "TORNADO_SPAWN" then
        task.spawn(function() TORNADO.spawn(isAll and senderName or nil) end)
    else
        TORNADO.clear()
    end
end

local function hookPlayer(plr)
    plr.Chatted:Connect(function(msg) handleNet(plr.Name, msg) end)
end
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)

-- chat novo (TextChatService) como reforço
pcall(function()
    local TCS = game:GetService("TextChatService")
    TCS.MessageReceived:Connect(function(m)
        local src = m.TextSource
        if src then
            local plr = Players:GetPlayerByUserId(src.UserId)
            if plr then handleNet(plr.Name, m.Text) end
        end
    end)
end)

-- envia o comando pro chat (os outros com o script recebem)
local function netSend(cmd, target)
    local text = ";" .. cmd .. " " .. (target or "ALL")
    local sent = false
    pcall(function()
        local TCS = game:GetService("TextChatService")
        local ch = TCS.TextChannels:FindFirstChild("RBXGeneral")
        if ch then ch:SendAsync(text) sent = true end
    end)
    if not sent then
        pcall(function()
            local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            ev.SayMessageRequest:FireServer(text, "All")
            sent = true
        end)
    end
    if not sent then handleNet(LocalPlayer.Name, text) end  -- sem chat: roda só aqui
end

--==============================================================
-- COMANDO
--   tornado("ON") / tornado("OFF") / tornado()      -> só pra você
--   tornado("ON", "ALL") / tornado("OFF", "ALL")    -> rede (todos com o script)
--   tornado("ON", "NomeDoJogador")                  -> rede (só esse jogador)
--==============================================================
function tornado(mode, target)
    mode = mode and string.upper(mode) or (TORNADO.S and "OFF" or "ON")
    if target then
        netSend(mode == "OFF" and "TORNADO_CLEAR" or "TORNADO_SPAWN", target)
        return
    end
    if mode == "OFF" then
        TORNADO.clear()
    else
        TORNADO.spawn()
    end
end
_G.tornado = tornado
-- opcionais (sem GUI): chame no console
_G.tornadoPerto = function() if TORNADO.S then teleportNear(TORNADO.S) end end
_G.tornadoOlho  = function() if TORNADO.S then teleportEye(TORNADO.S) end end
-- Sem auto start: seu botão chama tornado("ON") / tornado("OFF") / tornado()

end -- fim do bloco TORNADO

-- ================== EFEITOS VISÍVEIS PARA TODOS (JAIL / EXPLODE / ICE) ==================
-- Antes só o alvo executava; agora TODO mundo com o script desenha o efeito no alvo.
local BROADCAST_ACTIONS = { JAIL = true, UNJAIL = true, EXPLODE = true, ICE = true, UNICE = true }

local function broadcastTargets(name)
    local list = {}
    if not name or name == "" then return list end
    if string.upper(name) == "ALL" then
        for _, p in ipairs(Players:GetPlayers()) do table.insert(list, p) end
    else
        local l = string.lower(name)
        local p = Players:FindFirstChild(name)
        if not p then
            for _, q in ipairs(Players:GetPlayers()) do
                if string.lower(q.Name) == l or string.lower(q.DisplayName) == l then p = q break end
            end
        end
        if p then table.insert(list, p) end
    end
    return list
end

local function runBroadcast(action, senderName, targetName)
    local TweenService = game:GetService("TweenService")
    for _, plr in ipairs(broadcastTargets(targetName)) do
        local chr = plr.Character
        local thrp = chr and chr:FindFirstChild("HumanoidRootPart")
        local thum = chr and chr:FindFirstChildOfClass("Humanoid")
        local isMeTarget = (plr == LocalPlayer)

        if action == "JAIL" then
            if thrp then
                local old = workspace:FindFirstChild("Jail_" .. plr.Name)
                if old then old:Destroy() end
                local cage = Instance.new("Model")
                cage.Name = "Jail_" .. plr.Name
                local cf = thrp.CFrame
                for _, d in ipairs({
                    {Vector3.new(6,1,6), cf * CFrame.new(0,-3.5,0)},
                    {Vector3.new(6,1,6), cf * CFrame.new(0, 3.5,0)},
                    {Vector3.new(1,6,6), cf * CFrame.new( 3,0,0)},
                    {Vector3.new(1,6,6), cf * CFrame.new(-3,0,0)},
                    {Vector3.new(6,6,1), cf * CFrame.new(0,0, 3)},
                    {Vector3.new(6,6,1), cf * CFrame.new(0,0,-3)},
                }) do
                    local p = Instance.new("Part")
                    p.Size, p.CFrame = d[1], d[2]
                    p.Color, p.Material = Color3.fromRGB(168, 85, 247), Enum.Material.Neon
                    p.Anchored, p.Transparency = true, 0.3
                    p.CanCollide = true
                    p.Parent = cage
                end
                cage.Parent = workspace
            end

        elseif action == "UNJAIL" then
            local old = workspace:FindFirstChild("Jail_" .. plr.Name)
            if old then old:Destroy() end

        elseif action == "EXPLODE" then
            if thrp then
                local pos = thrp.Position
                local ex = Instance.new("Explosion")
                ex.Position = pos
                ex.BlastRadius = 14
                ex.BlastPressure = 0
                ex.DestroyJointRadiusPercent = 0
                ex.Parent = workspace

                local ball = Instance.new("Part")
                ball.Shape = Enum.PartType.Ball
                ball.Anchored, ball.CanCollide, ball.CanQuery, ball.CanTouch = true, false, false, false
                ball.Material = Enum.Material.Neon
                ball.Color = Color3.fromRGB(255, 140, 20)
                ball.Transparency = 0.2
                ball.Size = Vector3.new(2, 2, 2)
                ball.Position = pos
                ball.Parent = workspace
                local light = Instance.new("PointLight", ball)
                light.Color, light.Range, light.Brightness = Color3.fromRGB(255, 170, 60), 40, 8
                TweenService:Create(ball, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = Vector3.new(30, 30, 30), Transparency = 1,
                }):Play()
                game:GetService("Debris"):AddItem(ball, 0.8)

                if isMeTarget and thum then thum.Health = 0 end
            end

        elseif action == "ICE" then
            if thrp then
                local old = workspace:FindFirstChild("Ice_" .. plr.Name)
                if old then old:Destroy() end
                local ip = Instance.new("Part")
                ip.Name, ip.Size, ip.CFrame = "Ice_" .. plr.Name, Vector3.new(6, 8, 6), thrp.CFrame
                ip.Anchored, ip.CanCollide = true, false
                ip.Color, ip.Material, ip.Transparency = Color3.fromRGB(0, 170, 255), Enum.Material.Glass, 0.4
                ip.Parent = workspace
                if isMeTarget then
                    if thum then thum.WalkSpeed = 0 end
                    thrp.Anchored = true
                end
            end

        elseif action == "UNICE" then
            local old = workspace:FindFirstChild("Ice_" .. plr.Name)
            if old then old:Destroy() end
            if isMeTarget then
                if thum then thum.WalkSpeed = 16 end
                if thrp then thrp.Anchored = false end
            end
        end
    end
end

-- ================== SUKUNA: CORTES (CLEAVE) + CENÁRIO SOMBRIO (usados no domínio e no choque) ==================
SHRINE_YAW = 0   -- ajuste da direção do santuário (0/90/180/270) — também no painel > Configuração
CLEAVE_LOW = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- corte do Sukuna: núcleo branco/prateado + rastro preto + brilho vermelho, risca o ar e deixa rastro
function cleaveLine(parent, a, b, w, life)
    life = life or 0.4
    local TSv = game:GetService("TweenService")
    local DBv = game:GetService("Debris")
    local holder = Instance.new("Part")
    holder.Anchored, holder.CanCollide, holder.CanQuery, holder.CanTouch, holder.CastShadow = true, false, false, false, false
    holder.Transparency = 1
    holder.Size = Vector3.new(0.2, 0.2, 0.2)
    holder.CFrame = CFrame.new(a)
    holder.Parent = parent
    local function att(pos)
        local at = Instance.new("Attachment")
        at.Parent = holder
        at.WorldPosition = pos
        return at
    end
    local a0, am, a1 = att(a), att(a), att(a)
    local beams = {}
    local function bm(x0, x1, w0, w1, color, emis, tr)
        local m = Instance.new("Beam")
        m.Attachment0, m.Attachment1 = x0, x1
        m.Width0, m.Width1 = w0, w1
        m.FaceCamera, m.Segments = true, 1
        m.Color = ColorSequence.new(color)
        m.Transparency = NumberSequence.new(tr)
        m.LightEmission, m.LightInfluence = emis, 0
        m.Parent = holder
        beams[#beams + 1] = m
    end
    local RED, BLK, WHT = Color3.fromRGB(235, 0, 12), Color3.new(0, 0, 0), Color3.fromRGB(245, 248, 255)
    bm(a0, am, 0, w * 4, RED, 1, 0.6)
    bm(am, a1, w * 4, 0, RED, 1, 0.6)
    bm(a0, am, 0, w * 2.2, BLK, 0, 0.05)
    bm(am, a1, w * 2.2, 0, BLK, 0, 0.05)
    bm(a0, am, 0, w, WHT, 1, 0)
    bm(am, a1, w, 0, WHT, 1, 0)
    local trail
    if not CLEAVE_LOW then
        trail = Instance.new("Beam")
        trail.Attachment0, trail.Attachment1 = a0, a1
        trail.Width0, trail.Width1 = w * 0.5, w * 0.5
        trail.FaceCamera, trail.Segments = true, 1
        trail.Color = ColorSequence.new(Color3.fromRGB(150, 0, 10))
        trail.Transparency = NumberSequence.new(0.4)
        trail.LightEmission, trail.LightInfluence = 0, 0
        trail.Parent = holder
    end
    DBv:AddItem(holder, life + 1.6)
    task.spawn(function()
        pcall(function()
            for i = 1, 5 do
                local p1 = a + (b - a) * (i / 5)
                a1.WorldPosition = p1
                am.WorldPosition = (a + p1) / 2
                RunService.Heartbeat:Wait()
            end
            -- faíscas no fim do corte
            local sp = Instance.new("Part")
            sp.Anchored, sp.CanCollide, sp.CanQuery, sp.CanTouch, sp.CastShadow = true, false, false, false, false
            sp.Transparency = 1
            sp.Size = Vector3.new(0.2, 0.2, 0.2)
            sp.Position = b
            sp.Parent = parent
            local e = Instance.new("ParticleEmitter")
            e.Rate = 0
            e.Lifetime = NumberRange.new(0.3, 0.7)
            e.Speed = NumberRange.new(10, 35)
            e.SpreadAngle = Vector2.new(180, 180)
            e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0) })
            e.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(255, 30, 30))
            e.LightEmission, e.LightInfluence = 1, 0
            e.Parent = sp
            e:Emit(CLEAVE_LOW and 4 or 10)
            DBv:AddItem(sp, 1)
            for _, m in ipairs(beams) do
                TSv:Create(m, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Width0 = 0, Width1 = 0 }):Play()
            end
            if trail then
                TSv:Create(trail, TweenInfo.new(life + 0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Width0 = 0, Width1 = 0 }):Play()
            end
        end)
    end)
end

-- cenário do Santuário Malevolente: chão rachado brilhando, entulho, pilares e montanhas cortados ao meio
function buildSukunaScenery(parent, center, halfX, halfZ, count, avoid)
    avoid = avoid or 0
    local function mk(size, cf, color, mat, transp)
        local p = Instance.new("Part")
        p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, true
        p.Size, p.CFrame, p.Color = size, cf, color
        p.Material = mat or Enum.Material.Slate
        p.Transparency = transp or 0
        p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
        p.Parent = parent
        return p
    end
    local function rpos()
        local pos
        for _ = 1, 8 do
            pos = center + Vector3.new((math.random() * 2 - 1) * halfX, 0, (math.random() * 2 - 1) * halfZ)
            if (Vector3.new(pos.X - center.X, 0, pos.Z - center.Z)).Magnitude >= avoid then break end
        end
        return pos
    end
    local ROCK, ROCK2 = Color3.fromRGB(34, 28, 30), Color3.fromRGB(22, 18, 20)
    local GLOW = Color3.fromRGB(255, 25, 25)

    -- rachaduras brilhando no chão
    for _ = 1, count * 5 do
        local p = rpos()
        local c = mk(Vector3.new(0.5 + math.random() * 0.8, 0.15, 18 + math.random() * 60),
            CFrame.new(p + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, math.random() * math.pi, 0), GLOW, Enum.Material.Neon, 0.1)
        c.CastShadow = false
    end
    -- entulho espalhado
    for _ = 1, count * 12 do
        local p = rpos()
        local s = 0.8 + math.random() * 4
        mk(Vector3.new(s * (0.6 + math.random()), s * (0.4 + math.random() * 0.8), s * (0.6 + math.random())),
            CFrame.new(p + Vector3.new(0, s * 0.3, 0)) * CFrame.Angles(math.random() * 0.8, math.random() * 6.28, math.random() * 0.8),
            (math.random() < 0.5) and ROCK or ROCK2)
    end
    -- bloco cortado ao meio (parte de cima desliza), com a linha do corte brilhando
    local function sliced(p, w, h, d)
        local base = CFrame.new(p) * CFrame.Angles(0, math.random() * math.pi, 0)
        local cutH = h * (0.35 + math.random() * 0.3)
        mk(Vector3.new(w, cutH, d), base * CFrame.new(0, cutH / 2, 0), ROCK)
        local slide = (math.random() < 0.5 and 1 or -1) * (w * 0.06 + math.random() * 4)
        mk(Vector3.new(w * 0.97, h - cutH, d * 0.97),
            base * CFrame.new(slide, cutH + (h - cutH) / 2 + 1.5, slide * 0.4) * CFrame.Angles(0, 0, math.rad(slide * 0.8)), ROCK)
        local g = mk(Vector3.new(w * 1.02, 0.35, d * 1.02), base * CFrame.new(0, cutH + 0.2, 0), GLOW, Enum.Material.Neon, 0.1)
        g.CastShadow = false
    end
    for _ = 1, count do
        sliced(rpos(), 12 + math.random() * 16, 40 + math.random() * 70, 12 + math.random() * 16)
    end
    -- montanhas cortadas ao fundo
    for _ = 1, 3 do
        local ang = math.random() * math.pi * 2
        local p = center + Vector3.new(math.cos(ang) * halfX * 0.9, 0, math.sin(ang) * halfZ * 0.9)
        sliced(p, 90 + math.random() * 60, 110 + math.random() * 80, 90 + math.random() * 60)
    end
    -- pedaços de terra flutuando
    for _ = 1, count * 2 do
        local p = rpos() + Vector3.new(0, 15 + math.random() * 55, 0)
        local s = 2 + math.random() * 7
        mk(Vector3.new(s * 1.3, s * 0.7, s), CFrame.new(p) * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6), ROCK2)
    end
end

SUKUNA_BUSY, SUKUNA_ABORT, SUKUNA_CASTER = false, false, nil
DOMAIN_BATTLE = { active = false, token = 0, count = 0 }

-- ======== CHOQUE DE DOMÍNIOS 3D (Sukuna vermelho x Gojo azul) ========
do
    local TS = game:GetService("TweenService")
    local DB = game:GetService("Debris")
    local LOWFX = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local function part(parent, size, cf, color, mat, transp, shape)
        local p = Instance.new("Part")
        p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
        if shape then p.Shape = shape end
        p.Size, p.CFrame, p.Color = size, cf, color
        p.Material = mat or Enum.Material.SmoothPlastic
        p.Transparency = transp or 0
        p.Parent = parent
        return p
    end

    local function tween(o, t, props, style, dir)
        local tw = TS:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
        tw:Play()
        return tw
    end

    -- pedaços de vidro caindo (domínio destruído)
    local function shatter(center, radius, count, glowC, baseC)
        local folder = Instance.new("Folder")
        folder.Name = "DomainShatter"
        folder.Parent = workspace
        for _ = 1, count do
            task.delay(math.random() * 0.5, function()
                local pc = Instance.new("Part")
                pc.Size = Vector3.new(1 + math.random() * 6, 1 + math.random() * 5, 0.12 + math.random() * 0.3)
                pc.Material = Enum.Material.Neon
                pc.Color = glowC
                pc.Transparency = 0.05
                pc.CanCollide, pc.CanQuery, pc.CanTouch, pc.CastShadow = false, false, false, false
                local ang, elev = math.random() * math.pi * 2, (math.random() - 0.5) * math.pi
                local r = radius * (0.25 + 0.75 * math.random())
                local off = Vector3.new(math.cos(ang) * math.cos(elev) * r, math.sin(elev) * r * 0.7, math.sin(ang) * math.cos(elev) * r)
                pc.CFrame = CFrame.new(center + off) * CFrame.Angles(math.random() * 6.28, math.random() * 6.28, math.random() * 6.28)
                pc.Anchored = false
                pc.Parent = folder
                pc.AssemblyLinearVelocity = off.Unit * (4 + math.random() * 16) + Vector3.new(0, -2 - math.random() * 18, 0)
                pc.AssemblyAngularVelocity = Vector3.new((math.random() - 0.5) * 14, (math.random() - 0.5) * 14, (math.random() - 0.5) * 14)
                task.delay(0.12, function()
                    if pc.Parent then
                        pc.Material = Enum.Material.Glass
                        pc.Color = baseC
                        pc.Transparency = 0.3
                    end
                end)
                task.delay(2.2, function()
                    if pc.Parent then tween(pc, 0.9, { Transparency = 1 }) end
                end)
                DB:AddItem(pc, 4)
            end)
        end
        pcall(function()
            local sn = Instance.new("Sound")
            sn.SoundId, sn.Volume = "rbxassetid://5221180459", 3.5
            sn.Parent = workspace
            sn:Play()
            DB:AddItem(sn, 4)
        end)
        DB:AddItem(folder, 6)
    end

    local function runBattle(token, gojoName, sukunaName, targetL)
        -- cancela os domínios individuais e espera eles se limparem
        GOJO.cancelFlag = true
        SUKUNA_ABORT = true
        local w0 = os.clock()
        while (GOJO.busy or SUKUNA_BUSY) and os.clock() - w0 < 6 do task.wait(0.05) end
        GOJO.cancelFlag = false
        SUKUNA_ABORT = false
        if DOMAIN_BATTLE.token ~= token then return end

        local me = LocalPlayer.Name
        local meL, myDisp = string.lower(me), string.lower(LocalPlayer.DisplayName)
        local isSukuna = (sukunaName == me)
        local isGojo = (gojoName == me)
        local isTarget = (not isSukuna) and (not isGojo) and targetL ~= nil and targetL ~= ""
            and (targetL == meL or targetL == myDisp)
        local participant = isSukuna or isGojo or isTarget

        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if participant and (not myHrp or not myHum or myHum.Health <= 0) then participant = false end

        local gp = gojoName and Players:FindFirstChild(gojoName)
        local gHrp = gp and gp.Character and gp.Character:FindFirstChild("HumanoidRootPart")
        local near = participant or (gHrp ~= nil and myHrp ~= nil and (myHrp.Position - gHrp.Position).Magnitude <= 300)

        -- resultado igual pra todo mundo (calculado com os nomes)
        local sum = DOMAIN_BATTLE.count
        for _, nm in ipairs({ gojoName or "", sukunaName or "" }) do
            for i = 1, #nm do sum += string.byte(nm, i) end
        end
        DOMAIN_BATTLE.count += 1
        local sukunaWins = (sum % 100) < 65

        local C = Vector3.new(0, 8000, 0)
        local folder = Instance.new("Folder")
        folder.Name = "DomainBattleWorld"
        folder.Parent = workspace

        local cam = workspace.CurrentCamera
        local oldFov = cam and cam.FieldOfView or 70
        local oldLook = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
        local renderName = "DomainBattle" .. tostring(math.random(1, 1000000))
        local saved, hiddenAtm, hiddenSky = {}, {}, {}
        local cc, bloom, gui, flash, ttl, sky, bb, L, shrine, wall
        local teleported, returnCF = false, nil
        local aimFrames = 0
        local arenaOn, redOn, blueOn = false, true, true
        local smokesRed, smokesBlue = {}, {}
        local barrier = {}
        local lineData, wallX, techSaved, atm, dof, dome = {}, 0, nil, nil, nil, nil
        local T0 = os.clock()

        local function alive() return DOMAIN_BATTLE.token == token end
        local function waitUntil(t)
            while alive() and os.clock() - T0 < t do task.wait() end
            return alive()
        end

        local function crack()
            if not gui then return end
            local cx, cy = 0.2 + math.random() * 0.6, 0.25 + math.random() * 0.5
            for i = 1, 16 do
                local f = Instance.new("Frame")
                f.AnchorPoint = Vector2.new(0, 0.5)
                f.Position = UDim2.fromScale(cx, cy)
                f.Size = UDim2.new(0, 0, 0, 2 + math.random() * 2)
                f.Rotation = (i / 16) * 360 + math.random(-10, 10)
                f.BackgroundColor3, f.BorderSizePixel, f.ZIndex = Color3.new(1, 1, 1), 0, 40
                f.Parent = gui
                tween(f, 0.18 + math.random() * 0.12, { Size = UDim2.new(0, 260 + math.random() * 700, 0, f.Size.Y.Offset) })
                task.delay(0.55, function()
                    if f.Parent then tween(f, 0.3, { BackgroundTransparency = 1 }) end
                end)
                DB:AddItem(f, 1.2)
            end
        end

        -- risco afilado (feixe): grosso no meio, pontudo nas pontas, branco com borda preta
        local function beamLine(a, b, w, coreC, outC, life)
            local holder = part(folder, Vector3.new(0.2, 0.2, 0.2), CFrame.new(a), Color3.new(1, 1, 1), nil, 1)
            local a0 = Instance.new("Attachment")
            a0.Parent = holder
            a0.WorldPosition = a
            local am = Instance.new("Attachment")
            am.Parent = holder
            am.WorldPosition = (a + b) / 2
            local a1 = Instance.new("Attachment")
            a1.Parent = holder
            a1.WorldPosition = b
            local made = {}
            local function bm(x0, x1, w0, w1, color, emis, tr)
                local m = Instance.new("Beam")
                m.Attachment0, m.Attachment1 = x0, x1
                m.Width0, m.Width1 = w0, w1
                m.FaceCamera, m.Segments = true, 1
                m.Color = ColorSequence.new(color)
                m.Transparency = NumberSequence.new(tr or 0)
                m.LightEmission, m.LightInfluence = emis, 0
                m.Parent = holder
                made[#made + 1] = m
            end
            if outC then
                bm(a0, am, 0, w * 2.2, outC, 0, 0.25)
                bm(am, a1, w * 2.2, 0, outC, 0, 0.25)
            end
            bm(a0, am, 0, w, coreC, 1, 0)
            bm(am, a1, w, 0, coreC, 1, 0)
            for _, m in ipairs(made) do
                tween(m, life, { Width0 = 0, Width1 = 0 })
            end
            DB:AddItem(holder, life + 0.15)
        end

        local function randDir()
            local d = Vector3.new(math.random() - 0.5, (math.random() - 0.5) * 1.4, math.random() - 0.5)
            if d.Magnitude < 0.05 then d = Vector3.new(1, 0.3, 0) end
            return d.Unit
        end

        -- cortes do Sukuna (lado vermelho)
        local function slashRed()
            local base = C + Vector3.new(-130 + math.random() * 150, 5 + math.random() * 95, -120 + math.random() * 150)
            local d = randDir()
            local len = 60 + math.random() * 150
            local thin = math.random() < 0.45
            local w = thin and (0.25 + math.random() * 0.3) or (2 + math.random() * 3.5)
            cleaveLine(folder, base - d * len / 2, base + d * len / 2, thin and 0.35 or (1.2 + math.random() * 1.6), 0.45)
        end

        -- riscos finos vermelhos/roxos na borda esquerda (como na referência)
        local function edgeStreak()
            local base = C + Vector3.new(-170 + math.random() * 60, 5 + math.random() * 100, -120 + math.random() * 150)
            local d = Vector3.new(1, (math.random() - 0.5) * 0.6, (math.random() - 0.5) * 0.3).Unit
            local len = 90 + math.random() * 110
            local col = (math.random() < 0.5) and Color3.fromRGB(255, 30, 50) or Color3.fromRGB(90, 70, 255)
            beamLine(base - d * len / 2, base + d * len / 2, 0.6 + math.random() * 1.2, col, nil, 0.35)
        end

        -- riscos azuis/rosa do lado do Gojo
        local BLUES = { Color3.fromRGB(60, 120, 255), Color3.fromRGB(150, 90, 255), Color3.fromRGB(255, 80, 170), Color3.fromRGB(180, 230, 255) }
        local function streakBlue()
            local base = C + Vector3.new(10 + math.random() * 180, 5 + math.random() * 100, -150 + math.random() * 170)
            local d = Vector3.new(1, (math.random() - 0.5) * 0.15, (math.random() - 0.5) * 0.3).Unit
            local len = 80 + math.random() * 120
            beamLine(base - d * len / 2, base + d * len / 2, 0.7 + math.random() * 1.3, BLUES[math.random(#BLUES)], nil, 0.35)
        end

        -- rachadura / raio branco atravessando a parede de choque
        local function crackBolt()
            local a = C + Vector3.new(wallX + (math.random() - 0.5) * 6, 5 + math.random() * 100, -150 + math.random() * 170)
            local b = a + Vector3.new((math.random() - 0.5) * 8, (math.random() - 0.5) * 120, (math.random() - 0.5) * 160)
            local segs = 9
            local holder = part(folder, Vector3.new(0.2, 0.2, 0.2), CFrame.new(a), Color3.new(1, 1, 1), nil, 1)
            local atts = {}
            local dir = b - a
            for i = 0, segs do
                local at = Instance.new("Attachment")
                at.Parent = holder
                local jit = (i == 0 or i == segs) and 0 or 7
                at.WorldPosition = a + dir * (i / segs)
                    + Vector3.new((math.random() - 0.5) * jit, (math.random() - 0.5) * jit, (math.random() - 0.5) * jit)
                atts[#atts + 1] = at
            end
            local glow = (math.random() < 0.5) and Color3.fromRGB(255, 40, 60) or Color3.fromRGB(70, 110, 255)
            local made = {}
            for i = 1, segs do
                for _, spec in ipairs({ { glow, 1.8, 0.45 }, { Color3.new(1, 1, 1), 0.5, 0 } }) do
                    local m = Instance.new("Beam")
                    m.Attachment0, m.Attachment1 = atts[i], atts[i + 1]
                    m.Width0, m.Width1 = spec[2], spec[2]
                    m.FaceCamera, m.Segments = true, 1
                    m.Color = ColorSequence.new(spec[1])
                    m.Transparency = NumberSequence.new(spec[3])
                    m.LightEmission, m.LightInfluence = 1, 0
                    m.Parent = holder
                    made[#made + 1] = m
                end
            end
            for _, m in ipairs(made) do tween(m, 0.3, { Width0 = 0, Width1 = 0 }) end
            DB:AddItem(holder, 0.4)
        end

        local ok, err = pcall(function()
            -- ===== 1) BOLINHA PRETA DO GOJO (todo mundo perto vê) =====
            if near and gHrp then
                local pos = gHrp.Position + Vector3.new(0, 4, 0)
                local ball = part(folder, Vector3.new(1, 1, 1), CFrame.new(pos), Color3.new(0, 0, 0), nil, 0, Enum.PartType.Ball)
                local shell = part(folder, Vector3.new(1, 1, 1), CFrame.new(pos), Color3.fromRGB(150, 220, 255), Enum.Material.Neon, 0.8, Enum.PartType.Ball)
                local rshell = part(folder, Vector3.new(1, 1, 1), CFrame.new(pos), Color3.fromRGB(255, 40, 40), Enum.Material.Neon, 0.85, Enum.PartType.Ball)
                tween(ball, 0.7, { Size = Vector3.new(7, 7, 7) }, Enum.EasingStyle.Back)
                tween(shell, 0.7, { Size = Vector3.new(9, 9, 9) }, Enum.EasingStyle.Back)
                tween(rshell, 0.9, { Size = Vector3.new(12, 12, 12) }, Enum.EasingStyle.Back)
                task.delay(1.6, function()
                    pcall(function()
                        tween(ball, 0.3, { Size = Vector3.new(1, 1, 1) })
                        tween(shell, 0.3, { Size = Vector3.new(1, 1, 1), Transparency = 1 })
                        tween(rshell, 0.3, { Size = Vector3.new(1, 1, 1), Transparency = 1 })
                    end)
                end)
            end

            -- ===== preparação de quem vai pro choque =====
            if participant then
                for _, k in ipairs({ "Ambient", "OutdoorAmbient", "Brightness", "ClockTime", "FogColor", "FogStart", "FogEnd", "ExposureCompensation" }) do
                    pcall(function() saved[k] = Lighting[k] end)
                end
                pcall(function()
                    for _, c in ipairs(Lighting:GetChildren()) do
                        if c:IsA("Atmosphere") then table.insert(hiddenAtm, c) c.Parent = nil
                        elseif c:IsA("Sky") then table.insert(hiddenSky, c) c.Parent = nil end
                    end
                end)

                local pg = LocalPlayer:WaitForChild("PlayerGui", 3)
                gui = Instance.new("ScreenGui")
                gui.Name, gui.IgnoreGuiInset, gui.ResetOnSpawn, gui.DisplayOrder = "DomainBattleGui", true, false, 70
                gui.Parent = pg
                flash = Instance.new("Frame")
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3, flash.BorderSizePixel, flash.BackgroundTransparency, flash.ZIndex = Color3.new(1, 1, 1), 0, 1, 100
                flash.Parent = gui

                ttl = Instance.new("TextLabel")
                ttl.Size, ttl.Position, ttl.BackgroundTransparency = UDim2.new(0.9, 0, 0, 40), UDim2.new(0.05, 0, 0.03, 0), 1
                ttl.Text, ttl.TextColor3, ttl.Font, ttl.TextSize = "", Color3.new(1, 1, 1), Enum.Font.GothamBlack, 28
                ttl.TextStrokeTransparency, ttl.ZIndex = 0, 30
                ttl.Parent = gui

                local ls = Instance.new("TextLabel")
                ls.Size, ls.Position, ls.BackgroundTransparency = UDim2.new(0.4, 0, 0, 34), UDim2.new(0.04, 0, 0.9, 0), 1
                ls.Text, ls.TextColor3, ls.Font, ls.TextSize, ls.TextStrokeTransparency, ls.ZIndex = "SUKUNA", Color3.fromRGB(255, 70, 70), Enum.Font.GothamBlack, 26, 0, 30
                ls.Parent = gui
                local rs = Instance.new("TextLabel")
                rs.Size, rs.Position, rs.BackgroundTransparency = UDim2.new(0.4, 0, 0, 34), UDim2.new(0.56, 0, 0.9, 0), 1
                rs.Text, rs.TextColor3, rs.Font, rs.TextSize, rs.TextStrokeTransparency, rs.ZIndex = "GOJO SATORU", Color3.fromRGB(80, 180, 255), Enum.Font.GothamBlack, 26, 0, 30
                rs.Parent = gui

                cc = Instance.new("ColorCorrectionEffect")
                cc.Parent = Lighting
                bloom = Instance.new("BloomEffect")
                bloom.Intensity, bloom.Size, bloom.Threshold = 0, 40, 0.8
                bloom.Parent = Lighting
                tween(bloom, 1.0, { Intensity = 2.2, Size = 60 })

                -- realismo: luz Future (sombras de luzes), névoa roxa, profundidade de campo, luzes de contorno
                pcall(function() techSaved = gethiddenproperty(Lighting, "Technology") end)
                pcall(function() sethiddenproperty(Lighting, "Technology", Enum.Technology.Future) end)
                pcall(function()
                    atm = Instance.new("Atmosphere")
                    atm.Name = "DomainBattleAtm"
                    atm.Density, atm.Offset, atm.Glare, atm.Haze = 0.3, 0.1, 0, 1.2
                    atm.Color, atm.Decay = Color3.fromRGB(90, 30, 100), Color3.fromRGB(40, 10, 50)
                    atm.Parent = Lighting
                    dof = Instance.new("DepthOfFieldEffect")
                    dof.Name = "DomainBattleDOF"
                    dof.FarIntensity, dof.NearIntensity, dof.FocusDistance, dof.InFocusRadius = 0.3, 0, 40, 70
                    dof.Parent = Lighting
                end)
                for _, sx in ipairs({ -1, 1 }) do
                    local lp = part(folder, Vector3.new(1, 1, 1), CFrame.new(C + Vector3.new(sx * 34, 14, 20)), Color3.new(1, 1, 1), nil, 1)
                    local pl = Instance.new("PointLight")
                    pl.Color = sx < 0 and Color3.fromRGB(255, 25, 30) or Color3.fromRGB(70, 130, 255)
                    pl.Range, pl.Brightness, pl.Shadows = 45, 7, true
                    pl.Parent = lp
                end

                -- ---------- ARENA ----------
                local function solid(size, off)
                    local b = part(folder, size, CFrame.new(C + off), Color3.new(1, 1, 1), nil, 1)
                    b.CanCollide = true
                end
                solid(Vector3.new(300, 4, 260), Vector3.new(0, -2, -20))
                solid(Vector3.new(4, 300, 260), Vector3.new(-150, 140, -20))
                solid(Vector3.new(4, 300, 260), Vector3.new(150, 140, -20))
                solid(Vector3.new(300, 300, 4), Vector3.new(0, 140, -150))
                solid(Vector3.new(300, 300, 4), Vector3.new(0, 140, 110))
                solid(Vector3.new(300, 4, 260), Vector3.new(0, 290, -20))

                sky = Instance.new("Sky")
                sky.Name = "DomainBattleSky"
                sky.StarCount = 4000
                sky.CelestialBodiesShown = false
                sky.Parent = Lighting

                local function setL(k, v) pcall(function() Lighting[k] = v end) end
                setL("Ambient", Color3.fromRGB(40, 10, 48))
                setL("OutdoorAmbient", Color3.fromRGB(25, 5, 35))
                setL("Brightness", 0.3)
                setL("ClockTime", 0)
                setL("FogColor", Color3.fromRGB(16, 0, 26))
                setL("FogStart", 250)
                setL("FogEnd", 1800)
                setL("ExposureCompensation", 0)
                setL("GlobalShadows", true)
                setL("EnvironmentDiffuseScale", 0.4)
                setL("EnvironmentSpecularScale", 0.6)

                -- luzes coloridas (vermelho à esquerda, azul à direita)
                for i = 1, 4 do
                    local rl = part(folder, Vector3.new(1, 1, 1), CFrame.new(C + Vector3.new(-40 - i * 35, 30, -120 + i * 45)), Color3.new(1, 1, 1), nil, 1)
                    local pl = Instance.new("PointLight")
                    pl.Color, pl.Range, pl.Brightness = Color3.fromRGB(255, 20, 20), 60, 5
                    pl.Parent = rl
                    local bl = part(folder, Vector3.new(1, 1, 1), CFrame.new(C + Vector3.new(40 + i * 35, 30, -120 + i * 45)), Color3.new(1, 1, 1), nil, 1)
                    local pl2 = Instance.new("PointLight")
                    pl2.Color, pl2.Range, pl2.Brightness = Color3.fromRGB(60, 140, 255), 60, 5
                    pl2.Parent = bl
                end

                -- fumaça: vermelha manchada (Sukuna) e azul-turquesa igual ao domínio normal do Gojo
                local function puff(pos, seq, list, glow, szA, szB, rate, tr0)
                    local sp = part(folder, Vector3.new(4, 4, 4), CFrame.new(pos), Color3.new(1, 1, 1), nil, 1)
                    local e = Instance.new("ParticleEmitter")
                    e.Texture = "rbxasset://textures/particles/smoke_main.dds"
                    e.Rate = rate
                    e.Lifetime = NumberRange.new(7, 11)
                    e.Speed = NumberRange.new(2, 7)
                    e.SpreadAngle = Vector2.new(180, 180)
                    e.Rotation = NumberRange.new(0, 360)
                    e.RotSpeed = NumberRange.new(-10, 10)
                    e.Drag = 0.5
                    e.LightEmission, e.LightInfluence = glow, 0
                    e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, szA), NumberSequenceKeypoint.new(1, szB) })
                    e.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.18, tr0),
                        NumberSequenceKeypoint.new(0.8, math.min(tr0 + 0.1, 1)), NumberSequenceKeypoint.new(1, 1) })
                    e.Color = seq
                    e.Parent = sp
                    list[#list + 1] = e
                    return sp
                end

                local redBright = ColorSequence.new(Color3.fromRGB(235, 10, 12), Color3.fromRGB(170, 0, 8))
                local redDark   = ColorSequence.new(Color3.fromRGB(110, 0, 10), Color3.fromRGB(60, 0, 6))
                local redBlack  = ColorSequence.new(Color3.fromRGB(18, 0, 6), Color3.fromRGB(8, 0, 4))
                local redGlow   = ColorSequence.new(Color3.fromRGB(255, 40, 30), Color3.fromRGB(200, 0, 0))
                local tealSeq   = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 140, 170)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 80, 115)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 30, 55)) })

                -- lado vermelho SOMBRIO: nuvens densas escuras e névoa baixa (sem fumaça vermelha viva)
                local mistRed = ColorSequence.new(Color3.fromRGB(70, 0, 6), Color3.fromRGB(25, 0, 3))
                local cloudBlack = ColorSequence.new(Color3.fromRGB(10, 2, 4), Color3.fromRGB(28, 4, 8))
                for _ = 1, (LOWFX and 6 or 10) do
                    local pos = C + Vector3.new(-190 + math.random() * 182, 150 + math.random() * 110, -190 + math.random() * 230)
                    puff(pos, cloudBlack, smokesRed, 0, 120, 240, 1.4, 0.35)
                    puff(pos, mistRed, smokesRed, 0.05, 110, 220, 1.0, 0.5)
                end
                for _ = 1, (LOWFX and 4 or 7) do
                    puff(C + Vector3.new(-190 + math.random() * 182, 4 + math.random() * 18, -180 + math.random() * 210),
                        mistRed, smokesRed, 0, 90, 170, 1.0, 0.65)
                end
                local moon = part(folder, Vector3.new(90, 90, 90), CFrame.new(C + Vector3.new(-110, 230, -170)),
                    Color3.fromRGB(150, 0, 10), Enum.Material.Neon, 0.1, Enum.PartType.Ball)
                moon.CastShadow = false

                -- lado azul: o mesmo cosmos do domínio normal do Gojo
                for i = 1, (LOWFX and 7 or 12) do
                    local a = (i / 12) * math.pi * 2
                    local pos = C + Vector3.new(120 + math.cos(a) * 90, 20 + math.random() * 110, -90 + math.sin(a) * 110)
                    puff(pos, tealSeq, smokesBlue, 0.35, 160, 320, LOWFX and 1.2 or 2.5, 0.55)
                end
                for _, off in ipairs({ Vector3.new(120, 40, -100), Vector3.new(55, -5, -95), Vector3.new(105, 75, -120) }) do
                    local sp = part(folder, Vector3.new(4, 4, 4), CFrame.new(C + off), Color3.new(1, 1, 1), nil, 1)
                    local e = Instance.new("ParticleEmitter")
                    e.Texture = "rbxasset://textures/particles/smoke_main.dds"
                    e.Rate = LOWFX and 3 or 6
                    e.Lifetime = NumberRange.new(4, 7)
                    e.Speed = NumberRange.new(4, 14)
                    e.SpreadAngle = Vector2.new(180, 180)
                    e.Rotation = NumberRange.new(0, 360)
                    e.RotSpeed = NumberRange.new(-40, 40)
                    e.Drag = 1.2
                    e.LightEmission, e.LightInfluence = 0.8, 0
                    e.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 14), NumberSequenceKeypoint.new(0.5, 32), NumberSequenceKeypoint.new(1, 44) })
                    e.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.1),
                        NumberSequenceKeypoint.new(0.7, 0.45), NumberSequenceKeypoint.new(1, 1) })
                    e.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 225, 245))
                    e.Parent = sp
                    smokesBlue[#smokesBlue + 1] = e
                end

                -- estrelas (fundo do cosmos do Gojo)
                local starPart = part(folder, Vector3.new(460, 460, 460), CFrame.new(C + Vector3.new(0, 100, -20)), Color3.new(1, 1, 1), nil, 1)
                local stars = Instance.new("ParticleEmitter")
                pcall(function()
                    stars.Shape = Enum.ParticleEmitterShape.Box
                    stars.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
                    stars.ShapeInOut = Enum.ParticleEmitterShapeInOut.InAndOut
                end)
                stars.Rate = LOWFX and 20 or 45
                stars.Lifetime = NumberRange.new(6, 10)
                stars.Speed = NumberRange.new(0, 2)
                stars.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 5),
                    NumberSequenceKeypoint.new(0.8, 5), NumberSequenceKeypoint.new(1, 0) })
                stars.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(150, 220, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 150, 255)) })
                stars.LightEmission, stars.LightInfluence = 1, 0
                stars.Parent = starPart
                stars:Emit(LOWFX and 80 or 200)

                -- fogo e brasas no lado vermelho
                for _ = 1, (LOWFX and 5 or 10) do
                    local fp = part(folder, Vector3.new(4, 4, 4), CFrame.new(C + Vector3.new(-170 + math.random() * 150, 2 + math.random() * 30, -160 + math.random() * 190)), Color3.new(1, 1, 1), nil, 1)
                    local fe = Instance.new("ParticleEmitter")
                    fe.Texture = "rbxasset://textures/particles/fire_main.dds"
                    fe.Rate = LOWFX and 3 or 6
                    fe.Lifetime = NumberRange.new(1, 2)
                    fe.Speed = NumberRange.new(6, 16)
                    fe.SpreadAngle = Vector2.new(25, 25)
                    fe.EmissionDirection = Enum.NormalId.Top
                    fe.Acceleration = Vector3.new(0, 10, 0)
                    fe.Rotation = NumberRange.new(0, 360)
                    fe.RotSpeed = NumberRange.new(-60, 60)
                    fe.LightEmission, fe.LightInfluence = 1, 0
                    fe.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 7), NumberSequenceKeypoint.new(1, 0) })
                    fe.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
                    fe.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 80)),
                        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 50, 20)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 0)) })
                    fe.Parent = fp
                    smokesRed[#smokesRed + 1] = fe
                end

                -- domo vermelho enorme na borda esquerda (domínio do Sukuna visto de longe)
                dome = part(folder, Vector3.new(300, 300, 300), CFrame.new(C + Vector3.new(-250, 60, -50)), Color3.fromRGB(95, 0, 8), Enum.Material.Neon, 0.1, Enum.PartType.Ball)
                buildSukunaScenery(folder, C + Vector3.new(-85, 0, -115), 70, 75, LOWFX and 3 or 6, 0)

                -- linhas de velocidade vermelhas/azuis saindo do buraco negro
                local holeC = C + Vector3.new(80, 45, -140)
                local LC = { Color3.fromRGB(255, 30, 60), Color3.fromRGB(255, 30, 60), Color3.fromRGB(60, 80, 255),
                    Color3.fromRGB(60, 80, 255), Color3.fromRGB(150, 90, 255), Color3.new(1, 1, 1) }
                for i = 1, (LOWFX and 30 or 60) do
                    local tgt = C + Vector3.new(-130 + math.random() * 260, math.random() * 100, math.random() * 60)
                    local d = (tgt - holeC).Unit
                    local len = 60 + math.random() * 120
                    local pt = part(folder, Vector3.new(0.35, 0.35, len), CFrame.new(holeC), LC[math.random(#LC)], Enum.Material.Neon, 0.1)
                    lineData[i] = { part = pt, d = d, r = 30 + math.random() * 400, sp = 260 + math.random() * 420, V = holeC }
                end

                -- parede de choque no meio
                wall = part(folder, Vector3.new(2.5, 260, 260), CFrame.new(C + Vector3.new(0, 110, -20)), Color3.fromRGB(255, 235, 200), Enum.Material.Neon, 0.75)
                local sparks = Instance.new("ParticleEmitter")
                pcall(function()
                    sparks.Shape = Enum.ParticleEmitterShape.Box
                    sparks.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
                end)
                sparks.Rate = LOWFX and 40 or 90
                sparks.Lifetime = NumberRange.new(0.4, 0.9)
                sparks.Speed = NumberRange.new(20, 60)
                sparks.SpreadAngle = Vector2.new(180, 180)
                sparks.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.4), NumberSequenceKeypoint.new(1, 0) })
                sparks.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(255, 150, 60))
                sparks.LightEmission, sparks.LightInfluence = 1, 0
                sparks.Parent = wall

                -- BARREIRA: parede de fumaça (vermelha do lado do Sukuna, azul do lado do Gojo)
                for _, zz in ipairs({ -170, -120, -70, -20, 30 }) do
                    for _, yy in ipairs({ 20, 60, 100 }) do
                        if not LOWFX or ((zz + yy) % 100 == 0) then
                            local hr = puff(C + Vector3.new(-8, yy, zz), mistRed, smokesRed, 0.05, 40, 90, 1.0, 0.45)
                            local hb = puff(C + Vector3.new(8, yy, zz), tealSeq, smokesBlue, 0.35, 40, 90, 1.2, 0.3)
                            barrier[#barrier + 1] = { part = hr, dx = -8, y = yy, z = zz }
                            barrier[#barrier + 1] = { part = hb, dx = 8, y = yy, z = zz }
                        end
                    end
                end

                -- santuário do Sukuna (lado vermelho)
                task.spawn(function()
                    local sm = fetchAssetAsModel(SUK_SHRINE)
                    if not sm or not alive() then return end
                    shrine = sm
                    sm.Parent = folder
                    pcall(function() sm:ScaleTo(7) end)
                    for _, p in ipairs(sm:GetDescendants()) do
                        if p:IsA("BasePart") then p.Anchored, p.CanCollide = true, false end
                    end
                    local bcf, bs = sm:GetBoundingBox()
                    local bo = sm:GetPivot().Position.Y - (bcf.Position.Y - bs.Y / 2)
                    local tcf = CFrame.new(C.X - 85, C.Y + bo + SHRINE_Y, C.Z - 150)
                        * CFrame.lookAt(Vector3.zero, Vector3.new(0, 0, 1)).Rotation * CFrame.Angles(0, math.rad(SHRINE_YAW), 0)
                    local scf = tcf * CFrame.new(0, -40, 0)
                    sm:PivotTo(scf)
                    for i = 1, 50 do
                        if not sm.Parent then return end
                        local a = i / 50
                        sm:PivotTo(scf:Lerp(tcf, a * a * (3 - 2 * a)))
                        task.wait(0.015)
                    end
                    if sm.Parent then sm:PivotTo(tcf) end
                end)

                -- loop visual
                RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function(dt)
                    local t = os.clock() - T0
                    if aimFrames > 0 and cam and myHrp and myHrp.Parent then
                        aimFrames -= 1
                        local p = myHrp.Position
                        cam.CFrame = CFrame.lookAt(p + Vector3.new(0, 5, 16), p + Vector3.new(0, 9, -60))
                    end
                    if L then
                        L.rainbowGrad.Rotation = (L.rainbowGrad.Rotation + 22 * dt) % 360
                        L.swirlGrad.Rotation = (L.swirlGrad.Rotation - 12 * dt) % 360
                        for _, w in ipairs(L.wisps) do w.g.Rotation = (w.g.Rotation + w.speed * dt) % 360 end
                    end
                    if wall and wall.Parent and arenaOn then
                        local pr = math.clamp((t - 1.9) / 7.5, 0, 1)
                        local k = pr * pr * (3 - 2 * pr)
                        local x = (sukunaWins and 1 or -1) * 62 * k + math.sin(t * 6.5) * 7 * (1 - k * 0.6)
                        wallX = x
                        wall.CFrame = CFrame.new(C + Vector3.new(x, 110, -20))
                        for _, bz in ipairs(barrier) do
                            if bz.part.Parent then bz.part.CFrame = CFrame.new(C + Vector3.new(x + bz.dx, bz.y, bz.z)) end
                        end
                        if pr < 1 then wall.Transparency = 0.7 + 0.15 * math.sin(t * 17) end
                    end
                    if arenaOn then
                        for _, ln in ipairs(lineData) do
                            ln.r += ln.sp * dt
                            if ln.r > 460 then ln.r = 30 end
                            local pos = ln.V + ln.d * ln.r
                            ln.part.CFrame = CFrame.lookAt(pos, pos + ln.d)
                        end
                    end
                    if arenaOn and cam then
                        local sh = 0.012
                        cam.CFrame = cam.CFrame * CFrame.Angles(
                            (math.random() - 0.5) * sh, (math.random() - 0.5) * sh, (math.random() - 0.5) * sh * 0.4)
                    end
                end)

                -- cortes vermelhos (esquerda) e riscos azuis (direita)
                task.spawn(function()
                    while alive() and gui and gui.Parent do
                        if arenaOn then
                            if redOn then
                                for _ = 1, (LOWFX and 1 or 2) do slashRed() end
                                if math.random() < 0.7 then edgeStreak() end
                            end
                            if blueOn then for _ = 1, (LOWFX and 1 or 2) do streakBlue() end end
                            if math.random() < 0.45 then crackBolt() end
                        end
                        task.wait(0.07)
                    end
                end)
            end

            -- ===== 2) TELA BRANCA -> TELEPORTE PRO CHOQUE =====
            if not waitUntil(1.4) then return end
            if flash then tween(flash, 0.25, { BackgroundTransparency = 0 }) end
            if not waitUntil(1.75) then return end

            if participant then
                returnCF = myHrp.CFrame
                local spot
                if isSukuna then
                    spot = CFrame.lookAt(C + Vector3.new(-24, 4, 0), C + Vector3.new(-24, 4, -80))
                elseif isGojo then
                    spot = CFrame.lookAt(C + Vector3.new(24, 4, 0), C + Vector3.new(24, 4, -80))
                else
                    spot = CFrame.lookAt(C + Vector3.new(36, 4, 10), C + Vector3.new(36, 4, -80))
                end
                myHrp.AssemblyLinearVelocity = Vector3.zero
                myHrp.CFrame = spot
                teleported = true
                aimFrames = 12
                arenaOn = true

                tween(cc, 0.6, { TintColor = Color3.fromRGB(235, 200, 245), Saturation = 0.3, Contrast = 0.3 })
                tween(bloom, 0.6, { Intensity = 1.2, Size = 30 })
                tween(flash, 1.0, { BackgroundTransparency = 1 })
                if ttl then ttl.Text = "CHOQUE DE DOMINIOS" end
                if cam then tween(cam, 1.2, { FieldOfView = oldFov - 6 }) end

                -- buraco negro do Gojo (lado azul)
                local holeAnchor = part(folder, Vector3.new(1, 1, 1), CFrame.new(C + Vector3.new(80, 45, -140)), Color3.new(1, 1, 1), nil, 1)
                local rootF
                bb, rootF, L = GOJO.buildHole(holeAnchor, 190)
                tween(rootF, 0.9, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Back)
                task.delay(0.6, function()
                    if L then
                        for _, sp in ipairs(L.splash) do
                            task.delay(math.random() * 0.25, function()
                                if sp.f.Parent then tween(sp.f, 0.35, { Size = UDim2.fromScale(sp.w, sp.h) }, Enum.EasingStyle.Back) end
                            end)
                        end
                    end
                end)
            end

            -- ===== 3) A DISPUTA (7.5s) =====
            if not waitUntil(9.4) then return end

            -- ===== 4) RESULTADO: o domínio perdedor quebra como vidro =====
            if sukunaWins then
                if ttl then ttl.Text, ttl.TextColor3, ttl.TextSize = "SUKUNA VENCE! O DOMINIO DO GOJO QUEBROU!", Color3.fromRGB(255, 60, 60), 22 end
                blueOn = false
                if dome then tween(dome, 1.5, { Size = Vector3.new(420, 420, 420) }) end
                for _, e in ipairs(smokesBlue) do e.Enabled = false end
                if participant then
                    crack()
                    if flash then
                        flash.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
                        flash.BackgroundTransparency = 0.3
                        tween(flash, 1.2, { BackgroundTransparency = 1 })
                    end
                    if L and bb then
                        pcall(function() tween(bb.Root, 0.5, { Size = UDim2.fromScale(0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In) end)
                    end
                    shatter(C + Vector3.new(85, 55, -80), 130, LOWFX and 60 or 110, Color3.fromRGB(150, 210, 255), Color3.fromRGB(60, 130, 255))
                    if not isSukuna and myHum and myHum.Parent then
                        task.spawn(function()
                            for _ = 1, 4 do
                                task.wait(0.38)
                                if myHum and myHum.Parent and myHum.Health > 0 then
                                    pcall(function() myHum:TakeDamage(myHum.MaxHealth * 0.17) end)
                                end
                            end
                        end)
                    end
                end
            else
                if ttl then ttl.Text, ttl.TextColor3, ttl.TextSize = "GOJO VENCE! O DOMINIO DO SUKUNA QUEBROU!", Color3.fromRGB(90, 200, 255), 22 end
                redOn = false
                if dome then tween(dome, 0.6, { Transparency = 1 }) end
                for _, e in ipairs(smokesRed) do e.Enabled = false end
                if participant then
                    crack()
                    if flash then
                        flash.BackgroundColor3 = Color3.fromRGB(0, 70, 190)
                        flash.BackgroundTransparency = 0.3
                        tween(flash, 1.2, { BackgroundTransparency = 1 })
                    end
                    if shrine then
                        for _, p in ipairs(shrine:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.Anchored = false
                                p.AssemblyLinearVelocity = Vector3.new((math.random() - 0.5) * 20, -5 - math.random() * 15, (math.random() - 0.5) * 20)
                                p.AssemblyAngularVelocity = Vector3.new((math.random() - 0.5) * 6, (math.random() - 0.5) * 6, (math.random() - 0.5) * 6)
                            end
                        end
                    end
                    shatter(C + Vector3.new(-85, 55, -80), 130, LOWFX and 60 or 110, Color3.fromRGB(255, 90, 90), Color3.fromRGB(170, 20, 20))
                    if isSukuna and myHum and myHum.Parent and myHum.Health > 0 then
                        task.delay(0.5, function()
                            if myHum and myHum.Parent then pcall(function() myHum:TakeDamage(myHum.MaxHealth * 0.55) end) end
                        end)
                    end
                end
            end
            if wall and wall.Parent then tween(wall, 0.6, { Transparency = 1 }) end

            if not waitUntil(13.2) then return end
        end)
        if not ok then warn("[DomainBattle] " .. tostring(err)) end

        -- ===== 5) FINAL: clarão, todo mundo volta, tudo é limpo =====
        arenaOn = false
        pcall(function() RunService:UnbindFromRenderStep(renderName) end)
        pcall(function()
            if flash then
                flash.BackgroundColor3, flash.BackgroundTransparency = Color3.new(1, 1, 1), 0.15
            end
            task.wait(0.2)
            if participant and teleported and returnCF and myHrp and myHrp.Parent and myHum and myHum.Health > 0 then
                myHrp.AssemblyLinearVelocity = Vector3.zero
                myHrp.CFrame = returnCF
                if cam then
                    for _ = 1, 6 do
                        local p = myHrp.Position
                        cam.CFrame = CFrame.lookAt(p - oldLook * 12 + Vector3.new(0, 3, 0), p + oldLook * 40)
                        RunService.RenderStepped:Wait()
                    end
                end
            end
        end)
        pcall(function() if cam then cam.FieldOfView = oldFov end end)
        pcall(function() folder:Destroy() end)
        pcall(function() if bb then bb:Destroy() end end)
        pcall(function() if sky then sky:Destroy() end end)
        pcall(function() if atm then atm:Destroy() end end)
        pcall(function() if dof then dof:Destroy() end end)
        if techSaved ~= nil then pcall(function() sethiddenproperty(Lighting, "Technology", techSaved) end) end
        pcall(function() if cc then cc:Destroy() end end)
        pcall(function() if bloom then bloom:Destroy() end end)
        for k, v in pairs(saved) do pcall(function() Lighting[k] = v end) end
        for _, a in ipairs(hiddenAtm) do pcall(function() a.Parent = Lighting end) end
        for _, a in ipairs(hiddenSky) do pcall(function() a.Parent = Lighting end) end
        if flash then pcall(function() tween(flash, 0.9, { BackgroundTransparency = 1 }) end) end
        task.delay(1.0, function() pcall(function() if gui then gui:Destroy() end end) end)
        if isGojo then GOJO.cdEnd = os.clock() + 20 end
    end

    function startDomainBattle(gojoName, sukunaName, targetL)
        if DOMAIN_BATTLE.active then return end
        DOMAIN_BATTLE.active = true
        DOMAIN_BATTLE.token += 1
        local token = DOMAIN_BATTLE.token
        task.spawn(function()
            local ok, err = pcall(runBattle, token, gojoName, sukunaName, targetL)
            if not ok then warn("[DomainBattle] " .. tostring(err)) end
            DOMAIN_BATTLE.active = false
            SUKUNA_BUSY = false
        end)
    end
end

-- ================== EXPANSÃO DE DOMÍNIO (SUKUNA) - CAIXA ESCURA VERMELHA ==================
local function runSukunaDomain(senderName)
    local sp = Players:FindFirstChild(senderName)
    local sc = sp and sp.Character
    local sh = sc and sc:FindFirstChild("HumanoidRootPart")
    if not sh then return end
    -- Choque de Domínios: se Gojo também está ativo, batalha!
    if type(GOJO)=="table" and GOJO.busy and not DOMAIN_BATTLE.active then
        SUKUNA_CASTER = senderName
        startDomainBattle(GOJO.casterName, senderName, GOJO.currentTarget)
        return
    end
    if DOMAIN_BATTLE.active then return end
    SUKUNA_BUSY = true
    SUKUNA_ABORT = false
    SUKUNA_CASTER = senderName

    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local DURATION, RANGE = 15, 140
    local iAmCaster = (senderName == LocalPlayer.Name)

    local folder = Instance.new("Folder")
    folder.Name = "SukunaDomain"
    folder.Parent = workspace

    -- som do domínio
    local snd = Instance.new("Sound", sh)
    snd.SoundId, snd.Volume = SUK_AUDIO, 5
    snd:Play()
    snd.Ended:Connect(function() snd:Destroy() end)

    -- chão
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances, rp.FilterType = { sc }, Enum.RaycastFilterType.Exclude
    local rr = workspace:Raycast(sh.Position + Vector3.new(0, 50, 0), Vector3.new(0, -200, 0), rp)
    local gy = rr and rr.Position.Y or (sh.Position.Y - 3)
    local cx, cz = sh.Position.X, sh.Position.Z

    -- ===== CAIXA PRETA SOMBRIA =====
    local SIZE, TH = 480, 6
    local half = SIZE / 2
    local cy = gy + half - 20
    local RED = Color3.fromRGB(190, 0, 0)

    local function boxPart(size, pos, color, transp, neon)
        local p = Instance.new("Part")
        p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
        p.Material = neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
        p.Color = color
        p.Transparency = transp or 0
        p.Size = size
        p.Position = pos
        p.Parent = folder
        return p
    end

    local WALL = Color3.fromRGB(8, 0, 0)
    boxPart(Vector3.new(TH, SIZE, SIZE), Vector3.new(cx - half, cy, cz), WALL)
    boxPart(Vector3.new(TH, SIZE, SIZE), Vector3.new(cx + half, cy, cz), WALL)
    boxPart(Vector3.new(SIZE, SIZE, TH), Vector3.new(cx, cy, cz - half), WALL)
    boxPart(Vector3.new(SIZE, SIZE, TH), Vector3.new(cx, cy, cz + half), WALL)
    boxPart(Vector3.new(SIZE, TH, SIZE), Vector3.new(cx, cy + half, cz), WALL)
    boxPart(Vector3.new(SIZE, 0.2, SIZE), Vector3.new(cx, gy + 0.08, cz), Color3.fromRGB(70, 0, 0), 0.35)

    -- veios vermelhos brilhando nas paredes
    for _ = 1, 26 do
        local h = math.random(60, 220)
        local y = gy + math.random(20, 420)
        local off = (math.random() - 0.5) * (SIZE - 40)
        local side = math.random(1, 4)
        if side == 1 then
            boxPart(Vector3.new(0.6, h, 3), Vector3.new(cx - half + TH / 2 + 0.4, y, cz + off), RED, 0.25, true)
        elseif side == 2 then
            boxPart(Vector3.new(0.6, h, 3), Vector3.new(cx + half - TH / 2 - 0.4, y, cz + off), RED, 0.25, true)
        elseif side == 3 then
            boxPart(Vector3.new(3, h, 0.6), Vector3.new(cx + off, y, cz - half + TH / 2 + 0.4), RED, 0.25, true)
        else
            boxPart(Vector3.new(3, h, 0.6), Vector3.new(cx + off, y, cz + half - TH / 2 - 0.4), RED, 0.25, true)
        end
    end

    -- ===== CENÁRIO SOMBRIO: chão destruído, ruínas cortadas, nuvens densas, lua vermelha, brasas =====
    do
        local LOWS = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        buildSukunaScenery(folder, Vector3.new(cx, gy, cz), 190, 190, LOWS and 6 or 12, 32)
        local topY = cy + half
        local function cloudAt(pos, c1, c2, tr)
            local cp = boxPart(Vector3.new(4, 4, 4), pos, Color3.new(1, 1, 1), 1)
            local e = Instance.new("ParticleEmitter")
            e.Texture = "rbxasset://textures/particles/smoke_main.dds"
            e.Rate = LOWS and 1 or 1.6
            e.Lifetime = NumberRange.new(9, 14)
            e.Speed = NumberRange.new(2, 6)
            e.SpreadAngle = Vector2.new(180, 180)
            e.Rotation = NumberRange.new(0, 360)
            e.RotSpeed = NumberRange.new(-6, 6)
            e.Drag = 0.5
            e.LightEmission, e.LightInfluence = 0.03, 0
            e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 180), NumberSequenceKeypoint.new(1, 340) })
            e.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, tr),
                NumberSequenceKeypoint.new(0.8, math.min(tr + 0.1, 1)), NumberSequenceKeypoint.new(1, 1) })
            e.Color = ColorSequence.new(c1, c2)
            e.Parent = cp
        end
        for _ = 1, (LOWS and 7 or 12) do
            local pos = Vector3.new(cx + (math.random() - 0.5) * 420, topY - 40 - math.random() * 70, cz + (math.random() - 0.5) * 420)
            cloudAt(pos, Color3.fromRGB(10, 2, 4), Color3.fromRGB(32, 4, 8), 0.35)
            cloudAt(pos, Color3.fromRGB(80, 0, 8), Color3.fromRGB(30, 0, 4), 0.55)
        end
        local moon = boxPart(Vector3.new(130, 130, 130), Vector3.new(cx + 110, topY - 100, cz - 170), Color3.fromRGB(140, 0, 8), 0.1, true)
        moon.Shape = Enum.PartType.Ball
        -- luzes vermelhas baixas pra iluminar as ruínas
        for _, o in ipairs({ Vector3.new(60, 22, 60), Vector3.new(-60, 22, 60), Vector3.new(60, 22, -60), Vector3.new(-60, 22, -60) }) do
            local lp = boxPart(Vector3.new(1, 1, 1), Vector3.new(cx, gy, cz) + o, Color3.new(1, 1, 1), 1)
            local pl = Instance.new("PointLight")
            pl.Color, pl.Range, pl.Brightness = Color3.fromRGB(255, 20, 20), 60, 3
            pl.Parent = lp
        end
        -- brasas subindo
        local ep = boxPart(Vector3.new(380, 120, 380), Vector3.new(cx, gy + 60, cz), Color3.new(1, 1, 1), 1)
        local em = Instance.new("ParticleEmitter")
        pcall(function()
            em.Shape = Enum.ParticleEmitterShape.Box
            em.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
        end)
        em.Rate = LOWS and 25 or 60
        em.Lifetime = NumberRange.new(4, 7)
        em.Speed = NumberRange.new(3, 9)
        em.Acceleration = Vector3.new(0, 5, 0)
        em.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0) })
        em.Color = ColorSequence.new(Color3.fromRGB(255, 120, 60), Color3.fromRGB(200, 0, 0))
        em.LightEmission, em.LightInfluence = 1, 0
        em.Parent = ep
    end

    -- ===== ILUMINAÇÃO VERMELHA / ESCURA =====
    local saved, hidden = {}, {}
    for _, k in ipairs({ "Ambient", "OutdoorAmbient", "Brightness", "ClockTime", "FogColor", "FogStart", "FogEnd", "ExposureCompensation" }) do
        pcall(function() saved[k] = Lighting[k] end)
    end
    pcall(function()
        for _, c in ipairs(Lighting:GetChildren()) do
            if c:IsA("Atmosphere") then table.insert(hidden, c) c.Parent = nil end
        end
    end)
    local function setL(k, v) pcall(function() Lighting[k] = v end) end
    setL("Ambient", Color3.fromRGB(32, 0, 2))
    setL("OutdoorAmbient", Color3.fromRGB(22, 0, 2))
    setL("Brightness", 0.25)
    setL("ClockTime", 0)
    setL("FogColor", Color3.fromRGB(12, 0, 2))
    setL("FogStart", 10)
    setL("FogEnd", 380)
    setL("ExposureCompensation", -0.5)

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "SukunaCC"
    cc.TintColor = Color3.fromRGB(255, 140, 140)
    cc.Saturation, cc.Contrast, cc.Brightness = 0, 0.35, -0.08
    cc.Parent = Lighting
    local atm = Instance.new("Atmosphere")
    atm.Name = "SukunaAtmosphere"
    atm.Color, atm.Decay = Color3.fromRGB(80, 0, 0), Color3.fromRGB(20, 0, 0)
    atm.Density, atm.Haze, atm.Offset = 0.45, 2.2, 0
    atm.Parent = Lighting

    -- ===== TREMOR DE CÂMERA + FLASH VERMELHO =====
    local shake = 0
    local shakeName = "SukunaShake" .. tostring(math.random(1, 1000000))
    RunService:BindToRenderStep(shakeName, Enum.RenderPriority.Camera.Value + 1, function()
        if shake > 0.01 then
            local cam = workspace.CurrentCamera
            if cam then
                local s = shake
                cam.CFrame = cam.CFrame
                    * CFrame.Angles((math.random() - 0.5) * 0.05 * s, (math.random() - 0.5) * 0.05 * s, (math.random() - 0.5) * 0.08 * s)
                    + Vector3.new((math.random() - 0.5) * 0.6 * s, (math.random() - 0.5) * 0.6 * s, 0)
            end
            shake *= 0.9
        end
    end)

    local flash, flashGui
    pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui", 3)
        flashGui = Instance.new("ScreenGui")
        flashGui.Name, flashGui.IgnoreGuiInset, flashGui.ResetOnSpawn, flashGui.DisplayOrder = "SukunaFlash", true, false, 50
        flashGui.Parent = pg
        flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        flash.BackgroundTransparency = 1
        flash.BorderSizePixel = 0
        flash.Parent = flashGui
    end)

    -- ===== CORTES VERMELHOS =====
    local function slash(pos, dir, len, thick)
        cleaveLine(folder, pos - dir * (len / 2), pos + dir * (len / 2), math.max(thick * 1.1, 0.5), 0.4)
    end

    local function bloodBurst(pos)
        local p = Instance.new("Part")
        p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
        p.Transparency = 1
        p.Size = Vector3.new(0.2, 0.2, 0.2)
        p.Position = pos
        p.Parent = folder
        local e = Instance.new("ParticleEmitter")
        e.Color = ColorSequence.new(Color3.fromRGB(170, 0, 0), Color3.fromRGB(90, 0, 0))
        e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
        e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
        e.Lifetime = NumberRange.new(0.3, 0.7)
        e.Speed = NumberRange.new(10, 30)
        e.SpreadAngle = Vector2.new(180, 180)
        e.Acceleration = Vector3.new(0, -40, 0)
        e.LightEmission = 0.3
        e.Rate = 0
        e.Parent = p
        e:Emit(14)
        Debris:AddItem(p, 1)
    end

    local function rndDir()
        local v = Vector3.new(math.random() - 0.5, (math.random() - 0.5) * 1.2, math.random() - 0.5)
        if v.Magnitude < 0.05 then v = Vector3.new(1, 0, 0) end
        return v.Unit
    end

    -- ===== SANTUÁRIO SOBE DO CHÃO =====
    local shrine = fetchAssetAsModel(SUK_SHRINE)
    if shrine then
        shrine.Parent = folder
        pcall(function() shrine:ScaleTo(7) end)
        for _, p in ipairs(shrine:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored, p.CanCollide = true, false end
        end
        -- santuário reto, 55 studs à frente de quem lançou, virado pra ele
        local lk = Vector3.new(sh.CFrame.LookVector.X, 0, sh.CFrame.LookVector.Z)
        lk = lk.Magnitude > 0.1 and lk.Unit or Vector3.new(0, 0, -1)
        local tpos = sh.Position + lk * 55
        local bcf, bs = shrine:GetBoundingBox()
        local bo = shrine:GetPivot().Position.Y - (bcf.Position.Y - (bs.Y / 2))
        local tcf = CFrame.new(tpos.X, gy + bo + SHRINE_Y, tpos.Z)
            * CFrame.lookAt(Vector3.zero, -lk).Rotation * CFrame.Angles(0, math.rad(SHRINE_YAW), 0)
        local scf = tcf * CFrame.new(0, -35, 0)
        shrine:PivotTo(scf)
        for i = 1, 50 do
            local a = i / 50
            shrine:PivotTo(scf:Lerp(tcf, a * a * (3 - 2 * a)))
            shake = math.max(shake, 0.35)
            task.wait(0.015)
        end
        shrine:PivotTo(tcf)
    end

    -- ===== LOOP DOS CORTES =====
    local st, n = tick(), 0
    while tick() - st < DURATION and folder.Parent and not SUKUNA_ABORT do
        n += 1
        local center = sh.Position

        -- cortes soltos no ar
        for _ = 1, 3 do
            local off = Vector3.new(math.random(-35, 35), math.random(-5, 22), math.random(-35, 35))
            slash(center + off, rndDir(), math.random(22, 46), math.random(8, 16) / 10)
        end

        -- cortes atravessando o corpo de quem está no alcance
        if n % 2 == 0 then
            for _, plr in ipairs(Players:GetPlayers()) do
                local c = plr.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                if h and (h.Position - sh.Position).Magnitude <= RANGE then
                    local p = h.Position + Vector3.new((math.random() - 0.5) * 1.6, (math.random() - 0.5) * 3, (math.random() - 0.5) * 1.6)
                    slash(p, rndDir(), 16, 1.1)
                    bloodBurst(p)
                    if plr == LocalPlayer then
                        shake = math.min(shake + 0.55, 1.6)
                        if flash then
                            flash.BackgroundTransparency = 0.55
                            TweenService:Create(flash, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
                        end
                    end
                end
            end
        end

        -- dano (o próprio autor não se machuca)
        if not iAmCaster then
            local mc = LocalPlayer.Character
            local mh = mc and mc:FindFirstChild("HumanoidRootPart")
            local mhum = mc and mc:FindFirstChildOfClass("Humanoid")
            if mh and mhum and (mh.Position - sh.Position).Magnitude <= RANGE then
                mhum:TakeDamage(10)
            end
        end

        task.wait(0.05)
    end

    -- ===== LIMPEZA =====
    pcall(function() RunService:UnbindFromRenderStep(shakeName) end)
    pcall(function() folder:Destroy() end)
    pcall(function() if flashGui then flashGui:Destroy() end end)
    pcall(function() cc:Destroy() end)
    pcall(function() atm:Destroy() end)
    for k, v in pairs(saved) do pcall(function() Lighting[k] = v end) end
    for _, a in ipairs(hidden) do pcall(function() a.Parent = Lighting end) end
    SUKUNA_BUSY = false
end

-- ================== EXPANSÃO DE DOMÍNIO (GOJO) - VAZIO ILIMITADO v3 (estilo Jujutsu Shenanigans) ==================
-- Sequência (baseada no vídeo de referência):
--  1) pose do Gojo + esfera preta + brilho (bloom) branco
--  2) tela branca -> você e o alvo MAIS PRÓXIMO são teleportados pro domínio
--  3) riscos magenta/roxo/vermelho irradiando num cosmos roxo
--  4) transição pro cosmos azul-turquesa com fumaça, respingos brancos e o BURACO NEGRO distante
--  5) alvo paralisado (chão invisível) e morrendo devagar em 5s -> domínio colapsa e todos voltam
GOJO = { busy = false, cancelFlag = false, cdEnd = 0, token = 0 }

do
    local TweenService = game:GetService("TweenService")
    local Debris       = game:GetService("Debris")

    -- ======== CONFIGURAÇÃO ========
    local COOLDOWN    = 20     -- recarga (s) depois que a expansão termina
    local HOLD_TIME   = 9.5    -- tempo do domínio depois da abertura (alvo paralisado até o fim) -> duração total ~15s
    local MAX_DIST    = 600    -- distância máxima pra achar o alvo mais próximo
    local HOLE_STUDS  = 150    -- diâmetro do buraco negro (como na imagem de referência)
    local GOJO_SOUND  = "rbxassetid://6667923288"   -- música que toca quando a expansão ativa
    local COSMOS_SKY  = "108682468477856"          -- skybox do domínio (some quando a expansão termina)
    local LOW         = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local C_WHITE  = Color3.new(1, 1, 1)
    local C_CYAN   = Color3.fromRGB(150, 220, 255)
    local WHITE, BLACK, OLIVE = C_WHITE, Color3.new(0, 0, 0), Color3.fromRGB(128, 128, 0)
    local LIGHT_KEYS = { "Ambient", "OutdoorAmbient", "Brightness", "ClockTime", "FogColor", "FogStart", "FogEnd", "ExposureCompensation" }
    local SMOKE_TEX = "rbxasset://textures/particles/smoke_main.dds"

    local RAINBOW = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.15, Color3.fromRGB(255, 220, 150)),
        ColorSequenceKeypoint.new(0.30, Color3.fromRGB(190, 255, 170)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(140, 220, 255)),
        ColorSequenceKeypoint.new(0.60, Color3.fromRGB(170, 140, 255)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 160, 220)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255)),
    })

    local function tw(obj, t, props, style, dir)
        local tween = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
        tween:Play()
        return tween
    end

    local function mkp(parent, size, cf, color, mat, transp, shape)
        local p = Instance.new("Part")
        p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
        if shape then p.Shape = shape end
        p.Size, p.CFrame, p.Color = size, cf, color
        p.Material = mat or Enum.Material.SmoothPlastic
        p.Transparency = transp or 0
        p.Parent = parent
        return p
    end

    -- ======== BURACO NEGRO (BillboardGui - o seu código, sempre encara a câmera) ========
    local function circle(parent, scale, color, z, transp)
        local f = Instance.new("Frame")
        f.AnchorPoint = Vector2.new(.5, .5)
        f.Position = UDim2.fromScale(.5, .5)
        f.Size = UDim2.fromScale(scale, scale)
        f.BackgroundColor3 = color
        f.BackgroundTransparency = transp or 0
        f.BorderSizePixel = 0
        f.ZIndex = z
        Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
        f.Parent = parent
        return f
    end
    local function ring(parent, scale, thickness, color, z, transp)
        local f = circle(parent, scale, color, z, 1)
        local s = Instance.new("UIStroke", f)
        s.Color = color; s.Thickness = thickness; s.Transparency = transp or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return f, s
    end

    local function buildBlackHoleBillboard(adornee, studs)
        local bb = Instance.new("BillboardGui")
        bb.Name = "VoidEye"
        bb.Adornee = adornee
        bb.Size = UDim2.fromScale(studs, studs)   -- tamanho em studs
        bb.LightInfluence = 0
        bb.AlwaysOnTop = false
        bb.MaxDistance = 100000
        bb.ResetOnSpawn = false
        bb.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local rootF = Instance.new("Frame", bb)
        rootF.Size = UDim2.fromScale(1, 1)
        rootF.BackgroundTransparency = 1
        rootF.Name = "Root"

        local L = {}
        L.glow = circle(rootF, 1.0, Color3.fromRGB(120, 160, 255), 1, .85)
        local gg = Instance.new("UIGradient", L.glow)
        gg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, .2), NumberSequenceKeypoint.new(.5, .7), NumberSequenceKeypoint.new(1, .2)
        })

        -- anel dourado fino (como no vídeo) + anéis bege/oliva (como na imagem)
        L.gold, L.goldStroke = ring(rootF, .95, 7, Color3.fromRGB(255, 225, 90), 2, .1)
        L.olive, L.oliveStroke = ring(rootF, .9, 18, OLIVE, 2, .15)
        local og = Instance.new("UIGradient", L.oliveStroke)
        og.Color = ColorSequence.new(Color3.fromRGB(230, 225, 190), Color3.fromRGB(150, 145, 100))
        L.oliveGrad = og
        L.olive2, L.olive2Stroke = ring(rootF, .82, 6, Color3.fromRGB(240, 236, 210), 2, .3)

        L.rainbow, L.rainbowStroke = ring(rootF, .74, 10, WHITE, 3, 0)
        L.rainbowGrad = Instance.new("UIGradient", L.rainbowStroke)
        L.rainbowGrad.Color = RAINBOW
        L.rainbowGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(.35, .1),
            NumberSequenceKeypoint.new(.6, .75), NumberSequenceKeypoint.new(.85, .2), NumberSequenceKeypoint.new(1, 0)
        })
        L.rainbowThin, L.rainbowThinStroke = ring(rootF, .7, 3, WHITE, 3, 0)
        L.rainbowThinGrad = Instance.new("UIGradient", L.rainbowThinStroke)
        L.rainbowThinGrad.Color = RAINBOW

        L.swirl = circle(rootF, .68, Color3.fromRGB(150, 160, 210), 4, 0)
        L.swirlGrad = Instance.new("UIGradient", L.swirl)
        L.swirlGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 235, 255)),
            ColorSequenceKeypoint.new(.25, Color3.fromRGB(90, 100, 150)),
            ColorSequenceKeypoint.new(.5, Color3.fromRGB(200, 210, 245)),
            ColorSequenceKeypoint.new(.75, Color3.fromRGB(70, 80, 130)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 235, 255)),
        })

        L.wisps = {}
        for i = 1, 6 do
            local w, ws = ring(rootF, .66 - i * .025, 4 + (i % 3) * 2, WHITE, 5, .35)
            local wg = Instance.new("UIGradient", ws)
            wg.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.2, .2),
                NumberSequenceKeypoint.new(.45, 1), NumberSequenceKeypoint.new(1, 1)
            })
            wg.Rotation = i * 60
            L.wisps[i] = { g = wg, speed = (40 + i * 18) * (i % 2 == 0 and -1 or 1) }
        end

        L.coreEdge = circle(rootF, .43, Color3.fromRGB(20, 22, 40), 6, .3)
        L.core = circle(rootF, .4, BLACK, 7, 0)

        L.splats = {}
        for i = 1, 26 do
            local ang = math.random() * math.pi * 2
            local d = .1 + math.random() * .32
            local s = .015 + math.random() * .05
            local sp = Instance.new("Frame", rootF)
            sp.AnchorPoint = Vector2.new(.5, .5)
            sp.Position = UDim2.fromScale(.5 + math.cos(ang) * d, .5 + math.sin(ang) * d)
            sp.Size = UDim2.fromScale(s * (1 + math.random() * 1.5), s)
            sp.Rotation = math.random(0, 360)
            sp.BackgroundColor3 = WHITE
            sp.BackgroundTransparency = 0
            sp.BorderSizePixel = 0
            sp.ZIndex = 8
            Instance.new("UICorner", sp).CornerRadius = UDim.new(1, 0)
            L.splats[i] = sp
        end

        -- mancha branca GRANDE no centro (aparece no impacto, como na imagem de referência)
        L.splash = {}
        local function blob(x, y, w, h, rot)
            local f = Instance.new("Frame")
            f.AnchorPoint = Vector2.new(.5, .5)
            f.Position = UDim2.fromScale(x, y)
            f.Size = UDim2.fromScale(0, 0)
            f.Rotation = rot or 0
            f.BackgroundColor3 = WHITE
            f.BorderSizePixel = 0
            f.ZIndex = 9
            Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
            f.Parent = rootF
            L.splash[#L.splash + 1] = { f = f, w = w, h = h }
        end
        for _ = 1, 26 do
            local a, d = math.random() * math.pi * 2, math.random() * .13
            local s = .05 + math.random() * .11
            blob(.5 + math.cos(a) * d, .5 + math.sin(a) * d, s * (1 + math.random()), s, math.random(0, 360))
        end
        for _ = 1, 34 do
            local a, d = math.random() * math.pi * 2, .12 + math.random() * .3
            local s = .01 + math.random() * .035
            blob(.5 + math.cos(a) * d, .5 + math.sin(a) * d, s * (1 + math.random() * 2), s, math.random(0, 360))
        end
        for _ = 1, 8 do
            local a, d = math.random() * math.pi * 2, .15 + math.random() * .25
            blob(.5 + math.cos(a) * d, .5 + math.sin(a) * d, .12 + math.random() * .1, .008, math.deg(a))
        end

        rootF.Size = UDim2.fromScale(0, 0)
        rootF.AnchorPoint = Vector2.new(.5, .5)
        rootF.Position = UDim2.fromScale(.5, .5)
        return bb, rootF, L
    end

    GOJO.buildHole = buildBlackHoleBillboard

    -- ======== CONTROLE ========
    function GOJO.cancel()
        if GOJO.busy then GOJO.cancelFlag = true end
    end

    function GOJO.cancelAll()
        GOJO.cancel()
        sendNetCmd(";GOJO_CANCEL ALL")
    end

    function GOJO.cooldownLeft()
        return math.max(GOJO.cdEnd - os.clock(), 0)
    end

    -- alvo mais próximo entre quem usa o hub (só eles podem ser teleportados)
    function GOJO.findNearest()
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil end
        local best, bestD = nil, MAX_DIST
        for name in pairs(activeScriptUsers) do
            if name ~= LocalPlayer.Name then
                local plr = Players:FindFirstChild(name)
                local c = plr and plr.Character
                local h = c and c:FindFirstChild("HumanoidRootPart")
                local hm = c and c:FindFirstChildOfClass("Humanoid")
                if h and hm and hm.Health > 0 then
                    local d = (h.Position - myHrp.Position).Magnitude
                    if d < bestD then best, bestD = name, d end
                end
            end
        end
        return best
    end

    -- target = "NEAREST" (alvo mais próximo) ou o nome de um jogador
    function GOJO.cast(target)
        if not target or target == "" then return false end
        if GOJO.busy then notify("Gojo", "A expansão já está ativa.") return false end
        local left = GOJO.cooldownLeft()
        if left > 0 then notify("Gojo", "Em recarga: " .. math.ceil(left) .. "s") return false end

        local name = target
        if string.upper(target) == "NEAREST" then
            name = GOJO.findNearest()
            if not name then
                notify("Gojo", "Nenhum jogador com o hub por perto.")
                return false
            end
        end
        task.spawn(function() pcall(GOJO.run, LocalPlayer.Name, name) end)
        sendNetCmd(";GOJO_DOMAIN " .. name)
        return true
    end

    -- ======== A EXPANSÃO ========
    function GOJO.run(senderName, targetName)
        local sp = Players:FindFirstChild(senderName)
        local sc = sp and sp.Character
        local sh = sc and sc:FindFirstChild("HumanoidRootPart")
        local sHum = sc and sc:FindFirstChildOfClass("Humanoid")
        if GOJO.busy or not sh or not sHum or sHum.Health <= 0 then return end
        -- Choque de Domínios: se Sukuna está ativo, batalha!
        if SUKUNA_BUSY and not DOMAIN_BATTLE.active then
            startDomainBattle(senderName, SUKUNA_CASTER, string.lower(tostring(targetName or "")))
            return
        end
        if DOMAIN_BATTLE.active then return end
        GOJO.busy = true
        GOJO.cancelFlag = false
        GOJO.token += 1
        local token = GOJO.token

        local tname = string.lower(tostring(targetName or ""))
        GOJO.casterName = senderName
        GOJO.currentTarget = tname
        local iAmCaster = (senderName == LocalPlayer.Name)
        local nameIsMe = (string.lower(LocalPlayer.Name) == tname or string.lower(LocalPlayer.DisplayName) == tname)
        local selfCast = iAmCaster and nameIsMe          -- você escolheu o seu próprio nome: só pra ver o domínio (não paralisa nem mata você)
        local iAmTarget = nameIsMe and not iAmCaster     -- você é a vítima de outro jogador
        local participant = iAmCaster or iAmTarget

        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if participant and (not myHrp or not myHum or myHum.Health <= 0) then
            GOJO.busy = false
            return
        end
        local casterPos = sh.Position
        local near = participant or (myHrp ~= nil and (myHrp.Position - casterPos).Magnitude <= 300)

        local function alive()
            return GOJO.token == token and not GOJO.cancelFlag
                and sc.Parent ~= nil and sh.Parent ~= nil and sHum.Health > 0
        end

        -- layout do domínio (longe do mapa, no céu)
        local C = Vector3.new(((tonumber(sp.UserId) or 0) % 40) * 800, 6000, 0)
        local casterSpot = CFrame.lookAt(C + Vector3.new(-6, 4, -12), C + Vector3.new(-6, 4, 80))
        local targetSpot = CFrame.lookAt(C + Vector3.new(7, 4, 8), C + Vector3.new(7, 4, 90))
        local holeC = C + Vector3.new(0, 18, 118)

        local oldWS = myHum and myHum.WalkSpeed or 16
        local oldJP = myHum and myHum.JumpPower or 50
        local oldCasterWS = sHum.WalkSpeed

        local folder = Instance.new("Folder")
        folder.Name = "GojoDomain"
        folder.Parent = workspace

        local cam = workspace.CurrentCamera
        local oldFov = cam and cam.FieldOfView or 70
        local renderName = "GojoRender" .. tostring(math.random(1, 1000000))
        local saved, hiddenAtm, hiddenSky = {}, {}, {}
        local cc, bloom, gui, flash, domainSky, bb, domainSnd
        local running, paralyzed, teleported = true, false, false
        local frozen = {}
        local casterTrack
        local returnCF
        local aimFrames = 0
        local oldLook = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
        local T0 = os.clock()

        local function waitUntil(t)
            while alive() and os.clock() - T0 < t do task.wait() end
            return alive()
        end

        local ok, err = pcall(function()
            -- ===== 1) ESFERA PRETA no local original (todos que estão perto veem) =====
            if near then
                local sphere = mkp(folder, Vector3.new(1, 1, 1), CFrame.new(casterPos), BLACK, nil, 0, Enum.PartType.Ball)
                local shell = mkp(folder, Vector3.new(1, 1, 1), CFrame.new(casterPos), C_CYAN, Enum.Material.Neon, 0.85, Enum.PartType.Ball)
                tw(sphere, 0.8, { Size = Vector3.new(24, 24, 24) }, Enum.EasingStyle.Back)
                tw(shell, 0.8, { Size = Vector3.new(28, 28, 28) }, Enum.EasingStyle.Back)
                task.delay(1.15, function()
                    pcall(function()
                        tw(sphere, 0.35, { Size = Vector3.new(1, 1, 1) })
                        tw(shell, 0.35, { Size = Vector3.new(1, 1, 1), Transparency = 1 })
                    end)
                end)
                if casterTrack == nil then casterTrack = safePlayAnimation(sc, CUSTOM_ANIM_ID) end
            end
            if iAmCaster then sHum.WalkSpeed = 0 end

            if GOJO_SOUND ~= "" and near then
                domainSnd = Instance.new("Sound")
                domainSnd.SoundId, domainSnd.Volume = GOJO_SOUND, 4
                domainSnd.Looped = false
                -- quem vai pro domínio ouve sem perder volume pela distância; os outros ouvem do Gojo
                domainSnd.Parent = participant and game:GetService("SoundService") or sh
                domainSnd:Play()
                Debris:AddItem(domainSnd, 60)
            end

            -- ===== preparação de quem vai pro domínio (você e o alvo) =====
            local lineData, smokes, splashE, stars = {}, {}, {}, nil
            local inkGroup
            local holeOpened, linesOn, ringT0 = false, false, 0
            local L

            local function setLook(kind, t)
                local p
                if kind == "A" then
                    p = { Ambient = Color3.fromRGB(70, 25, 100), OutdoorAmbient = Color3.fromRGB(50, 20, 85), Brightness = 0.3,
                          ClockTime = 0, FogColor = Color3.fromRGB(22, 6, 40), FogStart = 120, FogEnd = 1000, ExposureCompensation = 0 }
                else
                    p = { Ambient = Color3.fromRGB(25, 55, 85), OutdoorAmbient = Color3.fromRGB(18, 40, 70), Brightness = 0.3,
                          ClockTime = 0, FogColor = Color3.fromRGB(3, 12, 22), FogStart = 250, FogEnd = 1800, ExposureCompensation = 0 }
                end
                pcall(function()
                    if t <= 0 then
                        for k, v in pairs(p) do Lighting[k] = v end
                    else
                        tw(Lighting, t, p)
                    end
                end)
            end

            if participant then
                for _, k in ipairs(LIGHT_KEYS) do pcall(function() saved[k] = Lighting[k] end) end
                pcall(function()
                    for _, c in ipairs(Lighting:GetChildren()) do
                        if c:IsA("Atmosphere") then table.insert(hiddenAtm, c) c.Parent = nil
                        elseif c:IsA("Sky") then table.insert(hiddenSky, c) c.Parent = nil end
                    end
                end)

                local pg = LocalPlayer:WaitForChild("PlayerGui", 3)
                gui = Instance.new("ScreenGui")
                gui.Name, gui.IgnoreGuiInset, gui.ResetOnSpawn, gui.DisplayOrder = "GojoDomainGui", true, false, 60
                gui.Parent = pg
                flash = Instance.new("Frame")
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3, flash.BorderSizePixel = C_WHITE, 0
                flash.BackgroundTransparency = 1
                flash.ZIndex = 100
                flash.Parent = gui

                cc = Instance.new("ColorCorrectionEffect")
                cc.Parent = Lighting
                bloom = Instance.new("BloomEffect")
                bloom.Intensity, bloom.Size, bloom.Threshold = 0, 40, 0.8
                bloom.Parent = Lighting
                tw(bloom, 1.0, { Intensity = 2.2, Size = 60 })   -- brilho branco da abertura
                if cam then tw(cam, 1.0, { FieldOfView = oldFov - 12 }) end

                -- --- céu/cosmos ---
                domainSky = Instance.new("Sky")
                domainSky.Name = "GojoCosmos"
                local face = ""
                if COSMOS_SKY ~= "" then face = resolveImage(COSMOS_SKY) end
                domainSky.SkyboxBk, domainSky.SkyboxDn, domainSky.SkyboxFt = face, face, face
                domainSky.SkyboxLf, domainSky.SkyboxRt, domainSky.SkyboxUp = face, face, face
                domainSky.StarCount = 4000
                domainSky.CelestialBodiesShown = false
                domainSky.Parent = Lighting

                -- --- chão INVISÍVEL (mas sólido) e barreiras invisíveis ---
                local function solid(size, off)
                    local b = mkp(folder, size, CFrame.new(C + off), C_WHITE, nil, 1)
                    b.CanCollide = true
                end
                solid(Vector3.new(170, 4, 170), Vector3.new(0, -2, 0))
                solid(Vector3.new(4, 260, 170), Vector3.new(-85, 110, 0))
                solid(Vector3.new(4, 260, 170), Vector3.new(85, 110, 0))
                solid(Vector3.new(170, 260, 4), Vector3.new(0, 110, -85))
                solid(Vector3.new(170, 260, 4), Vector3.new(0, 110, 85))
                solid(Vector3.new(170, 4, 170), Vector3.new(0, 240, 0))

                -- --- estrelas ---
                local starPart = mkp(folder, Vector3.new(460, 460, 460), CFrame.new(C + Vector3.new(0, 100, 0)), C_WHITE, nil, 1)
                stars = Instance.new("ParticleEmitter")
                pcall(function()
                    stars.Shape = Enum.ParticleEmitterShape.Box
                    stars.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
                    stars.ShapeInOut = Enum.ParticleEmitterShapeInOut.InAndOut
                end)
                stars.Rate = LOW and 20 or 45
                stars.Lifetime = NumberRange.new(6, 10)
                stars.Speed = NumberRange.new(0, 2)
                stars.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 5),
                    NumberSequenceKeypoint.new(0.8, 5), NumberSequenceKeypoint.new(1, 0) })
                stars.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, C_WHITE), ColorSequenceKeypoint.new(0.6, C_CYAN),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 150, 255)) })
                stars.LightEmission, stars.LightInfluence = 1, 0
                stars.Parent = starPart
                stars:Emit(LOW and 80 or 200)

                -- --- riscos magenta/roxo/vermelho (fase da ativação) ---
                local cols = { Color3.fromRGB(255, 40, 220), Color3.fromRGB(180, 50, 255), Color3.fromRGB(255, 45, 90), Color3.fromRGB(255, 170, 255) }
                for i = 1, (LOW and 36 or 70) do
                    local side = (i % 2 == 0) and 1 or -1
                    local V = C + Vector3.new(0, 20, 320 * side)
                    local d = Vector3.new((math.random() - 0.5) * 1.8, (math.random() - 0.5) * 1.2, -side * (0.5 + math.random() * 0.8)).Unit
                    local len = 60 + math.random() * 160
                    local p = mkp(folder, Vector3.new(0.5, 0.5, len), CFrame.new(V), cols[math.random(#cols)], Enum.Material.Neon, 1)
                    lineData[i] = { part = p, V = V, d = d, r = 60 + math.random() * 500, sp = 260 + math.random() * 420 }
                end

                -- --- fumaça azul-turquesa do cosmos (fase final) ---
                local teal = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 140, 170)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 80, 115)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 30, 55)) })
                local nSmoke = LOW and 7 or 12
                for i = 1, nSmoke do
                    local a = (i / nSmoke) * math.pi * 2
                    local rad = 200 + math.random() * 120
                    local pos = C + Vector3.new(math.cos(a) * rad, 20 + math.random() * 120, math.sin(a) * rad)
                    local sPart = mkp(folder, Vector3.new(4, 4, 4), CFrame.new(pos), C_WHITE, nil, 1)
                    local e = Instance.new("ParticleEmitter")
                    e.Texture = SMOKE_TEX
                    e.Rate = LOW and 1.2 or 2.5
                    e.Lifetime = NumberRange.new(14, 20)
                    e.Speed = NumberRange.new(2, 6)
                    e.SpreadAngle = Vector2.new(180, 180)
                    e.Rotation = NumberRange.new(0, 360)
                    e.RotSpeed = NumberRange.new(-6, 6)
                    e.Drag = 0.5
                    e.LightEmission, e.LightInfluence = 0.35, 0
                    e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 160), NumberSequenceKeypoint.new(1, 320) })
                    e.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.25, 0.55),
                        NumberSequenceKeypoint.new(0.75, 0.7), NumberSequenceKeypoint.new(1, 1) })
                    e.Color = teal
                    e.Enabled = false
                    e.Parent = sPart
                    smokes[#smokes + 1] = e
                end

                -- --- respingos brancos (lado direito, como no vídeo) ---
                for _, off in ipairs({ Vector3.new(130, 30, 110), Vector3.new(105, -10, 135), Vector3.new(150, 60, 140) }) do
                    local sPart = mkp(folder, Vector3.new(4, 4, 4), CFrame.new(C + off), C_WHITE, nil, 1)
                    local e = Instance.new("ParticleEmitter")
                    e.Texture = SMOKE_TEX
                    e.Rate = LOW and 3 or 6
                    e.Lifetime = NumberRange.new(4, 7)
                    e.Speed = NumberRange.new(4, 14)
                    e.SpreadAngle = Vector2.new(180, 180)
                    e.Rotation = NumberRange.new(0, 360)
                    e.RotSpeed = NumberRange.new(-40, 40)
                    e.Drag = 1.2
                    e.LightEmission, e.LightInfluence = 0.8, 0
                    e.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 14), NumberSequenceKeypoint.new(0.5, 32), NumberSequenceKeypoint.new(1, 44) })
                    e.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.15, 0.1),
                        NumberSequenceKeypoint.new(0.7, 0.45), NumberSequenceKeypoint.new(1, 1) })
                    e.Color = ColorSequence.new(C_WHITE, Color3.fromRGB(200, 225, 245))
                    e.Enabled = false
                    e.Parent = sPart
                    splashE[#splashE + 1] = e
                end

                -- --- tinta branca pintada ao fundo do domínio (manchas brancas como na referência) ---
                do
                    local backWall = mkp(folder, Vector3.new(900, 450, 1), CFrame.new(C + Vector3.new(0, 90, 360)), C_WHITE, nil, 1)
                    local sgui = Instance.new("SurfaceGui")
                    sgui.Face = Enum.NormalId.Front
                    sgui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
                    sgui.CanvasSize = Vector2.new(1800, 900)
                    sgui.LightInfluence = 0
                    sgui.AlwaysOnTop = false
                    sgui.Parent = backWall
                    inkGroup = Instance.new("CanvasGroup")
                    inkGroup.Size = UDim2.fromScale(1, 1)
                    inkGroup.BackgroundTransparency = 1
                    inkGroup.GroupTransparency = 1
                    inkGroup.Parent = sgui
                    local function blob(cx, cy, px, col, tr)
                        local f = Instance.new("Frame")
                        f.AnchorPoint = Vector2.new(0.5, 0.5)
                        f.Position = UDim2.fromScale(cx, cy)
                        f.Size = UDim2.fromOffset(px, px * (0.7 + math.random() * 0.6))
                        f.Rotation = math.random(0, 360)
                        f.BackgroundColor3 = col
                        f.BackgroundTransparency = tr
                        f.BorderSizePixel = 0
                        Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
                        f.Parent = inkGroup
                    end
                    for _ = 1, (LOW and 7 or 12) do
                        local cx, cy = 0.06 + math.random() * 0.88, 0.1 + math.random() * 0.8
                        for _ = 1, 9 do
                            local a, d = math.random() * math.pi * 2, math.random() * 0.07
                            local bx, by = cx + math.cos(a) * d * 0.5, cy + math.sin(a) * d
                            local px = 40 + math.random() * 150
                            blob(bx, by, px * 1.5, Color3.fromRGB(190, 225, 255), 0.6)   -- brilho azulado em volta
                            blob(bx, by, px, C_WHITE, 0.03)                                -- mancha branca
                        end
                    end
                end

                -- --- loop visual único ---
                local rt0 = os.clock()
                RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function(dt)
                    local t = os.clock() - rt0
                    if aimFrames > 0 and cam and myHrp and myHrp.Parent then
                        -- vira a câmera pro buraco negro (sem isso o alvo olhava pro lado errado e via só preto)
                        aimFrames -= 1
                        local p = myHrp.Position
                        cam.CFrame = CFrame.lookAt(p + Vector3.new(0, 4, -13), p + Vector3.new(0, 6, 40))
                    end
                    if linesOn then
                        for _, ln in ipairs(lineData) do
                            ln.r += ln.sp * dt
                            if ln.r > 650 then ln.r = 40 end
                            local pos = ln.V + ln.d * ln.r
                            ln.part.CFrame = CFrame.lookAt(pos, pos + ln.d)
                        end
                    end
                    if L then
                        L.rainbowGrad.Rotation = (L.rainbowGrad.Rotation + 22 * dt) % 360
                        L.swirlGrad.Rotation = (L.swirlGrad.Rotation - 12 * dt) % 360
                        for _, w in ipairs(L.wisps) do
                            w.g.Rotation = (w.g.Rotation + w.speed * dt) % 360
                        end
                    end
                    if iAmTarget and paralyzed and cam then
                        cam.FieldOfView = oldFov + math.sin(t * 7) * 3
                        cam.CFrame = cam.CFrame * CFrame.Angles(
                            (math.random() - 0.5) * 0.008, (math.random() - 0.5) * 0.008, (math.random() - 0.5) * 0.012)
                    end
                end)
            end

            -- ===== 2) BRILHO BRANCO -> TELA BRANCA -> TELEPORTE =====
            if not waitUntil(0.9) then return end
            if flash then tw(flash, 0.25, { BackgroundTransparency = 0 }) end

            if not waitUntil(1.15) then return end
            if participant then
                returnCF = myHrp.CFrame
                myHrp.AssemblyLinearVelocity = Vector3.zero
                myHrp.CFrame = iAmCaster and casterSpot or targetSpot
                teleported = true
                aimFrames = 12
                if iAmTarget then
                    myHrp.Anchored = true
                    myHum.WalkSpeed, myHum.JumpPower = 0, 0
                    pcall(function() myHum.JumpHeight = 0 end)
                    pcall(function()
                        local an = myHum:FindFirstChildOfClass("Animator") or myHum
                        for _, tr in ipairs(an:GetPlayingAnimationTracks()) do
                            tr:AdjustSpeed(0)
                            table.insert(frozen, tr)
                        end
                    end)
                    paralyzed = true
                end
                setLook("A", 0)
                tw(cc, 0.6, { TintColor = Color3.fromRGB(255, 190, 255), Saturation = 0.25, Contrast = 0.2 })
                tw(bloom, 0.6, { Intensity = 0.9, Size = 30 })
                linesOn = true
                for _, ln in ipairs(lineData) do tw(ln.part, 0.5, { Transparency = 0.1 }) end
                tw(flash, 1.1, { BackgroundTransparency = 1 })   -- a tela branca se dissolve nos riscos
                if cam then tw(cam, 1.1, { FieldOfView = oldFov }) end
            end

            -- ===== 3) RISCOS MAGENTA (pose do Gojo) até 4.0s =====
            if not waitUntil(4.0) then return end
            if casterTrack then pcall(function() casterTrack:Stop(0.5) end) end
            if iAmCaster then pcall(function() sHum.WalkSpeed = oldCasterWS end) end

            -- ===== 4) TRANSIÇÃO: névoa turquesa + buraco negro abrindo =====
            if participant then
                for _, ln in ipairs(lineData) do tw(ln.part, 0.9, { Transparency = 1 }) end
                task.delay(1.0, function() linesOn = false end)
                setLook("B", 1.2)
                tw(cc, 1.2, { TintColor = Color3.fromRGB(190, 225, 255), Saturation = 0.1, Contrast = 0.25 })
                for _, e in ipairs(smokes) do e.Enabled = true e:Emit(6) end
                for _, e in ipairs(splashE) do e.Enabled = true e:Emit(4) end

                local holeAnchor = mkp(folder, Vector3.new(1, 1, 1), CFrame.new(holeC), C_WHITE, nil, 1)
                local rootF
                bb, rootF, L = buildBlackHoleBillboard(holeAnchor, HOLE_STUDS)
                tw(rootF, 0.9, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Back)   -- abertura com impacto
                if inkGroup then tw(inkGroup, 1.4, { GroupTransparency = 0 }) end
                if cam then
                    tw(cam, 0.3, { FieldOfView = oldFov - 8 })
                    task.delay(0.35, function()
                        if running and cam then tw(cam, 1.2, { FieldOfView = oldFov }, Enum.EasingStyle.Quint) end
                    end)
                end
            end

            -- ===== 5) ALVO PARALISADO, MORRENDO EM HOLD_TIME SEGUNDOS =====
            if not waitUntil(5.2) then return end
            if participant and L then
                task.delay(0.4, function()
                    if not running then return end
                    for _, s in ipairs(L.splash) do
                        task.delay(math.random() * 0.25, function()
                            if running and s.f.Parent then
                                tw(s.f, 0.35, { Size = UDim2.fromScale(s.w, s.h) }, Enum.EasingStyle.Back)
                            end
                        end)
                    end
                end)
            end
            local h0 = (iAmTarget and myHum) and myHum.Health or 0
            local st = os.clock()
            while alive() and os.clock() - st < HOLD_TIME do
                if iAmTarget and myHum and myHum.Parent and myHum.Health > 0 then
                    local a = (os.clock() - st) / HOLD_TIME
                    myHum.Health = math.min(myHum.Health, h0 * (1 - a))
                end
                task.wait()
            end
            if alive() and iAmTarget and myHum and myHum.Parent then
                if myHrp then myHrp.Anchored = false end
                paralyzed = false
                myHum.Health = 0
            end
        end)
        if not ok then warn("[Gojo] " .. tostring(err)) end

        -- ===== 6) FINAL: clarão, todo mundo volta pro lugar, tudo é limpo =====
        running = false
        pcall(function() RunService:UnbindFromRenderStep(renderName) end)
        pcall(function()
            if flash then
                flash.BackgroundColor3, flash.BackgroundTransparency = C_WHITE, 0.15
            end
            task.wait(0.2)
            if participant and teleported and returnCF and myHrp and myHrp.Parent and myHum and myHum.Health > 0 then
                myHrp.AssemblyLinearVelocity = Vector3.zero
                myHrp.CFrame = returnCF
                if cam then
                    for _ = 1, 6 do
                        local p = myHrp.Position
                        cam.CFrame = CFrame.lookAt(p - oldLook * 12 + Vector3.new(0, 3, 0), p + oldLook * 40)
                        RunService.RenderStepped:Wait()
                    end
                end
            end
        end)
        pcall(function()
            if iAmTarget then
                if myHrp and myHrp.Parent and paralyzed then myHrp.Anchored = false end
                if myHum and myHum.Parent then myHum.WalkSpeed, myHum.JumpPower = oldWS, oldJP end
                for _, tr in ipairs(frozen) do pcall(function() tr:AdjustSpeed(1) end) end
                paralyzed = false
            end
            if iAmCaster then sHum.WalkSpeed = oldCasterWS end
            if casterTrack then casterTrack:Stop(0.3) end
        end)
        pcall(function() if cam then cam.FieldOfView = oldFov end end)
        pcall(function() folder:Destroy() end)
        pcall(function() if bb then bb:Destroy() end end)
        pcall(function() if domainSky then domainSky:Destroy() end end)
        pcall(function()
            if domainSnd then
                tw(domainSnd, 0.8, { Volume = 0 })
                Debris:AddItem(domainSnd, 1)
            end
        end)
        pcall(function() if cc then cc:Destroy() end end)
        pcall(function() if bloom then bloom:Destroy() end end)
        for k, v in pairs(saved) do pcall(function() Lighting[k] = v end) end
        for _, a in ipairs(hiddenAtm) do pcall(function() a.Parent = Lighting end) end
        for _, a in ipairs(hiddenSky) do pcall(function() a.Parent = Lighting end) end
        if flash then pcall(function() tw(flash, 0.9, { BackgroundTransparency = 1 }) end) end
        task.delay(1.0, function() pcall(function() if gui then gui:Destroy() end end) end)
        if iAmCaster then GOJO.cdEnd = os.clock() + COOLDOWN end
        GOJO.busy = false
    end
end

-- ================== COMANDOS ADM EXTRAS (FLOAT / LOOPKILL / REJOIN) ==================
HUBCFG = { kickReason = "", floatBP = nil, floatToken = 0, loopToken = 0 }

function HUBCFG.setFloat(on)
    HUBCFG.floatToken += 1
    local token = HUBCFG.floatToken
    if HUBCFG.floatBP then
        pcall(function() HUBCFG.floatBP:Destroy() end)
        HUBCFG.floatBP = nil
    end
    local chr = LocalPlayer.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not on or not hrp then return end
    local baseY = hrp.Position.Y + 12
    local bp = Instance.new("BodyPosition")
    bp.Name = "F1L_Float"
    bp.MaxForce = Vector3.new(0, 1e9, 0)   -- só controla a altura; você ainda anda
    bp.P, bp.D = 12000, 1200
    bp.Position = Vector3.new(0, baseY, 0)
    bp.Parent = hrp
    HUBCFG.floatBP = bp
    task.spawn(function()
        local t0 = os.clock()
        while HUBCFG.floatToken == token and bp.Parent do
            bp.Position = Vector3.new(0, baseY + math.sin((os.clock() - t0) * 2) * 1.2, 0)
            task.wait(0.03)
        end
    end)
end

function HUBCFG.setLoopKill(on)
    HUBCFG.loopToken += 1
    local token = HUBCFG.loopToken
    if not on then return end
    task.spawn(function()
        while HUBCFG.loopToken == token do
            local chr = LocalPlayer.Character
            local hum = chr and chr:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hum.Health = 0 end
            task.wait(0.2)
        end
    end)
end

function HUBCFG.rejoin()
    local TeleportService = game:GetService("TeleportService")
    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    if not ok then pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end
end

-- ================== RECEPTOR ==================
function executeActionLocally(action, senderName, extraArg)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if action == "KILL" and hum then hum.Health = 0
    elseif action == "KICK" then
        -- kick SEM motivo (quem envia nunca se expulsa)
        if senderName ~= LocalPlayer.Name then LocalPlayer:Kick("Expulso pelo Fantasma1l Hub.") end
    elseif action == "KICKR" then
        -- kick COM motivo (o texto vem em extraArg)
        if senderName ~= LocalPlayer.Name then
            local why = (extraArg and extraArg ~= "") and extraArg or "Expulso pelo Fantasma1l Hub."
            LocalPlayer:Kick(why)
        end
    elseif action == "KILLPLUS" then
        -- kill forte: tira ForceField, arremessa pro alto e quebra o corpo
        if senderName ~= LocalPlayer.Name and char and hum then
            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("ForceField") then c:Destroy() end
            end
            if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, 250, 0) end
            pcall(function() char:BreakJoints() end)
            hum.Health = 0
        end
    elseif action == "FLING" then
        -- arremessa o alvo longe e mata (quem envia nunca é atingido)
        if senderName ~= LocalPlayer.Name and hrp and hum then
            task.spawn(function()
                pcall(function()
                    for _, c in ipairs(char:GetChildren()) do
                        if c:IsA("ForceField") then c:Destroy() end
                    end
                    hrp.Anchored = false
                    local dir = Vector3.new(math.random() - 0.5, 0.6, math.random() - 0.5).Unit
                    for _ = 1, 8 do
                        hrp.AssemblyLinearVelocity = dir * 5000
                        hrp.AssemblyAngularVelocity = Vector3.new(0, 9999, 0)
                        task.wait()
                    end
                    hum.Health = 0
                end)
            end)
        end
    elseif action == "FLOAT" then pcall(HUBCFG.setFloat, true)
    elseif action == "UNFLOAT" then pcall(HUBCFG.setFloat, false)
    elseif action == "LOOPKILL" then
        if senderName ~= LocalPlayer.Name then HUBCFG.setLoopKill(true) end
    elseif action == "UNLOOPKILL" then HUBCFG.setLoopKill(false)
    elseif action == "REJOIN" then
        if senderName ~= LocalPlayer.Name then task.spawn(HUBCFG.rejoin) end
    elseif action == "FREEZE" and hrp and hum then hrp.Anchored, hum.WalkSpeed, hum.JumpPower = true, 0, 0
    elseif action == "UNFREEZE" and hrp and hum then hrp.Anchored, hum.WalkSpeed, hum.JumpPower = false, 16, 50
    elseif action == "CRASH" then while true do end
    elseif BROADCAST_ACTIONS[action] then
        runBroadcast(action, senderName, extraArg or LocalPlayer.Name)
    elseif action == "TP_TO_POS" and hrp and senderName then
        local sp = Players:FindFirstChild(senderName)
        if sp and sp.Character and sp.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = sp.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        end
    elseif action == "TP_ME" and hrp and senderName then
        local sp = Players:FindFirstChild(senderName)
        if sp and sp.Character and sp.Character:FindFirstChild("HumanoidRootPart") then
            sp.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
        end
    elseif action == "VISIBLE" and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency = 0 p.LocalTransparencyModifier = 0 end
        end
    elseif action == "CHAT_AS" and extraArg then sendNetCmd(extraArg)
    elseif action == "COOLKID_EFFECT" then
        task.spawn(function() pcall(executeCoolkidEffect) end)
    elseif action == "BACKROOMS_SPAWN" then
        task.spawn(function() pcall(POOL.clear, true) pcall(function() spawnBackrooms(extraArg) end) end)
    elseif action == "POOLROOMS_SPAWN" then
        task.spawn(function() pcall(function() POOL.spawn(extraArg) end) end)
    elseif action == "POOLROOMS_CLEAR" then
        task.spawn(function() pcall(POOL.clear) end)
    elseif action == "BACKROOMS_CLEAR" then task.spawn(function() pcall(clearBackrooms) end)
    elseif action == "LIFEFORM_SPAWN" then
        task.spawn(function()
            local folder = workspace:FindFirstChild("Backrooms_Level0")
            if not folder then
                pcall(function() spawnBackrooms(extraArg) end)
                task.wait(3)
                folder = workspace:FindFirstChild("Backrooms_Level0")
            end
            if folder then
                local targetP = Players:FindFirstChild(extraArg or selectedPlayerName) or LocalPlayer
                local chr = targetP.Character
                local hrp2 = chr and chr:FindFirstChild("HumanoidRootPart")
                local pos = hrp2 and (hrp2.Position + Vector3.new(30, 0, 30)) or Vector3.new(30, 203, 30)
                pcall(function() spawnLifeform(pos, folder, targetP.Name) end)
            end
        end)
    elseif action == "LIFEFORM_CLEAR" then
        task.spawn(function() pcall(clearLifeform) end)
    elseif action == "BRAINROT_SPAWN" then
        task.spawn(function() pcall(roubeUmBrainrot, "ON") end)
    elseif action == "BRAINROT_CLEAR" then
        task.spawn(function() pcall(roubeUmBrainrot, "OFF") end)
    -- >>> PATCH v37 - PASSO 3a: TORNADO (antes do FLASH & AURA)
    elseif action == "TORNADO_SPAWN" then
        task.spawn(function() pcall(TORNADO.spawn, senderName) end)
    elseif action == "TORNADO_CLEAR" then
        task.spawn(function() pcall(TORNADO.clear) end)
    -- >>> FLASH & AURA (REDE) <<<
    elseif FXNET.actions[action] then
        FXNET.run(action, extraArg)
    elseif action == "KAMUI" then
        task.spawn(function()
            local pg = LocalPlayer:WaitForChild("PlayerGui")
            local sg = Instance.new("ScreenGui", pg)
            sg.Name, sg.IgnoreGuiInset, sg.ResetOnSpawn = "KamuiEffect", true, false
            local img = Instance.new("ImageLabel", sg)
            img.Size, img.AnchorPoint, img.Position = UDim2.new(0, 320, 0, 320), Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0)
            img.BackgroundTransparency, img.Image, img.ScaleType = 1, resolveImage(KAMUI_IMG), Enum.ScaleType.Fit
            local s = Instance.new("Sound", workspace)
            s.SoundId, s.Volume = KAMUI_SND, 6
            s:Play()
            local start = tick()
            local conn
            conn = RunService.RenderStepped:Connect(function()
                if tick() - start < 3.5 then img.Rotation = (tick() - start) * 350
                else conn:Disconnect() end
            end)
            task.wait(3.5)
            if sg then sg:Destroy() end
            if s then s:Destroy() end
            if not kamuiEnabled then toggleKamuiDimensionLocal(true)
            else
                local pf = workspace:FindFirstChild("KamuiDimensionBox") and workspace.KamuiDimensionBox:FindFirstChild("KamuiTargetPlatform")
                if hrp and pf then hrp.CFrame = pf.CFrame + Vector3.new(0, 6, 0) end
            end
        end)
    elseif action == "SUKUNA_DOMAIN" and senderName then
        task.spawn(function() pcall(runSukunaDomain, senderName) end)
    elseif action == "TACO_RAIN" then
        task.spawn(function()
            for _ = 1, 15 do
                local m = fetchAssetAsModel(TACO_ID)
                if m then
                    for _, p in ipairs(m:GetDescendants()) do
                        if p:IsA("BasePart") then p.Anchored, p.CanCollide = false, false end
                    end
                    pcall(function() m:ScaleTo(12) end)
                    m:PivotTo(CFrame.new(math.random(-200,200), 150, math.random(-200,200)))
                    m.Parent = workspace
                    makeModelFallSlowly(m)
                    task.delay(12, function() if m and m.Parent then m:Destroy() end end)
                end
                task.wait(0.4)
            end
        end)
    elseif action == "RENEGADO_RAIN" then
        task.spawn(function()
            local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync("renegado6661l") end)
            if ok and uid then
                local sok, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(uid) end)
                if sok and desc then
                    for _ = 1, 10 do
                        local cm = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
                        for _, p in ipairs(cm:GetDescendants()) do
                            if p:IsA("BasePart") then p.Anchored, p.CanCollide = false, true end
                        end
                        cm:PivotTo(CFrame.new(math.random(-200,200), 150, math.random(-200,200)))
                        cm.Parent = workspace
                        makeModelFallSlowly(cm)
                        task.delay(10, function() if cm and cm.Parent then cm:Destroy() end end)
                        task.wait(0.5)
                    end
                end
            end
        end)
    elseif action:find("JUMPSCARE_") then
        local data = JUMPS[action] or JUMPS["JUMPSCARE_1"]
        task.spawn(function()
            local pg = LocalPlayer:WaitForChild("PlayerGui")
            local old = pg:FindFirstChild("Screamer")
            if old then old:Destroy() end
            local ng = Instance.new("ScreenGui", pg)
            ng.Name, ng.IgnoreGuiInset, ng.ResetOnSpawn = "Screamer", true, false
            local im = Instance.new("ImageLabel", ng)
            im.Size, im.BackgroundTransparency = UDim2.new(1,0,1,0), 1
            im.Image, im.ScaleType = resolveImage(data.Img), Enum.ScaleType.Crop
            local s = Instance.new("Sound", ng)
            s.SoundId, s.Volume = data.Snd, 10
            s:Play()
            local st = tick()
            while tick() - st < 2.5 do
                if not im.Parent then break end
                im.Position = UDim2.new(0, math.random(-25,25), 0, math.random(-25,25))
                im.Rotation = math.random(-3,3)
                task.wait(0.04)
            end
            task.wait(0.3)
            ng:Destroy()
        end)
    end
end

-- ================== REDE (PREFIXO ;) ==================
local recentNet = {}
local function isMe(t)
    if not t then return false end
    local l = string.lower(t)
    return l == string.lower(LocalPlayer.Name) or l == string.lower(LocalPlayer.DisplayName)
end

function processNetMessage(msg, senderName)
    if not msg then return end
    do
        local now = os.clock()
        local key = tostring(senderName) .. ":" .. msg
        if recentNet[key] and now - recentNet[key] < 1.5 then return end
        recentNet[key] = now
        for k, t in pairs(recentNet) do
            if now - t > 5 then recentNet[k] = nil end
        end
    end
    local body
    if msg:sub(1, 1) == ";" then
        body = msg:sub(2)
    elseif string.lower(msg:sub(1, 5)) == "fhub " then
        body = msg:sub(6)
    else
        return
    end
    local parts = string.split(body, " ")
    if #parts < 1 or parts[1] == "" then return end

    local action = string.upper(parts[1])
    local target = parts[2]
    local extraArg = parts[3] and table.concat(parts, " ", 3) or nil

    if action == "PING" then
        if senderName and senderName ~= LocalPlayer.Name then
            activeScriptUsers[senderName] = true
            FantasmaTag.refreshByName(senderName)
        end
        FantasmaTag.announce()
    elseif action == "PONG" and target then
        -- só vale se quem mandou é mesmo o jogador citado (evita forjar)
        if senderName == target and target ~= LocalPlayer.Name then
            activeScriptUsers[target] = true
            local peer = FantasmaTag.peers[target] or {}
            FantasmaTag.peers[target] = peer
            for _, part in ipairs(parts) do
                local c = part:match("^COL_(%d+)$")
                if c then peer.color = tonumber(c) end
                local t = part:match("^TAG_(%d)$")
                if t then peer.off = (t == "0") end
            end
            FantasmaTag.refreshByName(target)
        end
    end

    -- comandos digitados por mim mesmo (admin)
    if senderName == LocalPlayer.Name and IS_ADMIN then
        if action == "VERIFICAR" or action == "VERIFY" then
            task.spawn(FantasmaTag.verify)
            return
        elseif action == "TAG" then
            local v = string.lower(target or "")
            FantasmaTag.setEnabled(not (v == "off" or v == "0" or v == "desligar"))
            return
        elseif action == "TAGCOR" then
            FantasmaTag.setColor(tonumber(target) or 1)
            return
        end
    end

    if action ~= "PING" and action ~= "PONG" then
        if REQUIRE_WHITELIST and senderName ~= LocalPlayer.Name and not WHITELIST[senderName] then return end
    end

    if FXNET.actions[action] then
        if target then
            task.spawn(function() pcall(executeActionLocally, action, senderName, target) end)
        end
        return
    end

    if BROADCAST_ACTIONS[action] then
        if target then
            task.spawn(function() pcall(runBroadcast, action, senderName, target) end)
        end
        return
    end

    -- >>> EXPANSÃO DE DOMÍNIO DO GOJO: todos com o script veem a cena <<<
    if action == "GOJO_CANCEL" then
        GOJO.cancel()
        return
    end

    if action == "GOJO_DOMAIN" then
        if target and senderName ~= LocalPlayer.Name then
            task.spawn(function() pcall(GOJO.run, senderName, target) end)
        end
        return
    end

    if action == "KAMUI" or action == "COOLKID_EFFECT" then
        if target == "ALL" or target == LocalPlayer.Name or senderName == LocalPlayer.Name or target == selectedPlayerName then
            task.spawn(function() pcall(function() executeActionLocally(action, senderName, target or extraArg) end) end)
        end
    else
        if target and (string.upper(target) == "ALL" or isMe(target)) then
            task.spawn(function() pcall(function() executeActionLocally(action, senderName, extraArg) end) end)
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(msg) processNetMessage(msg, p.Name) end)
end
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(msg) processNetMessage(msg, p.Name) end)
end)

task.spawn(function()
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local tc = TextChatService:WaitForChild("TextChannels", 3)
            if tc then
                local g = tc:WaitForChild("RBXGeneral", 3)
                if g then
                    g.MessageReceived:Connect(function(tcm)
                        if tcm.TextSource then
                            local s = Players:GetPlayerByUserId(tcm.TextSource.UserId)
                            if s then processNetMessage(tcm.Text, s.Name) end
                        end
                    end)
                end
            end
        end
    end)
    task.wait(1)
    FantasmaTag.announce(true)
    sendNetCmd(";PING ALL")
end)

-- ================== ADM HUB ==================
if IS_ADMIN then

local function toggleFlyWithWings()
    flyWingsActive = not flyWingsActive
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
    local head = char and char:FindFirstChild("Head")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not torso or not head then return end

    if flyWingsActive then
        local ok, w = pcall(function() return game:GetObjects("rbxassetid://" .. WINGS_ID) end)
        if ok and w and #w > 0 then
            wingsModel = w[1]
            if not wingsModel:IsA("Model") then
                local m = Instance.new("Model")
                for _, o in ipairs(w) do o.Parent = m end
                wingsModel = m
            end
            wingsModel.Parent = char
            for _, p in ipairs(wingsModel:GetDescendants()) do
                if p:IsA("BasePart") then p.Anchored, p.CanCollide = false, false end
            end
            local pr = wingsModel.PrimaryPart or wingsModel:FindFirstChildWhichIsA("BasePart", true)
            if pr then
                wingsModel.PrimaryPart = pr
                local wc = Instance.new("WeldConstraint")
                wc.Part0, wc.Part1, wc.Parent = torso, pr, pr
            end
        end
        local function loadHalo(id)
            local s, o = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
            if s and o and #o > 0 then
                local h = o[1]
                if not h:IsA("Model") then
                    local m = Instance.new("Model")
                    for _, x in ipairs(o) do x.Parent = m end
                    h = m
                end
                h.Parent = char
                for _, p in ipairs(h:GetDescendants()) do
                    if p:IsA("BasePart") then p.Anchored, p.CanCollide = false, false end
                end
                local pr = h.PrimaryPart or h:FindFirstChildWhichIsA("BasePart", true)
                if pr then
                    h.PrimaryPart = pr
                    local wc = Instance.new("WeldConstraint")
                    wc.Part0, wc.Part1, wc.Parent = head, pr, pr
                end
                return h
            end
        end
        halo1Model = loadHalo(HALO1_ID)
        halo2Model = loadHalo(HALO2_ID)
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name, bv.MaxForce, bv.Velocity = "FlyVelocity", Vector3.new(1e9,1e9,1e9), Vector3.zero
        local bg = Instance.new("BodyGyro", hrp)
        bg.Name, bg.MaxTorque, bg.CFrame = "FlyGyro", Vector3.new(1e9,1e9,1e9), hrp.CFrame
        if hum then hum.PlatformStand = true end
        local an = hum and hum:FindFirstChild("Animator")
        local ia = Instance.new("Animation") ia.AnimationId = FLY_IDLE
        local ma = Instance.new("Animation") ma.AnimationId = FLY_MOVE
        local it = an and an:LoadAnimation(ia)
        local mt = an and an:LoadAnimation(ma)
        if it then it:Play() end
        local lastM, cam = false, workspace.CurrentCamera
        local wt, ht = 0, 0
        flyConnections.RS = RunService.RenderStepped:Connect(function(dt)
            if not hrp or not hrp.Parent then return end
            local dir = Vector3.zero
            local ccf = cam.CFrame
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + ccf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - ccf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - ccf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + ccf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            if hum and hum.MoveDirection.Magnitude > 0 then dir = dir + hum.MoveDirection end
            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * 55
                if not lastM then
                    lastM = true
                    if it then it:Stop() end
                    if mt and not mt.IsPlaying then mt:Play() end
                end
            else
                bv.Velocity = Vector3.zero
                if lastM then
                    lastM = false
                    if mt then mt:Stop() end
                    if it and not it.IsPlaying then it:Play() end
                end
            end
            bg.CFrame = ccf
            wt = wt + dt * 5
            if wingsModel and wingsModel.PrimaryPart then
                wingsModel:SetPrimaryPartCFrame(torso.CFrame * CFrame.new(0,-0.2,0.6) * CFrame.Angles(0, math.pi, math.sin(wt)*0.15))
            end
            ht = ht + dt
            local r = tick() * 3.5
            if halo1Model and halo1Model.PrimaryPart then
                halo1Model:SetPrimaryPartCFrame(head.CFrame * CFrame.new(0,1.3,0) * CFrame.Angles(0, r, 0))
            end
            if halo2Model and halo2Model.PrimaryPart then
                halo2Model:SetPrimaryPartCFrame(head.CFrame * CFrame.new(0,1.3,0) * CFrame.Angles(0, -r, 0))
            end
            local t = math.floor(ht * 2) % 2 == 0 and 0 or 1
            if halo1Model then for _, p in ipairs(halo1Model:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = t end end end
            if halo2Model then for _, p in ipairs(halo2Model:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 - t end end end
        end)
    else
        for _, c in pairs(flyConnections) do c:Disconnect() end
        flyConnections = {}
        if wingsModel then wingsModel:Destroy() wingsModel = nil end
        if halo1Model then halo1Model:Destroy() halo1Model = nil end
        if halo2Model then halo2Model:Destroy() halo2Model = nil end
        if hrp then
            if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
            if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        end
        if hum then hum.PlatformStand = false end
    end
end

local function spawnSkyline(targetName)
    local tp = Players:FindFirstChild(targetName)
    if not tp or not tp.Character then notify("ADM", "Alvo inválido!") return end
    local th = tp.Character:FindFirstChild("HumanoidRootPart")
    if not th then return end
    task.spawn(function()
        notify("ADM", "Skyline → " .. targetName)
        local ok, objs = pcall(function() return game:GetObjects("rbxassetid://" .. SKYLINE_MODEL_ID) end)
        if not (ok and objs and #objs > 0) then return end
        local car = objs[1]
        if not car:IsA("Model") then
            local m = Instance.new("Model")
            for _, o in ipairs(objs) do o.Parent = m end
            car = m
        end
        if not car.PrimaryPart then car.PrimaryPart = car:FindFirstChildWhichIsA("BasePart", true) end
        car.Parent = workspace
        pcall(function() car:ScaleTo(0.35) end)
        for _, p in ipairs(car:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored, p.CanCollide = true, false end
        end
        local sp = th.Position + th.CFrame.LookVector * 45
        local rp = RaycastParams.new()
        rp.FilterType, rp.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, {car, tp.Character}
        local rr = workspace:Raycast(sp + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), rp)
        local gy = rr and rr.Position.Y or sp.Y
        local bcf, bs = car:GetBoundingBox()
        local bo = car:GetPivot().Position.Y - (bcf.Position.Y - bs.Y / 2)
        local tcf = CFrame.new(sp.X, gy + bo, sp.Z) * CFrame.lookAt(sp, th.Position).Rotation
        local scf = tcf * CFrame.new(0, -10, 0)
        car:PivotTo(scf)
        for i = 1, 35 do
            car:PivotTo(scf:Lerp(tcf, (i / 35) ^ 2 * (3 - 2 * (i / 35))))
            task.wait(0.015)
        end
        car:PivotTo(tcf)
        task.wait(0.15)
        local st, dur, hit = tick(), 10, false
        while tick() - st < dur and car and car.Parent do
            if tp and tp.Character then
                local cth = tp.Character:FindFirstChild("HumanoidRootPart")
                local ch = tp.Character:FindFirstChildOfClass("Humanoid")
                if cth then
                    local ccf = car:GetPivot()
                    local cr = workspace:Raycast(cth.Position + Vector3.new(0,20,0), Vector3.new(0,-40,0), rp)
                    local cgy = cr and cr.Position.Y or cth.Position.Y
                    local tpos = Vector3.new(cth.Position.X, cgy + bo, cth.Position.Z)
                    local d = tpos - ccf.Position
                    if d.Magnitude > 2 then car:PivotTo(CFrame.new(ccf.Position + d.Unit * 3.75, tpos)) end
                    if (ccf.Position - cth.Position).Magnitude <= 7 and not hit then
                        hit = true
                        if ch then ch.Health = 0 end
                        Instance.new("Explosion", workspace).Position = cth.Position
                    end
                end
            else break end
            task.wait(0.03)
        end
        task.wait(0.4)
        if car then car:Destroy() end
    end)
end

local function toggleAura()
    local char = LocalPlayer.Character
    if not char then return end
    if auraTrack then auraTrack:Stop() auraTrack = nil notify("Aura", "Off")
    else
        auraTrack = safePlayAnimation(char, AURA_ANIM_ID)
        if auraTrack then auraTrack.Looped = true notify("Aura", "On") end
    end
end

local function giveGojo()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then return end
    local t = Instance.new("Tool")
    t.Name, t.RequiresHandle = "Vazio Roxo", false
    t.Parent = LocalPlayer:FindFirstChild("Backpack") or char
    t.Activated:Connect(function()
        safePlayAnimation(char, CUSTOM_ANIM_ID)
        task.spawn(function()
            local p = fetchAssetAsModel("14819645681")
            if p and p.PrimaryPart then
                pcall(function() p:ScaleTo(300) end)
                for _, x in ipairs(p:GetDescendants()) do
                    if x:IsA("BasePart") then x.Anchored, x.CanCollide = true, false end
                end
                p:PivotTo(hrp.CFrame * CFrame.new(0, 2, -20))
                p.Parent = workspace
                local dir = hrp.CFrame.LookVector
                local cn
                cn = RunService.RenderStepped:Connect(function(dt)
                    if p and p.Parent then p:PivotTo(p:GetPivot() + dir * 150 * dt)
                    else cn:Disconnect() end
                end)
                task.delay(4, function() if cn then cn:Disconnect() end if p then p:Destroy() end end)
            end
        end)
    end)
    notify("Gojo", "Ativado!")
end

local function giveAK47()
    local char = LocalPlayer.Character
    if not char then return end
    task.spawn(function()
        local ok, objs = pcall(function() return game:GetObjects("rbxassetid://" .. AK47_MODEL_ID) end)
        if ok and objs and #objs > 0 then
            local t = objs[1]:IsA("Tool") and objs[1] or Instance.new("Tool", workspace)
            t.Name = "AK-47 Exclusiva"
            t.Parent = LocalPlayer:FindFirstChild("Backpack") or char
        end
    end)
end

local function giveYoru()
    task.spawn(function()
        local ok, objs = pcall(function() return game:GetObjects("rbxassetid://" .. YORU_MODEL_ID) end)
        if ok and objs and #objs > 0 then
            local t = objs[1]:IsA("Tool") and objs[1] or Instance.new("Tool", workspace)
            t.Name = "Yoru"
            t.Parent = LocalPlayer:WaitForChild("Backpack")
        end
    end)
end

-- ================== GONER PLAYER ==================
FantasmaGoner = {
    CLOTHES    = {17812417356, 17770317484, 17822722698, 17822749561, 17772174303, 17771175724},
    GONER_ANIM = "rbxassetid://71611618090433",
    CLICK_ANIM = "rbxassetid://118273721275238",   -- animação ao clicar com o machado
    CLICK_ID   = 118273721275238,
    ANIM_ID    = 97005849733115,                   -- animação do goner parado (idle)
    WALK_ID    = 108059497211872,                  -- animação do goner andando
    AXE_ID     = 14054756735,
    ICON       = "rbxassetid://130540399630094",
    SWING_ONLY = true,   -- true: só transforma se acertar durante o golpe (clique). false: qualquer encostada
    SWING_TIME = 1.0,
    TURN_DELAY = 3,      -- tempo da animação antes de virar goner
    hit = {},
}

FantasmaGoner.specs = setmetatable({}, { __mode = "k" })
FantasmaGoner.retired = setmetatable({}, { __mode = "k" })

function FantasmaGoner.getSpec(char)
    local sp = FantasmaGoner.specs[char]
    if not sp then
        sp = { items = {}, worn = {} }   -- items[id] = lista de instâncias que esse ID colocou
        FantasmaGoner.specs[char] = sp
    end
    return sp
end

-- ====== APRENDER COMO O BROOKHAVEN EQUIPA (captura o remote do próprio menu) ======
FantasmaGoner.armed = false          -- false | "wear" | "anim"
FantasmaGoner.templates = {}

function FantasmaGoner.findId(args)
    for i, v in ipairs(args) do
        if type(v) == "number" and v >= 1e6 and v % 1 == 0 then return { i }, v end
        if type(v) == "string" and #v >= 7 and v:match("^%d+$") then return { i }, v end
        if type(v) == "table" then
            for k, x in pairs(v) do
                if type(x) == "number" and x >= 1e6 and x % 1 == 0 then return { i, k }, x end
                if type(x) == "string" and #x >= 7 and x:match("^%d+$") then return { i, k }, x end
            end
        end
    end
end

FantasmaGoner.hookOK = pcall(function()
    local old
    old = hookmetamethod(game, "__namecall", (newcclosure or function(f) return f end)(function(self, ...)
        if FantasmaGoner.armed then
            local m = getnamecallmethod()
            if (m == "FireServer" or m == "InvokeServer") and not checkcaller() then
                local cn = typeof(self) == "Instance" and self.ClassName or ""
                if cn == "RemoteEvent" or cn == "RemoteFunction" then
                    local nm = string.lower(self.Name)
                    if not (nm:find("chat") or nm:find("say") or nm:find("message")) then
                        local args = { ... }
                        local path, val = FantasmaGoner.findId(args)
                        if path then
                            FantasmaGoner.templates[FantasmaGoner.armed] = { remote = self, method = m, args = args, path = path, vtype = type(val) }
                            FantasmaGoner.armed = false
                        end
                    end
                end
            end
        end
        return old(self, ...)
    end))
end)

-- dispara o remote aprendido trocando só o ID
function FantasmaGoner.fireTemplate(kind, id)
    local t = FantasmaGoner.templates[kind]
    if not t or not t.remote or not t.remote.Parent then return false end
    local args = {}
    for i, v in ipairs(t.args) do
        if type(v) == "table" then
            local c = {}
            for k, x in pairs(v) do c[k] = x end
            args[i] = c
        else
            args[i] = v
        end
    end
    local val = (t.vtype == "string") and tostring(id) or id
    if #t.path == 1 then args[t.path[1]] = val else args[t.path[1]][t.path[2]] = val end
    local n = table.maxn(args)
    pcall(function()
        if t.method == "FireServer" then t.remote:FireServer(table.unpack(args, 1, n))
        else task.spawn(function() pcall(function() t.remote:InvokeServer(table.unpack(args, 1, n)) end) end) end
    end)
    return true
end

-- carrega um asset (GetObjects, com fallback InsertService)
function FantasmaGoner.load(id)
    for attempt = 1, 3 do
        local ok, objs = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
        if ok and objs and #objs > 0 then return objs end
        local ok2, model = pcall(function() return game:GetService("InsertService"):LoadAsset(id) end)
        if ok2 and model then return { model } end
        task.wait(0.4)
    end
    return nil
end

function FantasmaGoner.retire(inst)
    FantasmaGoner.retired[inst] = true
    pcall(function() inst:Destroy() end)
end

function FantasmaGoner.meshOf(acc)
    local h = acc:FindFirstChild("Handle")
    if not h then return "" end
    if h:IsA("MeshPart") and h.MeshId ~= "" then return h.MeshId end
    local sm = h:FindFirstChildOfClass("SpecialMesh")
    return sm and sm.MeshId or ""
end

-- aplica UM ID localmente. Cada item é rastreado pelo ID (sem comparar aparência,
-- então acessórios parecidos como as duas asas NÃO são tratados como repetidos).
-- retorna -1 se não carregou
function FantasmaGoner.applyId(char, id)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return 0 end
    local objs = FantasmaGoner.load(id)
    if not objs then return -1 end
    local spec = FantasmaGoner.getSpec(char)

    -- remove o que ESTE id colocou antes (reaplicar nunca duplica)
    for _, inst in ipairs(spec.items[id] or {}) do
        if inst.Parent then FantasmaGoner.retire(inst) end
    end
    local mine = {}
    spec.items[id] = mine

    local list = {}
    for _, o in ipairs(objs) do
        table.insert(list, o)
        for _, d in ipairs(o:GetDescendants()) do table.insert(list, d) end
    end

    local accs = {}
    for _, o in ipairs(list) do
        if o:IsA("Shirt") or o:IsA("Pants") or o:IsA("ShirtGraphic") or o:IsA("BodyColors") then
            for _, old in ipairs(char:GetChildren()) do
                if old.ClassName == o.ClassName then FantasmaGoner.retire(old) end
            end
            local c = o:Clone()
            c:SetAttribute("GonerLocal", true)
            c.Parent = char
            table.insert(mine, c)
        elseif o:IsA("Accessory") then
            local c = o:Clone()
            c:SetAttribute("GonerLocal", true)
            -- já existe igual desenhado pelo servidor? então não duplica
            local dup = false
            local mesh = FantasmaGoner.meshOf(c)
            if mesh ~= "" then
                for _, ex in ipairs(char:GetChildren()) do
                    if ex:IsA("Accessory") and not ex:GetAttribute("GonerLocal") and FantasmaGoner.meshOf(ex) == mesh then
                        dup = true break
                    end
                end
            end
            local ok = (not dup) and pcall(function() hum:AddAccessory(c) end)
            if ok and c.Parent == char then
                table.insert(mine, c)
                table.insert(accs, c)
            else
                pcall(function() c:Destroy() end)
            end
        elseif o:IsA("Decal") and o.Name == "face" and char:FindFirstChild("Head") then
            local f = char.Head:FindFirstChild("face")
            if f then f:Destroy() end
            o:Clone().Parent = char.Head
        end
    end

    -- acessório que não prendeu no corpo cai no chão: apaga
    if #accs > 0 then
        task.wait(0.4)
        for i = #mine, 1, -1 do
            local inst = mine[i]
            if inst:IsA("Accessory") then
                local h = inst:FindFirstChild("Handle")
                local welded = h and (h:FindFirstChildWhichIsA("Weld") or h:FindFirstChildWhichIsA("WeldConstraint")
                    or h:FindFirstChildWhichIsA("Motor6D"))
                if not welded then
                    FantasmaGoner.retire(inst)
                    table.remove(mine, i)
                end
            end
        end
    end
    return #mine
end

-- repõe só o que sumiu (por ID); o que já está no personagem não é mexido
function FantasmaGoner.ensure(char)
    local spec = FantasmaGoner.specs[char]
    if not spec or not char or not char.Parent then return end
    local rebuild = {}
    for id, list in pairs(spec.items) do
        for i = #list, 1, -1 do
            if FantasmaGoner.retired[list[i]] then table.remove(list, i) end
        end
        for _, inst in ipairs(list) do
            if inst.Parent ~= char then rebuild[id] = true break end
        end
    end
    for id in pairs(rebuild) do
        FantasmaGoner.applyId(char, id)
        task.wait(0.1)
    end
end

function FantasmaGoner.startWatcher()
    if FantasmaGoner.watcher then return end
    FantasmaGoner.watcher = true
    task.spawn(function()
        while true do
            task.wait(1.5)
            for char in pairs(FantasmaGoner.specs) do
                if char and char.Parent then pcall(FantasmaGoner.ensure, char) end
            end
        end
    end)
end

-- aplica todos os IDs localmente, um de cada vez (usado no alvo do machado)
function FantasmaGoner.applyLocal(char)
    if not char then return end
    local failed = {}
    for _, id in ipairs(FantasmaGoner.CLOTHES) do
        if FantasmaGoner.applyId(char, id) == -1 then table.insert(failed, id) end
        task.wait(0.15)
    end
    FantasmaGoner.startWatcher()
    if #failed > 0 then notify("Goner", "Falhou carregar: " .. table.concat(failed, ", ")) end
end

-- ===== MÉTODO CERTO DO BROOKHAVEN (visto em scripts da comunidade) =====
-- ReplicatedStorage.Remotes.Wear:InvokeServer(assetId)  -> UM item por chamada (roupa, acessório,
-- rosto e até animação). Chamar rápido demais é ignorado pelo servidor (tem cooldown), então
-- é uma chamada por vez, esperando a resposta, com pausa entre elas.
FantasmaGoner.WEAR_GAP = 1.3
-- opcional: se algum ID for parte do corpo, preencha {torso, bracoDir, bracoEsq, pernaDir, pernaEsq, cabeca} (0 = nenhum)
FantasmaGoner.BODY = nil

function FantasmaGoner.getWear()
    local RS = game:GetService("ReplicatedStorage")
    local holder = RS:FindFirstChild("Remotes") or RS:WaitForChild("Remotes", 5)
    if not holder then return nil end
    return holder:FindFirstChild("Wear") or holder:WaitForChild("Wear", 5)
end

-- uma chamada de Wear que espera o servidor responder (máx 8s)
function FantasmaGoner.wearId(id)
    local r = FantasmaGoner.getWear()
    if not r then return false end
    local done, ok = false, false
    task.spawn(function()
        ok = pcall(function()
            if r:IsA("RemoteFunction") then return r:InvokeServer(id) else r:FireServer(id) end
        end)
        done = true
    end)
    local t0 = os.clock()
    while not done and os.clock() - t0 < 8 do task.wait(0.1) end
    return ok
end

-- conjunto de IDs que o personagem JÁ está usando (evita chamar Wear de novo e desequipar)
function FantasmaGoner.appliedSet(char)
    local set = {}
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return set end
    local ok, d = pcall(function() return hum:GetAppliedDescription() end)
    if not ok or not d then return set end
    local function add(v) v = tonumber(v) if v and v > 0 then set[v] = true end end
    for _, prop in ipairs({ "Shirt", "Pants", "GraphicTShirt", "Face", "Head", "Torso", "LeftArm", "RightArm",
        "LeftLeg", "RightLeg", "IdleAnimation", "RunAnimation", "WalkAnimation", "JumpAnimation",
        "FallAnimation", "ClimbAnimation", "SwimAnimation" }) do
        pcall(function() add(d[prop]) end)
    end
    for _, prop in ipairs({ "HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory",
        "ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory" }) do
        pcall(function() for part in tostring(d[prop]):gmatch("%d+") do add(part) end end)
    end
    pcall(function() for _, a in ipairs(d:GetAccessories(true)) do add(a.AssetId) end end)
    return set
end

-- equipa as 6 roupas pelo Brookhaven, uma por vez, sem repetir (repetir desequipa)
function FantasmaGoner.wear(char)
    char = char or LocalPlayer.Character
    if not char then return end
    local spec = FantasmaGoner.getSpec(char)
    if spec.wornDone then return end
    spec.wornDone = true
    if not FantasmaGoner.getWear() then
        notify("Goner", "Remote Wear do Brookhaven não encontrado. Aplicando direto no boneco.")
        FantasmaGoner.applyLocal(char)
        FantasmaGoner.startWatcher()
        return
    end
    if FantasmaGoner.BODY then
        local holder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        local cb = holder and holder:FindFirstChild("ChangeCharacterBody")
        local b = FantasmaGoner.BODY
        if cb then
            pcall(function() cb:InvokeServer({ b[1] or 0, b[2] or 0, b[3] or 0, b[4] or 0, b[5] or 0, b[6] or 0 }) end)
            task.wait(FantasmaGoner.WEAR_GAP)
        end
    end
    local have = FantasmaGoner.appliedSet(char)
    for i, id in ipairs(FantasmaGoner.CLOTHES) do
        if not have[id] then
            FantasmaGoner.wearId(id)
            task.wait(FantasmaGoner.WEAR_GAP)
        end
    end
end

-- transforma o PRÓPRIO jogador em goner (usado pelo comando de rede)
-- chama um remote (RemoteEvent ou RemoteFunction) sem travar
function FantasmaGoner.callRemote(r, ...)
    local args = { ... }
    local n = select("#", ...)
    local done = false
    task.spawn(function()
        pcall(function()
            if r:IsA("RemoteFunction") then r:InvokeServer(table.unpack(args, 1, n))
            else r:FireServer(table.unpack(args, 1, n)) end
        end)
        done = true
    end)
    local t0 = os.clock()
    while not done and os.clock() - t0 < 6 do task.wait(0.1) end
end

function FantasmaGoner.remote(name)
    local holder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    return holder and holder:FindFirstChild(name)
end

-- IDs dos cabelos que o personagem está usando (fora os itens do goner)
function FantasmaGoner.hairIds(char)
    local ids = {}
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return ids end
    local ok, d = pcall(function() return hum:GetAppliedDescription() end)
    if not ok or not d then return ids end
    local skip = { [FantasmaGoner.AXE_ID] = true, [FantasmaGoner.ANIM_ID] = true, [FantasmaGoner.CLICK_ID] = true, [FantasmaGoner.WALK_ID] = true }
    for _, id in ipairs(FantasmaGoner.CLOTHES) do skip[id] = true end
    local seen = {}
    local function add(v)
        v = tonumber(v)
        if v and v > 0 and not skip[v] and not seen[v] then seen[v] = true table.insert(ids, v) end
    end
    pcall(function()
        for _, a in ipairs(d:GetAccessories(true)) do
            if a.AccessoryType == Enum.AccessoryType.Hair then add(a.AssetId) end
        end
    end)
    pcall(function() for part in tostring(d.HairAccessory):gmatch("%d+") do add(part) end end)
    return ids
end

-- tira o cabelo no Brookhaven: Wear num item já equipado desequipa (um por vez, com pausa)
function FantasmaGoner.removeHair(char)
    char = char or LocalPlayer.Character
    if not char or not FantasmaGoner.getWear() then return end
    for _, id in ipairs(FantasmaGoner.hairIds(char)) do
        FantasmaGoner.wearId(id)
        task.wait(FantasmaGoner.WEAR_GAP)
    end
end

-- tira a camisa que o personagem está usando (Wear num item equipado desequipa)
function FantasmaGoner.removeShirt(char)
    char = char or LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not FantasmaGoner.getWear() then return end
    local ok, d = pcall(function() return hum:GetAppliedDescription() end)
    if not ok or not d then return end
    local skip = {}
    for _, id in ipairs(FantasmaGoner.CLOTHES) do skip[id] = true end
    for _, prop in ipairs({ "Shirt", "GraphicTShirt" }) do
        local id
        pcall(function() id = tonumber(d[prop]) end)
        if id and id > 0 and not skip[id] then
            FantasmaGoner.wearId(id)
            task.wait(FantasmaGoner.WEAR_GAP)
        end
    end
end

function FantasmaGoner.isBlack(char)
    local bc = char and char:FindFirstChildOfClass("BodyColors")
    if not bc then return false end
    local b = BrickColor.new("Black")
    return bc.HeadColor == b and bc.TorsoColor == b and bc.LeftArmColor == b
        and bc.RightArmColor == b and bc.LeftLegColor == b and bc.RightLegColor == b
end

-- pinta de preto só visualmente (usado em quem não tem o hub / se o remote falhar)
function FantasmaGoner.paintLocal(char)
    if not char then return end
    local b = BrickColor.new("Black")
    local bc = char:FindFirstChildOfClass("BodyColors")
    if not bc then bc = Instance.new("BodyColors") bc.Parent = char end
    bc.HeadColor = b bc.TorsoColor = b bc.LeftArmColor = b
    bc.RightArmColor = b bc.LeftLegColor = b bc.RightLegColor = b
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.BrickColor = b end
    end
end

-- cor da pele preta no Brookhaven: Remotes.ChangeBodyColor
function FantasmaGoner.paintBlack(char)
    char = char or LocalPlayer.Character
    if not char or FantasmaGoner.isBlack(char) then return end
    local r = FantasmaGoner.remote("ChangeBodyColor")
    if not r then FantasmaGoner.paintLocal(char) return end
    FantasmaGoner.callRemote(r, "Black")
    task.wait(1.2)
    if not FantasmaGoner.isBlack(char) then
        FantasmaGoner.callRemote(r, { BrickColor.new("Black") })
        task.wait(1.2)
    end
    if not FantasmaGoner.isBlack(char) then FantasmaGoner.paintLocal(char) end
end

-- sem cabelo + pele preta, no servidor do Brookhaven
function FantasmaGoner.styleSelf(char)
    FantasmaGoner.removeHair(char)
    FantasmaGoner.removeShirt(char)
    FantasmaGoner.paintBlack(char)
end

-- mesmo visual, só na sua tela (para o alvo que não usa o hub)
function FantasmaGoner.styleLocal(char)
    if not char then return end
    for _, o in ipairs(char:GetChildren()) do
        if o:IsA("Accessory") and o.AccessoryType == Enum.AccessoryType.Hair then o:Destroy() end
    end
    FantasmaGoner.paintLocal(char)
end

-- transformação completa do PRÓPRIO jogador pelo Brookhaven
function FantasmaGoner.goner(char)
    char = char or LocalPlayer.Character
    if not char then return end
    FantasmaGoner.wear(char)
    FantasmaGoner.styleSelf(char)
    FantasmaGoner.equipAnim(char)
end

-- clique com o machado: anima na hora e também equipa a animação pelo Wear (depois volta ao goner parado)
FantasmaGoner.clickBusy = false
function FantasmaGoner.clickAnim()
    local char = LocalPlayer.Character
    if not char then return end
    safePlayAnimation(char, FantasmaGoner.CLICK_ANIM)
    if FantasmaGoner.clickBusy or not FantasmaGoner.getWear() then return end
    FantasmaGoner.clickBusy = true
    task.spawn(function()
        local click, idle = FantasmaGoner.CLICK_ID, FantasmaGoner.ANIM_ID
        if not FantasmaGoner.appliedSet(char)[click] then
            FantasmaGoner.wearId(click)
            task.wait(FantasmaGoner.SWING_TIME + 0.5)
        end
        local set = FantasmaGoner.appliedSet(char)
        if set[click] then
            FantasmaGoner.wearId(click)          -- desequipa a animação do clique
            task.wait(FantasmaGoner.WEAR_GAP)
            set = FantasmaGoner.appliedSet(char)
        end
        for _, id in ipairs({ idle, FantasmaGoner.WALK_ID }) do   -- volta parado + andando do goner
            if not set[id] then
                FantasmaGoner.wearId(id)
                task.wait(FantasmaGoner.WEAR_GAP)
            end
        end
        FantasmaGoner.clickBusy = false
    end)
end

function FantasmaGoner.turnSelf()
    local char = LocalPlayer.Character
    if not char then return end
    local track = safePlayAnimation(char, FantasmaGoner.GONER_ANIM)
    task.wait(FantasmaGoner.TURN_DELAY)
    if track then pcall(function() track:Stop() end) end
    FantasmaGoner.goner(char)
end

-- transforma outro jogador (animação -> volta ao normal -> goner)
function FantasmaGoner.turnOther(plr)
    local char = plr and plr.Character
    if not char then return end
    local now = os.clock()
    if FantasmaGoner.hit[plr] and now - FantasmaGoner.hit[plr] < 6 then return end
    FantasmaGoner.hit[plr] = now
    sendNetCmd(";GONER_TURN " .. plr.Name)           -- quem usa o hub aplica no próprio client
    local track = safePlayAnimation(char, FantasmaGoner.GONER_ANIM)
    task.wait(FantasmaGoner.TURN_DELAY)
    if track then pcall(function() track:Stop() end) end
    FantasmaGoner.applyLocal(char)
    FantasmaGoner.styleLocal(char)
    notify("Goner", plr.Name .. " virou goner!")
end

-- espera o usuário tocar em algo no menu do Brookhaven para aprender o remote
function FantasmaGoner.learn(kind, msg)
    if FantasmaGoner.templates[kind] or not FantasmaGoner.hookOK then return FantasmaGoner.templates[kind] ~= nil end
    FantasmaGoner.armed = kind
    notify("Goner", msg)
    local t0 = os.clock()
    while not FantasmaGoner.templates[kind] and os.clock() - t0 < 120 do task.wait(0.25) end
    FantasmaGoner.armed = false
    if FantasmaGoner.templates[kind] then
        notify("Goner", "Aprendi! Continuando...")
        task.wait(1.5)
        return true
    end
    notify("Goner", "Tempo esgotado.")
    return false
end

-- equipa a animação do goner pelo Brookhaven (uma vez por personagem)
function FantasmaGoner.equipAnim(char)
    char = char or LocalPlayer.Character
    if not char then return end
    local spec = FantasmaGoner.getSpec(char)
    if spec.animDone then return end
    spec.animDone = true
    -- a animação também é equipada pelo Wear (o Brookhaven trata como item de animação)
    if FantasmaGoner.getWear() then
        local set = FantasmaGoner.appliedSet(char)
        for _, id in ipairs({ FantasmaGoner.ANIM_ID, FantasmaGoner.WALK_ID }) do
            if not set[id] then
                FantasmaGoner.wearId(id)
                task.wait(FantasmaGoner.WEAR_GAP)
            end
        end
        return
    end
    -- sem remote: toca a animação do goner em loop no próprio personagem
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3))
    if not animator then return end
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://" .. FantasmaGoner.ANIM_ID
    local ok, track = pcall(function() return animator:LoadAnimation(a) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Movement
        track.Looped = true
        track:Play()
        spec.animTrack = track
    end
end

-- liga clique + encostar em um tool (parts = peças que detectam o encontro)
function FantasmaGoner.setupTool(tool, parts)
    local swingUntil = 0
    tool.Activated:Connect(function()
        swingUntil = os.clock() + FantasmaGoner.SWING_TIME
        FantasmaGoner.clickAnim()
    end)
    local function onTouch(part)
        if FantasmaGoner.SWING_ONLY and os.clock() > swingUntil then return end
        local model = part:FindFirstAncestorOfClass("Model")
        local plr = model and Players:GetPlayerFromCharacter(model)
        if plr and plr ~= LocalPlayer then task.spawn(FantasmaGoner.turnOther, plr) end
    end
    for _, root in ipairs(parts) do
        if root:IsA("BasePart") then root.Touched:Connect(onTouch) end
        for _, p in ipairs(root:GetDescendants()) do
            if p:IsA("BasePart") then p.Touched:Connect(onTouch) end
        end
        root.DescendantAdded:Connect(function(p)
            if p:IsA("BasePart") then p.Touched:Connect(onTouch) end
        end)
    end
end

-- monta um Tool COM Handle a partir do asset (para o machado aparecer na mão ao equipar)
function FantasmaGoner.buildToolFromAsset()
    local objs = FantasmaGoner.load(FantasmaGoner.AXE_ID)
    if not objs then return nil end
    local root = objs[1]
    if root:IsA("Tool") then return root end
    local tool = Instance.new("Tool")
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    local source = root:IsA("Accessory") and root:FindFirstChild("Handle") or nil
    if not source then
        if root:IsA("BasePart") then source = root
        else
            local best, size = nil, -1
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("BasePart") and d.Size.Magnitude > size then best, size = d, d.Size.Magnitude end
            end
            source = best
        end
    end
    if not source then return nil end
    local container = root:Clone()
    local handle
    if container:IsA("Accessory") then handle = container:FindFirstChild("Handle")
    elseif container:IsA("BasePart") then handle = container
    else
        for _, d in ipairs(container:GetDescendants()) do
            if d:IsA("BasePart") and d.Size == source.Size and d.Name == source.Name then handle = d break end
        end
    end
    if not handle then return nil end
    for _, d in ipairs(container:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored = false d.CanCollide = false
            if d ~= handle then
                local w = Instance.new("WeldConstraint")
                w.Part0 = handle w.Part1 = d w.Parent = d
            end
        end
    end
    handle.Name = "Handle"
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = tool
    if container ~= handle then
        for _, c in ipairs(container:GetChildren()) do
            if c ~= handle and not c:IsA("Attachment") then c.Parent = tool end
        end
    end
    return tool
end

function FantasmaGoner.giveAxe()
    local char = LocalPlayer.Character
    if not char then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack") or char
    for _, holder in ipairs({ backpack, char }) do
        local old = holder:FindFirstChild("Machado Goner")
        if old then old:Destroy() end
    end
    local okIcon, img = pcall(resolveImage, FantasmaGoner.ICON)
    local icon = (okIcon and img) or FantasmaGoner.ICON

    -- 1) machado equipado pelo Brookhaven (Wear), como as roupas
    if FantasmaGoner.getWear() then
        local before = {}
        for _, h in ipairs({ backpack, char }) do
            for _, o in ipairs(h:GetChildren()) do before[o] = true end
        end
        if not FantasmaGoner.appliedSet(char)[FantasmaGoner.AXE_ID] then
            FantasmaGoner.wearId(FantasmaGoner.AXE_ID)
            task.wait(FantasmaGoner.WEAR_GAP + 0.7)
        end
        -- veio um Tool?
        for _, h in ipairs({ backpack, char }) do
            for _, o in ipairs(h:GetChildren()) do
                if not before[o] and o:IsA("Tool") then
                    o.Name = "Machado Goner"
                    o.TextureId = icon
                    FantasmaGoner.setupTool(o, { o })
                    return
                end
            end
        end
        -- veio como acessório: acha pelo formato e liga ao tool (mostra ao equipar, some ao desequipar)
        local axeAcc
        local objs = FantasmaGoner.load(FantasmaGoner.AXE_ID)
        local want = ""
        if objs then
            for _, o in ipairs(objs) do
                local acc = o:IsA("Accessory") and o or o:FindFirstChildWhichIsA("Accessory", true)
                if acc then want = FantasmaGoner.meshOf(acc) break end
            end
        end
        for _, o in ipairs(char:GetChildren()) do
            if o:IsA("Accessory") and ((want ~= "" and FantasmaGoner.meshOf(o) == want)
                or (not before[o] and want == "")) then
                axeAcc = o break
            end
        end
        if axeAcc then
            local tool = Instance.new("Tool")
            tool.Name = "Machado Goner"
            tool.ToolTip = "Machado Goner"
            tool.RequiresHandle = false
            tool.CanBeDropped = false
            tool.TextureId = icon
            local function show(v)
                for _, d in ipairs(axeAcc:GetDescendants()) do
                    if d:IsA("BasePart") then d.LocalTransparencyModifier = v and 0 or 1 end
                end
            end
            show(false)
            tool.Equipped:Connect(function() show(true) end)
            tool.Unequipped:Connect(function() show(false) end)
            FantasmaGoner.setupTool(tool, { axeAcc })
            tool.Parent = backpack
            return
        end
    end

    -- 2) fallback: monta o tool localmente (aparece na mão ao equipar, some ao desequipar)
    local tool = FantasmaGoner.buildToolFromAsset()
    if not tool then
        tool = Instance.new("Tool")
        tool.RequiresHandle = false
        notify("Goner", "Não consegui carregar o modelo do machado.")
    end
    tool.Name = "Machado Goner"
    tool.ToolTip = "Machado Goner"
    tool.CanBeDropped = false
    tool.TextureId = icon
    FantasmaGoner.setupTool(tool, { tool })
    tool.Parent = backpack
end

function FantasmaGoner.activate()
    if not FantasmaGoner.respawnConn then
        FantasmaGoner.respawnConn = LocalPlayer.CharacterAdded:Connect(function(c)
            if not FantasmaGoner.keep then return end
            task.wait(3)
            FantasmaGoner.goner(c)
            FantasmaGoner.giveAxe()
        end)
    end
    FantasmaGoner.keep = true
    task.spawn(function()
        if FantasmaGoner.forceLearn then
            FantasmaGoner.forceLearn = false
            FantasmaGoner.learn("wear", "1/2: abra o menu de ROUPA do Brookhaven e toque em QUALQUER item 1 vez.")
            FantasmaGoner.learn("anim", "2/2: agora abra o menu de ANIMAÇÃO do Brookhaven e toque em QUALQUER animação 1 vez.")
        end
        FantasmaGoner.goner(LocalPlayer.Character)
        FantasmaGoner.giveAxe()
        notify("Goner", "Gonerplayer ativado! Roupa + sem cabelo + pele preta + animação + Machado Goner.")
    end)
end


-- ================== COOLKID EFFECT PLAYER (roupa + martelo, igual goner) ==================
FantasmaCoolkid = {
    CLOTHES    = {87560241153484, 129138676667607, 122172916928401, 82466679852006, 123703043118660, 12289720586},
    IDLE_ANIM  = "rbxassetid://135586253433745",
    IDLE_ID    = 135586253433745,
    WALK_ANIM  = "rbxassetid://103108206614856",
    WALK_ID    = 103108206614856,
    HAMMER_ID  = 82707077257631,
    ICON       = "rbxassetid://82707077257631",
    SWING_ONLY = true,
    SWING_TIME = 1.0,
    hit = {},
}

function FantasmaCoolkid.getSpec(char)
    local sp = FantasmaGoner.specs[char]  -- reaproveita o mesmo rastreador de instâncias do goner
    if not sp then
        sp = { items = {}, worn = {} }
        FantasmaGoner.specs[char] = sp
    end
    return sp
end

-- equipa as roupas + animações pelo Wear, igual ao goner (um ID por vez, sem repetir)
function FantasmaCoolkid.wear(char)
    char = char or LocalPlayer.Character
    if not char then return end
    local spec = FantasmaCoolkid.getSpec(char)
    if spec.coolkidDone then return end
    spec.coolkidDone = true
    if not FantasmaGoner.getWear() then
        for _, id in ipairs(FantasmaCoolkid.CLOTHES) do
            FantasmaGoner.applyId(char, id)
            task.wait(0.15)
        end
        FantasmaGoner.startWatcher()
        return
    end
    local have = FantasmaGoner.appliedSet(char)
    for _, id in ipairs(FantasmaCoolkid.CLOTHES) do
        if not have[id] then
            FantasmaGoner.wearId(id)
            task.wait(FantasmaGoner.WEAR_GAP)
        end
    end
end

FantasmaCoolkid.clickBusy = false
function FantasmaCoolkid.clickAnim()
    local char = LocalPlayer.Character
    if not char then return end
    safePlayAnimation(char, FantasmaCoolkid.WALK_ANIM)   -- toca na hora, sem esperar rede
    if FantasmaCoolkid.clickBusy or not FantasmaGoner.getWear() then return end
    FantasmaCoolkid.clickBusy = true
    task.spawn(function()
        local set = FantasmaGoner.appliedSet(char)
        if not set[FantasmaCoolkid.WALK_ID] then
            FantasmaGoner.wearId(FantasmaCoolkid.WALK_ID)
            task.wait(FantasmaGoner.WEAR_GAP)
        end
        FantasmaCoolkid.clickBusy = false
    end)
end

function FantasmaCoolkid.equipAnim(char)
    char = char or LocalPlayer.Character
    if not char then return end
    local spec = FantasmaCoolkid.getSpec(char)
    if spec.coolkidAnimDone then return end
    spec.coolkidAnimDone = true
    if FantasmaGoner.getWear() then
        local set = FantasmaGoner.appliedSet(char)
        for _, id in ipairs({ FantasmaCoolkid.IDLE_ID, FantasmaCoolkid.WALK_ID }) do
            if not set[id] then
                FantasmaGoner.wearId(id)
                task.wait(FantasmaGoner.WEAR_GAP)
            end
        end
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3))
    if not animator then return end
    local a = Instance.new("Animation")
    a.AnimationId = FantasmaCoolkid.IDLE_ANIM
    local ok, track = pcall(function() return animator:LoadAnimation(a) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Movement
        track.Looped = true
        track:Play()
        spec.coolkidTrack = track
    end
end


function FantasmaCoolkid.isRed(char)
    local bc = char and char:FindFirstChildOfClass("BodyColors")
    if not bc then return false end
    local b = BrickColor.new("Really red")
    return bc.HeadColor == b and bc.TorsoColor == b and bc.LeftArmColor == b
        and bc.RightArmColor == b and bc.LeftLegColor == b and bc.RightLegColor == b
end

function FantasmaCoolkid.paintRedLocal(char)
    if not char then return end
    local b = BrickColor.new("Really red")
    local bc = char:FindFirstChildOfClass("BodyColors")
    if not bc then bc = Instance.new("BodyColors") bc.Parent = char end
    bc.HeadColor = b bc.TorsoColor = b bc.LeftArmColor = b
    bc.RightArmColor = b bc.LeftLegColor = b bc.RightLegColor = b
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.BrickColor = b end
    end
end

-- cor da pele vermelha no Brookhaven: mesmo remote do goner (Remotes.ChangeBodyColor)
function FantasmaCoolkid.paintRed(char)
    char = char or LocalPlayer.Character
    if not char or FantasmaCoolkid.isRed(char) then return end
    local r = FantasmaGoner.remote("ChangeBodyColor")
    if not r then FantasmaCoolkid.paintRedLocal(char) return end
    FantasmaGoner.callRemote(r, "Really red")
    task.wait(1.2)
    if not FantasmaCoolkid.isRed(char) then
        FantasmaGoner.callRemote(r, { BrickColor.new("Really red") })
        task.wait(1.2)
    end
    if not FantasmaCoolkid.isRed(char) then FantasmaCoolkid.paintRedLocal(char) end
end

-- transformação completa de um personagem pelo Brookhaven
function FantasmaCoolkid.apply(char)
    char = char or LocalPlayer.Character
    if not char then return end
    FantasmaCoolkid.wear(char)
    FantasmaCoolkid.paintRed(char)
    FantasmaCoolkid.equipAnim(char)
end

function FantasmaCoolkid.turnSelf()
    FantasmaCoolkid.apply(LocalPlayer.Character)
end

function FantasmaCoolkid.turnOther(plr)
    local char = plr and plr.Character
    if not char then return end
    local now = os.clock()
    if FantasmaCoolkid.hit[plr] and now - FantasmaCoolkid.hit[plr] < 6 then return end
    FantasmaCoolkid.hit[plr] = now
    sendNetCmd(";COOLKIDP_TURN " .. plr.Name)
    for _, id in ipairs(FantasmaCoolkid.CLOTHES) do
        FantasmaGoner.applyId(char, id)
        task.wait(0.1)
    end
    for _, o in ipairs(char:GetChildren()) do
        if o:IsA("Accessory") and o.AccessoryType == Enum.AccessoryType.Hair then o:Destroy() end
    end
    FantasmaCoolkid.paintRedLocal(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if animator then
        local a = Instance.new("Animation")
        a.AnimationId = FantasmaCoolkid.IDLE_ANIM
        local ok, track = pcall(function() return animator:LoadAnimation(a) end)
        if ok and track then track.Looped = true track:Play() end
    end
    notify("Coolkid", plr.Name .. " foi transformado!")
end

-- martelo: clique toca animação de golpe, encostar transforma o outro jogador (sem dano)
function FantasmaCoolkid.giveHammer()
    local char = LocalPlayer.Character
    if not char then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack") or char
    for _, holder in ipairs({ backpack, char }) do
        local old = holder:FindFirstChild("Martelo Coolkid")
        if old then old:Destroy() end
    end
    local okIcon, img = pcall(resolveImage, FantasmaCoolkid.ICON)
    local icon = (okIcon and img) or FantasmaCoolkid.ICON

    local tool
    local objs = FantasmaGoner.load(FantasmaCoolkid.HAMMER_ID)
    if objs and objs[1] then
        if objs[1]:IsA("Tool") then
            tool = objs[1]
        else
            -- monta um Tool com Handle a partir do modelo (mesma técnica do machado do goner)
            local root = objs[1]
            local source = root:IsA("BasePart") and root or root:FindFirstChildWhichIsA("BasePart", true)
            if source then
                tool = Instance.new("Tool")
                tool.RequiresHandle = true
                local container = root:Clone()
                local handle = container:IsA("BasePart") and container or container:FindFirstChildWhichIsA("BasePart", true)
                if handle then
                    for _, d in ipairs(container:GetDescendants()) do
                        if d:IsA("BasePart") then
                            d.Anchored, d.CanCollide = false, false
                            if d ~= handle then
                                local w = Instance.new("WeldConstraint")
                                w.Part0, w.Part1, w.Parent = handle, d, d
                            end
                        end
                    end
                    handle.Name = "Handle"
                    handle.Anchored, handle.CanCollide = false, false
                    handle.Parent = tool
                    if container ~= handle then
                        for _, c in ipairs(container:GetChildren()) do
                            if c ~= handle and not c:IsA("Attachment") then c.Parent = tool end
                        end
                    end
                end
            end
        end
    end
    if not tool then
        tool = Instance.new("Tool")
        tool.RequiresHandle = false
        notify("Coolkid", "Não consegui carregar o modelo do martelo.")
    end
    tool.Name = "Martelo Coolkid"
    tool.ToolTip = "Martelo Coolkid"
    tool.CanBeDropped = false
    tool.TextureId = icon

    local swingUntil = 0
    tool.Activated:Connect(function()
        swingUntil = os.clock() + FantasmaCoolkid.SWING_TIME
        FantasmaCoolkid.clickAnim()   -- instantâneo: toca a animação no clique, sem esperar nada
    end)
    local function onTouch(part)
        if FantasmaCoolkid.SWING_ONLY and os.clock() > swingUntil then return end
        local model = part:FindFirstAncestorOfClass("Model")
        local plr = model and Players:GetPlayerFromCharacter(model)
        if plr and plr ~= LocalPlayer then task.spawn(FantasmaCoolkid.turnOther, plr) end
    end
    for _, p in ipairs(tool:GetDescendants()) do
        if p:IsA("BasePart") then p.Touched:Connect(onTouch) end
    end
    tool.DescendantAdded:Connect(function(p)
        if p:IsA("BasePart") then p.Touched:Connect(onTouch) end
    end)
    tool.Parent = backpack
end

function FantasmaCoolkid.activate()
    task.spawn(function()
        FantasmaCoolkid.apply(LocalPlayer.Character)
        FantasmaCoolkid.giveHammer()
        notify("Coolkid", "Coolkid Effect Player ativado!")
    end)
end

function FantasmaGoner.relearn()
    FantasmaGoner.templates = {}
    FantasmaGoner.forceLearn = true
    local ch = LocalPlayer.Character
    if ch and FantasmaGoner.specs[ch] then FantasmaGoner.specs[ch].wornDone = false FantasmaGoner.specs[ch].animDone = false end
    FantasmaGoner.activate()
end

local function triggerCommand(action, target, extraArg)
    if not target or target == "" then return end
    if action == "GOJO_DOMAIN" then
        GOJO.cast(target)
        return
    elseif BROADCAST_ACTIONS[action] then
        task.spawn(function() pcall(runBroadcast, action, LocalPlayer.Name, target) end)
    elseif target == LocalPlayer.Name or target == "ALL" then
        executeActionLocally(action, LocalPlayer.Name, extraArg)
    end
    local cmd = ";" .. action .. " " .. target
    if extraArg then cmd = cmd .. " " .. extraArg end
    sendNetCmd(cmd)
    notify("ADM", action .. " → " .. target)
end

local function getPlayerNames()
    local n = {}
    for _, p in pairs(Players:GetPlayers()) do table.insert(n, p.Name) end
    return n
end

local ok, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not ok or not WindUI then
    notify("Erro", "Falha ao carregar WindUI.")
else
    local HUB_NAME   = "Fantasma1l hub"
    local HUB_VER    = "FANTASMA1L HUB | Administrator Version | V1.29"
    local HUB_AUTHOR = "By Fantasma1l / renegado6661l"

    -- chama método do WindUI tentando as duas assinaturas (obj:método e obj.método)
    local function try(obj, name, ...)
        local f = obj and obj[name]
        if type(f) ~= "function" then return false end
        local args = table.pack(...)
        if pcall(f, obj, table.unpack(args, 1, args.n)) then return true end
        return (pcall(f, table.unpack(args, 1, args.n)))
    end

    -- ================== TEMAS EM DEGRADÊ (com sombra) ==================
    local BLACK = Color3.new(0, 0, 0)
    local function addTheme(id, c1, c2, accent, light)
        local bg = c1
        pcall(function()
            if WindUI.Gradient then
                bg = WindUI:Gradient({
                    ["0"]   = { Color = c1, Transparency = 0 },
                    ["100"] = { Color = c2, Transparency = 0 },
                }, { Rotation = 35 })
            end
        end)
        local text = light and Color3.fromRGB(20, 20, 24) or Color3.fromRGB(255, 255, 255)
        pcall(function()
            WindUI:AddTheme({
                Name        = id,
                Accent      = accent,
                Dialog      = c2:Lerp(BLACK, 0.3),
                Outline     = accent,
                Text        = text,
                Placeholder = text:Lerp(c2, 0.5),
                Background  = bg,
                Button      = c1:Lerp(BLACK, 0.2),
                Icon        = accent,
            })
        end)
    end

    local function shaded(base) return base:Lerp(BLACK, 0.3), base:Lerp(BLACK, 0.8) end

    local THEME_LIST = {
        { "Padrão (atual)", "Dark" },
    }
    local function solid(label, base)
        local c1, c2 = shaded(base)
        addTheme("F1L_" .. label, c1, c2, base)
        table.insert(THEME_LIST, { label, "F1L_" .. label })
    end
    solid("Azul",     Color3.fromRGB(40, 110, 255))
    solid("Vermelho", Color3.fromRGB(230, 30, 40))
    solid("Laranja",  Color3.fromRGB(255, 130, 20))
    solid("Roxo",     Color3.fromRGB(150, 60, 230))
    solid("Amarelo",  Color3.fromRGB(250, 200, 20))
    solid("Verde",    Color3.fromRGB(40, 200, 90))
    solid("Cinza",    Color3.fromRGB(130, 135, 145))
    addTheme("F1L_Branco", Color3.fromRGB(245, 245, 248), Color3.fromRGB(170, 175, 185), Color3.fromRGB(60, 60, 70), true)
    table.insert(THEME_LIST, { "Branco", "F1L_Branco" })
    addTheme("F1L_Preto", Color3.fromRGB(22, 22, 26), Color3.fromRGB(4, 4, 6), Color3.fromRGB(200, 200, 205))
    table.insert(THEME_LIST, { "Preto", "F1L_Preto" })
    addTheme("F1L_BrancoAzul", Color3.fromRGB(245, 245, 250), Color3.fromRGB(50, 110, 240), Color3.fromRGB(40, 90, 220), true)
    table.insert(THEME_LIST, { "Branco e Azul", "F1L_BrancoAzul" })
    addTheme("F1L_LilasVerde", Color3.fromRGB(176, 132, 235), Color3.fromRGB(40, 170, 110), Color3.fromRGB(130, 80, 220))
    table.insert(THEME_LIST, { "Lilás e Verde", "F1L_LilasVerde" })
    addTheme("F1L_PretoLilas", Color3.fromRGB(10, 10, 14), Color3.fromRGB(130, 80, 210), Color3.fromRGB(160, 110, 240))
    table.insert(THEME_LIST, { "Preto e Lilás", "F1L_PretoLilas" })

    local THEME_NAMES, THEME_IDS = {}, {}
    for _, t in ipairs(THEME_LIST) do
        table.insert(THEME_NAMES, t[1])
        THEME_IDS[t[1]] = t[2]
    end

    -- ================== JANELA ==================
    local Window = WindUI:CreateWindow({
        Title        = HUB_NAME .. " | " .. HUB_VER,
        Author       = HUB_AUTHOR,
        Icon         = "landmark",
        Theme        = "Dark",
        Transparent  = true,
        Size         = UDim2.fromOffset(560, 300),
        SideBarWidth = 150,
        HasOutline   = false,
        Resizable    = true,
        ScrollBarEnabled = true,
    })

    -- Botão flutuante minimizado: pílula com borda azul → rosa
    pcall(function()
        Window:EditOpenButton({
            Title           = HUB_NAME .. " | Administrador",
            Icon            = "landmark",
            CornerRadius    = UDim.new(1, 0),
            StrokeThickness = 3,
            Color           = ColorSequence.new(
                Color3.fromHex("3B82F6"),
                Color3.fromHex("FF2DAA")
            ),
            OnlyMobile      = false,
            Enabled         = true,
            Draggable       = true,
        })
    end)

    -- ================== AÇÕES ==================
    local function toggleFX(kind)
        local stateTable = (kind == "FLASH") and FXNET.flash or FXNET.aura
        local isOn = stateTable[LocalPlayer.Name] ~= nil
        FXNET.send(kind .. (isOn and "_OFF" or "_ON"), LocalPlayer.Name)
    end

    local function sair()
        pcall(POOL.clear, true)
        pcall(roubeUmBrainrot, "OFF")
        pcall(TORNADO.clear, true)
        if workspace:FindFirstChild("Backrooms_Level0") then pcall(clearBackrooms) end
        task.wait(0.3)
        local chr = LocalPlayer.Character
        local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
        local best, bestD
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("SpawnLocation") then
                local dist = hrp and (d.Position - hrp.Position).Magnitude or 0
                if not best or dist < bestD then best, bestD = d, dist end
            end
        end
        if hrp and best then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = best.CFrame + Vector3.new(0, 5, 0)
        end
        notify("ADM", best and "De volta ao spawn." or "Sem SpawnLocation no mapa; use reset.")
    end

    -- ================== COMANDOS (sem Locust / Xester / Memes) ==================
    local function cmd(title, desc, cb)
        return { kind = "button", title = title, desc = desc, cb = cb }
    end
    local function exec(name, action, withExtra)
        return cmd(";" .. name, "Execute ;" .. name .. " no Jogador", function()
            triggerCommand(action, selectedPlayerName, withExtra and selectedPlayerName or nil)
        end)
    end

    local CATEGORIES = {
        {
            name = "Admin Commands", icon = "landmark",
            section = "Admin", sectionIcon = "user",
            items = {
                exec("kick",     "KICK"),
                { kind = "input", title = "Motivo do Kick", placeholder = "Digite o motivo...",
                  cb = function(t) HUBCFG.kickReason = t end },
                cmd(";kickmotivo", "Runs ;Kick PlayerName Reason", function()
                    if selectedPlayerName == LocalPlayer.Name then
                        notify("ADM", "Selecione outro jogador como alvo.")
                        return
                    end
                    local why = HUBCFG.kickReason ~= "" and HUBCFG.kickReason or nil
                    triggerCommand("KICKR", selectedPlayerName, why)
                end),
                exec("killplus",   "KILLPLUS"),
                exec("loopkill",   "LOOPKILL"),
                exec("unloopkill", "UNLOOPKILL"),
                exec("float",      "FLOAT"),
                exec("unfloat",    "UNFLOAT"),
                exec("rejoin",     "REJOIN"),
                exec("fling",      "FLING"),
                cmd(";flingall", "Fling em TODOS que usam o hub (menos você)", function()
                    triggerCommand("FLING", "ALL")
                end),
                exec("kill",     "KILL"),
                exec("freeze",   "FREEZE"),
                exec("unfreeze", "UNFREEZE"),
                exec("ice",      "ICE"),
                exec("unice",    "UNICE"),
                exec("jail",     "JAIL", true),
                exec("unjail",   "UNJAIL", true),
                exec("explode",  "EXPLODE"),
                exec("crash",    "CRASH"),
                exec("bring",    "TP_TO_POS"),
                exec("goto",     "TP_ME"),
                exec("visible",  "VISIBLE"),
                cmd(";skyline",  "Atropelar o Jogador com Skyline", function() spawnSkyline(selectedPlayerName) end),
                exec("kamui",    "KAMUI"),
                cmd(";backrooms",   "Backrooms (Eu e o Alvo)", function()
                    triggerCommand("BACKROOMS_SPAWN", selectedPlayerName, selectedPlayerName)
                end),
                cmd(";unbackrooms", "Limpar Backrooms", function()
                    task.spawn(function() pcall(clearBackrooms) end)
                    sendNetCmd(";BACKROOMS_CLEAR ALL")
                end),
                cmd(";lifeform",   "The Lifeform no Alvo", function()
                    triggerCommand("LIFEFORM_SPAWN", selectedPlayerName, selectedPlayerName)
                end),
                cmd(";unlifeform", "Remover The Lifeform", function()
                    task.spawn(function() pcall(clearLifeform) end)
                    sendNetCmd(";LIFEFORM_CLEAR ALL")
                end),
                cmd(";poolrooms",   "Poolrooms (Eu e o Alvo)", function()
                    triggerCommand("POOLROOMS_SPAWN", selectedPlayerName, selectedPlayerName)
                end),
                cmd(";unpoolrooms", "Limpar Poolrooms", function()
                    task.spawn(function() pcall(POOL.clear) end)
                    sendNetCmd(";POOLROOMS_CLEAR ALL")
                end),
            },
        },
        {
            name = "Players Effect", icon = "monitor",
            section = "Efeitos Especiais e Jumpscares", sectionIcon = "sparkles",
            items = {
                exec("jumps1", "JUMPSCARE_1"),
                exec("jumps2", "JUMPSCARE_2"),
                exec("jumps3", "JUMPSCARE_3"),
                cmd(";fly",      "Fly com Asas e Dois Halos", function() toggleFlyWithWings() end),
                cmd(";aura",     "Ativar/Desativar Aura (animação)", function() toggleAura() end),
                cmd(";flash",    "Flash (ligar/desligar)", function() toggleFX("FLASH") end),
                cmd(";goldaura", "Aura Dourada (ligar/desligar)", function() toggleFX("AURA") end),
                cmd(";brainrot",      "Roube um Brainrot (Eu e Alvo)", function()
                    task.spawn(function() pcall(roubeUmBrainrot, "ON") end)
                    if selectedPlayerName ~= LocalPlayer.Name then
                        sendNetCmd(";BRAINROT_SPAWN " .. selectedPlayerName)
                    end
                    notify("ADM", "BRAINROT → " .. selectedPlayerName)
                end),
                cmd(";brainrotall",   "Roube um Brainrot (Todos)", function() triggerCommand("BRAINROT_SPAWN", "ALL") end),
                cmd(";unbrainrot",    "Roube um Brainrot (Limpar)", function()
                    task.spawn(function() pcall(roubeUmBrainrot, "OFF") end)
                    sendNetCmd(";BRAINROT_CLEAR ALL")
                end),
                cmd(";tornado",       "Tornado EF5 (Eu)", function()
                    task.spawn(function() pcall(TORNADO.spawn, LocalPlayer.Name) end)
                end),
                cmd(";tornadoall",    "Tornado EF5 (Todos)", function() triggerCommand("TORNADO_SPAWN", "ALL") end),
                cmd(";untornado",     "Tornado (Limpar)", function()
                    task.spawn(function() pcall(TORNADO.clear) end)
                    sendNetCmd(";TORNADO_CLEAR ALL")
                end),
                cmd(";gojo",      "Modo Satoru Gojo", function() giveGojo() end),
                cmd(";sukuna",    "Expansão de Domínio [Sukuna]", function() triggerCommand("SUKUNA_DOMAIN", "ALL") end),
                cmd(";gojodominio", "Expansão de Domínio [Gojo] no jogador MAIS PRÓXIMO", function()
                    GOJO.cast("NEAREST")
                end),
                cmd(";gojodominiosel", "Expansão de Domínio [Gojo] no alvo selecionado (pode ser você)", function()
                    GOJO.cast(selectedPlayerName)
                end),
                cmd(";gojocancel", "Cancelar a Expansão de Domínio", function()
                    GOJO.cancelAll()
                end),
                cmd(";ak47",      "Pegar AK-47", function() giveAK47() end),
                cmd(";yoru",      "Equipar Yoru", function() giveYoru() end),
                cmd(";gonerplayer", "Goner Player (roupa + Machado Goner)", function() FantasmaGoner.activate() end),
                cmd(";gonerlearn", "Modo manual: ensinar roupa/animação (só se o automático falhar)", function() FantasmaGoner.relearn() end),
                cmd(";coolkideffectplayer", "Coolkid Effect Player (roupa + Martelo)", function() FantasmaCoolkid.activate() end),
                cmd(";tacos",     "Chuva de Tacos (Server)", function() triggerCommand("TACO_RAIN", "ALL") end),
                cmd(";renegado",  "Chuva do Renegado (Server)", function() triggerCommand("RENEGADO_RAIN", "ALL") end),
            },
        },
        {
            name = "Say / Command", icon = "pen-line",
            section = "Say / Command", sectionIcon = "message-square",
            items = {
                { kind = "input", title = "Texto da Mensagem", placeholder = "Digite a frase...",
                  cb = function(t) customChatText = t end },
                cmd(";say", "Say with the Target", function()
                    if customChatText ~= "" then
                        triggerCommand("CHAT_AS", selectedPlayerName, customChatText)
                    end
                end),
                cmd(";view", "Controlar Visão (View)", function()
                    isControlling = not isControlling
                    local tp = Players:FindFirstChild(selectedPlayerName)
                    if isControlling and tp and tp.Character then
                        workspace.CurrentCamera.CameraSubject = tp.Character:FindFirstChildOfClass("Humanoid")
                    else
                        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    end
                end),
                exec("c00lkidd", "COOLKID_EFFECT", true),
            },
        },
        {
            name = "Authorized", icon = "shield-check",
            section = "Authorized", sectionIcon = "shield",
            items = {
                cmd(";verificar", "Ver quem está usando o hub", function() FantasmaTag.verify() end),
                cmd(";spawn", "Sair dos mundos (voltar ao spawn)", function() task.spawn(sair) end),
            },
        },
    }

    -- ================== CONSTRUÇÃO DAS ABAS (leve: sem aba duplicada) ==================
    local dropdowns = {}
    local built = 0

    local function addTarget(tab)
        local dd = tab:Dropdown({
            Title    = "Selecionar Alvo",
            Values   = getPlayerNames(),
            Value    = selectedPlayerName,
            Callback = function(v) selectedPlayerName = v end,
        })
        table.insert(dropdowns, dd)
    end

    local function addItem(tab, item)
        if item.kind == "input" then
            tab:Input({ Title = item.title, Placeholder = item.placeholder, Callback = item.cb })
        else
            tab:Button({ Title = item.title, Desc = item.desc, Icon = "mouse-pointer-click", Callback = item.cb })
        end
        built += 1
        if built % 8 == 0 then task.wait() end   -- não congela a tela ao montar o painel
    end

    for _, cat in ipairs(CATEGORIES) do
        local tab = Window:Tab({ Title = cat.name, Icon = cat.icon })
        if cat.name ~= "Authorized" then addTarget(tab) end
        tab:Section({ Title = cat.section, Icon = cat.sectionIcon })
        for _, item in ipairs(cat.items) do addItem(tab, item) end
    end

    -- ================== ABA CONFIGURAÇÃO ==================
    local TabCfg = Window:Tab({ Title = "Configuração", Icon = "settings" })

    -- ---- Tag ----
    TabCfg:Section({ Title = "Tag", Icon = "tag" })
    TabCfg:Toggle({
        Title = "Tag ativada",
        Desc  = "Liga/desliga a tag (a sua e as que você vê)",
        Value = true,
        Callback = function(v) FantasmaTag.setEnabled(v) end,
    })
    TabCfg:Dropdown({
        Title  = "Cor da tag",
        Desc   = "Muda a cor da sua tag (os outros veem a cor escolhida)",
        Values = FantasmaTag.presetNames(),
        Value  = FantasmaTag.PRESETS[FantasmaTag.myColor()].name,
        Callback = function(name) FantasmaTag.setColor(FantasmaTag.indexOf(name)) end,
    })

    -- ---- Desempenho ----
    TabCfg:Section({ Title = "Desempenho", Icon = "gauge" })
    TabCfg:Dropdown({
        Title  = "Anti-lag",
        Desc   = "Reduz sombras/efeitos do mapa para não travar. Nenhuma função do hub é removida",
        Values = { "Desligado", "Leve", "Forte" },
        Value  = "Leve",
        Callback = function(v) FantasmaPerf.set(v) end,
    })
    FantasmaPerf.set("Leve")

    -- ---- Aparência: transparência do painel ----
    TabCfg:Section({ Title = "Aparência", Icon = "paintbrush" })
    local transparentOn, transparentVal = true, 0.2
    local function applyTransparency()
        pcall(function() WindUI.TransparencyValue = transparentVal end)
        try(Window, "ToggleTransparency", transparentOn)
    end
    TabCfg:Toggle({
        Title = "Painel transparente",
        Desc  = "Liga/desliga a transparência do painel",
        Value = true,
        Callback = function(v) transparentOn = v applyTransparency() end,
    })
    TabCfg:Slider({
        Title = "Transparência do painel",
        Desc  = "0 = sólido | 0.9 = bem transparente",
        Step  = 0.05,
        Value = { Min = 0, Max = 0.9, Default = 0.2 },
        Callback = function(v)
            transparentVal = tonumber(v) or 0.2
            applyTransparency()
        end,
    })

    -- ---- Cor do painel (degradê com sombra) ----
    TabCfg:Section({ Title = "Cor do painel", Icon = "palette" })
    TabCfg:Dropdown({
        Title  = "Tema / cor",
        Desc   = "Azul, vermelho, laranja, roxo, amarelo, verde, cinza, branco, preto e combinações",
        Values = THEME_NAMES,
        Value  = "Padrão (atual)",
        Callback = function(name)
            local id = THEME_IDS[name]
            if id then pcall(function() WindUI:SetTheme(id) end) end
        end,
    })

    -- ---- Fundo (imagem) ----
    TabCfg:Section({ Title = "Fundo (imagem)", Icon = "image" })
    local BG_IDS = {
        ["Gojo"] = 99188277568430,
        ["Toji"] = 99521340506230,
        ["Halloween"] = 72671289611166,
        ["Dragon"] = 123754864736277,
        ["Ilustração"] = 121502907054918,
    }
    local bgTransparency = 0.6
    local bgLabel

    -- acha o quadro principal do painel (o "corpo" da janela do WindUI)
    local function findMainFrame()
        local main
        pcall(function() main = Window.UIElements.Main end)
        if typeof(main) == "Instance" then return main end

        local roots = {}
        pcall(function() table.insert(roots, gethui()) end)
        pcall(function() table.insert(roots, game:GetService("CoreGui")) end)
        table.insert(roots, LocalPlayer:WaitForChild("PlayerGui"))
        local best, bestArea = nil, 0
        for _, r in ipairs(roots) do
            local okc, kids = pcall(function() return r:GetChildren() end)
            if okc then
                for _, g in ipairs(kids) do
                    if g:IsA("ScreenGui") and string.find(string.lower(g.Name), "windui") then
                        for _, d in ipairs(g:GetDescendants()) do
                            if d:IsA("Frame") and d.Name == "Main" then return d end
                        end
                        for _, d in ipairs(g:GetDescendants()) do
                            if d:IsA("Frame") and d:FindFirstChildOfClass("UICorner") then
                                local area = d.AbsoluteSize.X * d.AbsoluteSize.Y
                                if d.AbsoluteSize.X < g.AbsoluteSize.X * 0.98 and area > bestArea then
                                    best, bestArea = d, area
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local function setBackground(name)
        if bgLabel then
            pcall(function() bgLabel:Destroy() end)
            bgLabel = nil
        end
        local id = BG_IDS[name]
        if not id then return end
        local host = findMainFrame()
        if not host then
            notify("Fundo", "Não achei o painel pra colocar a imagem.")
            return
        end
        local src = resolveImage(id)   -- converte Decal -> imagem real
        local lbl = Instance.new("ImageLabel")
        lbl.Name = "F1L_Background"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Image = src
        lbl.ImageTransparency = bgTransparency
        lbl.ScaleType = Enum.ScaleType.Crop
        lbl.ZIndex = 50            -- por cima do fundo do painel, pra sempre aparecer
        lbl.Active = false
        pcall(function() lbl.Interactable = false end)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 16)
        corner.Parent = lbl
        lbl.Parent = host
        bgLabel = lbl
        -- plano B: se a imagem não carregar em 4s, usa a miniatura do asset
        task.delay(4, function()
            if bgLabel == lbl and lbl.Parent and not lbl.IsLoaded then
                lbl.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=420&h=420"
            end
        end)
    end

    TabCfg:Dropdown({
        Title  = "Imagem de fundo",
        Desc   = "Gojo, Toji, Halloween, Dragon ou Ilustração",
        Values = { "Nenhum", "Gojo", "Toji", "Halloween", "Dragon", "Ilustração" },
        Value  = "Nenhum",
        Callback = function(name)
            task.spawn(function() pcall(setBackground, name) end)
        end,
    })
    TabCfg:Slider({
        Title = "Transparência da imagem",
        Desc  = "0 = imagem forte | 1 = invisível",
        Step  = 0.05,
        Value = { Min = 0, Max = 1, Default = 0.6 },
        Callback = function(v)
            bgTransparency = tonumber(v) or 0.6
            if bgLabel and bgLabel.Parent then bgLabel.ImageTransparency = bgTransparency end
        end,
    })

    TabCfg:Section({ Title = "Santuário do Sukuna", Icon = "landmark" })
    TabCfg:Dropdown({
        Title  = "Direção do santuário",
        Desc   = "Se o santuário aparecer de lado ou de costas, troque aqui",
        Values = { "0°", "90°", "180°", "270°" },
        Value  = "0°",
        Callback = function(v)
            SHRINE_YAW = tonumber(tostring(v):match("%d+")) or 0
        end,
    })

    pcall(function() Window:SelectTab(1) end)

    -- Mantém o dropdown de alvo atualizado
    local function refreshPlayers()
        local names = getPlayerNames()
        for _, dd in ipairs(dropdowns) do
            pcall(function()
                if dd.Refresh then dd:Refresh(names)
                elseif dd.SetValues then dd:SetValues(names) end
            end)
        end
    end
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(function() task.defer(refreshPlayers) end)
end

end -- fim IS_ADMIN
