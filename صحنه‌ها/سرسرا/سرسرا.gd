extends Control
@export var اعلان: PackedScene = preload(بازی.اعلان)
var شکلک_برگزیده = بازی.شکلک_دل
var گوینده = PacketPeerUDP.new()


@rpc("any_peer")
func درخواست_تجسم(بازیکن):
	if $"گزینه‌ها/سربرگ‌ها/تجسم/فهرست".has_node(str(بازیکن)):
		return 1
	if بازی.داده‌ها.has("بازیکنان"):
		if بازی.داده‌ها["بازیکنان"].has(بازیکن):
			return 1
	var داده = {
			"نام": بازی.داده‌ها["تماشاگران"][بازیکن]["نام"],
			"امتیاز": 0,
			"اندیس": بازیکن
		}
	var نودرخواست = HFlowContainer.new()
	نودرخواست.name = str(بازیکن)
	var نام = Label.new()
	نام.text = بازی.داده‌ها["تماشاگران"][بازیکن]["نام"]
	نام.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	نام.size_flags_horizontal = SIZE_EXPAND_FILL
	var دکمه = Button.new()
	دکمه.pressed.connect(تجسم.rpc.bind(داده))
	دکمه.text = "تجسم"
	نودرخواست.add_child(نام)
	نودرخواست.add_child(دکمه)
	$"گزینه‌ها/سربرگ‌ها/تجسم/فهرست".add_child(نودرخواست)


@rpc("call_local")
func تجسم(داده: Dictionary):
	if multiplayer.is_server() and داده["اندیس"] != 1:
		$"گزینه‌ها/سربرگ‌ها/تجسم/فهرست".get_node(str(داده["اندیس"])).queue_free()
	if not بازی.داده‌ها.has("بازیکنان"):
		بازی.داده‌ها["بازیکنان"] = {}
	بازی.داده‌ها["بازیکنان"][داده["اندیس"]] = داده
	if len(بازی.داده‌ها["بازیکنان"]) == 1:
		$"راست".show()
		بازی.داده‌ها["بازیکنان"][داده["اندیس"]]["سمت"] = "راست"
	else:
		$"چپ".show()
		بازی.داده‌ها["بازیکنان"][داده["اندیس"]]["سمت"] = "چپ"


func فشردن_تجسم(بودن: bool):
	if بودن:
		if multiplayer.is_server():
			if not بازی.داده‌ها.has("بازیکنان") or len(بازی.داده‌ها["بازیکنان"].keys()) == 0:
				var داده = {
						"نام": بازی.داده‌ها["نام"],
						"امتیاز": 0,
						"اندیس": 1
					}
				تجسم.rpc(داده)
			elif len(بازی.داده‌ها["بازیکنان"].keys()) == 1 and not بازی.داده‌ها["بازیکنان"].has(1):
				var داده = {
						"نام": بازی.داده‌ها["نام"],
						"امتیاز": 0,
						"اندیس": 1
					}
				تجسم.rpc(داده)
			elif len(بازی.داده‌ها["بازیکنان"].keys()) >= 2:
				pass
			else:
				pass
		else:
			if بازی.داده‌ها.has("بازیکنان"):
				if len(بازی.داده‌ها["بازیکنان"]) == 2:
					$"پا/تجسم".button_pressed = false
					return 1
			درخواست_تجسم.rpc_id(1, multiplayer.get_unique_id())
	else:
		if multiplayer.is_server():
			pass
		else:
			pass


@rpc("any_peer")
func کسی_به_ما_پیوست(اندیس):
	اعلان_کسی_به_ما_پیوست.rpc_id(اندیس, multiplayer.get_unique_id(), بازی.داده‌ها)


func بگو():
	var داده = JSON.stringify(بازی.داده‌ها)
	گوینده.put_packet(داده.to_utf8_buffer())


func آماده‌سازی_شکلکان():
	for شکلک in بازی.شکلکان.values():
		var دکمه = Button.new()
		دکمه.size_flags_horizontal = SIZE_EXPAND_FILL
		دکمه.size_flags_vertical = SIZE_EXPAND_FILL
		دکمه.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		دکمه.icon = load(شکلک)
		دکمه.pressed.connect(تغییرشکلک.bind(شکلک))
		$"شکلک/نگهدارنده".add_child(دکمه)


func نمایش_شکلکان():
	$"شکلک".show()


func نگهداشتن_فرستادن_شکلک():
	await get_tree().create_timer(1.5).timeout
	if $"پا/فرستادن_شکلک".button_pressed:
		شکلک_در_شبکه.rpc(شکلک_برگزیده, 11)
		شکلک_بفرست(شکلک_برگزیده, 11)
		$"پا/فرستادن_شکلک".disabled = true
		await get_tree().create_timer(2.5).timeout
		$"پا/فرستادن_شکلک".disabled = false


