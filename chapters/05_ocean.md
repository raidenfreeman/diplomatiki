# Κεφάλαιο 5 — Πυλώνας Α: Ocean Emissions και STAR Connect

Ο πρώτος πυλώνας του ET Platform αφορά τη συλλογή, επεξεργασία και αποθήκευση εκπομπών για το σύνολο των θαλάσσιων μεταφορών της Maersk. Είναι ο θεμέλιος λίθος του συστήματος: χωρίς αξιόπιστα δεδομένα κινήσεων εμπορευματοκιβωτίων και πραγματικής κατανάλωσης καυσίμου, κανένας από τους υπόλοιπους πυλώνες — παράδοση ECO προϊόντων (Κεφ. 6), βελτιστοποίηση ανεφοδιασμού (Κεφ. 7) — δεν θα μπορούσε να λειτουργήσει. Το παρόν κεφάλαιο εξετάζει την πολυπλοκότητα του προβλήματος (5.1), τις πηγές δεδομένων (5.2), το σύστημα vessel master data (5.3), τη ροή πραγματικού χρόνου μέσω STAR Connect (5.4), τον αλγόριθμο υπολογισμού εκπομπών (5.5), την ενσωμάτωση του Ευρωπαϊκού Συστήματος Εμπορίας Εκπομπών (5.6) και τη λειτουργία Customer Baseline Emissions (5.7).

## 5.1 Πρόκληση: Ακριβής καταγραφή εκπομπών στόλου

Η Maersk διαχειρίζεται έναν στόλο άνω των 700 πλοίων και εκτελεί δεκάδες χιλιάδες δρομολόγια ετησίως, μεταφέροντας εμπορευματοκιβώτια σε διαφορετικά μεγέθη, τύπους και προϊόντα από εκατοντάδες λιμάνια σε 130+ χώρες. Η ακριβής καταγραφή εκπομπών σε αυτή την κλίμακα αντιμετωπίζει πλήθος προκλήσεων.

**Ετερογένεια εμπορευματοκιβωτίων.** Κάθε κίνηση εμπορευματοκιβωτίου (*container move*) χαρακτηρίζεται από το μέγεθός του — 20", 40", 45", 53" — και τον τύπο του — ξηρό φορτίο (*dry*) ή ψυγείο (*reefer*). Η μονάδα μέτρησης *FFE* (Forty-Foot Equivalent) αποτελεί τον κοινό κανονιστή: ένα 20" κοντέινερ αντιστοιχεί σε 0,5 FFE, ενώ ένα 40" ή 45" αντιστοιχεί σε 1 FFE. Τα ψυγεία καταναλώνουν περισσότερη ενέργεια λόγω ψύξης και απαιτούν διαφορετικούς συντελεστές εκπομπών.

**Πολυπλοκότητα προϊόντων.** Η Maersk προσφέρει εύρος ECO προϊόντων — EC2, EC3, EC4, EC5, ECM — που αντιστοιχούν σε διαφορετικές αναλογίες χρήσης πράσινου καυσίμου και διαφορετικές μεθοδολογίες υπολογισμού (ECOv1, ECOv2). Ένα συμβατικό *FOSSIL* προϊόν έχει πλήρεις εκπομπές γκρίζων καυσίμων, ενώ τα ECO προϊόντα φέρουν μερική ή πλήρη μείωση εκπομπών. Κάθε προϊόν εφαρμόζει διαφορετικό συντελεστή εκπομπών κατά τον υπολογισμό.

**Δυσκολία απόδοσης εκπομπών.** Σε ένα δρομολόγιο, ένα πλοίο μεταφέρει χιλιάδες κοντέινερ ταυτόχρονα. Οι εκπομπές πρέπει να κατανεμηθούν σε κάθε κίνηση εμπορευματοκιβωτίου με βάση εμπορικώς αποδεκτούς συντελεστές — τους *trade factors* — που έχουν προκαθοριστεί ανά εμπορική διαδρομή, κατεύθυνση και έτος. Αυτή η μέθοδος, αντί για ακριβές μέτρηση κατανάλωσης ανά κοντέινερ, αποτελεί πρακτική αναγκαιότητα δεδομένης της αδυναμίας φυσικής απόδοσης καυσίμου σε μεμονωμένες αποστολές.

