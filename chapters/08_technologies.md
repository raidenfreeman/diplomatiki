# Κεφάλαιο 8 — Τεχνολογίες

Το παρόν κεφάλαιο παρουσιάζει αναλυτικά το τεχνολογικό στοίβα (*technology stack*) που επιλέχθηκε για την υλοποίηση του Πάγκου Εργασίας Εκπομπών. Κάθε τεχνολογία εξετάζεται ως προς τα εξής τέσσερα ερωτήματα: τι είναι, γιατί επιλέχθηκε για τις συγκεκριμένες απαιτήσεις του συστήματος, πώς χρησιμοποιείται στην πράξη εντός του NRG και ποιες εναλλακτικές απορρίφθηκαν όπου αυτό είναι κατατοπιστικό. Η επισκόπηση της αλληλεπίδρασης μεταξύ των επιμέρους τεχνολογιών, καθώς και ο τρόπος με τον οποίο αυτές συνθέτουν μια ενιαία αρχιτεκτονική, αναπτύσσεται στο Κεφ. 9.

## 8.1 BEAM, Erlang και Elixir

Η κεντρική τεχνολογική επιλογή του NRG είναι η εικονική μηχανή (*virtual machine*) **BEAM** και η γλώσσα **Elixir** που εκτελείται πάνω σ' αυτήν. Η BEAM αναπτύχθηκε αρχικά από μηχανικούς της Ericsson τη δεκαετία του 1980 για την εκτέλεση της γλώσσας Erlang σε συστήματα τηλεπικοινωνίας που απαιτούσαν υψηλή διαθεσιμότητα και ανοχή σε σφάλματα. Η Elixir, που δημιουργήθηκε το 2011 από τον José Valim, φέρνει σύγχρονο συντακτικό και το οικοσύστημα του Phoenix Framework πάνω στην ίδια VM.

Η BEAM υλοποιεί έναν **preemptive scheduler** με τόσα νήματα λειτουργικού συστήματος (*OS threads*) όσοι και οι πυρήνες του επεξεργαστή. Πάνω σε αυτά ο scheduler εκτελεί εκατοντάδες χιλιάδες **BEAM processes** — ελαφριές εικονικές διεργασίες με ιδιωτική μνήμη και ουρά μηνυμάτων. Επικοινωνία μεταξύ τους γίνεται αποκλειστικά μέσω **ασύγχρονων μηνυμάτων** (*message passing*), χωρίς κοινόχρηστη μνήμη (*shared state*). Το αποτέλεσμα είναι ότι η αποτυχία μιας διεργασίας δεν μολύνει τις υπόλοιπες — η φιλοσοφία «*let it crash*» της OTP επιτρέπει σε *supervisor* διεργασίες να επανεκκινούν αυτόματα οποιαδήποτε παιδική διεργασία αποτύχει.

Σε σύγκριση με εναλλακτικές: η **JVM** υποστηρίζει πολλές γλώσσες αλλά με βαριά OS threads ως μονάδα παραλληλίας· η **Go** προσφέρει goroutines αλλά με κοινόχρηστη μνήμη που απαιτεί συγχρονισμό· το **Node.js** είναι μονονηματικό και εξαρτάται από callbacks για ασύγχρονη εκτέλεση. Η BEAM αντιμετωπίζει φυσιολογικά σενάρια όπου χιλιάδες WebSocket συνδέσεις ή εισερχόμενα Kafka events χρειάζονται ταυτόχρονη επεξεργασία — ακριβώς η κατάσταση στον Πάγκο Εργασίας Εκπομπών.

Επιπλέον, η BEAM υποστηρίζει **Erlang Ports**: μηχανισμό επικοινωνίας με εξωτερικές native διεργασίες μέσω stdio, χωρίς να μοιράζονται τον ίδιο χώρο διευθύνσεων. Αυτό χρησιμοποιείται στον BOPS για την επικοινωνία με τον C++ solver (βλ. Κεφ. 7.4).

Η Elixir ως **συναρτησιακή** (*functional*) γλώσσα ενθαρρύνει φυσικά pipelines μετασχηματισμού δεδομένων με αμετάβλητες δομές (*immutable data structures*). Μόνο στα άκρα του pipeline — εισαγωγή δεδομένων και αποθήκευση — υπάρχουν παρενέργειες (*side effects*), γεγονός που περιορίζει σημαντικά τα σημεία αστοχίας.

**Listing 8.1.1** — Pipeline μετασχηματισμού αρχείου εισόδου (`nrg/components/emissions_workbench/lib/nrg/ocean/ingest/converters.ex`, γραμμές 55–73):

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

