# مافيا — موزع الأدوار الذكي | Mafia Role Dealer (`Obsidian Syndicate` v1.0)

<p align="center">
  <img src="assets/images/لوقو النيتف سبلاش.jpg" alt="Mafia App Logo" width="180" />
</p>

<p align="center">
  <strong>An offline-first, zero-latency Arabic pass-and-play Mafia role distributor & session companion engineered with Flutter, Clean Architecture, and the Obsidian Syndicate Design System.</strong>
</p>

<p align="center">
  <a href="https://github.com/Someooo/Mafia-app"><img src="https://img.shields.io/badge/GitHub-Someooo%2FMafia--app-161616?style=flat-square&logo=github" alt="Repository" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.24%2B-02569B?style=flat-square&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20%2B%20BLoC-D90429?style=flat-square" alt="Clean Architecture" />
  <img src="https://img.shields.io/badge/Directionality-Arabic%20RTL-0D0D0D?style=flat-square" alt="Arabic RTL" />
  <img src="https://img.shields.io/badge/Mode-100%25%20Offline-2E7D32?style=flat-square" alt="Offline" />
</p>

---

## 1. Overview & Core Value | نظرة عامة على المشروع

**Mafia Role Dealer (`مافيا — موزع الأدوار الذكي`)** is a complete offline Arabic-only (`RTL`) pass-and-play companion app built for live social-deduction tabletop sessions. It replaces worn paper decks, eliminates accidental peeking during phone handoffs, automates the first night's Mafia introduction with custom Arabic voiceover cues, and provides a live post-deal Verification Vault to verify eliminated players and track surviving faction balance in real time.

Built around the **"Obsidian Syndicate"** aesthetic (`#0D0D0D` Obsidian Canvas, `#161616` / `#1A1A1A` Charcoal Tiers, `#D90429` Syndicate Crimson CTAs & active glows, `#FFFFFF` crisp white typography), the app is optimized for low-light room environments and smooth 60–120 FPS performance on mid-range Android devices.

---

## 2. Key Features | المميزات الرئيسية

1. **Cryptographic Role Distribution (`Random.secure()`) for 6–18 Players:**
   - Enforces the **4 mandatory core roles** in every game: `شيخ المواطنين` (`citizens_leader`), `المسعف` (`medic`), `شيخ المافيا` (`mafia_leader`), and `مافيا التسكيت` (`silencer_mafia`).
   - Supports toggling **3 optional tactical roles** (`ولد الصالحين` `avenger_villager`, `القناص` `sniper`, `مافيا عادي` `regular_mafia`) while mathematically guaranteeing `remainingCitizenCount >= 0`.
   - Automatically fills remaining slots with `مواطن صالح` (`regular_citizen`) and shuffles via Fisher-Yates using `Random.secure()`.

2. **Sequential Player-to-Card Binding (`1..N`) & Anti-Cheat Privacy:**
   - Grid cards are unnumbered so each player freely picks any hidden `2:3` card on the table.
   - Tapping a card flips it in 3D (`Matrix4.rotationY`) into a large centered `2:3` spotlight modal (`width: 0.78 * screenWidth`, `BoxFit.contain`) so both the Arabic title and bottom role description are 100% visible and never cropped.
   - While one card is revealed, all other grid cards are locked. When claimed (`فهمت — اضغط للإخفاء`), the role is bound to `playerRoles[currentTurnPlayerNumber]` and an opaque privacy handoff shield (`مرر الهاتف للاعب رقم X`) blocks the screen until the next player takes the phone.

3. **Automated Night-1 Moderator (`الليدر الآلي — الليلة الأولى`):**
   - Transitions into a calm **Standby / Ready** state (`NightOnePhase.standby`) after the final card is claimed so players can place the phone in the center of the table and press **"بدء الليلة الأولى"** when ready.
   - Guides the table through 4 timed phases with custom Arabic voiceover MP3s (`assets/audio/`):
     1. **`everyoneSleep` (15s):** `"المدينة تغفو الآن... على الجميع إغماض أعينهم بالكامل"` (`night_sleep.mp3`)
     2. **`mafiaWake` (12s):** `"فريق المافيا فقط... افتحوا أعينكم الآن وتعرفوا على بعضكم بصمت"` (`mafia_wake.mp3` + pulsing crimson aura)
     3. **`mafiaSleep` (5s):** `"انتهى الوقت... فريق المافيا، أغمضوا أعينكم الآن"` (`mafia_sleep.mp3`)
     4. **`everyoneWake` (3s):** `"أشرق الصباح... على الجميع فتح أعينهم الآن. ابدأوا النقاش!"` (`city_wake.mp3`)
   - Includes instant controls for **"إعادة الصوت"** (`replayCurrentPhaseAudio()`), **"إعادة من البداية"** (`restartNightModerator()`), and **"تخطي"** (`skipNightModerator()`).

