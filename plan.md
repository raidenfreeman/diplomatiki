# Πλάνο Διπλωματικής Εργασίας: Πάγκος Εργασίας Εκπομπών Maersk

## Στόχοι του πλάνου

- **Στόχος μεγέθους:** 80-100 σελίδες A4, 12pt, mainfont Arial (ορίζεται ήδη στο `gkinis_konstantinos.md`)
- **Αναλογία περιεχομένου:** ~10% κώδικας/listings (περίπου 8-10 σελίδες), ~10-15% εικόνες/διαγράμματα, ~75-80% κείμενο (θεωρία/περιγραφή σε ίσες αναλογίες)
- **Γλώσσα:** Ελληνικά
- **Ύφος:** Διπλωματική Master, αντικειμενικό, τεκμηριωμένο, με τεχνική ακρίβεια. Διατηρείται το ύφος του υπάρχοντος κειμένου: σαφή θεωρητικά εισαγωγικά πριν τα τεχνικά, κάθε επιλογή τεχνολογίας/μεθόδου τεκμηριωμένη με αιτιολόγηση.
- **Συγγραφή:** Παράλληλα 3 sonnet sub-agents τη φορά, ένας ανά κεφάλαιο. Ένας commit ανά υποκεφάλαιο.

## Πηγές πληροφορίας

- `presentations/ETPlatformTechMeet2025.pdf` — επίσημη παρουσίαση πυλώνων
- `presentations/Nix Workshop.md` — εσωτερικό workshop για Nix
- `nrg/README.md` — επισκόπηση μονο-αποθετηρίου
- `nrg/guides/` — εσωτερική τεκμηρίωση (clean architecture, code style, observability, security, dremio, etw, people-operations)
- `nrg/components/emissions_workbench/` — κύρια εφαρμογή
- `nrg/components/bunker/` — BOPS / BoW
- `nrg/components/ocean/` — vessel master data + EU ETS
- `nrg/components/eco_products/` — placeholder, πραγματικός κώδικας στο emissions_workbench
- `nrg/components/net_zero/` — placeholder
- `nrg/alerts/` — observability alerts as code
- `nrg/flake.nix`, `nrg/team.json` — υποδομή/ομάδα
- Υπάρχον κείμενο στο `gkinis_konstantinos.md` (~46KB) — ενσωματώνεται και επεκτείνεται

## Επιβεβαιωμένα μετρικά για χρήση στο κείμενο

Όλα τα παρακάτω αντλήθηκαν από τον κώδικα ή τα guides και πρέπει να χρησιμοποιηθούν στα αντίστοιχα κεφάλαια:

- **Κώδικας:** 6.033 αρχεία `.ex`/`.exs`, 786 test files, 93.431 LOC στα core components
- **Components (LOC):** emissions_workbench 67.877 / bunker/bow 16.738 / bunker/api 8.816
- **Patterns:** 14+ LiveView modules (και πολλά LiveComponents σε 4 namespace: Eco Delivery, Energy Bank, Emissions Data Inventory, Admin) · 31 Oban workers · 294 Ecto schemas · 112 GenServers · 9 αρχεία Kafka integration με `:brod`
- **Database:** 151 ξεχωριστοί πίνακες, 720+ migrations (499 emissions_workbench, 218 bunker/bow, 4 bunker/api)
- **Infrastructure:** 57 Terraform `.tf` αρχεία · 20 GitHub workflows · 4 alert configurations (13+ alert rules στο `alerts/metrics/alerts.yaml`)
- **Ομάδα:** 28 μέλη (17 Ευρώπη, 11 Ινδία) — distributed development
- **Παραγωγική χρήση από:** Σεπτέμβριος 2023
- **Έναρξη ανάπτυξης:** Μάρτιος 2023
- **Επιχειρησιακά (από PDF):** 1300+ χρήστες (από 1000+ pre-launch) · 98K FFE / $31M USD ECO Delivery 2024 · ~32 deploys/ημέρα · αντιμετώπιση 2023 GIA audit · αυτόματη παραγωγή πιστοποιητικών για ECOv1 και ECOv2

## Υπάρχουσες εικόνες προς ενσωμάτωση

- `Carbon_Accounting_Scopes.png` (Κεφ. 3.2)
- `Extreme_Programming_Loops.png` (Κεφ. 10.6)
- `system_overview_diagram.png` (Κεφ. 9.1)
- Screenshots από `presentations/` (πιθανώς UI shots για κεφ. 4-6)

## Cross-cutting style guide (για όλους τους sub-agents)

