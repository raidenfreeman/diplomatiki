# Κεφάλαιο 7 — Πυλώνας Γ: Bunker Optimization (Energy Markets)

## 7.1 Το πρόβλημα ανεφοδιασμού

Ο ανεφοδιασμός καυσίμου (*bunkering*) αποτελεί έναν από τους σημαντικότερους παράγοντες κόστους στην εμπορική ναυτιλία. Για έναν στόλο της κλίμακας της Maersk, με εκατοντάδες πλοία να εκτελούν περιστροφικά δρομολόγια (*vessel rotations*) σε δεκάδες λιμάνια ανά τον κόσμο, οι αποφάσεις που αφορούν στο ποσό καυσίμου που θα φορτωθεί σε κάθε λιμάνι συνιστούν πρόβλημα βελτιστοποίησης με πολλαπλές μεταβλητές και αυστηρούς περιορισμούς.

Τα βασικά στοιχεία της πολυπλοκότητας είναι τα εξής. Πρώτον, η τιμή καυσίμου διαφέρει σημαντικά μεταξύ λιμανιών και κυμαίνεται στον χρόνο: ένας χειριστής (*operator*) μπορεί να επιλέξει να φορτώσει περισσότερο καύσιμο σε ένα φθηνό λιμάνι και λιγότερο σε ένα ακριβό, εφόσον το πλοίο έχει επαρκή αποθηκευτική ικανότητα. Δεύτερον, κάθε λιμάνι έχει περιορισμένο διαθέσιμο χρόνο παραμονής (*port call duration*) και ενδέχεται να μην διαθέτει πάντα το ζητούμενο είδος καυσίμου. Τρίτον, οι κανονισμοί περί θείου (MARPOL Annex VI, SECA zones) επιβάλλουν τη χρήση χαμηλόθειων καυσίμων σε συγκεκριμένες περιοχές, προσθέτοντας επιπλέον τύπους καυσίμου στο πρόβλημα: HSFO (*High Sulfur Fuel Oil*), VLSFO (*Very Low Sulfur Fuel Oil*), LSDIS (*Low Sulfur Distillate*), ULSFO (*Ultra Low Sulfur Fuel Oil*), μεθανόλη. Τέταρτον, το EU ETS Maritime (βλ. Κεφ. 2.4), που ισχύει από το 2024, προσθέτει ένα επιπλέον κόστος άνθρακα ανά tonne εκπομπών στο αντικειμενικό άθροισμα κόστους της βελτιστοποίησης.

Ο στόχος είναι η ελαχιστοποίηση του συνολικού δαπανώμενου ποσού για καύσιμα κατά τη διάρκεια ενός ορίζοντα σχεδιασμού (*planning horizon*), που συνήθως αντιστοιχεί σε ένα πλήρες voyage rotation. Η επίλυση αυτού του προβλήματος απαιτεί γραμμικό προγραμματισμό (*linear programming*) με δεκάδες μεταβλητές απόφασης, γεγονός που καθιστά αναγκαία τη χρήση εξειδικευμένου επιλυτή (*solver*).

Σε μεσοπρόθεσμο ορίζοντα, η αρχιτεκτονική του Bunker Optimization πυλώνα προβλέπεται να επεκταθεί ώστε να ενσωματώσει στο αντικειμενικό άθροισμα τόσο το κόστος άνθρακα του EU ETS όσο και τη δυνατότητα επιλογής πράσινου καυσίμου σε συγκεκριμένα λιμάνια, σε άμεση σύνδεση με το Energy Bank (βλ. Κεφ. 6.3).

---

## 7.2 BOPS: Bunker Optimization Planning System

Το σύστημα που υλοποιεί τον πυλώνα ανεφοδιασμού ονομάζεται BOPS (*Bunker Optimization Planning System*). Αποτελεί επανα-πλατφόρμωση (*replatforming*) ενός υπάρχοντος συστήματος της Maersk Energy Markets, με στόχο τη σύγχρονη αρχιτεκτονική, τη συντηρησιμότητα και τη δυνατότητα ενσωμάτωσης με τα υπόλοιπα components του NRG monorepo (βλ. Κεφ. 9.3).

Το BOPS οργανώνεται σε τρία διακριτά επίπεδα:

**Επίπεδο 1 — API** (`bunker/api/`): Πρόκειται για τον συντονιστή (*coordinator*) της βελτιστοποίησης. Διαχειρίζεται την ουρά εργασιών, επικοινωνεί με τον C++ επιλυτή μέσω Erlang Ports και επιστρέφει τα αποτελέσματα. Περιέχει περίπου 8.816 γραμμές Elixir κώδικα.

**Επίπεδο 2 — BoW (Bunker on Water Workbench)** (`bunker/bow/`): Η web εφαρμογή που χρησιμοποιούν οι χειριστές για να παρακολουθούν και να τροποποιούν τα bunker plans. Υλοποιείται με Phoenix LiveView και αντιπροσωπεύει 16.738 γραμμές κώδικα.

**Επίπεδο 3 — MBC (*Multi-Bundle Connector*)**: Ο C++ γραμμικός επιλυτής που εκτελεί τους πραγματικούς βελτιστοποιητικούς υπολογισμούς. Εκτελείται ως ξεχωριστή διεργασία του λειτουργικού συστήματος και επικοινωνεί με τον BEAM μέσω `Port`.

Η συνολική ροή δεδομένων ακολουθεί την παρακάτω πορεία:

```
Shiptech → API → BoW UI → Operator edits → API → MBC Solver → Results → BoW → Shiptech writeback
```

Αρχικά, τα δεδομένα πλοίου και δρομολογίου αντλούνται από το Shiptech (το legacy σύστημα σχεδιασμού ναυτιλιακών δρομολογίων). Ο χειριστής εισάγει στο BoW τυχόν αλλαγές (π.χ. διορθώσεις στις τιμές καυσίμου ανά λιμάνι ή τροποποίηση διαθεσιμότητας). Το API συγκεντρώνει τα δεδομένα, δρομολογεί το αίτημα στον MBC solver, λαμβάνει τα αποτελέσματα και τα επιστρέφει στο Shiptech για εγγραφή (*writeback*), ενώ ταυτόχρονα τα εμφανίζει στο BoW για επισκόπηση.

Η αρχιτεκτονική αυτή διαφέρει σημαντικά από εκείνη του `emissions_workbench`, που έχει κυρίως αναλυτικό χαρακτήρα. Το BOPS είναι κατά βάση συναλλακτικό (*transactional*): κάθε εκτέλεση επιλυτή αντιστοιχεί σε ένα συγκεκριμένο πλοίο και ένα συγκεκριμένο χρονικό παράθυρο, και τα αποτελέσματα πρέπει να εγγραφούν αμέσως στο Shiptech.

---

## 7.3 BoW: Bunker on Water Workbench

Το BoW (*Bunker on Water Workbench*) αποτελεί την πύλη αλληλεπίδρασης των χειριστών με τη λειτουργία ανεφοδιασμού. Είναι μια Phoenix LiveView εφαρμογή που εκτελείται σε ξεχωριστό Elixir service (`bunker/bow`) και επικοινωνεί με το BOPS API μέσω HTTP για να εκκινεί plan runs, να ανακτά αποτελέσματα και να αποστέλλει διορθωτικές εισόδους χειριστή.

Τα κεντρικά σχήματα δεδομένων (*schemas*) που διαχειρίζεται το BoW περιλαμβάνουν: `vessels` (πλοία με IMO number, κωδικό GSIS, τύπο καυσίμου), `bunker_plans` (σχέδια ανεφοδιασμού ανά πλοίο), `port_calls` (κλήσεις λιμανιών με ETA/ETD), `schedules` (δρομολόγια), και `remaining_fuel_on_board` (τελευταία μέτρηση καυσίμου ανά τύπο).

Η ροή εργασίας ενός χειριστή (*operator workflow*) ακολουθεί τα εξής βήματα:

1. **Επισκόπηση τρέχοντος plan**: Ο χειριστής βλέπει για κάθε πλοίο τον πλήρη κατάλογο λιμανιών επίσκεψης με τις προτεινόμενες ποσότητες ανεφοδιασμού ανά τύπο καυσίμου (HSFO, VLSFO, LSDIS, ULSFO) και τις αντίστοιχες τιμές αγοράς.

