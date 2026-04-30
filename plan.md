# Πλάνο Διπλωματικής Εργασίας: Πάγκος Εργασίας Εκπομπών Maersk

## Στόχοι του πλάνου

- **Στόχος μεγέθους:** 80-100 σελίδες A4, 12pt, mainfont Arial (όπως ορίζεται ήδη στο `gkinis_konstantinos.md`)
- **Αναλογία περιεχομένου:** ~10% κώδικας/listings (περίπου 8-10 σελίδες), ~10-15% εικόνες/διαγράμματα, ~75-80% κείμενο (θεωρία/περιγραφή σε ίσες αναλογίες)
- **Γλώσσα:** Ελληνικά
- **Ύφος:** Διπλωματική Master, αντικειμενικό, τεκμηριωμένο, με τεχνική ακρίβεια. Διατηρείται το ύφος του υπάρχοντος κειμένου: σαφή θεωρητικά εισαγωγικά πριν τα τεχνικά, κάθε επιλογή τεχνολογίας/μεθόδου τεκμηριωμένη με αιτιολόγηση.
- **Συγγραφή:** Παράλληλα 3 sonnet sub-agents τη φορά, ένας ανά κεφάλαιο. Ένας commit ανά υποκεφάλαιο.

## Πηγές πληροφορίας

- `presentations/ETPlatformTechMeet2025.pdf` — επίσημη παρουσίαση πυλώνων
- `presentations/Nix Workshop.md` — εσωτερικό workshop για Nix (χρήσιμο για κεφ. τεχνολογίες)
- `nrg/README.md` — επισκόπηση μονο-αποθετηρίου
- `nrg/guides/` — όλη η εσωτερική τεκμηρίωση (clean architecture, code style, observability, security, dremio, etw, people-operations)
- `nrg/components/emissions_workbench/` — κύρια εφαρμογή (56 LiveViews, 11 contexts)
- `nrg/components/bunker/` — BOPS / BoW
- `nrg/components/ocean/` — vessel master data + EU ETS
- `nrg/components/eco_products/` — placeholder, πραγματικός κώδικας στο emissions_workbench
- `nrg/components/net_zero/` — placeholder
- `nrg/alerts/` — observability alerts as code
- `nrg/flake.nix`, `nrg/team.json` — υποδομή/ομάδα
- Υπάρχον κείμενο στο `gkinis_konstantinos.md` (~46KB) — ενσωματώνεται και επεκτείνεται

## Δομή κεφαλαίων και κατανομή σελίδων

| # | Κεφάλαιο | Σελίδες | Σύνολο |
|---|----------|---------|--------|
| 1 | Εισαγωγή | 3-4 | 4 |
| 2 | Πλαίσιο και πρόβλημα | 8-9 | 13 |
| 3 | Θεωρητικό υπόβαθρο: Λογιστική αερίων θερμοκηπίου | 8-10 | 23 |
| 4 | Ο Πάγκος Εργασίας Εκπομπών: Επισκόπηση | 4-5 | 28 |
| 5 | Πυλώνας Α: Ocean Emissions και STAR Connect | 9-11 | 39 |
| 6 | Πυλώνας Β: ECO Product Delivery και πιστοποιητικά | 9-10 | 49 |
| 7 | Πυλώνας Γ: Bunker Optimization (Energy Markets) | 7-8 | 57 |
| 8 | Τεχνολογίες | 11-13 | 70 |
| 9 | Αρχιτεκτονική του συστήματος | 12-14 | 84 |
| 10 | Εργασιακές μέθοδοι | 9-11 | 95 |
| 11 | Συμπεράσματα | 3 | 98 |
| 12 | Μελλοντική εργασία | 2 | 100 |
| 13 | Βιβλιογραφία | 2-3 | 103 |

**Σύνολο: 87-104 σελίδες** (εντός στόχου).

---

## Κεφ. 1 — Εισαγωγή (3-4 σελίδες)

**Σκοπός:** Σύντομη παρουσίαση του πλαισίου και των στόχων της εργασίας.