4. **Verification Vault (`خزنة التحقق من الهوية`), Live Faction Balance & Instant Rematch:**
   - **Live Faction Balance Bar:** Displays real-time surviving counts for Mafia (`المافيا الأحياء`) vs Citizens (`الصالحون الأحياء`).
   - **Automatic Win-Condition Detection:** Immediately alerts the table when Mafia reaches parity with Citizens (`isMafiaVictory`: `aliveMafiaCount >= aliveCitizensCount`) or when all Mafia members are eliminated (`isCitizensVictory`: `aliveMafiaCount == 0`).
   - **Player Number Lookup (`1..N`):** Enter an eliminated player's number to confirm and reveal their true `2:3` role card modal, logging them in the eliminated players chips list.
   - **Full Round Reveal & Instant Rematch:** Includes `"إعادة الليدر الآلي"`, `"كشف جميع الأدوار (نهاية الجولة)"`, and **"جولة جديدة (إعادة خلط فورية)"** (`startInstantRematch()`) to start a new round immediately with the same settings.

---

## 3. Roles Encyclopedia | دليل الأدوار

| الدور (Arabic Title) | المعرف (`id`) | الفريق (`Team`) | النوع (`Category`) | القدرة السرية (`Description`) |
| :--- | :--- | :--- | :--- | :--- |
| **شيخ المافيا** | `mafia_leader` | المافيا (`♠ م`) | أساسي إجباري | يختار ضحية كل ليلة |
| **مافيا التسكيت** | `silencer_mafia` | المافيا (`♠ م`) | أساسي إجباري | يمنع لاعباً من الكلام |
| **مافيا عادي** | `regular_mafia` | المافيا (`♠ م`) | تكتيكي اختياري | يتآمر مع فريقه |
| **شيخ المواطنين** | `citizens_leader` | المواطنون (`♦ مـ`) | أساسي إجباري | يقود النقاش ويكشف المؤامرات |
| **المسعف** | `medic` | المواطنون (`♦ مـ`) | أساسي إجباري | ينقذ لاعباً من القتل |
| **ولد الصالحين** | `avenger_villager` | المواطنون (`♦ مـ`) | تكتيكي اختياري | يسحب لاعباً معه |
| **القناص** | `sniper` | المواطنون (`♦ مـ`) | تكتيكي اختياري | يطلق على المافيا ليلاً |
| **مواطن صالح** | `regular_citizen` | المواطنون (`♦ مـ`) | مواطن أساسي (تلقائي) | يبحث مع فريقه |

---

## 📱 استعراض الشاشات وشرح الأزرار (Screens & Buttons Guide)

يستعرض هذا الدليل المصوّر جميع شاشات التطبيق ومراحل اللعب بالتسلسل الزمني، مع شرح تفصيلي لوظيفة كل شاشة وكل زر وعنصر تفاعلي فيها:

---

### 1. شاشة الترحيب الرئيسية (`HomeScreen`)

<p align="center">
  <img src="assets/images/appScreen/شاشه%20الترحيب.jpeg" alt="شاشة الترحيب الرئيسية" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  واجهة الاستقبال الرئيسية المصممة بثيم **"Obsidian Syndicate"** الداكن (`#0D0D0D`). تقوم بتحميل جميع صور البطاقات مسبقاً في الذاكرة (`GameAssetPrecacher.precacheAll`) لضمان سلاسة حركة القلب ثلاثية الأبعاد دون أي تقطيع أو وميض أبيض، وتمنح اللاعبين نقطة انطلاق سريعة لبدء جولة جديدة أو مراجعة قوانين الأدوار قبل اللعب.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **شارة `طاولة اللعب السرية`** | مؤشر علوي يعكس هوية الجلسة المحلية بدون إنترنت مع رموز أوراق اللعب (`♠ ♦`). |
