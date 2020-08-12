extends CanvasLayer

# 按下按钮
func _on_Button_button_up():
	if not Global.isPaused: # 如果不是暂停就暂停
		#暂停
		get_tree().paused = true # 暂停
		$SettingButton.text = "返回继续" # 设置按钮文字
		$SettingButton.icon = preload("res://Assets/back.png") # 加载图标
		Global.isPaused = true
		pause_mode = Node.PAUSE_MODE_PROCESS # 设置按钮在暂停时不受影响
		
		$TabContainer.show()
	else: #否则就取消暂停
		get_tree().paused = false
		$SettingButton.text = "更多设置"
		$SettingButton.icon = preload("res://Assets/history.png")
		Global.isPaused = false
		
		$TabContainer.hide()


# 文字刷新
func _on_Universe_refresh_title():
	if Global.ALL_YEARS % 100 == 0: # 年份刷新
		$Title.text = "宇宙历年：" + str(Global.ALL_YEARS)
		$Title/stars.text = "星系数目：" + str(Global.STAR_NUM)
		$Title/civis.text = "文明数量：" + str(Global.CIVI_NUM)
		# 先将所有清空
		for i in $Sort.get_children():
			i.text = ""
		
		# 排序
		if Global.CIVI_NUM > 0:
			var list = Global.CIVI_LIST.duplicate(true)
			list.sort_custom(ResSorter, "sort") # 排序
			$Sort/res1.text = list[0].cv_name + "：" + str(round(list[0].All_Resource))
			$Sort/res1.self_modulate = list[0].color
			if Global.CIVI_NUM >= 2:
				$Sort/res2.text = list[1].cv_name + "：" + str(round(list[1].All_Resource))
				$Sort/res2.self_modulate = list[1].color
			if Global.CIVI_NUM >= 3:
				$Sort/res3.text = list[2].cv_name + "：" + str(round(list[2].All_Resource))
				$Sort/res3.self_modulate = list[2].color
			
			list.sort_custom(LviSorter, "sort") # 排序
			$Sort/lvs1.text = list[0].cv_name + "：" + str(stepify(list[0].Living, 0.0001))
			$Sort/lvs1.self_modulate = list[0].color
			if Global.CIVI_NUM >= 2:
				$Sort/lvs2.text = list[1].cv_name + "：" + str(stepify(list[1].Living, 0.0001))
				$Sort/lvs2.self_modulate = list[1].color
			if Global.CIVI_NUM >= 3:
				$Sort/lvs3.text = list[2].cv_name + "：" + str(stepify(list[2].Living, 0.0001))
				$Sort/lvs3.self_modulate = list[2].color
			
			list.sort_custom(TecSorter, "sort") # 排序
			$Sort/tcs1.text = list[0].cv_name + "：" + str(stepify(list[0].Technol, 0.0001))
			$Sort/tcs1.self_modulate = list[0].color
			if Global.CIVI_NUM >= 2:
				$Sort/tcs2.text = list[1].cv_name + "：" + str(stepify(list[1].Technol, 0.0001))
				$Sort/tcs2.self_modulate = list[1].color
			if Global.CIVI_NUM >= 3:
				$Sort/tcs3.text = list[2].cv_name + "：" + str(stepify(list[2].Technol, 0.0001))
				$Sort/tcs3.self_modulate = list[2].color

class ResSorter:
	static func sort(a, b):
		if a.All_Resource > b.All_Resource:
			return true
		return false

class LviSorter:
	static func sort(a, b):
		if a.Living > b.Living:
			return true
		return false

class TecSorter:
	static func sort(a, b):
		if a.Technol > b.Technol:
			return true
		return false
