# FOCUSJAM 🎧⏱️

**Birlikte çalış, aynı anda odaklan. Senkron kal. 🔥🤝**

FocusJam, çalışma arkadaşlarınla veya ekibinle aynı anda odak oturumu başlatmanı sağlayan gerçek zamanlı senkron Pomodoro / fokus uygulamasıdır. Bir kişi oturumu başlatır (**Host**) 👑, diğerleri koda girerek katılır (**Join**) 🔑 ve herkes aynı süreyi aynı anda takip eder. “3…2…1… başla!” derdi biter, ritim bozulmaz. ✅

• **Study together. Stay in sync. 🌍**

---

## NEDEN FOCUSJAM? ❓
İki (veya daha fazla) kişi aynı anda Pomodoro başlatmaya çalışınca küçük gecikmeler büyür: sayaçlar saniyelerle kayar ⏳, molalar uyuşmaz ☕, grup ritmi bozulur 💔. FocusJam bunu çözer: tüm cihazlar tek bir ortak zaman çizelgesini takip eder. 🧭✅

---

## MEVCUT AŞAMA: V1 (MVP) — GELİŞTİRME AŞAMASINDA 🛠️
Bu repo şu anda V1 MVP sürümünü içerir. Önce **Kapalı Alfa** (arkadaşlar / küçük grup) 👥 ile test, sonra **Açık Beta** 🧪, ardından mağaza yayını 🚀 planlanır.

---

## V1 HEDEFLERİ (MVP) 🎯
- **Oda sistemi (16 kişiye kadar)** 👨‍👩‍👧‍👦  
- **Host / Join akışı** 👑🔑  
- **Katılım yöntemi:** 6 karakterli **Join Code** (MVP için en stabil yöntem) 🔐  
- **Oturum ayarları** host tarafından kontrol edilir ⚙️  
  - Çalışma süresi ⏱️  
  - Mola süresi ☕  
  - Set sayısı 🔁  
  - Seçenek: “Mola toplam süreye dahil olsun mu?” (aç/kapat) ✅/❌  
- **Senkron sayaç:** tek bir referans zamanına göre çalışacak (Firebase ile **server timestamp** yaklaşımı planlanıyor) 🌐🕒  

---

## ŞU ANA KADAR YAPILANLAR (WIP) ✅🚧
- Ana ekran UI (Create Room / Join with Code) 🏠  
- Join akışı UI (bottom sheet + kod doğrulama) 🧾  
- Create Room akışı (kod üretme + panoya kopyalama) 🧩📋  

---

## YOL HARİTASI 🗺️

### V1 — MVP (Şu an) 🚀
**Hedef:** Güvenilir senkron grup timer ⏱️🤝  
- Firebase Authentication: Google ile giriş, Email/Password ile giriş 🔐  
- Firebase Realtime Database: odalar, üyeler, host durumu 🗃️  
- Başlangıç zamanı **server timestamp** olarak tutulacak 🕒  
- Room Lobby: üye listesi, host kontrolleri, oturum ayarları 👥⚙️  
- Senkron başlat / durdur / duraklat (host yetkili) ▶️⏸️⏹️  
- Kapalı Alfa → Açık Beta → Yayın 👥🧪🚀  

### V2 — Verimlilik Geliştirmeleri ⚡
**Hedef:** Daha esnek odak seçenekleri 🎛️  
- Custom Sessions: çalışma/mola süreleri tamamen özelleştirilebilir, set presetleri 🧱  
- Deep Work Mode: uzun kesintisiz çalışma blokları (örn: 60–90 dk) 🧠🔥  
- Sprint Mode: yoğun kısa sprintler (ekipler/hackathon için uygun) 🏁  
- Basit istatistikler: toplam odak süresi, tamamlanan oturumlar 📊  

### V3 — Ekip & Büyüme Özellikleri 🌱🏢
**Hedef:** Grup timer’dan hafif ekip odak platformuna evrilmek 🔄  
- Agile Sprint Timer: sprint bazlı odak planlama 📅  
- Gelişmiş istatistik ve raporlar 📈🧾  
- Davet seçenekleri: link ile join, QR ile join, email daveti (opsiyonel, daha sonra) 🔗📷✉️  
- Premium ekip özellikleri (dikkatli planlanacak, reklam yok) 💎🚫📢  

---

