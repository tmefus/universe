extends Node

### 全局变量 ###

var STAR_NUM   # Star数量
var STAR_LIST  # Star列表
var CIVI_LIST  # Civi列表
var CIVI_NUM   # Civi数量
var All_CIVI_NUM # 总共出现过的Civi数量
var ALL_YEARS  # 总共的年份
var ARMY_NUM   # 军队数量

### 暂停 ###
var isPaused = false

### 自定义相关 ###
var randomStart = false
var starNumber = 1
var civilizationName = String(9527)
var civilizationColor:Color = Color.white
var civilizationPosition:Vector2
var customizeStart = false