Το listing αποτυπώνει χαρακτηριστικά στοιχεία της Elixir: η έκφραση `with` αποσυνθέτει σειριακά τον μετασχηματισμό, κάθε βήμα επιστρέφει είτε την τιμή είτε αιτιολογημένο σφάλμα, και ο κλάδος `else` χειρίζεται κάθε πιθανή αποτυχία ρητά. Το αποτέλεσμα είναι κώδικας ευανάγνωστος, χωρίς εξαιρέσεις (*exceptions*) που «ξεφεύγουν» ανεξέλεγκτα.

## 8.2 Phoenix Framework και LiveView

Το **Phoenix Framework** είναι το web framework της Elixir, με φιλοσοφία παρόμοια με το Ruby on Rails: επίκεντρο η παραγωγικότητα, σαφής διαχωρισμός ευθυνών (Router → Controller/LiveView → Template) και πλούσια εργαλεία γραμμής εντολών (*generators*). Εδράζεται στη βιβλιοθήκη **Plug** για σύνθεση middleware, και δεν εισάγει νέο στοίβα εκτός BEAM — όλο το HTTP request handling γίνεται εντός BEAM processes.

Η κύρια καινοτομία που χρησιμοποιείται εκτεταμένα στο NRG είναι το **Phoenix LiveView**: αντί να αποστέλλεται στατικό HTML ή να επικοινωνεί το frontend με REST/GraphQL API, η κατάσταση (*state*) της σελίδας διαχειρίζεται σε ένα BEAM process ανά σύνδεση. Οι αλλαγές αποστέλλονται στον browser μέσω μόνιμης σύνδεσης **WebSocket** ως διαφορά (*diff*) του DOM. Το αποτέλεσμα είναι εμπειρία χρήστη αντίστοιχη *Single-Page Application* (SPA) χωρίς ξεχωριστή βάση κώδικα JavaScript — ένα ενιαίο Elixir module ελέγχει τόσο την επιχειρησιακή λογική όσο και την παρουσίαση. Στο NRG υπάρχουν 14+ LiveView modules κατανεμημένα σε τέσσερα namespaces: Eco Delivery, Energy Bank, Emissions Data Inventory και Admin.

Η σύγκριση με SPA frameworks (React, Vue): η προσέγγιση με LiveView μειώνει τον κώδικα που συντηρεί η ομάδα και εξαλείφει το «impedance mismatch» μεταξύ backend και frontend τύπων. Το μειονέκτημα είναι η απαίτηση μόνιμης WebSocket σύνδεσης, άρα αυξημένη εξάρτηση από τη διαθεσιμότητα του server.

**Listing 8.2.1** — `mount/3` και `handle_event/3` από `OceanSimulatorLive` (`nrg/components/emissions_workbench/lib/nrg_web/live/ocean_simulator_live.ex`, γραμμές 34–79):

```elixir
@impl Phoenix.LiveView
def mount(_params, _session, socket) do
  filter_options = Nrg.Ocean.Factors.list_filter_options()
  latest_year = List.last(filter_options.years)

  assigns = %{
    page_id: "ocean-simulator",
    form: %SimulationInput{date: to_string(latest_year)},
    result: nil,
    filter_options: filter_options,
    selected_year: latest_year,
    products: Nrg.Products.simulatable()
  }

  {:ok, assign(socket, assigns)}
end

@impl Phoenix.LiveView
def handle_event(
      "submit_form",
      %{
        "container_size" => container_size,
        "container_type" => container_type,
        "date" => date,
        "lane_id" => lane_id,
        "number_of_ffe" => number_of_ffe,
        "number_of_moves" => number_of_moves,
        "product_id" => product_id
      },
      socket
    ) do
  form =
    %SimulationInput{
      container_size: container_size,
      container_type: container_type,
      date: date,
      lane_id: lane_id,
      number_of_ffe: number_of_ffe,
      number_of_moves: number_of_moves,
      product_id: product_id
    }

  result = calculate_result(form)

  {:noreply, assign(socket, result: result)}
end
```

Το `mount/3` εκτελείται κατά τη δημιουργία της σύνδεσης και αρχικοποιεί το state του LiveView process. Το `handle_event/3` ανταποκρίνεται σε γεγονότα από τον browser — εδώ η υποβολή φόρμας — με pattern matching στα πεδία της φόρμας και υπολογισμό αποτελέσματος. Ο server επιστρέφει `{:noreply, assign(...)}` για να ενημερώσει το state και να ενεργοποιήσει re-render.

## 8.3 PostgreSQL και Ecto