**Ιδιοκτησιακό καθεστώς πλοίων.** Ο στόλος περιλαμβάνει πλοία υπό πλήρη ιδιοκτησία (Scope 1 εκπομπές), υπό ναύλωση (*chartered vessels*, Scope 3 κατηγορία 7) και υπό ναυλοσύμφωνο χρόνου. Κάθε κατηγορία αντιμετωπίζεται διαφορετικά στο GHG Protocol (βλ. Κεφ. 2.4 και 3.2), γεγονός που απαιτεί ευέλικτη λογική ταξινόμησης στο σύστημα.

**Κλίμακα δεδομένων.** Το `emissions_workbench` component, με 67.877 γραμμές κώδικα Elixir, καλύπτει 151 πίνακες βάσης δεδομένων και 499 migrations μόνο για αυτό το component. Το πρόβλημα εισαγωγής δεδομένων δεν είναι απλώς τεχνικό — απαιτεί συνεχή ευθυγράμμιση με αλλαγές στις upstream πηγές δεδομένων χωρίς διακοπή λειτουργίας.

## 5.2 Πηγές δεδομένων

Ο πυλώνας Ocean Emissions τροφοδοτείται από τρεις κύριες πηγές δεδομένων, καθεμία με διαφορετικά χαρακτηριστικά διαθεσιμότητας, εγκαιρότητας και δομής.

### 5.2.1 Dremio Data Lake

Το Dremio αποτελεί την κεντρική εταιρική πλατφόρμα ανάλυσης δεδομένων της Maersk και λειτουργεί ως κύρια πηγή batch δεδομένων για κινήσεις εμπορευματοκιβωτίων. Μέσω της Dremio, το σύστημα έχει πρόσβαση σε πολλαπλές βάσεις δεδομένων:

- `Infrastructure_GDA.Energy_Transition.*` — δεδομένα ενεργειακής μετάβασης, συντελεστές εκπομπών
- `EcoDelivery.ShipmentDetails` — λεπτομέρειες αποστολών ECO προϊόντων
- `Common_Datasets.*` — κοινές αναφορές (λιμάνια, διαδρομές, πελάτες)
- `Infrastructure_GDA.Energy_Transition.NetZero.EU_ETS.*` — δεδομένα EU ETS (βλ. 5.6)

Οι ερωτήματα εκτελούνται μέσω ενός αφαιρετικού στρώματος `Dremio.encode_sql/1` και `Dremio.stream/1`, που επιτρέπει *streaming* αποτελεσμάτων χωρίς φόρτωση ολόκληρου του resultset στη μνήμη — κρίσιμο για πίνακες εκατομμυρίων εγγραφών.

### 5.2.2 Shiptech

Το Shiptech είναι το legacy σύστημα διαχείρισης ναυτιλιακών εντολών και ταξιδιών της Maersk. Προσπελαύνεται μέσω ODBC και περιέχει ιστορικά δεδομένα δρομολογίων που δεν έχουν ακόμη μεταναστεύσει στο Dremio. Η πρόσβαση μέσω ODBC επιβάλλει ιδιαίτερη προσοχή στη διαχείριση συνδέσεων και το error handling.

### 5.2.3 Δομή κίνησης εμπορευματοκιβωτίου (ContainerMove)

Κάθε κίνηση εμπορευματοκιβωτίου μοντελοποιείται ως Ecto schema που αντικατοπτρίζει τον πίνακα `ocean_container_moves` στη βάση δεδομένων. Η δομή περιλαμβάνει τόσο τεχνικά χαρακτηριστικά του κοντέινερ όσο και επιχειρησιακά στοιχεία αποστολής:

```elixir
schema "ocean_container_moves" do
  field(:container_size, Ecto.Enum, values: Nrg.Ocean.Container.sizes())
  field(:container_type, Ecto.Enum, values: Nrg.Ocean.Container.types())
  field(:equipment_id, :string)
  field(:loaded_ffe, :decimal)
  field(:missing_in_dremio, :boolean)

  # these fields come from shipment data
  field(:first_loaded_at, :utc_datetime)
  field(:arrived_on, :date)
  field(:lane_id, :string)
  field(:test_id, :string)
  field(:deleted_at, :utc_datetime)

  timestamps()

  belongs_to(:customer, Customer)
  belongs_to(:shipment, Shipment)

  field(:port_of_receipt_location, :map, virtual: true)
  field(:port_of_discharge_location, :map, virtual: true)
end
```

*(Πηγή: `nrg/components/emissions_workbench/lib/nrg/ocean/container_move.ex`, γρ. 33-54)*

Αξίζει να σημειωθούν μερικές σχεδιαστικές επιλογές. Τα πεδία `container_size` και `container_type` ορίζονται ως `Ecto.Enum`, εξασφαλίζοντας ότι μόνο επιτρεπτές τιμές μπορούν να αποθηκευτούν — οι επιτρεπτές τιμές ορίζονται δυναμικά από τα `Nrg.Ocean.Container.sizes()` και `Nrg.Ocean.Container.types()`. Το πεδίο `missing_in_dremio` αποτελεί σήμα ποιότητας δεδομένων: αν μια κίνηση δεν βρεθεί στη Dremio, σημαίνεται ώστε να μη συμπεριληφθεί σε υπολογισμούς εκπομπών χωρίς χειροκίνητη αναθεώρηση. Τα πεδία `port_of_receipt_location` και `port_of_discharge_location` ορίζονται ως `virtual: true`, δηλαδή δεν αποθηκεύονται στη βάση αλλά εμπλουτίζονται κατά τη φόρτωση για χρήση στο UI ή σε υπολογισμούς. Τέλος, οι συσχετίσεις `belongs_to(:customer)` και `belongs_to(:shipment)` εξασφαλίζουν ακεραιότητα αναφοράς σε επίπεδο βάσης.

## 5.3 Vessel Master Data (ocean_api)

Η γνώση ποια πλοία ανήκουν στον στόλο, ποιο IMO number φέρουν και αν είναι ενεργά σε δεδομένη χρονική στιγμή, αποτελεί προαπαιτούμενο τόσο για τον υπολογισμό εκπομπών όσο και για τη σωστή αντιστοίχηση δεδομένων STAR Connect. Το component `nrg/components/ocean/ocean_api/` παρέχει ακριβώς αυτή τη λειτουργικότητα.

**Αρχιτεκτονική GenServer με `:pg`.** Το `OceanApi.VesselApi` υλοποιείται ως `GenServer` που εκκινεί με `start_link/1` και εγγράφεται σε process group μέσω `:pg.join(@name, self())`. Αυτή η επιλογή επιτρέπει σε πολλαπλές επαναλήψεις του server να τρέχουν ταυτόχρονα σε ένα distributed BEAM cluster: η `find_server/0` εντοπίζει ένα διαθέσιμο process, διανέμοντας φυσικά τη φόρτωση χωρίς explict load balancer (βλ. Κεφ. 9 για την κατανεμημένη αρχιτεκτονική).

**Δημόσιο API.** Οι τρεις κύριες συναρτήσεις που εκτίθενται είναι:
- `get_all_vessels/0` — επιστρέφει όλα τα γνωστά πλοία
- `all_active/0` — φιλτράρει μόνο ενεργά πλοία (χωρίς `deleted_at`)
- `find_by_imo/1` — αναζήτηση βάσει IMO number

Κάθε `Vessel` φέρει τουλάχιστον: αριθμό IMO, ονομασία πλοίου, καθεστώς ιδιοκτησίας (*ownership*), *flag state* (σημαία) και κατάσταση. Η αντιστοίχηση με το `Bops.ExternalDataFeeds.RemainingFuelOnBoard` γίνεται μέσω `imo_number`, πεδίου κοινού και στις δύο δομές.

**Σχέση με STAR Connect.** Κάθε μέτρηση STAR Connect φθάνει με ένα `imo_number`. Το `ocean_api` παρέχει την αρχή αλήθειας για τη σχέση IMO → vessel record, επιτρέποντας τον εμπλουτισμό των δεδομένων RoB με τα master data του πλοίου πριν αποθηκευτούν.

