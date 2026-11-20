# دليل النشر في Google Play وApple App Store — إمبراطورية الذكاء (v2.0.0)

## 1. الأصول المجهزة داخل المشروع
* **أيقونة Google Play (512×512):** `store_assets/icon_512.png`
* **أيقونة Apple App Store (1024×1024 بدون شفافية):** `store_assets/icon_1024.png`
* **صورة الغلاف (Feature Graphic 1024×500):** `store_assets/feature_graphic_1024x500.png`
* **أيقونات أندرويد بجميع الكثافات:** مثبّتة جاهزة داخل `android/app/src/main/res/mipmap-*/ic_launcher.png` مع شاشة إطلاق داكنة (`#090E1A`).
* **سياسة الخصوصية:** `PRIVACY_POLICY.md` (ارفعها على GitHub Pages أو رابط عام وألصق الرابط في المتجرين).

## 2. خطوات بناء ورفع نسخة Google Play (AAB)
1. أنشئ مفتاح التوقيع مرة واحدة فقط (واحتفظ به بمكان آمن):
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
2. أنشئ ملف `android/key.properties` (لا ترفعه إلى GitHub):
```properties
storePassword=كلمة_مرور_المخزن
keyPassword=كلمة_مرور_المفتاح
keyAlias=upload
storeFile=upload-keystore.jks
```
3. تحقق من الاختبارات وابنِ حزمة المتجر `.aab`:
```bash
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
```
ستجد الملف الجاهز للرفع في: `build/app/outputs/bundle/release/app-release.aab`.

## 3. خطوات بناء ورفع نسخة Apple App Store (iOS)
1. أضف مجلد `ios/` من جهاز macOS يحتوي على Xcode:
```bash
flutter create --platforms=ios --org com.aiempire .
```
2. استبدل الأيقونة الافتراضية داخل `ios/Runner/Assets.xcassets/AppIcon.appiconset/` باستخدام `store_assets/icon_1024.png`.
3. اضبط في Xcode:
   * **Display Name:** `إمبراطورية الذكاء`
   * **Bundle Identifier:** `com.aiempire.aiEmpire`
   * **Signing & Capabilities:** اختر حساب Apple Developer الخاص بك.
4. ابنِ أرشيف النشر:
```bash
flutter build ipa --release
```
ثم ارفع الملف عبر **Transporter** أو **Xcode Organizer** إلى App Store Connect.

## 4. نصوص المتجر الجاهزة للنسخ

### العربية
* **العنوان:** إمبراطورية الذكاء — محاكي شركات AI
* **الوصف المختصر:** قُد شركتك الناشئة من مرآب صغير إلى صدارة سباق الذكاء الاصطناعي العالمي.
* **الوصف الكامل:**
  ابنِ إمبراطوريتك في عالم الذكاء الاصطناعي من الصفر. أدر رأس المال والحوسبة والبيانات وتدريب النماذج وإطلاق المنتجات، وواجه منافسين أذكياء وأحداثاً عالمية متقلبة. راقب نمو شركتك عبر مشهد حي ورسوم بيانية تاريخية، واستعن بالمستشار الاستراتيجي لتفادي الإفلاس وتصدر السوق أربعة أسابيع متتالية لتحقيق النصر. تعمل اللعبة بالكامل دون إنترنت ودون إعلانات أو تتبع.

### English
* **Title:** AI Empire: Tech Startup Sim
* **Short Description:** Lead your AI startup from a small garage to the top of the global AI race.
* **Full Description:**
  Build your AI empire from scratch. Balance cash runway, GPU compute, dataset quality, model training, research projects, product launches, and specialist hiring while competing against dynamic AI rivals and global events. Track growth with interactive charts, a live skyline scene, and a built-in strategic advisor. 100% offline with zero ads or data tracking.

## 5. إجابات نماذج الخصوصية (Data Safety / App Privacy)
* **Does your app collect or share user data?** → **No**
* **Data Not Collected** (App Store Privacy Nutrition Label)
* **Uses Encryption:** No (only standard OS storage, no custom encryption)