Η βάση δεδομένων που επιλέχθηκε είναι η **PostgreSQL**, ώριμη ανοιχτού κώδικα σχεσιακή βάση δεδομένων (*relational database*) με πλήρη υποστήριξη **ACID** συναλλαγών (*transactions*), τύπους JSON/JSONB για ημιδομημένα δεδομένα, και πλούσιο οικοσύστημα επεκτάσεων. Στο NRG η PostgreSQL φιλοξενείται ως διαχειριζόμενη υπηρεσία **Azure Database for PostgreSQL Flexible Server**, που αναλαμβάνει backups, patches και υψηλή διαθεσιμότητα.

Το μέγεθος της βάσης είναι σημαντικό: **151 ξεχωριστοί πίνακες** και **720+ migrations** συνολικά (499 στο emissions_workbench, 218 στο bunker/bow, 4 στο bunker/api). Κάθε component του monorepo διατηρεί τη δική του βάση δεδομένων και το δικό του `Repo` module, εφαρμόζοντας αρχή ελάχιστης πρόσβασης (*principle of least privilege*) και περιορίζοντας το «blast radius» τυχόν λανθασμένων queries.

Η βιβλιοθήκη **Ecto** είναι το επίπεδο αλληλεπίδρασης με τη βάση στην Elixir. Αποτελείται από τέσσερα στρώματα: *Adapter* (σύνδεση με PostgreSQL driver), *Schema* (αντιστοίχηση Elixir struct σε πίνακα), *Changeset* (επικύρωση και μετασχηματισμός δεδομένων πριν την αποθήκευση) και *Query* (composable DSL για SQL queries). Η προσέγγιση αυτή διαχωρίζει σαφώς τον ορισμό δεδομένων από την επικύρωση, επιτρέποντας διαφορετικά changesets για δημιουργία, ενημέρωση και επικύρωση στο ίδιο schema.

**Listing 8.3.1** — Ecto schema `ContainerMove` (`nrg/components/emissions_workbench/lib/nrg/ocean/container_move.ex`, γραμμές 33–54):

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

Το schema ορίζει ρητά τύπους ανά πεδίο — ιδιαίτερα `Ecto.Enum` για `container_size` και `container_type` που διασφαλίζουν ότι μόνο έγκυρες τιμές αποθηκεύονται στη βάση. Τα `virtual` πεδία (`port_of_receipt_location`, `port_of_discharge_location`) δεν αντιστοιχούν σε στήλες πίνακα αλλά χρησιμοποιούνται για εμπλουτισμό του struct κατά το query χωρίς ξεχωριστό join model.

## 8.4 Apache Kafka

Το **Apache Kafka** είναι κατανεμημένο σύστημα καταγραφής μηνυμάτων (*distributed log*) που χρησιμεύει ως **message broker** μεταξύ παραγωγών (*producers*) και καταναλωτών (*consumers*) δεδομένων. Η κεντρική αρχή του είναι ότι τα μηνύματα αποθηκεύονται διατεταγμένα και αμετάβλητα σε *topics* και *partitions*, επιτρέποντας αναπαραγωγή (*replay*), backpressure και ανεξάρτητη κλιμάκωση παραγωγών και καταναλωτών.

Στο NRG, το Kafka χρησιμεύει κυρίως για:
- **Τηλεμετρία πλοίων (STAR Connect)**: τα δεδομένα καυσίμου από τα πλοία εισρέουν ως Kafka events και λαμβάνονται από το BoW για τον υπολογισμό του *Remaining Fuel on Board*.
- **Ocean emissions ingestion**: εισαγωγή container move δεδομένων από εσωτερικά Maersk συστήματα.
- **Event streaming μεταξύ components**: ασύγχρονη επικοινωνία με αποσύνδεση (*decoupling*) παραγωγού-καταναλωτή.

Το NRG χρησιμοποιεί τη βιβλιοθήκη **`:brod`** — τον Erlang-native Kafka client — που ενσωματώνεται φυσικά στη BEAM χωρίς JNI ή FFI. Συνολικά υπάρχουν **9 αρχεία** με ενσωμάτωση Kafka στο codebase. Τα topics διαιρούνται σε partitions ανά vessel (με κλειδί το IMO number), διασφαλίζοντας διατακτική επεξεργασία (*ordering*) για κάθε πλοίο. Οι καταναλωτές ανήκουν σε *consumer groups*, επιτρέποντας οριζόντια κλιμάκωση και ανάκτηση από τον τελευταίο επεξεργασμένο *offset* σε περίπτωση επανεκκίνησης.

## 8.5 Dremio

Το **Dremio** είναι πλατφόρμα ομοσπονδιακής αναζήτησης SQL (*federated SQL query engine*) που επιτρέπει ερωτήματα σε διάφορες πηγές δεδομένων (αρχεία Parquet, S3, βάσεις δεδομένων) μέσω ενός ενιαίου SQL interface χωρίς ETL (*Extract-Transform-Load*). Στη Maersk χρησιμοποιείται ως η εταιρική πλατφόρμα data lake.