### 1.1 Πλαίσιο
- Maersk: μια από τις μεγαλύτερες εταιρείες ναυτιλίας/logistics παγκοσμίως
- Ο τομέας της ναυτιλίας ως υπεύθυνος για ~3% παγκόσμιων εκπομπών CO₂
- Πίεση από ρυθμιστικό πλαίσιο (CSRD, EU ETS Maritime, Fuels EU Maritime, IMO)

### 1.2 Στόχος της εργασίας
- Παρουσίαση του Πάγκου Εργασίας Εκπομπών (Emissions Workbench / NRG)
- Περιγραφή τεχνολογιών, αρχιτεκτονικής και μεθόδων ανάπτυξης
- Συνεισφορές: σχεδιαστικές αποφάσεις, τεχνικά μαθήματα

### 1.3 Δομή του κειμένου
- Σύντομη επισκόπηση κάθε κεφαλαίου

**Πηγές:** `presentations/ETPlatformTechMeet2025.pdf`, υπάρχον intro στο `gkinis_konstantinos.md`

---

## Κεφ. 2 — Πλαίσιο και πρόβλημα (8-9 σελίδες)

**Σκοπός:** Να εξηγήσει γιατί χρειάστηκε το λογισμικό. Επεκτείνει το υπάρχον κεφάλαιο "Η ανάγκη δημιουργίας του Πάγκου Εργασίας Εκπομπών".

### 2.1 Η Maersk και ο τομέας της θαλάσσιας μεταφοράς
- Σύντομο profile εταιρείας, μέγεθος στόλου, εμπορική παρουσία
- Συνεισφορά της ναυτιλίας στις παγκόσμιες εκπομπές

### 2.2 Ο στόχος Net Zero 2040
- Στόχος Maersk: καθαρές μηδενικές εκπομπές μέχρι το 2040 (10 χρόνια πριν τον στόχο IMO 2050)
- 30% βιώσιμη ενέργεια χρήσης μέχρι το 2030
- Μετάβαση στόλου σε εναλλακτικά καύσιμα (μεθανόλη, αμμωνία, βιοκαύσιμα)

### 2.3 Ρυθμιστικό πλαίσιο
- **CSRD (Corporate Sustainability Reporting Directive)**: υποχρέωση EU
- **EU ETS Maritime**: επέκταση συστήματος εμπορίας εκπομπών στη ναυτιλία (2024)
- **Fuels EU Maritime**: ποιοτικοί στόχοι για καύσιμα
- **IMO**: στόχοι μείωσης εκπομπών

### 2.4 Η προηγούμενη χειρωνακτική διαδικασία (επέκταση υπάρχοντος)
- Email προς Emissions Reporting Team
- Manual εξαγωγή shipment data, manual εφαρμογή emissions
- Excel-based, βδομάδες/μήνες καθυστέρηση
- Σφάλματα κανονικοποίησης, αντιφάσεις, μη επαναληψιμότητα

### 2.5 Ομάδες χρηστών (1000+)
- ECO Delivery Ocean Products
- Regional Product Management
- Commercial Sustainability
- Regional Sales
- Contract Management
- Account Managers
- Πώς ο καθένας χρησιμοποιεί δεδομένα εκπομπών

### 2.6 Ο εσωτερικός έλεγχος GIA του 2023
- Ζητήματα που αναδείχθηκαν (data tracking, audit concerns, scalability)
- Αντιμετώπιση μέσω του νέου λογισμικού

**Πηγές:** PDF presentation slides 9-11, υπάρχον κείμενο, διαδικτυακή αναζήτηση για ρυθμιστικά
**Στοιχεία προς ενσωμάτωση:** 1300+ users, $31M USD ECO Delivery 2024, 98K FFE

---

## Κεφ. 3 — Θεωρητικό υπόβαθρο: Λογιστική αερίων θερμοκηπίου (8-10 σελίδες)

**Σκοπός:** Πλαίσιο θεωρητικής γνώσης για να γίνουν κατανοητά τα τεχνικά κεφάλαια. Επεκτείνει το υπάρχον "Μέτρηση εκπομπών CO₂".