## 5.4 STAR Connect: Real-time Τηλεμετρία Καυσίμων

### 5.4.1 Τι είναι το STAR Connect

Το *STAR Connect* είναι η εσωτερική πλατφόρμα τηλεμετρίας πλοίων της Maersk. Ενσωματώνει αισθητήρες και συστήματα αυτοματισμού από τη μηχανοστάσιο κάθε πλοίου, αποστέλλοντας σε τακτά διαστήματα μετρήσεις πραγματικού χρόνου — μεταξύ άλλων, το *Remaining Fuel On Board* (RoB), δηλαδή τη ποσότητα καυσίμου που απομένει στις δεξαμενές του πλοίου, ανά τύπο καυσίμου.

Αυτά τα δεδομένα είναι πολύτιμα για δύο λόγους: αφενός επιτρέπουν υπολογισμό της κατανάλωσης ανά voyage (ΔRoB = RoB_αρχή − RoB_τέλος), αφετέρου τροφοδοτούν τα bunker plans με πληροφορίες για τη διαθέσιμη ποσότητα καυσίμου πριν από τον επόμενο ανεφοδιασμό (βλ. Κεφ. 7 για τον πυλώνα Bunker Optimization).

### 5.4.2 Ροή δεδομένων: STAR Connect → Kafka → BoW

Η αρχιτεκτονική ενσωμάτωσης ακολουθεί ένα *event-driven* μοντέλο με Kafka ως μεσίτη μηνυμάτων (*message broker*):

```
STAR Connect (vessel sensors)
        ↓
  Kafka topic (per-vessel partition)
        ↓
  Bops.ExternalDataFeeds.RemainingFuelOnBoard
  (BoW consumer — bunker/bow component)
        ↓
  PostgreSQL table: remaining_fuel_on_board
```

Η επιλογή του Kafka δικαιολογείται από πολλαπλές απαιτήσεις. Πρώτον, η ασύγχρονη ροή (*backpressure*) εξασφαλίζει ότι παροδικές καθυστερήσεις στην επεξεργασία δεν οδηγούν σε απώλεια μηνυμάτων — το Kafka αποθηκεύει τα events μέχρι να τα επεξεργαστεί ο consumer. Δεύτερον, η διάταξη ανά partition εξασφαλίζει ότι τα μηνύματα ενός πλοίου επεξεργάζονται με σωστή χρονολογική σειρά, κρίσιμο για σωστό υπολογισμό ΔRoB. Τρίτον, το Kafka επιτρέπει πολλαπλούς *consumers* στο ίδιο topic χωρίς αλληλεπικάλυψη — αυτή η ιδιότητα επιτρέπει τόσο στο BoW (bunker) όσο και σε μελλοντικά components να καταναλώνουν τα ίδια δεδομένα ανεξάρτητα (βλ. Κεφ. 8.4 για τη γενικότερη χρήση Kafka στην πλατφόρμα).

### 5.4.3 Δομή δεδομένων RemainingFuelOnBoard

Το Ecto schema `Bops.ExternalDataFeeds.RemainingFuelOnBoard` αποτυπώνει τη δομή κάθε μέτρησης RoB:

```elixir
schema "remaining_fuel_on_board" do
  field :imo_number, :integer
  field :period_end, :naive_datetime
  field :hsdis, Measurement.Ecto.Type, unit: :tonnes
  field :hsfo, Measurement.Ecto.Type, unit: :tonnes
  field :lsdis, Measurement.Ecto.Type, unit: :tonnes
  field :ulsfo, Measurement.Ecto.Type, unit: :tonnes
  field :vlsfo, Measurement.Ecto.Type, unit: :tonnes
  field :methanol, Measurement.Ecto.Type, unit: :tonnes
  field :other, Measurement.Ecto.Type, unit: :tonnes
  has_many :bunker_plans, Bops.BunkerPlans.BunkerPlan
  belongs_to :vessel, Bops.Vessels.Vessel
  timestamps()
end
```