## GELİR MODELİ 💰
Reklam yok 🚫📺. Free + Premium kademeleri olacak 🆓💎. Amaç: kullanıcıya pahalı gelmeyecek, adil planlar 🤝✅.

---

## TEKNOLOJİ 🧑‍💻
- Flutter (Dart) 🦋  
- Android öncelikli, iOS planlı 🤖🍎  
- Planlanan backend: Firebase Authentication + Firebase Realtime Database 🔥🗃️  

---

## LOKAL ÇALIŞTIRMA ▶️
-bash
-flutter pub get
-flutter run

## DURUM 📌

Aktif geliştirme — MVP adım adım test edilerek ilerliyor. 🚧✅


---

eng
# FOCUSJAM 🎧⏱️

**Work together, focus at the same time. Stay in sync. 🔥🤝**

FocusJam is a real-time synchronized Pomodoro / focus-session app that helps you start sessions with your friends or team at the exact same moment. One person starts the session (**Host**) 👑, others join with a code (**Join**) 🔑, and everyone follows the same timeline. No more “3…2…1… start!” — the rhythm stays intact. ✅

• **Study together. Stay in sync. 🌍**

---

## WHY FOCUSJAM? ❓
When two (or more) people try to start a Pomodoro at the same time, small delays add up: timers drift by seconds ⏳, breaks don’t match ☕, and the group flow breaks 💔. FocusJam solves this by keeping all devices on one shared timeline. 🧭✅

---

## CURRENT STAGE: V1 (MVP) — IN DEVELOPMENT 🛠️
This repository currently contains the V1 MVP. We’ll test it in **Closed Alpha** (friends / small group) 👥 first, then **Open Beta** 🧪, and finally release it publicly 🚀.

---

## V1 GOALS (MVP) 🎯
- **Room system (up to 16 people)** 👨‍👩‍👧‍👦  
- **Host / Join flow** 👑🔑  
- **Join method:** 6-character **Join Code** (most reliable for MVP) 🔐  
- **Session settings** controlled by the host ⚙️  
  - Work duration ⏱️  
  - Break duration ☕  
  - Number of sets 🔁  
  - Option: “Include breaks in total time?” toggle ✅/❌  
- **Synchronized timer:** based on a single reference timeline (Firebase **server timestamp** planned) 🌐🕒  

---

## WHAT’S DONE SO FAR (WIP) ✅🚧
- Home UI (Create Room / Join with Code) 🏠  
- Join flow UI (bottom sheet + code validation) 🧾  
- Create Room flow (generate code + copy to clipboard) 🧩📋  

---

## ROADMAP 🗺️

### V1 — MVP (Now) 🚀
**Goal:** A reliable synchronized group timer ⏱️🤝  
- Firebase Authentication: Google sign-in + Email/Password 🔐  
- Firebase Realtime Database: rooms, members, host state 🗃️  
- Start time stored as **server timestamp** 🕒  
- Room Lobby: member list, host controls, session settings 👥⚙️  
- Synchronized start / stop / pause (host authority) ▶️⏸️⏹️  
- Closed Alpha → Open Beta → Public Launch 👥🧪🚀  

### V2 — Productivity Upgrades ⚡
**Goal:** More flexible focus options 🎛️  
- Custom Sessions: fully configurable work/break + presets 🧱  
- Deep Work Mode: longer uninterrupted blocks (e.g., 60–90 min) 🧠🔥  
- Sprint Mode: intense short sprints (great for teams/hackathons) 🏁  
- Basic stats: total focus time, sessions completed 📊  

### V3 — Team & Growth Features 🌱🏢
**Goal:** Evolve from a group timer into a lightweight team focus platform 🔄  
- Agile Sprint Timer: sprint-based focus planning 📅  
- Advanced stats & reports 📈🧾  
- Better invites: join link, QR join, email invites (optional later) 🔗📷✉️  
- Premium team features (carefully planned, no ads) 💎🚫📢  

---

## MONETIZATION 💰
No ads 🚫📺. Free + Premium tiers 🆓💎. Goal: fair, affordable plans that users won’t find “expensive” 🤝✅.

---

## TECH STACK 🧑‍💻
- Flutter (Dart) 🦋  
- Android first, iOS planned 🤖🍎  
- Planned backend: Firebase Authentication + Firebase Realtime Database 🔥🗃️  

---

## RUN LOCALLY ▶️
-bash
-flutter pub get
-flutter run

## STATUS 📌

Active development — MVP is built and tested iteratively. 🚧✅
