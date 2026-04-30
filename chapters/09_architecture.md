# Κεφάλαιο 9 — Αρχιτεκτονική του συστήματος

## 9.1 Επισκόπηση συστήματος

Το σύστημα NRG / Emissions Workbench αποτελεί μια πολύπλοκη, κατανεμημένη πλατφόρμα η οποία ενορχηστρώνει αφενός τη συλλογή και επεξεργασία δεδομένων εκπομπών από ετερογενείς πηγές, αφετέρου την παρουσίαση επεξεργασμένων πληροφοριών σε 1.300 και πλέον χρήστες διαφορετικών επιχειρησιακών ρόλων. Η αρχιτεκτονική ενσωματώνει τρεις κύριους πυλώνες λειτουργικότητας — Ocean Emissions, ECO Product Delivery και Bunker Optimization (βλ. Κεφ. 4) — μέσα σε ένα ενιαίο, συνεκτικό σύστημα που εκτείνεται από την πραγματικού χρόνου τηλεμετρία πλοίων ως την έκδοση νομικά δεσμευτικών πιστοποιητικών βιωσιμότητας.

Το παρακάτω διάγραμμα παρέχει μια υψηλού επιπέδου θεώρηση των συστατικών στοιχείων του συστήματος και των αλληλεπιδράσεών τους:

![Αρχιτεκτονική Συστήματος](./system_overview_diagram.png)

Η λογική άποψη του συστήματος διακρίνει πέντε βασικά συστατικά (*components*): το `emissions_workbench` ως κεντρικό domain component με 67.877 γραμμές κώδικα, το `bunker/bow` (16.738 γραμμές) και το `bunker/api` (8.816 γραμμές) για τη βελτιστοποίηση ανεφοδιασμού, καθώς και τα `ocean` και `eco_products` ως εξειδικευμένα, αυτόνομα components. Όλα συνυπάρχουν σε ένα μονο-αποθετήριο (*monorepo*) που διαχειρίζεται την κοινή υποδομή, τη δοκιμή και την ανάπτυξη.

Η φυσική άποψη περιλαμβάνει δύο ανεξάρτητα deployment περιβάλλοντα (παραγωγή και ενδιάμεσο περιβάλλον δοκιμής — *staging*), με τρία αντίγραφα (*replicas*) web server pod και ένα αποκλειστικό pod για επεξεργασία παρασκηνίου (*background processing*), όλα ενορχηστρωμένα μέσω Azure Kubernetes Service. Η υψηλού επιπέδου ροή δεδομένων ακολουθεί ένα μοτίβο αγωγού (*pipeline*): εξωτερικές πηγές (Dremio, Kafka, Shiptech) → στρώμα ενσωμάτωσης (*ingestion layer*) → domain logic → στρώμα παρουσίασης (LiveView) → αποθήκευση αποτελεσμάτων (PostgreSQL, Azure Blob Storage).

Η ανάπτυξη ξεκίνησε το Μάρτιο του 2023 και το σύστημα μπήκε σε παραγωγή τον Σεπτέμβριο του 2023 — ένας κύκλος ανάπτυξης έξι μηνών από κενή κατάσταση σε πλήρως λειτουργικό σύστημα παραγωγής. Η επιλογή της αρχιτεκτονικής ήταν συνειδητά προσανατολισμένη στην ταχύτητα ανάπτυξης, χωρίς να θυσιάζεται η επιχειρησιακή ορθότητα — δεδομένου ότι τα παραγόμενα δεδομένα χρησιμοποιούνται για κανονιστική συμμόρφωση (EU ETS, CSRD) και εμπορικές συναλλαγές ύψους 31 εκατομμυρίων δολαρίων.

Αξίζει να σημειωθεί ότι η αρχιτεκτονική δεν σχεδιάστηκε εκ των προτέρων ως ολοκληρωμένο blueprint, αλλά εξελίχθηκε σταδιακά υπό τις αρχές του Extreme Programming (βλ. Κεφ. 10): απλούστατη δομή αρχικά, με συνεχή ανακαινισμό (*refactoring*) καθώς αποκαλύπτονταν νέες επιχειρησιακές απαιτήσεις. Αυτό εξηγεί γιατί ορισμένα components (πχ `eco_products`, `net_zero`) παραμένουν placeholders — η ομάδα δεν δημιουργεί δομή που δεν χρειάζεται ακόμα.

## 9.2 Clean Architecture στην πράξη

Η θεμελιώδης αρχιτεκτονική αρχή που διέπει τον κώδικα του NRG είναι η *Clean Architecture*, όπως αυτή τεκμηριώθηκε από τον Robert C. Martin. Η αρχή αυτή οργανώνει τον κώδικα σε ομόκεντρα στρώματα με αυστηρή κατευθυντήρια εξάρτηση: εξωτερικά στρώματα εξαρτώνται από εσωτερικά, ενώ το αντίθετο απαγορεύεται.

Στο πλαίσιο του NRG, η αρχιτεκτονική αυτή υλοποιείται με τέσσερα επίπεδα:

**Entities (Οντότητες):** Τα βασικά επιχειρησιακά δεδομένα και οι κανόνες που θα υπήρχαν ακόμη και αν το σύστημα δεν ήταν αυτοματοποιημένο. Στο NRG, αυτά περιλαμβάνουν έννοιες όπως `ContainerMove`, `ClearingAccount`, `FuelOrder`, `Certificate` — δομές δεδομένων χωρίς εξαρτήσεις σε εξωτερικά frameworks.

**Use Cases (Περιπτώσεις Χρήσης):** Η επιχειρησιακή λογική της εφαρμογής, ανεξάρτητη από web frameworks, βάσεις δεδομένων και λοιπές υποδομές. Παράδειγμα: ο υπολογισμός εκπομπών ανά δρομολόγιο εμπεριέχει την επιχειρησιακή λογική (`EmissionsCalculator`), αλλά δεν γνωρίζει τίποτα για SQL ή HTTP. Τα use cases ορίζουν *behaviours* (συμπεριφορές) για τα δεδομένα που χρειάζονται, χωρίς να γνωρίζουν πώς αυτά ανακτώνται.

**Adapters/Gateways (Προσαρμογείς):** Αποτελούν τη γέφυρα μεταξύ των use cases και του εξωτερικού κόσμου. Τα *Gateways* υλοποιούν τις συμπεριφορές που ορίζουν τα use cases και αλληλεπιδρούν με εξωτερικά συστήματα (PostgreSQL, Dremio, Kafka). Τα *Web adapters* (LiveView, HTTP controllers) εκχωρούν όλη την επεξεργασία δεδομένων στα use cases, παρέχοντάς τους τα κατάλληλα Gateways.

