extends Control
@export var اعلان: PackedScene = preload(بازی.اعلان)
var شکلک_برگزیده = بازی.شکلک_دل
var گوینده = PacketPeerUDP.new()
var دست: int = 0
var دست‌ها: Dictionary
var حرکت_موقت: String = ""
var بازیکنان: Dictionary
var تماشاگران: Dictionary
var کران‌بالای_دست: int = 6
var شمارش_آغاز: int = 0
var متن_موقت: String = ""
var آیا_بازی_درجریان_است: bool = false
signal شدآمداعلان
signal برنده_آشکار_گشت


@rpc("any_peer")
func درخواست_تجسم(بازیکن):
	if $"گزینه‌ها/سربرگ‌ها/تجسم/فهرست".has_node(str(بازیکن)):
		return 1
	if بازی.داده‌ها.has("بازیکنان"):
		if بازیکنان.has(بازیکن):
			return 1
	var داده = {
			"نام": تماشاگران[بازیکن]["نام"],
			"امتیاز": 0,
			"اندیس": بازیکن
		}
	var نودرخواست = HFlowContainer.new()
	نودرخواست.name = str(بازیکن)
	var نام = Label.new()
	نام.text = تماشاگران[بازیکن]["نام"]
	نام.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	نام.size_flags_horizontal = SIZE_EXPAND_FILL
	var دکمه = Button.new()
	دکمه.pressed.connect(تجسم.bind(داده))
	دکمه.text = "تجسم"
	نودرخواست.add_child(نام)
	نودرخواست.add_child(دکمه)
	$"گزینه‌ها/سربرگ‌ها/تجسم/فهرست".add_child(نودرخواست)


@rpc("call_local")
func آماده_کردن_بازیکنان_برای_بازی(آشکار: bool, کدام_دست: String):
	if آشکار:
		if get_node("گزینش {0}/سنگ".format([کدام_دست])).pressed.get_connections().is_empty():
			get_node("گزینش {0}/سنگ".format([کدام_دست])).pressed.connect(گزینش.bind(کدام_دست, "سنگ"))
			get_node("گزینش {0}/کاغذ".format([کدام_دست])).pressed.connect(گزینش.bind(کدام_دست, "کاغذ"))
			get_node("گزینش {0}/قیچی".format([کدام_دست])).pressed.connect(گزینش.bind(کدام_دست, "قیچی"))
		get_node("گزینش {0}".format([کدام_دست])).show()
		get_node("گزینش {0}/پویانمایی".format([کدام_دست])).play("آغاز")
	else:
		get_node("گزینش {0}/سنگ".format([کدام_دست])).button_pressed = false
		get_node("گزینش {0}/کاغذ".format([کدام_دست])).button_pressed = false
		get_node("گزینش {0}/قیچی".format([کدام_دست])).button_pressed = false
		get_node("گزینش {0}".format([کدام_دست])).hide()
		get_node("گزینش {0}/پویانمایی".format([کدام_دست])).play("RESET")


@rpc("call_local")
func درخواست_همگام‌سازی_حرکت():
	همگام‌سازی_حرکت.rpc(multiplayer.get_unique_id(), حرکت_موقت)
	await get_tree().create_timer(2).timeout
	حرکت_موقت = ""


@rpc("call_local", "any_peer")
func همگام‌سازی_حرکت(بازیکن, حرکت):
	if not دست‌ها.has(دست):
		دست‌ها[دست] = {}
	دست‌ها[دست][بازیکن] = حرکت


func گزینش(سمت: String, حرکت: String):
	if حرکت_موقت == حرکت or not حرکت_موقت.is_empty():
			get_node("گزینش {0}/{1}".format([سمت, "پویانمایی"])).play_backwards(حرکت_موقت)
			await get_node("گزینش {0}/{1}".format([سمت, "پویانمایی"])).animation_finished
			get_node("گزینش {0}/{1}".format([سمت, "پویانمایی"])).play(حرکت)
	else:
		get_node("گزینش {0}/{1}".format([سمت, "پویانمایی"])).play(حرکت)
	حرکت_موقت = حرکت



@rpc("any_peer", "call_local")
func اعلان_بفرست(متن_اعلان: String, نگاشتن: bool = false):
	if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/دریافت اعلان":
		var نواعلان = اعلان.instantiate()
		نواعلان.text = متن_اعلان
		add_child(نواعلان)
	if نگاشتن and $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/نگاشتن تاریخچه اعلان‌ها".button_pressed:
		var نوتاریخ = Label.new()
		نوتاریخ.text = متن_اعلان
		نوتاریخ.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$"گزینه‌ها/سربرگ‌ها/تاریخچه اعلان‌ها/فهرست".add_child(نوتاریخ)
	await get_tree().create_timer(1).timeout
	شدآمداعلان.emit()

