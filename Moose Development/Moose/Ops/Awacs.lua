--- **Ops** - AWACS
--
-- ===
-- 
-- **AWACS** - MOOSE based AI AWACS Fighter Engagement Zone Operations for Players and AI
-- 
-- ===
--
-- ## Example Missions:
-- 
-- ### Demo missions can be found on [github](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/develop/).
--   
-- ===
--
-- ** Main Features: **
--
--  * WIP
--  * References from ARN33396 ATP 3-52.4 (Sep 2021)
--  * References from CNATRA P-877 (Rev. 12-20)
--    
-- ===
-- 
-- ### Author: **applevangelist**
-- Last Update April 2022
--
-- @module Ops.AWACS
-- @image OPS_AWACS.jpg

do
--- Ops AWACS Class
-- @type AWACS
-- @field #string ClassName Name of this class.
-- @field #string version Versioning.
-- @field #string lid LID for log entries.
-- @field #number coalition Colition side.
-- @field #string coalitiontxt e.g."blue"
-- @field Core.Zone#ZONE OpsZone,
-- @field Core.Zone#ZONE StationZone,
-- @field Core.Zone#ZONE BorderZone,
-- @field #number Frequency
-- @field #number Modulation
-- @field Wrapper.Airbase#AIRBASE Airbase
-- @field Ops.AirWing#AIRWING AirWing
-- @field #number AwacsAngels
-- @field Core.Zone#ZONE OrbitZone
-- @field #number CallSign
-- @field #number CallSignNo
-- @field #boolean debug
-- @field #number verbose
-- @field #table ManagedGrps
-- @field #number ManagedGrpID
-- @field #number ManagedTaskID
-- @field Utilities.FiFo#FIFO AnchorStacks
-- @field Utilities.FiFo#FIFO CAPIdleAI
-- @field Utilities.FiFo#FIFO CAPIdleHuman
-- @field Utilities.FiFo#FIFO TaskedCAPAI
-- @field Utilities.FiFo#FIFO TaskedCAPHuman
-- @field Utilities.FiFo#FIFO OpenTasks
-- @field Utilities.FiFo#FIFO ManagedTasks
-- @field Utilities.FiFo#FIFO PictureAO
-- @field Utilities.FiFo#FIFO PictureEWR
-- @field Utilities.FiFo#FIFO Contacts
-- @field #table CatchAllMissions
-- @field #table CatchAllFGs
-- @field #number Countactcounter
-- @field Utilities.FiFo#FIFO ContactsAO
-- @field Utilities.FiFo#FIFO RadioQueue
-- @field Utilities.FiFo#FIFO CAPAirwings
-- @field #number AwacsTimeOnStation
-- @field #number AwacsTimeStamp
-- @field #number EscortsTimeOnStation
-- @field #number EscortsTimeStamp
-- @field #string AwacsROE
-- @field #string AwacsROT
-- @field Ops.Auftrag#AUFTRAG AwacsMission
-- @field Ops.Auftrag#AUFTRAG EscortMission
-- @field Ops.Auftrag#AUFTRAG AwacsMissionReplacement
-- @field Ops.Auftrag#AUFTRAG EscortMissionReplacement
-- @field Utilities.FiFo#FIFO AICAPMissions FIFO for Ops.Auftrag#AUFTRAG for AI CAP
-- @field #boolean MenuStrict
-- @field #number MaxAIonCAP
-- @field #number AIonCAP
-- @field #boolean ShiftChangeAwacsFlag
-- @field #boolean ShiftChangeEscortsFlag
-- @field #boolean ShiftChangeAwacsRequested
-- @field #boolean ShiftChangeEscortsRequested
-- @field #AWACS.MonitoringData MonitoringData
-- @field #boolean MonitoringOn
-- @field Core.Set#SET_GROUP clientset
-- @field Utilities.FiFo#FIFO FlightGroups
-- @field #number PictureInterval Interval in seconds for general picture
-- @field #number PictureTimeStamp Interval timestamp
-- @field #number maxassigndistance Only assing AI/Pilots to targets max this far away
-- @field #boolean PlayerGuidance -- if true additional callouts to guide/warn players
-- @field #boolean ModernEra -- if true we get more intel on targets, and EPLR on the AIC
-- @field #boolean callsignshort -- if true use short (group) callsigns, e.g. "Ghost 1", else "Ghost 1 1"
-- @extends Core.Fsm#FSM

---
--- *Of all men\'s miseries the bitterest is this: to know so much and to have control over nothing.* (Herodotus)
--
-- ===
--
-- 
-- @field #AWACS
AWACS = {
  ClassName = "AWACS", -- #string
  version = "alpha 0.0.10", -- #string
  lid = "", -- #string
  coalition = coalition.side.BLUE, -- #number
  coalitiontxt = "blue", -- #string
  OpsZone = nil,
  StationZone = nil,
  AirWing = nil,
  Frequency = 271, -- #number
  Modulation = radio.modulation.AM, -- #number
  Airbase = nil,
  AwacsAngels = 25, -- orbit at 25'000 ft
  OrbitZone = nil,
  CallSign = CALLSIGN.AWACS.Magic, -- #number
  CallSignNo = 1, -- #number
  debug = true,
  verbose = true,
  ManagedGrps = {},
  ManagedGrpID = 0, -- #number
  ManagedTaskID = 0, -- #number
  AnchorStacks = {}, -- Utilities.FiFo#FIFO
  CAPIdleAI = {},
  CAPIdleHuman = {},
  TaskedCAPAI = {},
  TaskedCAPHuman = {},
  OpenTasks = {}, -- Utilities.FiFo#FIFO
  ManagedTasks = {}, -- Utilities.FiFo#FIFO
  PictureAO = {}, -- Utilities.FiFo#FIFO
  PictureEWR = {}, -- Utilities.FiFo#FIFO
  Contacts = {}, -- Utilities.FiFo#FIFO
  Countactcounter = 0,
  ContactsAO = {}, -- Utilities.FiFo#FIFO
  RadioQueue = {}, -- Utilities.FiFo#FIFO
  AwacsTimeOnStation = 1,
  AwacsTimeStamp = 0,
  EscortsTimeOnStation = 0.5,
  EscortsTimeStamp = 0,
  CAPTimeOnStation = 4,
  AwacsROE = "",
  AwacsROT = "",
  MenuStrict = true,
  MaxAIonCAP = 3,
  AIonCAP = 0,
  AICAPMissions = {}, -- Utilities.FiFo#FIFO
  ShiftChangeAwacsFlag = false,
  ShiftChangeEscortsFlag = false,
  ShiftChangeAwacsRequested = false,
  ShiftChangeEscortsRequested = false,
  CAPAirwings = {},  -- Utilities.FiFo#FIFO
  MonitoringData = {},
  MonitoringOn = false,
  FlightGroups = {},
  AwacsMission = nil,
  AwacsInZone = false, -- not yet arrived or gone again
  AwacsReady = false,
  CatchAllMissions = {},
  CatchAllFGs = {},
  PictureInterval = 300,
  PictureTimeStamp = 0,
  BorderZone = nil,
  maxassigndistance = 80,
  PlayerGuidance = true,
  ModernEra = true,
  callsignshort = true,
}

---
--@field CallSignClear
AWACS.CallSignClear = {
    [1]="Overlord",
    [2]="Magic",
    [3]="Wizard",
    [4]="Focus",
    [5]="Darkstar",
}

---
-- @field AnchorNames
AWACS.AnchorNames = {
  [1] = "One",
  [2] = "Two",
  [3] = "Three",
  [4] = "Four",
  [5] = "Five",
  [6] = "Six",
  [7] = "Seven",
  [8] = "Eight",
  [9] = "Nine",
  [10] = "Ten",
}

---
-- @field IFF
AWACS.IFF =
{
  SPADES = "Spades",
  NEUTRAL = "Neutral",
  FRIENDLY = "Friendly",
  ENEMY = "Enemy",
}

---
-- @field Phonetic
AWACS.Phonetic =
{
  [1] = 'Alpha',
  [2] = 'Bravo',
  [3] = 'Charlie',
  [4] = 'Delta',
  [5] = 'Echo',
  [6] = 'Foxtrot',
  [7] = 'Golf',
  [8] = 'Hotel',
  [9] = 'India',
  [10] = 'Juliett',
  [11] = 'Kilo',
  [12] = 'Lima',
  [13] = 'Mike',
  [14] = 'November',
  [15] = 'Oscar',
  [16] = 'Papa',
  [17] = 'Quebec',
  [18] = 'Romeo',
  [19] = 'Sierra',
  [20] = 'Tango',
  [21] = 'Uniform',
  [22] = 'Victor',
  [23] = 'Whiskey',
  [24] = 'Xray',
  [25] = 'Yankee',
  [26] = 'Zulu',
}

---
-- @field Shipsize
AWACS.Shipsize =
{
  [1] = "Singleton",
  [2] = "Two-Ship",
  [3] = "Heavy",
}

---
-- @field ROE
AWACS.ROE = {
  POLICE = "Police",
  VID = "Visual ID",
  IFF = "IFF",
  BVR = "Beyond Visual Range",
}

---
-- @field AWACS.ROT
AWACS.ROT = {
    PASSIVE = "Passive Defense",
    ACTIVE = "Active Defense",
    LOCK = "Lock",
    RETURNFIRE = "Return Fire",
    OPENFIRE = "Open Fire",
 }
 
---
--@field THREATLEVEL -- can be 1-10, thresholds
AWACS.THREATLEVEL = {
  GREEN = 3,
  AMBER = 7,
  RED = 10,
}

---
-- @type AWACS.MonitoringData
-- @field #string AwacsStateMission
-- @field #string AwacsStateFG
-- @field #boolean AwacsShiftChange 
-- @field #string EscortsStateMission
-- @field #string EscortsStateFG
-- @field #boolean EscortsShiftChange
-- @field #number AICAPMax
-- @field #number AICAPCurrent
-- @field #number Airwings
-- @field #number Players
-- @field #number PlayersCheckedin

---
-- @type AWACS.MenuStructure
-- @field #boolean menuset
-- @field #string groupname
-- @field Core.Menu#MENU_GROUP_DELAYED basemenu
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED checkin
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED checkout
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED picture
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED bogeydope
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED declare
-- @field Core.Menu#MENU_GROUP_DELAYED tasking
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED showtask
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED judy
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED unable
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED abort
-- @field Core.Menu#MENU_GROUP_COMMAND_DELAYED commit

---
-- @type AWACS.ManagedGroup
-- @field Wrapper.Group#GROUP Group
-- @field #string GroupName
-- @field Ops.FlightGroup#FLIGHTGROUP FlightGroup for AI
-- @field #boolean IsPlayer
-- @field #boolean IsAI
-- @field #string CallSign
-- @field #number CurrentAuftrag -- Auftragsnummer for AI
-- @field #number CurrentTask -- ManagedTask ID
-- @field #boolean HasAssignedTask
-- @field #number GID
-- @field #number AnchorStackNo
-- @field #number AnchorStackAngels
-- @field #number ContactCID
-- @field Ultilities.FiFo#FIFO TaskQueue

--- Contact Data
-- @type AWACS.ManagedContact
-- @field #number CID
-- @field Ops.Intelligence#INTEL.Contact Contact
-- @field Ops.Intelligence#INTEL.Cluster Cluster
-- @field #string IFF -- ID'ed or not
-- @field Ops.Target#TARGET Target
-- @field #number LinkedTask --> TID
-- @field #number LinkedGroup --> GID
-- @field #string Status - #AWACS.TaskStatus
-- @field #string TargetGroupNaming
-- @field #string EngagementTag

---
-- @type AWACS.TaskDescription
AWACS.TaskDescription = {
  ANCHOR = "Anchor",
  REANCHOR = "Re-Anchor",
  VID = "VID",
  IFF = "IFF",
  INTERCEPT = "Intercept",
  SWEEP = "Sweep",
  RTB = "RTB",
}

---
-- @type AWACS.TaskStatus
AWACS.TaskStatus = {
  IDLE = "Idle",
  UNASSIGNED = "Unassigned",
  REQUESTED = "Requested",
  ASSIGNED = "Assigned",
  EXECUTING = "Executing",
  SUCCESS = "Success",
  FAILED = "Failed",
  DEAD = "Dead",
}

---
-- @type AWACS.ManagedTask
-- @field #number TID
-- @field #number AssignedGroupID
-- @field #boolean IsPlayerTask
-- @field #boolean IsUnassigned
-- @field Ops.Target#TARGET Target
-- @field Ops.Auftrag#AUFTRAG Auftrag
-- @field #AWACS.TaskStatus Status
-- @field #AWACS.TaskDescription ToDo
-- @field #string ScreenText Long descrition
-- @field Ops.Intelligence#INTEL.Contact Contact
-- @field Ops.Intelligence#INTEL.Cluster Cluster
-- @field #number CurrentAuftrag

---
-- @type AWACS.AnchorAssignedEntry
-- @field #number ID
-- @field #number Angels

---
-- @type AWACS.AnchorData
-- @field #number AnchorBaseAngels
-- @field Core.Zone#ZONE_RADIUS StationZone
-- @field Core.Point#COORDINATE StationZoneCoordinate
-- @field #string StationZoneCoordinateText
-- @field #string StationName
-- @field Utilities.FiFo#FIFO AnchorAssignedID FiFo of #AWACS.AnchorAssignedEntry
-- @field Utilities.FiFo#FIFO Anchors FiFo of available stacks
-- @field Wrapper.Marker#MARKER AnchorMarker Tag for this station

---
--@type RadioEntry
--@field #string TextTTS
--@field #string TextScreen
--@field #boolean IsNew
--@field #boolean IsGroup
--@field #boolean GroupID
--@field #number Duration
--@field #boolean ToScreen
--@field #boolean FromAI

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TODO-List 0.0.10
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- TODO - System for Players to VID contacts? And put data into contacst fifo
-- TODO - TripWire - Threat (35nm), Meld (45nm, on mission), Merged (<3nm)
--
-- TODO - Player tasking
-- TODO - Localization
-- TODO - (LOW) LotATC / IFF
-- 
-- TODO - SW Optimizer
-- 
-- DEBUG - (WIP) Missile launch callout
-- DEBUG - Event detection, Player joining, eject, crash, dead, leaving; AI shot -> DEFEND
-- DEBUG - AI Tasking
-- DEBUG - Multiple AIRWING connection? Can't really get recruit to work, switched to random round robin
-- DEBUG - Shift Change, Change on asset RTB or dead or mission done (done for AWACS and Escorts)
--
-- DONE - Escorts via AirWing not staying on
-- DONE - Borders for INTEL. Optional, i.e. land based defense within borders
-- DONE - Use AO as Anchor of Bulls, AO as default
-- DONE - SRS TTS output
-- DONE - Check-In/Out Humans
-- DONE - Check-In/Out AI
-- DONE - Picture
-- DONE - Declare
-- DONE - Bogey Dope
-- DONE - Radio Menu
-- DONE - Intel Detection
-- DONE - ROE
-- DONE - Anchor Stack Management
-- DONE - Shift Length AWACS/AI
-- DONE - (WIP) Reporting

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constructor
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TODO Constructor

--- Set up a new AI AWACS.
-- @param #AWACS self
-- @param #string Name Name of this AWACS for the radio menu.
-- @param #string AirWing The core Ops.AirWing#AIRWING managing the AWACS, Escort and (optionally) AI CAP planes for us.
-- @param #number Coalition Coalition, e.g. coalition.side.BLUE. Can also be passed as "blue", "red" or "neutral".
-- @param #string AirbaseName Name of the home airbase.
-- @param #string AwacsOrbit Name of the round, mission editor created zone where this AWACS orbits.
-- @param #string OpsZone Name of the round, mission editor created Fighter Engagement operations zone (FEZ) this AWACS controls. Can be passed as #ZONE_POLYGON. 
-- Will be used in referenc call, ensure a radio friendly name that does not collide with NATOPS keywords.
-- @param #string StationZone Name of the round, mission editor created anchor zone where CAP groups will be stationed. Usually a short city name.
-- @param #number Frequency Radio frequency, e.g. 271.
-- @param #number Modulation Radio modulation, e.g. radio.modulation.AM or radio.modulation.FM.
-- @return #AWACS self
function AWACS:New(Name,AirWing,Coalition,AirbaseName,AwacsOrbit,OpsZone,StationZone,Frequency,Modulation)
    -- Inherit everything from FSM class.
  local self=BASE:Inherit(self, FSM:New())
  
  --set Coalition
  if Coalition and type(Coalition)=="string" then
    if Coalition=="blue" then
      self.coalition=coalition.side.BLUE
      self.coalitiontxt = Coalition
    elseif Coalition=="red" then
      self.coalition=coalition.side.RED
      self.coalitiontxt = Coalition
    elseif Coalition=="neutral" then
      self.coalition=coalition.side.NEUTRAL
      self.coalitiontxt = Coalition
    else
      self:E("ERROR: Unknown coalition in AWACS!")
    end
  else
    self.coalition = Coalition
    self.coalitiontxt = string.lower(UTILS.GetCoalitionName(self.coalition))
  end
  
  -- base setup
  self.Name = Name -- #string
  self.AirWing = AirWing -- Ops.AirWing#AIRWING object
  
  AirWing:SetUsingOpsAwacs(self)
  
  self.CAPAirwings = FIFO:New() -- Utilities.FiFo#FIFO
  self.CAPAirwings:Push(AirWing,1)
  
  self.AwacsFG = nil
  --self.AwacsPayload = PayLoad -- Ops.AirWing#AIRWING.Payload
  --self.ModernEra = true -- use of EPLRS
  self.RadarBlur = 10 -- 10% detection precision i.e. 90-110 reported group size
  if type(OpsZone) == "string" then
    self.OpsZone = ZONE:New(OpsZone) -- Core.Zone#ZONE
  elseif type(OpsZone) == "table" and OpsZone.ClassName and OpsZone.ClassName == "ZONE_POLYGON" then
    self.OpsZone = OpsZone
  else
    self:E("AWACS - Invalid OpsZone passed!")
    return
  end
  
  self.AOCoordinate = self.OpsZone:GetCoordinate()
  self.AOName = self.OpsZone:GetName()
  self.UseBullsAO = false -- as per NATOPS
  self.ControlZoneRadius = 100 -- nm
  self.StationZone = ZONE:New(StationZone) -- Core.Zone#ZONE
  self.Frequency = Frequency or 271 -- #number
  self.Modulation = Modulation or radio.modulation.AM
  self.Airbase = AIRBASE:FindByName(AirbaseName)
  self.AwacsAngels = 25 -- orbit at 25'000 ft
  self.OrbitZone = ZONE:New(AwacsOrbit) -- Core.Zone#ZONE
  self.BorderZone = nil
  self.CallSign = CALLSIGN.AWACS.Darkstar -- #number
  self.CallSignNo = 1 -- #number
  self.NoHelos = true
  self.MaxAIonCAP = 4
  self.AIRequested = 0
  self.AIonCAP = 0
  self.AICAPMissions = FIFO:New() -- Utilities.FiFo#FIFO
  self.FlightGroups = FIFO:New() -- Utilities.FiFo#FIFO
  self.Countactcounter = 0
  
  self.PictureInterval = 300 -- picture every 5s mins
  self.PictureTimeStamp = 0 -- timestamp
  
  self.intelstarted = false
  
  local speed = 250
  self.SpeedBase = speed
  self.Speed = UTILS.KnotsToAltKIAS(speed,self.AwacsAngels*1000)
  self.CapSpeedBase = 220
  self.Heading = 0 -- north
  self.Leg = 50 -- nm
  self.invisible = false
  self.immortal = false
  self.callsigntxt = "AWACS"
  self.maxassigndistance = 80 --nm
  
  self.AwacsTimeOnStation = 2
  self.AwacsTimeStamp = 0
  self.EscortsTimeOnStation = 2
  self.EscortsTimeStamp = 0
  self.ShiftChangeTime = 0.25 -- 15mins
  self.ShiftChangeAwacsFlag = false
  self.ShiftChangeEscortsFlag = false
  self.CAPTimeOnStation = 4
  
  self.DeclareRadius = 5 -- NM
  
  self.AwacsMission = nil
  self.AwacsInZone = false -- not yet arrived or gone again
  self.AwacsReady = false
  
  self.AwacsROE = AWACS.ROE.POLICE
  self.AwacsROT = AWACS.ROT.PASSIVE
  
  self.MenuStrict = true
  
  -- Escorts
  self.HasEscorts = false
  self.EscortTemplate = ""
  
  -- SRS
  self.PathToSRS = "C:\\Program Files\\DCS-SimpleRadio-Standalone"
  self.Gender = "male"
  self.Culture = "en-US"
  self.Voice = nil
  self.Port = 5002
  self.RadioQueue = FIFO:New() -- Utilities.FiFo#FIFO
  self.maxspeakentries = 3
  
  self.CAPGender = "male"
  self.CAPCulture = "en-US"
  self.CAPVoice = nil
  
  -- Client SET  
  self.clientset = SET_GROUP:New():FilterCategoryAirplane():FilterCoalitions(self.coalitiontxt):FilterStart()
  self.PlayerGuidance = true
  self.ModernEra = true
  
  -- managed groups
  self.ManagedGrps = {} -- #table of #AWACS.ManagedGroup entries
  self.ManagedGrpID = 0  
  
  self.AICAPCAllName = CALLSIGN.Aircraft.Dodge
  self.AICAPCAllNumber = 0
  
  -- Anchor stacks init
  self.AnchorStacks = FIFO:New() -- Utilities.FiFo#FIFO
  self.AnchorBaseAngels = 22
  self.AnchorStackDistance = 2
  self.AnchorMaxStacks = 4
  self.AnchorMaxAnchors = 2
  self.AnchorMaxZones = 6
  self.AnchorCurrZones = 1
  self.AnchorTurn = -(360/self.AnchorMaxZones)

  self:_CreateAnchorStack()

  -- Task lists
  self.ManagedTasks = FIFO:New() -- Utilities.FiFo#FIFO
  --self.OpenTasks = FIFO:New() -- Utilities.FiFo#FIFO
  
  -- Monitoring, init
  local MonitoringData = {} -- #AWACS.MonitoringData
  MonitoringData.AICAPCurrent = 0
  MonitoringData.AICAPMax = self.MaxAIonCAP
  MonitoringData.Airwings = 1
  MonitoringData.PlayersCheckedin = 0
  MonitoringData.Players = 0 
  MonitoringData.AwacsShiftChange = false
  MonitoringData.AwacsStateFG = "unknown"
  MonitoringData.AwacsStateMission = "unknown"
  MonitoringData.EscortsShiftChange = false
  MonitoringData.EscortsStateFG= "unknown"
  MonitoringData.EscortsStateMission = "unknown"
  self.MonitoringOn = false -- #boolean
  self.MonitoringData = MonitoringData
  
  self.CatchAllMissions = {}
  self.CatchAllFGs = {}
  
  -- Picture, Contacts, Bogeys
  self.PictureAO = FIFO:New() -- Utilities.FiFo#FIFO
  self.PictureEWR = FIFO:New() -- Utilities.FiFo#FIFO
  self.Contacts = FIFO:New() -- Utilities.FiFo#FIFO
  --self.ManagedContacts = FIFO:New()
  self.CID = 0
  self.ContactsAO = FIFO:New() -- Utilities.FiFo#FIFO

  -- SET for Intel Detection
  self.DetectionSet=SET_GROUP:New()
  
  -- Set some string id for output to DCS.log file.
  self.lid=string.format("%s (%s) | ", self.Name, self.coalition and UTILS.GetCoalitionName(self.coalition) or "unknown")
  
    -- Start State.
  self:SetStartState("Stopped")
  
  -- Add FSM transitions.
  --                 From State  -->   Event        -->     To State
  self:AddTransition("Stopped",       "Start",              "StartUp")     -- Start FSM.
  self:AddTransition("StartUp",       "Started",            "Running")    
  self:AddTransition("*",             "Status",             "*")           -- Status update.
  self:AddTransition("*",             "CheckedIn",          "*") 
  self:AddTransition("*",             "CheckedOut",         "*") 
  self:AddTransition("*",             "AssignAnchor",       "*") 
  self:AddTransition("*",             "AssignedAnchor",     "*")
  self:AddTransition("*",             "ReAnchor",           "*")
  self:AddTransition("*",             "NewCluster",         "*")
  self:AddTransition("*",             "NewContact",         "*")
  self:AddTransition("*",             "LostCluster",        "*")
  self:AddTransition("*",             "LostContact",        "*")
  self:AddTransition("*",             "CheckRadioQueue",    "*")
  self:AddTransition("*",             "EscortShiftChange",  "*")
  self:AddTransition("*",             "AwacsShiftChange",   "*")
  self:AddTransition("*",             "FlightOnMission",    "*")
  self:AddTransition("*",             "Intercept",          "*")
  self:AddTransition("*",             "InterceptSuccess",   "*")
  self:AddTransition("*",             "InterceptFailure",   "*")
  --
  self:AddTransition("*",             "Stop",               "Stopped")     -- Stop FSM.
  
  -- self:__Start(math.random(2,5))
  
  local text = string.format("%sAWACS Version %s Initiated",self.lid,self.version)
  
  self:I(text)
  
  -- debug zone markers
  if self.debug then
    self.OpsZone:DrawZone(-1,{1,0,0},1,{1,0,0},0.2,5,true)
    local Rocktag = string.format("FEZ: %s\nCoordinate: %s",self.AOName,self.OpsZone:GetCoordinate():ToStringLLDDM())
    MARKER:New(self.OpsZone:GetCoordinate(),Rocktag):ToAll()
    self.StationZone:DrawZone(-1,{0,0,1},1,{0,0,1},0.2,5,true)
    local stationtag = string.format("Station: %s\nCoordinate: %s",StationZone,self.StationZone:GetCoordinate():ToStringLLDDM())
    MARKER:New(self.StationZone:GetCoordinate(),stationtag):ToAll()
    self.OrbitZone:DrawZone(-1,{0,1,0},1,{0,1,0},0.2,5,true)
    MARKER:New(self.OrbitZone:GetCoordinate(),"AIC Orbit Zone"):ToAll()
  end
  
  -- Events
  -- Player joins
  self:HandleEvent(EVENTS.PlayerEnterAircraft, self._EventHandler)
  self:HandleEvent(EVENTS.PlayerEnterUnit, self._EventHandler)
    -- Player leaves
  self:HandleEvent(EVENTS.PlayerLeaveUnit, self._EventHandler)
  self:HandleEvent(EVENTS.Ejection, self._EventHandler)
  self:HandleEvent(EVENTS.Crash, self._EventHandler)
  self:HandleEvent(EVENTS.Dead, self._EventHandler)
  self:HandleEvent(EVENTS.PilotDead, self._EventHandler)
  -- Missile warning
  self:HandleEvent(EVENTS.Shot, self._EventHandler)
  
  return self
