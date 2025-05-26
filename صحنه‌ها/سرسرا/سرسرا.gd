extends Control
@export var اعلان: PackedScene = preload(بازی.اعلان)
var شکلک_برگزیده = بازی.شکلک_دل
var گوینده = PacketPeerUDP.new()


@rpc("any_peer")
func داده_بفرست(اندیس, نام):
	if not بازی.داده‌ها.has(اندیس):
		بازی.داده‌ها["بازیکنان"] = {
			اندیس: {
				"نام": نام,
				"اندیس": اندیس
			}
		}
		var نواعلان = اعلان.instantiate()
		نواعلان.text = نواعلان.text.format([نام])
		add_child(نواعلان)


@rpc("any_peer")
func کسی_به_ما_پیوست(اندیس):
	داده_بفرست.rpc_id(اندیس, multiplayer.get_unique_id(), بازی.داده‌ها["نام"])


func بگو():
	var داده = JSON.stringify(بازی.داده‌ها)
	گوینده.put_packet(داده.to_utf8_buffer())


func نمایش_شکلکان():
	$"شکلک".show()


@rpc("any_peer", "call_local")
func آمادگی_برای_فرستادن_شکلک(کی):
	if get_multiplayer_authority() != کی:
		return 1
	await get_tree().create_timer(1.5).timeout
	if $"کار/فرستادن_شکلک".button_pressed:
		شکلک_بفرست.rpc(شکلک_برگزیده, 11)
		$"کار/فرستادن_شکلک".disabled = true
		await get_tree().create_timer(2.5).timeout
		$"کار/فرستادن_شکلک".disabled = false


@rpc("any_peer")
func شکلک_درشبکه(نمونه):
	if نمونه is EncodedObjectAsID:
		add_child(instance_from_id(نمونه.object_id))
	else:
		add_child(نمونه)


func فشردن_فرستادن_شکلک():
	if not $"کار/فرستادن_شکلک".is_hovered():
		return 0
	شکلک_بفرست(شکلک_برگزیده)


@rpc("any_peer", "call_local")
func شکلک_بفرست(شکلک: String, شمار: int = 1):
	var نمونه_شکلک = preload(بازی.شکلک).instantiate()
	نمونه_شکلک.position = $"کار/فرستادن_شکلک".global_position
	نمونه_شکلک.amount = شمار
	نمونه_شکلک.texture = load(شکلک)
	add_child(نمونه_شکلک)


@rpc("any_peer", "call_remote")
func پیام_بفرست(متن: String, فرستنده: String):
	var نواعلان = اعلان.instantiate()
	نواعلان.text = فرستنده + ": " + متن
	add_child(نواعلان) 


func تجسم_فشردن():
	if multiplayer.is_server():
		# create hand (human color)
		pass
	else:
		# call to another function
		# request host to be
		# hand of white color
		# if accepted
		pass


@rpc
func پیام_بفرست_فشردن():
	if not $"کار/پیام".text.strip_edges():
		$"هشدار".show()
		return 0
	پیام_بفرست.rpc($"کار/پیام".text, بازی.داده‌ها["نام"])
	$"کار/پیام".text = ""


func تغییرشکلک(شکلک: String):
	$"کار/فرستادن_شکلک".icon = load(شکلک)
	شکلک_برگزیده = شکلک
	$"کار/فرستادن_شکلک".button_up.disconnect(شکلک_بفرست.rpc)
	$"کار/فرستادن_شکلک".button_up.connect(شکلک_بفرست.rpc.bind(شکلک_برگزیده))


func _ready():
	$"کار/فرستادن_شکلک".button_up.connect(شکلک_بفرست.rpc.bind(شکلک_برگزیده))
	$"کار/فرستادن_شکلک".button_down.connect(آمادگی_برای_فرستادن_شکلک.rpc.bind(get_multiplayer_authority()))
	for شکلک in بازی.شکلکان.values():
		var دکمه = Button.new()
		دکمه.icon = load(شکلک)
		دکمه.pressed.connect(تغییرشکلک.bind(شکلک))
		$"شکلک/نگهدارنده".add_child(دکمه)
	multiplayer.peer_connected.connect(کسی_به_ما_پیوست)
	if multiplayer.is_server():
		گوینده.set_broadcast_enabled(true)
		گوینده.set_dest_address("255.255.255.255", بازی.درگاه + 1)
		var تندی_گفتن = Timer.new()
		تندی_گفتن.autostart = true
		تندی_گفتن.timeout.connect(بگو)
		add_child(تندی_گفتن)
