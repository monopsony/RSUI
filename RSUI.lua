_,RSUI=...

_rsuiGlobal=RSUI

RSUI.bigS=45
RSUI.medS=30
RSUI.smallS=20
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
    local port={}
    local mf=math.floor
    local afterDo=C_Timer.After
    local pairs=pairs
    local playerName=UnitName("player")
    local nCheck=4 --means echecking 4 times across the duration of the cooldown (to account for haste changes, kinda)
                   --I know it's not clean but it still seems more efficient than any alternative
                   
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

    function RSUI.onCastRap(self)
      local t,d=GetSpellCooldown(self.id)
      if d<2 then
        self.offCD:Show()
        self.onCD:Hide()
      else
        self.offCD:Hide()
        self.onCD:Show()
        self.onCD.et=1
        self.onCD.cd:SetCooldown(t,d)
        self.onCD.t=t
        self.onCD.d=d
        
        local ext=select(6,fabn("Rapture","player","HELPFUL","PLAYER"))
        if ext then
        self.active:Show()
        self.active.ext=ext
        afterDo(ext-GetTime(),function() self.active:Hide() end)
        end
      end

    end
    
    function RSUI.onUpdate1(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end

      self.et=0
      local rT=self.t+self.d-GetTime()
      self.text1:SetText(mf(rT))
      if rT<0.01 then self.parent:onCast() end
    end
    
    function RSUI.onUpdate2(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end

      self.et=0
      local rT=self.t+self.d-GetTime()
      if rT<0.01 then self.parent:onCast() end
    end
    
    function RSUI.onUpdateJSSChannelUp(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end

      self.et=0
      local rT=self.t+self.d-GetTime()
      self.text:SetText(mf(rT))    
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
    
    local function createAuraIcon(id,size)
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

      iF.normal.text=iF.normal:CreateFontString(nil,"OVERLAY")
      iF.normal.text:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.normal.text:SetPoint("CENTER")

      iF.normal:Hide()

      iF.normal.et=0
      return iF
    end

    local function checkTalentStuff()
      local _,_,_,sch = GetTalentInfo(1,3,1)
      local _,_,_,sol = GetTalentInfo(3,3,1)
      local _,_,_,mb = GetTalentInfo(3,2,1)
      local _,_,_,halo = GetTalentInfo(6,3,1)
      local _,_,_,ds = GetTalentInfo(6,2,1)
      local _,_,_,evan=GetTalentInfo(7,3,1)
      local _,_,_,lb=GetTalentInfo(7,2,1)
      if sch then RSUI.sch:Show(); RSUI.sch:onCast() else RSUI.sch:Hide() end
      if sol then RSUI.sol:Show(); RSUI.sol:onCast() else RSUI.sol:Hide() end
      if halo then RSUI.halo:Show(); RSUI.halo:onCast() else RSUI.halo:Hide() end 
      if ds then RSUI.ds:Show(); RSUI.ds:onCast() else RSUI.ds:Hide() end 
      if evan then RSUI.evan:Show(); RSUI.evan:onCast(); else RSUI.evan:Hide() end
      if mb then RSUI.mb:Show(); RSUI.mb:onCast(); else RSUI.mb:Hide() end
      if lb then RSUI.lb:Show(); RSUI.lb:onCast(); RSUI.pwb:Hide(); else RSUI.pwb:Show(); RSUI.pwb:onCast(); RSUI.lb:Hide(); end

    end

    local function checkCombat()
        if true then return  end
        if InCombatLockdown() then RSUI.f:Show() else RSUI.f:Hide() end 
    end
    
    local function checkSpecialization()
      
      if GetSpecialization()==1 then 
        RSUI.f:Show() 
        RSUI.f.loaded=true
      else 
        RSUI.f:Hide() 
        RSUI.f.loaded=false
      end
      checkCombat()
    end
    
    local function checkTargetSWP()
      if not UnitExists("target") then return nil end

      local _,_,_,_,d,ext=fabn("Shadow Word: Pain","target","HARMFUL","PLAYER")
      
      if not d then 
        d,ext=select(5,fabn("Purge the Wicked","target","HARMFUL","PLAYER"))  --kind of dirty, should do it with checkTalent() TBA
      end
      
      return d,ext
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
        self.offCD.cd:SetCooldown(t,d)
        self.offCD.t=t
        self.offCD.d=d
        self.offCD.text2:SetText(s)
        afterDo(d, function() self:onCast() end)
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
    local hasteSpells={129250}
    RSUI.eventHandler = function(self,event,_,tar,id,id2)
      if not self.loaded then return end
      if event=="UNIT_HEALTH_FREQUENT" then
        RSUI.health:update()

      elseif event=="UNIT_POWER_UPDATE" then 
        RSUI.mana:update()
                
      elseif event=="UNIT_SPELLCAST_SUCCEEDED" then
       local spell=port[id]
       
       if spell then    
         spell.cast=true         
         afterDo(0,function() spell:onCast();  end)         
       end
       if id==132157 then afterDo(0,function() port[194509]:onCast() end) end --if holy nova then check radiance
      
      elseif event=="UNIT_SPELL_HASTE" then
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

    RSUI.ul=createCDIcon(73685,"big",true)
    RSUI.ul:SetPoint("TOPLEFT",RSUI.f,"TOPLEFT",0,0)
    RSUI.ul.onCast=RSUI.onCast1
    
    RSUI.rip=createCDIcon(61295,"big",true)
    RSUI.rip:SetPoint("LEFT",RSUI.pen,"RIGHT",1,0)
    RSUI.rip.onCast=RSUI.onCastRip
    RSUI.rip.offCD.text2:SetTextColor(green[1],green[2],green[3])

    RSUI.hst=createCDIcon(5394,"med",true)
    RSUI.hst:SetPoint("TOPRIGHT",RSUI.rad,"BOTTOMRIGHT",0,-2-RSUI.bigS)
    RSUI.hst.onCast=RSUI.onCastRip
    RSUI.hst.offCD.text2:SetTextColor(green[1],green[2],green[3])
   
    RSUI.ds=createCDIcon(110744,"med")
    RSUI.ds:SetPoint("TOPRIGHT",RSUI.rad,"BOTTOMRIGHT",0,-2-RSUI.bigS)
    RSUI.ds.onCast=RSUI.onCast1
    
    RSUI.sol=createCDIcon(129250,"big",true)
    RSUI.sol:SetPoint("TOP",RSUI.pen,"BOTTOM",0,-1)
    RSUI.sol.onCast=RSUI.onCast1
   
    RSUI.mb=createCDIcon(123040,"big",true)
    RSUI.mb:SetPoint("TOP",RSUI.pen,"BOTTOM",0,-1)
    RSUI.mb.onCast=RSUI.onCast1
   
    RSUI.sch=createCDIcon(214621,"big",true)
    RSUI.sch:SetPoint("TOP",RSUI.rad,"BOTTOM",0,-1)
    RSUI.sch.onCast=RSUI.onCast1
    
    RSUI.evan=createCDIcon(246287,"med",true)
    RSUI.evan:SetPoint("TOPRIGHT",RSUI.rad,"BOTTOMRIGHT",0,-3-RSUI.bigS-RSUI.medS)
    RSUI.evan.onCast=RSUI.onCast1
    
    RSUI.sdp=createAuraIcon(589,"med")
    RSUI.sdp:SetPoint("TOPLEFT",RSUI.pen,"BOTTOMLEFT",0,-2-RSUI.bigS)
    RSUI.sdp:RegisterUnitEvent("UNIT_AURA","TARGET")
    RSUI.sdp:RegisterEvent("PLAYER_TARGET_CHANGED")
    RSUI.sdp:SetScript("OnEvent",function(self)
      local d,ext=checkTargetSWP()      
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
    RSUI.sdp.normal:SetScript("OnUpdate",function(self,elapsed)
      self.et=self.et+elapsed
      if self.et<0.15 then return end
      self.et=0
      self.text:SetText(mf(self.ext-GetTime()))   
    end)
    
    RSUI.rap=createCDIcon(47536,"med",true)
    RSUI.rap:SetPoint("TOPLEFT",RSUI.pen,"BOTTOMLEFT",0,-3-RSUI.bigS-RSUI.medS)
    RSUI.rap.onCast=RSUI.onCastRap      
    
    RSUI.rapActive=CreateFrame("Frame",nil,RSUI.rap)
    RSUI.rapActive:SetFrameLevel(RSUI.rap:GetFrameLevel()+2)
    RSUI.rap.active=RSUI.rapActive
    RSUI.rapActive:SetAllPoints()
    
    RSUI.rapActive.texture=RSUI.rapActive:CreateTexture(nil,"BACKGROUND")
    RSUI.rapActive.texture:SetAllPoints()
    RSUI.rapActive.texture:SetTexture(237548)
    
    RSUI.rapActive.text=RSUI.rapActive:CreateFontString(nil,"OVERLAY")
    RSUI.rapActive.text:SetFont("Fonts\\FRIZQT__.ttf",RSUI.medFS,"OUTLINE")
    RSUI.rapActive.text:SetTextColor(yellow[1],yellow[2],yellow[3])
    RSUI.rapActive.text:SetText("NA")
    RSUI.rapActive.text:SetPoint("CENTER")
    RSUI.rapActive.et=10
    RSUI.rapActive.ext=GetTime()
    RSUI.rapActive:SetScript("OnUpdate",function(self,elapsed)
      self.et=self.et+elapsed
      if self.et<0.15 then return end
      self.et=0   
      self.text:SetText(math.floor(self.ext-GetTime()))
    end)
    RSUI.rapActive:Hide()

    RSUI.sf=createCDIcon(254224,"med",false)
    RSUI.sf:SetPoint("TOP",RSUI.rap,"BOTTOM",0,-1)
    RSUI.sf.onCast=RSUI.onCast1   
    
    RSUI.pwb=createCDIcon(62618,"med",false)
    RSUI.pwb:SetPoint("TOPRIGHT",RSUI.rad,"BOTTOMRIGHT",0,-4-RSUI.bigS-2*RSUI.medS)
    RSUI.pwb.onCast=RSUI.onCast1   
    RSUI.pwb.onCD.texture:SetTexture(253400)
    RSUI.pwb.offCD.texture:SetTexture(253400)
    
    RSUI.lb=createCDIcon(271466,"med",false)
    RSUI.lb:SetPoint("TOPRIGHT",RSUI.rad,"BOTTOMRIGHT",0,-4-RSUI.bigS-2*RSUI.medS)
    RSUI.lb.onCast=RSUI.onCast1   
    RSUI.lb.onCD.texture:SetTexture(537078)
    RSUI.lb.offCD.texture:SetTexture(537078)

    
    RSUI.lj=createCDIcon(255647,"med",false)
    RSUI.lj:SetPoint("TOP",RSUI.pwb,"BOTTOM",0,-1)
    RSUI.lj.onCast=RSUI.onCast1  
    
    RSUI.pf=createCDIcon(527,"med",true)
    RSUI.pf:SetPoint("TOP",RSUI.sf,"BOTTOM",0,-1)
    RSUI.pf.onCast=RSUI.onCast1  
    
    RSUI.fade=createCDIcon(586,"small",false)
    RSUI.fade:SetPoint("TOPLEFT",RSUI.pf,"BOTTOM",10,-1)
    RSUI.fade.onCast=RSUI.onCast1
    
    RSUI.dp=createCDIcon(19236,"small",false)
    RSUI.dp:SetPoint("LEFT",RSUI.fade,"RIGHT",1,0)
    RSUI.dp.onCast=RSUI.onCast1
    
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
    RSUI.mana:SetPoint("TOPLEFT",RSUI.rad,"BOTTOMLEFT",1,-2-RSUI.bigS)
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
    RSUI.health:SetPoint("TOPRIGHT",RSUI.pen,"BOTTOMRIGHT",-1,-2-RSUI.bigS)
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