Το NRG προσπελαύνει το Dremio για ανάκτηση κύριων δεδομένων (*master data*) και ιστορικών εκπομπών από namespaces όπως:
- `Infrastructure_GDA.Energy_Transition.NetZero.*` — δεδομένα εκπομπών στόλου
- `EcoDelivery.ShipmentDetails` — λεπτομέρειες αποστολών
- `Common_Datasets.*` — κοινά επιχειρησιακά δεδομένα
- `Masterdata.*` — master data αναφοράς

Η σύνδεση γίνεται μέσω ODBC ή Arrow Flight (για streaming queries μεγάλου όγκου), με αυθεντικοποίηση μέσω personal access token (`DREMIO_API_KEY`). Ο λόγος χρήσης Dremio αντί για απευθείας πρόσβαση στα υποκείμενα συστήματα είναι η αποσύνδεση: το NRG δεν χρειάζεται να γνωρίζει τη φυσική αποθήκευση των δεδομένων, και οι αλλαγές στο data lake δεν επηρεάζουν τις εφαρμογές εφόσον το SQL interface παραμένει σταθερό.

## 8.6 ODBC ενσωματώσεις

Η πρόσβαση σε εξωτερικά συστήματα μέσω **ODBC** (*Open Database Connectivity*) χρησιμοποιείται σε δύο σημεία: στη σύνδεση με το **Shiptech** (legacy σύστημα σχεδιασμού ταξιδιών σε Microsoft SQL Server) και στην πρόσβαση στο **Dremio** μέσω ODBC. Το Erlang/OTP περιλαμβάνει native ODBC adapter (`:odbc` application) που επιτρέπει χρήση ODBC χωρίς εξωτερικές εξαρτήσεις.

Η ενσωμάτωση με Shiptech ακολουθεί το μοτίβο ξεχωριστού `Repo` (`Shiptech.Repo`) που αξιοποιεί Ecto ως DSL αλλά οδηγεί SQL Server μέσω ODBC αντί για PostgreSQL driver. Αυτό επιτρέπει στο υπόλοιπο σύστημα να αλληλεπιδρά με legacy SQL Server με τον ίδιο τρόπο που αλληλεπιδρά με PostgreSQL, μειώνοντας γνωσιακό φορτίο (*cognitive load*).

## 8.7 Microsoft Azure

Το **Microsoft Azure** είναι η πλατφόρμα νέφους (*cloud platform*) που χρησιμοποιεί η Maersk ως εταιρικό πρότυπο για τις υποδομές της. Η επιλογή δεν έγινε από την ομάδα ET Platform αλλά κληρονομήθηκε ως εταιρική απαίτηση, γεγονός που εξαλείφει τις ανησυχίες περί vendor lock-in στη συγκεκριμένη περίπτωση.

Οι υπηρεσίες Azure που χρησιμοποιούνται στο NRG περιλαμβάνουν:
- **Azure Database for PostgreSQL Flexible Server**: διαχειριζόμενη βάση δεδομένων για emissions_workbench, bunker/bow και EventStore.
- **Azure Kubernetes Service (AKS)**: εκτέλεση των containerized εφαρμογών (βλ. 8.8).
- **Azure Blob Storage**: αποθήκευση PDF πιστοποιητικών ECO Delivery (βλ. Κεφ. 6.5).
- **Azure Key Vault**: αποθήκευση ευαίσθητων παραμέτρων (*secrets*) — συμπληρωματικά με HashiCorp Vault (βλ. 8.14).
- **Azure Logic Apps**: ορχήστρωση ροών εργασίας στο BOPS (8 Logic Apps: `activate_vessel`, `pre_processing`, `upload_bunker_plan`, `upload_user_input` κ.ά.).
- **Azure API Management**: gateway για το BOPS API.
- **Azure Active Directory + SAML SSO**: αυθεντικοποίηση χρηστών (βλ. Κεφ. 9.7).

Το σύστημα λειτουργεί σε **δύο περιβάλλοντα** (staging και production), καθένα με ανεξάρτητες υποδομές. Το πλεονέκτημα του Azure ως διαχειριζόμενης υπηρεσίας είναι η μείωση του λειτουργικού φορτίου (*operational overhead*) για patches, backups και υψηλή διαθεσιμότητα. Το μειονέκτημα είναι αυξημένο κόστος σε σχέση με self-hosted λύσεις, και εξάρτηση από διαθεσιμότητα τρίτου παρόχου.

## 8.8 Kubernetes

Το **Kubernetes** (*K8s*) είναι πλατφόρμα ορχήστρωσης containers (*container orchestration*) που αναλαμβάνει την εκτέλεση, κλιμάκωση, αυτόματη επανεκκίνηση και rolling updates των υπηρεσιών. Στο NRG, ο web server του emissions_workbench τρέχει σε **3 replicas** πάνω σε AKS.

