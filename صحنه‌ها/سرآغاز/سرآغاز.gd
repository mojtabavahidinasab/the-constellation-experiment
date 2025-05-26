extends Control
var شنونده = PacketPeerUDP.new()
var کارسازان: Dictionary = {}


func ازنوبشنو(کران‌پایین, کران‌بالا):
	for درگاه in range(بازی.کران‌پایین_درگاه, بازی.کران‌بالای_درگاه):
			var خطا = شنونده.bind(درگاه)
			if خطا == OK:
				بازی.درگاه = درگاه
				print("port: ", درگاه)
				break


func پیوستن(نشانی: String, درگاه: int, خودکار: bool = true):
	print("addr: ", نشانی, ", port: ", درگاه)
	if $"رابط/نام".text.strip_edges() == "":
		$هشدار.show()
		return 0
	if خودکار:
		if کارسازان[نشانی]["نام"] == $"رابط/نام".text.strip_edges():
			$"هشدار".dialog_text = بازی.خطانام_یکسان
			$"هشدار".show()
			return 0
	var خطا = بازی.کارساز.create_client(نشانی, درگاه)
	if خطا == OK:
		بازی.داده‌ها["نام"] = $"رابط/نام".text
		multiplayer.multiplayer_peer = بازی.کارساز
		get_tree().change_scene_to_file(بازی.سرسرا)


func پیوستن_خودکار():
	$"رابط/درگاه".hide()
	$"رابط/سردر".show()
	$"رابط/کارساز".show()
	$"رابط/نشانی".hide()
	$"رابط/کار/ساز".show()
	$"رابط/کار/همگام".show()
	$"رابط/کار/دستی".show()
	$"رابط/کار/خودکار".hide()
	$"رابط/کار/پیوستن".hide()
	if درگاه_درست_است():
		بازی.درگاه = int($"رابط/درگاه".text)


func پیوستن_دستی(بپیوندم: bool = false):
	$"رابط/درگاه".show()
	$"رابط/سردر".hide()
	$"رابط/کارساز".hide()
	$"رابط/نشانی".show()
	$"رابط/کار/ساز".hide()
	$"رابط/کار/همگام".hide()
	$"رابط/کار/دستی".hide()
	$"رابط/کار/خودکار".show()
	$"رابط/کار/پیوستن".show()
	if بپیوندم:
		if درگاه_درست_است():
			بازی.درگاه = $"رابط/درگاه".text.strip_edges()
		if نشانی_درست_است():
			بازی.نشانی = $"رابط/نشانی".text.strip_edges()
		پیوستن(بازی.نشانی, بازی.درگاه, false)


func درگاه_درست_است():
	if $"رابط/درگاه".text.strip_edges().begins_with("-"):
		return false
	if not $"رابط/درگاه".text.strip_edges().is_valid_int():
		return false
	return true


func نشانی_درست_است():
	if not $"رابط/نشانی".text.strip_edges().is_valid_ip_address():
		return false
	return true


func همگام‌سازی():
	if not $"رابط/نام".text or $"رابط/نام".text.strip_edges() == "":
		$هشدار.show()
		return 0
	if not شنونده.is_bound():
		print("local ips: ", IP.get_local_addresses())
		شنونده.bind(بازی.درگاه + 1)
	if شنونده.get_available_packet_count() > 0:
		var داده_خام = شنونده.get_packet()
		var نشانی = شنونده.get_packet_ip()
		var درگاه = شنونده.get_packet_port()
		if درگاه == 0:
			return 0
		var داده_متنی = داده_خام.get_string_from_utf8()
		var داده = JSON.parse_string(داده_خام.get_string_from_utf8())
		if not کارسازان.has(نشانی):
			var اندیس: String = str(len(کارسازان.keys()) + 1)
			کارسازان[نشانی] = {"نام": داده["نام"], "شمارگان": داده["شمارگان"]}
			var داده‌های_کارساز = HBoxContainer.new()
			داده‌های_کارساز.name = اندیس
			var شمارگان = Label.new()
			شمارگان.text = str(داده["شمارگان"])
			شمارگان.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			شمارگان.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			شمارگان.size_flags_horizontal = SIZE_EXPAND_FILL
			var نام = Button.new()
			نام.alignment = HORIZONTAL_ALIGNMENT_CENTER
			نام.text = داده["نام"]
			نام.pressed.connect(پیوستن.bind(نشانی, درگاه))
			نام.size_flags_horizontal = SIZE_EXPAND_FILL
			var اندیس_کارساز = Label.new()
			اندیس_کارساز.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			اندیس_کارساز.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			اندیس_کارساز.text = اندیس
			$"رابط/کارساز/فهرست".add_child(داده‌های_کارساز)
			var نمونه_داده‌های_کارساز = get_node("رابط/کارساز/فهرست/{0}".format([int(اندیس)]))
			نمونه_داده‌های_کارساز.add_child(شمارگان)
			نمونه_داده‌های_کارساز.add_child(نام)
			نمونه_داده‌های_کارساز.add_child(اندیس_کارساز)


func بستن_هشدار():
	$هشدار.hide()
	$"هشدار".dialog_text = بازی.خطانام


func کارسازبساز():
	if not $"رابط/نام".text or $"رابط/نام".text.strip_edges() == "":
		$هشدار.show()
		return 0
	var خطا = بازی.کارساز.create_server(بازی.درگاه)
	if خطا == OK:
		print("new port: ", بازی.درگاه)
		multiplayer.multiplayer_peer = بازی.کارساز
		بازی.داده‌ها["نام"] = $"رابط/نام".text
		بازی.داده‌ها["شمارگان"] = multiplayer.get_peers()
		get_tree().change_scene_to_file(بازی.سرسرا)
	else:
		بازی.درگاه = randi_range(بازی.کران‌پایین_درگاه, بازی.کران‌بالای_درگاه)
