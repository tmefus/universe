extends Node2D

var Civi_Gen
var TC_interstellar
var TC_super

var rand = RandomNumberGenerator.new()
signal refresh_title

func _ready():
	rand.randomize()
	## 设置全局变量 ##
	Global.STAR_NUM = 100 # 生成Star数量
	Global.STAR_LIST = [] # Star列表
	Global.CIVI_LIST = [] # 文明列表
	Global.CIVI_NUM = 0
	Global.ARMY_NUM = 0
	Global.All_CIVI_NUM = 0
	Global.ALL_YEARS = 0
	# 内部变量 #
	Civi_Gen = 0.0015  # 每年，每个无主的恒星系诞生生命的概率
	TC_interstellar = 10  # 星际时代的技术值门槛
	TC_super = 5000  # 技术值超过这个，达到固定最大速度
	new_star() # 生成Star
	
# 创建Star
func new_star(pre=false):
	var W = get_viewport_rect().size.x
	var H = get_viewport_rect().size.y
	var poss = good_position(W, H, Global.STAR_NUM, pre)
	for pos in poss:
		var star = preload("res://Star.tscn").instance()
		star.position = pos
		$Space.add_child(star)
		Global.STAR_LIST.append(star)

# 生成不会重叠位置的点
func good_position(w, h, goal_num, prePos=false):
	var now_num = 0
	var pos_list = [] # 合适的点的位置列表
	
	if prePos: # 当预定了一个位置时
		goal_num = Global.starNumber
		now_num += 1
		var pos = Global.civilizationPosition
		pos_list.append(pos)

	while now_num < goal_num:
		if now_num == 0:
			var pos = get_location(w, h)
			pos_list.append(pos)
			now_num += 1
			continue
		var pos = get_location(w, h)
		var isOk = true
		for p in pos_list: # 新的点与之前的点比较
			if (pow(p.x - pos.x, 2) + pow(p.y - pos.y, 2)) < 3600: # 3600是60的平方
				isOk = false
				break # 如果这个点与任意已有点位置不合适，就退出重新生成
		if isOk:
			pos_list.append(pos)
			now_num += 1
	return pos_list

# 得到一个位置，排除边界
func get_location(w, h):
	var border = 40
	var x = round(rand.randf() * float(w))
	var y = round(rand.randf() * float(h))
	if x < w/ 6: # 空出左边1/7的屏幕显示排名等信息
		x += w/ 6
	if x > w-border:
		x -= border
	if y < border:
		y += border
	if y > h-border:
		y -= border
	return Vector2(x, y)

####### 以上是初始化相关 ######

# warning-ignore:unused_argument
func _physics_process(delta):
	reStart() # 重新随机开始
	gen_civi() # 生成文明
	civi_refresh() # 文明刷新
	send_army(delta) # 派出军队，之后事务由军队自行管理
	Global.ALL_YEARS += 10 # 每次刷新代表10年
	refresh_title() # 刷新信息文字

# 重新开始
func reStart():
	# 随机开始
	if Global.randomStart:
		Global.randomStart = false
		# 删除所有先前的Star
		for i in $Space.get_children():
			i.queue_free()
		_ready() # 重新开始
	
	# 自定义开始
	if Global.customizeStart:
		Global.customizeStart = false
		# 删除所有先前的Star
		for i in $Space.get_children():
			i.queue_free()
		# 创建一个Star
		var star = preload("res://Star.tscn").instance()
		star.position = Global.civilizationPosition
		$Space.add_child(star)
		Global.STAR_LIST.append(star)
		# 在刚才的Star上生成Civi
		Global.CIVI_NUM += 1 # 文明计数加一
		Global.All_CIVI_NUM += 1
		var civi = Civilization.new(star, Global.civilizationName)  # 生成文明
		civi.color = Global.civilizationColor
		star.occupied = civi # 设置占领
		Global.CIVI_LIST.append(civi)
		# 生成其他Star
		Global.STAR_LIST = [] # Star列表
		Global.CIVI_LIST = [] # 文明列表
		Global.CIVI_NUM = 0
		Global.ARMY_NUM = 0
		Global.All_CIVI_NUM = 0
		Global.ALL_YEARS = 0
		new_star(true)

# 文字刷新
func refresh_title():
	# 发送给Canvase的脚本处理
	emit_signal("refresh_title")