Η ροή της κυκλοφορίας (*traffic flow*) ακολουθεί τα εξής βήματα: **Akamai** (CDN και WAF) → **Stargate** (εσωτερικό API gateway Maersk) → **nginx ingress controller** (AKS) → **pods**. Κάθε pod εκτελεί το Elixir release σε Docker container. Το Kubernetes διαμορφώνει *readiness probes* (η εφαρμογή είναι έτοιμη να δεχτεί κυκλοφορία) και *liveness probes* (η εφαρμογή είναι εν λειτουργία), επανεκκινώντας αυτόματα pods που δεν ανταποκρίνονται.

Ιδιαίτερο χαρακτηριστικό είναι το custom CLI εργαλείο **`k8s`**: ένα Nix-based wrapper πάνω από `kubectl` που τυποποιεί τις εντολές deployment και παρέχει έτοιμα *namespaces*, *contexts* και credentials. Η ανάπτυξη γίνεται μέσω rolling updates — το νέο pod ξεκινά, περνά τα readiness checks, και μόνο τότε τερματίζεται το παλαιό — διασφαλίζοντας μηδενικό χρόνο διακοπής (*zero-downtime deployment*) ακόμα και κατά τις ~32 αναπτύξεις ανά ημέρα.

## 8.9 Terraform

Το **Terraform** της HashiCorp είναι εργαλείο υποδομής ως κώδικα (*Infrastructure as Code — IaC*): οι υποδομές ορίζονται σε αρχεία HCL (*HashiCorp Configuration Language*) και δημιουργούνται/ενημερώνονται ντετερμινιστικά με `terraform apply`. Οποιαδήποτε αλλαγή στην υποδομή (νέος πίνακας, νέο AKS cluster, firewall rule) γίνεται μόνο μέσω αλλαγής κώδικα Terraform, επιτρέποντας *code review*, *audit trail* και εύκολη αναδημιουργία.

Στο NRG υπάρχουν **57 αρχεία `.tf`** και χρησιμοποιούνται **34+ τύποι πόρων `azurerm`**. Για το BOPS υπάρχουν **4 ξεχωριστά περιβάλλοντα**: staging/production × api/logic_app, καθένα με δική του κατάσταση (*state*) Terraform. Η διαχείριση του state γίνεται σε Azure Storage Account με *state locking* για αποφυγή ταυτόχρονων εφαρμογών.

Σε σχέση με εναλλακτικές (Pulumi, AWS CDK, Ansible): το Terraform επιλέχθηκε για την ευρεία υιοθέτησή του στη Maersk, τον ώριμο `azurerm` provider και τη σαφή γλώσσα δήλωσης πόρων.

## 8.10 Nix και nix-darwin

Το **Nix** είναι διαχειριστής πακέτων (*package manager*) και γλώσσα δήλωσης ρυθμίσεων (*configuration language*) με κεντρική αρχή την **αναπαραγωγιμότητα** (*reproducibility*): κάθε πακέτο ορίζεται από το ακριβές *hash* των εξαρτήσεών του, εξαλείφοντας το φαινόμενο «στον υπολογιστή μου λειτουργεί». Τα **Nix Flakes** εισάγουν δηλωτικό lockfile (`flake.lock`) που καρφώνει (*pins*) κάθε εξάρτηση σε ακριβή έκδοση, παρόμοια με `package-lock.json` αλλά για ολόκληρο το περιβάλλον ανάπτυξης.

Στο NRG, ολόκληρο το περιβάλλον ανάπτυξης — Elixir, Erlang, Node.js, εργαλεία CI, k8s binary — ορίζεται στο `flake.nix`. Η ενσωμάτωση **nix-darwin** επιτρέπει τη χρήση Nix σε macOS, καλύπτοντας το development laptop κάθε μηχανικού. Το **Home Manager** διαχειρίζεται ρυθμίσεις χρήστη (`.zshrc`, git config, packages). Το **direnv** φορτώνει αυτόματα το περιβάλλον `flake.nix` κάθε φορά που ο χρήστης μπαίνει στον κατάλογο του project.

**Listing 8.10.1** — Ορισμός εφαρμογής `nrg` στο `flake.nix` (γραμμές 100–105):

```nix
nrg = addK8sToApp {
  app = callPackage ./components/emissions_workbench { };
  containerImage = (callPackage ./components/emissions_workbench/container.nix) {
    paths = [ nrg.app ];
  };
};
```

