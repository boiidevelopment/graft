--[[ 
    This file is part of GRAFT (General Runtime Abstraction & Framework Toolkit) and is licensed under the MIT License.
    See the LICENSE file in the root directory for full terms.

    © 2025 Case @ Playing In Traffic

    Support honest development — retain this credit. Don"t be that guy...
]]

--[[
#########################################################
#  ____  _        _ __   _____ _   _  ____   ___ _   _  #
# |  _ \| |      / \\ \ / /_ _| \ | |/ ___| |_ _| \ | | #
# | |_) | |     / _ \\ V / | ||  \| | |  _   | ||  \| | #
# |  __/| |___ / ___ \| |  | || |\  | |_| |  | || |\  | #
# |_|   |_____/_/   \_\_| |___|_| \_|\____| |___|_| \_| #
#  _____ ____      _    _____ _____ ___ ____            #
# |_   _|  _ \    / \  |  ___|  ___|_ _/ ___|           #
#   | | | |_) |  / _ \ | |_  | |_   | | |               #
#   | | |  _ <  / ___ \|  _| |  _|  | | |___            #
#   |_| |_| \_\/_/   \_\_|   |_|   |___\____|           #              
#########################################################
]]

fx_version "cerulean"
games { "gta5", "rdr3" }

name "graft"
version "1.1.2"
description "GRAFT - General Runtime Abstraction & Framework Toolkit"
author "PlayingInTraffic"
repository "https://github.com/playingintraffic/graft"
lua54 "yes"

fx_version "cerulean"
game "gta5"

server_script "@oxmysql/lib/MySQL.lua"

shared_script "init.lua"
server_script "users.lua" -- Required! user accounts handle permissions for commands etc.. dont remove.

shared_scripts {
    "lib/events/*.lua",
    "lib/modules/*.lua",
    "lib/callbacks/*lua",
    "bridges/**/impl/*.lua",
    "bridges/**/loader.lua",
}