| **زر `لعبة جديدة` (`▶`)** | الزر الرئيسي باللون القرمزي (`#D90429`)، ينقل المستخدم مباشرة إلى شاشة إعداد الجولة (`SetupScreen`). |
| **زر `دليل الأدوار` (`📖`)** | يفتح نافذة منبثقة سفلية (`RoleGuideSheet`) تستعرض جميع شخصيات اللعبة الـ 8 وقدراتها السرية. |

---

### 2. نافذة دليل الأدوار وشرح البطاقات (`RoleGuideSheet`)

<p align="center">
  <img src="assets/images/appScreen/شاشة%20شروحات%20الادوار%20والبطاقات.jpeg" alt="شاشة شروحات الأدوار والبطاقات" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  موسوعة مرجعية سريعة للاعبين الجدد والقدامى على الطاولة؛ تعرض جميع الأدوار الـ 8 مع صورها الفنية، والفريق الذي تنتمي إليه (`المافيا` باللون القرمزي أو `المواطنون` باللون السماوي)، ونوع الدور (`دور أساسي إجباري` أو `دور تكتيكي اختياري`)، والقدرة الخاصة بكل شخصية.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **زر الإغلاق (`✕`) / السحب للأسفل** | يغلق نافذة دليل الأدوار ويعيد المستخدم إلى الشاشة السابقة فوراً. |
| **قائمة البطاقات القابلة للتمرير** | تتيح تصفح جميع الأدوار الـ 8 ومراجعة تفاصيل كل بطاقة قبل بدء توزيع الأدوار. |

---

### 3. شاشة إعداد الجولة والأدوار الإجبارية (`SetupScreen` — الجزء العلوي)

<p align="center">
  <img src="assets/images/appScreen/شاشه%20اعداد%20جولة%20والكروت%20الرئيسية.jpeg" alt="شاشة إعداد جولة والكروت الرئيسية" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  لوحة التحكم في حجم الطاولة (`6` إلى `18` لاعباً) وعرض الأدوار الإجبارية الأربعة الثابتة في كل جولة. تحفظ هذه الشاشة إعداداتك تلقائياً في الذاكرة المحلية (`SharedPreferences`) بحيث تجد نفس إعدادات مجموعتك جاهزة عند فتح التطبيق في المرات القادمة.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **زر الرجوع (`←`)** | يعود إلى شاشة الترحيب الرئيسية (`HomeScreen`). |
| **زر المساعدة (`?`)** | يفتح نافذة `"دليل الأدوار"` من داخل شاشة الإعدادات لمراجعة أي دور. |
| **زر زيادة اللاعبين (`+`)** | يزيد عدد اللاعبين بمقدار `1` (بحد أقصى `18` لاعباً) مع نبضة اهتزاز لمسية (`HapticFeedback.lightImpact`) وحفظ فوري للإعداد. |
| **زر إنقاص اللاعبين (`-`)** | ينقص عدد اللاعبين بمقدار `1` (بحد أدنى `6` لاعبين)، ويقوم تلقائياً بإلغاء تفعيل الأدوار الاختيارية الزائدة إذا كان عدد المواطنين العاديين سينخفض تحت `0`. |
| **مؤشرا `فريق المافيا` و `فريق المواطنين`** | يعرضان التوزيع المتوقع للفريقين لحظياً بناءً على عدد اللاعبين والأدوار المفعّلة. |
| **بطاقات `الأدوار الإجبارية` (`🔒`)** | تعرض الأدوار الأربعة الأساسية المقفلة (`شيخ المواطنين`، `المسعف`، `شيخ المافيا`، `مافيا التسكيت`) الضرورية لتوازن أي جولة. |

---

### 4. شاشة إعداد الأدوار الاختيارية وشريط التوزيع (`SetupScreen` — الجزء السفلي)

<p align="center">
  <img src="assets/images/appScreen/شاشه%20اعداد%20جولة%20والكروت%20الاختيارية.jpeg" alt="شاشة إعداد جولة والكروت الاختيارية" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  تمكّن المجموعة من تخصيص عمق الجولة التكتيكي عبر تفعيل أو تعطيل الأدوار الاختيارية الثلاثة (`ولد الصالحين`، `القناص`، `مافيا عادي`) مع حماية رياضية تمنع تفعيل أدوار تتجاوز عدد المقاعد المتاحة للمواطنين.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **مفتاح `ولد الصالحين` (`Switch`)** | يفعّل أو يعطّل إضافة بطاقة `ولد الصالحين` (`يسحب لاعباً معه`) إلى مجموعة اللعب. |