**Frameworks/Drivers:** Το εξωτερικότερο στρώμα — Phoenix, Ecto, Kafka clients, Azure SDKs. Οι επιλογές αυτές μπορούν να αντικατασταθούν χωρίς να επηρεαστεί η επιχειρησιακή λογική.

Ένα χαρακτηριστικό παράδειγμα εφαρμογής της Clean Architecture είναι το σύστημα έκδοσης πιστοποιητικών (βλ. Κεφ. 6.5): το use case συγκεντρώνει εκπομπές μέσω ενός gateway, υπολογίζει αποταμιεύσεις ανεξάρτητα από τη βάση δεδομένων, και στη συνέχεια ο web controller μεριμνά για τη μορφοποίηση και αποθήκευση του PDF — κάθε στρώμα ξεχωριστό, με καθαρές διεπαφές. Αυτή η αυστηρή διαστρωμάτωση επέτρεψε στην ομάδα να αλλάζει τον τρόπο παραγωγής PDF χωρίς να αγγίξει τη λογική υπολογισμού εκπομπών.

Ένα ζήτημα που προκύπτει συχνά κατά την εφαρμογή Clean Architecture σε Elixir είναι η σχέση με τις παραδοσιακές Phoenix conventions: το Phoenix framework, από μόνο του, δεν επιβάλλει Clean Architecture — απλοποιεί την ανάπτυξη με controllers που απευθείας αλληλεπιδρούν με Ecto schemas. Στο NRG, η ομάδα επέλεξε να υπερβεί αυτό το default pattern, εισάγοντας ρητή Gateway layer: οι controllers και οι LiveView modules δεν αλληλεπιδρούν ποτέ άμεσα με τους Ecto repos, αλλά μέσω Gateway modules που υλοποιούν behaviours ορισμένα από τα use cases. Αυτή η επιλογή αυξάνει ελαφρά το boilerplate, αλλά επιτρέπει πλήρη unit testing των use cases χωρίς βάση δεδομένων — κρίσιμο για τη διατήρηση του ρυθμού TDD (βλ. Κεφ. 10).

Στην εσωτερική τεκμηρίωση της ομάδας (`guides/tech/clean-architecture.md`), η αρχιτεκτονική αυτή παρουσιάζεται με ένα διάγραμμα σχέσεων: ο Controller εκκινεί το Gateway, το οποίο παρέχεται στο Use Case για εκτέλεση. Το Use Case γνωρίζει μόνο το behaviour, ενώ το Gateway γνωρίζει τα εξωτερικά συστήματα. Αυτή η αρχιτεκτονική αντιστοιχία — behaviour ως σύμβαση, Gateway ως υλοποίηση — αξιοποιεί τη φυσική έννοια των Elixir behaviours και callbacks, καθιστώντας την αρχιτεκτονική ιδιαίτερα εύστοχη για τη γλώσσα.

Η Clean Architecture εκτός από τεχνική επιλογή αποτελεί και πολιτισμική αρχή: η ομάδα χρησιμοποιεί τη διαστρωμάτωση ως κοινή γλώσσα στις code reviews. Ερωτήματα του τύπου "αυτό ανήκει στο use case ή στο gateway;" αποτελούν τακτικές συζητήσεις στο pair programming (βλ. Κεφ. 10), διαμορφώνοντας μια ομαδική κουλτούρα αρχιτεκτονικής συνέπειας ανεξάρτητα από ατομικές προτιμήσεις.

## 9.3 Monorepo οργάνωση

Ολόκληρη η κωδικοβάση φιλοξενείται σε ένα ενιαίο αποθετήριο (*monorepo*) που συνδυάζει το εργαλείο `Workspace` για ενορχήστρωση Elixir monorepo με Mix umbrella applications. Αυτή η επιλογή αντανακλά μια συνειδητή αρχιτεκτονική απόφαση: η ατομική διαχείριση πολλαπλών αποθετηρίων θα εισήγαγε σημαντική πολυπλοκότητα συντονισμού σε μια κωδικοβάση όπου τα components μοιράζονται domain γνώση και τεχνολογική υποδομή.

Τα πέντε κύρια components οργανώνονται κάτω από τον κατάλογο `components/`:

- `emissions_workbench`: Ο κεντρικός κόμβος — Ocean Emissions, ECO Product Delivery, Energy Bank. Αποτελεί το μεγαλύτερο component (67.877 LOC) και φιλοξενεί τη συντριπτική πλειοψηφία των 294 Ecto schemas, των 112 GenServers και των 31 Oban workers.
- `bunker/bow`: Το web UI του συστήματος βελτιστοποίησης ανεφοδιασμού (16.738 LOC).
- `bunker/api`: Ο coordinator service που επικοινωνεί με τον C++ solver (8.816 LOC).
- `ocean`: Αυτόνομο component για vessel master data και EU ETS δεδομένα.
- `eco_products` και `net_zero`: Placeholder components για μελλοντική επέκταση.

Ένα κρίσιμο πλεονέκτημα του monorepo είναι η ανίχνευση επηρεαζόμενων εφαρμογών (*affected workspace apps*) κατά τη φάση CI/CD: αντί να επανεκτελούνται τα tests για ολόκληρη την κωδικοβάση σε κάθε commit, το σύστημα εντοπίζει ποια components επηρεάστηκαν από τις αλλαγές και εκτελεί μόνο τα σχετικά tests — αυτό επιτρέπει τη διατήρηση υψηλής συχνότητας deployments (~32 ανά ημέρα) χωρίς αδικαιολόγητα μεγάλους χρόνους αναμονής (βλ. Κεφ. 10 για CI/CD πρακτικές).

Ένα εγγενές μειονέκτημα είναι η αυξημένη πολυπλοκότητα κατασκευής (*build complexity*): η ατομική εκτέλεση ενός component απαιτεί κατανόηση του γράφου εξαρτήσεων. Αυτό αντιμετωπίζεται μέσω τεκμηρίωσης και εργαλείων ανίχνευσης εξαρτήσεων του `Workspace`.

Σε αριθμητικά μεγέθη, η κωδικοβάση αριθμεί 6.033 αρχεία `.ex`/`.exs`, 786 test files και 93.431 γραμμές κώδικα στα core components. Ο λόγος test/production code (~13%) αντικατοπτρίζει τη συστηματική εφαρμογή TDD, ενώ οι 294 Ecto schemas δείχνουν τον πλούτο του domain model που φιλοξενεί το σύστημα. Ο μεγάλος αριθμός GenServers (112) αντανακλά τη στρατηγική επιλογή BEAM ως πλατφόρμας: η ομάδα αξιοποιεί native BEAM concurrency primitives αντί να βασίζεται σε external message brokers για εσωτερική επικοινωνία.

