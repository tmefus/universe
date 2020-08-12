extends Sprite

var civi
var target
var v_direction
var AC
var possible
var isAction
var rand = RandomNumberGenerator.new()

func _init():
	rand.randomize()
	possible = 0.5  # 准备好战争后生命损失减少
	isAction = false # 军队准备

# warning-ignore:unused_argument
func _physics_process(delta):
	if isAction:
		position += v_direction # 前进

# 碰撞检测
func _on_Area2D_area_entered(area): # area是与军队碰撞的 物体的碰撞区域
	if area.name == "Army": # 撞到了Army
		pass
	if area.name == "Star": # 撞到了Star
		if dis(position, target) < 15: # 在这里判断，排除路上撞到其他Star
			var item = area.get_parent() # 将碰撞区域转为撞到的物体
			arrived_pos(item)
			queue_free()

# 情况判断
func arrived_pos(item):
	if civi in Global.CIVI_LIST: # 如果派出军队的文明没有死亡
		civi.army_list.erase(self) # 军队本身从所在文明中删除
		if item.occupied == null: # 如果Star为空就占领它
			item.occupied = civi
			civi.domains.append(item)
			return
		if item.occupied == civi:
			return # 排除先后向同一星系派出两拨军队，前面占领，后面与前面抗衡的事件 （目的变成自己）
		if item.occupied != civi and item.occupied != null: # Star被其他文明占领
			var my_AC = AC
			var enemy_AC = item.occupied.AC
			var win_AC  = max(my_AC, enemy_AC) # 得到较大的军力
			var my_RC = civi.All_Resource
			var enemy_RC = item.occupied.All_Resource
			#var win_RC
			var lose_RC
			var win_civi
			var lose_civi
			###### 按军力确定输赢 ###
			if my_AC < enemy_AC:
				#win_RC = enemy_RC
				lose_RC = my_RC
				win_civi = item.occupied
				lose_civi = civi
			else:
				#win_RC = my_RC
				lose_RC = enemy_RC
				win_civi = civi
				lose_civi = item.occupied
			var win_war = 1 - (1 - possible) / (1 + (lose_civi.gama * lose_RC) / (lose_civi.alpha * win_AC))
			var lose_war = 1 - (1 - possible) / (1 + (win_civi.gama * lose_RC) / (win_civi.alpha * win_AC))
			# 随机选择
			var win_choose_war = prob(win_war)
			var lose_choose_war = prob(lose_war)
			# 双方都不选择战争，什么都不发生
			if not win_choose_war and not lose_choose_war:
				return
			else:
				# 发生战争，强者灭绝弱者，并将弱者的领地资源据为己有
				domain_star(win_civi, lose_civi) # 战争胜利后占领败方Star
				# 去重
				dis_doub(win_civi)
				# 强者也会受伤
				win_civi.Living -= lose_civi.AC
				return
		return
	else: # 文明本体死亡了，如果军队目的地是无人占领状态就在此重建文明
		if item.occupied == null: # 如果Star为空就占领它
			var c = Civilization.new(item, civi.cv_name)  # 生成文明
			c.color = civi.color # 颜色
			c.Technol = 2.0 # 因为不是从头开始，所以技术和生命值都比原始文明高
			c.Living = 1.3
			item.occupied = c # 设置占领
			Global.CIVI_LIST.append(c)
			Global.CIVI_NUM += 1
			Global.All_CIVI_NUM += 1
			return

# 战争胜利后占领败方Star
func domain_star(win, lose):
	for star in lose.domains:
		star.occupied = win # 改变占领
		win.domains.append(star) # 将该Star放入胜方占领列表
	Global.CIVI_LIST.erase(lose) # 将战败方除名
	Global.CIVI_NUM -= 1

# 去重
func dis_doub(win_civi):
	var domwin = []
	for i in range(win_civi.domains.size()):
		if not win_civi.domains[i] in domwin:
			domwin.append(win_civi.domains[i])
	win_civi.domains = domwin

func dis(a, b):
	return sqrt(pow(a.x-b.x, 2) + pow(a.y-b.y, 2))

# 以一定概率p返回true
func prob(_p):
	if rand.randf_range(0, 1) < _p:
		return true
	else:
		return false