2. **Επεξεργασία εισόδων**: Ο χειριστής μπορεί να τροποποιήσει τιμές καυσίμου ανά λιμάνι, να προσαρμόσει περιορισμούς διαθεσιμότητας ή να επισημάνει ένα λιμάνι ως μη-ανεφοδιαζόμενο (*non-bunkerable*). Αυτές οι τροποποιήσεις αποθηκεύονται στο σχήμα `fpms_bp_operator_port_inputs` και αποστέλλονται στο Shiptech μέσω της αποθηκευμένης διαδικασίας `sp_UpdateBunkerPlanOperatorInputs`.

3. **Εκκίνηση plan run**: Ο χειριστής ενεργοποιεί χειροκίνητα ή το σύστημα αυτόματα ενεργοποιεί νέα εκτέλεση του solver. Η ουρά διαχειρίζεται ασύγχρονα (βλ. Κεφ. 7.6).

4. **Σύγκριση αποτελεσμάτων**: Αφού ολοκληρωθεί το plan run, ο χειριστής βλέπει τα νέα αποτελέσματα σε σύγκριση με τα προηγούμενα. Το BoW υποστηρίζει πρόσβαση σε ιστορικά plans για ελεγξιμότητα.

Ιδιαίτερο χαρακτηριστικό του BoW είναι η ενσωμάτωση δεδομένων *Remaining Fuel on Board* (RoB) που λαμβάνονται σε πραγματικό χρόνο από το STAR Connect μέσω Kafka (βλ. Κεφ. 5.4). Αυτά τα δεδομένα εμφανίζονται στη σελίδα τρέχοντος bunker plan, παρέχοντας στον χειριστή την πλέον πρόσφατη εικόνα των αποθεμάτων καυσίμου του πλοίου και αποτελούν είσοδο για τον υπολογισμό των ποσοτήτων ανεφοδιασμού στο επόμενο plan run.

---

## 7.4 Ο C++ Solver μέσω Erlang Ports

### 7.4.1 Αρχιτεκτονική σύνδεσης με εξωτερικό επιλυτή

Η επιλογή του MBC (*Multi-Bundle Connector*) ως εξωτερικό C++ εκτελέσιμο για τη βελτιστοποίηση οφείλεται σε δύο συμπληρωματικούς λόγους. Πρώτον, οι αλγόριθμοι γραμμικού προγραμματισμού απαιτούν ώριμες βιβλιοθήκες σε χαμηλού επιπέδου γλώσσα, με C++ να αποτελεί de facto επιλογή σε παραγωγικά solver περιβάλλοντα. Δεύτερον, ο MBC προϋπήρχε ήδη ως αποδεδειγμένο σύστημα στη Maersk και η επαναχρησιμοποίησή του μέσω του BOPS API εξοικονόμησε σημαντικό αναπτυξιακό κόστος.

Η ενσωμάτωση του C++ εκτελεσίμου στον BEAM γίνεται μέσω **Erlang Ports**, και όχι μέσω NIFs (*Native Implemented Functions*). Η διαφορά είναι κρίσιμης σημασίας από αρχιτεκτονικής άποψης: τα NIFs εκτελούνται μέσα στον χώρο διευθύνσεων (*address space*) της BEAM VM, οπότε ένα segmentation fault ή ένας ατέρμων βρόχος σε native κώδικα καταρρίπτει ολόκληρο το node. Αντίθετα, τα Ports εκκινούν τον C++ κώδικα ως ξεχωριστή διεργασία του λειτουργικού συστήματος· εάν αυτή αποτύχει ή εξέλθει με σφάλμα, η BEAM VM παραμένει άθικτη και το supervision tree μπορεί να ανταποκριθεί κανονικά (βλ. Κεφ. 8.1 για αναλυτικότερη επεξήγηση των Erlang Ports).

Η επικοινωνία γίνεται μέσω stdio σε δυαδική μορφή (*binary protocol*): το `Port` στέλνει τα δεδομένα εισόδου στο `stdin` του MBC και λαμβάνει τα αποτελέσματα από το `stdout` γραμμή προς γραμμή. Αυτή η σχεδίαση επιτρέπει στον BEAM GenServer να παρακολουθεί σε πραγματικό χρόνο τα log μηνύματα του solver κατά τη διάρκεια της εκτέλεσης.

### 7.4.2 Υλοποίηση: BopsApi.Server