func فشردن_فرستادن_شکلک():
	if not $"پا/فرستادن_شکلک".is_hovered():
		return 0
	شکلک_بفرست(شکلک_برگزیده, 1)
	شکلک_در_شبکه.rpc(شکلک_برگزیده)


func تغییرشکلک(شکلک: String):
	$"شکلک".hide()
	$"پا/فرستادن_شکلک".icon = load(شکلک)
	شکلک_برگزیده = شکلک


func شکلک_بفرست(شکلک, شمار):
	var نمونه_شکلک = preload(بازی.شکلک).instantiate()
	نمونه_شکلک.position = $"پا/فرستادن_شکلک".global_position
	نمونه_شکلک.amount = شمار
	نمونه_شکلک.texture = load(شکلک)
	add_child(نمونه_شکلک)


@rpc("any_peer", "call_remote")
func شکلک_در_شبکه(شکلک: String, شمار: int = 1):
	if not $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/دریافت شکلک".button_pressed:
		return 1
	شکلک_بفرست(شکلک, شمار)


@rpc("any_peer")
func اعلان_کسی_به_ما_پیوست(اندیس: int, داده: Dictionary):
	if not بازی.داده‌ها.has(اندیس):
		بازی.داده‌ها["تماشاگران"] = {
			اندیس: {
				"نام": داده["نام"],
				"اندیس": اندیس,
				"بردها": داده["بردها"],
				"بازی‌ها": داده["بازی‌ها"]
			}
		}
		var برچسب_نام_نوبازیکن = Label.new()
		برچسب_نام_نوبازیکن.text = داده["نام"]
		برچسب_نام_نوبازیکن.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$"گزینه‌ها/سربرگ‌ها/بازی/داده‌ها".add_child(برچسب_نام_نوبازیکن)
		if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/دریافت اعلان".button_pressed:
			var نواعلان = اعلان.instantiate()
			نواعلان.text = نواعلان.text.format([داده["نام"]])
			add_child(نواعلان)
		if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/نگاشتن تاریخچه اعلان‌ها".button_pressed:
			var برچسب = Label.new()
			برچسب.text = "{0} به کارساز پیوست".format([داده["نام"]])
			برچسب.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			$"گزینه‌ها/سربرگ‌ها/تاریخچه اعلان‌ها/فهرست".add_child(برچسب)

func فرستادن_سریع(پیام):
	if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/فرستادن پیام با فشردن کلید <Enter>".button_pressed:
		فشردن_فرستادن_پیام()


@rpc("any_peer", "call_remote")
func پیام_بفرست(متن: String, فرستنده: String):
	var پیام = فرستنده + ": " + متن
	if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/دریافت پیام".button_pressed:
		var نواعلان = اعلان.instantiate()
		نواعلان.text = پیام
		add_child(نواعلان)
	if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/نگاشتن تاریخچه پیام‌ها".button_pressed:
		var برچسب = Label.new()
		برچسب.text = پیام
		برچسب.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$"گزینه‌ها/سربرگ‌ها/تاریخچه پیام‌ها/فهرست".add_child(برچسب)


func فشردن_فرستادن_پیام():
	if not $"پا/پیام".text.strip_edges():
		$"هشدار".show()
		return 0
	پیام_بفرست.rpc($"پا/پیام".text, بازی.داده‌ها["نام"])
	$"پا/پیام".text = ""


func پیکربندی():
	$"گزینه‌ها".show()


func من_همانم_که_هستم(بودن: bool):
	if بودن:
		گوینده.set_broadcast_enabled(true)
		گوینده.set_dest_address("255.255.255.255", بازی.درگاه + 1)
		$"بودن".paused = false
	else:
		گوینده.close()
		$"بودن".paused = true


func _ready():
	آماده‌سازی_شکلکان()
	$"گزینه‌ها/سربرگ‌ها/بازی/داده‌ها/نشانی".text += بازی.نشانی
	$"گزینه‌ها/سربرگ‌ها/بازی/داده‌ها/درگاه".text += str(بازی.درگاه)
	$"پا/فرستادن_شکلک".button_up.connect(فشردن_فرستادن_شکلک)
	$"پا/فرستادن_شکلک".button_down.connect(نگهداشتن_فرستادن_شکلک)
	multiplayer.peer_connected.connect(کسی_به_ما_پیوست)
	if multiplayer.is_server():
		گوینده.set_broadcast_enabled(true)
		گوینده.set_dest_address("255.255.255.255", بازی.درگاه + 1)
		$"بودن".start()
	else:
		$"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/بودن".queue_free()
		$"بودن".queue_free()
		$"گزینه‌ها/سربرگ‌ها/تجسم".queue_free()
