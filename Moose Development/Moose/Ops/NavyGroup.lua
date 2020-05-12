--- **Ops** - Control Naval Groups.
-- 
-- **Main Features:**
--
--    * Nice stuff.
--     
-- ===
--
-- ### Author: **funkyfranky**
-- @module Ops.NavyGroup
-- @image OPS_NavyGroup.png


--- NAVYGROUP class.
-- @type NAVYGROUP
-- @field #string ClassName Name of the class.
-- @field #boolean Debug Debug mode. Messages to all about status.
-- @field #string lid Class id string for output to DCS log file.
-- @field #string groupname The name of the NAVY group.
-- @field Wrapper.Group#GROUP group The group object.
-- @field #table elements Elements of the group.
-- @field #number currentwp Last waypoint passed.
-- @field #number speedCruise Cruising speed in km/h.
-- @extends Core.Fsm#FSM

--- *Something must be left to chance; nothing is sure in a sea fight above all.* --- Horatio Nelson
--
-- ===
--
-- ![Banner Image](..\Presentations\NAVYGROUP\NavyGroup_Main.jpg)
--
-- # The NAVYGROUP Concept
-- 
-- 
-- 
-- @field #NAVYGROUP
NAVYGROUP = {
  ClassName      = "NAVYGROUP",
  lid            =   nil,
  groupname      =   nil,
  group          =   nil,
  currentwp      =     1,
  elements       =    {},
  taskqueue      =    {},
}

--- Navy group element.
-- @type NAVYGROUP.Element
-- @field #string name Name of the element, i.e. the unit.
-- @field #string typename Type name.