| **مفتاح `القناص` (`Switch`)** | يفعّل أو يعطّل إضافة بطاقة `القناص` (`يطلق على المافيا ليلاً`) إلى مجموعة اللعب. |
| **مفتاح `مافيا عادي` (`Switch`)** | يفعّل أو يعطّل إضافة عضو مافيا ثالث (`مافيا عادي — يتآمر مع فريقه`) لزيادة صعوبة الجولة في المجموعات الكبيرة. |
| **شريط `المواطنون العاديون: X`** | شريط سفلي ثابت يحسب لحظياً عدد بطاقات `مواطن صالح` التي ستملأ المقاعد المتبقية (`المجموع: N بطاقات`). |
| **زر `توزيع البطاقات`** | يبني مجموعة البطاقات ويخلطها عشوائياً بخوارزمية `Fisher-Yates` عبر `Random.secure()` وينتقل إلى شاشة شبكة البطاقات (`PlayGridScreen`). |

---

### 5. شاشة شبكة البطاقات وبدء السحب التسلسلي (`PlayGridScreen`)

<p align="center">
  <img src="assets/images/appScreen/توزيع%20البطافات%20وبدا%20اللاعبين%20الاختيار.jpeg" alt="توزيع البطاقات وبدء اللاعبين الاختيار" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  تعرض البطاقات مقلوبة بنسبة أبعاد `2:3` حقيقية بدون أرقام فوق البطاقات، مما يمنح كل لاعب حرية اختيار أي بطاقة يريدها من الشبكة، بينما يتتبع النظام رقم اللاعب الحالي (`دور اللاعب رقم 1..N`) في الشريط العلوي ويربط البطاقة التي يختارها برقمه تلقائياً. الشاشة محمية بـ `PopScope` لمنع الخروج العشوائي أثناء التوزيع.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **زر الرجوع (`>`)** | يفتح نافذة تأكيد (`إنهاء الجولة؟`) لحماية التوزيع الجاري من الضياع عند الضغط بالخطأ على زر الرجوع. |
| **زر `إعادة خلط`** | يفتح نافذة تأكيد (`إعادة خلط البطاقات؟`) لإلغاء التوزيع الحالي وإعادة خلط جميع البطاقات عشوائياً من اللاعب رقم `1` بنفس الإعدادات. |
| **شريط `دور اللاعب رقم #X`** | يوضح رقم اللاعب الذي يحمل الهاتف حالياً (`#1 دور اللاعب رقم 1`) ويذكّره بحفظ رقمه قبل سحب البطاقة. |
| **البطاقات المقلوبة في الشبكة** | عند الضغط على أي بطاقة مقلوبة، تنقلب البطاقة بحركة ثلاثية الأبعاد (`3D Flip`) وتفتح في نافذة عرض مركزية كبيرة مع قفل باقي البطاقات فوراً. |

---

### 6. نافذة كشف الدور ثلاثية الأبعاد للاعب (`3D Spotlight Role Reveal`)

<p align="center">
  <img src="assets/images/appScreen/مثال%20عند%20الضغغط%20على%20كرت%20وعرض%20الدور%20للاعب.jpeg" alt="مثال عند الضغط على كرت وعرض الدور للاعب" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  تعرض البطاقة التي سحبها اللاعب في نافذة مركزية كبيرة فوق خلفية ضبابية معتمة (`BackdropFilter`) بنسبة أبعاد `2:3` كاملة بدون أي قص (`BoxFit.contain`)، بحيث يقرأ اللاعب اسم دوره، وفريقه، والوصف التفصيلي لقدرته في أسفل البطاقة بوضوح تام. أثناء فتح هذه النافذة، تكون جميع البطاقات الأخرى مقفلة تماماً لمنع الغش.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **شريط معلومات البطاقة العلوي** | يعرض رقم اللاعب الحالي (`اللاعب رقم #2`) وشارة الفريق (`م ♠ المافيا` أو `مـ ♦ المواطنون`). |
| **زر `فهمت — اضغط للإخفاء` (أو الضغط على البطاقة)** | يخفي البطاقة فوراً، ويسجل الدور باسم اللاعب الحالي في السجل السري (`playerRoles[X]`)، ويحول موقع البطاقة في الشبكة إلى حالة مقفلة (`تم السحب`)، ويُظهر شاشة التمرير السرية للاعب التالي. |

---