### 3.1 Το πρωτόκολλο GHG (Greenhouse Gas Protocol)
- Ιστορικό (Kyoto 1997, GHGP από 2001)
- Συνθήκη του Κυότο και τα 6 κύρια αέρια
- Διεθνής υιοθέτηση και τυποποίηση

### 3.2 Κατηγορίες εκπομπών (Scopes)
- Scope 1: άμεσες εκπομπές (στόλος, καύσιμα)
- Scope 2: έμμεσες από αγορά ενέργειας
- Scope 3: ανώτερη/κατώτερη αλυσίδα αξίας (15 categories)
- Συνέπεια: Maersk → Scope 1 (ίδιος στόλος), Scope 3 (chartered vessels)
- Επεξήγηση εικόνας `Carbon_Accounting_Scopes.png`

### 3.3 Μεθοδολογίες μέτρησης
- **Cost-based**: απλή, δευτερογενή δεδομένα, χαμηλή ακρίβεια
- **Activity-based**: κατανομή ανά πραγματική δραστηριότητα, μέγιστη ακρίβεια
- **Hybrid**: συνδυασμός — η επιλογή της Maersk

### 3.4 TTW vs WTW
- Tank-to-Wheel (καύση επί του πλοίου)
- Well-to-Wheel (συνολικός κύκλος ζωής καυσίμου)
- Πότε χρησιμοποιείται κάθε ένας

### 3.5 Mass Balance και Book-and-Claim
- Φυσική ροή vs λογιστική ροή
- Παραδείγματα από άλλες βιομηχανίες (πχ πράσινη ηλεκτρική ενέργεια)
- Πώς πιστοποιείται

### 3.6 Πρότυπα και πιστοποιήσεις
- ISCC (International Sustainability and Carbon Certification)
- SBTi (Science Based Targets initiative)
- GLEC Framework (Global Logistics Emissions Council)
- Proof of Sustainability (POS) έγγραφα

**Πηγές:** GHG Protocol website (web search), υπάρχον κείμενο, ISCC docs, SBTi guides

---

## Κεφ. 4 — Ο Πάγκος Εργασίας Εκπομπών: Επισκόπηση (4-5 σελίδες)

**Σκοπός:** Υψηλού επιπέδου επισκόπηση πριν τα τεχνικά κεφάλαια.

### 4.1 Στόχοι και αποστολή ομάδας ET Platform
- Citation από PDF: «Ensure Maersk realises our Net Zero 2040 targets by providing definitive emissions data and technology services...»
- Από Σεπ. 2023 παραγωγική χρήση
- Άρχισε Μαρ. 2023

### 4.2 Οι τέσσερις πυλώνες
- Σύντομη παρουσίαση καθενός με την αποστολή του:
  - Ocean Emissions (decarbonisation roadmaps)
  - ECO Product Delivery (30% βιώσιμη ενέργεια έως 2030)
  - Energy Markets (bunker optimization, ETS)
  - Customer Baseline Emissions / Certificates
- Σχέσεις μεταξύ τους

### 4.3 Επιτεύγματα και αντίκτυπος
- 1300+ χρήστες (από 1000+ pre-launch)
- 98K FFE / $31M USD ECO Delivery 2024
- Αντιμετώπιση 2023 GIA audit
- Αυτόματη παραγωγή πιστοποιητικών ECOv1/v2

### 4.4 Επισκόπηση χαρακτηριστικών
- Self-service web app
- Εκδόσεις πιστοποιητικών
- Excel exports
- Real-time dashboards

**Πηγές:** PDF presentation, README του NRG

---

## Κεφ. 5 — Πυλώνας Α: Ocean Emissions και STAR Connect (9-11 σελίδες)

**Σκοπός:** Λεπτομερής περιγραφή του πιο σύνθετου πυλώνα.

### 5.1 Πρόκληση: Ακριβής καταγραφή εκπομπών στόλου
- Πολυπλοκότητα ναυτιλίας (διάφορα προϊόντα, lanes, container types)
- Διαφορετικά δεδομένα για owned vs chartered vessels