end

-- TODO Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- [Internal] Event handler
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group, can also be passed as #string group name
-- @return #boolean found
-- @return #number GID
-- @return #string CallSign
function AWACS:_GetGIDFromGroupOrName(Group)
  local GID = 0
  local Outcome = false
  local CallSign = "Ghost 1"
  local nametocheck = CallSign
  if Group and type(Group) == "string" then
    nametocheck = Group
  elseif Group and Group:IsInstanceOf("GROUP") then
    nametocheck = Group:GetName()
  else
    return false, 0, CallSign
  end

  local managedgrps = self.ManagedGrps or {}
  for _,_managed in pairs (managedgrps) do
    local managed = _managed -- #AWACS.ManagedGroup
    if managed.GroupName == nametocheck then
      GID = managed.GID
      Outcome = true
      CallSign = managed.CallSign
    end
  end
  return Outcome, GID, CallSign
end

--- [Internal] Event handler
-- @param #AWACS self
-- @param Core.Event#EVENTDATA EventData
-- @return #AWACS self
function AWACS:_EventHandler(EventData)
  self:I(self.lid.."_EventHandler")
  self:T({Event = EventData.id})
  
  local Event = EventData -- Core.Event#EVENTDATA
  
  if Event.id == EVENTS.PlayerEnterAircraft or Event.id == EVENTS.PlayerEnterUnit then --player entered unit
    --self:I("Player enter unit: " .. Event.IniPlayerName)
    --self:I("Coalition = " .. UTILS.GetCoalitionName(Event.IniCoalition))
    if Event.IniCoalition == self.coalition then
      self:_SetClientMenus()
    end
  end
  
  if Event.id == EVENTS.PlayerLeaveUnit then --player left unit
    -- check known player?
    --self:I("Player group left  unit: " .. Event.IniGroupName)
    --self:I("Player name left: " .. Event.IniPlayerName)
    --self:I("Coalition = " .. UTILS.GetCoalitionName(Event.IniCoalition))
    if Event.IniCoalition == self.coalition then
      local Outcome, GID, CallSign = self:_GetGIDFromGroupOrName(Event.IniGroupName)
      if Outcome and GID > 0 then
        self:_CheckOut(nil,GID,true)
      end
    end
  end
  
  if Event.id == EVENTS.Ejection or Event.id == EVENTS.Crash or Event.id == EVENTS.Dead or Event.id == EVENTS.PilotDead then --unit or player dead
    -- check known group?
    if Event.IniCoalition == self.coalition then
      --self:I("Ejection/Crash/Dead/PilotDead Group: " .. Event.IniGroupName)
      --self:I("Coalition = " .. UTILS.GetCoalitionName(Event.IniCoalition))
      local Outcome, GID, CallSign = self:_GetGIDFromGroupOrName(Event.IniGroupName)
      if Outcome and GID > 0 then
        self:_CheckOut(nil,GID,true)
      end
    end
  end
  
  if Event.id == EVENTS.Shot and self.PlayerGuidance then
    if Event.IniCoalition ~= self.coalition then
      self:I("Shot from: " .. Event.IniGroupName)
      local position = Event.IniGroup:GetCoordinate()
      --self:I("Coalition = " .. UTILS.GetCoalitionName(Event.IniCoalition))
      -- Check missile type
      local Category = Event.WeaponCategory
      local WeaponDesc = EventData.Weapon:getDesc() -- https://wiki.hoggitworld.com/view/DCS_enum_weapon
      self:I({WeaponDesc})
      --self:I("Weapon = " .. tostring(WeaponDesc.displayName))
      if WeaponDesc.category == 1 and (WeaponDesc.missileCategory == 1 or WeaponDesc.missileCategory == 2) then
        self:I("AAM or SAM Missile fired")
        -- Missile fired
        -- WIP Missile Callouts
        local warndist = 25
        local Type = "SAM"
        if WeaponDesc.category == 1 then
          Type = "Missile"
          -- AAM  
          local guidance = WeaponDesc.guidance -- IR=2, Radar Active=3, Radar Semi Active=4, Radar Passive = 5
          if guidance == 2 then
            warndist = 10
          elseif guidance == 3 then
            warndist = 25
          elseif guidance == 4 then
            warndist = 15
          elseif guidance == 5 then
            warndist = 10
          end -- guidance
        end -- cat 1
        self:_MissileWarning(position,Type,warndist)
      end -- cat 1 or 2
      
    end -- end coalition
  end -- end shot
  
  return self
end

--- [Internal] Missile Warning Callout
-- @param #AWACS self
-- @param Core.Point#COORDINATE Coordinate Where the shot happened
-- @param #string Type Type to call out, e.i. "SAM" or "Missile"
-- @param #number Warndist Distance in NM to find friendly planes
-- @return #AWACS self
function AWACS:_MissileWarning(Coordinate,Type,Warndist)
  self:I(self.lid.."_MissileWarning Type="..Type.." WarnDist="..Warndist)
  local shotzone = ZONE_RADIUS:New("WarningZone",Coordinate:GetVec2(),UTILS.NMToMeters(Warndist))
  local targetgrpset = SET_GROUP:New():FilterCoalitions(self.coalitiontxt):FilterCategoryAirplane():FilterActive():FilterZones({shotzone}):FilterOnce()
  if targetgrpset:Count() > 0 then
    local targets = targetgrpset:GetSetObjects()
    for _,_grp in pairs (targets) do
      -- TODO - player callouts only
      if _grp and _grp:IsAlive() then
        local isPlayer = _grp:GetUnit(1):IsPlayer()
        if self.debug or isPlayer then
          local callsign = self:_GetCallSign(_grp)
          local text = string.format("%s, %s! %s! %s! Defend!",callsign,Type,Type,Type)
          local RadioEntry = {} -- #AWACS.RadioEntry
          RadioEntry.IsNew = true
          RadioEntry.TextTTS = text
          RadioEntry.TextScreen = text
          RadioEntry.GroupID = 0
          RadioEntry.ToScreen = self.debug 
          RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8 
          self.RadioQueue:Push(RadioEntry)
        end
      end
    end
  end
  return self
end

--- [User] Get AWACS Name
-- @param #AWACS self
-- @return #string Name of this instance
function AWACS:GetName()
  return self.Name or "not set"
end

--- [User] Set Border Zone
-- @param #AWACS self
-- @param Core.Zone#ZONE Zone
-- @return #AWACS self
function AWACS:SetBorderZone(Zone)
  self:T(self.lid.."SetBorderZone")
  self.BorderZone = Zone
  if self.debug then
    Zone:DrawZone(-1,{1,0.64,0},1,{1,0.64,0},0.2,1,true)
    MARKER:New(Zone:GetCoordinate(),"Border Zone"):ToAll()
  end
  return self
end

--- [User] Set AWACS flight details
-- @param #AWACS self
-- @param #number CallSign Defaults to CALLSIGN.AWACS.Magic
-- @param #number CallSignNo Defaults to 1
-- @param #number Angels Defaults to 25 (i.e. 25000 ft)
-- @param #number Speed Defaults to 250kn
-- @param #number Heading Defaults to 0 (North)
-- @param #number Leg Defaults to 25nm
-- @return #AWACS self
function AWACS:SetAwacsDetails(CallSign,CallSignNo,Angels,Speed,Heading,Leg)
  self:T(self.lid.."SetAwacsDetails")
  self.CallSign = CallSign or CALLSIGN.AWACS.Magic
  self.CallSignNo = CallSignNo or 1
  self.Angels = Angels or 25
  local speed = Speed or 250
  self.SpeedBase = speed
  self.Speed = UTILS.KnotsToAltKIAS(speed,self.Angels*1000)
  self.Heading = Heading or 0
  self.Leg = Leg or 25
  return self
end

--- [User] Add a radar GROUP object to the INTEL detection SET_GROUP
-- @param Wrapper.Group#GROUP Group The GROUP to be added. Can be passed as SET_GROUP.
-- @return #AWACS self
function AWACS:AddGroupToDetection(Group)
  self:T(self.lid.."AddGroupToDetection")
  if Group and Group.ClassName and Group.ClassName == "GROUP" then
    self.DetectionSet:AddGroup(Group)
  elseif Group and Group.ClassName and Group.ClassName == "SET_GROUP" then
    self.DetectionSet:AddSet(Group)
  end
  return self
end

