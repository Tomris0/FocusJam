FOCUSJAM 🎧⏱️

Birlikte çalış, aynı anda odaklan. Senkron kal. 🔥🤝

FocusJam, çalışma arkadaşlarınla veya ekibinle aynı anda odak oturumu başlatmanı sağlayan gerçek zamanlı senkron Pomodoro / fokus uygulamasıdır. Bir kişi oturumu başlatır (Host) 👑, diğerleri koda girerek katılır (Join) 🔑 ve herkes aynı süreyi aynı anda takip eder. “3…2…1… başla!” derdi biter, ritim bozulmaz. ✅

• Study together. Stay in sync. 🌍 

NEDEN FOCUSJAM? ❓
İki (veya daha fazla) kişi aynı anda Pomodoro başlatmaya çalışınca küçük gecikmeler büyür: sayaçlar saniyelerle kayar ⏳, molalar uyuşmaz ☕, grup ritmi bozulur 💔. FocusJam bunu çözer: tüm cihazlar tek bir ortak zaman çizelgesini takip eder. 🧭✅

MEVCUT AŞAMA: V1 (MVP) — GELİŞTİRME AŞAMASINDA 🛠️
Bu repo şu anda V1 MVP sürümünü içerir. Önce Kapalı Alfa (arkadaşlar / küçük grup) 👥 ile test, sonra Açık Beta 🧪, ardından mağaza yayını 🚀 planlanır.

V1 HEDEFLERİ (MVP) 🎯
• Oda sistemi (16 kişiye kadar) 👨‍👩‍👧‍👦
• Host / Join akışı 👑🔑
• Katılım yöntemi: 6 karakterli Join Code (MVP için en stabil yöntem) 🔐
• Oturum ayarları host tarafından kontrol edilir ⚙️

Çalışma süresi ⏱️

Mola süresi ☕

Set sayısı 🔁

Seçenek: “Mola toplam süreye dahil olsun mu?” (aç/kapat) ✅/❌
• Senkron sayaç: tek bir referans zamanına göre çalışacak (Firebase ile server timestamp yaklaşımı planlanıyor) 🌐🕒

ŞU ANA KADAR YAPILANLAR (WIP) ✅🚧
• Ana ekran UI (Create Room / Join with Code) 🏠
• Join akışı UI (bottom sheet + kod doğrulama) 🧾
• Create Room akışı (kod üretme + panoya kopyalama) 🧩📋

YOL HARİTASI 🗺️

V1 — MVP (Şu an) 🚀
Hedef: Güvenilir senkron grup timer ⏱️🤝
• Firebase Authentication: Google ile giriş, Email/Password ile giriş 🔐
• Firebase Realtime Database: odalar, üyeler, host durumu 🗃️
• Başlangıç zamanı server timestamp olarak tutulacak 🕒
• Room Lobby: üye listesi, host kontrolleri, oturum ayarları 👥⚙️
• Senkron başlat / durdur / duraklat (host yetkili) ▶️⏸️⏹️
• Kapalı Alfa → Açık Beta → Yayın 👥🧪🚀

V2 — Verimlilik Geliştirmeleri ⚡
Hedef: Daha esnek odak seçenekleri 🎛️
• Custom Sessions: çalışma/mola süreleri tamamen özelleştirilebilir, set presetleri 🧱
• Deep Work Mode: uzun kesintisiz çalışma blokları (örn: 60–90 dk) 🧠🔥
• Sprint Mode: yoğun kısa sprintler (ekipler/hackathon için uygun) 🏁
• Basit istatistikler: toplam odak süresi, tamamlanan oturumlar 📊

V3 — Ekip & Büyüme Özellikleri 🌱🏢
Hedef: Grup timer’dan hafif ekip odak platformuna evrilmek 🔄
• Agile Sprint Timer: sprint bazlı odak planlama 📅
• Gelişmiş istatistik ve raporlar 📈🧾
• Davet seçenekleri: link ile join, QR ile join, email daveti (opsiyonel, daha sonra) 🔗📷✉️
• Premium ekip özellikleri (dikkatli planlanacak, reklam yok) 💎🚫📢

GELİR MODELİ 💰
Reklam yok 🚫📺. Free + Premium kademeleri olacak 🆓💎. Amaç: kullanıcıya pahalı gelmeyecek, adil planlar 🤝✅.

TEKNOLOJİ 🧑‍💻
Flutter (Dart) 🦋
Android öncelikli, iOS planlı 🤖🍎
Planlanan backend: Firebase Authentication + Firebase Realtime Database 🔥🗃️

LOKAL ÇALIŞTIRMA ▶️
flutter pub get
flutter run

DURUM 📌
Aktif geliştirme — MVP adım adım test edilerek ilerliyor. 🚧✅