@rpc("any_peer")
func بررسی_برنده(کسی: int, دیگری: int):
	var حرکت_کسی: String = ""
	var سمت_کسی = بازیکنان[کسی]["سمت"]
	var حرکت_دیگری: String = ""
	var سمت_دیگری = بازیکنان[دیگری]["سمت"]
	if دست‌ها[دست].has(کسی):
		حرکت_کسی = دست‌ها[دست][کسی]
		if not حرکت_کسی.is_empty():
			get_node("{0}/پویانمایی".format([سمت_کسی])).play("پایان")
			await get_node("{0}/پویانمایی".format([سمت_کسی])).animation_finished
			get_node("{0}".format([سمت_کسی])).play(حرکت_کسی)
	if دست‌ها[دست].has(دیگری):
		حرکت_دیگری = دست‌ها[دست][دیگری]
		if not حرکت_دیگری.is_empty():
			get_node("{0}/پویانمایی".format([سمت_دیگری])).play("پایان")
			await get_node("{0}/پویانمایی".format([سمت_دیگری])).animation_finished
			get_node("{0}".format([سمت_دیگری])).play(حرکت_دیگری)
	var برنده: int
	var بازنده: int
	var نام_برنده: String = ""
	var نام_بازنده: String = ""
	if حرکت_کسی == حرکت_دیگری and not حرکت_دیگری.is_empty():
		برنده = 0
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "هیچکس برنده نشد."
	elif حرکت_کسی == حرکت_دیگری and حرکت_دیگری.is_empty():
		برنده = 0
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "هیچکس برنده نشد."
	elif not حرکت_کسی.is_empty() and حرکت_دیگری.is_empty():
		برنده = کسی
		نام_برنده = بازیکنان[کسی]["نام"]
		بازنده = دیگری
		نام_بازنده = بازیکنان[دیگری]["نام"]
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "{0} بر {1} چیره شد.".format([نام_برنده, نام_بازنده])
	elif حرکت_کسی.is_empty() and not حرکت_دیگری.is_empty():
		برنده = دیگری
		نام_برنده = بازیکنان[دیگری]["نام"]
		بازنده = کسی
		نام_بازنده = بازیکنان[کسی]["نام"]
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "{0} بر {1} چیره شد.".format([نام_برنده, نام_بازنده])
	elif حرکت_کسی == "سنگ" and حرکت_دیگری == "کاغذ":
		برنده = دیگری
		نام_برنده = بازیکنان[دیگری]["نام"]
		بازنده = کسی
		نام_بازنده = بازیکنان[کسی]["نام"]
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "{0} بر {1} چیره شد.".format([نام_برنده, نام_بازنده])
	elif حرکت_کسی == "سنگ" and حرکت_دیگری == "قیچی":
		برنده = کسی
		نام_برنده = بازیکنان[کسی]["نام"]
		بازنده = دیگری
		نام_بازنده = بازیکنان[دیگری]["نام"]
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "{0} بر {1} چیره شد.".format([نام_برنده, نام_بازنده])
	elif حرکت_کسی == "کاغذ" and حرکت_دیگری == "سنگ":
		برنده = کسی
		نام_برنده = بازیکنان[کسی]["نام"]
		بازنده = دیگری
		نام_بازنده = بازیکنان[دیگری]["نام"]
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "{0} بر {1} چیره شد.".format([نام_برنده, نام_بازنده])
	elif حرکت_کسی == "کاغذ" and حرکت_دیگری == "قیچی":
		برنده = دیگری
		نام_برنده = بازیکنان[دیگری]["نام"]
		بازنده = کسی
		نام_بازنده = بازیکنان[کسی]["نام"]
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "{0} بر {1} چیره شد.".format([نام_برنده, نام_بازنده])
	elif حرکت_کسی == "قیچی" and حرکت_دیگری == "سنگ":
		برنده = دیگری
		نام_برنده = بازیکنان[دیگری]["نام"]
		بازنده = کسی
		نام_بازنده = بازیکنان[کسی]["نام"]
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "{0} بر {1} چیره شد.".format([نام_برنده, نام_بازنده])
	elif حرکت_کسی == "قیچی" and حرکت_دیگری == "کاغذ":
		برنده = کسی
		نام_برنده = بازیکنان[کسی]["نام"]
		بازنده = دیگری
		نام_بازنده = بازیکنان[دیگری]["نام"]
		دست‌ها[دست]["برنده"] = برنده
		متن_موقت = "{0} بر {1} چیره شد.".format([نام_برنده, نام_بازنده])
	await get_tree().create_timer(2).timeout
	if دست‌ها[دست].has(کسی):
		if not حرکت_کسی.is_empty():
			get_node("{0}/پویانمایی".format([سمت_کسی])).play_backwards("پایان")
			get_node("{0}".format([سمت_کسی])).play_backwards("سنگ")
	if دست‌ها[دست].has(دیگری):
		if not حرکت_دیگری.is_empty():
			get_node("{0}/پویانمایی".format([سمت_دیگری])).play_backwards("پایان")
			get_node("{0}".format([سمت_دیگری])).play_backwards("سنگ")
	برنده_آشکار_گشت.emit()