*(Πηγή: `nrg/components/bunker/bow/lib/bops/external_data_feeds/remaining_fuel_on_board.ex`)*

Κάθε εγγραφή αντιστοιχεί σε μία χρονική στιγμή (`period_end`) για ένα συγκεκριμένο πλοίο (`imo_number`). Τα πεδία καυσίμων χρησιμοποιούν τον τύπο `Measurement.Ecto.Type` με μονάδα `:tonnes`, εξασφαλίζοντας type-safe μετατροπές μονάδων. Το εύρος καυσίμων καλύπτει όλους τους τύπους που χρησιμοποιεί ο στόλος: `hsdis` (High Sulfur Distillate), `hsfo` (High Sulfur Fuel Oil), `lsdis` (Low Sulfur Distillate), `ulsfo` (Ultra Low Sulfur Fuel Oil), `vlsfo` (Very Low Sulfur Fuel Oil) και `methanol`.

### 5.4.4 API πρόσβασης

Το module εκθέτει τρεις δημόσιες συναρτήσεις: `all/0` για ανάκτηση όλων των μετρήσεων, `store!/1` για εισαγωγή νέας μέτρησης από τον Kafka consumer και `for_vessel/1` που επιστρέφει την πιο πρόσφατη μέτρηση για δεδομένο IMO number — αυτή χρησιμοποιείται στη σελίδα *current bunker plan* για εμφάνιση του τρέχοντος RoB.

Η ίδια αυτή ροή τροφοδοτεί και τον πυλώνα Bunker Optimization (Κεφ. 7), καθώς το RoB αποτελεί κρίσιμο input για τον σχεδιασμό του επόμενου ανεφοδιασμού.

## 5.5 Υπολογισμός Εκπομπών

### 5.5.1 Trade Factors: ο πυρήνας της μεθοδολογίας

Ο υπολογισμός εκπομπών για κάθε κίνηση εμπορευματοκιβωτίου βασίζεται στους *trade factors* — προκαθορισμένους συντελεστές που αντιστοιχούν σε μια πλέγμα παραμέτρων:

```
συντελεστής = f(route_code, direction, container_size, container_type, product, year)
```

Οι συντελεστές αποθηκεύονται σε πίνακες `ocean_trade_factors_*` στη βάση δεδομένων και εισάγονται μέσω της `Nrg.Ocean.Ingest.OceanTradeFactors`. Κάθε συντελεστής φέρει τόσο TTW (*Tank-to-Wheel*) — εκπομπές μόνο από καύση — όσο και WTW (*Well-to-Wheel*) τιμή, που συμπεριλαμβάνει και τις εκπομπές παραγωγής και μεταφοράς καυσίμου (βλ. Κεφ. 3.4). Ο λόγος WTW/TTW κυμαίνεται από 1.0 έως ~1.4 ανάλογα με τον τύπο καυσίμου, με τα εναλλακτικά βιοκαύσιμα να εμφανίζουν μικρότερες διαφορές λόγω χαμηλότερων WTT εκπομπών.

### 5.5.2 EmissionsCalculator: η δημόσια API υπολογισμού

Το module `Nrg.Ocean.EmissionsCalculator` αποτελεί την κύρια *context* για τον υπολογισμό εκπομπών. Η κύρια συνάρτηση `get_ocean_emissions_for_route/N` δέχεται:

```elixir
get_ocean_emissions_for_route(
  route_code_and_direction,
  container_size,
  container_type,
  container_count,
  year,
  eco_product,
  ocean_factors_filter_options \\ Nrg.Ocean.Factors.list_filter_options()
)
```

Το αποτέλεσμα είναι ένα `EcoOceanLaneEmissionsModel` που περιέχει τόσο TTW όσο και WTW τιμές για τη δεδομένη διαδρομή και προϊόν, ήδη πολλαπλασιασμένες με τον αριθμό FFE. Η φόρμουλα υπολογισμού σε ψευδοκώδικα:

```
emissions_kg_ttw = loaded_ffe × ttw_factor(route, size, type, product, year)
emissions_kg_wtw = loaded_ffe × wtw_factor(route, size, type, product, year)
```