### 7. شاشة درع الخصوصية وتمرير الهاتف (`Pass-the-Phone Privacy Shield`)

<p align="center">
  <img src="assets/images/appScreen/مرحله%20ما%20بعد%20اختيار%20البطاقه.jpeg" alt="مرحلة ما بعد اختيار البطاقة" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  درع حماية بصري معتم بالكامل يظهر تلقائياً بين كل لاعب واللاعب الذي يليه؛ يمنع أي شخص من رؤية الشبكة أو البطاقات أثناء تمرير الهاتف باليد حول الطاولة، ويضمن أن اللاعب التالي فقط هو من يفتح الشاشة لسحب بطاقته.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **شارة `دور اللاعب رقم X`** | تنبه المجموعة إلى رقم اللاعب الذي يجب أن يستلم الهاتف الآن (`مرر الهاتف للاعب رقم 3 لفتح بطاقة عشوائية`). |
| **زر `أنا اللاعب رقم X - متابعة`** | يزيل درع الحجب ويفتح شبكة البطاقات المتبقية للاعب الجديد ليختار بطاقته السرية. |

---

### 8. شاشة استعداد الليدر الآلي بعد اكتمال التوزيع (`NightModeratorScreen — Standby`)

<p align="center">
  <img src="assets/images/appScreen/شاشه%20الانتهاء%20من%20توزيع%20الادوار.jpeg" alt="شاشة الانتهاء من توزيع الأدوار" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  تظهر تلقائياً فور قيام اللاعب الأخير بسحب وإخفاء بطاقته (`NightOnePhase.standby`). بدلاً من تشغيل الصوت فجأة والهاتف لا يزال في يد اللاعب الأخير، تدخل الشاشة في وضع **"الاستعداد"** الهادئ حتى يضع اللاعبون الهاتف في منتصف الطاولة ويكون الجميع مستعداً لبدء الليلة الأولى.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **زر `بدء الليلة الأولى` (`▶`)** | الزر القرمزي الرئيسي؛ يبدأ التسلسل الصوتي والزمني لليدر الآلي (`startNightSequence()`) انطلاقاً من المرحلة الأولى (`سبات المدينة — 15 ثانية`). |
| **زر `تخطي والانتقال لخزنة التحقق` (`⏭`)** | يتجاوز الليدر الصوتي لليلة الأولى بالكامل وينتقل مباشرة إلى شاشة خزنة التحقق من الهوية (`VerificationVaultScreen`). |
| **زر `إعادة خلط`** | يتيح إعادة خلط البطاقات وتوزيعها من جديد في حال رغبت المجموعة بإلغاء التوزيع قبل بدء الليلة. |

---

### 9. شاشة الليدر الصوتي والبصري الآلي لليلة الأولى (`NightModeratorScreen — Active`)

<p align="center">
  <img src="assets/images/appScreen/ليدر%20صوتي%20للمرحله%20الاولى.jpeg" alt="ليدر صوتي للمرحلة الأولى" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  تدير الليلة التمهيدية الأولى آلياً بالكامل عبر نداءات صوتية عربية مسجلة (`assets/audio/*.mp3`) ومؤقت تنازلي دقيق، حتى لا يضطر أي لاعب للقيام بدور الراوي (الليدر) وخسارة فرصته في اللعب. تمر الشاشة بـ 4 مراحل متتالية:
  1. **سبات المدينة (`15 ثانية`):** `"المدينة تغفو الآن... على الجميع إغماض أعينهم بالكامل"`
  2. **استيقاظ المافيا (`12 ثانية`):** `"فريق المافيا فقط... افتحوا أعينكم الآن وتعرفوا على بعضكم بصمت"` (مع توهج قرمزي نابض)
  3. **عودة المافيا للسبات (`5 ثوانٍ`):** `"انتهى الوقت... فريق المافيا، أغمضوا أعينكم الآن"`
  4. **شروق الصباح (`3 ثوانٍ`):** `"أشرق الصباح... على الجميع فتح أعينهم الآن. ابدأوا النقاش!"` ثم الانتقال التلقائي لخزنة التحقق.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **حلقة العد التنازلي المركزية** | تعرض عدد الثواني المتبقية في المرحلة الحالية مع شريط تقدم دائري وخطي علوي. |