### 5.2 Πηγές δεδομένων
- **Dremio data lake**: Enterprise data warehouse (`Infrastructure_GDA.Energy_Transition.*`)
- **Shiptech**: legacy maritime order system (ODBC)
- **Kafka streams**: real-time events
- Container moves: data structure (size, type, FFE, lane, ETA)

### 5.3 Vessel master data (ocean_api)
- Vessel schema (IMO, name, ownership, flag_state)
- GenServer-based API με `:pg` clustering
- Παραδείγματα queries

### 5.4 STAR Connect: Real-time τηλεμετρία
- Τι είναι το STAR Connect (Maersk vessel telematics)
- Παραδείγματα δεδομένων: RemainingFuelOnBoard ανά τύπο (HSFO, VLSFO, LSDIS, ULSFO, μεθανόλη)
- Ροή: STAR Connect → Kafka → BoW external_data_feeds
- Κανονικοποίηση τύπων καυσίμου (`starconnect_fuel_type_to_bow`)
- Σύνδεση με fuel consumption και emissions calculation

### 5.5 Υπολογισμός εκπομπών
- Trade Factors (route_code × container_size × product × year)
- `Nrg.Ocean.EmissionsCalculator`
- Container FFE × Emissions Factor → TTW/WTW emissions

### 5.6 EU ETS surcharges
- Πώς υπολογίζονται οι χρεώσεις πελάτη
- Read-only από Dremio (`EUETSEmissionsTradeFactor`, `EUETSEmissionsSurcharge`, `EUETSPriceHistory`)
- Quarterly validity (Q1-Q4)

### 5.7 Customer Baseline Emissions
- Αναζητήσεις χρήστη ανά πελάτη/route/timeframe
- Reports για baseline emissions
- LiveView UI για το feature

**Πηγές:** `nrg/components/ocean/`, `nrg/components/emissions_workbench/lib/nrg/ocean/`, `nrg/components/bunker/bow/lib/bops/external_data_feeds/remaining_fuel_on_board.ex`

---

## Κεφ. 6 — Πυλώνας Β: ECO Product Delivery (9-10 σελίδες)

**Σκοπός:** Η πιο εμπορικά καίρια λειτουργικότητα.

### 6.1 Τι είναι τα ECO Products
- ECO Delivery Ocean: μεταφορά με εναλλακτικά καύσιμα
- Customer value proposition

### 6.2 ECOv1 vs ECOv2
- ECOv1: CO₂ basis, απόλυτες διαφορές, full grey emissions − green emissions
- ECOv2: CO₂e basis, ποσοστιαία savings (`ttw_emissions_savings_percentage * green_fuel_percentage`)
- Πότε επιλέγεται κάθε ένα

### 6.3 Energy Bank: λογιστική πράσινου καυσίμου
- Πρόκληση: ισοζύγιο μεταξύ αγοράς και πώλησης πράσινου καυσίμου
- **Event Sourcing και CQRS**:
  - Commands → Events → Projections
  - Επαληθευσιμότητα ιστορικού
  - EventStore backend
- Deposits (από fuel orders)
- Withdrawals (από shipments)
- Clearing accounts

### 6.4 Proof of Sustainability (POS) και ISCC
- Έγγραφα POS από προμηθευτές
- ISCC certification chain
- `MatchedPos`: αντιστοίχηση shipment → POS

### 6.5 Έκδοση πιστοποιητικών
- Δομή πιστοποιητικού (concern, year, FFE, savings)
- PDF generation
- Azure Blob Storage για archival
- Reissue logic όταν αλλάζουν δεδομένα
- Void με reason

### 6.6 ECO Delivery Surcharges
- Cost of Abatement
- Formula: `grey_fuel_used * green_fuel_price_foe` ή `wtw_savings * abatement_cost`

**Πηγές:** `nrg/components/emissions_workbench/lib/energy_bank.ex`, `lib/nrg/products/eco.ex` και `eco2.ex`, `lib/nrg/ocean/certificates.ex`, `lib/eco_delivery_surcharges/`