Ο `Nrg.Ocean.Container.equivalent_container_size_for_co2e/1` κανονικοποιεί ορισμένα μεγέθη πριν την αναζήτηση — για παράδειγμα, τα μεγέθη `:size45` και `:size53` αντιστοιχίζονται σε `:size40` για τους υπολογισμούς CO₂e, καθώς οι trade factors δεν διαθέτουν ξεχωριστό συντελεστή για αυτά τα μεγέθη.

### 5.5.3 Pipeline μετασχηματισμού εισαγωγής

Κατά την εισαγωγή δεδομένων, κάθε raw εγγραφή από τη Dremio μετασχηματίζεται σε domain objects μέσω του `Nrg.Ocean.Ingest.Converters`. Το pipeline χρησιμοποιεί την έκφραση `with` της Elixir για σαφή διαχείριση σφαλμάτων:

```elixir
def from_raw(%Ingest.RawOceanContainerMove{record: record}, to: :shipment_attrs) do
  with operator when not is_nil(operator) <- record["shipment_operator"],
       product when product != :unrecognized_product <-
         dremio_product_to_product(record["shipment_product"]) do
    {:ok,
     %{
       external_id: record["shipment_no"],
       operator: operator |> String.downcase(),
       status: shipment_status(record["shipment_status"]),
       product: product
     }}
  else
    nil ->
      {:error, :missing_shipment_operator}

    :unrecognized_product ->
      {:error, :unrecognized_product}
  end
end
```

*(Πηγή: `nrg/components/emissions_workbench/lib/nrg/ocean/ingest/converters.ex`, γρ. 55-73)*

Αυτή η δομή επιτυγχάνει αρκετά πράγματα ταυτόχρονα. Το `with` εκφράζει σειρά ελέγχων που πρέπει όλοι να επιτύχουν· αν οποιοσδήποτε αποτύχει, εκτελείται ο κλάδος `else` με ακριβή αιτιολογία σφάλματος. Η κανονικοποίηση `String.downcase()` στον `operator` εξασφαλίζει consistency σε case-insensitive αναζητήσεις αργότερα. Η μετατροπή `dremio_product_to_product/1` μεταφράζει τους κωδικούς προϊόντων της Dremio σε εσωτερικές τιμές `atom` — αν ο κωδικός δεν αναγνωρίζεται, επιστρέφει `:unrecognized_product` που ο `with` αντιμετωπίζει ως σφάλμα. Αυτό αποτρέπει την εισαγωγή εγγραφών με άγνωστα προϊόντα, που θα οδηγούσαν αργότερα σε λανθασμένους υπολογισμούς εκπομπών.

Μια παρόμοια λογική εφαρμόζεται στους converter για customer_attrs και consignee_attrs, δομώντας τη φάση εισαγωγής δεδομένων ως σειρά ανεξάρτητων μετασχηματισμών με αυστηρό error handling. Η υβριδική μεθοδολογία (βλ. Κεφ. 3.3.3) εφαρμόζεται εδώ στην πράξη: δεδομένα από Dremio και Shiptech χρησιμοποιούνται όπου είναι διαθέσιμα, ενώ οι trade factors καλύπτουν τα κενά.

## 5.6 EU ETS Surcharges

### 5.6.1 Ρυθμιστικό πλαίσιο

Από 1 Ιανουαρίου 2024, το Ευρωπαϊκό Σύστημα Εμπορίας Δικαιωμάτων Εκπομπών (*EU ETS — Emissions Trading System*) επεκτάθηκε στη ναυτιλία. Σύμφωνα με αυτό, τα ναυτιλιακά γραφεία διαχείρισης πλοίων υποχρεούνται να αγοράζουν *ευρωπαϊκά δικαιώματα εκπομπών* (*EUAs — European Union Allowances*) για ένα ποσοστό των εκπομπών CO₂ των πλοίων τους σε ευρωπαϊκά ύδατα. Το ποσοστό κλιμακώνεται: 40% το 2024, 70% το 2025 και 100% από το 2026 (βλ. Κεφ. 2.4).