| **زر `إعادة الصوت` (`🔊`)** | يعيد تشغيل النداء الصوتي للمرحلة الحالية فوراً (`replayCurrentPhaseAudio()`) مع إيقاف أي صوت سابق لمنع تداخل الأصوات. |
| **زر `إعادة من البداية` (`↻`)** | يوقف المؤقت والصوت الحالي ويعيد الليدر الآلي إلى شاشة الاستعداد (`NightOnePhase.standby`) لبدء الليلة الأولى من جديد (`restartNightModerator()`). |
| **زر `تخطي` (`⏭`)** | يوقف الصوت والمؤقت فوراً وينقل الطاولة مباشرة إلى شاشة خزنة التحقق من الهوية (`skipNightModerator()`). |

---

### 10. شاشة خزنة التحقق من الهوية وميزان القوى أثناء الجولة (`VerificationVaultScreen`)

<p align="center">
  <img src="assets/images/appScreen/حالة%20ما%20اثناء%20الجولة.jpeg" alt="حالة ما أثناء الجولة — خزنة التحقق من الهوية" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  المرافق التكتيكي للطاولة طوال مراحل النقاش والتصويت النهارية. تحافظ على سرية أدوار اللاعبين الأحياء، بينما تتيح للطاولة التحقق من البطاقة الحقيقية لأي لاعب يتم طرده بالتصويت عبر إدخال رقمه (`1..N`)، وتحدّث ميزان القوى الحي (`المافيا الأحياء` مقابل `الصالحون الأحياء`) تلقائياً وتعلن الفائز فور تحقق شرط الفوز.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **شريط ميزان القوى الحي (`المافيا الأحياء` / `الصالحون الأحياء`)** | يعرض عدد اللاعبين الأحياء في كل فريق لحظياً، ويتحدث تلقائياً عند كشف هوية أي لاعب مطرود. |
| **حقل `# أدخل رقم اللاعب المطرود (1 - N)`** | حقل إدخال رقمي للبحث برقم اللاعب الذي قررت الطاولة طرده. |
| **زر `كشف هوية اللاعب` (`👁`)** | يتحقق من صحة الرقم المدخل ويفتح نافذة تأكيد كشف الهوية. |
| **قسم `سجل اللاعبين المطرودين`** | يحتفظ بشارات (`Chips`) لجميع اللاعبين الذين تم طردهم مع أدوارهم؛ والضغط على أي شارة يعيد فتح بطاقة اللاعب الكاملة. |
| **زر `إعادة الليدر الآلي`** | يعيد فتح شاشة الليدر الصوتي لليلة الأولى في حال أرادت الطاولة إعادة تشغيل النداءات الصوتية. |
| **زر `كشف جميع الأدوار (نهاية الجولة)`** | يفتح نافذة تأكيد لعرض السجل الكامل لجميع اللاعبين وأدوارهم السرية عند انتهاء الجولة. |
| **زر `جولة جديدة (إعادة خلط فورية)` (`↻`)** | يخلط البطاقات فوراً بنفس إعدادات الجولة الحالية (`startInstantRematch()`) ويعيد التوزيع من اللاعب رقم `1` بضغطة واحدة. |
| **زر `تعديل الإعدادات`** | ينهي الجولة الحالية ويعود إلى شاشة `SetupScreen` لتغيير عدد اللاعبين أو الأدوار الاختيارية. |
| **زر `القائمة الرئيسية`** | يعود مباشرة إلى شاشة الترحيب الرئيسية (`HomeScreen`). |

---

### 11. نافذة تأكيد كشف هوية اللاعب المطرود (`Verify Player Confirmation Dialog`)

<p align="center">
  <img src="assets/images/appScreen/اختيار%20رقم%20لاعب%20لتتحق%20من%20كرته.jpeg" alt="اختيار رقم لاعب للتحقق من كرته" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  خط دفاع وقائي يمنع كشف دور لاعب بالخطأ عند كتابة رقم غير مقصود في حقل البحث؛ يطلب تأكيداً صريحاً قبل كشف البطاقة السرية أمام الطاولة وخصم اللاعب من عداد الأحياء.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **زر `كشف الهوية`** | يؤكد طرد اللاعب المحدد، ويسجله في قائمة المطرودين، ويحدّث عداد الأحياء وفحص شروط الفوز، ثم يفتح بطاقته الكاملة. |
| **زر `تراجع`** | يلغي العملية ويغلق النافذة دون كشف أو تغيير حالة اللاعب. |

---

### 12. نافذة عرض بطاقة اللاعب المطرود (`Eliminated Player Role Card Modal`)

