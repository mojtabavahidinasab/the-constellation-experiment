extends Node
class_name بازی
const کران‌بالای_درگاه: int = 65535
const کران‌پایین_درگاه: int = 49152
const خانه: String = "127.0.0.1"
const خطانام = "خواهشمندم نام خود را بنویسید."
const خطانام_یکسان = "خواهشمندم نامتان را تغییر دهید."
const خطادرگاه = "درگاه درست نیست. باید شماره‌ای بین 49152 و 65535 باشد."
const خطانشانی = "نشانی درست نیست. باید رشته‌ای 127.0.0.1 گونه باشد."
const سرسرا = "uid://dkl4ai81i3wbp"
const سرآغاز = "uid://buby8xkxlyusy"
const راست = "uid://bmlopd7anw4d3"
const چپ = "uid://c8rdjpj0w2wkf"
const اعلان = "uid://bbejnooqc4jc8"
const شکلک = "uid://dcjfvulefkpyn"
const شکلک_دل = "uid://bfor52j5yk48l"
const شکلک_خواب = "uid://bw1l22bqumhic"
const شکلک_خواب۲ = "uid://ifnbi3v714aq"
const شکلک_ستاره = "uid://bfmergn7jqct3"
const شکلک_ستارگان = "uid://dlpsunvci1p0"
const شکلک_گرداب = "uid://de4flomcpp4lk"
const شکلک_شاد = "uid://d31p4x6vfpjnh"
const شکلک_اندوهگین = "uid://dkred3a8dqufr"
const شکلک_دلان = "uid://ccpjuj4vumkun"
const شکلک_دلشکسته = "uid://dljl3jpa3g132"
const شکلک_لامپ = "uid://34ys1uvyh1q0"
const شکلک_پرسش = "uid://c6g3pu6nax46a"
const شکلک_اخم = "uid://cj02fyrrpir4s"
const شکلک_تعجب = "uid://b1cmfowo6bh6l"
const شکلک_تعجب۲ = "uid://d1vgqsen6k155"
const شکلک_اشک = "uid://cl8nfd8m84l5m"
const شکلک_اکشان = "uid://bgfh433j2cf1i"
const شکلک_نقطه = "uid://bxmvp1cxfk1pl"
const شکلک_دونقطه = "uid://b0l8fwoiap8b4"
const شکلک_سه_نقطه = "uid://xyhied2ke5mf"
const شکلک_دلار = "uid://dbi8y8conappp"
const شکلک_دایره = "uid://mp87veue2wng"
const شکلک_ابر = "uid://brgjk38m5yxyr"
const شکلک_ضرب = "uid://01llewbusj7n"
const شکلک_موسیقی = "uid://c730lutwifdxk"
const شکلک_خشمگین = "uid://c5bpsl02qt5l8"
const شکلک_هشدار = "uid://b2ib1ymxcw6pt"
const شکلک_میله = "uid://wbkwqhga3dse"
const شکلک_هاها = "uid://3p181nb3ug4i"
const شکلکان = {
	"شکلک_خواب": شکلک_خواب,
	"شکلک_خواب۲": شکلک_خواب۲,
	"شکلک_ستاره": شکلک_ستاره,
	"شکلک_ستارگان": شکلک_ستارگان,
	"شکلک_گرداب": شکلک_گرداب,
	"شکلک_شاد": شکلک_شاد,
	"شکلک_اندوهگین": شکلک_اندوهگین,
	"شکلک_دلان": شکلک_دلان,
	"شکلک_دلشکسته": شکلک_دلشکسته,
	"شکلک_لامپ": شکلک_لامپ,
	"شکلک_پرسش": شکلک_پرسش,
	"شکلک_اخم": شکلک_اخم,
	"شکلک_تعجب": شکلک_تعجب,
	"شکلک_تعجب۲": شکلک_تعجب۲,
	"شکلک_اشک": شکلک_اشک,
	"شکلک_اکشان": شکلک_اکشان,
	"شکلک_نقطه": شکلک_نقطه,
	"شکلک_دونقطه": شکلک_دونقطه,
	"شکلک_سه_نقطه": شکلک_سه_نقطه,
	"شکلک_دلار": شکلک_دلار,
	"شکلک_دایره": شکلک_دایره,
	"شکلک_ابر": شکلک_ابر,
	"شکلک_ضرب": شکلک_ضرب,
	"شکلک_موسیقی": شکلک_موسیقی,
	"شکلک_خشمگین": شکلک_خشمگین,
	"شکلک_هشدار": شکلک_هشدار,
	"شکلک_میله": شکلک_میله,
	"شکلک_هاها": شکلک_هاها,
}
static var کارساز = ENetMultiplayerPeer.new()
static var درگاه: int = 49494
static var نشانی: String = خانه
static var داده‌ها: Dictionary = {
	"نام": "نام",
	"بردها": 0,
	"بازی‌ها": {}
	}