---

## Κεφ. 7 — Πυλώνας Γ: Bunker Optimization (Energy Markets) (7-8 σελίδες)

**Σκοπός:** Κάλυψη ξεχωριστού subsystem (BOPS) με διαφορετική φύση.

### 7.1 Το πρόβλημα ανεφοδιασμού
- Πολυπλοκότητα: πολλά λιμάνια, διαφορετικές τιμές, ETS κόστη
- Στόχος: ελάχιστο κόστος ανά voyage
- Ταυτόχρονα προγραμματισμός για green fuel sourcing

### 7.2 BOPS (Bunker Operations Planning System)
- Αρχιτεκτονική: API + BoW + C++ solver (MBC)
- Ροή: Shiptech → API → BoW → operator → Solver → BoW → Shiptech writeback

### 7.3 BoW: Bunker on Water Workbench
- Web UI για bunker plans
- LiveView interface
- Operator edits και approval workflow

### 7.4 C++ Solver μέσω Erlang Ports
- Linear programming για βελτιστοποίηση κόστους
- Επικοινωνία Elixir ↔ C++ via Erlang Ports
- Γιατί όχι NIFs (αξιοπιστία)

### 7.5 Shiptech integration
- VesselVoyagedetailId, port_calls
- Stored procedures (`sp_CreateModelRunDataWithString`, `sp_UpdateBunkerPlanOperatorInputs`)

### 7.6 Plan run scheduling
- `PlanRunEnqueuer`
- Triggers (manual, scheduled)

### 7.7 Σύνδεση με ETS και green fuel
- Bunker plan ως foundation για ETS optimization
- Πώς θα επεκταθεί για green fuels (μελλοντικό)

**Πηγές:** `nrg/components/bunker/`, README.md, code/tests

---

## Κεφ. 8 — Τεχνολογίες (11-13 σελίδες)

**Σκοπός:** Λεπτομερής τεκμηρίωση κάθε επιλογής τεχνολογίας. Επεκτείνει σημαντικά το υπάρχον "Τεχνολογία".

### 8.1 BEAM, Erlang, Elixir
- Ιστορικό BEAM (Ericsson, Erlang)
- Elixir vs Erlang (συντακτικό, OTP)
- **Πλεονεκτήματα BEAM**:
  - Lightweight processes (10000s ταυτόχρονα)
  - Preemptive scheduler
  - "Let it crash" philosophy και supervision trees
  - Hot code reloading
- **Πλεονεκτήματα Elixir**:
  - Functional, immutable
  - Pattern matching
  - Pipeline operator (`|>`)
- Παράδειγμα κώδικα: pipeline επεξεργασίας δεδομένων

### 8.2 Phoenix Framework & LiveView
- Σχεδιαστική φιλοσοφία (Rails-inspired)
- Generators (μειώνουν boilerplate)
- **LiveView**:
  - Server-rendered, με ασύγχρονες ενημερώσεις
  - WebSocket transport
  - PubSub για real-time UI
  - Πλεονεκτήματα έναντι SPA frameworks

### 8.3 PostgreSQL & Ecto
- Γιατί PostgreSQL
- Ecto: query builder, migrations, schemas
- Ξεχωριστές βάσεις ανά context (multi-tenancy)
- Παράδειγμα schema/query

### 8.4 Apache Kafka
- Message broker / event streaming
- Χρήση: STAR Connect feeds, ocean emissions ingestion
- Producer/Consumer patterns σε Elixir

### 8.5 Dremio
- Federated SQL για data lake
- Maersk Enterprise Data Warehouse
- Authentication via personal access tokens
- Streaming queries σε Elixir

### 8.6 ODBC integrations
- Για legacy συστήματα (Shiptech)
- BEAM ODBC adapter
- Παράδειγμα query

### 8.7 Microsoft Azure
- Cloud platform choice
- Resources: Postgres Flexible Server, AKS, Key Vault, Logic Apps, Blob Storage
- 2 environments: staging + production

