extends Node

# 文明的类，包含单个文明所有的信息
class_name Civilization

var cv_name
var position
var star
var domains
var color
var Living
var Technol
var All_Resource
var Used_Resource
var Living_Time
var Tech_Explosion
var Tech_Explosion_Prob
var Tech_Explosion_Num
var Tech_Rest_time
var Tech_Explosion_t
var Disaster_Prob
var Disaster_k_Tech
var Disaster_k_Living
var Resource_rt
var Resource_rl
var Living_l
var Resource_lr
var Technol_lt
var p_expand
var alpha
var beta
var gama
var al
var at
var AC
var army_list
var rand = RandomNumberGenerator.new()

func _init(_star, _name):
	rand.randomize() # 每次生成不同的随机数
	cv_name = _name
	position = _star.position
	star = _star # 发源地
	domains = [_star] # 文明占有的Star
	color = Color(rand.randf_range(0.2, 1), rand.randf_range(0.2, 1), rand.randf_range(0.2, 1), 0.9)
	Living = rand.randf_range(1.0, 1.3)  # 生命值
	Technol = 1.0  # 技术值
	All_Resource = _star.resource  # 文明剩下的资源，是所有星系的资源之和
	Used_Resource = 0.0  # 文明使用过的资源
	Living_Time = 0  # 存活时间
	# 科技爆炸
	Tech_Explosion = false  # 是否正在技术爆炸
	Tech_Explosion_Prob = 0.0004  # 技术爆炸的可能性,按照人类文明平均1250年一次
	Tech_Explosion_Num = 0  # 已经进行了几次科技革命
	Tech_Rest_time = 0  # 科技革命剩下的时间
	Tech_Explosion_t = 0.02  # 技术爆炸的年化增长率
	# 天灾
	Disaster_Prob = 0.01  # 天灾的可能性
	Disaster_k_Tech = 0.95  # 天灾后技术退化比
	Disaster_k_Living = 0.95  # 天灾后人口衰减比
	# 资源
	Resource_rt = 0.01  # 文明消耗资源的速度,来自技术
	Resource_rl = 0.01  # 文明消耗资源的速度,来自生命
	# 生命
	Living_l = 0.02  # 文明的生命值增加率
	Resource_lr = 0.1  # 单位资源可以承载的人口上限
	Technol_lt = 0.15  # 单位技术可以承载的人口上限
	# 扩张欲望
	p_expand = rand.randf_range(0.5, 1) * 0.005 # [0.5, 1] * 0.005
	# 文明政策
	alpha = rand.randf()  # 生命值重要程度
	beta = rand.randf()  # 技术值重要程度
	gama = rand.randf()  # 资源值重要程度
	# 军队
	al = 0.001 # 一次派出军队的人口占文明人口的比例
	at = 0.001 # 一次派出军队的技术占文明技术的比例
	AC = 0.0 # 军力
	army_list = [] # 文明派出的军队列表

func refresh():
	# ############生存判定###############
	# 文明的生命值过低则死亡
	if Living <= 0.1:
		return 1
	# 资源耗尽，文明死亡
	if All_Resource <= 0:
		return 2
	# 退化文明死亡
	if Technol <= 0.1:
		return 3
	# ############生存判定###############
	# 生存时间增加
	Living_Time += 1
	# 没有革命才随机进行革命
	if not Tech_Explosion:
		if rand.randf() < Tech_Explosion_Prob:
			Tech_Explosion = true
			Tech_Explosion_Num += 1
			Tech_Rest_time = rand.randi_range(10, 100)  # 10-100之间取随机整数
	elif Tech_Explosion and Tech_Rest_time != 0:
		Tech_Rest_time -= 1  # 革命结束年限-1
		Technol += Technol * Tech_Explosion_t  # 革命结束期间技术增长值
	elif Tech_Explosion and Tech_Rest_time == 0:  # 技术革命结束
		Tech_Explosion = false

	# 文明的生命值增加
	Living += Living*Living_l*(1-Living / min(All_Resource*Resource_lr, Technol*Technol_lt))

	# 发生天灾
	if rand.randf() < Disaster_Prob:
		Living = Living * Disaster_k_Living
		Technol = Technol * Disaster_k_Tech

	# 每回合，资源都会消耗
	var this_year_resource_use = Technol * Resource_rt + Living * Resource_rl
	All_Resource -= this_year_resource_use
	# 每个星系内的资源平均减少
	var n = this_year_resource_use / domains.size()
	for s in domains:
		s.resource -= n
	# 使用过的资源量
	Used_Resource += this_year_resource_use
	
	# 合计文明总占有资源量
	var all_res = 0
	for s in domains:
		if s.resource <= 1: # 如果该Star的资源量小于等于0，就解除占领
			domains.erase(s)
			s.queue_free() # 资源耗尽，清除显示
			Global.STAR_LIST.erase(s) # 从STAR_LIST中清除
			Global.STAR_NUM -= 1 # Star数量-1
		else:
			all_res += s.resource
	All_Resource = all_res

	# 更新军力值
	AC = al * Living + at * Technol
	
	return 0
