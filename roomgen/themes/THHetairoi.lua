local lookUpTable = {}
-- lookUpTable["block"] = 1
lookUpTable["wall"] = {21,31}
lookUpTable["wall_edge"] = 22
lookUpTable["wall_top"] = 35
lookUpTable["band_edge"] = 33
lookUpTable["band"] = 34

lookUpTable["slope"] = 3
lookUpTable["slope2Bot"] = 4
lookUpTable["slope2Top"] = 5

lookUpTable["corner"] = 13
lookUpTable["horizontal"] = 14
lookUpTable["innerCorner"] = 23
lookUpTable["vertical"] = 24
lookUpTable["block"] = {1,2,11,12}
lookUpTable["jumpThru"] = 18

lookUpTable["blockSingle"] = 26

lookUpTable["fence"] = 78
lookUpTable["fence_edge"] = 77

lookUpTable["fenceLow"] = 7
lookUpTable["fenceLow_edge"] = 6

lookUpTable["sign"] = {48,49,50}
lookUpTable["sign_bkg"] = {36,37}
lookUpTable["window"] = {22,32,42}
lookUpTable["pipe"] = {28,29,30}
lookUpTable["pipe_corner"] = 27
lookUpTable["baseBoard_edge"] = 43
lookUpTable["baseBoard"] = 44
lookUpTable["curve_edge"] = 41
lookUpTable["side"] = 71
lookUpTable["light_ceiling"] = 38
lookUpTable["light_ground"] = 59
lookUpTable["light_side"] = 60
lookUpTable["window_largeTop"] = 62
lookUpTable["window_largeBottom"] = 72

local Theme = require "roomgen.Theme"
local theme = Theme(lookUpTable,"Hetairoi")

local red_building = {}

red_building["wall"] = {11,21}
red_building["wall_edge"] = {12,22}
red_building["wall_top"] = 32
red_building["band_edge"] = 41
red_building["band"] = 42
red_building["baseBoard_edge"] = 51
red_building["baseBoard"] = 52
red_building["window_largeTop"] = 61
red_building["window_largeBottom"] = 71

local yellow_building = {}

yellow_building["wall"] = {13,23}
yellow_building["wall_edge"] = {14,24}
yellow_building["wall_top"] = 34
yellow_building["band_edge"] = 43
yellow_building["band"] = 44
yellow_building["baseBoard_edge"] = 53
yellow_building["baseBoard"] = 54

local orange_building = {}

orange_building["wall"] = {15,25}
orange_building["wall_edge"] = {16,26}
orange_building["wall_top"] = 36
orange_building["band_edge"] = 45
orange_building["band"] = 46
orange_building["baseBoard_edge"] = 55
orange_building["baseBoard"] = 56

orange_building["block"] = 73

local dark_building = {}

dark_building["wall"] = {17,27}
dark_building["wall_edge"] = {18,28}
dark_building["wall_top"] = 38
dark_building["band_edge"] = 47
dark_building["band"] = 48
dark_building["baseBoard_edge"] = 57
dark_building["baseBoard"] = 58

theme:addSubTheme("red_building",red_building,"Hetairoi_extra")
theme:addSubTheme("yellow_building",yellow_building,"Hetairoi_extra")
theme:addSubTheme("orange_building", orange_building,"Hetairoi_extra")
theme:addSubTheme("dark_building",dark_building,"Hetairoi_extra")

return theme