### 8.8 Kubernetes
- Container orchestration
- 3 replicas web server
- Akamai load balancer + reverse proxy
- Επανεκκίνηση και scaling

### 8.9 Terraform
- Infrastructure as Code
- 4 περιβάλλοντα BOPS, αυτόνομο για NRG
- 34+ azurerm resource types
- Παράδειγμα module

### 8.10 Nix και nix-darwin
- Reproducible dev environment
- Flakes (declarative dependencies)
- Home Manager (user config)
- Direnv για auto-loading
- Σύνδεση με Nix Workshop παρουσίαση

### 8.11 GitHub Actions και Custom Runner
- 23+ workflows
- Custom NixOS runner στο Azure
- 32 deploys/ημέρα
- Workflow examples (build, test, IaC scan, security)

### 8.12 Maersk Design System (MDS)
- Web components
- Brand consistency
- Storybook ως reference

### 8.13 Observability stack
- **Logs**: Grafana Loki + LogQL
- **Metrics**: PromEx + Prometheus + Grafana
- **Traces**: OpenTelemetry → OpenObserve
- **MOP** (Maersk Observability Platform)
- Πώς συνδέεται με alerts (επόμενο)

### 8.14 HashiCorp Vault & agenix
- Secrets management
- AppRole auth (CI/CD)
- agenix για declarative secrets via Nix

### 8.15 Oban
- Background jobs σε PostgreSQL
- Retry logic, scheduled jobs
- Παράδειγμα workflow (certificate reissue)

### 8.16 EventStore
- Event sourcing για Energy Bank
- CQRS pattern
- Παράδειγμα command/event

**Πηγές:** Όλα τα guides, υπάρχον κείμενο, web search για βιβλιογραφικές αναφορές

---

## Κεφ. 9 — Αρχιτεκτονική του συστήματος (12-14 σελίδες)

**Σκοπός:** Σύνδεση των τεχνολογιών σε ολοκληρωμένη αρχιτεκτονική.

### 9.1 Επισκόπηση συστήματος
- Διάγραμμα `system_overview_diagram.png` με αναλυτικές περιγραφές
- Logical και physical view

### 9.2 Clean Architecture στην πράξη
- Στρώματα: Entities → Use Cases → Adapters → Frameworks
- Polymorphic Gateway interfaces
- Humble Object pattern σε boundaries
- Παράδειγμα: Certificates feature ως case study

### 9.3 Monorepo οργάνωση
- Workspace + Mix umbrella
- Components: emissions_workbench, bunker, ocean, eco_products, net_zero
- Affected app detection για incremental builds

### 9.4 Components και τα όριά τους
- DAG εξαρτήσεων
- Internal vs public APIs
- Όρια: τι κάνει το καθένα, τι δεν κάνει

### 9.5 Data ingestion pipeline
- **Polling sources**: Dremio (ODBC streaming), Shiptech (ODBC)
- **Streaming**: Kafka consumers (OceanEmission.Ingestion.KafkaConsumer)
- **Job processing**: Oban workers
- Staging tables → enrichment → main tables
- Idempotency και exactly-once semantics

### 9.6 Web layer
- LiveView modules ανά feature area
- MDS components
- Στατικά assets

### 9.7 Authentication & Authorization
- SAML SSO με Azure AD
- AD groups (πχ "SBTi Developers")
- Role-based access control
- Privileged Identity Management (PIM) για production

### 9.8 Persistence layer
- PostgreSQL Flexible Server (Azure)
- Multiple databases ανά context
- Backup/restore strategy
- Data Protection backup vault

### 9.9 Event sourcing για Energy Bank
- Commands → Aggregates → Events → Projections
- Event versioning
- Re-projection για new read models

### 9.10 Observability αρχιτεκτονική
- Telemetry events σε όλη τη ροή
- Trace propagation
- Alerts as code (`/alerts/`)
  - 13+ rules: CrashLoop, ETW concurrency, DB storage, data freshness, Oban failures
  - Loki-based για log alerts
- Hedwig για notifications

