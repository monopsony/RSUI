_,RSUI=...

_rsuiGlobal=RSUI

RSUI.bigS=45
RSUI.medS=30
RSUI.smallS=22.5
RSUI.bigFS=24
RSUI.medFS=15
RSUI.smallFS=13

local tempF=CreateFrame("Frame")
tempF:RegisterEvent("PLAYER_ENTERING_WORLD")
tempF:SetScript("OnEvent",function()
  local className=UnitClass("player")
  if className~="Shaman" then return
  else
    tempF:UnregisterEvent("PLAYER_ENTERING_WORLD")
    tempF=nil
    local fabn=function(goal,unit,arg1,arg2,arg3)
        for i=1,40 do
          local name,_,_,_,_,_,caster=UnitAura(unit,i,arg1,arg2)
          if not name then return nil end
          if (name==goal) and (caster=="player") then return UnitAura(unit,i,arg1,arg2,arg3) end
        end  
    end
    
    local green={0.3,0.95,0.3}
    local red={0.9,0.3,0.3}
    local yellow={0.95,0.95,0.3}
    
    local manaBD={edgeFile ="Interface\\DialogFrame\\UI-DialogBox-Border",edgeSize = 8, insets ={ left = 0, right = 0, top = 0, bottom = 0 }}
    local bd2={edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 10, insets = { left = 4, right = 4, top = 4, bottom = 4 }}
    local insert=table.insert
    local port,auraPort,activeAuras={},{},{}
    local mf=math.floor
    local afterDo=C_Timer.After
    local pairs=pairs
    local playerName=UnitName("player")
    local nCheck=4 --means echecking 4 times across the duration of the cooldown (to account for random changes, kinda)
                   --I know it's not clean but it still seems safe for little loss
                   
    function RSUI.onCast1(self)
      local t,d=GetSpellCooldown(self.id)
      if d<1.5 then
        self.offCD:Show()
        self.onCD:Hide()
      else
        if self.cast then
          local d2=d/nCheck
          for i=1,nCheck-1 do
            afterDo(i*d2,function() self:onCast() end)
          end
        end
        
        self.offCD:Hide()
        self.onCD:Show()
        self.onCD.et=1
        self.onCD.cd:SetCooldown(t,d)
        self.onCD.t=t
        self.onCD.d=d
      end
      self.cast=false
    end

    function RSUI.onUpdate1(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end

      self.et=0
      local rT=self.t+self.d-GetTime()
      self.text1:SetText(mf(rT))
      if rT<0.01 then self.parent:onCast() end
    end
    
    function RSUI.auraTOnUpdate(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end
      self.et=0
      local rT=self.eT-GetTime()
      self.normal.text:SetText(mf(rT))
    end
    
    function RSUI.onUpdate2(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end

      self.et=0
      local rT=self.t+self.d-GetTime()
      if rT<0.01 then self.parent:onCast() end
    end
   
    local function createCDIcon(id,size,hasCDTimer)
      local hasCDTimer=hasCDTimer
      if not hasCDTimer then hasCDTimer=false end --unnecessary, I know
      local iF
      local _,_,icon=GetSpellInfo(id)
      local s,fs
      if size=="big" then s=RSUI.bigS; fs=RSUI.bigFS end
      if size=="med" then s=RSUI.medS; fs=RSUI.medFS end
      if size=="small" then s=RSUI.smallS; fs=RSUI.smallFS end

      iF=CreateFrame("Frame",nil,RSUI.f)
      iF:SetSize(s,s)
      iF:SetFrameLevel(5)
      iF.id=id
      
      iF.offCD=CreateFrame("Frame",nil,iF)
      iF.offCD:SetAllPoints(true)

      iF.offCD.texture=iF.offCD:CreateTexture(nil,"BACKGROUND")
      iF.offCD.texture:SetAllPoints(true)
      iF.offCD.texture:SetTexture(icon)

      iF.offCD.cd=CreateFrame("Cooldown",nil,iF.offCD,"CooldownFrameTemplate")
      iF.offCD.cd:SetAllPoints(true)
      iF.offCD.cd:SetFrameLevel(iF.offCD:GetFrameLevel())
      iF.offCD.cd:SetDrawEdge(false)
      iF.offCD.cd:SetDrawBling(false)
      
      iF.offCD.text2=iF.offCD:CreateFontString(nil,"OVERLAY")
      iF.offCD.text2:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.offCD.text2:SetPoint("CENTER")
      
      iF.onCD=CreateFrame("Frame",nil,iF)
      iF.onCD:SetAllPoints(true)
      
      iF.onCD.texture=iF.onCD:CreateTexture(nil,"BACKGROUND")
      iF.onCD.texture:SetAllPoints(true)
      iF.onCD.texture:SetTexture(icon)
      iF.onCD.texture:SetDesaturated(1)

      iF.onCD.cd=CreateFrame("Cooldown",nil,iF.onCD,"CooldownFrameTemplate")
      iF.onCD.cd:SetAllPoints(true)
      iF.onCD.cd:SetFrameLevel(iF.onCD:GetFrameLevel())
      iF.onCD.cd:SetDrawEdge(false)
      iF.onCD.cd:SetDrawBling(false)
      
      iF.onCD.text1=iF.onCD:CreateFontString(nil,"OVERLAY")
      iF.onCD.text1:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.onCD.text1:SetPoint("CENTER")

      if hasCDTimer then iF.onCD:SetScript("OnUpdate",RSUI.onUpdate1) 
      else iF.onCD:SetScript("OnUpdate",RSUI.onUpdate2) end
      iF.onCD.parent=iF

      iF.onCD:Hide()

      iF.onCD.et=0
      port[id]=iF
      return iF
    end
    
    local function createAuraIcon(id,size,notplayer)
      local iF
      local _,_,icon=GetSpellInfo(id)
      local s,fs
      if size=="big" then s=RSUI.bigS; fs=RSUI.bigFS end
      if size=="med" then s=RSUI.medS; fs=RSUI.medFS end
      if size=="small" then s=RSUI.smallS; fs=RSUI.smallFS end

      iF=CreateFrame("Frame",nil,RSUI.f)
      iF:SetSize(s,s)
      iF:SetFrameLevel(5)
      iF.id=id
      
      iF.grey=CreateFrame("Frame",nil,iF)
      iF.grey:SetAllPoints(true)

      iF.grey.texture=iF.grey:CreateTexture(nil,"BACKGROUND")
      iF.grey.texture:SetAllPoints(true)
      iF.grey.texture:SetTexture(icon)
      iF.grey.texture:SetDesaturated(1)

      iF.grey.text=iF.grey:CreateFontString(nil,"OVERLAY")
      iF.grey.text:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.grey.text:SetPoint("CENTER")
      
      iF.normal=CreateFrame("Frame",nil,iF)
      iF.normal:SetAllPoints(true)
      
      iF.normal.texture=iF.normal:CreateTexture(nil,"BACKGROUND")
      iF.normal.texture:SetAllPoints(true)
      iF.normal.texture:SetTexture(icon)

      iF.normal.cd=CreateFrame("Cooldown",nil,iF.normal,"CooldownFrameTemplate")
      iF.normal.cd:SetAllPoints(true)
      iF.normal.cd:SetFrameLevel(iF.normal:GetFrameLevel())
      iF.normal.cd:SetReverse(true)
      
      
      iF.normal.text=iF.normal:CreateFontString(nil,"OVERLAY")
      iF.normal.text:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.normal.text:SetPoint("CENTER")

      iF.normal:Hide()

      iF.normal.et=0
      if not notplayer then auraPort[id]=iF end
      return iF
    end

    local function checkTalentStuff()
      local _,_,_,ul = GetTalentInfo(1,3,1)
      local _,_,_,echo = GetTalentInfo(2,1,1)
      local _,_,_,ewt = GetTalentInfo(4,2,1)
      local _,_,_,apt = GetTalentInfo(4,3,1)
      local _,_,_,dp = GetTalentInfo(6,2,1)
      local _,_,_,ht=GetTalentInfo(7,1,1)
      local _,_,_,wsp=GetTalentInfo(7,2,1)
      local _,_,_,asc=GetTalentInfo(7,3,1)
      
      if ul then RSUI.ul:Show(); RSUI.ul:onCast() else RSUI.ul:Hide() end
      if echo then RSUI.rip.echo=true; RSUI.hst.echo=true; RSUI.lb.echo=true; else RSUI.rip.echo=false; RSUI.hst.echo=false; RSUI.lb.echo=true; end
      if apt then RSUI.apt:Show(); RSUI.apt:onCast() else RSUI.apt:Hide() end 
      if dp then RSUI.dp:Show(); RSUI.dp:onCast() else RSUI.dp:Hide() end 
      if ht then RSUI.ht:Show(); else RSUI.ht:Hide() end
      if ewt then RSUI.ewt:Show() else RSUI.ewt:Hide() end
      
      --Why 0.5? idk seems to work fine stfu
      afterDo(0.5, function()
          for k,v in pairs({"rip","hst","lb"}) do 
             RSUI[v]:onCast()
          end
      end)
      
    end

    local function checkCombat()
        if true then return  end
        if InCombatLockdown() then RSUI.f:Show() else RSUI.f:Hide() end 
    end
    
    local function checkSpecialization()
      
      if GetSpecialization()==3 then 
        RSUI.f:Show() 
        RSUI.f.loaded=true
      else 
        RSUI.f:Hide() 
        RSUI.f.loaded=false
      end
      checkCombat()
    end
    
    local function checkTargetFS()
      if not UnitExists("target") then return nil end

      local _,_,_,_,d,ext=fabn("Flame Shock","target","HARMFUL","PLAYER")
      
      return d,ext
    end
    
    local function checkRegisteredAuras()
      wipe(activeAuras)
      
      for i=1,40 do 
        local name,_,count,_,d,eT,_,_,_,id=UnitAura("player",i,"HELPFUL","PLAYER")
        if not name then break end
        if auraPort[id] then activeAuras[id]={d=d,eT=eT,count=count} end
      end  
      
      for k,v in pairs(auraPort) do v:check() end
      
    end
    
    local function checkAura(self)
      local id=self.id
      if not activeAuras[id] then 
          self.grey:Show()
          self.normal:Hide()
      else
          self.normal:Show()
          self.grey:Hide()
          local s,d,eT=activeAuras[id].count or 0,activeAuras[id].d,activeAuras[id].eT
          self.normal.cd:SetCooldown(eT-d,d)
          self.normal.text:SetText(s)
      end
    end
    
    local function checkAuraT(self)
      local id=self.id
      if not activeAuras[id] then 
          self:Hide()
      else
          self:Show()
          local s,d,eT=activeAuras[id].count or 0,activeAuras[id].d,activeAuras[id].eT
          self.normal.cd:SetCooldown(eT-d,d)
          self.et=1
          self.eT=eT
      end
    end
       
    local function fOnShow()
      for _,v in pairs(port) do  v:onCast() end
      RSUI.mana:update()
    end
          
    function RSUI.onCastRip(self)
      local s,_,t,d=GetSpellCharges(self.id)

      if s==2 then
        self.onCD:Hide()
        self.offCD:Show()
        self.offCD.et=1
        self.offCD.cd:SetCooldown(0,0)
        self.offCD.t=t
        self.offCD.d=d
        self.offCD.text2:SetText(s)
      elseif s>0 and d>2 then
        self.onCD:Hide()
        self.offCD:Show()
        self.offCD.et=1
        self.offCD.t=t
        self.offCD.d=d
        if self.echo then 
            self.offCD.cd:SetCooldown(t,d)
            self.offCD.text2:SetText(s)
            afterDo(d, function() self:onCast() end)
        else
            self.offCD.cd:SetCooldown(0,0)
            self.offCD.text2:SetText("")
        end
      elseif s==0 then
        self.offCD:Hide()
        self.onCD:Show()
        self.onCD.et=1
        self.onCD.cd:SetCooldown(t,d)
        self.onCD.t=t
        self.onCD.d=d
      end
      
    end
    
    local currentHaste=0
    local hasteSpells={}
    RSUI.eventHandler = function(self,event,_,tar,id,id2)
      if not self.loaded then return end
      if event=="UNIT_HEALTH_FREQUENT" then
        RSUI.health:update()

      elseif event=="UNIT_POWER_UPDATE" then 
        RSUI.mana:update()
                
      elseif event=="UNIT_AURA" then      
        checkRegisteredAuras()
        
      elseif event=="UNIT_SPELLCAST_SUCCEEDED" then
       local spell=port[id]
       
       if spell then    
         spell.cast=true         
         afterDo(0,function() spell:onCast();  end)         
       end
      
      elseif event=="UNIT_SPELL_HASTE" then
        if true then return end --TBA check if any haste spells
        local haste=UnitSpellHaste("player")
        if haste==currentHaste then return end
        currentHaste=haste
        for i=1,#hasteSpells do 
          local spell=port[hasteSpells[i]]
          afterDo(0,function() spell:onCast();  end)   
        end
      end
      
    end
    
    RSUI.f=CreateFrame("Frame","RSUIFrame",UIParent)
    local f=RSUI.f

    --main frame + mover + slash command
    do
    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED","player")
    f:RegisterUnitEvent("UNIT_POWER_UPDATE","player")
    f:RegisterUnitEvent("UNIT_HEALTH_FREQUENT","player")
    f:RegisterUnitEvent("UNIT_SPELL_HASTE","player")
    f:RegisterUnitEvent("UNIT_AURA","player")
    f:SetScript("OnEvent",RSUI.eventHandler)
    f:SetScript("OnShow",fOnShow)
    f:SetSize(2*RSUI.bigS+1,150)
    f:SetPoint("CENTER")
    f:SetMovable(true)

    f.mover=CreateFrame("Frame",nil,f)
    f.mover:SetAllPoints(true)
    f.mover:SetFrameLevel(20)

    f.mover.texture=f.mover:CreateTexture(nil,"OVERLAY")
    f.mover.texture:SetAllPoints(true)
    f.mover.texture:SetColorTexture(0,0,0.1,0.5)

    f.mover:EnableMouse(true)
    f.mover:SetMovable(true)
    f.mover:RegisterForDrag("LeftButton")
    f.mover:SetScript("OnMouseDown", function() RSUI.f:StartMoving();  end)
    f.mover:SetScript("OnMouseUp", function() RSUI.f:StopMovingOrSizing();  end)
    f.mover:Hide()

    SLASH_RSUI1="/rsui"
    SlashCmdList["RSUI"]= function(arg)
      if f.mover:IsShown() then f.mover:Hide() else f.mover:Show() end
    end

    end --end of main mover slash

    --helper frame
    do
    RSUI.h=CreateFrame("Frame","RSUIHFrame",UIParent)
    local h=RSUI.h
    h:SetPoint("CENTER")
    h:SetSize(1,1)
    h:RegisterEvent("PLAYER_REGEN_ENABLED")
    h:RegisterEvent("PLAYER_REGEN_DISABLED")
    h:RegisterEvent("PLAYER_ENTERING_WORLD")
    h:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    h:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    
    local function hEventHandler(self,event) 
      if event=="PLAYER_REGEN_ENABLED" then
        afterDo(15,checkCombat)
      elseif event=="PLAYER_REGEN_DISABLED" then
        if self.loaded then RSUI.f:Show() end
      elseif event=="ACTIVE_TALENT_GROUP_CHANGED" then
        checkTalentStuff()
      elseif event=="PLAYER_SPECIALIZATION_CHANGED" then
        checkSpecialization()
      end
    end

    h:SetScript("OnEvent",hEventHandler)

    end --end of help frame

    --spells 
    do 

    RSUI.rip=createCDIcon(61295,"big",true)
    RSUI.rip:SetPoint("TOPLEFT",RSUI.f,"TOPLEFT",0,0)
    RSUI.rip.onCast=RSUI.onCastRip  
    RSUI.rip.offCD.text2:SetTextColor(green[1],green[2],green[3])
    
    RSUI.ul=createCDIcon(73685,"big",true)
    RSUI.ul:SetPoint("LEFT",RSUI.rip,"RIGHT",1,0)
    RSUI.ul.onCast=RSUI.onCast1

    RSUI.hst=createCDIcon(5394,"med",true)
    RSUI.hst:SetPoint("TOPLEFT",RSUI.rip,"BOTTOMLEFT",0,-2-RSUI.bigS)
    RSUI.hst.onCast=RSUI.onCastRip
    RSUI.hst.offCD.text2:SetTextColor(green[1],green[2],green[3])
   
    RSUI.dp=createCDIcon(252159,"med")
    RSUI.dp:SetPoint("TOPRIGHT",RSUI.ul,"BOTTOMRIGHT",0,-2-RSUI.bigS)
    RSUI.dp.onCast=RSUI.onCast1
    
    RSUI.hr=createCDIcon(73920,"big",true)
    RSUI.hr:SetPoint("TOP",RSUI.rip,"BOTTOM",0,-1)
    RSUI.hr.onCast=RSUI.onCast1

    RSUI.tw=createAuraIcon(53390,"big")
    RSUI.tw:SetPoint("TOP",RSUI.ul,"BOTTOM",0,-1)
    RSUI.tw.normal.text:SetTextColor(green[1],green[2],green[3])
    RSUI.tw.normal.cd:SetReverse(true)
    RSUI.tw.check=checkAura
    
    RSUI.ht=createAuraIcon(288675,"med")
    RSUI.ht:SetPoint("TOPRIGHT",RSUI.ul,"BOTTOMRIGHT",0,-3-RSUI.bigS-RSUI.medS)
    RSUI.ht.normal.text:SetTextColor(green[1],green[2],green[3])
    RSUI.ht.normal.cd:SetReverse(true)
    RSUI.ht.check=checkAura

    RSUI.apt=createCDIcon(207399,"med",false)
    RSUI.apt:SetPoint("TOPLEFT",RSUI.hst,"BOTTOMLEFT",0,-1)
    RSUI.apt.onCast=RSUI.onCast1     
    
    RSUI.ewt=createCDIcon(198838,"med",false)
    RSUI.ewt:SetPoint("TOPLEFT",RSUI.hst,"BOTTOMLEFT",0,-1)
    RSUI.ewt.onCast=RSUI.onCast1   
    
    RSUI.ws=createCDIcon(57994,"med",false)
    RSUI.ws:SetPoint("TOP",RSUI.apt,"BOTTOM",0,-1)
    RSUI.ws.onCast=RSUI.onCast1   

    RSUI.ps=createCDIcon(77130,"med",false)
    RSUI.ps:SetPoint("TOP",RSUI.ws,"BOTTOM",0,-1)
    RSUI.ps.onCast=RSUI.onCast1   
    
    RSUI.htt=createCDIcon(108280,"med",false)
    RSUI.htt:SetPoint("TOPRIGHT",RSUI.tw,"BOTTOMRIGHT",0,-4-2*RSUI.medS)
    RSUI.htt.onCast=RSUI.onCast1   
    --RSUI.htt.onCD.texture:SetTexture(253400)
    --RSUI.htt.offCD.texture:SetTexture(253400)
    
    
    
    RSUI.fs=createAuraIcon(188389,"small",true)
    RSUI.fs:SetPoint("TOPLEFT",RSUI.ps,"BOTTOMLEFT",0,-2)
    RSUI.fs:RegisterUnitEvent("UNIT_AURA","TARGET")
    RSUI.fs:RegisterEvent("PLAYER_TARGET_CHANGED")
    RSUI.fs:SetScript("OnEvent",function(self)
      local d,ext=checkTargetFS()      
      if d then 
        self.grey:Hide()
        self.normal:Show()
        self.normal.d=d
        self.normal.ext=ext
        self.normal.cd:SetCooldown(ext-d,d)
        self.et=10
      else
        self.grey:Show()
        self.normal:Hide()
      end  
    end)
    RSUI.fs.normal:SetScript("OnUpdate",function(self,elapsed)
      self.et=self.et+elapsed
      if self.et<0.15 then return end
      self.et=0
      self.text:SetText(mf(self.ext-GetTime()))   
    end)

    RSUI.slt=createCDIcon(98008,"med",false)
    RSUI.slt:SetPoint("TOP",RSUI.htt,"BOTTOM",0,-1)
    RSUI.slt.onCast=RSUI.onCast1  
    
    
    RSUI.lb=createCDIcon(51505,"small",true)
    RSUI.lb:SetPoint("LEFT",RSUI.fs,"RIGHT",1,0)
    RSUI.lb.onCast=RSUI.onCastRip  
    RSUI.lb.offCD.text2:SetTextColor(green[1],green[2],green[3])
    
    RSUI.as=createCDIcon(108271,"small",false)
    RSUI.as:SetPoint("LEFT",RSUI.lb,"RIGHT",1,0)
    RSUI.as.onCast=RSUI.onCast1
    
    RSUI.swg=createCDIcon(79206,"small",true)
    RSUI.swg:SetPoint("LEFT",RSUI.as,"RIGHT",1,0)
    RSUI.swg.onCast=RSUI.onCast1
    
    RSUI.swgAura=createAuraIcon(79206,"small")
    RSUI.swgAura:SetPoint("CENTER",RSUI.f,"CENTER",0,-40)
    RSUI.swgAura.check=RSUI.checkAuraT
    RSUI.swgAura.normal.text:SetTextColor(yellow[1],yellow[2],yellow[3])
    RSUI.swgAura.normal.cd:SetReverse(true)
    RSUI.swgAura.onUpdate=RSUI.auraTOnUpdate
    RSUI.swgAura:SetScript("OnUpdate",RSUI.swgAura.onUpdate)
    RSUI.swgAura.check=checkAuraT
    RSUI.swgAura.normal:Show()
    RSUI.swgAura.grey:Hide()
    RSUI.swgAura.et=1
    RSUI.swgAura.eT=0
    RSUI.swgAura:SetAlpha(0.7)
    end

    --mana bar
    do
    local function manaUpdateFunc(self)
      local m=UnitPower("player")
      local mm=UnitPowerMax("player")
      local val=m/mm*100
      self:SetValue(val)
      self.text:SetText(mf(val))
    end


    RSUI.mana=CreateFrame("StatusBar","RSUImana",RSUI.f,"TextStatusBar")
    RSUI.mana:SetPoint("TOPLEFT",RSUI.tw,"BOTTOMLEFT",1,-1)
    RSUI.mana:SetHeight(122)
    RSUI.mana:SetWidth(12)
    RSUI.mana:SetOrientation("VERTICAL")
    RSUI.mana:SetReverseFill(false)
    RSUI.mana:SetMinMaxValues(0,100)
    RSUI.mana:SetStatusBarTexture(0.3,0.3,0.95,1)
    RSUI.mana.update=manaUpdateFunc

    local bt=RSUI.mana:GetStatusBarTexture()
    bt:SetGradientAlpha("HORIZONTAL",1,1,1,1,0.4,0.4,0.4,1)


    RSUI.mana.border=CreateFrame("Frame",nil,RSUI.mana)
    RSUI.mana.border:SetPoint("TOPRIGHT",RSUI.mana,"TOPRIGHT",3,3)
    RSUI.mana.border:SetPoint("BOTTOMLEFT",RSUI.mana,"BOTTOMLEFT",-6,-3)
    --RSUI.mana.border:SetBackdrop(manaBD) 

    RSUI.mana.text=RSUI.mana.border:CreateFontString(nil,"OVERLAY")
    RSUI.mana.text:SetFont("Fonts\\FRIZQT__.ttf",12,"OUTLINE")
    RSUI.mana.text:SetPoint("TOP",RSUI.mana,"TOP",0,-2)
    RSUI.mana.text:Hide() --rmove if want to show obv.

    RSUI.mana.bg=RSUI.mana:CreateTexture(nil,"BACKGROUND")
    RSUI.mana.bg:SetPoint("TOPRIGHT",RSUI.mana,"TOPRIGHT",2,2)
    RSUI.mana.bg:SetPoint("BOTTOMLEFT",RSUI.mana,"BOTTOMLEFT",-2,-2)
    RSUI.mana.bg:SetColorTexture(0,0,0,1)

    end

    --health bar
    do
    local function healthUpdateFunc(self)
      local m=UnitHealth("player")
      local mm=UnitHealthMax("player")
      local val=m/mm*100
      self:SetValue(val)
      self.text:SetText(mf(val))
    end


    RSUI.health=CreateFrame("StatusBar","RSUIhealth",RSUI.f,"TextStatusBar")
    RSUI.health:SetPoint("TOPRIGHT",RSUI.hr,"BOTTOMRIGHT",-1,-1)
    RSUI.health:SetHeight(122)
    RSUI.health:SetWidth(12)
    RSUI.health:SetOrientation("VERTICAL")
    RSUI.health:SetReverseFill(false)
    RSUI.health:SetMinMaxValues(0,100)
    RSUI.health:SetStatusBarTexture(0.3,0.85,0.3,1)
    RSUI.health.update=healthUpdateFunc

    local bt=RSUI.health:GetStatusBarTexture()
    bt:SetGradientAlpha("HORIZONTAL",1,1,1,1,0.4,0.4,0.4,1)

    RSUI.health.border=CreateFrame("Frame",nil,RSUI.health)
    RSUI.health.border:SetPoint("TOPRIGHT",RSUI.health,"TOPRIGHT",6,3)
    RSUI.health.border:SetPoint("BOTTOMLEFT",RSUI.health,"BOTTOMLEFT",-3,-3)
    --RSUI.health.border:SetBackdrop(healthBD) 

    RSUI.health.text=RSUI.health.border:CreateFontString(nil,"OVERLAY")
    RSUI.health.text:SetFont("Fonts\\FRIZQT__.ttf",12,"OUTLINE")
    RSUI.health.text:SetPoint("TOP",RSUI.health,"TOP",0,-2)
    RSUI.health.text:Hide() --rmove if want to show obv.

    RSUI.health.bg=RSUI.health:CreateTexture(nil,"BACKGROUND")
    RSUI.health.bg:SetPoint("TOPRIGHT",RSUI.health,"TOPRIGHT",2,2)
    RSUI.health.bg:SetPoint("BOTTOMLEFT",RSUI.health,"BOTTOMLEFT",-2,-2)
    RSUI.health.bg:SetColorTexture(0,0,0,1)
    end

    
    --things to do on PLAYER_ENTERING_WORLD
    checkTalentStuff()
    fOnShow()
    checkSpecialization()
    if playerName=="Monocarp" then 
        --RSUI.f:Show()
        if _eFGlobal then --eF1
            afterDo(0,function() RSUI.f:SetPoint("TOPRIGHT",_eFGlobal.units,"TOPLEFT",-2,0) end) 
            
        elseif elFramoGlobal then --eF2
            afterDo(0,function() RSUI.f:SetPoint("TOPRIGHT",UIParent,"BOTTOMLEFT",elFramoGlobal.para.units.xPos-2,elFramoGlobal.para.units.yPos) end) 
        end
    end    
    
    --NON DISC UI RELATED THINGS
    --[[
    afterDo(5,function()
    if BigWigsAnchor then BigWigsAnchor:ClearAllPoints();  BigWigsAnchor:SetPoint("TOPLEFT",_eFGlobal.units,"TOPRIGHT",0,2) end 
    end)
    ]]
    checkCombat()
    
  end
end)