Μια ενδιαφέρουσα πτυχή της monorepo οργάνωσης είναι ο τρόπος με τον οποίο συνδυάζεται με το εργαλείο Nix: το `flake.nix` ορίζει ένα ενιαίο, αναπαραγώγιμο development environment για ολόκληρο το repository. Αυτό σημαίνει ότι ένας νέος developer που κλωνοποιεί το repo εκτελεί μία μόνο εντολή (`nix develop`) και αποκτά ακριβώς την ίδια έκδοση Elixir, Erlang, PostgreSQL, και όλων των βοηθητικών εργαλείων που χρησιμοποιεί ολόκληρη η ομάδα — ανεξάρτητα από το λειτουργικό σύστημα ή τις τοπικές ρυθμίσεις.

## 9.4 Components και τα όριά τους

Η οργάνωση σε components δεν είναι απλώς φυσική διαίρεση φακέλων — αντιπροσωπεύει σαφώς οριοθετημένα επιχειρησιακά contexts (βλ. *Domain-Driven Design*). Κάθε component εκθέτει μια δημόσια διεπαφή και κρύβει τις εσωτερικές λεπτομέρειες υλοποίησης.

| Component | Ρόλος | Δημόσια API |
|-----------|-------|-------------|
| `emissions_workbench` | Κεντρικό domain: εκπομπές, ECO products, Energy Bank | `Nrg.Ocean.*`, `EnergyBank.*`, `NrgWeb.*` |
| `bunker/bow` | Web UI βελτιστοποίησης ανεφοδιασμού | Phoenix LiveView app, Oban workers |
| `bunker/api` | Coordinator για C++ solver | REST API, Port-based IPC |
| `ocean` | Vessel master data + EU ETS | `get_all_vessels/0`, `find_by_imo/1` |
| `eco_products` | ECO product logic (placeholder) | Εξαρτάται από emissions_workbench |

Η Elixir ως γλώσσα δεν διαθέτει access modifiers σε επίπεδο module, επομένως τα όρια εφαρμόζονται κατά σύμβαση: δημόσιες συναρτήσεις στα ανώτερα επίπεδα module path (πχ `EnergyBank.deposit/2`) αποτελούν τη σύμβαση δημόσιας διεπαφής, ενώ modules με βαθύτερη ιεραρχία (πχ `EnergyBank.Domain.Transactions.Withdrawal`) θεωρούνται εσωτερικής χρήσης.

Τα όρια μεταξύ components επιβάλλονται επίσης μέσω της δομής εξαρτήσεων στα Mix project files: ένα component δεν μπορεί να εισαγάγει κώδικα άλλου component αν αυτή η εξάρτηση δεν είναι δηλωμένη ρητά. Αυτό δημιουργεί ένα κατευθυνόμενο ακυκλικό γράφο (*DAG*) εξαρτήσεων που τεκμηριώνει τη συνολική αρχιτεκτονική δομή.

Εντός του `emissions_workbench`, τα domain contexts οργανώνονται επίσης ιεραρχικά: το `Nrg.Ocean` namespace ορίζει vessel master data και emissions calculation, το `EnergyBank` namespace διαχειρίζεται τη λογιστική καυσίμων, και το `NrgWeb` namespace εκθέτει το web interface. Η επικοινωνία μεταξύ αυτών των contexts γίνεται μέσω δημόσιων API συναρτήσεων, αποτρέποντας άμεση εξάρτηση μεταξύ εσωτερικών modules. Αυτή η πρακτική, αν και δεν επιβάλλεται από τον compiler, ελέγχεται στα code reviews ως αρχιτεκτονική αρχή της ομάδας.

Ένα ζήτημα που αντιμετωπίζουν πολλά microservices architectures είναι η διαχείριση δεδομένων που ανήκουν σε πολλαπλά contexts. Στο NRG, αυτό αντιμετωπίζεται με ρητή αντιγραφή (*copy-on-write*) μόνο των απαραίτητων πεδίων: το `emissions_workbench` αποθηκεύει τα vessel data που χρειάζεται τοπικά, αντί να καλεί κάθε φορά το `ocean` component. Αυτή η στρατηγική *data sovereignty per context* αυξάνει την τοπική συνοχή και μειώνει τη σύζευξη runtime, με το κόστος πιθανής (διαχειρίσιμης) πλεονασματικής αποθήκευσης.

## 9.5 Data ingestion pipeline

Ένας από τους αρχιτεκτονικά πιο ενδιαφέροντες τομείς του συστήματος είναι ο τρόπος με τον οποίο δεδομένα από ετερογενείς εξωτερικές πηγές εισέρχονται, κανονικοποιούνται και καθίστανται διαθέσιμα για επεξεργασία. Η ενσωμάτωση δεδομένων (*data ingestion*) αντιμετωπίζει τρεις διαφορετικές προκλήσεις: πηγές που απαιτούν περιοδική ανάκτηση (*polling*), ροές πραγματικού χρόνου (*streaming*) και σύνθετες εργασίες μετασχηματισμού (*batch processing*).

### 9.5.1 Polling sources

Η ανάκτηση δεδομένων από το Dremio data lake και το Shiptech πραγματοποιείται μέσω περιοδικής δειγματοληψίας που ενορχηστρώνεται από Oban workers. Κάθε worker υλοποιεί ένα μοτίβο *idempotent polling*: διατηρεί ένα σελιδοδείκτη (*bookmark*) `last_updated` ώστε να ανακτά μόνο τα νέα ή τροποποιημένα records, αποφεύγοντας επαναλαμβανόμενη εισαγωγή.

Τα Dremio queries εκτελούνται μέσω ODBC, εκμεταλλευόμενα τον ODBC adapter του Erlang OTP. Τα αποτελέσματα επιστρέφονται ως streaming cursor, κατάλληλος για μεγάλα datasets χωρίς να φορτώνεται ολόκληρο το result set στη μνήμη. Ο χρονοπρογραμματισμός ακολουθεί ημερήσιο κύκλο για την πλειοψηφία των δεδομένων, με υψηλότερη συχνότητα για time-sensitive streams (πχ vessel RoB).

Το Dremio λειτουργεί ως ενοποιητικό στρώμα δεδομένων (*federated data layer*) για το Maersk enterprise data ecosystem: αντί να αποθηκεύει δεδομένα, δρομολογεί SQL queries σε υποκείμενα συστήματα (data warehouses, data lakes, external databases). Για το NRG, αυτό σημαίνει ότι τα δεδομένα εκπομπών ανά δρομολόγιο, τα trade factors και τα vessel master data ανακτώνται μέσω ενιαίου SQL interface, ανεξάρτητα από το υποκείμενο σύστημα αποθήκευσης. Η αρχιτεκτονική αντίσταση (*architectural insulation*) που παρέχει το Dremio επιτρέπει στο NRG να παραμείνει αναλλοίωτο ακόμη και αν αλλάξει η υποκείμενη υποδομή του enterprise data platform.