@rpc("any_peer", "call_local")
func آغاز():
	var کسی: int = بازیکنان.keys()[0]
	var سمت_کسی: String = بازیکنان[کسی]["سمت"]
	var دیگری: int = بازیکنان.keys()[1]
	var سمت_دیگری: String = بازیکنان[دیگری]["سمت"]
	آماده_کردن_بازیکنان_برای_بازی.rpc_id(کسی, false, سمت_کسی)
	آماده_کردن_بازیکنان_برای_بازی.rpc_id(دیگری, false, سمت_دیگری)
	for هردست in کران‌بالای_دست:
		اعلان_بفرست("آماده...")
		آماده_کردن_بازیکنان_برای_بازی.rpc_id(کسی, true, سمت_کسی)
		آماده_کردن_بازیکنان_برای_بازی.rpc_id(دیگری, true, سمت_دیگری)
		await get_tree().create_timer(4).timeout
		اعلان_بفرست(بازی.سنگ)
		$"راست/پویانمایی".play("پویانمایی")
		$"چپ/پویانمایی".play("پویانمایی")
		await get_tree().create_timer(2).timeout
		اعلان_بفرست(بازی.کاغذ)
		$"راست/پویانمایی".play("پویانمایی")
		$"چپ/پویانمایی".play("پویانمایی")
		await get_tree().create_timer(1).timeout
		اعلان_بفرست(بازی.قیچی)
		await get_tree().create_timer(1).timeout
		آماده_کردن_بازیکنان_برای_بازی.rpc_id(کسی, false, سمت_کسی)
		آماده_کردن_بازیکنان_برای_بازی.rpc_id(دیگری, false, سمت_دیگری)
		درخواست_همگام‌سازی_حرکت.rpc_id(دیگری)
		درخواست_همگام‌سازی_حرکت.rpc_id(کسی)
		await get_tree().create_timer(1).timeout
		بررسی_برنده.rpc(کسی, دیگری)
		await برنده_آشکار_گشت
		await get_tree().create_timer(1).timeout
		اعلان_بفرست(متن_موقت, true)
		await get_tree().create_timer(2).timeout
		دست += 1


func فشردن_خیر_بعدا_بازی_را_آغاز_کن():
	$"گزینه‌ها/سربرگ‌ها/بازی/داده‌ها/آغازبازی".show()


func فشردن_آغازبازی():
	$"گزینه‌ها/سربرگ‌ها/بازی/داده‌ها/آغازبازی".hide()
	آیا_بازی_درجریان_است = true
	آغاز.rpc()


func تجسم(داده: Dictionary):
	if multiplayer.is_server() and داده["اندیس"] != 1:
		$"گزینه‌ها/سربرگ‌ها/تجسم/فهرست".get_node(str(داده["اندیس"])).queue_free()
	بازیکنان[داده["اندیس"]] = داده
	if len(بازیکنان) == 1:
		$"راست".show()
		بازیکنان[داده["اندیس"]]["سمت"] = "راست"
		آماده_کردن_بازیکنان_برای_بازی.rpc_id(داده["اندیس"], true, "راست")
		$"نام راست".text = داده["نام"]
	else:
		$"چپ".show()
		بازیکنان[داده["اندیس"]]["سمت"] = "چپ"
		آماده_کردن_بازیکنان_برای_بازی.rpc_id(داده["اندیس"], true, "چپ")
		$"نام چپ".text = داده["نام"]
		if multiplayer.is_server():
			if $'گزینه‌ها'.visible and not آیا_بازی_درجریان_است:
				await $"گزینه‌ها".visibility_changed
			$"پرسش_برای_آغازبازی".show()


func بستن_هشدار():
	$"هشدار".hide()
	$"هشدار".dialog_text = بازی.خطاپیام


func باشه_هشدار():
	$"هشدار".hide()
	if $"هشدار".dialog_text == بازی.هشدارباخت:
		pass  #TODO
	$"هشدار".dialog_text = بازی.خطاپیام


