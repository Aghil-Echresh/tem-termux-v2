# T-Termux v2 🚀

نسخه بازطراحی‌شده و ایمن‌تر پروژه `tem-termux` برای شخصی‌سازی Termux.

## امکانات

- نصب خودکار `zsh`، `git` و `figlet`
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- Prompt مدرن با Git status
- Banner سبک و بدون فایل Ruby Gem
- بکاپ قبل از تغییر `.zshrc`
- پنل مدیریتی `ttermux`
- Doctor برای بررسی نصب
- Update پلاگین‌ها
- Restore تنظیمات
- Uninstall بدون پاک‌کردن کورکورانه کل home
- سازگارتر با مسیرهای واقعی Termux و بدون hard-code کردن `/data/data/com.termux/...`

## نصب

```bash
pkg update -y
pkg install -y git
git clone https://github.com/Aghil-Echresh/tem-termux.git
cd tem-termux
bash install.sh
exec zsh
```

## مدیریت

```bash
ttermux
```

یا:

```bash
ttermux doctor
ttermux backup
ttermux restore
ttermux update
ttermux uninstall
```

## تفاوت مهم با نسخه قدیمی

نسخه قبلی هنگام نصب، `.zshrc` را با `cat >>` تغییر می‌داد و در بعضی مسیرها فایل‌های تنظیماتی را با `rm -rf` حذف می‌کرد. نسخه v2 ابتدا بکاپ می‌گیرد و فقط بخش مدیریت‌شده خودش را کنترل می‌کند.

همچنین وابستگی به `lolcat*.gem` و نصب Ruby برای Banner حذف شده است. پلاگین‌ها مستقیماً از مخزن رسمی خودشان دریافت می‌شوند.

## تست

```bash
bash -n install.sh
bash -n lib/ttermux
bash -n lib/ttermux-banner
```

## مجوز

این پروژه را با حفظ اعتبار نویسنده اصلی و با هدف بازطراحی فنی منتشر کنید.