### 9.5.2 Streaming

Η πραγματικού χρόνου ροή δεδομένων υλοποιείται μέσω Apache Kafka με την Erlang βιβλιοθήκη `:brod`. Εννέα αρχεία ολοκλήρωσης Kafka διαχειρίζονται topics που σχετίζονται με vessel telemetry (STAR Connect feeds) και ocean emissions updates.

Η κατανομή των partitions ανά vessel αριθμό IMO εγγυάται διατήρηση της σειράς μηνυμάτων ανά σκάφος — προϋπόθεση σημαντική για σωστή χρονολογική εφαρμογή των fuel consumption readings. Η διαχείριση offsets επιτρέπει idempotent processing: αν ένας consumer αποτύχει και επανεκκινηθεί, επεξεργάζεται εκ νέου τα μηνύματα από το τελευταίο επιτυχώς δεσμευμένο offset.

Η επιλογή `:brod` (Erlang client για Kafka) αντί για pure Elixir libraries (πχ `kafka_ex`) αντικατοπτρίζει την αρχιτεκτονική φιλοσοφία: η χρήση mature, low-level Erlang libraries παρέχει αξιοπιστία και performance που δεν απαιτεί wrapper libraries. Το `:brod` επιτρέπει fine-grained έλεγχο ανά partition consumer και υποστηρίζει native Erlang process model για τη διαχείριση consumers.

Αξίζει να σημειωθεί η αρχιτεκτονική επιλογή για *backpressure*: η BEAM φυσικά περιορίζει το throughput μέσω message queue sizing. Αν ένας downstream consumer δεν μπορεί να επεξεργαστεί μηνύματα αρκετά γρήγορα, η BEAM mailbox γεμίζει και ο producer επιβραδύνεται φυσικά — χωρίς πολύπλοκο infrastructure για rate limiting. Αυτό απλοποιεί σημαντικά την αρχιτεκτονική σε σχέση με JVM-based systems που απαιτούν ρητή διαχείριση backpressure.

### 9.5.3 Job processing και GenServer Director

Αφότου τα ακατέργαστα δεδομένα ενσωματωθούν, ακολουθεί ένας αγωγός μετασχηματισμού: πρώτα αποθηκεύονται σε staging tables (πχ `RawOceanContainerMove`), εμπλουτίζονται με αναφορικά δεδομένα (vessel data, trade factors, emissions factors) και τελικά μεταφέρονται στους κύριους πίνακες.

Η διαχείριση των background workers υλοποιείται μέσω του `NrgWorker.Director`, ενός GenServer που παρακολουθεί αλλαγές διαμόρφωσης και εκκινεί ή τερματίζει workers δυναμικά:

```elixir
defmodule NrgWorker.Director do
  @moduledoc "Listens for worker config changes and starts/stops workers accordingly."

  use GenServer

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(init_args \\ []) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    NrgWorker.Settings.subscribe(:worker_config)
    {:ok, [], {:continue, :apply_current_worker_config}}
  end

  @impl GenServer
  def handle_continue(:apply_current_worker_config, state) do
    NrgWorker.Settings.latest_worker_config() |> apply_config()
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:worker_config, :changed}, state) do
    NrgWorker.Settings.latest_worker_config() |> apply_config()
    {:noreply, state}
  end

  # Starts and stops workers based on the contents of `new_config`
  @spec apply_config(map()) :: :ok
  defp apply_config(new_config) do
    Enum.each(new_config, fn {field, should_be_running?} ->
      if field in NrgWorker.worker_config_fields() do
        worker = NrgWorker.find_by_config_field(field)

        if should_be_running?,
          do: NrgWorker.start(worker, NrgWorker.Supervisor),
          else: NrgWorker.stop(worker)
      end
    end)

    :ok
  end
end
```

**Listing 9.5.1:** `NrgWorker.Director` GenServer — δυναμική διαχείριση workers μέσω subscription σε αλλαγές διαμόρφωσης.

Η αρχιτεκτονική αυτή επιτρέπει run-time ενεργοποίηση ή απενεργοποίηση κάθε worker χωρίς επανεκκίνηση της εφαρμογής — κρίσιμο για λειτουργική ευελιξία σε production περιβάλλον. Ο Director εγγράφεται (`subscribe`) σε αλλαγές ρυθμίσεων και αντιδρά άμεσα, ακολουθώντας το BEAM μοτίβο της επικοινωνίας μέσω μηνυμάτων. Η χρήση `{:continue, :apply_current_worker_config}` στο `init/1` εξασφαλίζει ότι η αρχική διαμόρφωση εφαρμόζεται αμέσως μετά την εκκίνηση, χωρίς να μπλοκαριστεί ο supervisor.

## 9.6 Web layer

Το στρώμα παρουσίασης βασίζεται αποκλειστικά σε Phoenix LiveView, επιτρέποντας διαδραστικές, server-rendered εμπειρίες χρήστη χωρίς client-side JavaScript framework. Η κωδικοβάση περιλαμβάνει 14 και πλέον LiveView modules κατανεμημένα σε τέσσερα namespaces:

- **Eco Delivery** (~13 modules): Παρακολούθηση ECO product allocations, έκδοση πιστοποιητικών, dashboard επισκόπησης.
- **Energy Bank** (~7 modules): Διαχείριση clearing accounts, προβολή καταθέσεων/αναλήψεων, ισοζύγιο καυσίμων.
- **Emissions Data Inventory** (~14 modules): Αναζήτηση εκπομπών ανά πελάτη, export δεδομένων, ιστορικά reports.
- **Admin** (~7 modules): Διαχείριση ρυθμίσεων συστήματος, worker configuration, user roles.

Τα LiveView modules ακολουθούν το Humble Object pattern: η παρουσίαση (mount/handle_event/render) διαχωρίζεται από την επιχειρησιακή λογική, την οποία εκχωρούν σε use case modules. Αυτό επιτρέπει αποτελεσματική δοκιμή της επιχειρησιακής λογικής ανεξάρτητα από το web layer (βλ. Κεφ. 10 για TDD πρακτικές).

Η ενσωμάτωση με το Maersk Design System (MDS) — μια βιβλιοθήκη Web Components — εξασφαλίζει οπτική συνέπεια με άλλες εφαρμογές του ομίλου. Τα MDS components χρησιμοποιούνται ως custom HTML elements εντός των Phoenix HEEx templates, διατηρώντας τη διαχωριστική γραμμή μεταξύ περιεχομένου (Elixir) και παρουσίασης (MDS). Τα static assets διαχειρίζονται από `esbuild` με Phoenix integration.

Η επικοινωνία μεταξύ sessions χρηστών για πραγματικού χρόνου ενημερώσεις χρησιμοποιεί το Phoenix PubSub: όταν ένας worker ολοκληρώνει μια εισαγωγή δεδομένων, ενημερώνει τα ενεργά LiveView sessions μέσω broadcast, ώστε οι χρήστες να βλέπουν ενημερωμένα δεδομένα χωρίς manual refresh.