Ο ορισμός δείχνει τη σύνθεση (*composability*) του Nix: η εφαρμογή `nrg` δημιουργείται ως πακέτο μέσω `callPackage`, ενσωματώνεται σε Docker container image μέσω `container.nix`, και εμπλουτίζεται με Kubernetes εργαλεία μέσω `addK8sToApp`. Ολόκληρη η αλυσίδα από source code έως container image είναι δηλωτική και αναπαράξιμη.

Το πλεονέκτημα στην ομάδα είναι σημαντικό: νέος μηχανικός ρυθμίζει το περιβάλλον με `nix develop` χωρίς χειροκίνητη εγκατάσταση εξαρτήσεων. Το CI τρέχει το ίδιο Nix flake, διασφαλίζοντας ότι builds σε laptop και CI είναι πανομοιότυπα.

## 8.11 GitHub Actions και Custom Runner

Η ομάδα χρησιμοποιεί το **GitHub Actions** ως σύστημα συνεχούς ολοκλήρωσης (*CI — Continuous Integration*) και συνεχούς ανάπτυξης (*CD — Continuous Deployment*). Στο NRG υπάρχουν **20 workflows** που καλύπτουν: build και test, σάρωση υποδομής (*IaC scan*), αναπτύξεις σε staging και production, έλεγχοι ασφαλείας και εκτέλεση Terraform.

Κρίσιμη βελτίωση αποδοτικότητας είναι ο **Custom NixOS Runner**: εικονική μηχανή Azure που εκτελεί NixOS και χρησιμεύει ως GitHub Actions runner αντί για τους standard GitHub-hosted runners. Το πλεονέκτημα: αφού το περιβάλλον είναι Nix, το runner έχει ήδη cached τα πακέτα και ο χρόνος εκκίνησης CI είναι πολύ μικρότερος. Η αυθεντικοποίηση με HashiCorp Vault γίνεται μέσω **AppRole auth** — το CI λαμβάνει βραχύβιο token από Vault για πρόσβαση σε secrets production.

Μια σημαντική βελτιστοποίηση είναι το **affected workspace detection**: στο monorepo, κάθε CI run αξιολογεί ποια components επηρεάζονται από τις αλλαγές και εκτελεί tests μόνο για αυτά, μειώνοντας τον χρόνο ανατροφοδότησης. Το αποτέλεσμα είναι ρυθμός **~32 αναπτύξεις ανά ημέρα** σε production — τυπικό για XP ομάδες που εφαρμόζουν continuous deployment (βλ. Κεφ. 10).

## 8.12 Maersk Design System (MDS)

Το **Maersk Design System (MDS)** είναι η εσωτερική βιβλιοθήκη UI components της Maersk, υλοποιημένη ως **Web Components** — πρότυπο W3C που επιτρέπει επαναχρησιμοποιήσιμα HTML elements ανεξάρτητα από JavaScript framework. Παρέχει έτοιμα components (κουμπιά, φόρμες, πίνακες, modals) με εφαρμοσμένο το brand identity της Maersk (χρώματα, typography, spacing). Τεκμηρίωση και Storybook διατίθενται εσωτερικά στο `mds.maersk.com`.

Το NRG ενσωματώνει MDS μέσω `Phoenix.Component`: τα Web Components φορτώνονται ως npm packages μέσω esbuild στο Phoenix asset pipeline, και χρησιμοποιούνται απευθείας στα HEEx templates των LiveView modules. Το πλεονέκτημα είναι διπλό: η ομάδα δεν χρειάζεται να σχεδιάζει UI από το μηδέν, και οι χρήστες που εργάζονται σε πολλές Maersk εφαρμογές αναγνωρίζουν οικεία patterns ελαχιστοποιώντας τον χρόνο εκμάθησης.

## 8.13 Observability stack

Η παρακολούθηση (*observability*) ενός κατανεμημένου, event-driven συστήματος απαιτεί τρεις πυλώνες: logs, metrics και traces. Το NRG χρησιμοποιεί:

**Logs**: Το **Grafana Loki** συγκεντρώνει logs από όλα τα pods. Ερωτήματα σε logs γίνονται με **LogQL** (γλώσσα παρόμοια με PromQL). Ο agent αποστολής logs (`promtail` ή Kubernetes-native log shipper) στέλνει ένα log stream ανά pod.

**Metrics**: Η βιβλιοθήκη **PromEx** εξάγει αυτόματα Phoenix, Oban και LiveView metrics σε Prometheus exposition format. Ο **Prometheus** συλλέγει (*scrapes*) τα metrics ανά interval, και το **Grafana** παρέχει dashboards. Έτοιμα dashboards (Phoenix web server latency, Oban queue depth, LiveView connections) δίνουν ορατότητα χωρίς custom instrumentation.