<p align="center">
  <img src="assets/images/appScreen/كشف%20كرت%20لاعب%20بناء%20على%20الرقم.jpeg" alt="كشف كرت لاعب بناء على الرقم" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  تحسم النقاش على الطاولة وتمنع أي لاعب مطرود من إخفاء هويته أو الادعاء بدور آخر؛ حيث تعرض بطاقته الأصلية الكاملة بنسبة `2:3` مع رقم اللاعب وشارة فريقه (`المواطنون` أو `المافيا`).

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **شارات الرأس (`بطاقة اللاعب رقم X` وشارة الفريق)** | توضح رقم اللاعب المطرود والفريق الذي كان يلعب لصالحه. |
| **زر `إغلاق البطاقة` (`✓`)** | يغلق نافذة البطاقة ويعود إلى شاشة خزنة التحقق من الهوية مع ظهور اللاعب في سجل المطرودين وتحديث ميزان القوى. |

---

### 13. نافذة سجل أدوار الجولة الكامل (`End-of-Game Full Roles Roster`)

<p align="center">
  <img src="assets/images/appScreen/سجل%20الادوار.jpeg" alt="سجل الأدوار الكامل" width="280" />
</p>

- **وظيفة الشاشة (Screen Purpose):**
  تُستخدم في نهاية الجولة لكشف جميع الأوراق على الطاولة؛ حيث تعرض قائمة مرتبة بجميع اللاعبين من `اللاعب رقم 1` إلى `اللاعب رقم N` مع دور كل لاعب، وفريقه، وحالته (`مطرود` أو حي)، مما يتيح للمجموعة مراجعة مجريات الجولة وبدء جولة جديدة فوراً.

- **شرح الأزرار والعناصر التفاعلية (Buttons & Interactive Controls):**

| العنصر / الزر | الوظيفة والإجراء عند الضغط |
| :--- | :--- |
| **زر الإغلاق (`✕`)** | يغلق نافذة السجل الكامل ويعود إلى شاشة خزنة التحقق من الهوية. |
| **صفوف اللاعبين (`اللاعب رقم 1..N`)** | تعرض رقم اللاعب، وحالته (`مطرود` إن تم إقصاؤه)، ووصف قدرته، وشارة دوره الملونة حسب فريقه. |
| **زر `جولة جديدة (إعادة خلط فورية)` (`↻`)** | يغلق النافذة ويعيد خلط البطاقات فوراً بنفس عدد اللاعبين والأدوار المختارة لبدء جولة جديدة مباشرة من اللاعب رقم `1`. |

---

## 4. Architecture, Performance & Tech Stack | البنية المعمارية والأداء

### Clean Architecture Layer Isolation
- **`domain/` Layer (100% Pure Dart):** `GameRole`, `PlayableCard`, `NightOnePhase`, and `RoleShuffler` have zero imports from `package:flutter`, `shared_preferences`, `audioplayers`, or `presentation/`.
- **`data/` Layer:** `GameSettingsStorage` encapsulates all `SharedPreferences` keys and persistence logic with serialized FIFO writes.
- **`presentation/` Layer:** `GameCubit` and `NightModeratorCubit` manage all state transitions, timers, haptics, and audio playback. Screens use granular `BlocSelector` and `buildWhen` predicates, `RepaintBoundary` layers around 3D card flips and pulsing auras, once-per-lifecycle `GameAssetPrecacher`, and bounded image `cacheWidth` decoding.
- **Lean Asset Bundling:** Documentation screenshots inside `assets/images/appScreen/` are excluded from `pubspec.yaml` asset bundling so only production role artworks and voiceover audio tracks are packaged into the release APK/AAB.

### Technical Stack
- **Framework:** Flutter (`SDK ^3.6.1`, Material 3, Portrait-locked, Arabic RTL)
- **State Management:** `flutter_bloc` (`GameCubit`, `NightModeratorCubit`)
- **Audio & Local Persistence:** `audioplayers` (offline asset voiceovers), `shared_preferences`
- **Typography & Branding:** `google_fonts` (`IBM Plex Sans Arabic`, `FontStyle.normal`, `FontFeature.liningFigures()`), `flutter_launcher_icons`, `flutter_native_splash` (Android 12+ safe-zone padded `#0D0D0D`)

---

## 5. Folder Structure | هيكل المجلدات