--- [User] Set AWACS SRS TTS details - see @{#MSRS} for details
-- @param #AWACS self
-- @param #string PathToSRS Defaults to "C:\\Program Files\\DCS-SimpleRadio-Standalone"
-- @param #string Gender Defaults to "male"
-- @param #string Culture Defaults to "en-US"
-- @param #number Port Defaults to 5002
-- @param #string Voice (Optional) Use a specifc voice with the @{#MSRS.SetVoice} function, e.g, `:SetVoice("Microsoft Hedda Desktop")`.
-- Note that this must be installed on your windows system.
-- @return #AWACS self
function AWACS:SetSRS(PathToSRS,Gender,Culture,Port,Voice)
  self:T(self.lid.."SetSRS")
  self.PathToSRS = PathToSRS or "C:\\Program Files\\DCS-SimpleRadio-Standalone"
  self.Gender = Gender or "male"
  self.Culture = Culture or "en-US"
  self.Port = Port or 5002
  self.Voice = Voice 
  return self
end

--- [User] Set AWACS Escorts Template
-- @param #AWACS self
-- @param #number EscortNumber Number of fighther planes to accompany this AWACS. 0 or nil means no escorts.
-- @return #AWACS self
function AWACS:SetEscort(EscortNumber)
  self:T(self.lid.."SetEscort")
  if EscortNumber and EscortNumber > 0 then
    self.HasEscorts = true
    self.EscortNumber = EscortNumber
  end
  return self
end

--- [Internal] Message a vector BR to a position
-- @param #AWACS self
-- @param #number GID Group GID
-- @param #string Tag (optional) Text to add after Vector, e.g. " to Anchor" - NOTE the leading space
-- @param Core.Point#COORDINATE Coordinate The Coordinate to use
-- @param #number Angels (Optional) Add Angels 
-- @return #AWACS self
function AWACS:_MessageVector(GID,Tag,Coordinate,Angels)
  self:I(self.lid.."_MessageVector")
  
  local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
  local Tag = Tag or ""
  
  if managedgroup and Coordinate then
    
    local tocallsign = managedgroup.CallSign or "Ghost 1"
    local group = managedgroup.Group
    local groupposition = group:GetCoordinate()
    
    local BRtext = Coordinate:ToStringBR(groupposition)
    
    local text = string.format("%s, %s. Vector%s %s",tocallsign, self.callsigntxt,Tag,BRtext)
    local textScreen = string.format("%s, %s, Vector%s %s",tocallsign, self.callsigntxt,Tag,BRtext)
    
    if Angels then
      text = text .. ". Angels "..tostring(Angels).."."
      textScreen = textScreen .. ". Angels "..tostring(Angels).."."
    end
    
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = textScreen
    RadioEntry.GroupID = 0
    RadioEntry.ToScreen = self.debug 
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8 
    self.RadioQueue:Push(RadioEntry)
  
  end
  
  return self
end

--- [Internal] Start AWACS Escorts FlightGroup
-- @param #AWACS self
-- @param #boolean Shiftchange This is a shift change call
-- @return #AWACS self
function AWACS:_StartEscorts(Shiftchange)
  self:T(self.lid.."_StartEscorts")
  
  local AwacsFG = self.AwacsFG -- Ops.FlightGroup#FLIGHTGROUP
  local group = AwacsFG:GetGroup()
  local mission = AUFTRAG:NewESCORT(group,{x=-100, y=0, z=200},45,{"Air"})
  self.CatchAllMissions[#self.CatchAllMissions+1] = mission
  
  mission:SetRequiredAssets(self.EscortNumber)
  
  local timeonstation = (self.EscortsTimeOnStation + self.ShiftChangeTime) * 3600 -- hours to seconds
  mission:SetTime(nil,timeonstation)
  
  self.AirWing:AddMission(mission)
  
  if Shiftchange then
    self.EscortMissionReplacement = mission
  else
    self.EscortMission = mission
  end
  
  return self
end

--- [Internal] AWACS further Start Settings
-- @param #AWACS self
-- @param Ops.FlightGroup#FLIGHTGROUP FlightGroup
-- @param Ops.Auftrag#AUFTRAG Mission
-- @return #AWACS self
function AWACS:_StartSettings(FlightGroup,Mission)
  self:T(self.lid.."_StartSettings")
  
  local Mission = Mission -- Ops.Auftrag#AUFTRAG
  local AwacsFG = FlightGroup -- Ops.FlightGroup#FLIGHTGROUP
  
  -- Is this our Awacs mission?
  if self.AwacsMission:GetName() == Mission:GetName() then
    self:T("Setting up Awacs")
    AwacsFG:SetDefaultRadio(self.Frequency,self.Modulation,false)
    AwacsFG:SwitchRadio(self.Frequency,self.Modulation)
    AwacsFG:SetDefaultAltitude(self.AwacsAngels*1000)
    AwacsFG:SetHomebase(self.Airbase)
    AwacsFG:SetDefaultCallsign(self.CallSign,self.CallSignNo)
    AwacsFG:SetDefaultROE(ENUMS.ROE.WeaponHold)
    AwacsFG:SetDefaultAlarmstate(AI.Option.Ground.val.ALARM_STATE.GREEN)
    AwacsFG:SetDefaultEPLRS(self.ModernEra)
    AwacsFG:SetDespawnAfterLanding()
    AwacsFG:SetFuelLowRTB(true)
    AwacsFG:SetFuelLowThreshold(20)
    
    local group = AwacsFG:GetGroup() -- Wrapper.Group#GROUP
    
    group:SetCommandInvisible(self.invisible)
    group:SetCommandImmortal(self.immortal)
    group:CommandSetCallsign(self.CallSign,self.CallSignNo,2)
    -- Non AWACS does not seem take AWACS CS in DCS Group
    --group:CommandSetCallsign(CALLSIGN.Aircraft.Pig,self.CallSignNo,2)
    
    AwacsFG:SetSRS(self.PathToSRS,self.Gender,self.Culture,self.Voice,self.Port,nil,"AWACS")
    --self.callsigntxt = string.format("%s %d %d",AWACS.CallSignClear[self.CallSign],1,self.CallSignNo)
    self.callsigntxt = string.format("%s",AWACS.CallSignClear[self.CallSign])
    --local text = string.format("%s starting for AO %s control.",self.callsigntxt,self.AOName or "AO")
    local text = string.format("%s. All stations, SUNRISE SUNRISE SUNRISE, %s.",self.callsigntxt,self.callsigntxt)
    self:T(self.lid..text)
    
    AwacsFG:RadioTransmission(text,1,false)
    
    self.AwacsFG = AwacsFG 
    
    self:__CheckRadioQueue(10)
    
    if self.HasEscorts then
      --mission:SetRequiredEscorts(self.EscortNumber)
      self:_StartEscorts()
    end
    
    self.AwacsTimeStamp = timer.getTime()
    self.EscortsTimeStamp = timer.getTime()

    self.PictureTimeStamp = timer.getTime() + 10*60
    
    self.AwacsReady = true
    -- set FSM to started
    self:Started()
    
  elseif self.ShiftChangeAwacsRequested and self.AwacsMissionReplacement and self.AwacsMissionReplacement:GetName() == Mission:GetName() then
    self:I("Setting up Awacs Replacement")
    -- manage AWACS Replacement
    AwacsFG:SetDefaultRadio(self.Frequency,self.Modulation,false)
    AwacsFG:SwitchRadio(self.Frequency,self.Modulation)
    AwacsFG:SetDefaultAltitude(self.AwacsAngels*1000)
    AwacsFG:SetHomebase(self.Airbase)
    self.CallSignNo = self.CallSignNo+1
    AwacsFG:SetDefaultCallsign(self.CallSign,self.CallSignNo)
    AwacsFG:SetDefaultROE(ENUMS.ROE.WeaponHold)
    AwacsFG:SetDefaultAlarmstate(AI.Option.Ground.val.ALARM_STATE.GREEN)
    AwacsFG:SetDefaultEPLRS(self.ModernEra)
    AwacsFG:SetDespawnAfterLanding()
    AwacsFG:SetFuelLowRTB(true)
    AwacsFG:SetFuelLowThreshold(20)
    
    local group = AwacsFG:GetGroup() -- Wrapper.Group#GROUP
    
    group:SetCommandInvisible(self.invisible)
    group:SetCommandImmortal(self.immortal)
    group:CommandSetCallsign(self.CallSign,self.CallSignNo,2)
    -- Non AWACS does not seem take AWACS CS in DCS Group
    -- group:CommandSetCallsign(CALLSIGN.Aircraft.Pig,self.CallSignNo,2)
    
    AwacsFG:SetSRS(self.PathToSRS,self.Gender,self.Culture,self.Voice,self.Port,nil,"AWACS")
    --self.callsigntxt = string.format("%s %d %d",AWACS.CallSignClear[self.CallSign],1,self.CallSignNo)
    self.callsigntxt = string.format("%s",AWACS.CallSignClear[self.CallSign])
    
    local text = string.format("%s shift change for %s control.",self.callsigntxt,self.AOName or "Rock")
    self:T(self.lid..text)
    
    AwacsFG:RadioTransmission(text,1,false)
    
    self.AwacsFG = AwacsFG 
    
    --self:__CheckRadioQueue(10)
    
    if self.HasEscorts then
      --mission:SetRequiredEscorts(self.EscortNumber)
      self:_StartEscorts(true)
    end
    
    self.AwacsTimeStamp = timer.getTime()
    self.EscortsTimeStamp = timer.getTime()
    
    self.AwacsReady = true
    
  end
  return self
end

--- [Internal] Return Bullseye BR for Alpha Check etc, returns e.g. "Rock 021, 16" ("Rock" being the set BE name)
-- @param #AWACS self
-- @param Core.Point#COORDINATE Coordinate
-- @return #string BullseyeBR
function AWACS:ToStringBULLS( Coordinate )
 -- local BullsCoordinate = COORDINATE:NewFromVec3( coalition.getMainRefPoint( self.coalition ) )
  local bullseyename = self.AOName or "Rock"
  local BullsCoordinate = self.OpsZone:GetCoordinate()
  local DirectionVec3 = BullsCoordinate:GetDirectionVec3( Coordinate )
  local AngleRadians =  Coordinate:GetAngleRadians( DirectionVec3 )
  local Distance = Coordinate:Get2DDistance( BullsCoordinate )
  local AngleDegrees = UTILS.Round( UTILS.ToDegree( AngleRadians ), 0 )
  local Bearing = string.format( '%03d', AngleDegrees )
  local Distance = UTILS.Round( UTILS.MetersToNM( Distance ), 0 )
  return string.format("%s %03d, %03d",bullseyename,Bearing,Distance)
end

--- [Internal] Change Bullseye string to be TTS friendly,  "Bullseye 021, 16" returns e.g. "Bulls eye 0 2 1. 1 6"
-- @param #AWACS self
-- @param #string Text Input text
-- @return #string BullseyeBRTTS
function AWACS:ToStringBullsTTS(Text)
  local text = Text
  text=string.gsub(text,"Bullseye","Bulls eye")
  text=string.gsub(text,"%d","%1 ")
  text=string.gsub(text," ," ,".")
  text=string.gsub(text," $","")
  return text
end


--- [Internal] Check if a group has checked in
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to check
-- @return #number ID
-- @return #boolean CheckedIn
-- @return #string CallSign
function AWACS:_GetManagedGrpID(Group)
  if not Group or not Group:IsAlive() then
    self:E(self.lid.."_GetManagedGrpID - Requested Group is not alive!")
    return 0,false,""
  end
  self:T(self.lid.."_GetManagedGrpID for "..Group:GetName())
  local GID = 0
  local Outcome = false
  local CallSign = "Ghost 1"
  local nametocheck = Group:GetName()
  local managedgrps = self.ManagedGrps or {}
  for _,_managed in pairs (managedgrps) do
    local managed = _managed -- #AWACS.ManagedGroup
    if managed.GroupName == nametocheck then
      GID = managed.GID
      Outcome = true
      CallSign = managed.CallSign
    end
  end
  return GID, Outcome, CallSign
end

--- [Internal] AWACS Get TTS compatible callsign
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @param #number GID GID to use
-- @return #string Callsign
function AWACS:_GetCallSign(Group,GID)
  self:T(self.lid.."_GetCallSign - GID "..tostring(GID))
  
  if GID and type(GID) == "number" and GID > 0 then
    local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
    self:T("Saved Callsign for TTS = " .. tostring(managedgroup.CallSign))
    return managedgroup.CallSign
  end
  
  local callsign = "Ghost 1"
  if Group and Group:IsAlive() then
    local shortcallsign = Group:GetCallsign() or "unknown11"-- e.g.Uzi11, but we want Uzi 1 1
    local callnumber = string.match(shortcallsign, "(%d+)$" ) or "unknown11"
    local callnumbermajor = string.char(string.byte(callnumber,1))
    local callnumberminor = string.char(string.byte(callnumber,2))
    if self.callsignshort then
      callsign = string.gsub(shortcallsign,callnumber,"").." "..callnumbermajor
    else
      callsign = string.gsub(shortcallsign,callnumber,"").." "..callnumbermajor.." "..callnumberminor
    end
    self:I("Generated Callsign for TTS = " .. callsign)
  end
  return callsign
end

function AWACS:_CleanUpContacts()
  self:I(self.lid.."_CleanUpContacts")
  
  if self.Contacts:Count() >  0 then
    local deadcontacts = FIFO:New()   
    self.Contacts:ForEach(
      function (Contact)
        local contact = Contact -- #AWACS.ManagedContact
        if not contact.Contact.group:IsAlive() then
          deadcontacts:Push(contact,contact.CID)
        end
      end
    )
    -- announce VANISHED
    if deadcontacts:Count() > 0 then
      -- announce lost
      deadcontacts:ForEach(
      function (Contact) 
        local contact = Contact -- #AWACS.ManagedContact
        local text = string.format("%s, %s Group. Vanished.",self.callsigntxt, contact.TargetGroupNaming)
        local textScreen = string.format("%s, %s group vanished.", self.callsigntxt, contact.TargetGroupNaming)
        local RadioEntry = {} -- #AWACS.RadioEntry
        RadioEntry.IsNew = true
        RadioEntry.TextTTS = text
        RadioEntry.TextScreen = textScreen
        RadioEntry.GroupID = 0
        RadioEntry.ToScreen = self.debug 
        RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8 
        self.RadioQueue:Push(RadioEntry)
        
        -- pull from Contacts
        self.Contacts:PullByID(contact.CID)        
      end
      )
    end   
  end
  return self
end

--- [Internal] Select pilots available for tasking, return AI and Human
-- @param #AWACS self
-- @return #table AIPilots Table of #AWACS.ManagedGroup
-- @return #table HumanPilots Table of #AWACS.ManagedGroup
function AWACS:_GetIdlePilots()
  self:T(self.lid.."_GetIdlePilots")
  local AIPilots = {}
  local HumanPilots = {}
  
  for _name,_entry in pairs (self.ManagedGrps) do
    local entry = _entry -- #AWACS.ManagedGroup
    self:T("Looking at entry "..entry.GID.." Name "..entry.GroupName)
    local managedtask = self:_ReadAssignedTaskFromGID(entry.GID) -- #AWACS.ManagedTask
    local overridetask = false
    if managedtask then
      self:T("Current task = "..managedtask.ToDo or "Unknown")
      if managedtask.ToDo == AWACS.TaskDescription.ANCHOR then
        overridetask = true
      end
    end
    if entry.IsAI then
      if entry.FlightGroup:IsAirborne() and (not entry.HasAssignedTask or overridetask) then -- must be idle, or?
        self:T("Adding AI with Callsign: "..entry.CallSign)
        AIPilots[#AIPilots+1] = _entry
      end
    elseif entry.IsPlayer then
      if not entry.HasAssignedTask or overridetask then -- must be idle, or?
        self:T("Adding Human with Callsign: "..entry.CallSign)
        HumanPilots[#HumanPilots+1] = _entry
      end
    end
  end
  
  return AIPilots, HumanPilots

end

--- [Internal] Select max 3 targets for picture, bogey dope etc
-- @param #AWACS self
-- @param #boolean Untargeted Return not yet targeted contacts only
-- @return #boolean HaveTargets True if targets could be found, else false
-- @return Utilities.FiFo#FIFO Targetselection
function AWACS:_TargetSelectionProcess(Untargeted)
  self:I(self.lid.."_TargetSelectionProcess")
  
  local maxtargets = 3 -- handleable number of callouts
  local contactstable = self.Contacts:GetDataTable()
  local targettable = FIFO:New()
  local sortedtargets = FIFO:New() 
  local HaveTargets = false
  
  -- Bucket sort
   
  if Untargeted then
    -- pre-filter
    local prefiltered = FIFO:New()
    self.Contacts:ForEach(
      function (Contact)
        local contact = Contact -- #AWACS.ManagedContact
        if contact.Contact.group:IsAlive() and (contact.Status == AWACS.TaskStatus.IDLE or contact.Status == AWACS.TaskStatus.UNASSIGNED) then
          prefiltered:Push(contact,contact.CID)
        end
      end
    )
    contactstable = prefiltered:GetDataTable()
    --self:T(prefiltered:Flush())
    prefiltered:Clear()
  end
  
  -- Bucket 1 - close to AIC (HVT) ca ~45nm
  local HVTCoordinate = self.OrbitZone:GetCoordinate()
  for _,_contact in pairs(contactstable) do
    local contact = _contact -- #AWACS.ManagedContact
    -- get distance
    local contactcoord = contact.Contact.group:GetCoordinate()
    local distance = UTILS.NMToMeters(200)
    if contactcoord then
      distance = HVTCoordinate:Get2DDistance(contactcoord)
    end
    if UTILS.MetersToNM(distance) <= 45 then
      targettable:Push(contact,distance)
      sortedtargets:Push(contact,contact.CID)
    end -- end distance
  end -- end for
  
  -- Bucket 2 - in AO
  if targettable:Count() < 3 then
    for _,_contact in pairs(contactstable) do
      local contact = _contact -- #AWACS.ManagedContact
      -- get distance
      local contactcoord = contact.Contact.group:GetCoordinate()
      local distance = UTILS.NMToMeters(200)
      if contactcoord then
        distance = self.OpsZone:Get2DDistance(contactcoord)  
      end   
      if contactcoord and self.OpsZone:IsVec2InZone(contactcoord:GetVec2()) then
        -- DONE prefer heavy groups
        local groupsize = contact.Contact.group:CountAliveUnits()
        local threatlevel = contact.Contact.group:GetThreatLevel()
        if groupsize >= 3 then
          local threat = groupsize*threatlevel
          distance = math.abs(math.floor(100-threat))
        end -- end grpsize
        if not sortedtargets:HasUniqueID(contact.CID) then
          targettable:Push(contact,distance)
        end -- end unique
      end -- end in zone
    end -- end for
  end -- end count
  
  if targettable:Count() < 3 then
    -- Bucket 3 - in Radar(Control)Zone, < 100nm to AO, Aspect HOT on AO
    for _,_contact in pairs(contactstable) do
      local contact = _contact -- #AWACS.ManagedContact
      -- get distance
      local contactcoord = contact.Contact.group:GetCoordinate()
      local distance = UTILS.NMToMeters(200)
      if contactcoord then
        distance = self.ControlZone:Get2DDistance(contactcoord)
      end
      if contactcoord and self.ControlZone:IsVec2InZone(contactcoord:GetVec2()) then
        if not contactcoord.Heading then
          contactcoord.Heading = contact.Contact.group:GetHeading()       
        end -- end heading
        if contactcoord:ToStringAspect(self.ControlZone:GetCoordinate()) == "Hot" then
          -- DONE prefer heavy groups
          local groupsize = contact.Contact.group:CountAliveUnits()
          local threatlevel = contact.Contact.group:GetThreatLevel()
          if groupsize >= 3 then
            local threat = groupsize*threatlevel
            distance = math.abs(math.floor(100-threat))
          end -- end sizing
          if not sortedtargets:HasUniqueID(contact.CID) then
            targettable:Push(contact,distance)
          end -- end unique
        end -- end aspect
      end -- end in zone
    end -- end for
  end -- end count
  
  -- Bucket 4 (if set) within the border polyzone to be defended
  if targettable:Count() < 3 and self.BorderZone then
    for _,_contact in pairs(contactstable) do
      local contact = _contact -- #AWACS.ManagedContact
      -- get distance
      local contactcoord = contact.Contact.group:GetCoordinate()
      local distance = UTILS.NMToMeters(200)
      if contactcoord then
        distance = self.BorderZone:Get2DDistance(contactcoord)
      end
      --local distance = self.BorderZone:Get2DDistance(contactcoord)    
      if contactcoord and self.BorderZone:IsVec2InZone(contactcoord:GetVec2()) then
        -- DONE prefer heavy groups
        local groupsize = contact.Contact.group:CountAliveUnits()
        local threatlevel = contact.Contact.group:GetThreatLevel()
        if groupsize >= 3 then
          local threat = groupsize*threatlevel
          distance = math.abs(math.floor(100-threat))
        end -- end size
        if not sortedtargets:HasUniqueID(contact.CID) then
          targettable:Push(contact,distance)
        end -- end unique
      end -- end in zone
    end -- end for  
  end -- end count
  
  -- control
  if self.debug then
    self:I(string.format("%s**** TargetSelectionProcess outcome %d targets.",self.lid,targettable:Count()))   
    --targettable:Flush()
    if not self.TargetMarkers then
      self.TargetMarkers = {}
    end
    for _,_marker in pairs(self.TargetMarkers) do
      local marker = _marker -- Wrapper.Marker#MARKER
      marker:Remove(1)
      self.TargetMarkers = nil
      self.TargetMarkers = {}
    end
    for _,_contact in pairs(targettable:GetDataTable()) do
      local contact = _contact -- #AWACS.ManagedContact
      local markerinfo = string.format("CID=%d\nName=%s\nPlatform=%s\nSize=%d",contact.CID,contact.TargetGroupNaming,contact.ReportingName,contact.Contact.group:CountAliveUnits())
      local markercoord = contact.Contact.group:GetCoordinate()
      self.TargetMarkers[#self.TargetMarkers+1] = MARKER:New(markercoord,markerinfo):ToAll(1)
    end
  end
  
  sortedtargets:Clear()
  --DONE - sort table - but max 3 anyway?
  
  if targettable:Count() > 0 then
    HaveTargets = true
  end
  
  return HaveTargets, targettable
end

--- [Internal] AWACS Speak Picture AO/EWR entries
-- @param #AWACS self
-- @param #boolean AO If true this is for AO, else EWR
-- @param #string Callsign Callsign to address
-- @param #number GID GroupID for comms
-- @param #number MaxEntries Max entries to show
-- @param #boolean IsGeneral Is a general picture, address all stations
-- @return #AWACS self
function AWACS:_CreatePicture(AO,Callsign,GID,MaxEntries,IsGeneral)
  self:I(self.lid.."_CreatePicture AO="..tostring(AO).." for "..Callsign.." GID "..GID)
  
  local managedgroup = nil
  local group = nil
  local groupcoord = nil
  
  if not IsGeneral then
    managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
    group = managedgroup.Group -- Wrapper.Group#GROUP
    groupcoord = group:GetCoordinate()
  end
  
  local fifo = self.PictureAO -- Utilities.FiFo#FIFO
  
  local maxentries = self.maxspeakentries or 3
  
  if MaxEntries and MaxEntries>0  and MaxEntries <= 3 then
   maxentries = MaxEntries
  end
  
  local counter = 0
  
  if not AO then 
   -- fifo = self.PictureEWR 
  end
  
  local entries = fifo:GetSize()
  
  if entries < maxentries then maxentries = entries end
  
  local text = ""
  local textScreen = ""
  
  
  -- "<tag> group, <shipsize>, BRA, <bearing> for <range> at angels <alt/1000>, <aspect>"
  while counter < maxentries do
    counter = counter + 1
    local contact = fifo:Pull() -- #AWACS.ManagedContact
    self:T({contact})
    if contact and contact.Contact.group and contact.Contact.group:IsAlive() then
      local coordinate = contact.Contact.group:GetCoordinate()
      if not coordinate.Heading then
        coordinate.Heading = contact.Contact.group:GetHeading()
      end
      local refBRAA = ""
      text = contact.TargetGroupNaming.." group." -- Alpha Group.
      textScreen = contact.TargetGroupNaming.." group,"
      --self:I("Step 1")
      --self:I(text)
      --self:I(textScreen)
      -- sizing
      local size = contact.Contact.group:CountAliveUnits()
      local threatsize, threatsizetext = self:_GetBlurredSize(size)
      --local threatlevel = contact.threatlevel
      --local threattext = self:_GetThreatLevelText(threatlevel)
      text = text.." "..threatsizetext.."." -- Alpha Group. Heavy.
      textScreen = textScreen.." "..threatsizetext..","
      --self:I("Step 2")
      --self:I(text)
      --self:I(textScreen)
      if IsGeneral then
        -- AO/BE Reference
        refBRAA=self:ToStringBULLS(coordinate)
        text = text .. " "..self:ToStringBullsTTS(refBRAA).."." -- Alpha Group. Heavy. Bulls eye 0 2 1, 1 6. 
        textScreen = textScreen .. " "..refBRAA.."," -- Alpha Group, Heavy, Bullseye 021, 16,
        --self:I("Step 2 - General")
        --self:I(text)
        --self:I(textScreen)
      else
        -- pilot reference
        refBRAA = coordinate:ToStringBRAANATO(groupcoord,true) -- Charlie group, Singleton, BRAA, 045, 105 miles, Angels 41, Flanking, Track North-East, Spades.
        text = text .. " "..refBRAA
        textScreen = textScreen .." "..refBRAA
        --self:I("Step 2 - Pilot")
        --self:I(text)
        --self:I(textScreen)
      end
      -- Aspect
      local aspect = ""
      if IsGeneral then
        aspect = coordinate:ToStringAspect(self.OpsZone:GetCoordinate())
        text = text .. " "..aspect.."." -- Alpha Group. Heavy. Bulls eye 0 2 1, 1 6. Flanking.
        textScreen = textScreen .. " "..aspect.."." -- Alpha Group, Heavy, Bullseye 021, 16, Flanking.
        --self:I("Step 3 - General")
        --self:I(text)
        --self:I(textScreen)
      end
      -- engagement tag?
      if contact.EngagementTag then
        text = text .. " "..contact.EngagementTag -- Alpha Group. Heavy. Bulls eye 0 2 1, 1 6. Flanking. Targeted by Jazz 1 1.
        textScreen = textScreen .. " "..contact.EngagementTag -- Alpha Group, Heavy, Bullseye 021, 16, Flanking. Targeted by Jazz 1 1.
      end
      
      -- Transmit Radio
      local RadioEntry = {} -- #AWACS.RadioEntry
      RadioEntry.IsNew = true
      RadioEntry.TextTTS = text
      RadioEntry.TextScreen = textScreen
      RadioEntry.GroupID = GID
      if IsGeneral then
        RadioEntry.IsGroup = false
        RadioEntry.ToScreen = self.debug
      else
        RadioEntry.IsGroup = managedgroup.IsPlayer
        RadioEntry.ToScreen = managedgroup.IsPlayer
      end 
      RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
      
      self.RadioQueue:Push(RadioEntry)
    end
  end
  
  -- empty queue from leftovers
  fifo:Clear()
 
  return self
end

--- [Internal] AWACS Speak Bogey Dope entries
-- @param #AWACS self
-- @param #string Callsign Callsign to address
-- @param #number GID GroupID for comms
-- @return #AWACS self
function AWACS:_CreateBogeyDope(Callsign,GID)
  self:T(self.lid.."_CreateBogeyDope for "..Callsign.." GID "..GID)
  
  local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
  local group = managedgroup.Group -- Wrapper.Group#GROUP
  local groupcoord = group:GetCoordinate()
  
  local fifo = self.ContactsAO -- Utilities.FiFo#FIFO
  local maxentries = self.maxspeakentries
  local counter = 0
  
  local entries = fifo:GetSize()
  
  if entries < maxentries then maxentries = entries end
  
  local sortedIDs = fifo:GetIDStackSorted() -- sort by distance
  
  while counter < maxentries do
    counter = counter + 1
    local cluster = fifo:PullByID(sortedIDs[counter]) -- Ops.Intelligence#INTEL.Contact
    self:T({cluster})
    if cluster and cluster.position then
      local tag =  cluster.TargetGroupNaming
      local reportingname = cluster.group:GetNatoReportingName()
      -- DONE - add tag
      self:_AnnounceContact(cluster,false,group,true,tag,false,reportingname)
    end
  end
  
  -- empty queue from leftovers
  fifo:Clear()
  
  return self
end

--- [Internal] AWACS Menu for Picture
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @param #boolean IsGeneral General picture if true, address no-one specific
-- @return #AWACS self
function AWACS:_Picture(Group,IsGeneral)
  self:T(self.lid.."_Picture")
  local text = ""
  local textScreen = text
  local GID, Outcome, gcallsign = self:_GetManagedGrpID(Group) 
  --local gcallsign = ""
  
  if Outcome then
    IsGeneral = false
  end
  
  if IsGeneral then
    gcallsign = "All Stations"
  --else
    --gcallsign = self:_GetCallSign(Group,GID) or "Ghost 1"
  end
    
  if not self.intel then
    -- no intel yet!
    text = string.format("%s. %s. Clear.",gcallsign, self.callsigntxt)
    textScreen = text
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = text
    RadioEntry.ToScreen = true
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    
    self.RadioQueue:Push(RadioEntry) 
    return self 
  end

  if Outcome or IsGeneral then
    -- Pilot is checked in
    -- get clusters from Intel
    
    -- DONE Use contacts table!
    local contactstable = self.Contacts:GetDataTable()
    
    --local clustertable = self.intel:GetClusterTable() or {}
    -- sort into buckets
    for _,_contact in pairs(contactstable) do
      
      local contact  = _contact -- #AWACS.ManagedContact
      
      self:T(UTILS.OneLineSerialize(contact))
      
      local coordVec2 = contact.Contact.position:GetVec2()  
      
      --local coordVec2 = cluster.coordinate:GetVec2()      
      
      if self.OpsZone:IsVec2InZone(coordVec2) then
        self.PictureAO:Push(contact)
      elseif self.OrbitZone:IsVec2InZone(coordVec2) then
        self.PictureAO:Push(contact)
      elseif self.ControlZone:IsVec2InZone(coordVec2) then
        local distance = math.floor((contact.Contact.position:Get2DDistance(self.ControlZone:GetCoordinate()) / 1000) + 1) -- km
        self.PictureEWR:Push(contact,distance)
      end
      
    end
    
    local clustersAO = self.PictureAO:GetSize()
    local clustersEWR = self.PictureEWR:GetSize()
    
    if clustersAO < 3 and clustersEWR > 0 then
      -- make sure we have 3, can only add 1, 2 or 3
      local IDstack = self.PictureEWR:GetSortedDataTable()
      -- how many do we need?
      local weneed = 3-clustersAO
      -- do we have enough?
      self:T(string.format("Picture - adding %d/%d contacts from EWR",weneed,clustersEWR))
      if weneed > clustersEWR then
        weneed = clustersEWR
      end
      for i=1,weneed do
        self.PictureAO:Push(IDstack[i])
      end
    end
    
    clustersAO = self.PictureAO:GetSize()
    
    if clustersAO == 0 and clustersEWR == 0 then
      -- clear
      text = string.format("%s. %s. Clear.",gcallsign, self.callsigntxt)
      textScreen = text
      local RadioEntry = {} -- #AWACS.RadioEntry
      RadioEntry.IsNew = true
      RadioEntry.TextTTS = text
      RadioEntry.TextScreen = textScreen
      RadioEntry.GroupID = GID
      RadioEntry.IsGroup = Outcome
      RadioEntry.ToScreen = true
      RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
      
      self.RadioQueue:Push(RadioEntry)
    else
    
      if clustersAO > 0 then
        text = string.format("%s. %s. Picture. ",gcallsign, self.callsigntxt)
        textScreen = string.format("%s. %s. Picture. ",gcallsign, self.callsigntxt)
        if clustersAO == 1 then
          text = text .. "One group. "
          textScreen = textScreen .. "One group.\n"
        else
          text = text .. clustersAO .. " groups. "
          textScreen = textScreen .. clustersAO .. " groups.\n"
        end
        local RadioEntry = {} -- #AWACS.RadioEntry
        RadioEntry.IsNew = true
        RadioEntry.TextTTS = text
        RadioEntry.TextScreen = text
        RadioEntry.GroupID = GID
        RadioEntry.IsGroup = Outcome
        RadioEntry.ToScreen = true
        RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8      
        self.RadioQueue:Push(RadioEntry)
        
        self:_CreatePicture(true,gcallsign,GID,3,IsGeneral)
        
        self.PictureAO:Clear()
        self.PictureEWR:Clear()
      end
      --[[
      if clustersAO == 0 and clustersEWR > 0 then
       text = string.format("%s. %s. Picture Early Warning. ",gcallsign, self.callsigntxt)
       textScreen = string.format("%s. %s. Picture EWR. ",gcallsign, self.callsigntxt)
       if clustersEWR == 1 then
          text = text .. "One group. "
          textScreen = textScreen .. "One group.\n"
        else
          text = text .. clustersEWR .. " groups. "
          textScreen = textScreen .. clustersEWR .. " groups.\n"
        end
        local RadioEntry = {} -- #AWACS.RadioEntry
        RadioEntry.IsNew = true
        RadioEntry.TextTTS = text
        RadioEntry.TextScreen = textScreen
        RadioEntry.GroupID = GID
        RadioEntry.IsGroup = Outcome
        RadioEntry.ToScreen = true
        RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8     
        self.RadioQueue:Push(RadioEntry)
        
        self:_CreatePicture(false,gcallsign,GID,3,IsGeneral)
       
        self.PictureEWR:Clear()
      end
      --]]
    end
    
  elseif self.AwacsFG then
    -- no, unknown
    text = string.format("%s. %s. Negative. You are not checked in.",gcallsign, self.callsigntxt)  
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = text
    RadioEntry.GroupID = GID
    RadioEntry.IsGroup = Outcome
    RadioEntry.ToScreen = true
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    
    self.RadioQueue:Push(RadioEntry)
  end
  return self
end

--- [Internal] AWACS Menu for Bogey Dope
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @return #AWACS self
function AWACS:_BogeyDope(Group)
  self:T(self.lid.."_BogeyDope")
  local text = ""
  local textScreen = ""
  local GID, Outcome = self:_GetManagedGrpID(Group)
  local gcallsign = self:_GetCallSign(Group,GID) or "Ghost 1"
    
  if not self.intel then
    -- no intel yet!
    text = string.format("%s. %s. Clear.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
    textScreen = text
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = textScreen
    RadioEntry.GroupID = 0
    RadioEntry.IsGroup = false
    RadioEntry.ToScreen = true
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    
    self.RadioQueue:Push(RadioEntry) 
    return self 
  end

  if Outcome then
    -- Pilot is checked in
    
    local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
    local pilotgroup = managedgroup.Group
    local pilotcoord = managedgroup.Group:GetCoordinate()
    
    -- get contacts from Intel
    local contactstable = self.intel:GetContactTable()
    
    -- sort into buckets - AO only for bogey dope!
    for _,_contact in pairs(contactstable) do
      local cluster = _contact -- Ops.Intelligence#INTEL.Contact
      local coordVec2 = cluster.position:GetVec2()
      
      -- Get distance for sorting
      local dist = pilotcoord:Get2DDistance(cluster.position)

      if self.OpsZone:IsVec2InZone(coordVec2) then
        self.ContactsAO:Push(cluster,dist)
      elseif self.BorderZone and self.BorderZone:IsVec2InZone(coordVec2) then 
       self.ContactsAO:Push(cluster,dist)
      else
        local distance = cluster.position:Get2DDistance(self.OrbitZone:GetCoordinate())
        if (distance <= UTILS.NMToMeters(45)) then
          self.ContactsAO:Push(cluster,distance)
        end
      end     
    end
    
    local contactsAO = self.ContactsAO:GetSize()
    
    if contactsAO == 0 then
      -- clear
      text = string.format("%s. %s. Clear.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
      textScreen = text
      local RadioEntry = {} -- #AWACS.RadioEntry
      RadioEntry.IsNew = true
      RadioEntry.TextTTS = text
      RadioEntry.TextScreen = textScreen
      RadioEntry.GroupID = GID
      RadioEntry.IsGroup = Outcome
      RadioEntry.ToScreen = Outcome
      RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
      
      self.RadioQueue:Push(RadioEntry)
    else
    
      if contactsAO > 0 then
        text = string.format("%s. %s. Bogey Dope. ",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
        if contactsAO == 1 then
          text = text .. "One group. "
          textScreen = text .. "\n"
        else
          text = text .. contactsAO .. " groups. "
          textScreen = textScreen .. contactsAO .. " groups.\n"
        end
        local RadioEntry = {} -- #AWACS.RadioEntry
        RadioEntry.IsNew = true
        RadioEntry.TextTTS = text
        RadioEntry.TextScreen = textScreen
        RadioEntry.GroupID = GID
        RadioEntry.IsGroup = Outcome
        RadioEntry.ToScreen = true
        RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8      
        self.RadioQueue:Push(RadioEntry)
        
        self:_CreateBogeyDope(self:_GetCallSign(Group,GID) or "Ghost 1",GID)
      end
    end
    
  elseif self.AwacsFG then
    -- no, unknown
    text = string.format("%s. %s. Negative. You are not checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)  
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = text
    RadioEntry.GroupID = GID
    RadioEntry.IsGroup = Outcome
    RadioEntry.ToScreen = true
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    
    self.RadioQueue:Push(RadioEntry)
  end
  return self
end


--- [Internal] AWACS Menu for Declare
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @return #AWACS self
function AWACS:_Declare(Group)
  self:I(self.lid.."_Declare")

  local GID, Outcome, Callsign = self:_GetManagedGrpID(Group)
  local text = "Declare Not yet implemented"
  local TextTTS = ""
  
  if Outcome then
    --yes, known
    local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
    local group = managedgroup.Group
    local position = group:GetCoordinate()
    local radius = UTILS.NMToMeters(self.DeclareRadius) or UTILS.NMToMeters(5)
    -- find contacts nearby
    local groupzone = ZONE_GROUP:New(group:GetName(),group, radius)
    local Coalitions = {"red","neutral"}
    if self.coalition == coalition.side.NEUTRAL then
      Coalitions = {"red","blue"}
    elseif self.coalition == coalition.side.RED then
      Coalitions = {"blue","neutral"}
    end
    local contactset = SET_GROUP:New():FilterCategoryAirplane():FilterCoalitions(Coalitions):FilterZones({groupzone}):FilterOnce()
    local numbercontacts = contactset:CountAlive() or 0
    local foundcontacts = {}
    if numbercontacts > 0 then
      -- we have some around
      -- sort by distance
      contactset:ForEach(
        function (airpl)
          local distance = position:Get2DDistance(airpl:GetCoordinate())
          distance = UTILS.Round(distance,0) + 1
          foundcontacts[distance] = airpl
        end
      ,{}
      )
      for _dist,_contact in UTILS.spairs(foundcontacts) do
        local distanz = _dist
        local contact = _contact -- Wrapper.Group#GROUP
        local ccoalition = contact:GetCoalition()
        local ctypename = contact:GetTypeName()
        
        local friendorfoe = "Neutral"
        if self.self.ModernEra then
          if ccoalition == self.coalition then
            friendorfoe = "Friendly"
          elseif ccoalition == coalition.side.NEUTRAL then
            friendorfoe = "Neutral"
          elseif ccoalition ~= self.coalition then 
            friendorfoe = "Hostile"
          end
        else
          friendorfoe = "Spades"
        end
        -- AWACS - “Uzi 1-1, Magic, hostile/friendly”
        
        -- see if that works
        self:I(string.format("Distance %d ContactName %s Coalition %d (%s) TypeName %s",distanz,contact:GetName(),ccoalition,friendorfoe,ctypename))
        
        text = string.format("%s. %s. %s.",Callsign,self.callsigntxt,friendorfoe)
        TextTTS = text
        if self.ModernEra then
          text = string.format("%s %s.",text,ctypename)
        end
        break 
      end
    else
      -- clear
      text = string.format("%s. %s. %s.",Callsign,self.callsigntxt,"Clear")
      TextTTS = text
    end
    
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = TextTTS
    RadioEntry.TextScreen = text
    RadioEntry.GroupID = GID
    RadioEntry.IsGroup = Outcome
    RadioEntry.ToScreen = true
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    
    self.RadioQueue:Push(RadioEntry)
    
    --
  elseif self.AwacsFG then
    -- no, unknown
    text = string.format("%s. %s. Negative. You are not checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
  
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = text
    RadioEntry.GroupID = GID
    RadioEntry.IsGroup = Outcome
    RadioEntry.ToScreen = true
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    
    self.RadioQueue:Push(RadioEntry)
  end
  return self
end

--- [Internal] AWACS Menu for Commit
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @return #AWACS self
function AWACS:_Commit(Group)
  self:T(self.lid.."_Commit")
  
  local GID, Outcome = self:_GetManagedGrpID(Group)
  local text = "Commit Not yet implemented"
  if Outcome then
    --[[ yes, known

    --]]
  elseif self.AwacsFG then
    -- no, unknown
    text = string.format("%s. %s. Negative. You are not checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
  end
  
  local RadioEntry = {} -- #AWACS.RadioEntry
  RadioEntry.IsNew = true
  RadioEntry.TextTTS = text
  RadioEntry.TextScreen = text
  RadioEntry.GroupID = GID
  RadioEntry.IsGroup = Outcome
  RadioEntry.ToScreen = true
  RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
  
  self.RadioQueue:Push(RadioEntry)
  
  return self
end

--- [Internal] AWACS Menu for Judy
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @return #AWACS self
function AWACS:_Judy(Group)
  self:T(self.lid.."_Judy")
  
  local GID, Outcome = self:_GetManagedGrpID(Group)
  local text = "Judy Not yet implemented"
  if Outcome then
    --[[ yes, known

    --]]
  elseif self.AwacsFG then
    -- no, unknown
    text = string.format("%s. %s. Negative. You are not checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
  end
  
  local RadioEntry = {} -- #AWACS.RadioEntry
  RadioEntry.IsNew = true
  RadioEntry.TextTTS = text
  RadioEntry.TextScreen = text
  RadioEntry.GroupID = GID
  RadioEntry.IsGroup = Outcome
  RadioEntry.ToScreen = true
  RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
  
  self.RadioQueue:Push(RadioEntry)
  
  return self
end

--- [Internal] AWACS Menu for Unable
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @return #AWACS self
function AWACS:_Unable(Group)
  self:T(self.lid.."_Unable")
  
      local GID, Outcome = self:_GetManagedGrpID(Group)
  local text = "Unable Not yet implemented"
  if Outcome then
    --[[ yes, known

    --]]
  elseif self.AwacsFG then
    -- no, unknown
    text = string.format("%s. %s. Negative. You are not checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
  end
  
  local RadioEntry = {} -- #AWACS.RadioEntry
  RadioEntry.IsNew = true
  RadioEntry.TextTTS = text
  RadioEntry.TextScreen = text
  RadioEntry.GroupID = GID
  RadioEntry.IsGroup = Outcome
  RadioEntry.ToScreen = true
  RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
  
  self.RadioQueue:Push(RadioEntry)
  
  return self
end

--- [Internal] AWACS Menu for Abort
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @return #AWACS self
function AWACS:_TaskAbort(Group)
  self:T(self.lid.."_TaskAbort")
  
      local GID, Outcome = self:_GetManagedGrpID(Group)
  local text = "Abort Not yet implemented"
  if Outcome then
    --[[ yes, known

    --]]
  elseif self.AwacsFG then
    -- no, unknown
    text = string.format("%s. %s. Negative. You are not checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
  end
  
  local RadioEntry = {} -- #AWACS.RadioEntry
  RadioEntry.IsNew = true
  RadioEntry.TextTTS = text
  RadioEntry.TextScreen = text
  RadioEntry.GroupID = GID
  RadioEntry.IsGroup = Outcome
  RadioEntry.ToScreen = true
  RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
  
  self.RadioQueue:Push(RadioEntry)
  
  return self
end

--- [Internal] AWACS Menu for Showtask
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @return #AWACS self
function AWACS:_Showtask(Group)
  self:T(self.lid.."_Showtask")

  local GID, Outcome, Callsign = self:_GetManagedGrpID(Group)
  local text = "Showtask WIP"
  
  if Outcome then
   -- known group
   
   -- Do we have a task?
   local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
   
   if managedgroup.IsPlayer then

    if managedgroup.CurrentTask >0 and self.ManagedTasks:HasUniqueID(managedgroup.CurrentTask) then
      -- get task structure
      local currenttask = self.ManagedTasks:ReadByID(managedgroup.CurrentTask) -- #AWACS.ManagedTask
      if currenttask then
        local status = currenttask.Status
        local targettype = currenttask.Target:GetCategory()
        local targetstatus = currenttask.Target:GetState()
        local ToDo = currenttask.ToDo
        local description = currenttask.ScreenText
        local callsign = Callsign
        
        if self.debug then
          local taskreport = REPORT:New("AWACS Tasking Display")
          taskreport:Add("===============")
          taskreport:Add(string.format("Task for Callsign: %s",Callsign))
          taskreport:Add(string.format("Task: %s with Status: %s",ToDo,status))
          taskreport:Add(string.format("Target of Type: %s",targettype))
          taskreport:Add(string.format("Target in State: %s",targetstatus))
          taskreport:Add("===============")
          self:I(taskreport:Text())
        end
        
        MESSAGE:New(description,30,"AWACS",true):ToGroup(Group)
        
      end
    end
   end
   
  elseif self.AwacsFG then
    -- no, unknown
    text = string.format("%s. %s. Negative. You are not checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
  
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = text
    RadioEntry.GroupID = GID
    RadioEntry.IsGroup = Outcome
    RadioEntry.ToScreen = true
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    
    self.RadioQueue:Push(RadioEntry)
  end
  return self
end

--- [Internal] AWACS Menu for Check in
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @return #AWACS self
function AWACS:_CheckIn(Group)
  self:T(self.lid.."_CheckIn "..Group:GetName())
  -- check if already known
  local GID, Outcome = self:_GetManagedGrpID(Group)
  local text = ""
  if not Outcome then
    self.ManagedGrpID = self.ManagedGrpID + 1
    local managedgroup = {} -- #AWACS.ManagedGroup
      managedgroup.Group = Group
      managedgroup.GroupName = Group:GetName()
      managedgroup.IsPlayer = true
      managedgroup.IsAI = false
      managedgroup.CallSign = self:_GetCallSign(Group,GID) or "Ghost 1"
      managedgroup.CurrentAuftrag = 0
      managedgroup.HasAssignedTask = false
      managedgroup.GID = self.ManagedGrpID
      managedgroup.TaskQueue = FIFO:New()
      
      GID = managedgroup.GID
    self.ManagedGrps[self.ManagedGrpID]=managedgroup
    
    local alphacheckbulls = self:ToStringBULLS(Group:GetCoordinate())
    alphacheckbulls = self:ToStringBullsTTS(alphacheckbulls)-- make tts friendly
      
    self.ManagedGrps[self.ManagedGrpID]=managedgroup
    text = string.format("%s. %s. Alpha Check. %s",managedgroup.CallSign,self.callsigntxt,alphacheckbulls)
    
    self:__CheckedIn(1,managedgroup.GID)
    self:__AssignAnchor(5,managedgroup.GID)
    
  elseif self.AwacsFG then
    text = string.format("%s. %s. Negative. You are already checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
  end
  
  local RadioEntry = {} -- #AWACS.RadioEntry
  RadioEntry.IsNew = true
  RadioEntry.TextTTS = text
  RadioEntry.TextScreen = text
  RadioEntry.GroupID = GID
  RadioEntry.IsGroup = true
  RadioEntry.ToScreen = true
  RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
  
  self.RadioQueue:Push(RadioEntry)
  
  return self
end

--- [Internal] AWACS Menu for CheckInAI
-- @param #AWACS self
-- @param Ops.FlightGroup#FLIGHTGROUP FlightGroup to use
-- @param Wrapper.Group#GROUP Group Group to use
-- @param #number AuftragsNr Ops.Auftrag#AUFTRAG.auftragsnummer
-- @return #AWACS self
function AWACS:_CheckInAI(FlightGroup,Group,AuftragsNr)
  self:T(self.lid.."_CheckInAI "..Group:GetName() .. " to Auftrag Nr "..AuftragsNr)
  -- check if already known
  local GID, Outcome = self:_GetManagedGrpID(Group)
  local text = ""
  if not Outcome then
    self.ManagedGrpID = self.ManagedGrpID + 1
    local managedgroup = {} -- #AWACS.ManagedGroup
      managedgroup.Group = Group
      managedgroup.GroupName = Group:GetName()
      managedgroup.FlightGroup = FlightGroup
      managedgroup.IsPlayer = false
      managedgroup.IsAI = true
      --managedgroup.CallSign = self:_GetCallSign(Group,GID) or "AI 1 1"
      --   self.AICAPCAllName = CALLSIGN.F16.Viper (number)
      -- self.AICAPCAllNumber
      local callsignstring = UTILS.GetCallsignName(self.AICAPCAllName)
      local callsignmajor = math.fmod(self.AICAPCAllNumber,9)
      local callsign = string.format("%s %d 1",callsignstring,callsignmajor)
      self:T("Assigned Callsign: ".. callsign)
      managedgroup.CallSign =  callsign
      managedgroup.CurrentAuftrag = AuftragsNr
      managedgroup.HasAssignedTask = false
      managedgroup.GID = self.ManagedGrpID
      managedgroup.TaskQueue = FIFO:New()
    
    -- SRS voice for CAP
    --FlightGroup:SetSRS(PathToSRS,Gender,Culture,Voice,Port,PathToGoogleKey)
    
    FlightGroup:SetDefaultRadio(self.Frequency,self.Modulation,false)
    FlightGroup:SwitchRadio(self.Frequency,self.Modulation)
    --FlightGroup:SetDefaultCallsign(self.AICAPCAllName,callsignmajor)
    
    FlightGroup:SetSRS(self.PathToSRS,self.CAPGender,self.CAPCulture,self.CAPVoice,self.Port,nil,"FLIGHT")
    
    text = string.format("%s. %s. Checking in as fragged. Expected playtime %d hours. Request Alpha Check Bulls Eye.",self.callsigntxt, managedgroup.CallSign, self.CAPTimeOnStation)
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.ToScreen = false
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    RadioEntry.FromAI = true
    RadioEntry.GroupID = managedgroup.GID
    
    self.RadioQueue:Push(RadioEntry)
    
    local alphacheckbulls = self:ToStringBULLS(Group:GetCoordinate())
    alphacheckbulls = self:ToStringBullsTTS(alphacheckbulls)-- make tts friendly
      
    self.ManagedGrps[self.ManagedGrpID]=managedgroup
    text = string.format("%s. %s. Alpha Check. %s",managedgroup.CallSign,self.callsigntxt,alphacheckbulls)
    self:__CheckedIn(1,managedgroup.GID)
    self:__AssignAnchor(5,managedgroup.GID)
  else
    text = string.format("%s. %s. Negative. You are already checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
  end
  
  local RadioEntry = {} -- #AWACS.RadioEntry
  RadioEntry.IsNew = true
  RadioEntry.TextTTS = text
  RadioEntry.ToScreen = false
  RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
  
  self.RadioQueue:Push(RadioEntry)
  
  return self
end

--- [Internal] AWACS Menu for Check Out
-- @param #AWACS self
-- @param Wrapper.Group#GROUP Group Group to use
-- @param #number GID GroupID
-- @param #boolean dead If true, group is dead crashed or otherwise n/a
-- @return #AWACS self
function AWACS:_CheckOut(Group,GID,dead)
  self:T(self.lid.."_CheckOut")

  -- check if already known
  local GID, Outcome = self:_GetManagedGrpID(Group)
  local text = ""
  if Outcome then
    -- yes, known
    text = string.format("%s. %s. Copy. Have a safe flight home.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
    self:T(text)
    -- grab some data before we nil the entry
    local AnchorAssigned = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
    local Stack = AnchorAssigned.AnchorStackNo
    local Angels = AnchorAssigned.AnchorStackAngels
    -- remove menus
    if AnchorAssigned.IsPlayer then
      local menus = self.clientmenus[AnchorAssigned.GroupName] --#AWACS.MenuStructure
      menus.basemenu:Remove()
      self.clientmenus[AnchorAssigned.GroupName] = nil
    end
    self.ManagedGrps[GID] = nil
    self:__CheckedOut(1,GID,Stack,Angels)
  else
    -- no, unknown
    if not dead then
      text = string.format("%s. %s. Negative. You are not checked in.",self:_GetCallSign(Group,GID) or "Ghost 1", self.callsigntxt)
    end
  end
  
  if not dead then
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.ToScreen = true
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    self.RadioQueue:Push(RadioEntry)
  end
  
  return self
end

--- [Internal] AWACS set client menus
-- @param #AWACS self
-- @return #AWACS self
function AWACS:_SetClientMenus()
  self:T(self.lid.."_SetClientMenus")
  local clientset = self.clientset -- Core.Set#SET_GROUP
  local aliveset = clientset:GetAliveSet() -- #table of #GROUP objects
  --local aliveobjects = aliveset:GetSetObjects() or {}
  local clientmenus = {}
  local clientcount = 0
  local clientcheckedin = 0 
  for _,_group in pairs(aliveset) do
    -- go through set and build the menu
    local grp = _group -- Wrapper.Group#GROUP
    if self.MenuStrict then
      -- check if pilot has checked in
      if grp and grp:IsAlive() and grp:GetUnit(1):IsPlayer() then
        clientcount = clientcount + 1
        local GID, checkedin = self:_GetManagedGrpID(grp)
        if checkedin then
          -- full menu minus checkin
          clientcheckedin = clientcheckedin + 1
          
          local hasclientmenu = self.clientmenus[grp:GetName()] -- #AWACS.MenuStructure

          local basemenu = hasclientmenu.basemenu -- Core.Menu#MENU_GROUP_DELAYED)
          
          basemenu:RemoveSubMenus()
          
          local picture = MENU_GROUP_COMMAND_DELAYED:New(grp,"Picture",basemenu,self._Picture,self,grp)
          local bogeydope = MENU_GROUP_COMMAND_DELAYED:New(grp,"Bogey Dope",basemenu,self._BogeyDope,self,grp)
          local declare = MENU_GROUP_COMMAND_DELAYED:New(grp,"Declare",basemenu,self._Declare,self,grp)
          
          local tasking = MENU_GROUP_DELAYED:New(grp,"Tasking",basemenu)
          local showtask = MENU_GROUP_COMMAND_DELAYED:New(grp,"Showtask",tasking,self._Showtask,self,grp)
          local commit = MENU_GROUP_COMMAND_DELAYED:New(grp,"Commit",tasking,self._Commit,self,grp)
          local unable = MENU_GROUP_COMMAND_DELAYED:New(grp,"Unable",tasking,self._Unable,self,grp)
          local abort = MENU_GROUP_COMMAND_DELAYED:New(grp,"Abort",tasking,self._TaskAbort,self,grp)
          local judy = MENU_GROUP_COMMAND_DELAYED:New(grp,"Judy",tasking,self._Judy,self,grp)

          local checkout = MENU_GROUP_COMMAND_DELAYED:New(grp,"Check Out",basemenu,self._CheckOut,self,grp)
          
          basemenu:Set()
          
          clientmenus[grp:GetName()] = { -- #AWACS.MenuStructure
            groupname =  grp:GetName(),
            menuset = true,
            basemenu = basemenu,
            checkout= checkout,
            picture = picture,
            bogeydope = bogeydope,
            declare = declare,
            tasking = tasking,
            showtask = showtask,
            judy = judy,
            unable = unable,
            abort = abort,
            commit=commit,
          }
        elseif not clientmenus[grp:GetName()] then
          -- check in only
          local basemenu = MENU_GROUP_DELAYED:New(grp,self.Name,nil)
          basemenu:RemoveSubMenus()
          local checkin = MENU_GROUP_COMMAND_DELAYED:New(grp,"Check In",basemenu,self._CheckIn,self,grp)
          checkin:SetTag(grp:GetName())
          --checkin:Refresh()
          basemenu:Set()
          
          clientmenus[grp:GetName()] = { -- #AWACS.MenuStructure
            groupname =  grp:GetName(),
            menuset = true,
            basemenu = basemenu,
            checkin = checkin,
          }
          
        end
      end
    else
      if grp and grp:IsAlive() and grp:GetUnit(1):IsPlayer() and not clientmenus[grp:GetName()] then
        local basemenu = MENU_GROUP_DELAYED:New(grp,self.Name,nil)
        basemenu:RemoveSubMenus()
        local picture = MENU_GROUP_COMMAND_DELAYED:New(grp,"Picture",basemenu,self._Picture,self,grp)
        local bogeydope = MENU_GROUP_COMMAND_DELAYED:New(grp,"Bogey Dope",basemenu,self._BogeyDope,self,grp)
        local declare = MENU_GROUP_COMMAND_DELAYED:New(grp,"Declare",basemenu,self._Declare,self,grp)
        
        local tasking = MENU_GROUP_DELAYED:New(grp,"Tasking",basemenu)
        local showtask = MENU_GROUP_COMMAND_DELAYED:New(grp,"Showtask",tasking,self._Showtask,self,grp)
        local commit = MENU_GROUP_COMMAND_DELAYED:New(grp,"Commit",tasking,self._Commit,self,grp)
        local unable = MENU_GROUP_COMMAND_DELAYED:New(grp,"Unable",tasking,self._Unable,self,grp)
        local abort = MENU_GROUP_COMMAND_DELAYED:New(grp,"Abort",tasking,self._TaskAbort,self,grp)
        local judy = MENU_GROUP_COMMAND_DELAYED:New(grp,"Judy",tasking,self._Judy,self,grp)
        
        local checkin = MENU_GROUP_COMMAND_DELAYED:New(grp,"Check In",basemenu,self._CheckIn,self,grp)
        local checkout = MENU_GROUP_COMMAND_DELAYED:New(grp,"Check Out",basemenu,self._CheckOut,self,grp)
        
        basemenu:Set()
        
        clientmenus[grp:GetName()] = { -- #AWACS.MenuStructure
          groupname =  grp:GetName(),
          menuset = true,
          basemenu = basemenu,
          checkin = checkin,
          checkout= checkout,
          picture = picture,
          bogeydope = bogeydope,
          declare = declare,
          showtask = showtask,
          tasking = tasking,
          judy = judy,
          unable = unable,
          abort = abort,
          commit = commit,
        }
      end
    end
  end
  
  self.clientmenus = clientmenus
  self.MonitoringData.Players = clientcount or 0
  self.MonitoringData.PlayersCheckedin = clientcheckedin or 0
    
  return self
end

--- [Internal] AWACS Create a new Anchor Stack
-- @param #AWACS self
-- @return #boolean success
-- @return #nunber AnchorStackNo
function AWACS:_CreateAnchorStack()
  self:T(self.lid.."_CreateAnchorStack")
  local stackscreated = self.AnchorStacks:GetSize()
  if stackscreated == self.AnchorMaxAnchors  then
    -- only create self.AnchorMaxAnchors Anchors
    return false, 0
  end
  local AnchorStackOne = {} -- #AWACS.AnchorData
  AnchorStackOne.AnchorBaseAngels = self.AnchorBaseAngels
  AnchorStackOne.Anchors = FIFO:New() -- Utilities.FiFo#FIFO
  AnchorStackOne.AnchorAssignedID = FIFO:New() -- Utilities.FiFo#FIFO
  
  local newname = self.StationZone:GetName()
  
  for i=1,self.AnchorMaxStacks do
    AnchorStackOne.Anchors:Push((i-1)*self.AnchorStackDistance+self.AnchorBaseAngels)
  end
  
  if stackscreated == 0 then
    local newsubname = AWACS.AnchorNames[stackscreated+1] or tostring(stackscreated+1)
    newname = self.StationZone:GetName() .. "-"..newsubname
    AnchorStackOne.StationZone = self.StationZone
    AnchorStackOne.StationZoneCoordinate = self.StationZone:GetCoordinate()
    AnchorStackOne.StationZoneCoordinateText = self.StationZone:GetCoordinate():ToStringLLDDM()
    AnchorStackOne.StationName = newname
    --push to AnchorStacks
    if self.debug then
      --self.AnchorStacks:Flush()
      AnchorStackOne.StationZone:DrawZone(-1,{0,0,1},1,{0,0,1},0.2,5,true)
      local stationtag = string.format("Station: %s\nCoordinate: %s",newname,self.StationZone:GetCoordinate():ToStringLLDDM())
      AnchorStackOne.AnchorMarker=MARKER:New(AnchorStackOne.StationZone:GetCoordinate(),stationtag):ToAll()
    end
    self.AnchorStacks:Push(AnchorStackOne,newname)
  else
    local newsubname = AWACS.AnchorNames[stackscreated+1] or tostring(stackscreated+1)
    newname = self.StationZone:GetName() .. "-"..newsubname
    local anchorbasecoord = self.OpsZone:GetCoordinate() -- Core.Point#COORDINATE
    -- OpsZone can be Polygon, so use distance to StationZone as radius
    local anchorradius = anchorbasecoord:Get2DDistance(self.StationZone:GetCoordinate())
    --local anchorradius = self.OpsZone:GetRadius() -- #number
    --anchorradius = anchorradius + self.StationZone:GetRadius()
    local angel = self.StationZone:GetCoordinate():GetAngleDegrees(self.OpsZone:GetVec3())
    self:T("Angel Radians= " .. angel)
    local turn = math.fmod(self.AnchorTurn*stackscreated,360) -- #number
    if self.AnchorTurn < 0 then turn = -turn end
    local newanchorbasecoord = anchorbasecoord:Translate(anchorradius,turn+angel) -- Core.Point#COORDINATE
    AnchorStackOne.StationZone = ZONE_RADIUS:New(newname, newanchorbasecoord:GetVec2(), self.StationZone:GetRadius())
    AnchorStackOne.StationZoneCoordinate = newanchorbasecoord
    AnchorStackOne.StationZoneCoordinateText = newanchorbasecoord:ToStringLLDDM()
    AnchorStackOne.StationName = newname
    --push to AnchorStacks
    if self.debug then
      --self.AnchorStacks:Flush()
      AnchorStackOne.StationZone:DrawZone(-1,{0,0,1},1,{0,0,1},0.2,5,true)
      local stationtag = string.format("Station: %s\nCoordinate: %s",newname,self.StationZone:GetCoordinate():ToStringLLDDM())
      AnchorStackOne.AnchorMarker=MARKER:New(AnchorStackOne.StationZone:GetCoordinate(),stationtag):ToAll()
    end
    self.AnchorStacks:Push(AnchorStackOne,newname)
  end

  return true,self.AnchorStacks:GetSize()
  
end

--- [Internal] AWACS get free anchor stack for managed groups
-- @param #AWACS self
-- @return #number AnchorStackNo
-- @return #boolean free 
function AWACS:_GetFreeAnchorStack()
  self:T(self.lid.."_GetFreeAnchorStack")
  local AnchorStackNo, Free = 0, false
  --return AnchorStackNo, Free
  local availablestacks = self.AnchorStacks:GetPointerStack() or {} -- #table
  for _id,_entry in pairs(availablestacks) do
    local entry = _entry -- Utilities.FiFo#FIFO.IDEntry
    local data = entry.data -- #AWACS.AnchorData
    if data.Anchors:IsNotEmpty() then
      AnchorStackNo = _id
      Free = true
      break
    end
  end
  -- TODO - if extension of anchor stacks to max, send AI home
  if not Free then
    -- try to create another stack
    local created, number = self:_CreateAnchorStack()
    if created then
      -- we could create a new one - phew!
      self:_GetFreeAnchorStack()
    end
  end
  return AnchorStackNo, Free
end

--- [Internal] AWACS Assign Anchor Position to a Group
-- @param #AWACS self
-- @return #number GID Managed Group ID
-- @return #AWACS self
function AWACS:_AssignAnchorToID(GID)
  self:T(self.lid.."_AssignAnchorToID")
  local AnchorStackNo, Free = self:_GetFreeAnchorStack()
  if Free then
    -- get the Anchor from the stack
    local Anchor = self.AnchorStacks:PullByPointer(AnchorStackNo) -- #AWACS.AnchorData
    -- pull one free angels
    local freeangels = Anchor.Anchors:Pull()
    -- push GID on anchor
    Anchor.AnchorAssignedID:Push(GID)
    if self.debug then
      --Anchor.AnchorAssignedID:Flush()
      --Anchor.Anchors:Flush()
    end
    -- push back to AnchorStacks
    self.AnchorStacks:Push(Anchor)
    self:T({Anchor,freeangels})
    self:__AssignedAnchor(5,GID,Anchor,AnchorStackNo,freeangels)
  else
    self:E(self.lid .. "Cannot assign free anchor stack to GID ".. GID .. " Trying again in 10secs.")
    -- try again ...
    self:__AssignAnchor(10,GID)
  end
  return self
end

--- [Internal] Remove GID (group) from Anchor Stack
-- @param #AWACS self
-- @param #AWACS.ManagedGroup.GID ID
-- @param #number AnchorStackNo
-- @param #number Angels
-- @return #AWACS self
function AWACS:_RemoveIDFromAnchor(GID,AnchorStackNo,Angels)
  local gid = GID or 0
  local stack = AnchorStackNo or 0
  local angels = Angels or 0
  local debugstring = string.format("%s_RemoveIDFromAnchor for GID=%d Stack=%d Angels=%d",self.lid,gid,stack,angels)
  self:T(debugstring)
  -- pull correct anchor
  if stack > 0 and angels > 0 then
    local AnchorStackNo = AnchorStackNo or 1
    local Anchor = self.AnchorStacks:ReadByPointer(AnchorStackNo) -- #AWACS.AnchorData
    -- pull GID from stack
    local removedID = Anchor.AnchorAssignedID:PullByID(GID)
    -- push free angels to stack
    Anchor.Anchors:Push(Angels)
    -- push back AnchorStack
    --self.AnchorStacks:Push(Anchor)
  end
  return self
end

--- [Internal] Start INTEL detection when we reach the AWACS Orbit Zone
-- @param #AWACS self
-- @param Wrapper.Group#GROUP awacs
-- @return #AWACS self
function AWACS:_StartIntel(awacs)
  self:T(self.lid.."_StartIntel")
  
  if self.intelstarted then return self end
  
  self.DetectionSet:AddGroup(awacs)
  
  local intel = INTEL:New(self.DetectionSet,self.coalition,self.callsigntxt)
  --intel:SetVerbosity(2)
  intel:SetClusterAnalysis(true,false)
  
  local acceptzoneset = SET_ZONE:New()
  acceptzoneset:AddZone(self.ControlZone)
  --acceptzoneset:AddZone(self.OpsZone)
  
  self.OrbitZone:SetRadius(UTILS.NMToMeters(45))
  acceptzoneset:AddZone(self.OrbitZone)
  
  if self.BorderZone then
    acceptzoneset:AddZone(self.BorderZone)
  end
  
  --self.AwacsInZone
  --intel:SetAcceptZones(acceptzoneset)
  
  if self.NoHelos then
    intel:SetFilterCategory({Unit.Category.AIRPLANE})
  else
    intel:SetFilterCategory({Unit.Category.AIRPLANE,Unit.Category.HELICOPTER})
  end
  
  -- Callbacks
  local function NewCluster(Cluster)
    self:__NewCluster(5,Cluster)
  end 
  function intel:OnAfterNewCluster(From,Event,To,Cluster)
    NewCluster(Cluster)
  end
  
  local function NewContact(Contact)
    self:__NewContact(5,Contact)
  end 
  function intel:OnAfterNewContact(From,Event,To,Contact)
   NewContact(Contact)
  end
  
  local function LostContact(Contact)
    self:__LostContact(5,Contact)
  end 
  function intel:OnAfterLostContact(From,Event,To,Contact)
    LostContact(Contact)
  end
  
  local function LostCluster(Cluster,Mission)
    self:__LostCluster(5,Cluster,Mission)
  end
  function intel:OnAfterLostCluster(From,Event,To,Cluster,Mission)
    LostCluster(Cluster,Mission)
  end
  
  self.intelstarted = true
  
  intel:__Start(2)
  
  self.intel = intel -- Ops.Intelligence#INTEL
  return self
end

--- [Internal] Get blurred size of group or cluster
-- @param #AWACS self
-- @param #number size
-- @return #number adjusted size
-- @return #string AWACS.Shipsize entry for size 1..3
function AWACS:_GetBlurredSize(size)
  self:T(self.lid.."_GetBlurredSize")
  local threatsize = 0
  local blur = self.RadarBlur
  local blurmin = 100 - blur
  local blurmax = 100 + blur
  local actblur = math.random(blurmin,blurmax) / 100
  threatsize = math.floor(size * actblur)
  if threatsize == 0 then threatsize = 1 end
  if threatsize then end
  local threatsizetext = AWACS.Shipsize[1]
  if threatsize == 2  then 
    threatsizetext = AWACS.Shipsize[2]
  elseif threatsize >2 then 
    threatsizetext = AWACS.Shipsize[3]
  end
  return threatsize, threatsizetext
end

--- [Internal] Get threat level as clear test
-- @param #AWACS self
-- @param #number threatlevel
-- @return #string threattext
function AWACS:_GetThreatLevelText(threatlevel)
  self:T(self.lid.."_GetThreatLevelText")
  local threattext = "GREEN"
  if threatlevel <= AWACS.THREATLEVEL.GREEN then
   threattext = "GREEN"
  elseif threatlevel <= AWACS.THREATLEVEL.AMBER then
   threattext = "AMBER"
  else
    threattext = "RED"
  end
  return threattext
end

--- [Internal] Get BRA text for TTS
-- @param #AWACS self
-- @param Core.Point#COORDINATE clustercoordinate
-- @return #string BRAText
function AWACS:_GetBRAfromBullsOrAO(clustercoordinate)
  self:T(self.lid.."__GetBRAfromBullsOrAO")
  local refcoord = self.AOCoordinate -- Core.Point#COORDINATE
  local BRAText = ""
  if not self.UseBullsAO then
    -- get BR from AO
    local bullsname = self.AOName or "Rock"
    BRAText = string.format("%s %s",bullsname,refcoord:ToStringBR(clustercoordinate))
    --BRAText = "AO "..refcoord:ToStringBR(clustercoordinate)
  else
    -- get BR from Bulls
    BRAText = self:ToStringBULLS(clustercoordinate)
    -- BRAText = clustercoordinate:ToStringBULLS(self.coalition)
  end
  return BRAText
end

--- [Internal] Register Task for Group by GID
-- @param #AWACS self
-- @param #number GroupID ManagedGroup ID
-- @param #AWACS.TaskDescription Description Short Description Task Type
-- @param #string ScreenText Long task description for screen output
-- @param #table Object Object for Ops.Target#TARGET assignment
-- @param #AWACS.TaskStatus TaskStatus Status of this task
-- @param Ops.Auftrag#AUFTRAG Auftrag The Auftrag for this task if any
-- @return #number TID Task ID created
function AWACS:_CreateTaskForGroup(GroupID,Description,ScreenText,Object,TaskStatus,Auftrag)
   self:I(self.lid.."_CreateTaskForGroup "..GroupID .." Description: "..Description)
   
   local managedgroup = self.ManagedGrps[GroupID] -- #AWACS.ManagedGroup
   local task = {} -- #AWACS.ManagedTask
   self.ManagedTaskID = self.ManagedTaskID + 1
   task.TID = self.ManagedTaskID
   task.AssignedGroupID = GroupID
   task.Status = TaskStatus or AWACS.TaskStatus.ASSIGNED
   task.ToDo = Description
   task.Auftrag = Auftrag
   if Object and Object:IsInstanceOf("TARGET") then
    task.Target = Object
   else
    task.Target = TARGET:New(Object)
   end
   task.ScreenText = ScreenText
   if Description == AWACS.TaskDescription.ANCHOR or Description == AWACS.TaskDescription.REANCHOR then
    task.Target.Type = TARGET.ObjectType.ZONE
   end
   
   self.ManagedTasks:Push(task,task.TID)

   managedgroup.HasAssignedTask = true
   managedgroup.CurrentTask = task.TID
   managedgroup.TaskQueue:Push(task.TID)

   self.ManagedGrps[GroupID] = managedgroup

   return task.TID 
end 

--- [Internal] Read registered Task for Group by its ID
-- @param #AWACS self
-- @param #number GroupID ManagedGroup ID
-- @return #AWACS.ManagedTask Task or nil if n/e
function AWACS:_ReadAssignedTaskFromGID(GroupID)
   self:T(self.lid.."_GetAssignedTaskFromGID "..GroupID)
   local managedgroup = self.ManagedGrps[GroupID] -- #AWACS.ManagedGroup
   if managedgroup and managedgroup.HasAssignedTask then
     local TaskID = managedgroup.CurrentTask
     if self.ManagedTasks:HasUniqueID(TaskID) then
      return self.ManagedTasks:ReadByID(TaskID)
     end
   end
   return nil
end

--- [Internal] Read assigned Group from a TaskID
-- @param #AWACS self
-- @param #number TaskID ManagedTask ID
-- @return #AWACS.ManagedGroup Group structure or nil if n/e
function AWACS:_ReadAssignedGroupFromTID(TaskID)
   self:T(self.lid.."_ReadAssignedGroupFromTID "..TaskID)
   if self.ManagedTasks:HasUniqueID(TaskID) then
    local task = self.ManagedTasks:ReadByID(TaskID) -- #AWACS.ManagedTask
    if task and task.AssignedGroupID and task.AssignedGroupID > 0 then
      return self.ManagedGrps[task.AssignedGroupID]
    end
   end
   return nil
end

--- [Internal] Create new idle task from contact to pick up later
-- @param #AWACS self
-- @param #string Description Task Type
-- @param #table Object Object of TARGET
-- @param Ops.Intelligence#INTEL.Contact Contact
-- @return #AWACS self
function AWACS:_CreateIdleTaskForContact(Description,Object,Contact)
   self:T(self.lid.."_CreateIdleTaskForContact "..Description)
   local task = {} -- #AWACS.ManagedTask
   self.ManagedTaskID = self.ManagedTaskID + 1
   task.TID = self.ManagedTaskID
   task.AssignedGroupID = 0
   task.Status = AWACS.TaskStatus.IDLE
   task.ToDo = Description
   task.Target = TARGET:New(Object)
   task.Contact = Contact
   --task.IsContact = true
   task.ScreenText = Description
   if Description == AWACS.TaskDescription.ANCHOR or Description == AWACS.TaskDescription.REANCHOR then
    task.Target.Type = TARGET.ObjectType.ZONE
   end
   self.ManagedTasks:Push(task,task.TID)
   return self
end  

--- [Internal] Create new idle task from cluster to pick up later
-- @param #AWACS self
-- @param #string Description Task Type
-- @param #table Object Object of TARGET
-- @param Ops.Intelligence#INTEL.Cluster Cluster
-- @return #AWACS self
function AWACS:_CreateIdleTaskForCluster(Description,Object,Cluster)
   self:T(self.lid.."_CreateIdleTaskForCluster "..Description)
   local task = {} -- #AWACS.ManagedTask
   self.ManagedTaskID = self.ManagedTaskID + 1
   task.TID = self.ManagedTaskID
   task.AssignedGroupID = 0
   task.Status = AWACS.TaskStatus.IDLE
   task.ToDo = Description
   --self:T({Cluster.Contacts})
   --task.Target = TARGET:New(Cluster.Contacts[1])
   task.Target = TARGET:New(self.intel:GetClusterCoordinate(Cluster))
   task.Cluster = Cluster
   --task.IsCluster = true
   task.ScreenText = Description
   if Description == AWACS.TaskDescription.ANCHOR or Description == AWACS.TaskDescription.REANCHOR then
    task.Target.Type = TARGET.ObjectType.ZONE
   end
   self.ManagedTasks:Push(task,task.TID)
   return self
end 

--- [Internal] Create radio entry to tell players that CAP is on station in Anchor
-- @param #AWACS self
-- @param #number GID Group ID 
-- @return #AWACS self
function AWACS:_MessageAIReadyForTasking(GID)
  self:T(self.lid.."_MessageAIReadyForTasking")
  -- obtain group details
  if GID >0  and self.ManagedGrps[GID] then
    local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
    local GFCallsign = self:_GetCallSign(managedgroup.Group)
    local TextTTS = string.format("%s. %s. On station over anchor %d at angels  %d. Ready for tasking.",GFCallsign,self.callsigntxt,managedgroup.AnchorStackNo or 1,managedgroup.AnchorStackAngels or 25)
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.TextTTS = TextTTS
    RadioEntry.TextScreen = ""
    RadioEntry.IsNew = true
    RadioEntry.IsGroup = false
    RadioEntry.GroupID = GID
    RadioEntry.Duration = STTS.getSpeechTime(TextTTS,0.95,false)+2 or 16
    RadioEntry.ToScreen = false
    RadioEntry.FromAI = true
    
    self.RadioQueue:Push(RadioEntry)
  end
  return self
end

--- [Internal] Update Contact Tag
-- @param #AWACS self
-- @param #number CID Contact ID
-- @param #string Text Text to be used 
-- @return #AWACS self
function AWACS:_UpdateContactEngagementTag(CID,Text)
  self:I(self.lid.."_UpdateContactEngagementTag")
  local text = Text or ""
  -- get contact
  local contact = self.Contacts:PullByID(CID) -- #AWACS.ManagedContact
  if contact then
    contact.EngagementTag = text
    self.Contacts:Push(contact,CID)
  end
  return self
end

--- [Internal] Check available tasks and status
-- @param #AWACS self
-- @return #AWACS self
function AWACS:_CheckTaskQueue()
  self:I(self.lid.."_CheckTaskQueue")
  local opentasks = 0
  local assignedtasks = 0
  
  ----------------------------------------
  -- ANCHOR
  ----------------------------------------
  
  if self.ManagedTasks:IsNotEmpty() then
    opentasks = self.ManagedTasks:GetSize()
    self:I("Assigned Tasks: " .. opentasks)
    local taskstack = self.ManagedTasks:GetPointerStack()
    for _id,_entry in pairs(taskstack) do
      local data = _entry -- Utilities.FiFo#FIFO.IDEntry
      local entry = data.data -- #AWACS.ManagedTask
      local target = entry.Target -- Ops.Target#TARGET
      local description = entry.ToDo
      if description == AWACS.TaskDescription.ANCHOR or description == AWACS.TaskDescription.REANCHOR then
        --self:I("Open Task ANCHOR/REANCHOR")
        -- see if we have reached the anchor zone
        local managedgroup = self.ManagedGrps[entry.AssignedGroupID] -- #AWACS.ManagedGroup
        if managedgroup then
          local group = managedgroup.Group
          if group and group:IsAlive() then
            local groupcoord = group:GetCoordinate()
            local zone = target:GetObject() -- Core.Zone#ZONE
            self:T({zone})
            if group:IsInZone(zone) then
              self:I("Open Task ANCHOR/REANCHOR success for GroupID "..entry.AssignedGroupID)
              -- made it
              target:Stop()
              -- add group to idle stack
              if managedgroup.IsAI then
                -- message AI on station
                self:_MessageAIReadyForTasking(managedgroup.GID)
              elseif managedgroup.IsPlayer then
                --self.TaskedCAPHuman:PullByPointer(entry.AssignedGroupID)
                --self.CAPIdleHuman:Push(entry.AssignedGroupID)
              end -- end isAI
              managedgroup.HasAssignedTask = false
              self.ManagedGrps[entry.AssignedGroupID] = managedgroup
              -- pull task from OpenTasks
              self.ManagedTasks:PullByID(entry.TID)
            else --inzone
              -- not there yet
              self:I("Open Task ANCHOR/REANCHOR executing for GroupID "..entry.AssignedGroupID)
            end
          else
            -- group dead, pull task
            self.ManagedTasks:PullByID(entry.TID)
          end
        end
      
      ----------------------------------------
      -- INTERCEPT
      ----------------------------------------
        
      elseif description == AWACS.TaskDescription.INTERCEPT then
        -- DONE
        self:I("Open Tasks INTERCEPT")
        local taskstatus = entry.Status
        local targetstatus = entry.Target:GetState()
        
        if taskstatus == AWACS.TaskStatus.UNASSIGNED then
          -- thou shallst not be in this list!      
          self.ManagedTasks:PullByID(entry.TID)
          break
        end
        
        local auftrag = entry.Auftrag -- Ops.Auftrag#AUFTRAG
        local auftragstatus = "Not Known"
        if auftrag then
          auftragstatus = auftrag:GetState()
        end 
        local text = string.format("ID=%d | Status=%s | TargetState=%s | AuftragState=%s",entry.TID,taskstatus,targetstatus,auftragstatus)
        self:I(text)
        if auftrag then
          if auftrag:IsExecuting() then
            entry.Status = AWACS.TaskStatus.EXECUTING
          elseif auftrag:IsSuccess() then
            entry.Status = AWACS.TaskStatus.SUCCESS
          elseif auftrag:GetState() == AUFTRAG.Status.FAILED then 
            entry.Status = AWACS.TaskStatus.FAILED
          end 
          if targetstatus == "Dead" then
            entry.Status = AWACS.TaskStatus.SUCCESS
          elseif targetstatus == "Alive" and auftrag:IsOver() then
            entry.Status = AWACS.TaskStatus.FAILED
          end
        else
          -- Player task
          -- TODO
        end
        
        local managedgroup = self.ManagedGrps[entry.AssignedGroupID] -- #AWACS.ManagedGroup
        
        if entry.Status == AWACS.TaskStatus.SUCCESS then
          self:I("Open Tasks INTERCEPT success for GroupID "..entry.AssignedGroupID)
          if managedgroup then
          
            self:_UpdateContactEngagementTag(managedgroup.ContactCID,"")
            
            managedgroup.HasAssignedTask = false
            managedgroup.ContactCID = 0
            
            if managedgroup.IsAI then
              managedgroup.CurrentAuftrag = 0
            else
              managedgroup.CurrentTask = 0
            end
            
            self.ManagedGrps[entry.AssignedGroupID] = managedgroup
            self.ManagedTasks:PullByID(entry.TID)
            
            self:__InterceptSuccess(1)
            self:__ReAnchor(5,managedgroup.GID)
          end
         
        elseif entry.Status == AWACS.TaskStatus.FAILED then
          self:I("Open Tasks INTERCEPT failed for GroupID "..entry.AssignedGroupID)
          if managedgroup then
            managedgroup.HasAssignedTask = false
            self:_UpdateContactEngagementTag(managedgroup.ContactCID,"")
            managedgroup.ContactCID = 0
            if managedgroup.IsAI then
              managedgroup.CurrentAuftrag = 0
            else
              managedgroup.CurrentTask = 0
            end
            if managedgroup.IsPlayer then
              entry.IsPlayerTask = false
            end 
            self.ManagedGrps[entry.AssignedGroupID] = managedgroup
          end
          -- re-assign, if possible. FG state? Issue re-anchor
          entry.IsUnassigned = true
          entry.CurrentAuftrag = 0
          entry.Auftrag = nil
          entry.Status = AWACS.TaskStatus.UNASSIGNED
          entry.AssignedGroupID = 0           
          self.ManagedTasks:PullByID(entry.TID)
          --self.ManagedTasks:Push(entry,entry.TID)
          self:__InterceptFailure(1)
          self:__ReAnchor(5,managedgroup.GID)
        end
        
      ----------------------------------------
      -- OTHER
      ----------------------------------------
        
      elseif description == AWACS.TaskDescription.RTB then
       -- TODO
      end
      
    end
  end
  
  return self
end

--- [Internal] Write stats to log
-- @param #AWACS self
-- @return #AWACS self
function AWACS:_LogStatistics()
  self:T(self.lid.."_LogStatistics")
  local text = string.gsub(UTILS.OneLineSerialize(self.MonitoringData),",","\n")
  local text = string.gsub(text,"{","\n")
  local text = string.gsub(text,"}","")
  local text = string.gsub(text,"="," = ")
  self:T(text)
  if self.MonitoringOn then
    MESSAGE:New(text,20,"AWACS",false):ToAll()
  end
  return self 
end

--- [User] Add another AirWing for CAP Flights under management
-- @param #AWACS self
-- @param Ops.AirWing#AIRWING AirWing The AirWing to (also) obtain CAP flights from
-- @return #AWACS self
function AWACS:AddCAPAirWing(AirWing)
  self:T(self.lid.."AddCAPAirWing")
  if AirWing then
    AirWing:SetUsingOpsAwacs(self)
    local distance = self.AOCoordinate:Get2DDistance(AirWing:GetCoordinate())
    self.CAPAirwings:Push(AirWing,distance)
  end
  return self
end

--- Recruit assets for a given TARGET.
-- @param #AWACS self
-- @param #string MissionType Mission Type.
-- @param #number NassetsMin Min number of required assets.
-- @param #number NassetsMax Max number of required assets.
-- @return #boolean If `true` enough assets could be recruited.
-- @return #table Assets that have been recruited from all legions.
-- @return #table Legions that have recruited assets.
function AWACS:RecruitAssets(MissionType, NassetsMin, NassetsMax)

  -- Cohorts.
  local Cohorts={}
  local AWFiFo = self.CAPAirwings -- Utilities.FiFo#FIFO
  local AWStack = AWFiFo:GetPointerStack()
  local AirWingList = {}
  
  for _ID,_AWID in pairs(AWStack) do
    local SubAW = self.CAPAirwings:ReadByPointer(_ID)
    if SubAW then
      table.insert(AirWingList,SubAW)
    end
  end
  
  for _,_legion in pairs(AirWingList) do
    local legion=_legion --Ops.Legion#LEGION
    
    -- Check that runway is operational
    local Runway=legion:IsAirwing() and legion:IsRunwayOperational() or true
    
    if legion:IsRunning() and Runway then    
    
      -- Loops over cohorts.
      for _,_cohort in pairs(legion.cohorts) do
        local cohort=_cohort --Ops.Cohort#COHORT
        table.insert(Cohorts, cohort)
      end
      
    end
  end  

  -- Target position.
  local TargetVec2=self.OpsZone:GetVec2()
  
  -- Recruit assets.
  local recruited, assets, legions=LEGION.RecruitCohortAssets(Cohorts, MissionType, nil, NassetsMin, NassetsMax, TargetVec2)
  
  return recruited, assets, legions
end

--- [Internal] Announce a new contact
-- @param #AWACS self
-- @param Ops.Intelligence#INTEL.Contact Contact
-- @param #boolean IsNew Is a new contact
-- @param Wrapper.Group#GROUP Group Announce to Group if not nil
-- @param #boolean IsBogeyDope If true, this is a bogey dope announcement
-- @param #string Tag Tag name for this contact. Alpha, Brave, Charlie ... 
-- @param #boolean IsPopup This is a pop-up group
-- @param #string ReportingName The NATO code reporting name for the contact, e.g. "Foxbat". "Bogey" if unknown.
-- @return #AWACS self
function AWACS:_AnnounceContact(Contact,IsNew,Group,IsBogeyDope,Tag,IsPopup,ReportingName)
  self:T(self.lid.."_AnnounceContact")
  -- do we have a group to talk to?
  local tag = ""
  local Tag = Tag
  local CID = 0
  if not Tag then
    -- injected data available?
    CID = Contact.CID or 0
    Tag = Contact.TargetGroupNaming or ""
    --self:I({CID,Tag})
  end
  local isGroup = false
  local GID = 0
  local grpcallsign = "Ghost 1"
  if Group and Group:IsAlive() then
    GID, isGroup = self:_GetManagedGrpID(Group)
    self:T("GID="..GID.." CheckedIn = "..tostring(isGroup))
    grpcallsign = self:_GetCallSign(Group,GID) or "Ghost 1"
  end
  
  local contact = Contact -- Ops.Intelligence#INTEL.Contact
  local intel = self.intel -- Ops.Intelligence#INTEL
  local size = contact.group:CountAliveUnits()
  local threatsize, threatsizetext = self:_GetBlurredSize(size)
  local threatlevel = contact.threatlevel
  local threattext = self:_GetThreatLevelText(threatlevel)
  local clustercoordinate = contact.group:GetCoordinate()
  clustercoordinate:SetHeading(contact.group:GetHeading())
  
  local BRAfromBulls = self:_GetBRAfromBullsOrAO(clustercoordinate).."."
  if isGroup then
    BRAfromBulls = clustercoordinate:ToStringBRAANATO(Group:GetCoordinate(),IsNew)
  end
  
  -- "Uzi 1-1, Magic, BRA, 183 for 10 at 2000, hot"
  -- "<togroup>, <fromgroup>, <New>/<Contact>, <tag>, <shipsize>, BRA, <bearing> for <range> at angels <alt/1000>, <aspect>"
  
  local BRAText = ""
  local TextScreen = ""
  
  if isGroup then
    BRAText = string.format("%s, %s.",grpcallsign,self.callsigntxt)
    TextScreen = string.format("%s, %s.",grpcallsign,self.callsigntxt)
  else
    BRAText = string.format("%s.",self.callsigntxt)
    TextScreen = string.format("%s.",self.callsigntxt)
  end
  
  if IsNew then
    BRAText = BRAText .. " New group."
    TextScreen = TextScreen .. " New group."
  elseif IsPopup then
    BRAText = BRAText .. " Pop-up group."
    TextScreen = TextScreen .. " Pop-up group."
  elseif IsBogeyDope and Tag and Tag ~= "" then
    BRAText = BRAText .. " "..Tag.." group."
    TextScreen = TextScreen .. " "..Tag.." group."
  else
    BRAText = BRAText .. " Group."
    TextScreen = TextScreen .. " Group."
  end
  
  if not IsBogeyDope then
    if Tag and Tag ~= "" then
      BRAText = BRAText .. " "..Tag.."."
      TextScreen = TextScreen .. " "..Tag.."."
    end
  end
  
  BRAText = BRAText .. " "..threatsizetext..". "..BRAfromBulls
  TextScreen = TextScreen .. " "..threatsizetext..". "..BRAfromBulls
  
  if self.ModernEra then
    -- Platform
    if ReportingName and ReportingName ~= "Bogey" then
      ReportingName = string.gsub(ReportingName,"_"," ")
      BRAText = BRAText .. " "..ReportingName.."."
      TextScreen = TextScreen .. " "..ReportingName.."."
    end
    -- High - > 40k feet
    local height = contact.group:GetHeight()
    local height = UTILS.Round(UTILS.MetersToFeet(height)/1000,0) -- e.g, 25
    if height >= 40 then
      BRAText = BRAText .. " High."
      TextScreen = TextScreen .. " High."
    end
    -- Fast (>600kn) or Very fast (>900kn)
    local speed = contact.group:GetVelocityKNOTS()
    if speed > 900 then
      BRAText = BRAText .. " Very Fast."
      TextScreen = TextScreen .. " Very Fast."
    elseif speed >= 600 and speed <= 900 then
      BRAText = BRAText .. " Fast."
      TextScreen = TextScreen .. " Fast."
    end
  end
  
  --self:I(BRAText)
  
  local RadioEntry = {} -- #AWACS.RadioEntry
  RadioEntry.TextTTS = BRAText
  RadioEntry.TextScreen = TextScreen
  RadioEntry.IsNew = IsNew
  RadioEntry.IsGroup = isGroup
  RadioEntry.GroupID = GID
  RadioEntry.Duration = STTS.getSpeechTime(BRAText,0.95,false)+2 or 16
  RadioEntry.ToScreen = true
  
  self.RadioQueue:Push(RadioEntry)

  return self
end

--- [Internal] Check for alive OpsGroup from Mission OpsGroups table
-- @param #AWACS self
-- @param #table OpsGroups
-- @return Ops.OpsGroup#OPSGROUP or nil
function AWACS:_GetAliveOpsGroupFromTable(OpsGroups)
  self:T(self.lid.."_GetAliveOpsGroupFromTable")
  local handback = nil 
  for _,_OG in pairs(OpsGroups or {}) do
    local OG = _OG -- Ops.OpsGroup#OPSGROUP
    if OG and OG:IsAlive() then
      handback = OG
      --self:I("Handing back OG: " .. OG:GetName())
      break
    end
  end 
  return handback
end

--- [Internal] Clean up mission stack
-- @param #AWACS self
-- @return #number CAPMissions
-- @return #number Alert5Missions
-- @return #number InterceptMissions
function AWACS:_CleanUpAIMissionStack()
  self:T(self.lid.."_CleanUpAIMissionStack")
  
  local CAPMissions = 0
  local Alert5Missions = 0
  local InterceptMissions = 0
  
  local MissionStack = FIFO:New()
  
  self:T("Checking MissionStack")
  for _,_mission in pairs(self.CatchAllMissions) do
    -- looking for missions of type CAP and ALERT5
    local mission = _mission -- Ops.Auftrag#AUFTRAG
    local type = mission:GetType()
    if type == AUFTRAG.Type.ALERT5 then
      MissionStack:Push(mission,mission.auftragsnummer)
      Alert5Missions = Alert5Missions + 1
    elseif type == AUFTRAG.Type.CAP then
      MissionStack:Push(mission,mission.auftragsnummer)
      CAPMissions = CAPMissions + 1
    elseif type == AUFTRAG.Type.INTERCEPT then
      MissionStack:Push(mission,mission.auftragsnummer)
      InterceptMissions = InterceptMissions + 1
    end
  end
  
  self.AICAPMissions = nil
  self.AICAPMissions = MissionStack
  
  return CAPMissions, Alert5Missions, InterceptMissions
  
end

function AWACS:_ConsistencyCheck()
  self:T(self.lid.."_ConsistencyCheck")
  if self.debug then
    self:T("CatchAllMissions")
    local catchallm = {}
    local report1 = REPORT:New("CatchAll")
    report1:Add("====================")
    report1:Add("CatchAllMissions")
    report1:Add("====================")
    for _,_mission in pairs(self.CatchAllMissions) do
      local mission = _mission -- Ops.Auftrag#AUFTRAG
      local nummer = mission.auftragsnummer or 0
      local type = mission:GetType()
      local state = mission:GetState()
      local FG = mission:GetOpsGroups()
      local OG = self:_GetAliveOpsGroupFromTable(FG)
      local OGName = "UnknownFromMission"
      if OG then
        OGName=OG:GetName()
      end
      report1:Add(string.format("Auftrag Nr %d Type %s State %s FlightGroup %s",nummer,type,state,OGName))
      if mission:IsNotOver() then
        catchallm[#catchallm+1] = mission
      end
    end
    
    self.CatchAllMissions = nil
    self.CatchAllMissions = catchallm
    
    local catchallfg = {}
    
    self:T("CatchAllFGs")
    report1:Add("====================")
    report1:Add("CatchAllFGs")
    report1:Add("====================")
    for _,_fg in pairs(self.CatchAllFGs) do
      local FG = _fg -- Ops.FlightGroup#FLIGHTGROUP
      local mission = FG:GetMissionCurrent()
      local OGName = FG:GetName() or "UnknownFromFG"
      local nummer = 0
      local type = "No Type"
      local state = "None"
      if mission then
        type = mission:GetType()
        nummer = mission.auftragsnummer or 0
        state = mission:GetState()
      end
      report1:Add(string.format("Auftrag Nr %d Type %s State %s FlightGroup %s",nummer,type,state,OGName))
      if FG:IsAlive() then
        catchallfg[#catchallfg+1] = FG
      end
    end
    report1:Add("====================")
    self:T(report1:Text())
    
    self.CatchAllFGs = nil
    self.CatchAllFGs = catchallfg
    
  end
  return self
end

--- [Internal] Check Enough AI CAP on Station
-- @param #AWACS self
-- @return #AWACS self
function AWACS:_CheckAICAPOnStation()
  self:T(self.lid.."_CheckAICAPOnStation")
  
  self:_ConsistencyCheck()
  
  local capmissions, alert5missions, interceptmissions = self:_CleanUpAIMissionStack()
  self:T({capmissions, alert5missions, interceptmissions})
  
  if self.MaxAIonCAP > 0 then
    --local onstation = self.AICAPMissions:Count()
    local onstation = capmissions + alert5missions
    -- control number of AI CAP Flights
    if self.AIRequested < self.MaxAIonCAP then
      -- not enough
      local AnchorStackNo,free = self:_GetFreeAnchorStack()
      if free then
        -- create Alert5 and assign to ONE of our AWs
        -- TODO better selection due to resource shortage?
        local mission = AUFTRAG:NewALERT5(AUFTRAG.Type.CAP)
        self.CatchAllMissions[#self.CatchAllMissions+1] = mission
        local availableAWS = self.CAPAirwings:Count()
        local AWS = self.CAPAirwings:GetDataTable()
        -- random
        local selectedAW = AWS[math.random(1,availableAWS)]
        selectedAW:AddMission(mission)
        self.AIRequested = self.AIRequested + 1
        self:T("CAP="..capmissions.." ALERT5="..alert5missions.." Requested="..self.AIRequested)
      end
    end

    if self.AIRequested > self.MaxAIonCAP then
      -- too many, send one home
      self:T(string.format("*** Onstation %d > MaxAIOnCAP %d",onstation,self.MaxAIonCAP))
      local mission = self.AICAPMissions:Pull() -- Ops.Auftrag#AUFTRAG
      local Groups = mission:GetOpsGroups()
      local OpsGroup = self:_GetAliveOpsGroupFromTable(Groups)
      local GID,checkedin = self:_GetManagedGrpID(OpsGroup)
      mission:__Cancel(30)
      self.AIRequested = self.AIRequested - 1
      if checkedin then
        self:_CheckOut(OpsGroup,GID)
      end
    end
    
    -- Check CAP Mission states
    if onstation > 0 then
      local missions = self.AICAPMissions:GetDataTable()
      -- get mission type and state
      for _,_Mission in pairs(missions) do
        --local mission = self.AICAPMissions:ReadByID(_MissionID) -- Ops.Auftrag#AUFTRAG
        local mission = _Mission -- Ops.Auftrag#AUFTRAG
        self:T("Looking at AuftragsNr " .. mission.auftragsnummer)
        local type = mission:GetType()
        local state = mission:GetState()
        --if type == AUFTRAG.Type.CAP or type == AUFTRAG.Type.ALERT5 or type == AUFTRAG.Type.ORBIT then
        if type == AUFTRAG.Type.ALERT5 then
          -- parked up for CAP
          local OpsGroups = mission:GetOpsGroups()
          local OpsGroup = self:_GetAliveOpsGroupFromTable(OpsGroups)
          local FGstate = mission:GetGroupStatus(OpsGroup)
          if OpsGroup then
             FGstate = OpsGroup:GetState()
             self:T("FG Object in state: " .. FGstate)
          end
          -- FG ready?
         -- if OpsGroup and (state == AUFTRAG.Status.STARTED or FGstate ==  AUFTRAG.Status.EXECUTING or FGstate ==  AUFTRAG.Status.SCHEDULED) then
          if OpsGroup and (FGstate == "Parking" or FGstate == "Cruising") then
            -- has this group checked in already? Avoid double tasking
            local GID, CheckedInAlready = self:_GetManagedGrpID(OpsGroup:GetGroup())
            if not CheckedInAlready then
              self:_SetAIROE(OpsGroup,OpsGroup:GetGroup())
              self:_CheckInAI(OpsGroup,OpsGroup:GetGroup(),mission.auftragsnummer)
            end
          end
        end
      end
    end
    
    -- cycle mission status
    if onstation > 0 then
      local report = REPORT:New("CAP Mission Status")
      report:Add("===============")
      --local missionIDs = self.AICAPMissions:GetIDStackSorted()
      local missions = self.AICAPMissions:GetDataTable()
      local i = 1
      for _,_Mission in pairs(missions) do 
      --for i=1,self.MaxAIonCAP do
        --local mission = self.AICAPMissions:ReadByID(_MissionID) -- Ops.Auftrag#AUFTRAG
        --local mission = self.AICAPMissions:ReadByPointer(i) -- Ops.Auftrag#AUFTRAG
        local mission = _Mission -- Ops.Auftrag#AUFTRAG
        if mission then
          i = i + 1
          report:Add(string.format("Entry %d",i))
          report:Add(string.format("Mission No %d",mission.auftragsnummer))
          report:Add(string.format("Mission Type %s",mission:GetType()))
          report:Add(string.format("Mission State %s",mission:GetState()))
          local OpsGroups = mission:GetOpsGroups()
          local OpsGroup = self:_GetAliveOpsGroupFromTable(OpsGroups) -- Ops.OpsGroup#OPSGROUP
          if OpsGroup then
            local OpsName = OpsGroup:GetName() or "Unknown"
            --local OpsCallSign = OpsGroup:GetCallsignName() or "Unknown"
            local found,GID,OpsCallSign = self:_GetGIDFromGroupOrName(OpsGroup)
            report:Add(string.format("Mission FG %s",OpsName))
            report:Add(string.format("Callsign %s",OpsCallSign))
            report:Add(string.format("Mission FG State %s",OpsGroup:GetState()))
          else
            report:Add("***** Cannot obtain (yet) this missions OpsGroup!")
          end
          report:Add(string.format("Target Type %s",mission:GetTargetType()))
        end
        report:Add("===============") 
      end
      if self.debug then
        self:I(report:Text())
      end    
    end
  end
  return self
end

--- [Internal] Set ROE for AI CAP
-- @param #AWACS self
-- @param Ops.FlightGroup#FLIGHTGROUP FlightGroup
-- @param Wrapper.Group#GROUP Group
-- @return #AWACS self
function AWACS:_SetAIROE(FlightGroup,Group)
  self:T(self.lid.."_SetAIROE")
  local ROE = self.AwacsROE or AWACS.ROE.POLICE
  local ROT = self.AwacsROT or AWACS.ROT.PASSIVE
  
  -- TODO adjust to AWACS set ROE
  -- for the time being set to be defensive
  Group:OptionAlarmStateGreen()
  Group:OptionECM_OnlyLockByRadar()
  Group:OptionROEHoldFire()
  Group:OptionROTEvadeFire()
  Group:OptionRTBBingoFuel(true)
  Group:OptionKeepWeaponsOnThreat()
  local callname = self.AICAPCAllName or CALLSIGN.Aircraft.Colt
  self.AICAPCAllNumber = self.AICAPCAllNumber + 1 
  Group:CommandSetCallsign(callname,math.fmod(self.AICAPCAllNumber,9))
  -- FG level
  FlightGroup:SetDefaultAlarmstate(AI.Option.Ground.val.ALARM_STATE.GREEN)
  FlightGroup:SetDefaultCallsign(callname,math.fmod(self.AICAPCAllNumber,9))
  FlightGroup:SetDefaultROE(ENUMS.ROE.WeaponHold)
  FlightGroup:SetDefaultROT(ENUMS.ROT.EvadeFire)
  FlightGroup:SetFuelLowRTB(true)
  FlightGroup:SetFuelLowThreshold(0.2)
  FlightGroup:SetEngageDetectedOff()
  FlightGroup:SetOutOfAAMRTB(true)
  return self
end

--- [Internal] Assign a Pilot to a target
-- @param #AWACS self
-- @param #table Pilots Table of #AWACS.ManagedGroup Pilot 
-- @param #AWACS.ManagedContact Target
-- @return #AWACS self 
function AWACS:_AssignPilotToTarget(Pilots,Target)
  self:I(self.lid.."_AssignPilotToTarget")
  
  local inreach = false
  local Pilot = nil
  
  -- Check Distance
  local targetgroupcoord = Target.Contact.position
  local closest = UTILS.NMToMeters(self.maxassigndistance+1)
  
  -- get closest pilot from target
  for _,_Pilot in pairs(Pilots) do
    local pilotcoord = _Pilot.Group:GetCoordinate()
    local targetdist = targetgroupcoord:Get2DDistance(pilotcoord)
    if UTILS.MetersToNM(targetdist) < self.maxassigndistance and targetdist < closest then
      self:I(string.format("%sTarget distance %d! Assignment %s!",self.lid,UTILS.Round(UTILS.MetersToNM(targetdist),0),_Pilot.CallSign))
      inreach = true
      closest = targetdist
      Pilot = _Pilot
    else
      self:I(self.lid .. "Target distance > "..self.maxassigndistance.."NM! No Assignment!")
    end
  end

  -- TODO Currently doing AI only
  if inreach and Pilot and Pilot.IsAI then
    -- Target information
    local callsign = Pilot.CallSign
    local FGStatus = Pilot.FlightGroup:GetState()
    self:I("Pilot AI Callsign: " .. callsign)
    self:I("Pilot FG State: " .. FGStatus)
    local targetstatus = Target.Target:GetState()
    self:I("Target State: " .. targetstatus)
 
    --
    local currmission = Pilot.FlightGroup:GetMissionCurrent()
    if currmission then
      self:I("Current Mission: " .. currmission:GetType())
    end
    -- create one intercept Auftrag and one to return to CAP post this one
    local ZoneSet = SET_ZONE:New()
    ZoneSet:AddZone(self.ControlZone)
    ZoneSet:AddZone(self.OrbitZone)
    if self.BorderZone then
      ZoneSet:AddZone(self.BorderZone)
    end
    local intercept = AUFTRAG:NewINTERCEPT(Target.Target)
    intercept:SetWeaponExpend(AI.Task.WeaponExpend.ALL)
    intercept:SetWeaponType(ENUMS.WeaponFlag.Auto)
    
    -- TODO 
    -- now this is going to be interesting...
    -- Check if the target left the "hot" area or is dead already
    intercept:AddConditionSuccess(
      function(target,zoneset)
       -- BASE:I("AUFTRAG Condition Succes Eval Running")
        local success = true
        local target = target -- Ops.Target#TARGET
        if target:IsDestroyed() then return true end
        local tgtcoord = target:GetCoordinate():GetVec2()
        local zones = zoneset -- Core.Set#SET_ZONE
        zones:ForEachZone(
          function(zone)
           -- BASE:I("AUFTRAG Condition Succes ZONE Eval Running")
            if zone:IsVec2InZone(tgtcoord) then
              success = false
            end
          end
        )
        return success
      end,
      Target.Target,
      ZoneSet
    )
    
    Pilot.FlightGroup:AddMission(intercept)    
    
    local Angels = Pilot.AnchorStackAngels
    Angels = Angels * 1000
    local AnchorSpeed = self.CapSpeedBase or 220
    AnchorSpeed = UTILS.KnotsToAltKIAS(AnchorSpeed,Angels)
    local Anchor = self.AnchorStacks:ReadByPointer(Pilot.AnchorStackNo) -- #AWACS.AnchorData
    local capauftrag = AUFTRAG:NewCAP(Anchor.StationZone,Angels,AnchorSpeed,Anchor.StationZoneCoordinate,0,15,{})
    capauftrag:SetTime(nil,((self.CAPTimeOnStation*3600)+(15*60)))
    Pilot.FlightGroup:AddMission(capauftrag) 
    
    -- cancel current mission
    if currmission then
      currmission:__Cancel(3)
    end
    
    -- update known mission list
    self.CatchAllMissions[#self.CatchAllMissions+1] = intercept
    self.CatchAllMissions[#self.CatchAllMissions+1] = capauftrag
    
    -- update pilot TaskSheet
    self.ManagedTasks:PullByID(Pilot.CurrentTask)
    
    Pilot.HasAssignedTask = true
    Pilot.CurrentTask = self:_CreateTaskForGroup(Pilot.GID,AWACS.TaskDescription.INTERCEPT,"Intercept Task",Target.Target,AWACS.TaskStatus.ASSIGNED,intercept)
    Pilot.CurrentAuftrag = intercept.auftragsnummer
    Pilot.ContactCID = Target.CID
    
    -- update managed group
    self.ManagedGrps[Pilot.GID] = Pilot
    
    -- Update Contact Status
    Target.LinkedTask = Pilot.CurrentTask
    Target.LinkedGroup = Pilot.GID
    Target.Status = AWACS.TaskStatus.ASSIGNED
    Target.EngagementTag = string.format("Targeted by %s.",Pilot.CallSign)
    
    self.Contacts:PullByID(Target.CID)
    self.Contacts:Push(Target,Target.CID)
    
    -- message commit and return commit from AI
    --[[
    Controller: “TANGO, TEN GROUPS, GROUP ROCK 250/45, THIRTY-FIVE 
    THOUSAND, TRACK EAST, HOSTILE, RECOMMEND RAPTOR COMMIT.”
    Fighter: “RAPTOR COMMIT.
    --]]

    local bratext = Target.Contact.position:ToStringBRA(Pilot.Group:GetCoordinate())
    local text = string.format("%s. %s group. %s. %s commit.", self.callsigntxt,Target.TargetGroupNaming,bratext,Pilot.CallSign)
    
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = text
    RadioEntry.ToScreen = self.debug
    RadioEntry.Duration = (STTS.getSpeechTime(text,0.95,false) or 8) + 5
    
    self.RadioQueue:Push(RadioEntry)
    
    local text = string.format("%s. Commit.",Pilot.CallSign)
    local RadioEntry = {} -- #AWACS.RadioEntry
    RadioEntry.IsNew = true
    RadioEntry.TextTTS = text
    RadioEntry.TextScreen = text
    RadioEntry.ToScreen = self.debug
    RadioEntry.FromAI = true
    RadioEntry.GroupID = Pilot.GID
    RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
    
    self.RadioQueue:Push(RadioEntry)
    
    self:__Intercept(2)
    
  end
  
  return self
end

-- TODO FSMs
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FSM Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- [Internal] onafterStart
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @return #AWACS self
function AWACS:onafterStart(From, Event, To)
  self:T({From, Event, To})
  
  -- Set up control zone
  local controlzonename = "FEZ-"..self.AOName
  self.ControlZone = ZONE_RADIUS:New(controlzonename,self.OpsZone:GetVec2(),UTILS.NMToMeters(self.ControlZoneRadius))
  if self.debug then
    self.ControlZone:DrawZone(-1,{0,1,0},1,{1,0,0},0.05,3,true)
    --MARKER:New(self.ControlZone:GetCoordinate(),"AIC Zone"):ToAll()
  end
  
  -- set up the AWACS and let it orbit
  local AwacsAW = self.AirWing -- Ops.AirWing#AIRWING
  local mission = AUFTRAG:NewORBIT_RACETRACK(self.OrbitZone:GetCoordinate(),self.AwacsAngels*1000,self.Speed,self.Heading,self.Leg)
  local timeonstation = (self.AwacsTimeOnStation + self.ShiftChangeTime) * 3600
  mission:SetTime(nil,timeonstation)
  self.CatchAllMissions[#self.CatchAllMissions+1] = mission
  
  AwacsAW:AddMission(mission)
  
  self.AwacsMission = mission
  self.AwacsInZone = false -- not yet arrived or gone again
  self.AwacsReady = false
  
  self:__Status(-30)
  return self
end

function AWACS:_CheckAwacsStatus()
  self:I(self.lid.."_CheckAwacsStatus")
  
  local awacs = nil
  if self.AwacsFG then
    awacs = self.AwacsFG:GetGroup() -- Wrapper.Group#GROUP
  end
  
  local monitoringdata = self.MonitoringData -- #AWACS.MonitoringData
  
  if awacs and awacs:IsAlive() and not self.AwacsInZone then
    -- check if we arrived
    local orbitzone = self.OrbitZone -- Core.Zone#ZONE
    if awacs:IsInZone(orbitzone) then
      -- arrived
      self.AwacsInZone = true
      self:I(self.lid.."Arrived in Orbit Zone: " .. orbitzone:GetName())
      local text = string.format("%s on station for %s control.",self.callsigntxt,self.AOName or "Rock")
      local textScreen = string.format("%s on station for %s control.",self.callsigntxt,self.AOName or "Rock")
      local RadioEntry = {} -- #AWACS.RadioEntry
      RadioEntry.IsNew = true
      RadioEntry.TextTTS = text
      RadioEntry.TextScreen = textScreen
      RadioEntry.ToScreen = true
      RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8
      
      self.RadioQueue:Push(RadioEntry)
      --self:_StartIntel(awacs)
      
    end
  end 
  
  --------------------------------
  --     AWACS
  --------------------------------
   
  if (awacs and awacs:IsAlive()) then
    
    if not self.intelstarted then
      self:_StartIntel(awacs)
    end
    
    -- Check on Awacs Mission Status
    local AWmission = self.AwacsMission -- Ops.Auftrag#AUFTRAG
    local awstatus = AWmission:GetState()
    local AWmissiontime = (timer.getTime() - self.AwacsTimeStamp)
    
    local AWTOSLeft = UTILS.Round((((self.AwacsTimeOnStation+self.ShiftChangeTime)*3600) - AWmissiontime),0) -- seconds
    
    AWTOSLeft = UTILS.Round(AWTOSLeft/60,0) -- minutes
    
    local ChangeTime = UTILS.Round(((self.ShiftChangeTime * 3600)/60),0)
    
    local Changedue = "No"
    
    if not self.ShiftChangeAwacsFlag and (AWTOSLeft <= ChangeTime or AWmission:IsOver()) then 
      Changedue = "Yes"
      self.ShiftChangeAwacsFlag = true
      self:__AwacsShiftChange(2) 
    end
    
    local report = REPORT:New("AWACS:")
    report:Add("====================")
    report:Add("AWACS:")
    report:Add(string.format("Auftrag Status: %s",awstatus))
    report:Add(string.format("TOS Left: %d min",AWTOSLeft))
    report:Add(string.format("Needs ShiftChange: %s",Changedue))
    
    local OpsGroups = AWmission:GetOpsGroups()
    local OpsGroup = self:_GetAliveOpsGroupFromTable(OpsGroups) -- Ops.OpsGroup#OPSGROUP
    if OpsGroup then
      local OpsName = OpsGroup:GetName() or "Unknown"
      local OpsCallSign = OpsGroup:GetCallsignName() or "Unknown"
      report:Add(string.format("Mission FG %s",OpsName))
      report:Add(string.format("Callsign %s",OpsCallSign))
      report:Add(string.format("Mission FG State %s",OpsGroup:GetState()))
    else
      report:Add("***** Cannot obtain (yet) this missions OpsGroup!")
    end
    
    -- Check for replacement mission - if any
    if self.ShiftChangeAwacsFlag and self.ShiftChangeAwacsRequested then -- Ops.Auftrag#AUFTRAG
      AWmission = self.AwacsMissionReplacement
      local esstatus = AWmission:GetState()
      local ESmissiontime = (timer.getTime() - self.AwacsTimeStamp)
      local ESTOSLeft = UTILS.Round((((self.AwacsTimeOnStation+self.ShiftChangeTime)*3600) - ESmissiontime),0) -- seconds
      ESTOSLeft = UTILS.Round(ESTOSLeft/60,0) -- minutes
      local ChangeTime = UTILS.Round(((self.ShiftChangeTime * 3600)/60),0)
      --local Changedue = "No"
      
      --report:Add("====================")
      report:Add("AWACS REPLACEMENT:")
      report:Add(string.format("Auftrag Status: %s",esstatus))
      report:Add(string.format("TOS Left: %d min",ESTOSLeft))
      --report:Add(string.format("Needs ShiftChange: %s",Changedue))
      
      local OpsGroups = AWmission:GetOpsGroups()
      local OpsGroup = self:_GetAliveOpsGroupFromTable(OpsGroups) -- Ops.OpsGroup#OPSGROUP
      if OpsGroup then
        local OpsName = OpsGroup:GetName() or "Unknown"
        local OpsCallSign = OpsGroup:GetCallsignName() or "Unknown"
        report:Add(string.format("Mission FG %s",OpsName))
        report:Add(string.format("Callsign %s",OpsCallSign))
        report:Add(string.format("Mission FG State %s",OpsGroup:GetState()))
      else
        report:Add("***** Cannot obtain (yet) this missions OpsGroup!")
      end
      
      if AWmission:IsExecuting() then
        -- make the actual change in the queue
        self.ShiftChangeAwacsFlag = false
        self.ShiftChangeAwacsRequested = false
        -- cancel old mission
        if self.AwacsMission and self.AwacsMission:IsNotOver() then
            self.AwacsMission:Cancel()
        end
        self.AwacsMission = self.AwacsMissionReplacement
        self.AwacsMissionReplacement = nil
        self.AwacsTimeStamp = timer.getTime()
        report:Add("*** Replacement DONE ***")
      end
      report:Add("====================")
    end
    
    --------------------------------
    --     ESCORTS
    --------------------------------
                       
    if self.HasEscorts then
      local ESmission = self.EscortMission -- Ops.Auftrag#AUFTRAG
      local esstatus = ESmission:GetState()
      local ESmissiontime = (timer.getTime() - self.EscortsTimeStamp)
      local ESTOSLeft = UTILS.Round((((self.EscortsTimeOnStation+self.ShiftChangeTime)*3600) - ESmissiontime),0) -- seconds
      ESTOSLeft = UTILS.Round(ESTOSLeft/60,0) -- minutes
      local ChangeTime = UTILS.Round(((self.ShiftChangeTime * 3600)/60),0)
      local Changedue = "No"
      
      if (ESTOSLeft <= ChangeTime and not self.ShiftChangeEscortsFlag) or (ESmission:IsOver() and not self.ShiftChangeEscortsFlag) then 
        Changedue = "Yes" 
        self.ShiftChangeEscortsFlag = true -- set this back when new Escorts arrived
        self:__EscortShiftChange(2)
      end
      
      report:Add("====================")
      report:Add("ESCORTS:")
      report:Add(string.format("Auftrag Status: %s",esstatus))
      report:Add(string.format("TOS Left: %d min",ESTOSLeft))
      report:Add(string.format("Needs ShiftChange: %s",Changedue))
      
      local OpsGroups = ESmission:GetOpsGroups()
      local OpsGroup = self:_GetAliveOpsGroupFromTable(OpsGroups) -- Ops.OpsGroup#OPSGROUP
      if OpsGroup then
        local OpsName = OpsGroup:GetName() or "Unknown"
        local OpsCallSign = OpsGroup:GetCallsignName() or "Unknown"
        report:Add(string.format("Mission FG %s",OpsName))
        report:Add(string.format("Callsign %s",OpsCallSign))
        report:Add(string.format("Mission FG State %s",OpsGroup:GetState()))
        monitoringdata.EscortsStateMission = esstatus
        monitoringdata.EscortsStateFG = OpsGroup:GetState()
      else
        report:Add("***** Cannot obtain (yet) this missions OpsGroup!")
      end
      
      report:Add("====================")
      
      -- Check for replacement mission - if any
      if self.ShiftChangeEscortsFlag and self.ShiftChangeEscortsRequested then -- Ops.Auftrag#AUFTRAG
        ESmission = self.EscortMissionReplacement
        local esstatus = ESmission:GetState()
        local ESmissiontime = (timer.getTime() - self.EscortsTimeStamp)
        local ESTOSLeft = UTILS.Round((((self.EscortsTimeOnStation+self.ShiftChangeTime)*3600) - ESmissiontime),0) -- seconds
        ESTOSLeft = UTILS.Round(ESTOSLeft/60,0) -- minutes
        local ChangeTime = UTILS.Round(((self.ShiftChangeTime * 3600)/60),0)
        --local Changedue = "No"
        
        --report:Add("====================")
        report:Add("ESCORTS REPLACEMENT:")
        report:Add(string.format("Auftrag Status: %s",esstatus))
        report:Add(string.format("TOS Left: %d min",ESTOSLeft))
        --report:Add(string.format("Needs ShiftChange: %s",Changedue))
        
        local OpsGroups = ESmission:GetOpsGroups()
        local OpsGroup = self:_GetAliveOpsGroupFromTable(OpsGroups) -- Ops.OpsGroup#OPSGROUP
        if OpsGroup then
          local OpsName = OpsGroup:GetName() or "Unknown"
          local OpsCallSign = OpsGroup:GetCallsignName() or "Unknown"
          report:Add(string.format("Mission FG %s",OpsName))
          report:Add(string.format("Callsign %s",OpsCallSign))
          report:Add(string.format("Mission FG State %s",OpsGroup:GetState()))
        else
          report:Add("***** Cannot obtain (yet) this missions OpsGroup!")
        end
        
        if ESmission:IsExecuting() then
          -- make the actual change in the queue
          self.ShiftChangeEscortsFlag = false
          self.ShiftChangeEscortsRequested = false
          -- cancel old mission
          if self.EscortMission and self.EscortMission:IsNotOver() then
              self.EscortMission:Cancel()
          end
          self.EscortMission = self.EscortMissionReplacement
          self.EscortMissionReplacement = nil
          self.EscortsTimeStamp = timer.getTime()
          report:Add("*** Replacement DONE ***")
        end
        report:Add("====================")
      end
    end
      
    if self.debug then  
      self:T(report:Text())
    end
  
  else
       -- Check on Awacs Mission Status
    local AWmission = self.AwacsMission -- Ops.Auftrag#AUFTRAG
    local awstatus = AWmission:GetState()
    if AWmission:IsOver() then
      -- yup we're dead
      self:I(self.lid.."*****AWACS is dead!*****")
      self.ShiftChangeAwacsFlag = true
      self:__AwacsShiftChange(2)
    end 
  end
  
  return monitoringdata
end

--- [Internal] onafterStatus
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @return #AWACS self
function AWACS:onafterStatus(From, Event, To)
  self:I({From, Event, To})
  
  self:_SetClientMenus()
  
  local monitoringdata = self:_CheckAwacsStatus()
  
  local awacsalive = false
  if self.AwacsFG then
    local awacs = self.AwacsFG:GetGroup() -- Wrapper.Group#GROUP
    if awacs and awacs:IsAlive() then
      awacsalive= true
    end
  end
  
  -- Check on AUFTRAG status for CAP AI
  if self:Is("Running") and (awacsalive or self.AwacsInZone) then
    
    self:_CheckAICAPOnStation()
    
    self:_CleanUpContacts()
    
    if self.debug then
     --local outcome, targets = self:_TargetSelectionProcess() -- TODO for debug ATM
    end
    local outcome, targets = self:_TargetSelectionProcess(true)
    
    self:_CheckTaskQueue()
    
    local AI, Humans = self:_GetIdlePilots()
    -- assign Pilot if there are targets and available Pilots, prefer Humans to AI
    -- TODO - Implemented AI First, Humans laters ;)
    if outcome and #AI > 0 then
      -- add a task for AI
      self:_AssignPilotToTarget(AI,targets:Pull())
    end
  end
  
  monitoringdata.AwacsShiftChange = self.ShiftChangeAwacsFlag
  
  if self.AwacsFG then
   monitoringdata.AwacsStateFG = self.AwacsFG:GetState()
  end
  
  monitoringdata.AwacsStateMission = self.AwacsMission:GetState()
  monitoringdata.EscortsShiftChange = self.ShiftChangeEscortsFlag
  monitoringdata.AICAPCurrent = self.AICAPMissions:Count()
  monitoringdata.AICAPMax = self.MaxAIonCAP
  monitoringdata.Airwings = self.CAPAirwings:Count()
  
  self.MonitoringData = monitoringdata
  
  if self.debug then
    self:_LogStatistics()
  end
  
  local picturetime = timer.getTime() - self.PictureTimeStamp
  
  if self.AwacsInZone and picturetime > self.PictureInterval then
    -- reset timer
    self.PictureTimeStamp = timer.getTime()
    self:_Picture(nil,true)
  end
  
  self:__Status(30)
  
  return self
end

--- [Internal] onafterStop
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @return #AWACS self
function AWACS:onafterStop(From, Event, To)
  self:T({From, Event, To})
  -- unhandle stuff, exit intel
  
  self.intel:Stop()
  
  local AWFiFo = self.CAPAirwings -- Utilities.FiFo#FIFO
  local AWStack = AWFiFo:GetPointerStack()
  for _ID,_AWID in pairs(AWStack) do
    local SubAW = self.CAPAirwings:ReadByPointer(_ID)
    if SubAW then
      SubAW:RemoveUsingOpsAwacs()
    end
  end
  
  return self
end

--- [Internal] onafterAssignAnchor
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @param #number GID Group ID
-- @return #AWACS self
function AWACS:onafterAssignAnchor(From, Event, To, GID)
  self:T({From, Event, To, "GID = " .. GID})
  self:_AssignAnchorToID(GID)
  return self
end

--- [Internal] onafterCheckedOut
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @param #AWACS.ManagedGroup.GID Group ID 
-- @param #number AnchorStackNo
-- @param #number Angels
-- @return #AWACS self
function AWACS:onafterCheckedOut(From, Event, To, GID, AnchorStackNo, Angels)
  self:T({From, Event, To, "GID = " .. GID})
  self:_RemoveIDFromAnchor(GID,AnchorStackNo,Angels)
  return self
end

--- [Internal] onafterAssignedAnchor
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @param #number GID Managed Group ID
-- @param #AWACS.AnchorData Anchor
-- @param #number AnchorStackNo
-- @return #AWACS self
function AWACS:onafterAssignedAnchor(From, Event, To, GID, Anchor, AnchorStackNo, AnchorAngels)
  self:T({From, Event, To, "GID=" .. GID, "Stack=" .. AnchorStackNo})
  -- TODO
  local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
  if not managedgroup then
    self:E(self.lid .. "**** GID "..GID.." Not Registered!")
    return self
  end
  managedgroup.AnchorStackNo = AnchorStackNo
  managedgroup.AnchorStackAngels = AnchorAngels
  self.ManagedGrps[GID] = managedgroup
  local isPlayer = managedgroup.IsPlayer
  local isAI = managedgroup.IsAI
  local Group = managedgroup.Group
  local CallSign = managedgroup.CallSign or "Ghost 1"
  --local AnchorName = Anchor.StationZone:GetName() or "unknown"
  local AnchorName = Anchor.StationName or "unknown"
  local AnchorCoordTxt = Anchor.StationZoneCoordinateText or "unknown"
  local Angels = AnchorAngels or 25
  local AnchorSpeed = self.CapSpeedBase or 220
  local AuftragsNr = managedgroup.CurrentAuftrag

  local textTTS = string.format("%s. %s. Station at %s at angels %d doing %d knots. Wait for task assignment.",CallSign,self.callsigntxt,AnchorName,Angels,AnchorSpeed)
  local ROEROT = self.AwacsROE.." "..self.AwacsROT
  local textScreen = string.format("%s. %s.\nStation at %s\nAngels %d\nSpeed %d knots\nCoord %s\nROE %s\nWait for task assignment.",CallSign,self.callsigntxt,AnchorName,Angels,AnchorSpeed,AnchorCoordTxt,ROEROT)
  local TextTasking = string.format("%s. %s.\nStation at %s\nAngels %d\nSpeed %d knots\nCoord %s\nROE %s",CallSign,self.callsigntxt,AnchorName,Angels,AnchorSpeed,AnchorCoordTxt,ROEROT)
  
  local RadioEntry = {} -- #AWACS.RadioEntry
  RadioEntry.IsNew = true
  RadioEntry.TextTTS = textTTS
  RadioEntry.TextScreen = textScreen
  RadioEntry.GroupID = GID
  RadioEntry.IsGroup = isPlayer
  RadioEntry.Duration = STTS.getSpeechTime(textTTS,1.0,false) or 10
  RadioEntry.ToScreen = isPlayer
  
  self.RadioQueue:Push(RadioEntry)
      
  managedgroup.CurrentTask = self:_CreateTaskForGroup(GID,AWACS.TaskDescription.ANCHOR,TextTasking,Anchor.StationZone)
  
 -- if isAI and AuftragsNr and AuftragsNr > 0 and self.AICAPMissions:HasUniqueID(AuftragsNr) then
 
  -- if it's a Alert5, we want to push CAP instead
  if isAI then
    local auftrag = managedgroup.FlightGroup:GetMissionCurrent() -- Ops.Auftrag#AUFTRAG
    if auftrag then
      local auftragtype = auftrag:GetType()
      if auftragtype == AUFTRAG.Type.ALERT5 then
        -- all correct
        local capauftrag = AUFTRAG:NewCAP(Anchor.StationZone,Angels*1000,AnchorSpeed,Anchor.StationZone:GetCoordinate(),0,15,{})
        capauftrag:SetTime(nil,((self.CAPTimeOnStation*3600)+(15*60)))
        self.CatchAllMissions[#self.CatchAllMissions+1] = capauftrag
        managedgroup.FlightGroup:AddMission(capauftrag)
        auftrag:Cancel()
      else
       self:E("**** AssignedAnchor but Auftrag NOT ALERT5!")
      end
    else
      self:E("**** AssignedAnchor but NO Auftrag!")
    end 
  end  
  return self
end

--- [Internal] onafterNewCluster
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @param Ops.Intelligence#INTEL.Cluster Cluster
-- @return #AWACS self
function AWACS:onafterNewCluster(From,Event,To,Cluster)
  self:T({From, Event, To, Cluster})
  return self
end
  
--- [Internal] onafterNewContact
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @param Ops.Intelligence#INTEL.Contact Contact
-- @return #AWACS self 
function AWACS:onafterNewContact(From,Event,To,Contact)
  self:T({From, Event, To, Contact})
  
  self.CID = self.CID + 1
  self.Countactcounter = self.Countactcounter + 1
  
  local managedcontact = {} -- #AWACS.ManagedContact
  managedcontact.CID = self.CID
  managedcontact.Contact = Contact
  -- TODO set as per tech age...
  managedcontact.IFF = AWACS.IFF.SPADES -- no IFF yet
  managedcontact.Target = TARGET:New(Contact.group)
  managedcontact.LinkedGroup = 0
  managedcontact.LinkedTask = 0
  managedcontact.Status = AWACS.TaskStatus.IDLE
  local phoneid = math.fmod(self.Countactcounter,27)
  if phoneid == 0 then phoneid = 1 end
  managedcontact.TargetGroupNaming = AWACS.Phonetic[phoneid]
  managedcontact.ReportingName = Contact.group:GetNatoReportingName() -- e.g. Foxbat. Bogey if unknown
  
  local IsPopup = false
  -- is this a pop-up group? i.e. appeared inside AO
  if self.OpsZone:IsVec2InZone(Contact.position:GetVec2()) then
   IsPopup = true
  end
  
  -- let's see if we can inject some info into Contact
  Contact.CID = managedcontact.CID
  Contact.TargetGroupNaming = managedcontact.TargetGroupNaming
  
  self.Contacts:Push(managedcontact,self.CID)
  --self.ManagedContacts:Push(managedcontact,self.CID)
  
  -- only announce if in right distance to HVT/AIC or in ControlZone or in BorderZone
  local ContactCoordinate = Contact.position:GetVec2()
  local incontrolzone = self.ControlZone:IsVec2InZone(ContactCoordinate)
  -- distance check to HVT
  local distance = Contact.position:Get2DDistance(self.OrbitZone:GetCoordinate())
  local inborderzone = false
  if self.BorderZone then
    inborderzone = self.BorderZone:IsVec2InZone(ContactCoordinate)
  end
  
  if incontrolzone or inborderzone or (distance <= UTILS.NMToMeters(45)) then
    self:_AnnounceContact(Contact,true,nil,false,managedcontact.TargetGroupNaming,IsPopup,managedcontact.ReportingName)
  end
  
  return self
end
  
--- [Internal] onafterLostContact
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @param Ops.Intelligence#INTEL.Contact Contact
-- @return #AWACS self
function AWACS:onafterLostContact(From,Event,To,Contact)
  self:T({From, Event, To, Contact})
  self:_CleanUpContacts()
  return self
end
  
--- [Internal] onafterLostCluster
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @param Ops.Intelligence#INTEL.Cluster Cluster
-- @param Ops.Auftrag#AUFTRAG Mission
-- @return #AWACS self
function AWACS:onafterLostCluster(From,Event,To,Cluster,Mission)
  self:T({From, Event, To})
  self:_CleanUpContacts()
  return self
end

--- [Internal] onafterCheckRadioQueue
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @return #AWACS self
function AWACS:onafterCheckRadioQueue(From,Event,To)
 self:T({From, Event, To})
 -- do we have messages queued?
 
 local nextcall = 10
 if self.RadioQueue:IsNotEmpty() then
  local RadioEntry = self.RadioQueue:Pull() -- #AWACS.RadioEntry
  
  self:T({RadioEntry})
  
  if not RadioEntry.FromAI then
    -- AI AWACS Speaking
    self.AwacsFG:RadioTransmission(RadioEntry.TextTTS,1,false)
    self:T(RadioEntry.TextTTS)
  else
    -- CAP AI speaking
    if RadioEntry.GroupID and RadioEntry.GroupID ~= 0 then
      local managedgroup = self.ManagedGrps[RadioEntry.GroupID] -- #AWACS.ManagedGroup
      if managedgroup and managedgroup.FlightGroup and managedgroup.FlightGroup:IsAlive() then
        managedgroup.FlightGroup:RadioTransmission(RadioEntry.TextTTS,1,false)
        self:T(RadioEntry.TextTTS)
      end
    end
  end
  
  if RadioEntry.Duration then nextcall = RadioEntry.Duration end
  if RadioEntry.ToScreen and RadioEntry.TextScreen then
    if RadioEntry.GroupID and RadioEntry.GroupID ~= 0 then
      local managedgroup = self.ManagedGrps[RadioEntry.GroupID] -- #AWACS.ManagedGroup
      if managedgroup and managedgroup.Group and managedgroup.Group:IsAlive() then
        MESSAGE:New(RadioEntry.TextScreen,20,"AWACS"):ToGroup(managedgroup.Group)
        self:T(RadioEntry.TextScreen)
      end
    else
      MESSAGE:New(RadioEntry.TextScreen,20,"AWACS"):ToCoalition(self.coalition)
    end
  end
 end
 
 if self:Is("Running") then
  -- exit if stopped
  self:__CheckRadioQueue(nextcall+2)
 end
 return self
end

--- [Internal] onafterEscortShiftChange
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @return #AWACS self
function AWACS:onafterEscortShiftChange(From,Event,To)
  self:I({From, Event, To})
  -- request new Escorts, check if AWACS-FG still alive first!
  if self.AwacsFG and self.ShiftChangeEscortsFlag and not self.ShiftChangeEscortsRequested then
    local awacs = self.AwacsFG:GetGroup() -- Wrapper.Group#GROUP
    if awacs and awacs:IsAlive() then
      -- ok we're good to re-request
      self.ShiftChangeEscortsRequested = true
      self.EscortsTimeStamp = timer.getTime()
      self:_StartEscorts(true)
    else
      -- should not happen
      self:E("**** AWACS group dead at onafterEscortShiftChange!")
    end
  end
  return self
end

--- [Internal] onafterAwacsShiftChange
-- @param #AWACS self
-- @param #string From 
-- @param #string Event
-- @param #string To
-- @return #AWACS self
function AWACS:onafterAwacsShiftChange(From,Event,To)
  self:I({From, Event, To})
  -- request new AWACS
  if self.AwacsFG and self.ShiftChangeAwacsFlag and not self.ShiftChangeAwacsRequested then
    
    -- ok we're good to re-request
    self.ShiftChangeAwacsRequested = true
    self.AwacsTimeStamp = timer.getTime()
    
    -- set up the AWACS and let it orbit
    local AwacsAW = self.AirWing -- Ops.AirWing#AIRWING
    local mission = AUFTRAG:NewORBIT_RACETRACK(self.OrbitZone:GetCoordinate(),self.AwacsAngels*1000,self.Speed,self.Heading,self.Leg)
    self.CatchAllMissions[#self.CatchAllMissions+1] = mission
    local timeonstation = (self.AwacsTimeOnStation + self.ShiftChangeTime) * 3600
    mission:SetTime(nil,timeonstation)
  
    AwacsAW:AddMission(mission)
    
    self.AwacsMissionReplacement = mission
    
  end
  return self
end

--- On after "FlightOnMission".
-- @param #AWACS self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
-- @param Ops.FlightGroup#FLIGHTGROUP FlightGroup on mission.
-- @param Ops.Auftrag#AUFTRAG Mission The requested mission.
-- @return #AWACS self
function AWACS:onafterFlightOnMission(From, Event, To, FlightGroup, Mission)
  self:I({From, Event, To})
  -- coming back from AW, set up the flight
  self:T("FlightGroup " .. FlightGroup:GetName() .. " Mission " .. Mission:GetName() .. " Type "..Mission:GetType())
  self.CatchAllFGs[#self.CatchAllFGs+1] = FlightGroup
  if not self:Is("Stopped") then
    if not self.AwacsReady or self.ShiftChangeAwacsFlag or self.ShiftChangeEscortsFlag then
     self:_StartSettings(FlightGroup,Mission)
    elseif Mission and (Mission:GetType() == AUFTRAG.Type.CAP or Mission:GetType() == AUFTRAG.Type.ALERT5 or Mission:GetType() == AUFTRAG.Type.ORBIT) then
        if not self.FlightGroups:HasUniqueID(FlightGroup:GetName()) then
          self:T("Pushing FG " .. FlightGroup:GetName() .. " to stack!")
          self.FlightGroups:Push(FlightGroup,FlightGroup:GetName())
        end
    end
  end
  return self
end

--- On after "ReAnchor".
-- @param #AWACS self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
-- @param #number GID Group ID to check and re-anchor if possible
-- @return #AWACS self
function AWACS:onafterReAnchor(From, Event, To, GID)
  self:I({From, Event, To, GID})
  -- get managedgroup
  -- check AI FG state
  -- check weapon state
  -- check fuel state
  -- vector back to anchor or RTB
  local managedgroup = self.ManagedGrps[GID] -- #AWACS.ManagedGroup
  if managedgroup then
    if managedgroup.IsAI then
      -- AI will now have a new CAP AUFTRAG and head back to the stack anyway
      local AIFG = managedgroup.FlightGroup -- Ops.FlightGroup#FLIGHTGROUP
      if AIFG and AIFG:IsAlive() then
        -- check state
        if AIFG:IsFuelLow() or AIFG:IsOutOfMissiles() or AIFG:IsOutOfAmmo() then
          local destbase = AIFG.homebase
          if not destbase then destbase = self.Airbase end
          -- RTB call needs an AIRBASE
          AIFG:RTB(destbase)
          -- Check out
          self:_CheckOut(AIFG:GetGroup(),GID)
          self.AIRequested = self.AIRequested - 1
        else
          -- re-establish anchor task
          -- get anchor zone data
          local Anchor = self.AnchorStacks:ReadByPointer(managedgroup.AnchorStackNo) -- #AWACS.AnchorData
          local StationZone = Anchor.StationZone -- Core.Zone#ZONE
          managedgroup.CurrentTask = self:_CreateTaskForGroup(GID,AWACS.TaskDescription.ANCHOR,"Re-Station AI",StationZone)
          managedgroup.HasAssignedTask = true
          local mission = AIFG:GetMissionCurrent() -- Ops.Auftrag#AUFTRAG
          if mission then
            managedgroup.CurrentAuftrag = mission.auftragsnummer or 0
          else
            managedgroup.CurrentAuftrag = 0
          end
          managedgroup.ContactCID = 0
          self.ManagedGrps[GID] = managedgroup        
          self:_MessageVector(GID," to Station",Anchor.StationZoneCoordinate,managedgroup.AnchorStackAngels)
        end
      else
        -- lost group, remove from known groups, declare vanished
        -- AI - remove from known FGs! -- done in status loop
        -- ALL remove from managedgrps
        
        -- message loss
        local savedcallsign = managedgroup.CallSign

        local text = string.format("%s. Lost Flight %s.",self.callsigntxt, savedcallsign)
        local textScreen = string.format("%s. Lost Flight %s.", self.callsigntxt, savedcallsign)
        local RadioEntry = {} -- #AWACS.RadioEntry
        RadioEntry.IsNew = true
        RadioEntry.TextTTS = text
        RadioEntry.TextScreen = textScreen
        RadioEntry.GroupID = 0
        RadioEntry.ToScreen = self.debug 
        RadioEntry.Duration = STTS.getSpeechTime(text,0.95,false) or 8 
        self.RadioQueue:Push(RadioEntry)
        
        self.ManagedGrps[GID] = nil
      end 
    elseif managedgroup.IsPlayer then
      -- TODO
    end
  end
  return self
end

end -- end do
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- END AWACS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------