### 9.11 Deployment topology
- 3 replicas Phoenix
- Akamai → Stargate → Kubernetes
- Rolling deployments
- Migrations strategy

### 9.12 Disaster recovery & reproducibility
- Terraform για full system rebuild
- Nix για reproducible builds
- Database backups + restore tests (weekly automated)
- Disaster scenarios και RTO/RPO

**Πηγές:** Όλα τα code & guides

---

## Κεφ. 10 — Εργασιακές μέθοδοι (9-11 σελίδες)

**Σκοπός:** Εκτεταμένη επανασύνταξη του υπάρχοντος "Εργασιακές μέθοδοι".

### 10.1 Agile και Extreme Programming (XP)
- Σύντομο ιστορικό XP (Kent Beck, 1996)
- Αξίες: Communication, Simplicity, Feedback, Courage, Respect
- Σύγκριση με Scrum (γιατί XP)

### 10.2 Pair Programming
- Επέκταση υπάρχοντος
- Ρόλοι (driver/navigator)
- Tools (Tuple)
- Εμπειρικά αποτελέσματα από την ομάδα
- Mob programming και πότε χρησιμοποιείται

### 10.3 TDD (Test Driven Development)
- Επέκταση υπάρχοντος
- Red-Green-Refactor cycle
- Property-based testing (`ExUnitProperties`)
- Acceptance tests
- Test coverage culture

### 10.4 Continuous Integration / Continuous Delivery
- Επέκταση υπάρχοντος
- Trunk-based development (single branch)
- 32 deploys/ημέρα μέσος όρος
- Custom GitHub runner
- Feature flags / dark launching (αν εφαρμόζεται)
- Rollback strategy

### 10.5 Vertical Ownership
- Επέκταση υπάρχοντος
- Δραστηριότητες ομάδας: hardware, network, DBs, code, ops, observability, UI/UX
- Σύγκριση με horizontal teams
- Πλεονεκτήματα/μειονεκτήματα

### 10.6 Feedback Loops
- Επέκταση υπάρχοντος (εικόνα `Extreme_Programming_Loops.png`)
- Από δευτερόλεπτα (pairing) → λεπτά (tests) → ημέρα (standup) → εβδομάδες (planning) → μήνες (στρατηγική)
- Ασύγχρονη feedback collection

### 10.7 Onboarding & Knowledge Sharing
- Buddy system
- Week 1 / Week 2 milestones
- KT sessions
- Tools για κατανεμημένη ομάδα (23+ developers, Ευρώπη/Ινδία)

### 10.8 Code Review μέσω pairing
- Γιατί δεν χρησιμοποιούνται PRs (συνήθως)
- Εξαιρέσεις: external contributions, security review

**Πηγές:** Υπάρχον κείμενο, `nrg/guides/people-operations/`, `tech/code-style.md`

---

## Κεφ. 11 — Συμπεράσματα (3 σελίδες)

### 11.1 Σύνοψη της λύσης
- Τι προβλήματα λύνει
- Πώς

### 11.2 Επιτυχίες και μετρήσεις αντίκτυπου
- 1300+ users, 98K FFE, $31M USD
- Audit compliance
- Operational metrics

### 11.3 Μαθήματα από την υλοποίηση
- Τεχνικές επιλογές που λειτούργησαν
- Trade-offs
- Τι θα γινόταν διαφορετικά

---

## Κεφ. 12 — Μελλοντική εργασία (2 σελίδες)

### 12.1 Scope 2 measurements
- Programmed για 2025
- Πεδίο εφαρμογής

### 12.2 Επεκτάσεις στόλου
- Land-side reporting (trucks, terminals)
- Air freight emissions

### 12.3 SBTi reporting expansion
- Net Zero progress tracking

### 12.4 Προηγμένα analytics
- Πρόβλεψη εκπομπών
- Decarbonization scenarios

---

## Κεφ. 13 — Βιβλιογραφία (2-3 σελίδες)