Η αρχιτεκτονική επιλογή Phoenix LiveView αντί για SPA (Single Page Application) με React ή Vue έχει συγκεκριμένες επιπτώσεις στη δομή του κώδικα: ολόκληρη η λογική κατάστασης (*state management*) παραμένει στον server, εξαλείφοντας την ανάγκη για client-state synchronization. Ο server αποστέλλει ελάχιστα diffs HTML μέσω WebSocket αντί για JSON payloads, μειώνοντας τη σύζευξη client-server. Το κόστος αυτής της επιλογής είναι η υψηλότερη εξάρτηση από WebSocket connectivity — αποδεκτό κόστος για εταιρικούς χρήστες σε αξιόπιστα δίκτυα.

Επιπλέον, η χρήση LiveComponents για επαναχρησιμοποιήσιμα UI elements (πχ emissions summary cards, certificate status badges) εφαρμόζει την αρχή DRY εντός του web layer, μειώνοντας duplicated template logic. Κάθε LiveComponent διαχειρίζεται ανεξάρτητα την κατάστασή του, επιτρέποντας partial re-renders χωρίς να ανανεώνεται ολόκληρη η σελίδα.

## 9.7 Authentication και Authorization

Η ταυτοποίηση χρηστών βασίζεται σε SAML SSO μέσω Azure Active Directory. Κάθε χρήστης αυθεντικοποιείται μέσω του εταιρικού identity provider της Maersk, ενώ οι πληροφορίες ταυτότητας και ρόλων προέρχονται από AD groups.

Η εξουσιοδότηση (*authorization*) υλοποιείται με ρόλους βασισμένους σε ομάδες Azure AD. Ομάδες όπως "SBTi Developers" ή "ECO Sales" αντιστοιχίζονται σε internal ρόλους της εφαρμογής. Στα LiveView mounts, ο έλεγχος ρόλων πραγματοποιείται με helper macros τύπου `with_authenticated_request(ctx, roles: ~ROLES(admin))`, παρέχοντας διαδηλωτικό (*declarative*) και επαναχρησιμοποιήσιμο έλεγχο πρόσβασης.

Για πρόσβαση σε production περιβάλλον, χρησιμοποιείται Privileged Identity Management (PIM) της Azure — ένα σύστημα just-in-time πρόσβασης όπου ο χρήστης αιτείται ανύψωση προνομίων για συγκεκριμένο χρονικό διάστημα. Αυτό ελαχιστοποιεί την επιφάνεια επίθεσης σε περίπτωση παραβίασης λογαριασμού, και δημιουργεί ακριβές audit trail κάθε πρόσβασης στα production συστήματα — απαίτηση που προέκυψε άμεσα από τον εσωτερικό έλεγχο GIA του 2023 (βλ. Κεφ. 2.7).

Τα secrets της εφαρμογής (credentials βάσεων δεδομένων, API keys) διαχειρίζονται μέσω HashiCorp Vault, με AppRole authentication για τα CI/CD pipelines. Ο διαχωρισμός μεταξύ runtime secrets (Vault) και build-time secrets (agenix) αντικατοπτρίζει την αρχιτεκτονική αρχή της ελάχιστης δυνατής έκθεσης κατά την κάθε φάση.

Αξιοσημείωτη αρχιτεκτονική λεπτομέρεια είναι η απουσία session-level authorization state: κάθε LiveView request επαληθεύει τη συνεδρία (*session*) και τα δικαιώματα ανεξάρτητα, αντί να εκχωρεί αποφάσεις authorization σε cached state. Αυτό προστατεύει από κατηγορία επιθέσεων όπου η ανάκληση δικαιωμάτων (πχ αποχώρηση χρήστη) δεν αντανακλάται άμεσα σε ενεργές sessions. Στο πλαίσιο του NRG, όπου οι χρήστες έχουν πρόσβαση σε εμπιστευτικά οικονομικά δεδομένα πελατών, αυτή η προσέγγιση αποτελεί ορθή αρχιτεκτονική επιλογή.

## 9.8 Persistence layer

Η κεντρική αποθήκευση δεδομένων του συστήματος βασίζεται σε PostgreSQL Flexible Server της Azure. Η κωδικοβάση διαχειρίζεται συνολικά 151 πίνακες με 720 και πλέον migrations — 499 στο `emissions_workbench`, 218 στο `bunker/bow` και 4 στο `bunker/api`. Ο μεγάλος αριθμός migrations αντικατοπτρίζει τον υψηλό ρυθμό ανάπτυξης: η ομάδα ακολουθεί πολιτική continuou migrations, με κάθε deployment να μπορεί να εισαγάγει νέες αλλαγές σχήματος.

Η κρίσιμη αρχιτεκτονική απόφαση αφορά τη χρήση **πολλαπλών βάσεων δεδομένων** (multiple databases) αντί ενός ενιαίου αποθετηρίου: κάθε domain context έχει δική του Ecto Repo. Αυτό επιτρέπει:

- **Απομόνωση σφαλμάτων** (*blast radius*): πρόβλημα στη βάση δεδομένων του Energy Bank δεν επηρεάζει άμεσα τις Ocean emissions.
- **Ανεξάρτητη κλιμάκωση**: κάθε βάση μπορεί να διαμορφωθεί ανεξάρτητα (storage, compute, backup policy).
- **Καθαρά domain boundaries**: η αδυναμία foreign key constraints μεταξύ βάσεων αναγκάζει explicit modeling των cross-context relationships στον κώδικα.

Η στρατηγική δημιουργίας αντιγράφων ασφαλείας (*backup strategy*) αξιοποιεί το Azure Data Protection με ημερήσιες και εβδομαδιαίες λήψεις αντιγράφων. Κρίσιμο στοιχείο είναι τα αυτοματοποιημένα εβδομαδιαία τεστ αποκατάστασης: ένα GitHub Actions workflow (`db-restore-from-backup.yml`) εκτελείται κάθε Παρασκευή, αποκαθιστά τη βάση δεδομένων σε δοκιμαστικό περιβάλλον και επαληθεύει την ακεραιότητα των δεδομένων. Αυτή η πρακτική, σπάνια σε πολλές οργανώσεις, εξασφαλίζει ότι το RTO (Recovery Time Objective) παραμένει μετρήσιμο και επαληθευμένο, και όχι θεωρητικό.

Οι migrations ακολουθούν αρχή αντίστροφης συμβατότητας (*backward-compatible migrations only*): κάθε αλλαγή σχήματος πρέπει να είναι συμβατή με την προηγούμενη έκδοση κώδικα, επιτρέποντας zero-downtime deployments με κυλιόμενη ενημέρωση pods.