Αυτό συνεπάγεται για τη Maersk ένα επιπλέον κόστος ανά voyage που πρέπει να μεταφράζεται σε surcharge για τους πελάτες. Η πρόκληση δεν είναι μόνο τεχνική — η τιμή του EUA αγοράς διαμορφώνεται δυναμικά και απαιτεί τριμηνιαία ενημέρωση των υπολογισμών.

### 5.6.2 Υλοποίηση στο NRG

Το component `nrg/components/ocean/eu_ets/` υλοποιεί την ολόκληρη λογική EU ETS surcharge. Η δεδομένα αντλούνται από τη Dremio μέσω τεσσάρων πινάκων:

- `EUETSEmissionsTradeFactor` — συντελεστές εκπομπών ανά διαδρομή/κατεύθυνση/τύπο κοντέινερ
- `EUETSEmissionsSurcharge` — το υπολογισμένο surcharge ανά trade lane
- `EUETSPriceHistory` — ιστορικό τιμών EUA για κάθε τριμηνιαία περίοδο
- `EUETSMetadata` — μεταδεδομένα εγκυρότητας και *run IDs* για audit trail

Η φόρμουλα υπολογισμού εφαρμόζεται ως:

```
ets_charge = emissions_kg × ETS_trade_factor × EUA_price_used
```

Ο βαθμός εισαγωγής στο ETS (40%/70%/100%) ενσωματώνεται στον `EUETSEmissionsTradeFactor`, ώστε η φόρμουλα να παραμένει απλή και ο πελάτης να βλέπει το τελικό charge χωρίς να χρειάζεται να γνωρίζει το κλιμακούμενο ποσοστό.

### 5.6.3 Τριμηνιαία εγκυρότητα και audit trail

Κάθε run υπολογισμού λαμβάνει μοναδικό *run ID*, αποθηκευμένο στο `EUETSMetadata`. Η λογική `determine_valid_quarters/1` αναλύει τα πεδία `ValidFrom`/`ValidTo` και παράγει μια εγγραφή ανά τρίμηνο εντός της περιόδου εγκυρότητας. Αυτό εξασφαλίζει ότι κάθε surcharge που χρεώθηκε σε πελάτη μπορεί να αντιστοιχιστεί σε συγκεκριμένο run ID, EUA τιμή και τρίμηνο — ακριβώς η διαφάνεια που απαιτεί ο έλεγχος GIA (βλ. Κεφ. 2.7).

Η φιλτράρισμένη ροή (`Stream.filter(&valid?/2)`) απορρίπτει εγγραφές με άκυρη κατάσταση `isPromoted`, καταγράφοντας παράλληλα μετρικά τηλεμετρίας μέσω `:telemetry.execute/3`. Αυτά τα μετρικά επιτρέπουν παρακολούθηση της αναλογίας valid/invalid εγγραφών κατά την εισαγωγή δεδομένων — πρακτική που ευθυγραμμίζεται με τις αρχές *observability* που αναλύονται στο Κεφ. 9.

Το EU ETS surcharge αποτελεί επίσης τη βάση για τα ETS-related κόστη στα ECO προϊόντα — ένα ECO προϊόν μπορεί να μειώνει τα ETS charges επειδή χρησιμοποιεί καύσιμα με χαμηλότερες εκπομπές. Η σύνδεση με τον πυλώνα ECO Delivery αναλύεται στο Κεφ. 6.

## 5.7 Customer Baseline Emissions

### 5.7.1 Σκοπός και λειτουργικότητα

Η λειτουργία *Customer Baseline Emissions* αποτελεί το κύριο σημείο επαφής μεταξύ του backend υπολογισμού εκπομπών και των χρηστών του συστήματος. Επιτρέπει σε account managers, στελέχη πωλήσεων και managers ECO προϊόντων να αναζητήσουν τις εκπομπές ενός συγκεκριμένου πελάτη για δεδομένη χρονική περίοδο.