Ο `BopsApi.Server` είναι ο GenServer που επιτηρεί μία εκτέλεση του MBC solver. Εκκινείται από τον `BopsApi.ServerSupervisor` με στρατηγική `:one_for_all`, που σημαίνει ότι εάν ο Server ή ο Jobs Scheduler αποτύχει, και οι δύο επανεκκινούνται μαζί — διατηρώντας έτσι τη συνοχή κατάστασης.

```elixir
defmodule BopsApi.Server do
  use GenServer

  alias BopsApi.Response
  alias OpenTelemetry.Tracer

  require Tracer

  defmodule State do
    defstruct [
      :cmd,
      :current_mbc_trace_ctx,
      :log_batch_size,
      :request,
      :traceparent,
      logs: []
    ]

    def new(opts) do
      struct!(__MODULE__, opts)
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  @impl GenServer
  def init(opts) do
    state =
      State.new(
        cmd: Keyword.fetch!(opts, :cmd),
        log_batch_size: Keyword.get(opts, :log_batch_size, 50)
      )

    {:ok, state}
  end

  @impl GenServer
  def handle_cast(:find_work, state) do
    {:noreply, find_work(state)}
  end

  @impl GenServer
  def handle_continue(:find_work, state) do
    {:noreply, find_work(state)}
  end
```

*Listing 7.4.1: BopsApi.Server — δομή κατάστασης και αρχικοποίηση GenServer (`bunker/api/lib/bops_api/server.ex`, γραμμές 1–44)*

Στη δομή `State` αποθηκεύεται η εντολή εκτέλεσης του MBC (`cmd`), η αίτηση που επεξεργάζεται (`request`), το `traceparent` για distributed tracing με OpenTelemetry, και ένας buffer (`logs`) για τα μηνύματα εξόδου του solver.

Μόλις ο Server λάβει ένα job από την ουρά, εκκινεί τον solver ως Port:

```elixir
port = Port.open({:spawn_executable, path}, [
  :binary,
  :exit_status,
  args: [request.plan_id]
])
```

Εν συνεχεία, τα μηνύματα εξόδου του solver φτάνουν ως `handle_info({_port, {:data, output}}, state)` και αποθηκεύονται προσωρινά στο `state.logs`. Όταν η διεργασία ολοκληρωθεί επιτυχώς (`{:exit_status, 0}`), ο Server ανακτά τα αποτελέσματα από τη βάση δεδομένων του MBC μέσω του `BopsApi.Mbc.result/1` και τα αποστέλλει στο BoW μέσω `Response.done/1`. Σε περίπτωση σφάλματος (`{:exit_status, N}` με `N ≠ 0`), καταγράφεται το `mbc_crash` και το σφάλμα γνωστοποιείται στο BoW μέσω `Response.error/1`.

Αξίας σημείωσης είναι επίσης ο ενσωματωμένος μηχανισμός *distributed tracing*: ο Server αναλύει τις γραμμές εξόδου του solver αναζητώντας ειδικά prefixes (`Trace start:`, `Trace attribute:`, `Trace end:`), τα οποία μετατρέπει σε OpenTelemetry spans. Έτσι το trace του end-to-end plan run εκτείνεται από τον BEAM ως μέσα στα internals του C++ solver, παρέχοντας πλήρη ορατότητα στο σύστημα παρακολούθησης.

---

## 7.5 Ενσωμάτωση με το Shiptech

### 7.5.1 Αρχιτεκτονική ανταλλαγής δεδομένων

Το Shiptech είναι το legacy σύστημα σχεδιασμού ναυτιλιακών δρομολογίων και ανεφοδιασμού της Maersk, χτισμένο πάνω σε SQL Server. Περιέχει τα ιστορικά δεδομένα πλοίων, δρομολογίων και bunker plans και αποτελεί το σύστημα αρχείου (*system of record*) για την πλευρά των χειριστών. Το BOPS λειτουργεί ως overlay: διαβάζει από το Shiptech, επεξεργάζεται δεδομένα μέσω του MBC solver και εγγράφει πίσω τα αποτελέσματα.

Η ανάγνωση δεδομένων από το Shiptech γίνεται μέσω ODBC (*Open Database Connectivity*) με χρήση του Erlang ODBC adapter. Ο `Shiptech.Repo` διαχειρίζεται τη σύνδεση και εκτελεί ερωτήματα σε πίνακες του Shiptech, ανακτώντας στοιχεία όπως: `VesselVoyagedetailId` (μοναδικό αναγνωριστικό ταξιδιού), `VesselId`, χρονοδιαγράμματα λιμανιών (ETA/ETD), ποσότητες καυσίμου και τιμές αγοράς.