--- NavyGroup version.
-- @field #string version
NAVYGROUP.version="0.0.1"

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TODO list
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
-- TODO: Stop and resume route.
-- TODO: Add waypoints.
-- TODO: Add tasks.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constructor
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Create a new NAVYGROUP class object.
-- @param #NAVYGROUP self
-- @param #string GroupName Name of the group.
-- @return #NAVYGROUP self
function NAVYGROUP:New(GroupName)

  -- Inherit everything from FSM class.
  local self=BASE:Inherit(self, FSM:New()) -- #NAVYGROUP
  
  
  self.groupname=GroupName
  
  self.group=GROUP:FindByName(self.groupname)
  
  -- Set some string id for output to DCS.log file.
  self.lid=string.format("NAVYGROUP %s |", self.groupname)
  
  self:SetStartState("Stopped")

  -- Add FSM transitions.
  --                 From State  -->   Event      -->     To State
  self:AddTransition("Stopped",       "Start",             "Cruising")    -- Status update.
  self:AddTransition("*",             "Status",            "*")           -- Status update.
  
  self:AddTransition("*",             "PassingWaypoint",   "*")           -- Passing waypoint.
  self:AddTransition("*",             "UpdateRoute",       "*")           -- Passing waypoint.
  self:AddTransition("*",             "FullStop",          "Holding")     -- Hold position.
  self:AddTransition("*",             "TurnIntoWind",      "*")           -- Hold position.
  self:AddTransition("*",             "Cruise",            "Cruising")    -- Hold position.
  
  self:AddTransition("*",             "Dive",              "Diving")      -- Hold position.
  self:AddTransition("Diving",        "Surface",           "Cruising")    -- Hold position.
  
    
  
  ------------------------
  --- Pseudo Functions ---
  ------------------------

  --- Triggers the FSM event "Start". Starts the NAVYGROUP. Initializes parameters and starts event handlers.
  -- @function [parent=#NAVYGROUP] Start
  -- @param #NAVYGROUP self

  --- Triggers the FSM event "Start" after a delay. Starts the NAVYGROUP. Initializes parameters and starts event handlers.
  -- @function [parent=#NAVYGROUP] __Start
  -- @param #NAVYGROUP self
  -- @param #number delay Delay in seconds.

  --- Triggers the FSM event "Stop". Stops the NAVYGROUP and all its event handlers.
  -- @param #NAVYGROUP self

  --- Triggers the FSM event "Stop" after a delay. Stops the NAVYGROUP and all its event handlers.
  -- @function [parent=#NAVYGROUP] __Stop
  -- @param #NAVYGROUP self
  -- @param #number delay Delay in seconds.

  --- Triggers the FSM event "Status".
  -- @function [parent=#NAVYGROUP] Status
  -- @param #NAVYGROUP self

  --- Triggers the FSM event "Status" after a delay.
  -- @function [parent=#NAVYGROUP] __Status
  -- @param #NAVYGROUP self
  -- @param #number delay Delay in seconds.  

  -- Debug trace.
  if false then
    self.Debug=true
    BASE:TraceOnOff(true)
    BASE:TraceClass(self.ClassName)
    BASE:TraceLevel(1)
  end
  
  self:_InitGroup()
  
  self:Start()
   
  return self  
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- User Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Get coalition.
-- @param #NAVYGROUP self
-- @return #number Coalition side of carrier.
function NAVYGROUP:GetCoalition()
  return self.group:GetCoalition()
end

--- Get coordinate.
-- @param #NAVYGROUP self
-- @return Core.Point#COORDINATE Carrier coordinate.
function NAVYGROUP:GetCoordinate()
  return self.group:GetCoordinate()
end

--- Add a *scheduled* task.
-- @param #NAVYGROUP self
-- @param Core.Point#COORDINATE Coordinate Coordinate of the target.
-- @param #number Nshots Number of shots to fire. Default 3.
-- @param #number WeaponType Type of weapon. Default auto.
-- @param #string Clock Time when to start the attack.
-- @param #number Prio Priority of the task.
function NAVYGROUP:AddTaskFireAtPoint(Coordinate, Radius, Nshots, WeaponType, Clock, Prio)

  local DCStask=CONTROLLABLE.TaskFireAtPoint(nil, Coordinate:GetVec2(), Radius, Nshots, WeaponType)

  

end

--- Add a *scheduled* task.
-- @param #NAVYGROUP self
-- @param #table task DCS task table structure.
-- @param #string clock Mission time when task is executed. Default in 5 seconds. If argument passed as #number, it defines a relative delay in seconds.
-- @param #string description Brief text describing the task, e.g. "Attack SAM".
-- @param #number prio Priority of the task.
-- @param #number duration Duration before task is cancelled in seconds counted after task started. Default never.
-- @return #NAVYGROUP.Task The task structure.
function NAVYGROUP:AddTask(task, clock, description, prio, duration)

  local newtask=self:NewTaskScheduled(task, clock, description, prio, duration)

  -- Add to table.
  table.insert(self.taskqueue, newtask)
  
  -- Info.
  self:I(self.lid..string.format("Adding SCHEDULED task %s starting at %s", newtask.description, UTILS.SecondsToClock(newtask.time, true)))
  self:T3({newtask=newtask})

  return newtask
end

--- Create a *scheduled* task.
-- @param #NAVYGROUP self
-- @param #table task DCS task table structure.
-- @param #string clock Mission time when task is executed. Default in 5 seconds. If argument passed as #number, it defines a relative delay in seconds.
-- @param #string description Brief text describing the task, e.g. "Attack SAM".
-- @param #number prio Priority of the task.
-- @param #number duration Duration before task is cancelled in seconds counted after task started. Default never.
-- @return #NAVYGROUP.Task The task structure.
function NAVYGROUP:NewTaskScheduled(task, clock, description, prio, duration)

  -- Increase counter.
  self.taskcounter=self.taskcounter+1

  -- Set time.
  local time=timer.getAbsTime()+5
  if clock then
    if type(clock)=="string" then
      time=UTILS.ClockToSeconds(clock)
    elseif type(clock)=="number" then
      time=timer.getAbsTime()+clock
    end
  end

  -- Task data structure.
  local newtask={} --#NAVYGROUP.Task
  newtask.status=NAVYGROUP.TaskStatus.SCHEDULED
  newtask.dcstask=task
  newtask.description=description or task.id  
  newtask.prio=prio or 50
  newtask.time=time
  newtask.id=self.taskcounter
  newtask.duration=duration
  newtask.waypoint=-1
  newtask.type=NAVYGROUP.TaskType.SCHEDULED
  newtask.stopflag=USERFLAG:New(string.format("%s StopTaskFlag %d", self.groupname, newtask.id))  
  newtask.stopflag:Set(0)

  return newtask
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Status
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Start NAVYGROUP FSM. Handle events.
-- @param #NAVYGROUP self
function NAVYGROUP:onafterStart(From, Event, To)

  -- Info.
  self:I(self.lid..string.format("Starting NAVYGROUP v%s for %s", NAVYGROUP.version, self.groupname))
  
  -- Update route.
  --self:UpdateRoute()
  
  -- Init status updates.
  self:__Status(-1)
end

--- Update status.
-- @param #NAVYGROUP self
function NAVYGROUP:onafterStatus(From, Event, To)

  local fsmstate=self:GetState()
  
  local speed=self.group:GetVelocityKNOTS()

    -- Info text.
  local text=string.format("State %s: Speed=%.1f knots", fsmstate, speed)
  self:I(self.lid..text)

  self:__Status(-30)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FSM Events
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- On after "UpdateRoute" event.
-- @param #NAVYGROUP self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
-- @param #number n Waypoint number. Default is next waypoint.
function NAVYGROUP:onafterUpdateRoute(From, Event, To, n)

  -- Update route from this waypoint number onwards.
  n=n or self.currentwp+1
  
  -- Update waypoint tasks, i.e. inject WP tasks into waypoint table.
  self:_UpdateWaypointTasks()

  -- Waypoints.
  local waypoints={}
  
  -- Current velocity.
  local speed=self.group and self.group:GetVelocityKMH() or 100 
  
  
  local current=self:GetCoordinate():WaypointNaval(speed)
  table.insert(waypoints, current)
  
  -- Add remaining waypoints to route.
  for i=n, #self.waypoints do
    local wp=self.waypoints[i]
    
    -- Set speed.
    wp.speed=UTILS.KmphToMps(self.speedCruise)
    
    -- Add waypoint.
    table.insert(waypoints, wp)
  end

  
  if #waypoints>1 then

    -- Route group to all defined waypoints remaining.
    self.group:Route(waypoints, 1)
    
  else
  
    ---
    -- No waypoints left
    ---
  
    self:UpdateRoute(1)
          
  end

end

--- On after "TurnIntoWind" event.
-- @param #NAVYGROUP self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
-- @param #number Duration Duration in seconds.
-- @param #number Speed Speed in knots.
-- @param #boolean Uturn Return to the place we came from.
function NAVYGROUP:onafterTurnIntoWind(From, Event, To, Duration, Speed, Uturn)

  self.turnintowind=timer.getAbsTime()
  
  local headingTo=self:GetCoordinate():GetWind(50)
  
  local distance=UTILS.NMToMeters(1000)
  
  local wp={}
  
  local coord=self:GetCoordinate()
  local Coord=coord:Translate(distance, headingTo)
  
  wp[1]=coord:WaypointNaval(Speed)
  wp[2]=Coord:WaypointNaval(Speed)

  self.group:Route(wp, 1)
  
end

--- On after "FullStop" event.
-- @param #NAVYGROUP self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function NAVYGROUP:onafterFullStop(From, Event, To)

  -- Get current position.
  local pos=self:GetCoordinate()
  
  -- Create a new waypoint.
  local wp=pos:WaypointNaval(0)
  
  -- Create new route consisting of only this position ==> Stop!
  self.group:Route({wp})

end

--- On after "Cruise" event.
-- @param #NAVYGROUP self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function NAVYGROUP:onafterCruise(From, Event, To)

  self:UpdateRoute()

end

--- On after "PassingWaypoint" event.
-- @param #NAVYGROUP self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
-- @param #number n Waypoint passed.
-- @param #number N Total number of waypoints.
function NAVYGROUP:onafterPassingWaypoint(From, Event, To, n, N)
  self:I(self.lid..string.format("Passed waypoint %d of %d", n, N))
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Routing
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Set DCS task. Enroute tasks are injected automatically.
-- @param #NAVYGROUP self
-- @param #table DCSTask DCS task structure.
-- @return #NAVYGROUP self
function NAVYGROUP:SetTask(DCSTask)

  if self:IsAlive() then
  
    -- Set task.
    self.group:SetTask(DCSTask)
    
    -- Debug info.
    local text=string.format("SETTING Task %s", tostring(DCSTask.id))
    if tostring(DCSTask.id)=="ComboTask" then
      for i,task in pairs(DCSTask.params.tasks) do
        text=text..string.format("\n[%d] %s", i, tostring(task.id))
      end
    end
    self:I(self.lid..text)    
  end
  
  return self
end

--- Check if flight is alive.
-- @param #NAVYGROUP self
-- @return #boolean *true* if group is exists and is activated, *false* if group is exist but is NOT activated. *nil* otherwise, e.g. the GROUP object is *nil* or the group is not spawned yet.
function NAVYGROUP:IsAlive()

  if self.group then
    return self.group:IsAlive()
  end

  return nil
end

--- Route group along waypoints. Enroute tasks are also applied.
-- @param #NAVYGROUP self
-- @param #table waypoints Table of waypoints.
-- @return #NAVYGROUP self
function NAVYGROUP:Route(waypoints)

  if self:IsAlive() then

    -- DCS task combo.
    local Tasks={}
    
    -- Route (Mission) task.
    local TaskRoute=self.group:TaskRoute(waypoints)
    table.insert(Tasks, TaskRoute)
    
    -- TaskCombo of enroute and mission tasks.
    local TaskCombo=self.group:TaskCombo(Tasks)
        
    -- Set tasks.
    if #Tasks>1 then
      self:SetTask(TaskCombo)
    else
      self:SetTask(TaskRoute)
    end
    
  else
    self:E(self.lid.."ERROR: Group is not alive!")
  end
  
  return self
end

--- Initialize group parameters. Also initializes waypoints if self.waypoints is nil.
-- @param #NAVYGROUP self
-- @return #NAVYGROUP self
function NAVYGROUP:_InitGroup()

  -- First check if group was already initialized.
  if self.groupinitialized then
    self:E(self.lid.."WARNING: Group was already initialized!")
    return
  end

  -- Get template of group.
  self.template=self.group:GetTemplate()

  -- Helo group.
  --self.isSubmarine=self.group:IsSubmarine()
  
  -- Is (template) group late activated.
  self.isLateActivated=self.template.lateActivation
  
  -- Max speed in km/h.
  self.speedmax=self.group:GetSpeedMax()
  
  -- Cruise speed: 70% of max speed but within limit.
  self.speedCruise=self.speedmax*0.7
  
  -- Group ammo.
  --self.ammo=self:GetAmmoTot()
  
  self.traveldist=0
  self.traveltime=timer.getAbsTime()
  self.position=self:GetCoordinate()
  
  -- Radio parameters from template.
  --self.radioOn=self.template.communication
  self.radioFreq=self.template.units[1].frequency
  self.radioModu=self.template.units[1].modulation
  
  -- If not set by the use explicitly yet, we take the template values as defaults.
  if not self.radioFreqDefault then
    self.radioFreqDefault=self.radioFreq
    self.radioModuDefault=self.radioModu
  end
  
  -- Set default formation.
  if not self.formationDefault then
    if self.ishelo then
      self.formationDefault=ENUMS.Formation.RotaryWing.EchelonLeft.D300
    else
      self.formationDefault=ENUMS.Formation.FixedWing.EchelonLeft.Group
    end
  end
  
  -- Get first unit. This is used to extract other parameters.
  local unit=self.group:GetUnit(1)
  
  local units=self.group:GetUnits()
  for _,_unit in pairs(units) do
    local element={} --#NAVYGROUP.Element
    local unit=_unit --Wrapper.Unit#UNIT
    element.name=unit:GetName()
    element.typename=unit:GetTypeName()
    table.insert(self.elements, element)
  end
  
  if unit then
    
    self.descriptors=unit:GetDesc()
    
    self.actype=unit:GetTypeName()
  
    -- Init waypoints.
    if not self.waypoints then
      self:InitWaypoints()
    end
    
    -- Debug info.
    local text=string.format("Initialized Navy Group %s:\n", self.groupname)
    text=text..string.format("AC type      = %s\n", self.actype)
    text=text..string.format("Speed max    = %.1f Knots\n", UTILS.KmphToKnots(self.speedmax))
    text=text..string.format("Elements     = %d\n", #self.elements)
    text=text..string.format("Waypoints    = %d\n", #self.waypoints)
    text=text..string.format("Radio        = %.1f MHz %s %s\n", self.radioFreq, UTILS.GetModulationName(self.radioModu), tostring(self.radioOn))
    --text=text..string.format("Ammo         = %d (G=%d/R=%d/B=%d/M=%d)\n", self.ammo.Total, self.ammo.Guns, self.ammo.Rockets, self.ammo.Bombs, self.ammo.Missiles)
    text=text..string.format("FSM state    = %s\n", self:GetState())
    text=text..string.format("Is alive     = %s\n", tostring(self.group:IsAlive()))
    --text=text..string.format("LateActivate = %s\n", tostring(self:IsLateActivated()))
    self:I(self.lid..text)
    
    -- Init done.
    self.groupinitialized=true
    
  end
  
  return self
end

--- Initialize Mission Editor waypoints.
-- @param #NAVYGROUP self
-- @param #table waypoints Table of waypoints. Default is from group template.
-- @return #NAVYGROUP self
function NAVYGROUP:InitWaypoints(waypoints)

  -- Template waypoints.
  self.waypoints0=self.group:GetTemplateRoutePoints()

  -- Waypoints of group as defined in the ME.
  self.waypoints=waypoints or UTILS.DeepCopy(self.waypoints0)
  
  -- Debug info.
  self:T(self.lid..string.format("Initializing %d waypoints", #self.waypoints))
  
  -- Update route.
  if #self.waypoints>0 then
  
    -- Check if only 1 wp?
    if #self.waypoints==1 then
      self.passedfinalwp=true
    end
    
    -- Update route (when airborne).
    self:__UpdateRoute(-1)
  end

  return self
end

--- Initialize Mission Editor waypoints.
-- @param #NAVYGROUP self
function NAVYGROUP:_UpdateWaypointTasks()

  local waypoints=self.waypoints
  local nwaypoints=#waypoints

  for i,wp in pairs(waypoints) do
    
    if i>self.currentwp or nwaypoints==1 then
    
      -- Debug info.
      self:T2(self.lid..string.format("Updating waypoint task for waypoint %d/%d. Last waypoint passed %d.", i, nwaypoints, self.currentwp))
  
      -- Tasks of this waypoint
      local taskswp={}
    
      -- At each waypoint report passing.
      local TaskPassingWaypoint=self.group:TaskFunction("NAVYGROUP._PassingWaypoint", self, i)      
      table.insert(taskswp, TaskPassingWaypoint)      
          
      -- Waypoint task combo.
      wp.task=self.group:TaskCombo(taskswp)
      
    end
  end

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Misc Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Function called when a group is passing a waypoint.
--@param Wrapper.Group#GROUP group Group that passed the waypoint
--@param #NAVYGROUP navygroup Navy group object.
--@param #number i Waypoint number that has been reached.
function NAVYGROUP._PassingWaypoint(group, navygroup, i)

  local final=#navygroup.waypoints or 1

  -- Debug message.
  local text=string.format("Group passing waypoint %d of %d", i, final)
  navygroup:T3(navygroup.lid..text)

  -- Set current waypoint.
  navygroup.currentwp=i

  -- Trigger PassingWaypoint event.
  navygroup:PassingWaypoint(i, final)

end




--- Set rules of engagement.
-- @param #NAVYGROUP self
-- @param #string roe "Hold", "Free", "Return".
function NAVYGROUP:_SetROE(roe)

  if roe=="Hold" then
    self.group:OptionROEHoldFire()
  elseif roe=="Free" then
    self.group:OptionROEOpenFire()
  elseif roe=="Return" then  
    self.group:OptionROEReturnFire()
  end

  MESSAGE:New(string.format("ROE set to %s", roe), 5, self.ClassName):ToCoalition(self:GetCoalition())
end

--- Set alarm state. (Not useful/working for ships.)
-- @param #NAVYGROUP self
-- @param #string state "Green", "Red", "Auto".
function NAVYGROUP:_SetALS(state)

  if state=="Green" then
    self.group:OptionAlarmStateGreen()
  elseif state=="Red" then
    self.group:OptionAlarmStateRed()
  elseif state=="Auto" then
    self.group:OptionAlarmStateAuto()
  end
  
  MESSAGE:New(string.format("Alarm state set to %s", state), 5, self.ClassName):ToCoalition(self:GetCoalition())
end




-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------