Η λειτουργία υλοποιείται ως Phoenix LiveView, συνδυάζοντας διαδραστικό frontend με real-time ενημερώσεις χωρίς ανανέωση σελίδας. Ο χρήστης εισάγει τον κωδικό πελάτη (*concern code* ή *fact code*) και εύρος ημερομηνιών. Το σύστημα εκτελεί aggregated queries πάνω στον πίνακα `ocean_container_moves` σε join με `customers` και `shipments`, υπολογίζει και παρουσιάζει:

- Συνολικές εκπομπές WTW και TTW ανά τύπο προϊόντος
- Σύγκριση fossil baseline vs ECO actual εκπομπές
- Ποσοστό εξοικονόμησης εκπομπών (%)
- Κατανομή ανά lane, μέγεθος κοντέινερ και χρονική περίοδο

### 5.7.2 Backend: BaselineEmissionsReport

Το module `Nrg.Ocean.BaselineEmissionsReport` εκτελεί τις aggregated queries και κατασκευάζει το report model. Κεντρική λειτουργία είναι η επεξεργασία των `ContainerMoveEmissionsSummary` entries — ένα ενδιάμεσο data transfer object που ομαδοποιεί τις εκπομπές ανά διαδρομή και προϊόν.

Η αρχιτεκτονική ακολουθεί το pattern που ορίζεται στα εσωτερικά guides (*clean architecture*): η LiveView αναλαμβάνει αποκλειστικά presentation logic, ενώ το `BaselineEmissionsReport` διαχειρίζεται domain logic και queries. Αυτός ο διαχωρισμός επιτρέπει ανεξάρτητη δοκιμαστήριο (*unit testing*) του υπολογισμού εκπομπών χωρίς εξάρτηση από το web layer.

### 5.7.3 Audit trail ανά αναζήτηση

Κάθε εκτέλεση αναζήτησης baseline emissions καταγράφεται ως event. Αυτό εξυπηρετεί δύο σκοπούς: αφενός, παρέχει ιχνηλασιμότητα (*traceability*) — αν ένας πελάτης παραλάβει αναφορά εκπομπών, υπάρχει αρχείο για ποιον εκτέλεσε την αναζήτηση, πότε και με ποιά παραμέτρους. Αφετέρου, επιτρέπει την παρακολούθηση μέσω Loki/Grafana για ανίχνευση ανώμαλης χρήσης (βλ. Κεφ. 9).

### 5.7.4 Σύνδεση με downstream χρήσεις

Τα αποτελέσματα του Customer Baseline Emissions τροφοδοτούν δύο κρίσιμες downstream λειτουργίες. Πρώτον, αποτελούν τη βάση για την έκδοση πιστοποιητικών εκπομπών (Κεφ. 6.5) — το πιστοποιητικό αντλεί ακριβώς τα ίδια aggregated δεδομένα που βλέπει ο χρήστης στο UI, εξασφαλίζοντας συνέπεια μεταξύ αναφοράς και πιστοποιητικού. Δεύτερον, η σύγκριση fossil baseline vs ECO actual επιτρέπει την αξιολόγηση της αποτελεσματικότητας των ECO προϊόντων — δεδομένα που χρησιμοποιούνται για αναφορές βιωσιμότητας και αποτελέσματα της Maersk τόσο εσωτερικά όσο και στις αναφορές CSRD/CDP (Κεφ. 6, βλ. επίσης Κεφ. 2.4 για το ρυθμιστικό πλαίσιο).

---

Ο πυλώνας Ocean Emissions αποτελεί το θεμέλιο του συνολικού συστήματος. Η αξιοπιστία των δεδομένων κίνησης εμπορευματοκιβωτίων, η real-time τηλεμετρία μέσω STAR Connect, ο αλγόριθμος υπολογισμού βασισμένος σε trade factors και η ενσωμάτωση EU ETS απαντούν στις απαιτήσεις ακρίβειας, διαφάνειας και audit trail που εντοπίστηκαν ως βασικές ελλείψεις της παλιάς χειροκίνητης διαδικασίας. Τα επόμενα κεφάλαια εξετάζουν πώς αυτή η αξιόπιστη βάση εκπομπών χρησιμοποιείται για την παράδοση ECO προϊόντων (Κεφ. 6) και τον βέλτιστο ανεφοδιασμό καυσίμου (Κεφ. 7).
