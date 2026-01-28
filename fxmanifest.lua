--[[
--------------------------------------------------

This file is part of GRAFT.
You are free to use these files within your own resources.
Please retain the original credit and attached MIT license.
Support honest development.

Author: Case @ BOII Development
License: MIT (https://github.com/boiidevelopment/graft/blob/main/LICENSE)
GitHub: https://github.com/boiidevelopment/graft

--------------------------------------------------
]]

fx_version "cerulean"
games { "gta5", "rdr3" }

name "graft"
version "1.2.0"
description "Handles the hard GRAFT, so you dont have to."
author "Case"
repository "https://github.com/boiidevelopment/graft"
lua54 "yes"

fx_version "cerulean"
game "gta5"

shared_scripts {
    "graft/standalone/**/*.lua",
    
    "graft/cfx_require.lua",
    "graft/fivem/**/*.lua"
}