```text
MafiaApp/
├── android/
│   └── app/
│       ├── build.gradle                  # R8 minifyEnabled & shrinkResources release config
│       ├── proguard-rules.pro            # Release ProGuard rules
│       └── src/main/AndroidManifest.xml  # Arabic app label ("مافيا") & portrait orientation lock
├── assets/
│   ├── audio/                            # Clean ASCII Arabic voiceovers (night_sleep, mafia_wake, mafia_sleep, city_wake)
│   └── images/                           # 2:3 Role card artworks, card back, and splash logos
│       └── appScreen/                    # Documentation screenshots for README (not bundled in release binary)
├── lib/
│   ├── main.dart                         # Entry point, FlutterNativeSplash, portrait lock, RTL builder & BlocProvider
│   ├── core/
│   │   └── theme/
│   │       ├── app_colors.dart           # Obsidian Syndicate palette & SyndicateColorsExtension
│   │       ├── app_dimensions.dart       # 8pt spatial rhythm, corner radii & flat planar tiers
│   │       ├── app_theme.dart            # Single unified Material 3 dark ThemeData
│   │       └── app_typography.dart       # IBM Plex Sans Arabic typography scale
│   └── features/
│       └── game/
│           ├── data/
│           │   └── game_settings_storage.dart       # SharedPreferences persistence service
│           ├── domain/
│           │   ├── entities/
│           │   │   ├── game_role.dart               # Pure-Dart GameRole, RoleTeam & GameAssets constants
│           │   │   ├── night_one_phase.dart         # Pure-Dart NightOnePhase enum (standby -> completed)
│           │   │   └── playable_card.dart           # Pure-Dart PlayableCard entity with value equality
│           │   └── services/
│           │       └── role_shuffler.dart           # Cryptographic Fisher-Yates RoleShuffler
│           └── presentation/
│               ├── cubit/
│               │   ├── game_cubit.dart              # Setup, sequential dealing, vault & instant rematch logic
│               │   ├── game_state.dart              # Immutable GameState with live faction balance & win detection
│               │   ├── night_moderator_cubit.dart   # Standby + 4-phase Night-1 audio & timer state machine
│               │   └── night_moderator_state.dart   # Immutable NightModeratorState
│               ├── pages/
│               │   ├── home_screen.dart             # Noir landing screen & Role Guide trigger
│               │   ├── setup_screen.dart            # Granular BlocSelector setup dashboard (6-18 players)
│               │   ├── play_grid_screen.dart        # Per-cell BlocSelector 2:3 card grid & 3D spotlight modal
│               │   ├── night_moderator_screen.dart  # Standby trigger & isolated 1s countdown Night-1 moderator
│               │   └── verification_vault_screen.dart # Live faction balance bar, player lookup & instant rematch
│               ├── utils/
│               │   └── game_asset_precacher.dart    # Once-per-lifecycle Flutter ImageCache preloader
│               └── widgets/
│                   ├── flip_card_widget.dart        # RepaintBoundary 3D Matrix4.rotationY 2:3 card widget
│                   └── role_guide_sheet.dart        # Modal bottom sheet showcasing all 8 roles
├── test/
│   ├── widget_test.dart                             # RTL & navigation widget smoke test
│   └── features/game/
│       ├── domain/
│       │   └── role_shuffler_test.dart              # Deck size, mandatory roles & cryptographic variance tests
│       └── presentation/cubit/
│           ├── game_cubit_test.dart                 # Anti-cheat locking, sequential binding, win detection & storage tests
│           └── night_moderator_cubit_test.dart      # Standby initialization, 4-phase audio/timer, replay, restart & skip tests
├── PRIVACY_POLICY.md                                # 100% Offline Google Play Store privacy policy
└── pubspec.yaml                                     # Dependencies, assets, launcher icons & native splash
```

---

## 6. Getting Started & Build Commands | التشغيل والبناء

### 1. Install Dependencies & Generate Native Branding
```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

### 2. Run Static Analysis & Automated Tests
```bash
flutter analyze
flutter test
```

### 3. Build Production Release APK & AppBundle
```bash
# Build shrink-optimized release APK (or split-per-abi)
flutter build apk --release
flutter build apk --release --split-per-abi

# Build Google Play Store release AppBundle (.aab)
flutter build appbundle --release
```

---

## 7. Privacy Policy | الخصوصية

This application operates **100% offline**, collects zero personal data, and requires no internet permissions or user accounts. See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for full details.