func فشردن_تجسم(بودن: bool, داده: Dictionary = {}):
	if بودن:
		if multiplayer.is_server():
			if (not بازی.داده‌ها.has("بازیکنان") or len(بازیکنان.keys()) == 0) or not داده.is_empty():
				داده = {
						"نام": بازی.داده‌ها["نام"],
						"امتیاز": 0,
						"اندیس": 1
					}
				تجسم(داده)
			elif (len(بازیکنان.keys()) == 1 and not بازیکنان.has(1)) or داده.is_empty():
				داده = {
						"نام": بازی.داده‌ها["نام"],
						"امتیاز": 0,
						"اندیس": 1
					}
				تجسم.rpc(داده)
			elif len(بازیکنان) >= 2:
				$"هشدار".dialog_text = بازی.خطابازی_در_جریان
				$"هشدار".show()
				$"پا/تجسم".button_pressed = false
			else:
				pass
		else:
			if بازی.داده‌ها.has("بازیکنان"):
				if len(بازیکنان) == 2:
					$"هشدار".dialog_text = بازی.خطابازی_در_جریان
					$"هشدار".show()
					$"پا/تجسم".button_pressed = false
					return 1
			درخواست_تجسم.rpc_id(1, multiplayer.get_unique_id())
	else:
		$"هشدار".dialog_text = بازی.هشدارباخت
		$"هشدار".show()
		$"پا/تجسم".button_pressed = true


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
		شکلک_بفرست.rpc(شکلک_برگزیده, 11)
		$"پا/فرستادن_شکلک".disabled = true
		await get_tree().create_timer(2.5).timeout
		$"پا/فرستادن_شکلک".disabled = false


func فشردن_فرستادن_شکلک():
	if not $"پا/فرستادن_شکلک".is_hovered():
		return 0
	شکلک_بفرست.rpc(شکلک_برگزیده, 1)


func تغییرشکلک(شکلک: String):
	$"شکلک".hide()
	$"پا/فرستادن_شکلک".icon = load(شکلک)
	شکلک_برگزیده = شکلک


@rpc("any_peer", "call_local")
func شکلک_بفرست(شکلک, شمار):
	if not $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/دریافت شکلک".button_pressed:
		return 1
	var نمونه_شکلک = preload(بازی.شکلک).instantiate()
	نمونه_شکلک.position = $"پا/فرستادن_شکلک".global_position
	نمونه_شکلک.amount = شمار
	نمونه_شکلک.texture = load(شکلک)
	add_child(نمونه_شکلک)


@rpc("any_peer")
func اعلان_کسی_به_ما_پیوست(اندیس: int, داده: Dictionary):
	if not بازی.داده‌ها.has(اندیس):
		تماشاگران = {
			اندیس: {
				"نام": داده["نام"],
				"اندیس": اندیس,
				"بردها": داده["بردها"],
				"باخت‌ها": داده["باخت‌ها"],
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
	await get_tree().create_timer(1).timeout
	شدآمداعلان.emit()


@rpc("any_peer")
func کسی_به_ما_پیوست(اندیس):
	اعلان_کسی_به_ما_پیوست.rpc_id(اندیس, multiplayer.get_unique_id(), بازی.داده‌ها)
	await شدآمداعلان


func کسی_از_ما_جداشد(شناسه):
	var متن: String
	if بازیکنان.has(شناسه):
		متن = "{0} از کارساز جدا گشت.".format([بازیکنان[شناسه]["نام"]])
	elif تماشاگران.has(شناسه):
		متن = "{0} از کارساز جدا گشت.".format([تماشاگران[شناسه]["نام"]])
	if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/دریافت اعلان".button_pressed:
		var نواعلان = اعلان.instantiate()
		نواعلان.text = متن
		add_child(نواعلان)
	if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/نگاشتن تاریخچه اعلان‌ها".button_pressed:
		var برچسب = Label.new()
		برچسب.text = متن
		برچسب.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$"گزینه‌ها/سربرگ‌ها/تاریخچه اعلان‌ها/فهرست".add_child(برچسب)


func خروج():
	multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file(بازی.سرآغاز)


func فرستادن_سریع(پیام):
	if $"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/فرستادن پیام با فشردن کلید <Enter>".button_pressed:
		فشردن_فرستادن_پیام()


@rpc("any_peer", "call_remote")
func پیام_بفرست(متن_پیام: String, فرستنده: String):
	var پیام = فرستنده + ": " + متن_پیام
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
	multiplayer.peer_connected.connect(کسی_به_ما_پیوست)
	multiplayer.peer_disconnected.connect(کسی_از_ما_جداشد)
	#multiplayer.server_disconnected#TODO
	#multiplayer.connected_to_server#TODO
	#multiplayer.connection_failed#TODO
	if multiplayer.is_server():
		pass
	else:
		$"گزینه‌ها/سربرگ‌ها/پیکربندی/گزینه‌ها/بودن".queue_free()
		$"بودن".queue_free()
		$"گزینه‌ها/سربرگ‌ها/تجسم".queue_free()
		$"پرسش_برای_آغازبازی".queue_free()
