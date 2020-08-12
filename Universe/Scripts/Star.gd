extends Sprite

# Star相关参数
var resource
var occupied setget occupied_change
var rand = RandomNumberGenerator.new()

func _ready():
	rand.randomize()
	resource = round(pow(10, rand.randf_range(4, 6))) # 恒星系的初始资源值
	occupied = null # 恒星系被哪个文明控制
	
# occupied改变时调用
func occupied_change(civi):
	if civi != null:
		occupied = civi
		$name.text = civi.cv_name
		modulate = civi.color
	else:
		occupied = null
		$name.text = ""
		modulate = Color.white
		if resource < 1:
			queue_free()
			Global.STAR_LIST.erase(self) # 从STAR_LIST中清除
			Global.STAR_NUM -= 1 # Star数量-1
