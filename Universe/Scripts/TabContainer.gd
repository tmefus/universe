extends TabContainer

var colorRect: ColorRect
var posX: HScrollBar
var posY: HScrollBar
var pos: TextureRect
onready var RealPos = get_viewport_rect().size

func _ready():
	colorRect = $"设置/ColorRect"
	posX = $"设置/posX"
	posY = $"设置/posY"
	pos = $"设置/Region/pos"
	posX.max_value = $"设置/Region".rect_size.x - pos.rect_size.x / 2
	posY.max_value = $"设置/Region".rect_size.y - pos.rect_size.x / 2
	posX.value = posX.max_value / 2
	posY.value = posY.max_value / 2
	# 设置默认位置
	Global.civilizationPosition = Vector2(7/12 * RealPos.x, RealPos.y / 2)

# 当星系数量的滑动条变动时
func _on_HScrollBar_value_changed(value):
	$"设置/StarNum".text = String(value)
	Global.starNumber = value

# 当颜色滑动条改变时
func _on_ColorBar_value_changed(value):
	if value <= 100: # 白色-->灰色
		colorRect.color = Color8(255 - value, 255 - value, 255 - value)	
	if value > 100 and value <= 255: # 红色-->黄色
		colorRect.color = Color8(255, value-100, 0)
	if value > 255 and value <= 510: # 黄色-->绿色
		colorRect.color = Color8(510-value, 255, 0)
	if value > 510 and value <= 765: # 绿色-->青色
		colorRect.color = Color8(0, 255, value - 510)
	if value > 765 and value <= 1020: # 青色-->蓝色
		colorRect.color = Color8(0, 1020-value, 255)
	if value > 1020 and value <= 1275: # 蓝色-->玫红色
		colorRect.color = Color8(value - 1020, 0, 255)
	if value > 1275 and value <= 1530: #玫红色-->红色
		colorRect.color = Color8(255, 0, 1530-value)
	Global.civilizationColor = colorRect.color

# 当重新开始按钮按下
func _on_StartButton_up():
	Global.randomStart = true
	Global.isPaused = false # 更新暂停状态
	$"../SettingButton".text = "更多设置" # 重置设置按钮
	$"../SettingButton".icon = preload("res://Assets/history.png")
	get_tree().paused = false # 退出暂停
	hide() # 隐藏设置面板

# 当自定义按钮按下
func _on_CustomizeButton_up():
	Global.customizeStart = true
	Global.starNumber = $"设置/HScrollBar".value
	Global.civilizationName = $"设置/LineEdit".text
	Global.civilizationColor = colorRect.color
	Global.isPaused = false # 更新暂停状态
	$"../SettingButton".text = "更多设置" # 重置设置按钮
	$"../SettingButton".icon = preload("res://Assets/history.png")
	get_tree().paused = false # 退出暂停
	hide() # 隐藏设置面板

# 当位置滑动条变动时
func _on_posX_value_changed(value):
	pos.rect_position = Vector2(value, pos.rect_position.y)
	# 将设置的位置转为实际位置
	var X = (value / $"设置/Region".rect_size.x) * RealPos.x
	if X < RealPos.x / 6:
		X += RealPos.x / 6
	if X > RealPos.x - 40: 
		X -= RealPos.x
	Global.civilizationPosition.x = X

# 当位置滑动条变动时
func _on_posY_value_changed(value):
	pos.rect_position = Vector2(pos.rect_position.x, value)
	# 将设置的位置转为实际位置
	var Y = (value / $"设置/Region".rect_size.y) * RealPos.y
	if Y < 40:
		Y += 40
	if Y > RealPos.y-40:
		Y -= 40
	Global.civilizationPosition.y = Y