**Σημείωση:** Συμπληρώνεται σε επόμενο βήμα. Αρχικοί υποψήφιοι:
- GHG Protocol (corporate standard, scope 3 standard)
- Kent Beck — Extreme Programming Explained
- Joe Armstrong — Programming Erlang
- Saša Jurić — Elixir in Action
- Robert Martin — Clean Architecture
- Greg Young — CQRS / Event Sourcing
- ISCC documentation
- SBTi maritime sector guidance
- IMO GHG strategy
- EU ETS Maritime regulations

---

## Οδηγίες προς sub-agents συγγραφής

Κάθε sub-agent θα λάβει:

1. **Brief του κεφαλαίου** (το αντίστοιχο τμήμα από αυτό το πλάνο)
2. **Πηγές προς ανάγνωση** (συγκεκριμένα paths)
3. **Στόχος σελίδων**
4. **Style guide**:
   - Διπλωματική Master, Ελληνικά
   - Mainfont Arial 12pt
   - Τεκμηρίωση κάθε σχεδιαστικής επιλογής
   - Σαφή θεωρητικά εισαγωγικά πριν τα τεχνικά
   - Ορολογία αγγλική σε παρένθεση όπου εμφανίζεται για πρώτη φορά
5. **Υπάρχον κείμενο**: τμήματα του `gkinis_konstantinos.md` που θα ενσωματωθούν/αντικατασταθούν
6. **Commit policy**:
   - Έπειτα από κάθε υποκεφάλαιο, commit στο git
   - Conventional message: `Κεφ. X.Y: <τίτλος>` ή αγγλικά `Chapter X.Y: ...`
7. **Code listings**: αυτούσια από το repo (όχι abstractions), με path comment, ≤ 30 γραμμές ανά listing
8. **Διαγράμματα**: προτείνονται mermaid ή textual descriptions (αργότερα γίνονται εικόνες)

## Κατανομή κεφαλαίων σε 3-parallel sub-agent batches

**Batch 1 (παράλληλα):**
- Κεφ. 2 — Πλαίσιο και πρόβλημα
- Κεφ. 3 — Θεωρητικό υπόβαθρο
- Κεφ. 4 — Επισκόπηση πάγκου εργασίας

**Batch 2 (παράλληλα):**
- Κεφ. 5 — Ocean Emissions
- Κεφ. 6 — ECO Product Delivery
- Κεφ. 7 — Bunker Optimization

**Batch 3 (παράλληλα):**
- Κεφ. 8 — Τεχνολογίες
- Κεφ. 9 — Αρχιτεκτονική
- Κεφ. 10 — Εργασιακές μέθοδοι

**Batch 4 (παράλληλα):**
- Κεφ. 1 — Εισαγωγή (γράφεται μετά για συνεκτικότητα)
- Κεφ. 11 — Συμπεράσματα
- Κεφ. 12 — Μελλοντική εργασία

**Επόμενο βήμα:** Βιβλιογραφία (Κεφ. 13).

## Ροή εργασίας με σταδιακή ολοκλήρωση

- Κάθε batch: 3 sub-agents τρέχουν παράλληλα
- Όταν ολοκληρωθεί ένας από το batch, ξεκινά ο επόμενος (από το επόμενο batch ή το ίδιο)
- Συνολικά 12 sub-agents για συγγραφή κεφαλαίων + 1 για βιβλιογραφία
- Κάθε agent commit-άρει τη δουλειά του ανά υποκεφάλαιο
- Στο τέλος γίνεται final pass για συνέπεια ύφους και cross-references

## Risk register

| Κίνδυνος | Μετριασμός |
|---------|-----------|
| Token overrun | Αποθήκευση progress σε `plan.md` και commits κάθε φάση |
| Επικαλύψεις μεταξύ κεφαλαίων | Σαφή όρια στο plan, cross-references |
| Τεχνικές ανακρίβειες | Αναφορά σε συγκεκριμένα paths· verification στο τέλος |
| Στυλιστική ασυνέπεια | Final editorial pass μετά τα batches |
| Έλλειψη βιβλιογραφικών αναφορών | Δεδομένη — γίνεται σε επόμενο βήμα |