# 当有军队飞出可见区域时消除它
func _on_Visible_area_exited(area):
	if area.name == "Army": # Army
		area.get_parent().queue_free()

# 生成文明
func gen_civi():
	if Global.STAR_NUM != 0:
		for star in Global.STAR_LIST:
			if prob(Civi_Gen) and star.occupied == null: # 以一定几率产生文明
				Global.CIVI_NUM += 1 # 文明计数加一
				Global.All_CIVI_NUM += 1
				var civi = Civilization.new(star, "cv_" + str(Global.All_CIVI_NUM))  # 生成文明
				star.occupied = civi # 设置占领
				Global.CIVI_LIST.append(civi)
	else:
		# 在这里写结束
		pass

# 以一定概率p返回true
func prob(_p):
	if rand.randf_range(0, 1) < _p:
		return true
	else:
		return false

# 文明发展
func civi_refresh():
	if Global.CIVI_NUM != 0:
		for civi in Global.CIVI_LIST:
			if civi.refresh() != 0: # 如果返回值不为0 (0代表文明存续)
				for star in civi.domains:
					star.occupied = null # 释放已经死亡的文明对Star的占用
				Global.CIVI_LIST.erase(civi) # 从文明列表删除
				Global.CIVI_NUM -= 1

# 发出军队
func send_army(delta):
	if Global.CIVI_NUM != 0:
		for civi in Global.CIVI_LIST:
			# 当此文明军队技术能够航行且军队数量小于3且愿意出航时，派出军队
			if civi.Technol >= TC_interstellar and prob(civi.p_expand) and civi.army_list.size() < 3:
				var target_position = get_near_star(civi)  # 目标星系是最近的星系之一
				if target_position == null:  # 可选目标为空，说明该文明已经占领全宇宙
					return # 这里返回后不会继续下面的执行
				var army = preload("res://Army.tscn").instance() # 创建一支军队
				army.position = send_near_pos(civi, target_position)
				army.self_modulate = civi.color # 颜色
				army.name = civi.cv_name + "-" + str(civi.Living_Time) # 名字
				army.civi = civi # 来自
				army.target = target_position
				army.AC = civi.AC # 军力
				var direction = (target_position - army.position).normalized() # 方向向量归一化(仅表示方向)
				army.v_direction = direction * get_max_v(civi.Technol, delta)
				army.isAction = true
				civi.army_list.append(army) # 加入文明所持军队
				Global.ARMY_NUM += 1
				$Space.add_child(army) # 把军队加入场景
				army.look_at(to_global(target_position))

# 从最近的几个Star位置出发
func send_near_pos(send_civi, target_pos):
	var stars = []
	for star in send_civi.domains: # 将该文明的每一个Star与目标Star计算距离
		stars.append([star, MD_distance(star.position, target_pos)])
	stars.sort_custom(MyCustomSorter, "sort")
	var get = rand.randi_range(0, min(1, stars.size() - 1))
	return stars[get][0].position  # 随机返回距离最近的前3个(如果可选恒星>=3个)恒星中的一个的位置

# 获取最近的星系
func get_near_star(from_civi):
	# 得到距离这个文明最近的，非本文明占领的Star
	var ans = []
	for star in Global.STAR_LIST:
		if not star in from_civi.domains: # 如果该Star不在该文明的占领中
			ans.append([star, MD_distance(star.position, from_civi.position)]) # Star和距离的组合
	var num = ans.size()
	if num == 0:
		return null  # 返回为空，继续循环
	ans.sort_custom(MyCustomSorter, "sort") # 排序
	var get = rand.randi_range(0, min(2, num-1))
	return ans[get][0].position  # 随机返回距离最近的前3个(如果可选恒星>=3个)恒星中的一个的位置

# 返回的曼哈顿距离，考虑计算速度
func MD_distance(a, b):
	return abs(a.x - b.x) + abs(a.y - b.y)

# 距离公式
func dis(a, b):
	return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))

# 排序
class MyCustomSorter:
	static func sort(a, b):
		if a[1] < b[1]:
			return true
		return false

# 根据文明的技术值得到这个文明的星际宇航速度
func get_max_v(_tc, delta):
	if _tc >= TC_super:
		return 7
	else: # 这是一个[0.25， 3.32]之间的数
		var velc = (0.037 * _tc + 14.6) * delta
		return velc

# 退出按钮
func _on_Button_button_up():
	get_tree().quit()