Η απόφαση για 151 ξεχωριστούς πίνακες αντανακλά τον πλούτο του domain model: κάθε entity (container move, shipment, voyage, trade factor, certificate, clearing account, fuel order, POS document) μοντελοποιείται ρητά. Αυτή η "fat schema" προσέγγιση αντιτίθεται σε modelos που χρησιμοποιούν λίγους πίνακες με εκτεταμένα JSON columns — μια επιλογή που προτιμά την ακρίβεια των δεδομένων και την ευκολία querying έναντι της ευελιξίας σχήματος.

Η χρήση Ecto ως ORM (αντικειμενο-σχεσιακός χαρτογράφος — *Object-Relational Mapper*) παρέχει τυπική ασφάλεια για queries μέσω Ecto.Query DSL, ενώ τα Changesets εγγυώνται επικύρωση δεδομένων πριν από κάθε εγγραφή. Με 294 schemas, η ομάδα διαχειρίζεται ένα εκτεταμένο domain model — αριθμός που αντικατοπτρίζει την πολυπλοκότητα του επιχειρησιακού τομέα (εκπομπές, τιμολόγηση, πιστοποίηση) και όχι αρχιτεκτονικό over-engineering.

## 9.9 Event sourcing για Energy Bank

Το υποσύστημα Energy Bank αποτελεί αρχιτεκτονικά το πιο σύνθετο τμήμα του συστήματος, επιλέγοντας το μοτίβο *Event Sourcing* σε συνδυασμό με *CQRS (Command Query Responsibility Segregation)*. Η επιλογή αυτή δεν είναι τυχαία: το πρόβλημα της λογιστικής καυσίμων απαιτεί πλήρες ελεγκτικό ίχνος (*audit trail*), δυνατότητα αναπαραγωγής (*event replay*) για επαναϋπολογισμό ισοζυγίων, και αμεταβλητότητα του ιστορικού — ιδιότητες που το event sourcing παρέχει φυσικά.

Η αρχιτεκτονική ακολουθεί το μοτίβο Commands → Aggregates → Events → Projections, υλοποιούμενο με τη βιβλιοθήκη `Commanded` και EventStore backend (αποθήκευση event stream σε PostgreSQL).

Η δομή λειτουργεί ως εξής: ένα **Command** εκφράζει πρόθεση (πχ "ανάληψη ποσότητας ενέργειας"), επικυρώνεται και διαβιβάζεται στο αντίστοιχο **Aggregate** (`ClearingAccount`). Το Aggregate εφαρμόζει τους επιχειρησιακούς κανόνες (πχ ο λογαριασμός πρέπει να έχει επαρκές υπόλοιπο), και αν η επικύρωση επιτύχει, παράγει ένα **Event** (`EnergyWithdrawn`) που αποθηκεύεται αμετάβλητα στο EventStore. Τα Events τροφοδοτούν **Projections** — read models που υπολογίζουν τρέχουσα κατάσταση (πχ τρέχον υπόλοιπο clearing account).

Το παρακάτω listing παρουσιάζει το Command και τον CommandHandler για ανάληψη ενέργειας:

```elixir
defmodule EnergyBank.Application.Transactions.WithdrawEnergy do
  defmodule Command do
    use Ecto.Schema
    import Ecto.Changeset

    @fields [
      :transaction_id,
      :account_id,
      :amount,
      :withdrawn_at,
      :recorded_at
    ]

    @primary_key false
    embedded_schema do
      field :transaction_id, :string
      field :account_id, :string
      field :amount, :decimal
      field :withdrawn_at, :naive_datetime
      field :recorded_at, :naive_datetime
    end

    def new!(attrs) do
      %__MODULE__{}
      |> cast(attrs, @fields)
      |> validate_required(@fields)
      |> apply_action!(:new)
    end
  end

  defmodule CommandHandler do
    alias EnergyBank.Domain.Transactions.Withdrawal

    @behaviour Commanded.Commands.Handler

    @impl Commanded.Commands.Handler
    def handle(state, %Command{} = command) do
      Withdrawal.withdraw(state, command |> Map.from_struct())
    end
  end
end
```

**Listing 9.9.1:** `EnergyBank.Application.Transactions.WithdrawEnergy` — Command και CommandHandler για ανάληψη ενέργειας από clearing account.

Αξίζει να σημειωθεί η διαχωριστική γραμμή ευθύνης: το `Command` module χρησιμοποιεί Ecto για επικύρωση εισόδου (cast, validate_required), ενώ το `CommandHandler` αναθέτει την επιχειρησιακή λογική αποκλειστικά στο `Withdrawal.withdraw/2` domain module. Ο CommandHandler δεν γνωρίζει τίποτα για βάσεις δεδομένων — εφαρμόζει Clean Architecture στο επίπεδο event sourcing.

Ένα ιδιαίτερο χαρακτηριστικό του event sourcing είναι η δυνατότητα *re-projection*: σε περίπτωση αλλαγής επιχειρησιακής λογικής (πχ νέος τρόπος υπολογισμού ισοζυγίου), το σύστημα μπορεί να επαναλάβει ολόκληρο το history των events και να δημιουργήσει εκ νέου τις projections. Αυτό παρέχει ασυνήθιστη ευελιξία για επιχειρησιακά συστήματα που εξελίσσονται παράλληλα με ρυθμιστικές αλλαγές (βλ. Κεφ. 6.3 για επιχειρησιακή περιγραφή).

Μια σημαντική αρχιτεκτονική πτυχή είναι η διαχείριση *eventual consistency* μεταξύ commands και projections: όταν ένα command ολοκληρώνεται επιτυχώς, το αντίστοιχο event εγγράφεται στο EventStore, αλλά η projection ενδέχεται να μην έχει ακόμη ενημερωθεί. Σε scenarios όπου το UI πρέπει να εμφανίσει αμέσως το αποτέλεσμα μιας ενέργειας, απαιτείται μηχανισμός `wait_until` που αναμένει την ενημέρωση της projection. Αυτό αποτελεί ένα από τα πιο λεπτά θέματα σχεδίασης σε event-sourced συστήματα, και η ομάδα το αντιμετωπίζει με ρητή επιλογή ανά feature: τα περισσότερα UI flows αποδέχονται ελάχιστη καθυστέρηση, ενώ κρίσιμες λειτουργίες (πχ επαλήθευση υπολοίπου πριν withdrawal) χρησιμοποιούν σύγχρονη επαλήθευση.

Ο συνδυασμός CQRS με event sourcing επιτρέπει επίσης ανεξάρτητη βελτιστοποίηση read/write paths: τα command paths βελτιστοποιούνται για consistency και atomic writes, ενώ τα query paths (projections) βελτιστοποιούνται για ταχύτητα ανάγνωσης. Για το Energy Bank, αυτό σημαίνει ότι τα reports υπολοίπου clearing accounts ανακτώνται από pre-computed read models, ενώ νέες καταθέσεις/αναλήψεις γράφουν αποκλειστικά στο event stream.