1. **Ορολογία**: Πρώτη εμφάνιση όρου σε ελληνικά με αγγλικό σε παρένθεση. Πχ "πλατφόρμα ως υπηρεσία (PaaS)". Αν δεν υπάρχει σαφής ελληνική απόδοση, χρήση αγγλικού όρου σε italics.
2. **Αναφορές σε κώδικα**: Inline `monospace` για ονόματα modules/συναρτήσεων. Code listings σε fenced code blocks με γλώσσα (πχ ```` ```elixir ```` ).
3. **Λίστες αρχείων**: Αν αναφέρεται πλήθος αρχείων, χρήση πραγματικών αριθμών (από επιβεβαιωμένα μετρικά).
4. **Αιτιολόγηση επιλογών**: Κάθε σχεδιαστική απόφαση (πχ "επιλέχθηκε Elixir") πρέπει να συνοδεύεται από εξήγηση του γιατί, με αναφορά στις απαιτήσεις του προβλήματος.
5. **Cross-references**: Όταν αναφέρεται έννοια που αναπτύσσεται αλλού, χρήση "βλ. Κεφ. X" ή "(Κεφ. X)".
6. **Μη θαμπώνουμε με κώδικα**: Listings μόνο όπου είναι απαραίτητα για κατανόηση. Πάντα συνοδεύονται από 1-2 παραγράφους εξήγησης.
7. **Πορεία διάρθρωσης**: Σύντομη εισαγωγή → ανάπτυξη → σύνδεση με επόμενο.
8. **Για επεκτάσεις υπάρχοντος κειμένου**: Διατηρήστε φράσεις/παραγράφους που είναι ήδη καλά γραμμένες· επεκτείνετε με βάθος, μην αναγράφετε περιττά.

## Δομή κεφαλαίων και κατανομή σελίδων

| # | Κεφάλαιο | Σελίδες |
|---|----------|---------|
| 1 | Εισαγωγή | 3-4 |
| 2 | Πλαίσιο και πρόβλημα | 8-9 |
| 3 | Θεωρητικό υπόβαθρο: Λογιστική αερίων θερμοκηπίου | 8-10 |
| 4 | Ο Πάγκος Εργασίας Εκπομπών: Επισκόπηση | 4-5 |
| 5 | Πυλώνας Α: Ocean Emissions και STAR Connect | 9-11 |
| 6 | Πυλώνας Β: ECO Product Delivery και πιστοποιητικά | 9-10 |
| 7 | Πυλώνας Γ: Bunker Optimization | 7-8 |
| 8 | Τεχνολογίες | 11-13 |
| 9 | Αρχιτεκτονική του συστήματος | 12-14 |
| 10 | Εργασιακές μέθοδοι | 9-11 |
| 11 | Συμπεράσματα | 3 |
| 12 | Μελλοντική εργασία | 2 |
| 13 | Βιβλιογραφία | 2-3 |

**Σύνολο: 87-104 σελίδες**

---

# ΑΝΑΛΥΤΙΚΟ BRIEF ΑΝΑ ΚΕΦΑΛΑΙΟ

> Κάθε κεφάλαιο παρακάτω περιλαμβάνει: **Δομή** (παράγραφοι/βασικά σημεία), **Πηγές** (συγκεκριμένα paths), **Code listings** (παραθέματα από repo), **Στοιχεία** (νούμερα/citations), **Όχι εδώ** (τι αποφεύγουμε για να μην επικαλυφθεί), **Cross-refs**.

## Κεφ. 1 — Εισαγωγή (3-4 σελίδες)

### 1.1 Πλαίσιο της εργασίας

**Δομή:**
- Παρ. 1: Maersk ως one of the largest container shipping companies (700+ vessels), 130+ countries.
- Παρ. 2: Συνεισφορά της θαλάσσιας μεταφοράς στις παγκόσμιες εκπομπές (≈3% global CO₂, IMO 2023 GHG strategy).
- Παρ. 3: Ρυθμιστική πίεση (CSRD, EU ETS Maritime από 1/1/2024, Fuels EU Maritime από 1/1/2025) — σύντομη αναφορά, λεπτομέρειες στο Κεφ. 2.

### 1.2 Στόχος της εργασίας

**Δομή:**
- Τι παρουσιάζεται: NRG / Emissions Workbench της ομάδας ET Platform.
- Τι αναλύεται: τεχνολογικές αποφάσεις, αρχιτεκτονική, μεθοδολογία ανάπτυξης.
- Τι δεν καλύπτεται: εμπορικά/συμβασιακά θέματα Maersk, λεπτομέρειες προσωπικών δεδομένων.

### 1.3 Συνεισφορές της εργασίας

**Δομή:** Σύντομη λίστα (5-7 bullets):
- Τεκμηριωμένη παρουσίαση των τεσσάρων πυλώνων του ET Platform
- Αρχιτεκτονική event-driven με BEAM σε εμπορικό περιβάλλον
- Σύζευξη βιβλιογραφικού πλαισίου (GHG Protocol, ISCC, GLEC) με τεχνική υλοποίηση
- Επίδραση των πρακτικών XP σε production team της Maersk
- Επιχειρησιακά αποτελέσματα ($31M USD, 1300+ users)

### 1.4 Δομή του κειμένου

Σύντομη επισκόπηση κάθε κεφαλαίου σε 1-2 προτάσεις.

**Πηγές:** PDF intro slides, υπάρχον κείμενο στο `gkinis_konstantinos.md`.

**Όχι εδώ:** Λεπτομέρειες αρχιτεκτονικής (Κεφ. 9), τεχνολογιών (Κεφ. 8), μεθόδων (Κεφ. 10).

---

## Κεφ. 2 — Πλαίσιο και πρόβλημα (8-9 σελίδες)

> Επεκτείνει σημαντικά το υπάρχον "Η ανάγκη δημιουργίας του Πάγκου Εργασίας Εκπομπών".

### 2.1 Η Maersk και ο τομέας της θαλάσσιας μεταφοράς (1.5 σελ)

**Δομή:**
- Σύντομο profile εταιρείας: ίδρυση 1904, A.P. Møller-Mærsk, διεθνής παρουσία.
- Δραστηριότητες: Ocean (containers), Logistics & Services, Terminals, Towage.
- Μέγεθος στόλου, transit volumes (αν υπάρχουν δημόσια στοιχεία).
- Μετάβαση από καθαρά shipping company σε integrated logistics provider.

### 2.2 Συνεισφορά της ναυτιλίας στις εκπομπές (1 σελ)

**Δομή:**
- Παγκόσμιες εκπομπές: ≈3% global CO₂ (IMO 4th GHG Study).
- Ποιοτικές πληροφορίες: HFO/VLSFO ως κυρίαρχα καύσιμα, sulfur emissions, NOₓ, particulate matter.
- Δυσκολία απανθρακοποίησης: long-lived assets (vessels 25-30 χρόνια), high energy density requirements.

### 2.3 Ο στόχος Net Zero 2040 της Maersk (1 σελ)

**Δομή:**
- Στόχος: καθαρές μηδενικές εκπομπές μέχρι το 2040 — 10 χρόνια πριν τον στόχο IMO 2050.
- 30% sustainable energy usage μέχρι το 2030 (από PDF).
- Επενδύσεις σε εναλλακτικά καύσιμα: methanol-ready vessels, ammonia, biodiesel.
- Σχέσεις με ABS, Lloyd's για verifications.

### 2.4 Ρυθμιστικό πλαίσιο (1.5 σελ)

**Δομή:**
- **CSRD (Corporate Sustainability Reporting Directive)**: ισχύει από οικονομικά έτη 2024 (large public-interest entities).
- **EU ETS Maritime**: επέκταση Emissions Trading System σε ναυτιλία από 1/1/2024 (40% του CO₂ το 2024, 70% το 2025, 100% από 2026).
- **Fuels EU Maritime**: ποιοτικοί στόχοι GHG intensity καυσίμων (από 2025, σταδιακή μείωση intensity).
- **IMO MEPC**: 2023 strategy για 20-30% emission reduction by 2030, net-zero by 2050.
- **CDP, GRESB**: voluntary disclosure frameworks.

### 2.5 Η προηγούμενη χειρωνακτική διαδικασία (1.5 σελ)

> Επέκταση υπάρχουσας περιγραφής στο `gkinis_konstantinos.md`.

**Δομή:** Το PDF δείχνει 5 βήματα (slide 9):
- Email request στην Emissions Reporting Team
- Manual extract shipment data
- Manual application of emissions factors
- Report construction (Excel)
- Email return to requester

Επεκτείνεται με:
- Γιατί ήταν ακατάλληλο: data freshness (weeks), normalization errors, no audit trail, μη επαναληψιμότητα, χαμένα δεδομένα, μη scalable.
- Παράδειγμα τυπικής διαδικασίας (timeline 3-8 εβδομάδες ανά request).

### 2.6 Ομάδες χρηστών (1 σελ)

**Δομή:** Πίνακας με 6 user groups (από PDF slide 10):
- ECO Delivery Ocean Products
- Regional Product Management
- Commercial Sustainability
- Regional Sales
- Contract Management
- Account Managers

Για κάθε ομάδα: τι δεδομένα ζητούν, σε ποιά συχνότητα, σε ποιά μορφή.

### 2.7 Ο εσωτερικός έλεγχος GIA του 2023 (0.5 σελ)

**Δομή:**
- Group Internal Audit της Maersk → εντοπισμός ζητημάτων (αναφέρεται στο PDF: "Addressed the concerns raised in the 2023 internal GIA audit").
- Ζητήματα: data tracking, audit trail, scalability, error rates.
- Αυτό ήταν catalyst για ταχεία ανάπτυξη.

**Πηγές:** PDF slides 8-12, web search για CSRD/EU ETS/Fuels EU Maritime, υπάρχον κείμενο.

**Στοιχεία:** 1000+ users pre-launch, 1300+ τώρα, $31M USD το 2024 (από PDF — να αναφερθεί ως "indicative impact" εδώ).

**Code listings:** Καμία (περιγραφικό κεφάλαιο).

**Όχι εδώ:** Τεχνική περιγραφή της λύσης (Κεφ. 4-9), μεθοδολογία υπολογισμού (Κεφ. 3), εμπορικά αποτελέσματα μετρήσεων (Κεφ. 4).

**Cross-refs:** Κεφ. 3 (μεθοδολογία), Κεφ. 4 (επισκόπηση λύσης).

---

## Κεφ. 3 — Θεωρητικό υπόβαθρο: Λογιστική αερίων θερμοκηπίου (8-10 σελίδες)

> Επεκτείνει το υπάρχον "Μέτρηση εκπομπών CO₂".

### 3.1 Το πρωτόκολλο GHG (1.5 σελ)

**Δομή:**
- Ιστορικό: 1997 Kyoto Protocol — 6 βασικά αέρια (CO₂, CH₄, N₂O, HFCs, PFCs, SF₆· από 2012 +NF₃).
- 2001: GHG Protocol Corporate Standard (WBCSD + WRI).
- Σχέσεις με ISO 14064, EN 16258 (transport).
- Έννοια του CO₂ equivalent (CO₂e) και Global Warming Potential (GWP).

### 3.2 Κατηγορίες εκπομπών (Scopes) (1.5 σελ)

> Επέκταση υπάρχοντος.

**Δομή:**
- Scope 1: Direct emissions (Maersk: ίδιος στόλος, σταθερές εγκαταστάσεις).
- Scope 2: Indirect από αγορά ενέργειας (electricity, heat, steam, cooling). Σε Maersk: γραφεία, terminals.
- Scope 3: Upstream + downstream value chain (15 categories — αναφορά συγκεκριμένα στις πιο σχετικές για ναυτιλία: 1. Purchased goods/services, 4. Upstream transportation, 11. Use of sold products).
- Στη Maersk: chartered vessels → Scope 3 cat. 4 ή 7.
- Εικόνα `Carbon_Accounting_Scopes.png` με συνοδευτική περιγραφή.

### 3.3 Μεθοδολογίες μέτρησης (2 σελ)

**Δομή — 3 υποενότητες:**

**3.3.1 Cost-based**
- Δαπάνη × emission factor (πχ EEIO factors).
- Πλεονεκτήματα: απλό, default fallback.
- Μειονεκτήματα: χαμηλή ακρίβεια, εξάρτηση από τιμές.

**3.3.2 Activity-based**
- Πραγματικές δραστηριότητες × specific emission factor.
- Παραδείγματα: tonne-km × g CO₂/tonne-km, fuel consumed × emission factor per liter.
- Πλεονεκτήματα: ακρίβεια, επαληθευσιμότητα.
- Μειονεκτήματα: data collection complexity.

**3.3.3 Hybrid (επιλογή Maersk)**
- Activity-based όπου διαθέσιμα δεδομένα, cost-based για κενά.
- GHGP recommendation για scope 3.
- Πώς εφαρμόζεται στο NRG (preview, λεπτομέρειες Κεφ. 5).

### 3.4 TTW vs WTW (1 σελ)

**Δομή:**
- **Tank-to-Wheel (TTW)**: combustion-only, εκπομπές κατά την καύση καυσίμου.
- **Well-to-Wheel (WTW)** ή Well-to-Wake: WTT (well-to-tank: production+transport) + TTW.
- Σημαντικότητα WTW για σωστή σύγκριση εναλλακτικών καυσίμων (πχ blue/green hydrogen TTW=0 αλλά WTT μπορεί να είναι σημαντικό).
- Ευρωπαϊκή μετάβαση από TTW σε WTW.

### 3.5 Mass Balance και Book-and-Claim (1.5 σελ)

**Δομή:**
- **Φυσική ροή vs λογιστική ροή**: στη ναυτιλία, ένα συγκεκριμένο πλοίο μπορεί να μην έχει διαθέσιμο εναλλακτικό καύσιμο.
- **Mass Balance**: ισοζύγιο εισόδων/εξόδων ανά (mass) εντός ορισμένου χρονικού παραθύρου και γεωγραφικού πεδίου. Βιβλιογραφία: ISCC, RSB.
- **Book-and-Claim**: αποσύνδεση φυσικού και "claim" — ο πελάτης πληρώνει για συγκεκριμένη ποσότητα green fuel που χρησιμοποιείται κάπου αλλού στο σύστημα.
- Παραδείγματα από άλλους κλάδους: Renewable Energy Certificates (RECs), Sustainable Aviation Fuel.
- Επιπτώσεις στην εφαρμογή στη Maersk (preview για Κεφ. 6.4).

### 3.6 Πρότυπα και πιστοποιήσεις (1.5 σελ)

**Δομή — 4 standards:**
- **ISCC (International Sustainability and Carbon Certification)**: chain-of-custody, mass balance approach, EU recognition under RED II.
- **SBTi (Science Based Targets initiative)**: alignment με 1.5°C scenario, sector-specific guidance (maritime guidance pilot).
- **GLEC Framework**: industry-led methodology για logistics emissions accounting.
- **CDP, ISO 14001**: voluntary disclosure / management system frameworks.
- Σύνδεση: η Maersk έχει SBTi-validated targets (πιθανή web verification).

**Πηγές:** GHG Protocol (web), ISCC docs, SBTi portal, GLEC framework. Βιβλιογραφία θα συμπληρωθεί σε επόμενο βήμα.

**Code listings:** Καμία.

**Στοιχεία:** GHGP date 2001, Kyoto 1997, EU ETS Maritime 2024, Fuels EU Maritime 2025.

**Όχι εδώ:** Τεχνικές λεπτομέρειες υπολογισμού στο NRG (Κεφ. 5-6), αρχιτεκτονική (Κεφ. 9).

**Cross-refs:** Κεφ. 5.5 (πρακτική εφαρμογή hybrid), Κεφ. 6.3 (mass balance σε Energy Bank), Κεφ. 6.4 (POS/ISCC).

---

## Κεφ. 4 — Ο Πάγκος Εργασίας Εκπομπών: Επισκόπηση (4-5 σελίδες)

### 4.1 Στόχοι και αποστολή της ομάδας ET Platform (1 σελ)

**Δομή:**
- Citation από PDF (slide 1):
  > "Ensure Maersk realises our Net Zero 2040 targets by providing definitive emissions data and technology services that support customer decarbonization ambitions and drive ECO product adoption"
- Στόχοι ομάδας: trusted data, transparency, scale.
- Από Σεπ. 2023 παραγωγική χρήση (ξεκίνησε Μάρ. 2023).

### 4.2 Οι τέσσερις πυλώνες (2 σελ)

**Δομή — Πίνακας/διάγραμμα + παράγραφοι:**

| Πυλώνας | Mission |
|---------|---------|
| Ocean Emissions / Customer Baseline | Trusted emissions information & insights for decarbonization roadmaps |
| ECO Product Delivery | Integrated tech for rapid scale-up of ECO products → 30% sustainable energy by 2030 |
| Energy Markets (Bunker) | Optimize bunker plans for lowest spend; foundation για green fuel sourcing in ETS |
| Customer Baseline Emissions / Certificates | Customer-facing emissions data + certificates issuance |

Citation από PDF (slides 4-7) για κάθε πυλώνα.

Σχέσεις:
- Ocean Emissions feeds Customer Baseline & Certificates
- Bunker plans inform ETS surcharges in ECO pricing
- Energy Bank (mass balance) ορίζει τι μπορεί να πουληθεί ως ECO

### 4.3 Επιτεύγματα και αντίκτυπος (1 σελ)

**Δομή — Bullet points με μετρικά:**
- 1300+ onboarded users (slide 13)
- 98K FFE / $31M USD ECO Delivery Ocean sales 2024 (slide 13)
- Auto-generated certificates for ECO Delivery Ocean ECOv1 και ECOv2
- Resolution of 2023 GIA audit concerns
- ~32 deploys/ημέρα (operational metric)

### 4.4 Επισκόπηση χαρακτηριστικών UI (1 σελ)

**Δομή:** Βάσει PDF slide 12 (5 demo features):
1. Search and Find Emissions Data (customer code + date range)
2. Inspect Shipment Data on Route Level
3. Download Customer Data (Excel exports)
4. Generate Certificates for Customer
5. Get Certificates and Reports (PDF + accompanying report)

Αν είναι διαθέσιμα screenshots → ενσωμάτωση. Διαφορετικά περιγραφικά.

**Πηγές:** PDF slides 1-13, `nrg/README.md`.

**Code listings:** Καμία.

**Στοιχεία:** Όλα τα παραπάνω metrics.

**Όχι εδώ:** Λεπτομέρειες κάθε πυλώνα (Κεφ. 5-7), τεχνικές επιλογές (Κεφ. 8-9).

**Cross-refs:** Κεφ. 5, 6, 7 (πυλώνες σε βάθος).

---

## Κεφ. 5 — Πυλώνας Α: Ocean Emissions και STAR Connect (9-11 σελίδες)

### 5.1 Πρόκληση: Ακριβής καταγραφή εκπομπών στόλου (1 σελ)

**Δομή:**
- Πολυπλοκότητα: container shipping (πολλά proucts: ECO, EC2-EC5, FOSSIL· πολλές lanes)
- Διαφορετικές πηγές: vessels owned vs chartered
- Container types: Forty-Foot Equivalent (FFE), 20'/40', dry/reefer, etc.
- Voyage-level vs container-level granularity.

### 5.2 Πηγές δεδομένων (1.5 σελ)

**Δομή:**
- **Dremio data lake** (corporate data platform): `Infrastructure_GDA.Energy_Transition.*`, `EcoDelivery.ShipmentDetails`, `Common_Datasets.*`.
- **Shiptech**: legacy maritime order/voyage system, accessed via ODBC.
- **Kafka streams**: real-time events (vessel telemetry, shipment updates).
- Container moves data structure: `container_size`, `container_type`, `loaded_ffe`, `lane_id`, `port_of_receipt`, `port_of_discharge`, `arrived_on`, `first_loaded_at`.

**Code listing 5.2.1:** Από `nrg/components/emissions_workbench/lib/nrg/ocean/container_move.ex` lines 33-54 (Ecto schema container_move). Δείχνει modelling του container move με associations.

### 5.3 Vessel master data (ocean_api) (0.5 σελ)

**Δομή:**
- Component `nrg/components/ocean/ocean_api/`
- GenServer-based με `:pg` (process groups) για clustering
- Schemas: Vessel (IMO, name, ownership, flag_state, status)
- Public API: `get_all_vessels()`, `all_active()`, `find_by_imo()`

### 5.4 STAR Connect: Real-time τηλεμετρία (2 σελ)

**Δομή — λεπτομερής περιγραφή:**
- **Τι είναι STAR Connect**: σύστημα vessel telematics της Maersk που παρέχει real-time engine/fuel data.
- **Δεδομένα που παρέχει**:
  - Remaining Fuel On Board (RoB) ανά τύπο: HSFO, VLSFO, LSDIS, ULSFO, μεθανόλη, βιοκαύσιμα.
  - IMO number για vessel identification.
  - Period timestamps.
- **Ροή**: STAR Connect → Kafka topic → BoW external_data_feeds → ingestion στο PostgreSQL.
- **Κανονικοποίηση τύπων**: `starconnect_fuel_type_to_bow()` → "hs"/"vls"/"mdo"/"uls".
- **Σύνδεση**:
  - Bunker (κεφ. 7): RoB → input για επόμενο plan run.
  - Emissions (κεφ. 5.5): consumed fuel = ΔRoB → emission calculation.
- **Γιατί Kafka**: ασύγχρονη ροή με backpressure, durability, ordering ανά vessel partition.
- **Path**: `nrg/components/bunker/bow/lib/bops/external_data_feeds/remaining_fuel_on_board.ex` (αναφορά).

### 5.5 Υπολογισμός εκπομπών (1.5 σελ)

**Δομή:**
- **Trade Factors**: composite key (route_code × container_size × product × year). Πίνακες `ocean_trade_factors_*`.
- **EmissionsCalculator** (`Nrg.Ocean.EmissionsCalculator`): `get_ocean_emissions_for_route/N`.
- Formula:
  ```
  emissions_kg = loaded_ffe × emissions_factor(route, product, year, size)
  ```
- TTW vs WTW factors: ratio ~1.0-1.4 ανά καύσιμο.
- Calorific value normalization για cross-fuel comparison.

**Code listing 5.5.1:** Από `nrg/components/emissions_workbench/lib/nrg/ocean/ingest/converters.ex` lines 55-73 (pipeline transformation με `with`).

### 5.6 EU ETS surcharges (1 σελ)

**Δομή:**
- Component `nrg/components/ocean/eu_ets/`
- Διαβάζει από Dremio: `EUETSEmissionsTradeFactor`, `EUETSEmissionsSurcharge`, `EUETSPriceHistory`, `EUETSMetadata`.
- Quarterly validity (Q1-Q4) με run IDs για audit trail.
- Applied as charge to customer per voyage: `(emissions × ETS_factor × EUA_price)`.
- Σύνδεση με Fuels EU Maritime: incremental surcharge layer.

### 5.7 Customer Baseline Emissions (1 σελ)

**Δομή:**
- LiveView feature: search by customer code + date range → emissions report.
- Backend: aggregated queries πάνω σε `ocean_container_moves` joined με `customers`, `shipments`.
- Output: WTW/TTW totals, fossil baseline vs ECO actual, savings %.
- Audit trail per search (alert βασισμένο σε Loki, βλ. 9.10).

**Code listing 5.7.1 (προαιρετικό):** Από LiveView mount/handle_event για search form. Path: `lib/nrg_web/live/eco_delivery/dashboard_live.ex` ή παρόμοιο.

**Πηγές:**
- `nrg/components/ocean/` (όλο)
- `nrg/components/emissions_workbench/lib/nrg/ocean/` (κύρια domain)
- `nrg/components/emissions_workbench/lib/nrg/ocean/ingest/`
- `nrg/components/bunker/bow/lib/bops/external_data_feeds/remaining_fuel_on_board.ex`

**Στοιχεία:** ECO products: EC3, ECO, EC2, EC4, EC5, ECM (από test). Trade factor schemas: `ocean_trade_factors_*`. Container types/sizes enum.

**Όχι εδώ:** ECO certificates (Κεφ. 6), bunker plan optimization (Κεφ. 7), event sourcing internals (Κεφ. 9).

**Cross-refs:** Κεφ. 6 (downstream usage σε ECO products), Κεφ. 7 (bunker shares STAR Connect feed), Κεφ. 8.4 (Kafka), Κεφ. 8.5 (Dremio), Κεφ. 9.5 (data ingestion pipeline).

---

## Κεφ. 6 — Πυλώνας Β: ECO Product Delivery (9-10 σελίδες)

### 6.1 Τι είναι τα ECO Products (1 σελ)

**Δομή:**
- ECO Delivery Ocean: μεταφορά containers με εναλλακτικά καύσιμα.
- Customer value: αποδείξιμη μείωση scope 3 emissions.
- Quantification: tonnes CO₂e saved ανά FFE / ανά voyage.
- Παραδείγματα products: EC3, EC2, EC4, EC5, ECM (από test fixtures).
- Sales mechanism: customer πληρώνει premium · η Maersk εξασφαλίζει ότι το αντίστοιχο φυσικό καύσιμο χρησιμοποιείται κάπου στον στόλο (mass balance).

### 6.2 ECOv1 vs ECOv2 (1.5 σελ)

**Δομή:**

**ECOv1 (CO₂ basis):**
- Απόλυτη διαφορά (full grey emissions − green emissions)
- Formula:
  ```
  green_fuel_needed = (calorific_grey × grey_fuel_used) / calorific_green
  savings = (full_grey_emissions) − (green_emissions)
  ```
- Παραπομπή: `lib/nrg/products/eco.ex`

**ECOv2 (CO₂e basis, ποσοστιαίο):**
- Ποσοστιαία savings:
  ```
  ttw_savings = grey_emissions × ttw_emissions_savings_percentage × green_fuel_percentage
  ```
- Πιο ευέλικτο για πολλούς τύπους πράσινου καυσίμου.
- Παραπομπή: `lib/nrg/products/eco2.ex`

**Διαφορές πιστοποιητικού:**
- Template: `parse_template(:co2) → "ECO1"`, `parse_template(:co2e) → "ECO2"`
- Πεδίο "savings" εκφράζεται διαφορετικά (απόλυτο vs ποσοστιαίο).

### 6.3 Energy Bank: λογιστική πράσινου καυσίμου (3 σελ)

**Δομή — υποενότητες:**

**6.3.1 Πρόβλημα ισοζυγίου (0.5 σελ)**
- Πώς εξασφαλίζουμε ότι δεν πουλάμε περισσότερο πράσινο καύσιμο από το διαθέσιμο.
- Audit requirement: traceability to physical fuel orders.

**6.3.2 Event Sourcing και CQRS (1 σελ)**
- Commanded library, EventStore backend.
- Commands → Aggregates → Events → Projections
- Πλεονεκτήματα: full audit trail, event replay, time travel.
- Schema: events ως immutable, projections ως read models.

**Code listing 6.3.1:** Από `lib/energy_bank/application/transactions/withdraw_energy.ex` (lines 1-41) — Command + CommandHandler pattern.

**6.3.3 Deposits / Withdrawals / Clearing accounts (0.75 σελ)**
- **Deposits**: από fuel orders, εισαγωγή GJ/tonnes.
- **Withdrawals**: από shipments σε ECO products.
- **Clearing accounts**: ανά supplier/POS/period για logical separation.
- Projections: `clearing_account_deposits`, `fuel_order_deliveries`.

**6.3.4 Mass balance constraint (0.75 σελ)**
- Cumulative Deposits ≥ cumulative Withdrawals (per account / per period).
- Validation σε command handlers (cannot withdraw more than balance).
- Τι γίνεται όταν παραβιάζεται (alert + manual review).

### 6.4 Proof of Sustainability (POS) και ISCC (0.75 σελ)

**Δομή:**
- POS έγγραφα από προμηθευτές (refineries, biofuel producers).
- ISCC certification chain — POS αναφέρει feedstock, sustainability claims, energy content.
- `MatchedPos` projection: αντιστοίχηση `fuel_order_delivery → [POS]` με `pos_number`, `quantity`, `energy`.
- Path: `lib/energy_bank/projections/fuel_orders_projector.ex`.

### 6.5 Έκδοση πιστοποιητικών (2 σελ)

**Δομή:**

**6.5.1 Δομή πιστοποιητικού (0.5 σελ)**
- Πεδία: customer concern_code, year, FFE moves, total emissions WTW, savings % (ECOv2) ή absolute (ECOv1), ISCC reference, period validity.
- Σχήματα: `Nrg.Ocean.Certificates.Certificate`, embedded `EmissionsSummary`.

**6.5.2 PDF generation και Azure Blob Storage (0.75 σελ)**
- Process: aggregate emissions → format → render (πιθανώς via ChromicPDF ή PuppeteerHelper) → store στο Azure Blob.
- Filename convention: `{concern}_{year}_{template}_{certificate_id}.pdf`.
- Download endpoint: HTTP controller `lib/nrg_web/controllers/ocean/certificates_controller.ex` → `download/2`.

**6.5.3 Reissue, void, history (0.75 σελ)**
- Trigger reissue: όταν αλλάζουν δεδομένα (νέα emissions data ή POS).
- Async via Oban worker.
- Void with reason (audit metadata).
- `CertificateHistoryReport` για timeline ανά πελάτη.

**Code listing 6.5.1:** Oban worker από `lib/nrg/ocean/ingest/jobs/import_container_moves_batch.ex` (lines 1-36) — δείχνει pattern matching on perform/1, queue assignment.

### 6.6 ECO Delivery Surcharges (0.75 σελ)

**Δομή:**
- Component `lib/eco_delivery_surcharges/`
- Cost of Abatement formula:
  ```
  surcharge = grey_fuel_used × green_fuel_price_foe
  ή
  surcharge = wtw_savings × abatement_cost
  ```
- Pricing layer: customer-facing surcharge ανά voyage / contract.

**Πηγές:**
- `nrg/components/emissions_workbench/lib/energy_bank.ex`
- `nrg/components/emissions_workbench/lib/energy_bank/`
- `nrg/components/emissions_workbench/lib/nrg/products/eco.ex` και `eco2.ex`
- `nrg/components/emissions_workbench/lib/nrg/ocean/certificates.ex`
- `nrg/components/emissions_workbench/lib/nrg/ocean/certificates/`
- `nrg/components/emissions_workbench/lib/eco_delivery_surcharges/`

**Στοιχεία:** ECO1/ECO2 templates, FFE, calorific value, abatement cost.

**Όχι εδώ:** Bunker optimization (Κεφ. 7), event sourcing internals (Κεφ. 9.9 για βαθύτερα), framework/library επιλογές (Κεφ. 8.16).

**Cross-refs:** Κεφ. 3.5 (mass balance), Κεφ. 3.6 (ISCC), Κεφ. 5.5 (emissions calculation), Κεφ. 8.16 (EventStore), Κεφ. 9.9 (CQRS αρχιτεκτονική).

---

## Κεφ. 7 — Πυλώνας Γ: Bunker Optimization (Energy Markets) (7-8 σελίδες)

### 7.1 Το πρόβλημα ανεφοδιασμού (1 σελ)

**Δομή:**
- Πολυπλοκότητα: vessel rotations, multiple ports, fuel price variation, port call duration, ETS costs.
- Constraints: physical fuel availability, vessel storage, regulatory (sulfur caps).
- Στόχος: minimize total bunker spend over a planning horizon (συνήθως voyage rotation).
- Σύνδεση με ETS και green fuels: future expansion για cost of carbon στο objective function.

### 7.2 BOPS (Bunker Operations Planning System) (1 σελ)

**Δομή:**
- Acronym: BOPS.
- Δομή 3 layers:
  - **API** (`bunker/api/`): coordinator service, communicates με C++ solver.
  - **BoW (Bunker on Water Workbench)** (`bunker/bow/`): web UI (Phoenix).
  - **Solver (MBC = Multi-Bundle Connector)**: C++ linear programming.
- Ροή:
  ```
  Shiptech → API → BoW UI → Operator edits → API → Solver (MBC) → Results → BoW → Shiptech writeback
  ```
- Διαφορές από emissions_workbench: συνεργασία με external native solver, διαφορετική φύση (transactional vs analytical).

### 7.3 BoW: Web UI (1.5 σελ)

**Δομή:**
- Phoenix LiveView app.
- Σχήματα: vessels, bunker_plans, port_calls, schedules.
- Operator workflow:
  - Visualize current plan (vessel × ports × fuel quantities).
  - Edit inputs (port costs, fuel availability constraints).
  - Trigger plan run.
  - Compare results vs previous.
- Historical plans accessible (test: `see_historical_bunker_plans_test.exs`).

### 7.4 C++ Solver μέσω Erlang Ports (1.5 σελ)

**Δομή:**
- **Γιατί C++**: γραμμικός προγραμματισμός με ώριμες βιβλιοθήκες (πιθανώς CPLEX ή GLPK).
- **Γιατί Ports αντί NIFs**:
  - NIFs: shared address space → segfault σκοτώνει BEAM.
  - Ports: separate OS process → απομόνωση σφαλμάτων.
- Communication: stdio με binary protocol (συνήθως Erlang term format).
- Distributed tracing: traceparent IDs propagation (test: `solve_test.exs`).
- Path: `bunker/api/` (server.ex coordinates Port).

### 7.5 Shiptech integration (1 σελ)

**Δομή:**
- Shiptech: legacy SQL Server-based maritime planning system.
- Data IN: VesselVoyagedetailId, port calls, vessel schedules, ETA/ETD.
- Data OUT: bunker plan results (fuel estimates ανά port).
- Stored procedures: `sp_CreateModelRunDataWithString` (insert results), `sp_UpdateBunkerPlanOperatorInputs` (operator changes back).
- ODBC connectivity με `Shiptech.Repo`.

### 7.6 Plan run scheduling (0.5 σελ)

**Δομή:**
- `PlanRunEnqueuer` (path: `bow/lib/bops/vessels/plan_run_enqueuer.ex`).
- Triggers: scheduled (cron-like via Oban Pro? ή Quantum), manual (operator button).
- Idempotency και deduplication.

### 7.7 Σύνδεση με ETS και green fuel (0.5 σελ)

**Δομή:**
- Bunker plan ως foundation: ξέρουμε πού φορτώνουμε καύσιμο, πόσο, και την τιμή.
- ETS layer: επιπλέον cost component στο objective function (μελλοντικό).
- Green fuel sourcing: επιλογή πορτών με διαθέσιμο πράσινο καύσιμο, integration με Energy Bank deposits.

**Code listing 7.4.1:** GenServer pattern από `lib/nrg_worker/director.ex` (lines 1-44) — δείχνει supervision και dynamic worker management. (Ή εναλλακτικά κάτι από bunker/api/server.ex αν διαθέσιμο.)

**Code listing 7.5.1 (προαιρετικό):** Terraform azurerm_postgresql_flexible_server από `bunker/terraform/staging/database.tf` lines 1-53.

**Πηγές:**
- `nrg/components/bunker/README.md`
- `nrg/components/bunker/api/`
- `nrg/components/bunker/bow/`
- `nrg/components/bunker/shiptech/`
- `nrg/components/bunker/terraform/`

**Στοιχεία:** 8 logic apps (activate_vessel, pre_processing, upload_bunker_plan, upload_user_input + variants), 4 environments (staging/production × api/logic_app), bunker/bow LOC 16,738 / bunker/api 8,816.

**Όχι εδώ:** General Phoenix/LiveView (Κεφ. 8.2), Terraform deep dive (Κεφ. 8.9), CI/CD (Κεφ. 8.11).

**Cross-refs:** Κεφ. 5.4 (STAR Connect feed κοινή με bunker), Κεφ. 8.1 (BEAM Ports rationale), Κεφ. 8.7 (Azure), Κεφ. 9.3 (monorepo).

---

## Κεφ. 8 — Τεχνολογίες (11-13 σελίδες)

> Επεκτείνει σημαντικά το υπάρχον "Τεχνολογία".

**Συνολική προσέγγιση:** Κάθε τεχνολογία ~0.5-1 σελίδα. Δομή ανά υποενότητα: (i) τι είναι, (ii) γιατί επιλέχθηκε για το πρόβλημα, (iii) πώς χρησιμοποιείται στο NRG, (iv) εναλλακτικές που απορρίφθηκαν (όπου εφαρμόσιμο).

### 8.1 BEAM, Erlang, Elixir (1.5 σελ)

> Επέκταση υπάρχοντος.

- Ιστορικό: Ericsson, Erlang/OTP, BEAM VM, Elixir 2011.
- BEAM υψηλού επιπέδου: preemptive scheduler, lightweight processes, message passing, supervision trees, "Let it crash".
- Σύγκριση με JVM (heavy threads), Go (goroutines αλλά shared memory), Node.js (single-threaded).
- Ports για native integration (κεφ. 7.4 cross-ref).
- Hot code reloading (αν χρησιμοποιείται).
- **Code listing 8.1.1:** Pipeline transformation από `lib/nrg/ocean/ingest/converters.ex` 55-73.

### 8.2 Phoenix Framework & LiveView (1 σελ)

- Phoenix: web framework (Plug-based, MVC-like).
- LiveView: server-rendered UI με WebSocket για ασύγχρονη ενημέρωση.
- Σύγκριση με SPAs (React/Vue): single codebase, latency στο WebSocket vs API roundtrips.
- PubSub για real-time updates μεταξύ users/sessions.
- Phoenix.Component για reusable templates.
- **Code listing 8.2.1:** mount/handle_event από `lib/nrg_web/live/ocean_simulator_live.ex` 34-79.

### 8.3 PostgreSQL & Ecto (0.75 σελ)

- Γιατί PostgreSQL: ώριμη, ACID, JSON support, extensions (pg_cron, pg_stat_statements).
- Ecto: 4-layer (Adapter, Schema, Changeset, Query).
- Multi-tenancy / multi-database: ξεχωριστές DBs ανά context (Shiptech.Repo, EventStore).
- Migrations: 720+ συνολικά, declarative, reversible.
- **Code listing 8.3.1:** Ecto schema από `lib/nrg/ocean/container_move.ex` 33-54.

### 8.4 Apache Kafka (0.75 σελ)

- Distributed log + message broker.
- Χρήση: STAR Connect feeds, ocean emissions ingestion, event streaming μεταξύ components.
- Producer/Consumer με `:brod` (Erlang client).
- Topic partitioning ανά vessel (για ordering).
- Consumer groups, offsets, idempotent processing.
- 9 αρχεία με Kafka integration.

### 8.5 Dremio (0.75 σελ)

- Federated SQL για data lake (Maersk Enterprise platform).
- Αντικατάσταση direct queries σε underlying systems.
- Authentication: personal access tokens (DREMIO_API_KEY).
- ODBC/Arrow Flight για streaming queries.
- Schema namespaces: `Infrastructure_GDA.Energy_Transition.NetZero.*`, `Common_Datasets.*`, `Masterdata.*`.

### 8.6 ODBC integrations (0.5 σελ)

- BEAM ODBC adapter (στο Erlang OTP).
- Σύνδεση με Shiptech (SQL Server).
- Πιο εκτεταμένη χρήση Dremio είναι μέσω ODBC ή Arrow.

### 8.7 Microsoft Azure (1 σελ)

- Cloud platform choice (group-wide standard στη Maersk).
- Resources σε χρήση:
  - PostgreSQL Flexible Server (Azure Database)
  - Azure Kubernetes Service (AKS)
  - Azure Key Vault (κάποια secrets)
  - Logic Apps (BOPS workflow orchestration)
  - Blob Storage (PDF certificates)
  - API Management (BOPS gateway)
  - Active Directory + SAML SSO
- 2 environments (staging, production).
- Cost vs control trade-off.

### 8.8 Kubernetes (0.75 σελ)

- Container orchestration.
- 3 replicas web server.
- Akamai → Stargate (API gateway) → AKS ingress → pods.
- Rolling deployments, health checks (readiness/liveness probes).
- Custom `k8s` binary για deployment (Nix-based wrapper πάνω σε kubectl).

### 8.9 Terraform (0.75 σελ)

- Infrastructure as Code.
- 57 `.tf` files.
- 4 BOPS environments (staging/production × api/logic_app), αυτόνομο για NRG.
- 34+ azurerm resource types σε χρήση.
- State management.
- **Code listing 8.9.1:** azurerm_postgresql_flexible_server από `bunker/terraform/staging/database.tf` 1-53.

### 8.10 Nix και nix-darwin (1 σελ)

- Reproducible package management.
- Flakes (declarative, locked dependencies).
- nix-darwin: Nix integration στο macOS.
- Home Manager: user config (.zshrc, git, packages).
- Direnv για auto-loading `flake.nix` ανά project.
- Σύνδεση με `presentations/Nix Workshop.md` (εσωτερικό workshop).
- **Code listing 8.10.1:** flake.nix app definition lines 100-105.

### 8.11 GitHub Actions και Custom Runner (0.75 σελ)

- 20 workflows (build, test, IaC scan, deployments, security).
- Custom NixOS runner στο Azure (faster feedback vs GitHub-hosted).
- AppRole auth με Vault για secrets.
- Affected workspace apps (incremental builds).
- ~32 deploys/ημέρα average.

### 8.12 Maersk Design System (MDS) (0.5 σελ)

- Web Components-based UI library.
- Brand consistency across Maersk apps.
- Storybook reference: https://mds.maersk.com/
- Integration με Phoenix.Component.

### 8.13 Observability stack (1 σελ)

- **Logs**: Grafana Loki + LogQL.
- **Metrics**: PromEx → Prometheus → Grafana. Έτοιμα dashboards για Phoenix, Oban, LiveView.
- **Traces**: OpenTelemetry → OpenObserve (self-hosted, v0.14.4 στο flake).
- **Alerts**: code στο `/alerts/` (13+ rules), notifications via Hedwig (Teams/email).
- **Maersk Observability Platform (MOP)**: hosted dashboards, log ingestion.
- **Code listing 8.13.1:** Alert rule από `alerts/metrics/alerts.yaml` 40-49 (ETW concurrent requests).

### 8.14 HashiCorp Vault & agenix (0.5 σελ)

- Vault: secrets management για prod/staging credentials, OIDC login.
- AppRole auth pattern για CI/CD.
- agenix: declarative encryption με age, για config-time secrets (πχ binary cache netrc).
- Διαφορά: Vault για runtime, agenix για build-time.

### 8.15 Oban (0.75 σελ)

- Background job processor βασισμένο σε PostgreSQL.
- 31 workers στο NRG.
- Queues, retries, scheduled jobs.
- Παράδειγμα χρήσεων: certificate reissue, container moves batch ingestion.
- Sidekiq για Elixir (mental model).
- **Code listing 8.15.1:** Oban worker από `lib/nrg/ocean/ingest/jobs/import_container_moves_batch.ex` 1-36.

### 8.16 Commanded & EventStore (0.5 σελ)

- Event sourcing library για Elixir.
- EventStore (μήνας πακέτο `commanded_eventstore_adapter`) backend πάνω σε PostgreSQL.
- Aggregates → Commands → Events → Projections.
- Παράδειγμα: Energy Bank.

### 8.17 Λοιπά υποστηρικτικά εργαλεία (0.5 σελ)

- **Credo** (linter), **Dialyxir** (type checking).
- **Telemetry** (instrumentation).
- **Tuple** (pair programming).
- **Livebook** (data exploration, `data-quality.livemd`).
- **ChromicPDF** (πιθανώς για PDF generation).
- **Workspace** (Elixir monorepo orchestration).

**Πηγές:**
- `nrg/flake.nix`
- `nrg/mix.exs`
- `nrg/guides/tech/about-our-dev-environment-and-tooling.md`
- `nrg/guides/tech/code-style.md`
- `nrg/guides/observability/`
- `nrg/guides/security/`
- `nrg/guides/dremio/`
- `presentations/Nix Workshop.md`

**Στοιχεία:** Όλα τα μετρικά από την κορυφή.

**Όχι εδώ:** Πώς συνδέονται μεταξύ τους (Κεφ. 9), εργασιακές πρακτικές (Κεφ. 10).

**Cross-refs:** Κεφ. 9 (architecture), Κεφ. 10.4 (CI/CD policy).

---

## Κεφ. 9 — Αρχιτεκτονική του συστήματος (12-14 σελίδες)

### 9.1 Επισκόπηση συστήματος (1 σελ)

- Διάγραμμα `system_overview_diagram.png` με αναλυτικές περιγραφές.
- Logical view (components και αλληλεπιδράσεις) vs physical view (deployment).
- High-level data flow.

### 9.2 Clean Architecture στην πράξη (1.5 σελ)

> Επέκταση από guide `clean-architecture.md`.

**Δομή:**
- 4 levels: Entities, Use Cases, Adapters/Gateways, Frameworks/Drivers.
- Polymorphic Gateway interfaces (αντί για direct Repo calls).
- Humble Object pattern σε boundaries (LiveView, Controllers).
- Παράδειγμα: Certificates feature ως case study (use case → gateway → adapter → repo).
- Πώς ενσωματώνεται με Phoenix (συνηθισμένα patterns vs Clean).

### 9.3 Monorepo οργάνωση (1 σελ)

- Workspace + Mix umbrella combination.
- 5 components: emissions_workbench, bunker, ocean, eco_products (mostly placeholder), net_zero (placeholder).
- DAG of dependencies.
- Affected app detection για incremental CI.
- Pros (atomic refactoring, shared tooling) vs cons (build complexity).

### 9.4 Components και τα όριά τους (1 σελ)

- Πίνακας: component → ρόλος → public API.
- Internal vs public APIs (Elixir δεν έχει access modifiers — convention).
- Όρια domain (DDD bounded contexts).

### 9.5 Data ingestion pipeline (2 σελ)

**Δομή:**

**9.5.1 Polling sources (0.75 σελ)**
- Dremio queries (ODBC streaming).
- Shiptech queries.
- Schedule via Oban (πχ καθημερινά).
- Idempotency (last_updated bookmark).

**9.5.2 Streaming (0.75 σελ)**
- Kafka consumers (`OceanEmission.Ingestion.KafkaConsumer`).
- Backpressure με GenStage / Broadway (αν χρησιμοποιείται).
- Topic partitioning για ordering.
- Consumer offset management.

**9.5.3 Job processing (0.5 σελ)**
- Staging tables (RawOceanContainerMove) → enrichment → main tables.
- Oban worker pipeline.
- Error handling: dead-letter queue, retries, alerts.

**Code listing 9.5.1:** Reuse Oban worker από Κεφ. 8.15 ή GenServer από `nrg_worker/director.ex`.

### 9.6 Web layer (0.75 σελ)

- LiveView modules ανά feature area.
- 4 namespaces: Eco Delivery (13), Energy Bank (7), Emissions Data Inventory (14), Admin (7), Ocean Emission Web (6).
- LiveComponents reuse.
- MDS integration.
- Static assets (esbuild, esbuild Phoenix).

### 9.7 Authentication & Authorization (0.75 σελ)

- SAML SSO με Azure AD.
- AD groups (πχ "SBTi Developers", "ECO Sales") για RBAC.
- Roles σε LiveView mounts (`with_authenticated_request(ctx, roles: ~ROLES(admin))`).
- Privileged Identity Management (PIM) για production access.

### 9.8 Persistence layer (0.75 σελ)

- PostgreSQL Flexible Server (Azure).
- Multiple databases ανά context (separation of concerns, blast radius).
- Backup strategy: Azure Data Protection (daily/weekly), restore tests (κρίσιμο για audit).
- DB migrations cadence: continuous (κάθε deploy).

### 9.9 Event sourcing για Energy Bank (1.5 σελ)

> Πιο τεχνικά λεπτομερής από Κεφ. 6.3.

**Δομή:**
- Aggregates → state machines (πχ `ClearingAccount` aggregate).
- Commands → validation → events.
- Events → immutable log → projections.
- Projector pipeline: subscribe to events, update read models.
- Re-projection: rebuild from events (μηχανισμός για schema changes).
- Eventual consistency: command return ≠ projection updated (αν χρειαστεί `wait_until`).

**Code listing 9.9.1:** Reuse Command από Κεφ. 6.3.1.

### 9.10 Observability αρχιτεκτονική (1.5 σελ)

> Επέκταση κεφ. 8.13 με αρχιτεκτονικό view.

**Δομή:**
- Telemetry events σε όλη τη ροή (Phoenix, Ecto, Oban, custom).
- Trace propagation: HTTP → BEAM → DB → Kafka.
- Alert rules:
  - Pods CrashLoop (30s)
  - Cluster node unreachability
  - ETW concurrent requests (>5)
  - Non-200 spike (>200/10min)
  - DB storage >80%
  - Data freshness (Ingestion 72h, Enrichment 6h, Energy Bank deposits)
  - Vessel Voyage data stale (>49h)
  - Oban job failures
  - Unallocated emissions >2%
  - Energy Bank Projector failures
- Notifications: Hedwig → Teams/email.

**Code listing 9.10.1:** Reuse alert rule από Κεφ. 8.13.1.

### 9.11 Deployment topology (0.75 σελ)

- 3 replicas Phoenix web pods.
- 1 worker pod (background processing).
- Akamai → Stargate → AKS ingress → pods.
- Rolling deployments via Kubernetes.
- Migrations strategy: pre-deploy migrations, backward-compatible only (zero-downtime).

### 9.12 Disaster recovery & reproducibility (0.5 σελ)

- Terraform για full system rebuild.
- Nix για reproducible builds.
- Database backups + automated weekly restore tests (workflow `db-restore-from-backup.yml`).
- Disaster scenarios: AKS cluster failure → switch to backup region (αν εφαρμόζεται), DB failure → restore from PITR.
- RTO/RPO indicative.

**Πηγές:**
- `nrg/guides/tech/clean-architecture.md`
- `nrg/guides/observability/`
- `nrg/guides/security/`
- `nrg/guides/tech/postgres-dbs-in-azure.md`
- `nrg/guides/tech/migrating-kubernetes-clusters.md`
- `nrg/alerts/metrics/alerts.yaml`
- `nrg/components/*/infrastructure/`
- Όλος ο κώδικας

**Στοιχεία:** 720 migrations, 151 tables, 13+ alert rules, 3 web replicas, 2 environments.

**Όχι εδώ:** Tech choices σε λεπτομέρεια (Κεφ. 8), agile practices (Κεφ. 10).

**Cross-refs:** Κεφ. 8 (κάθε τεχνολογία), Κεφ. 10 (deployment cadence).

---

## Κεφ. 10 — Εργασιακές μέθοδοι (9-11 σελίδες)

> Εκτεταμένη επανασύνταξη του υπάρχοντος "Εργασιακές μέθοδοι".

### 10.1 Agile και Extreme Programming (1.5 σελ)

**Δομή:**
- Σύντομο ιστορικό XP (Kent Beck, "Extreme Programming Explained" 1999).
- Αξίες XP: Communication, Simplicity, Feedback, Courage, Respect.
- 12 πρακτικές XP (πλήρης λίστα).
- Σύγκριση με Scrum: γιατί η ομάδα επέλεξε XP (έμφαση στις τεχνικές πρακτικές, χαμηλότερο overhead ceremonies).
- Πιθανή αναφορά σε pivot από Scrum (αν συνέβη).

### 10.2 Pair Programming (1 σελ)

> Επέκταση υπάρχοντος.

**Δομή:**
- Ρόλοι (driver/navigator) — διατήρηση υπάρχοντος.
- Tools: Tuple (αναφορά onboarding), VS Code Live Share.
- Mob/Ensemble programming: πότε χρησιμοποιείται (συνήθως σε σύνθετο σχεδιασμό).
- Εμπειρικά αποτελέσματα (αναφορά στο υπάρχον).
- Σχέση με knowledge sharing (επέκταση).
- Παρατηρήσεις από distributed setting (Ευρώπη/Ινδία 28 μέλη).

### 10.3 TDD - Test Driven Development (1 σελ)

> Επέκταση υπάρχοντος.

**Δομή:**
- Red-Green-Refactor cycle.
- Test pyramid: unit, integration, acceptance, E2E.
- Property-based testing με `ExUnitProperties` (αναφορά test "for generated container moves are valid").
- Acceptance tests (αναφορά υπάρχοντος).
- Test coverage culture (786 test files, ~13% του κώδικα).
- Παράδειγμα: 5 tests στο `ocean_simulator_live_test.exs` δείχνουν incremental TDD.

**Code listing 10.3.1:** LiveView TDD test από `test/nrg_web/live/ocean_simulator_live_test.exs` 1-50.

### 10.4 Continuous Integration / Continuous Delivery (1.5 σελ)

> Επέκταση υπάρχοντος.

**Δομή:**
- Trunk-based development (single `main` branch).
- ~32 deploys/ημέρα στο production environment.
- Custom NixOS GitHub runner (κεφ. 8.11 cross-ref).
- Workflow categories:
  - Build/test (emissions-workbench.yml, bops.yml)
  - Security (iac-scan.yml με Checkov, Prisma Cloud SAST)
  - Cache (cache-send.yml, cache-build-image.yml)
  - DB (db-restore-from-backup.yml — weekly Friday)
  - Infrastructure (deploy-openobserve.yaml, repave-github-runner.yml)
  - Notifications (teams-notify.yml)
- Affected workspace apps για incremental builds.
- Rollback: revert PR → νέα έκδοση μέσω deploy.
- Feature flags (αν χρησιμοποιούνται).

### 10.5 Vertical Ownership (1 σελ)

> Επέκταση υπάρχοντος.

**Δομή:**
- Ευθύνες ομάδας (αναφορά υπάρχουσας λίστας).
- Σύγκριση με horizontal teams: η ομάδα δεν εξαρτάται από SRE/DBA/InfoSec teams.
- Πλεονεκτήματα: ταχύτητα, αυτονομία.
- Μειονεκτήματα: cognitive load, βάθος εξειδίκευσης.
- Πώς αντιμετωπίζεται το cognitive load: knowledge sharing μέσω pairing.

### 10.6 Feedback Loops (1 σελ)

> Επέκταση υπάρχοντος.

**Δομή:**
- Εικόνα `Extreme_Programming_Loops.png`.
- Multi-scale feedback (δευτερόλεπτα → μήνες).
- Συσκευές κάθε loop:
  - Pair (sec-min)
  - Tests + compiler (min)
  - Daily standup (day)
  - Acceptance tests + production telemetry (days-week)
  - Iteration planning (week)
  - Strategic alignment (month)
- Real-time feedback από production (1300+ users) μέσω observability + direct user feedback.

### 10.7 Onboarding & Knowledge Sharing (1 σελ)

**Δομή:**
- Buddy system (αναφορά `people-operations/`).
- Week 1: docs change + repo familiarity.
- Week 2: code change + production release.
- KT sessions: shipping basics, technical architecture, production deployment.
- Distribution lists για επικοινωνία (Outlook/Teams).
- Tools: Tuple, Confluence, Jira, Miro.
- Distributed team logistics (28 μέλη, Ευρώπη/Ινδία timezone overlap).
- Learning resources: O'Reilly portal, Elixir Learning Path.

### 10.8 Code Review μέσω pairing (0.5 σελ)

**Δομή:**
- Συνήθως δεν χρησιμοποιούνται PRs εσωτερικά (κώδικας merged απευθείας στο main από pairs).
- Αιτιολόγηση: pairing ≈ continuous code review.
- Εξαιρέσεις: external contributions, security-sensitive changes.
- Trade-offs: γρήγορη παράδοση vs traceability via PR comments (mitigated με commit messages).

### 10.9 Hiring & Team Composition (0.5 σελ)

**Δομή:**
- Hiring criteria (από people-operations): test-writing culture, pairing willingness.
- Σχέση με XP "Whole Team" practice.
- Distribution Europe/India.

**Πηγές:**
- Υπάρχον κείμενο (όλο)
- `nrg/guides/people-operations/`
- `nrg/guides/tech/code-style.md`
- `nrg/guides/tech/working-in-the-project.md`
- Βιβλιογραφία: Kent Beck "Extreme Programming Explained", Kent Beck "Test-Driven Development By Example"

**Στοιχεία:** 28 μέλη (17 EU, 11 IN), 32 deploys/ημέρα, 786 test files, 20 workflows, 4 environments BOPS.

**Code listings:** TDD test (10.3.1).

**Όχι εδώ:** Implementation details (Κεφ. 8-9).

**Cross-refs:** Κεφ. 8.11 (CI/CD tech), Κεφ. 9 (architecture).

---

## Κεφ. 11 — Συμπεράσματα (3 σελίδες)

### 11.1 Σύνοψη της λύσης (1 σελ)

**Δομή:**
- Επίτευγμα: από manual διαδικασία μηνών σε self-service real-time πλατφόρμα.
- Αρχιτεκτονικά highlights: BEAM, event sourcing, Clean Architecture, vertical ownership.
- Διαχείριση πολυπλοκότητας: monorepo + Workspace, Nix για reproducibility.

### 11.2 Επιτυχίες και μετρήσεις αντίκτυπου (1 σελ)

**Δομή — Πίνακας μετρικών:**
- 1300+ users (από <100 κατά τη χειρωνακτική εποχή).
- 98K FFE / $31M USD ECO Delivery sales 2024.
- Audit compliance (GIA 2023).
- Auto certificates (πιθανώς πολλές χιλιάδες ετησίως).
- 32 deploys/ημέρα (high velocity).
- 720+ migrations χωρίς downtime.
- 786 tests / 6033 source files.

### 11.3 Μαθήματα από την υλοποίηση (1 σελ)

**Δομή:**
- Επιλογές που λειτούργησαν:
  - BEAM για ανοχή σφαλμάτων και παραλληλία.
  - Event sourcing για audit trails.
  - Pair programming για knowledge sharing.
  - Vertical ownership για velocity.
  - Nix για reproducibility.
- Trade-offs:
  - Cognitive load από vertical ownership (mitigated με pairing).
  - Monorepo build complexity (mitigated με Workspace).
  - Cloud costs vs self-hosting.
  - Event sourcing complexity για onboarding.
- Τι θα γινόταν διαφορετικά:
  - Πιθανώς νωρίτερα Scope 2 inclusion.
  - Καλύτερη ενσωμάτωση από την αρχή με Bunker (BOPS).

**Όχι εδώ:** Νέα αρχιτεκτονικά στοιχεία (συνοψίζουμε ήδη ειπωμένα).

---

## Κεφ. 12 — Μελλοντική εργασία (2 σελίδες)

### 12.1 Scope 2 measurements (0.5 σελ)

- Έρχεται 2025 (αναφορά υπάρχοντος).
- Πεδίο: γραφεία, terminals, electricity για cold ironing.
- Τεχνική πρόκληση: integration με facility management systems.

### 12.2 Επεκτάσεις στόλου / activity coverage (0.5 σελ)

- Land-side reporting (trucks, rail, terminal equipment).
- Air freight emissions (Maersk Air Cargo).
- Last-mile delivery.

### 12.3 SBTi reporting expansion (0.25 σελ)

- Net Zero progress tracking.
- Annual SBTi disclosures.

### 12.4 Προηγμένα analytics (0.5 σελ)

- Predictive emissions: ML models για forecast.
- Decarbonization scenarios: what-if analysis για fleet transitions.
- Optimization beyond bunker: route + bunker + fuel mix joint optimization.

### 12.5 Bunker + Energy Bank σύνδεση (0.25 σελ)

- Αυτόματη επιλογή πορτών με green fuel availability.
- Pre-allocation στο Energy Bank από bunker plans.

**Cross-refs:** Κεφ. 7.7, Κεφ. 9.

---

## Κεφ. 13 — Βιβλιογραφία (2-3 σελίδες)

> Συμπληρώνεται σε επόμενο βήμα. Αρχικοί υποψήφιοι:

- **Πρότυπα/Πρωτόκολλα**:
  - GHG Protocol Corporate Standard (2004 revised)
  - GHG Protocol Scope 3 Standard (2011)
  - ISO 14064-1, 14064-2
  - GLEC Framework v3 (2023)
  - ISCC EU System Documents
  - SBTi Maritime Guidance
  - IMO 2023 GHG Strategy (MEPC.377(80))
  - CSRD Directive (EU) 2022/2464
  - EU ETS Maritime Regulation (EU) 2023/957
  - Fuels EU Maritime Regulation (EU) 2023/1805

- **Βιβλία/Tech**:
  - Kent Beck — "Extreme Programming Explained: Embrace Change" (2nd ed. 2004)
  - Kent Beck — "Test-Driven Development: By Example" (2002)
  - Robert C. Martin — "Clean Architecture" (2017)
  - Joe Armstrong — "Programming Erlang" (2nd ed. 2013)
  - Saša Jurić — "Elixir in Action" (3rd ed. 2024)
  - Greg Young — "CQRS Documents" (2010, web-published)
  - Vaughn Vernon — "Implementing Domain-Driven Design" (2013)

- **Web/Standards**:
  - GHG Protocol website
  - GLEC website
  - SBTi portal
  - IMO MEPC pages

---

# ΟΔΗΓΙΕΣ ΠΡΟΣ SUB-AGENTS ΣΥΓΓΡΑΦΗΣ

## Πρότυπο prompt για κάθε sub-agent

```
Είσαι sub-agent για τη συγγραφή ΕΝΟΣ συγκεκριμένου κεφαλαίου διπλωματικής Master στα Ελληνικά.

ΠΛΑΙΣΙΟ:
- Repo: /Users/kg/Desktop/report
- Κύριο αρχείο: gkinis_konstantinos.md (markdown με YAML frontmatter, mainfont Arial 12pt, ελληνικά)
- Κώδικας: /Users/kg/Desktop/report/nrg (symlink στο /Users/kg/workspace/nrg)
- Πλάνο: /Users/kg/Desktop/report/plan.md (διάβασε ΟΛΟΚΛΗΡΟ το πλάνο πρώτα για κατανόηση συνολικής δομής, μετά εστίασε στο δικό σου κεφάλαιο)
- Παρουσίαση: /Users/kg/Desktop/report/presentations/ETPlatformTechMeet2025.pdf

ΕΡΓΑΣΙΑ:
- Γράψε το κεφάλαιο: <Κεφ. X — Τίτλος>
- Στόχος σελίδων: <από πλάνο>
- Δομή: <από πλάνο>
- Ενσωμάτωσέ το στο gkinis_konstantinos.md ως νέο κεφάλαιο ή αντικαθιστώντας υπάρχον (όπου επικαλύπτεται).

ΟΔΗΓΙΕΣ:
1. Διάβασε το plan.md (ολόκληρο), εστιάζοντας στο δικό σου κεφάλαιο.
2. Διάβασε τις πηγές που αναφέρονται.
3. Διάβασε το υπάρχον τμήμα στο gkinis_konstantinos.md (αν υπάρχει).
4. Γράψε το κεφάλαιο ένα υποκεφάλαιο τη φορά:
   - Επεξεργάσου το gkinis_konstantinos.md (Edit tool).
   - Commit μετά από κάθε υποκεφάλαιο με μήνυμα:
     "Κεφ. X.Y: <Τίτλος υποκεφαλαίου>"
   - Συνεχισε με το επόμενο.
5. Ύφος: Ακολούθησε το cross-cutting style guide του πλάνου (ελληνικά, αγγλικός όρος σε παρένθεση πρώτη φορά, αιτιολόγηση επιλογών, code listings στους ακριβείς αριθμούς γραμμών που αναφέρονται).
6. Έλεγξε ότι το κείμενο ρέει και ταιριάζει με το ύφος του ήδη γραμμένου τμήματος.
7. Αν χρειάζονται εικόνες/διαγράμματα που δεν υπάρχουν, χρήση mermaid blocks ή textual descriptions με placeholder.
8. Στο τέλος: report ολιγόλογο για το τι ολοκληρώθηκε.

ΑΠΑΓΟΡΕΥΣΕΙΣ:
- ΜΗΝ αλλάξεις άλλα κεφάλαια (μόνο το δικό σου).
- ΜΗΝ προσθέσεις σχόλια σε κώδικα του repo (στο /nrg/).
- ΜΗΝ commit-άρεις με force ή με --no-verify.
- ΜΗΝ διαγράψεις το plan.md.
- ΜΗΝ ξεπεράσεις σημαντικά τον στόχο σελίδων (±20%).
```

## Κατανομή κεφαλαίων σε 3-parallel sub-agent batches

**Batch 1 (παράλληλα, ξεκινούν πρώτα):**
- B1.A — Κεφ. 2: Πλαίσιο και πρόβλημα
- B1.B — Κεφ. 3: Θεωρητικό υπόβαθρο
- B1.C — Κεφ. 4: Επισκόπηση πάγκου εργασίας

**Batch 2 (παράλληλα, μετά Batch 1):**
- B2.A — Κεφ. 5: Ocean Emissions και STAR Connect
- B2.B — Κεφ. 6: ECO Product Delivery
- B2.C — Κεφ. 7: Bunker Optimization

**Batch 3 (παράλληλα, μετά Batch 2):**
- B3.A — Κεφ. 8: Τεχνολογίες
- B3.B — Κεφ. 9: Αρχιτεκτονική
- B3.C — Κεφ. 10: Εργασιακές μέθοδοι

**Batch 4 (παράλληλα, τελευταίο):**
- B4.A — Κεφ. 1: Εισαγωγή (γράφεται τελευταίο για συνέπεια)
- B4.B — Κεφ. 11: Συμπεράσματα
- B4.C — Κεφ. 12: Μελλοντική εργασία

**Επόμενο step (μετά τη διπλωματική):** Κεφ. 13: Βιβλιογραφία.

## Σχήμα προοδευτικής εκτέλεσης

- Παράλληλα 3 sub-agents τη φορά.
- Όταν ολοκληρωθεί ένας του τρέχοντος batch, ξεκινά ο επόμενος.
- Από το επόμενο batch, ξεκινούν agents όταν αδειάζει slot (όχι μετά την πλήρη ολοκλήρωση του batch).
- Συνολικά: 12 chapter-writing agents.
- Κάθε agent commit-άρει ανά υποκεφάλαιο (σχήμα ~6-12 commits ανά κεφάλαιο).

## Τελικό editorial pass

Μετά την ολοκλήρωση όλων των batches:
1. Διάβασμα ολόκληρου του gkinis_konstantinos.md
2. Έλεγχος για:
   - Συνέπεια ορολογίας
   - Cross-references
   - Επανάληψη υλικού
   - Ροή ύφους
   - Τυπογραφία (μη συνεπείς fonts, λείπουν blank lines)
3. Διορθώσεις
4. Commit "Editorial pass: συνέπεια και ροή"

## Κατάσταση συντήρησης πλάνου

- Το plan.md ενημερώνεται όταν ένας sub-agent εντοπίζει αναγκαία αλλαγή.
- Πιθανές αλλαγές: page count adjustment, νέο υποκεφάλαιο, αναδιάταξη.
- Commits στο plan.md χωριστά από commits στο gkinis_konstantinos.md.

## Risk register (επικαιροποιημένο)

| Κίνδυνος | Πιθανότητα | Επίπτωση | Μετριασμός |
|---------|-----------|----------|-----------|
| Token overrun | Μεσαία | Υψηλή | Commits ανά υποκεφάλαιο, 3 παράλληλοι agents (όχι 12) |
| Επικαλύψεις κεφαλαίων | Υψηλή | Μεσαία | "Όχι εδώ" sections, cross-refs σαφή |
| Ασυνέπεια ύφους | Μεσαία | Μεσαία | Cross-cutting style guide, final editorial pass |
| Τεχνικές ανακρίβειες | Μεσαία | Υψηλή | Verification στους sources που δίνονται· final review |
| Έλλειψη βιβλιογραφικών | Δεδομένη | Χαμηλή | Επόμενο step μετά τη διπλωματική |
| Sub-agent αλλάζει άλλο κεφάλαιο | Χαμηλή | Υψηλή | Σαφής απαγόρευση στο prompt |
| Git conflicts μεταξύ parallel agents | Μεσαία | Μεσαία | Commits με δικά τους chapter prefixes· διαφορετικά section του αρχείου |
