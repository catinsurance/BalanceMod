local a=require("json")local b={ModReference=nil,Loaded={}}local function c()return b.ModReference~=nil end;local function d(...)_G.print("[BalanceMod] ".. ...)end;function b:Flush()if not c()then d("SaveManager:Save() called before initialization was complete, no save was made.")return end;local e=a.encode(b.Loaded)b.ModReference:SaveData(e)b.Loaded={}end;function b:Get(f)if not c()then d("SaveManager:Get() called before initialization was complete, no data was returned.")return end;return b.Loaded[f]end;function b:Set(f,g)if not c()then d("SaveManager:Set() called before initialization was complete, no data was set.")return end;b.Loaded[f]=g end;function b:Load()if not c()then d("SaveManager:GetData() called before initialization was complete, no data was returned.")return end;if b.ModReference:HasData()then local h=b.ModReference:LoadData()local i=h~=""and a.decode(h)or{}b.Loaded=i else b.Loaded={}end end;function b:Init(j)if c()then d("SaveManager:Init() called after initialization was complete, aborting initialization.")return end;b.ModReference=j end;return b