Η εγγραφή αποτελεσμάτων επιστρέφει επίσης στο Shiptech μέσω αποθηκευμένων διαδικασιών (*stored procedures*). Η βασικότερη είναι η `sp_CreateModelRunDataWithString`, η οποία δέχεται ολόκληρο το αποτέλεσμα βελτιστοποίησης σε μορφή JSON και το αποθηκεύει σε πολλαπλούς πίνακες ατομικά (*atomically*), εντός μίας SQL Server transaction. Ομοίως, η `sp_UpdateBunkerPlanOperatorInputs` αντιγράφει στο Shiptech τυχόν διορθώσεις που εισήγαγε ο χειριστής μέσω του BoW.

Η χρήση αποθηκευμένων διαδικασιών αντί για άμεσα `INSERT`/`UPDATE` ερωτήματα είναι σκόπιμη: το Shiptech διαθέτει σύνθετη σχεσιακή δομή με επιχειρησιακούς κανόνες (*business rules*) ενσωματωμένους στη βάση, και οι stored procedures ενθυλακώνουν αυτή την πολυπλοκότητα εξασφαλίζοντας συνέπεια δεδομένων ανεξαρτήτως του caller.

### 7.5.2 Ορισμός υποδομής με Terraform

Το BOPS API χρησιμοποιεί ξεχωριστή PostgreSQL βάση δεδομένων για τον MBC solver (η οποία διαφέρει από τη βάση του BoW). Η βάση αυτή αποθηκεύει προσωρινά τα δεδομένα εισόδου πριν την εκτέλεση του solver και τα αποτελέσματα αμέσως μετά, μέχρι να γραφούν στο Shiptech. Ο ορισμός της υποδομής γίνεται ως κώδικας με Terraform (βλ. Κεφ. 8.7 για Azure):

```hcl
resource "azurerm_postgresql_flexible_server" "bops-blue" {
  name                = "bops-staging-blue"
  resource_group_name = data.azurerm_resource_group.nrg.name
  version             = var.postgres_version

  administrator_login           = var.postgres_admin_username
  administrator_password        = var.postgres_admin_password
  public_network_access_enabled = false
  auto_grow_enabled             = true
  zone                          = "1"
  location                      = "West Europe"
  sku_name                      = "GP_Standard_D4s_v3"
  storage_mb                    = 524288

  tags = {
    "app"         = "bops"
    "app_id"      = "A3878"
    "env"         = "staging"
    "k8s_cluster" = "k8s_cluster"
    "mop_ingest"  = "true"
    "product_id"  = "sbti-portal"
  }

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }
}

resource "azurerm_postgresql_flexible_server_database" "bops-blue" {
  name      = "bops"
  server_id = azurerm_postgresql_flexible_server.bops-blue.id
}

resource "azurerm_postgresql_flexible_server_database" "solver-blue" {
  name      = "solver"
  server_id = azurerm_postgresql_flexible_server.bops-blue.id
}

resource "azurerm_postgresql_flexible_server_configuration" "shared_preload_libraries" {
  name      = "shared_preload_libraries"
  server_id = azurerm_postgresql_flexible_server.bops-blue.id
  value     = "pg_cron,pg_stat_statements"
}
```

*Listing 7.5.1: Terraform ορισμός PostgreSQL Flexible Server για το BOPS staging περιβάλλον (`bunker/terraform/staging/database.tf`, γραμμές 1–53)*

Αξιοσημείωτα στοιχεία αυτής της δήλωσης: ο server χρησιμοποιεί SKU `GP_Standard_D4s_v3` (4 vCores, general purpose) με 512 GB αποθηκευτικό χώρο, η δημόσια πρόσβαση είναι απενεργοποιημένη (`public_network_access_enabled = false`), και δημιουργούνται δύο ξεχωριστές βάσεις: `bops` (για τα δεδομένα εισόδου/εξόδου του BoW) και `solver` (αποκλειστικά για τα ενδιάμεσα δεδομένα του MBC). Το extension `pg_cron` φορτώνεται ως preload library για χρονοδρομολογημένες εργασίες, ενώ το `pg_stat_statements` επιτρέπει την παρακολούθηση επιδόσεων ερωτημάτων.