**Traces**: Το **OpenTelemetry** ενσωματώνεται στο Phoenix και Ecto για αυτόματη ιχνηλάτηση (*distributed tracing*) των HTTP requests και database queries. Τα traces αποστέλλονται στο **OpenObserve** (v0.14.4, self-hosted), αντικαθιστώντας ακριβότερες λύσεις cloud tracing.

**Alerts**: Κανόνες ειδοποίησης (*alert rules*) ορίζονται ως κώδικας στο `/alerts/` directory, με **13+ κανόνες** σε YAML. Ειδοποιήσεις αποστέλλονται μέσω **Hedwig** (εσωτερικό Maersk routing layer) σε Microsoft Teams channels ή email.

**Listing 8.13.1** — Κανόνας ειδοποίησης για ETW requests (`nrg/alerts/metrics/alerts.yaml`, γραμμές 40–49):

```yaml
- alert: Too many concurrent requests to ETW
  expr: sum(nrg_etw_requests_count{app="nrg-workers"}) by(env) > 5
  for: 5m0s
  labels:
    hedwig_scope: nrg-errors-scope
  annotations:
    runbook_url: https://maersk-tools.atlassian.net/wiki/x/lIl0iio
    summary: Too many current requests to ETW
    description: We've made too many concurrent requests to ETW in an environment.
```

Κάθε κανόνας ορίζει PromQL έκφραση (`expr`), διάρκεια ενεργοποίησης (`for`), scope ειδοποίησης (`hedwig_scope`) και σύνδεσμο runbook για αντιμετώπιση. Η αποθήκευση alert rules ως κώδικα επιτρέπει code review, version control και ελεγχόμενη εξέλιξη των κανόνων παράλληλα με τον κώδικα εφαρμογής.

Συμπληρωματικά, η Maersk παρέχει την εσωτερική πλατφόρμα **Maersk Observability Platform (MOP)** για centralized dashboard hosting και log aggregation σε εταιρικό επίπεδο.

## 8.14 HashiCorp Vault και agenix

Η διαχείριση ευαίσθητων παραμέτρων (*secrets management*) απαιτεί διαφορετικές λύσεις για διαφορετικές φάσεις: runtime credentials (database passwords, API keys) vs build-time secrets (κλειδιά πρόσβασης σε Nix binary cache).

Για **runtime secrets**, το **HashiCorp Vault** παρέχει κεντρικό αποθετήριο με fine-grained πολιτικές πρόσβασης (*policies*), audit logging κάθε ανάγνωσης και **dynamic secrets** (Vault δημιουργεί βραχύβια credentials που λήγουν αυτόματα). Η αυθεντικοποίηση του CI γίνεται μέσω **AppRole auth**: το GitHub Actions workflow παίρνει βραχύβιο token ανταλλάσσοντας role ID + secret ID, αποφεύγοντας τη διαχείριση μακρόβιων credentials στα GitHub Secrets.

Για **build-time secrets** (πχ netrc για private Nix binary cache), χρησιμοποιείται **agenix**: εργαλείο δηλωτικής κρυπτογράφησης βασισμένο στο πρότυπο *age*. Τα secrets αποθηκεύονται κρυπτογραφημένα στο Git repository και αποκρυπτογραφούνται κατά το build με το κατάλληλο κλειδί. Η διάκριση μεταξύ Vault (runtime) και agenix (build-time) αντικατοπτρίζει την αρχή ελάχιστης έκθεσης: κάθε secret εκτίθεται μόνο όταν χρειάζεται.

## 8.15 Oban

Το **Oban** είναι βιβλιοθήκη επεξεργασίας εργασιών υποβάθρου (*background job processor*) για Elixir, βασισμένη σε **PostgreSQL** ως αποθετήριο ουράς. Κάθε εργασία αποθηκεύεται ως γραμμή στον πίνακα `oban_jobs` με κατάσταση, ουρά (*queue*), αριθμό επαναπροσπαθειών (*attempts*) και προγραμματισμένο χρόνο εκτέλεσης. Αν ο server επανεκκινηθεί, οι εκκρεμείς εργασίες ανακτώνται από PostgreSQL — δεν χάνονται.

Στο NRG υπάρχουν **31 Oban workers** που καλύπτουν: batch εισαγωγή container moves από Dremio, αναέκδοση πιστοποιητικών ECO, προγραμματισμένα plan runs στο BOPS, αποστολή ειδοποιήσεων και εξαγωγή δεδομένων. Το Oban υποστηρίζει **ουρές με διαφορετική ταυτόχρονη χωρητικότητα** (*concurrency per queue*), επιτρέποντας π.χ. ανεξάρτητο ρυθμό εκτέλεσης για ingestion jobs vs certificate jobs.