## 9.10 Observability αρχιτεκτονική

Η παρατηρησιμότητα (*observability*) αντιμετωπίζεται αρχιτεκτονικά, όχι ως εκ των υστέρων προσθήκη. Τα τρία επίπεδα — logs, metrics, traces — ενσωματώνονται σε κάθε στρώμα του συστήματος, από το Phoenix request lifecycle ως τους Oban workers και τους Kafka consumers.

**Logs** συλλέγονται μέσω Grafana Loki με LogQL για structured querying. **Metrics** ρέουν μέσω PromEx (βιβλιοθήκη Elixir για Prometheus) → Prometheus → Grafana dashboards. **Traces** προωθούνται μέσω OpenTelemetry σε OpenObserve (self-hosted instance, v0.14.4), με propagation context που διατρέχει HTTP requests, BEAM processes, database queries και Kafka messages. Αυτό επιτρέπει ανίχνευση μιας αίτησης από το LiveView mount ως τις εγγραφές βάσης δεδομένων.

Η στρατηγική alerting υλοποιείται ως κώδικας (*alerts-as-code*) σε YAML, αποθηκευμένος στο αποθετήριο (`alerts/metrics/alerts.yaml`). Το σύστημα ορίζει 13 και πλέον κανόνες ειδοποίησης, κατανεμημένες σε τέσσερις ομάδες σύμφωνα με διαφορετικά επίπεδα κρισιμότητας και χρονικούς ορίζοντες.

Ένας χαρακτηριστικός κανόνας ειδοποίησης που αφορά την ακεραιότητα των δεδομένων:

```yaml
- name: NRG Energy Transition alerts
  interval: 1m
  rules:
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

**Listing 9.10.1:** Alert rule για ανίχνευση υπερβολικής παράλληλης φόρτωσης των External Trade Workbench (ETW) workers.

Ο κανόνας αυτός αξιολογείται κάθε λεπτό και ενεργοποιείται αν εντοπιστούν περισσότερα από 5 ταυτόχρονα requests στο ETW για διάστημα 5 λεπτών. Η ετικέτα `hedwig_scope: nrg-errors-scope` δρομολογεί την ειδοποίηση μέσω Hedwig — εσωτερικό σύστημα ειδοποίησης της Maersk — σε κανάλια Teams και email.

Πέρα από τα τεχνικά alerts (CrashLoopBackOff, cluster unreachability, non-200 spike), το σύστημα παρακολουθεί **επιχειρησιακές μετρικές**:
- Ο Ingestion Worker δεν έχει αναφέρει θετικό count εισαγωγής εντός 72 ωρών.
- Ο Enrichment Worker δεν έχει ολοκληρώσει εργασία εντός 6 ωρών.
- Δεδομένα πλοίων (*Vessel Voyage data*) πιο παλαιά από 49 ώρες.
- Ανεκχώρητες εκπομπές (*unallocated emissions*) άνω του 2%.
- Αποτυχία Energy Bank Projector.

Αυτή η πρακτική — ορισμός ορίων *freshness* για business-critical δεδομένα — αντανακλά την επιχειρησιακή ωριμότητα του συστήματος. Η ανίχνευση ενός stale ingestion worker δεν αποτελεί απλώς τεχνικό alert, αλλά σηματοδοτεί πιθανή επίπτωση στην εγκυρότητα υπολογισμών εκπομπών — εγκυρότητα που κρίνεται από regulators και εξωτερικούς ελεγκτές.

Οι ειδοποιήσεις συνδέονται πάντα με *runbook URLs* στο Atlassian wiki, παρέχοντας στον on-call engineer βήμα-βήμα οδηγίες αποκατάστασης.

Η αρχιτεκτονική telemetry ακολουθεί το Elixir `Telemetry` library pattern: κάθε σημαντικό σημείο του συστήματος εκπέμπει named events (πχ `[:nrg, :ocean, :emissions_calculation, :stop]`) με μετρήσεις και metadata. Το PromEx library συνδέεται αυτόματα σε Phoenix, Ecto και Oban telemetry events, δημιουργώντας Prometheus metrics χωρίς χειροκίνητο instrumentation. Για custom business metrics (πχ `nrg_etw_requests_count`, `nrg_worker_ingestion_sum`), η ομάδα ορίζει ρητά telemetry events στα κατάλληλα σημεία του κώδικα.

Ο distributed tracing μέσω OpenTelemetry παρέχει ένα πλήρες trace για κάθε user request: από το LiveView event handler, μέσω use cases και gateways, ως τα SQL queries και τα Kafka messages. Αυτό επιτρέπει διάγνωση performance bottlenecks που δεν εντοπίζονται από metrics μόνο — πχ αν ένα συγκεκριμένο query αργεί μόνο για συγκεκριμένους πελάτες με μεγάλο αριθμό container moves. Η αρχιτεκτονική παρατηρησιμότητας συνδέεται άμεσα με τις τεχνολογικές επιλογές που αναλύονται στο Κεφ. 8.

## 9.11 Deployment topology

Η τοπολογία ανάπτυξης αντικατοπτρίζει τις αρχές της διαθεσιμότητας, της κλιμάκωσης και της απλότητας λειτουργίας.

**Εισερχόμενος traffic** ακολουθεί την αλυσίδα: Akamai CDN → Stargate (εσωτερικό API gateway Maersk) → Azure Kubernetes Service ingress controller → Kubernetes pods. Το Akamai παρέχει DDoS προστασία και global routing, ενώ το Stargate επιβάλλει εταιρικές πολιτικές ασφαλείας και rate limiting.

**Kubernetes pods** οργανώνονται σε δύο τύπους:
- **3 web server replicas**: εξυπηρέτηση HTTP/WebSocket traffic, Phoenix LiveView connections, certificate downloads.
- **1 worker pod**: background processing — Oban jobs, Kafka consumers, Nrg Worker processes που διαχειρίζεται ο Director.

Ο διαχωρισμός web/worker επιτρέπει ανεξάρτητη κλιμάκωση: αν ο αριθμός των background workers χρειαστεί αύξηση, αλλάζει ο αριθμός replicas του worker pod χωρίς να επηρεαστεί ο web layer.

**Rolling deployments** αποτελούν τον τρόπο ενημέρωσης: το Kubernetes αντικαθιστά σταδιακά τα pods ένα-ένα, εξασφαλίζοντας ότι κάποιες replicas παραμένουν διαθέσιμες καθ' όλη τη διάρκεια. Αυτό, σε συνδυασμό με backward-compatible migrations (βλ. 9.8), επιτρέπει zero-downtime deployments — σημαντικό για ένα σύστημα με 1.300 ενεργούς χρήστες.

Η ανάπτυξη εκτελείται μέσω ενός custom `k8s` binary, wrapper πάνω σε `kubectl` κατασκευασμένο με Nix, που ενσωματώνει εταιρικές πρακτικές ανάπτυξης. Τα GitHub Actions workflows (~20 συνολικά) αυτοματοποιούν τον κύκλο build → test → deploy, με μέσο ρυθμό ~32 deployments ανά ημέρα (βλ. Κεφ. 8 για CI/CD τεχνολογίες).

Το σύστημα λειτουργεί σε δύο ανεξάρτητα περιβάλλοντα: *staging* για επαλήθευση πριν την παραγωγή, και *production* για τους τελικούς χρήστες. Η δομή infrastructure-as-code (Terraform) εξασφαλίζει ότι και τα δύο περιβάλλοντα είναι ισοδύναμα, αποτρέποντας το "works on staging, fails in production" σύνδρομο.

Η ροή ανάπτυξης ακολουθεί trunk-based development: ο κώδικας συγχωνεύεται στο `main` branch, το CI pipeline επικυρώνει (build, test, security scan), και στη συνέχεια γίνεται αυτόματο deploy στο staging, ακολουθούμενο — μετά από επιβεβαίωση — από deploy στο production. Δεδομένου του ρυθμού ~32 deployments ανά ημέρα, η διαδικασία είναι ελαφριά και αυτοματοποιημένη, με ελάχιστη χειροκίνητη παρέμβαση. Αυτή η υψηλή συχνότητα deployments — χαρακτηριστική των XP πρακτικών (βλ. Κεφ. 10) — απαιτεί ισχυρή αυτοματοποίηση, αξιόπιστα test suites και backward-compatible migrations, τρεις αρχιτεκτονικές ιδιότητες που το NRG επενδύει ενεργά να διατηρεί.

## 9.12 Disaster recovery και αναπαραγωγιμότητα

Η αρχιτεκτονική αναπαραγωγιμότητας του NRG βασίζεται σε τρεις αλληλοσυμπληρούμενες αρχές: υποδομή ως κώδικας, αναπαραγώγιμες κατασκευές (*reproducible builds*) και δοκιμασμένη αποκατάσταση.

**Υποδομή ως κώδικας μέσω Terraform:** Ολόκληρη η υποδομή Azure (databases, AKS cluster, storage accounts, networking) ορίζεται σε 57 αρχεία `.tf`. Σε περίπτωση καταστροφικής αποτυχίας, η υποδομή μπορεί να ανοικοδομηθεί από μηδενική βάση εκτελώντας `terraform apply`. Αυτό δεν αποτελεί θεωρητική δυνατότητα — η ομάδα έχει επαληθεύσει αυτή τη διαδικασία κατά τη μετεγκατάσταση Kubernetes clusters (βλ. guide `migrating-kubernetes-clusters.md`).

**Αναπαραγώγιμες κατασκευές μέσω Nix:** Το `flake.nix` ορίζει κλειδωμένες (*locked*) εξαρτήσεις για όλα τα εργαλεία ανάπτυξης, εξασφαλίζοντας ότι κάθε μέλος της ομάδας και κάθε CI runner χρησιμοποιεί ακριβώς την ίδια έκδοση εργαλείων. Αυτό εξαλείφει μια ολόκληρη κατηγορία σφαλμάτων ("it works on my machine") και απλοποιεί σημαντικά το onboarding νέων μελών.

**Δοκιμασμένη αποκατάσταση βάσης δεδομένων:** Εβδομαδιαία αυτοματοποιημένη επαλήθευση αντιγράφων ασφαλείας μέσω του workflow `db-restore-from-backup.yml`. Η αποκατάσταση χρησιμοποιεί *Point-In-Time Recovery (PITR)* της Azure, επιτρέποντας επαναφορά της βάσης σε οποιοδήποτε χρονικό σημείο εντός του παραθύρου διατήρησης.

Τα ενδεικτικά μεγέθη αποκατάστασης — αν και δεν έχουν δοκιμαστεί σε πλήρη αποτυχία AKS cluster — εκτιμώνται ως εξής:
- **RTO (Recovery Time Objective):** Υποδομή ~2 ώρες (Terraform apply), εφαρμογή ~30 λεπτά (Kubernetes deploy), βάση δεδομένων από PITR ~1 ώρα.
- **RPO (Recovery Point Objective):** Ελάχιστη απώλεια δεδομένων λόγω PITR και continuous backups.

Σε σενάρια μερικής αποτυχίας (πχ αποτυχία ενός pod), το Kubernetes αντιμετωπίζει αυτόματα την κατάσταση μέσω health checks και αντικατάσταση pods. Τα `CrashLoopBackOff` alerts (30 δευτερόλεπτα interval) εξασφαλίζουν ότι η ομάδα ειδοποιείται άμεσα για επανεκκινούμενα pods, ενώ τα runbooks παρέχουν δομημένη διαδικασία διερεύνησης και αποκατάστασης.

Η συνολική αρχιτεκτονική αναπαραγωγιμότητας υπηρετεί και σκοπούς ελέγχου: ο εσωτερικός έλεγχος GIA του 2023 (βλ. Κεφ. 2.7) έθεσε ρητά απαιτήσεις για *audit trail*, *data tracking* και *reproducibility*. Το συνδυασμένο χαρτοφυλάκιο event sourcing (Energy Bank), immutable migrations, automated backup tests και Terraform IaC παρέχει τεχνικές εγγυήσεις για κάθε μια από αυτές τις απαιτήσεις.

Αξίζει τέλος να σημειωθεί η ευρύτερη αρχιτεκτονική φιλοσοφία που διαπερνά το σύστημα: η επιλογή ώριμων, καλά κατανοητών τεχνολογιών (PostgreSQL, Kafka, Kubernetes, Terraform) αντί για cutting-edge λύσεις μειώνει τον λειτουργικό κίνδυνο σε ένα σύστημα production-critical. Η BEAM/Elixir αποτελεί αξιοσημείωτη εξαίρεση — μια τεχνολογική στοιχηματοποίηση που, τρία χρόνια μετά, φαίνεται να αποδίδει: το σύστημα διαχειρίζεται αδιαλείπτως 1.300 χρήστες, εκπέμπει ~32 deployments ανά ημέρα, και παράγει εμπορικές εκροές αξίας $31 εκατομμυρίων, χωρίς να έχει υπάρξει ανάγκη για horizontal scaling πέραν των τριών web replicas — μαρτυρία της εγγενούς αποδοτικότητας της BEAM αρχιτεκτονικής (βλ. Κεφ. 8 για αναλυτική συζήτηση τεχνολογικών επιλογών).
