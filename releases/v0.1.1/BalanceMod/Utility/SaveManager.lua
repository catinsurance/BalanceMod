local a=require("json")local b=print;local c={ModReference=nil,Loaded={}}local function d()return c.ModReference~=nil end;local function print(...)b(("[BalanceMod] %s"):format(...))end;function c:Flush()if not d()then print("SaveManager:Save() called before initialization was complete, no save was made.")return end;local e=a.encode(c.Loaded)c.ModReference:SaveData(e)c.Loaded={}end;function c:Get(f)if not d()then print("SaveManager:Get() called before initialization was complete, no data was returned.")return end;return c.Loaded[f]end;function c:Set(f,g)if not d()then print("SaveManager:Set() called before initialization was complete, no data was set.")return end;c.Loaded[f]=g end;function c:Load()if not d()then print("SaveManager:GetData() called before initialization was complete, no data was returned.")return end;if c.ModReference:HasData()then local h=c.ModReference:LoadData()local i=h~=""and a.decode(h)or{}c.Loaded=i else c.Loaded={}end end;function c:Init(j)if d()then print("SaveManager:Init() called after initialization was complete, aborting initialization.")return end;c.ModReference=j end;return c