Η νοητική αναλογία με το Sidekiq του Ruby on Rails είναι εύστοχη, με κεντρική διαφορά ότι το Oban χρησιμοποιεί PostgreSQL αντί Redis — αξιοποιώντας ACID εγγυήσεις για ακριβές exactly-once semantics μέσω advisory locks. Η χρήση Oban απαλλάσσει τους developers από την υλοποίηση custom scheduling και retry logic σε κάθε worker.

## 8.16 Commanded και EventStore

Το **Commanded** είναι βιβλιοθήκη υλοποίησης **CQRS** (*Command Query Responsibility Segregation*) και **event sourcing** στην Elixir. Παρέχει τα δομικά στοιχεία: `Aggregate` (domain object με state), `Command` (εντολή αλλαγής), `Event` (αμετάβλητο γεγονός που καταγράφει τι συνέβη) και `Projection` (read model που προκύπτει από replay events).

Το backend αποθήκευσης events είναι το **EventStore** (μέσω του `commanded_eventstore_adapter`), που εδράζεται πάνω σε PostgreSQL. Κάθε event αποθηκεύεται αμετάβλητα με sequence number, δίνοντας πλήρες audit trail και τη δυνατότητα αναπαραγωγής (*replay*) της ιστορίας.

Στο NRG, Commanded χρησιμοποιείται αποκλειστικά για το **Energy Bank** (Κεφ. 6.3): οι καταθέσεις (*deposits*) πράσινου καυσίμου και αναλήψεις (*withdrawals*) για ECO products υλοποιούνται ως Commands που παράγουν Events. Αυτό εξασφαλίζει πλήρη ιχνηλασιμότητα για τους GIA audit ελέγχους και επιτρέπει ανακατασκευή του ισοζυγίου ανά οποιαδήποτε χρονική στιγμή.

## 8.17 Λοιπά υποστηρικτικά εργαλεία

Πέραν των κεντρικών τεχνολογιών, το NRG αξιοποιεί μια σειρά εργαλείων που υποστηρίζουν ποιότητα κώδικα, παραγωγικότητα και ειδικές ανάγκες:

**Credo**: στατικός αναλυτής (*linter*) Elixir που εφαρμόζει κανόνες στυλ και αναγνωρίζει κοινά antipatterns. Εκτελείται στο CI για κάθε pull request. **Dialyxir**: wrapper για Dialyzer, το εργαλείο τυπικής ανάλυσης (*type analysis*) βασισμένο σε *success typings* — εντοπίζει κλήσεις συναρτήσεων που δεν μπορούν να επιστρέψουν *valid* τύπο χωρίς να απαιτεί ρητές type annotations.

**Telemetry**: βιβλιοθήκη instrumentation χαμηλού επιπέδου που εκπέμπει events για κρίσιμα σημεία (HTTP request έναρξη/λήξη, Ecto query εκτέλεση). PromEx χτίζει πάνω σε Telemetry για τα Phoenix/Oban metrics.

**Workspace**: εργαλείο διαχείρισης Elixir monorepo — ορίζει DAG εξαρτήσεων μεταξύ applications και επιτρέπει εντολές `mix workspace.run` να εκτελούνται μόνο στα affected components, ενισχύοντας την ταχύτητα CI.

**Livebook**: περιβάλλον notebook για Elixir (αντίστοιχο Jupyter), χρησιμοποιούμενο για εξερεύνηση ποιότητας δεδομένων (`data-quality.livemd`) και ad-hoc ανάλυση χωρίς να χρειάζεται ξεχωριστό Python περιβάλλον.

**ChromicPDF**: βιβλιοθήκη δημιουργίας PDF μέσω headless Chromium, χρησιμοποιούμενη για τη δημιουργία PDF πιστοποιητικών ECO (Κεφ. 6.5) από HTML templates.

**Tuple**: εργαλείο remote pair programming που χρησιμοποιεί η ομάδα για τις συνεδρίες ζεύγους (*pair programming sessions*) — ιδιαίτερα σημαντικό για κατανεμημένη ομάδα 28 μελών σε Ευρώπη και Ινδία (βλ. Κεφ. 10).

---

Η επιλογή κάθε τεχνολογίας στον παραπάνω κατάλογο δεν είναι τυχαία: αποτελεί συνειδητή απόφαση με αιτιολογημένη σύνδεση στις απαιτήσεις του συστήματος. Η BEAM επελέγη για παραλληλία και ανοχή σε σφάλματα, το Phoenix LiveView για ενοποιημένο full-stack development, το Nix για αναπαραγωγιμότητα περιβάλλοντος, και το Commanded/EventStore για audit trail στο Energy Bank. Στο επόμενο κεφάλαιο (Κεφ. 9) εξετάζεται πώς αυτές οι τεχνολογίες συνδέονται αρχιτεκτονικά σε ένα λειτουργικό σύνολο.
