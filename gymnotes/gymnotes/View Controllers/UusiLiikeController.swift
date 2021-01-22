import UIKit
import CoreData

protocol OhjelmaJaTreeniTakaisin {}

class UusiLiikeController: UIViewController, UITableViewDelegate, UITableViewDataSource, OhjelmaJaTreeniTakaisin {

    var stepper : UIStepper!
    var liikkeenNimi = UITextField()
    var muuttunutSarjaMaara: Int = 0
    var i: Int = 0
    var uusiLiikeTunniste: Bool = true
    var tyhjyysTunniste: Bool = false
    var ojaTjohonLisataanTreeni: OjaTjohonLisataanTreeni?
    var ohjelmaJohonLisays: String = ""
    var treeniJohonLisays: String = ""
    var liikeJotaMuokataan: String = ""
    var sarjat: [NSManagedObject] = []
    var managedObjectContext: NSManagedObjectContext? { return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
    var sarjojenPituudet =  ["","","","","",""]
    var muokattavanLiikkeenNimi: String = ""
    var sarjaJohonErikoistekniikka: String = ""
    var valittuTekniikka: String = ""

    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    override func viewDidLoad() { // luo näkymän

        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        self.view.addSubview(imagePaluu)
        self.view.addSubview(liikkeenLisaysOtsikko)
        self.view.addSubview(kehikko)
        self.view.addSubview(tallennusNappi)
        self.view.addSubview(peruutaNappi)
        self.view.addSubview(paluuButton)
        self.view.addSubview(imagePaluu)
        self.view.addSubview(viiva)
        self.view.addSubview(tableView)
        makeLiikkeenNimiTxt()
        
        tableView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SarjaCell")
        tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: "sarja_otsikko")
        tableView.sectionHeaderHeight = 50
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        
        setUpConstraints()
    }
    
    func setUpConstraints(){ // tekee autolayotit näkymälle
        
        paluuButton.translatesAutoresizingMaskIntoConstraints = false
        paluuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        paluuButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        imagePaluu.translatesAutoresizingMaskIntoConstraints = false
        imagePaluu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        imagePaluu.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        peruutaNappi.translatesAutoresizingMaskIntoConstraints = false
        peruutaNappi.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        peruutaNappi.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        peruutaNappi.heightAnchor.constraint(equalToConstant: 90).isActive = true
        peruutaNappi.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        tallennusNappi.translatesAutoresizingMaskIntoConstraints = false
        tallennusNappi.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        tallennusNappi.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        tallennusNappi.heightAnchor.constraint(equalToConstant: 90).isActive = true
        tallennusNappi.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: kehikko.bottomAnchor, constant: -2).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -9).isActive = true
        
        liikkeenLisaysOtsikko.translatesAutoresizingMaskIntoConstraints = false
        liikkeenLisaysOtsikko.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -45).isActive = true
        liikkeenLisaysOtsikko.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        kehikko.translatesAutoresizingMaskIntoConstraints = false
        kehikko.topAnchor.constraint(equalTo: tableView.topAnchor, constant: -40).isActive = true
        kehikko.bottomAnchor.constraint(equalTo: peruutaNappi.topAnchor, constant: -20).isActive = true
        kehikko.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        kehikko.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        
        paluuButton.translatesAutoresizingMaskIntoConstraints = false
        paluuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        paluuButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        imagePaluu.translatesAutoresizingMaskIntoConstraints = false
        imagePaluu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        imagePaluu.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        let ohjelmaJohonLisaysLabel: UILabel = makeOhjelmaJohonLisaysLabel()
        let treeniJohonLisaysLabel: UILabel = makeTreeniJohonLisaysLabel()
        self.view.addSubview(ohjelmaJohonLisaysLabel)
        self.view.addSubview(treeniJohonLisaysLabel)
        
        ohjelmaJohonLisaysLabel.translatesAutoresizingMaskIntoConstraints = false
        ohjelmaJohonLisaysLabel.centerYAnchor.constraint(equalTo: imagePaluu.centerYAnchor , constant: 0).isActive = true
        ohjelmaJohonLisaysLabel.centerXAnchor.constraint(equalTo: paluuButton.trailingAnchor, constant: 70).isActive = true
        
        treeniJohonLisaysLabel.translatesAutoresizingMaskIntoConstraints = false
        treeniJohonLisaysLabel.centerYAnchor.constraint(equalTo: imagePaluu.centerYAnchor , constant: 0).isActive = true
        treeniJohonLisaysLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 70).isActive = true
        
        viiva.translatesAutoresizingMaskIntoConstraints = false
        viiva.topAnchor.constraint(equalTo: paluuButton.bottomAnchor, constant: -25).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) { // tuo näkymään tiedot sen avautuessa
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sarja")
        let filter = NSPredicate(format: "liike.nimi == %@", liikeJotaMuokataan)
        
        super.viewWillAppear(animated)
    
        if(liikeJotaMuokataan != ""){
            liikkeenNimi.text = liikeJotaMuokataan
            
            fetchRequest.predicate = filter
        }else{
            uusiLiikeTunniste = true
            fetchRequest.predicate = filter
        }
        do{
          sarjat = try managedContext.fetch(fetchRequest)
        }catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // rakentaa taulukon solut
       
        let sarja = sarjat[indexPath.row]
        let sarjacell = tableView.dequeueReusableCell(withIdentifier: "SarjaCell", for: indexPath)
        sarjacell.textLabel?.text = sarja.value(forKeyPath: "nimi") as? String
        sarjacell.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        sarjacell.separatorInset = UIEdgeInsets.zero
        sarjacell.layoutMargins = UIEdgeInsets.zero
        sarjacell.selectionStyle = .none
        sarjacell.textLabel?.font = UIFont(name: "Copperplate", size: 26)
        
        sarjacell.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        sarjacell.textLabel?.centerYAnchor.constraint(equalTo: sarjacell.centerYAnchor, constant: 0).isActive = true
        sarjacell.textLabel?.leadingAnchor.constraint(equalTo: sarjacell.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        
        let toistotLabel = UILabel()
        toistotLabel.text = " toistot:"
        toistotLabel.textColor = UIColor.black
        toistotLabel.font = UIFont(name: "CopperPlate", size: 26)
        
        sarjacell.addSubview(toistotLabel)
        toistotLabel.translatesAutoresizingMaskIntoConstraints = false
        toistotLabel.centerYAnchor.constraint(equalTo: sarjacell.centerYAnchor, constant: 0).isActive = true
        toistotLabel.leadingAnchor.constraint(equalTo: sarjacell.textLabel!.trailingAnchor, constant: 0).isActive = true
        
        let etbutton = UIButton()
        var kuva = UIImage()
        kuva = UIImage(systemName: "plus.bubble")!
        kuva = kuva.imageWithColor(color1: UIColor.black)
        kuva = kuva.resized(to: CGSize(width: 55, height: 55))
        etbutton.setImage(kuva, for: .normal)
        etbutton.addTarget(self, action: #selector(erikoistekniikkaValikko), for: .touchUpInside)
        etbutton.tag = indexPath.row
        sarjacell.addSubview(etbutton)
        
        etbutton.translatesAutoresizingMaskIntoConstraints = false
        etbutton.centerYAnchor.constraint(equalTo: sarjacell.centerYAnchor, constant: 0).isActive = true
        etbutton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        etbutton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        etbutton.trailingAnchor.constraint(equalTo: sarjacell.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        let vari = #colorLiteral(red: 0.3686, green: 0.6667, blue: 0.7569, alpha: 1) /* #5eaac1 */
        let toistolkm = UITextField()
        toistolkm.backgroundColor = vari
        toistolkm.keyboardAppearance = .dark
        toistolkm.layer.borderWidth = 1
        toistolkm.layer.cornerRadius = 7
        toistolkm.textAlignment = .center
        toistolkm.keyboardType = UIKeyboardType.numbersAndPunctuation
        toistolkm.tag = indexPath.row
        toistolkm.addTarget(self, action: #selector(textFieldEdited), for: UIControl.Event.editingDidEnd)
        
        if(sarja.value(forKey: "pituus") != nil){
            toistolkm.text = sarja.value(forKeyPath: "pituus") as? String
            sarjojenPituudet[toistolkm.tag] = toistolkm.text!
        }

        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkText, .paragraphStyle: centeredParagraphStyle]
        toistolkm.attributedPlaceholder = NSAttributedString(string: "0", attributes: attributes)
       
        sarjacell.addSubview(toistolkm)
        toistolkm.translatesAutoresizingMaskIntoConstraints = false
        toistolkm.centerYAnchor.constraint(equalTo: sarjacell.centerYAnchor, constant: 0).isActive = true
        if(UIScreen.main.bounds.width<400){
            toistolkm.trailingAnchor.constraint(equalTo: etbutton.leadingAnchor, constant: -15).isActive = true
        }else{
            toistolkm.trailingAnchor.constraint(equalTo: etbutton.leadingAnchor, constant: -30).isActive = true
        }
        toistolkm.heightAnchor.constraint(equalToConstant: 40).isActive = true
        toistolkm.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        let tekniikkaLabel = UILabel()
        tekniikkaLabel.font = UIFont(name: "CopperPlate-Bold", size: 16)
        sarjacell.addSubview(tekniikkaLabel)
                
        tekniikkaLabel.translatesAutoresizingMaskIntoConstraints = false
        tekniikkaLabel.centerYAnchor.constraint(equalTo: etbutton.topAnchor, constant: -10).isActive = true
        tekniikkaLabel.centerXAnchor.constraint(equalTo: etbutton.centerXAnchor, constant: 0).isActive = true
        
        func peiteLisays(){ // peittää edeltävän erikoistekniikan
            let peite = UILabel()
            peite.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
            sarjacell.addSubview(peite)
            peite.translatesAutoresizingMaskIntoConstraints = false
            peite.centerYAnchor.constraint(equalTo: etbutton.topAnchor, constant: -10).isActive = true
            peite.centerXAnchor.constraint(equalTo: etbutton.centerXAnchor, constant: 0).isActive = true
            peite.heightAnchor.constraint(equalToConstant: 20).isActive = true
            peite.widthAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        func erikoistekniikkaTeksti(nimi: String){ // lisää erikoistekniikka tekstin soluun
            if tekniikkaLabel.text != "" {
                peiteLisays()
                sarjacell.addSubview(tekniikkaLabel)
            }
            tekniikkaLabel.text = nimi
        }
        
        if( sarja.value(forKeyPath: "sarja_erikoistekniikka") as? String == "Pakkotoisto" ){
            erikoistekniikkaTeksti(nimi: "PT")
        }
        if( sarja.value(forKeyPath: "sarja_erikoistekniikka") as? String == "Rest Pause" ){
            erikoistekniikkaTeksti(nimi: "RP")
        }
        if( sarja.value(forKeyPath: "sarja_erikoistekniikka") as? String == "Drop" ){
            erikoistekniikkaTeksti(nimi: "DROP")
        }
        if( sarja.value(forKeyPath: "sarja_erikoistekniikka") as? String == "" && tekniikkaLabel.text != "" ){
            peiteLisays()
        }
        
        sarjaCellKoot()
    
        return sarjacell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { // sallii taulukon rivien muokkauksen
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // palauttaa taulukon rivien määrän
        return sarjat.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{ // yhdistää otsikon taulukkoon
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "sarja_otsikko")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { // palauttaa osien määrän
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // funktio jota kutsutaan kun taulukon solua painetaan
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) { // määrittää otsikon värejä
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor(white: 0.5, alpha: 1.0)
    }
    
    func sarjaCellKoot(){ // määrittää solujen koot eri kokoisille näytöille
        
        if UIScreen.main.bounds.height > 1000{
            self.tableView.rowHeight = 150.0
            self.tableView.isScrollEnabled = false
        }
        
        if UIScreen.main.bounds.height < 900 && UIScreen.main.bounds.height > 700{
            self.tableView.rowHeight = 100.0
            
            if(sarjat.count == 6){
                self.tableView.isScrollEnabled = true
            }else{
                self.tableView.isScrollEnabled = false
            }
        }
        
        if UIScreen.main.bounds.height < 700{
            
            if(sarjat.count == 1){
                self.tableView.rowHeight = 100.0
                self.tableView.isScrollEnabled = false
            }
            if(sarjat.count == 2){
                self.tableView.rowHeight = 100.0
                self.tableView.isScrollEnabled = false
            }
            if(sarjat.count == 3){
                self.tableView.rowHeight = 100.0
                self.tableView.isScrollEnabled = false
            }
            if(sarjat.count == 4){
                self.tableView.rowHeight = 75.0
                self.tableView.isScrollEnabled = false
            }
            if(sarjat.count == 5){
                self.tableView.rowHeight = 70.0
                self.tableView.isScrollEnabled = true
            }
            if(sarjat.count == 6){
                self.tableView.rowHeight = 65.0
                self.tableView.isScrollEnabled = true
            }
        }
    }
    
    @objc func erikoistekniikkaValikko(sender: UIButton){ // avaa erikoistekniikka valikon
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
        
        let cell = tableView.cellForRow(at: indexPath)
        sarjaJohonErikoistekniikka = (cell?.textLabel!.text!)!
        
        let alert = UIAlertController(title: "Valitse erikoistekniikka sarjaan \(sender.tag+1)", message: "", preferredStyle: .alert)
        alert.view.tintColor = UIColor.black
        
        let action1 = UIAlertAction(title: "Rest Pause", style: .default, handler: { action in self.valittuTekniikka = "Rest Pause" ; self.erikoistekniikkaLisays() ; self.tableView.reloadData()})
        let action2 = UIAlertAction(title: "Drop", style: .default, handler: { action in self.valittuTekniikka = "Drop" ; self.erikoistekniikkaLisays() ; self.tableView.reloadData()})
        let action3 = UIAlertAction(title: "Pakkotoisto", style: .default, handler: { action in self.valittuTekniikka = "Pakkotoisto" ; self.erikoistekniikkaLisays() ; self.tableView.reloadData()})
        let action4 = UIAlertAction(title: "Poista erikoistekniikka", style: .default, handler: { action in self.valittuTekniikka = "" ; self.erikoistekniikkaLisays() ; self.tableView.reloadData()})
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
        
        func erikoistekniikkaLisays(){ // lisää erikoistekniikan sarjaan
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sarja")
            let filter = NSPredicate(format: "nimi == %@", sarjaJohonErikoistekniikka)
            let filter2 = NSPredicate(format: "liike.nimi == %@", liikeJotaMuokataan)
            let filter3 = NSPredicate(format: "liike.treeni.nimi == %@", treeniJohonLisays)
            let filter4 = NSPredicate(format: "liike.treeni.ohjelma.nimi == %@", ohjelmaJohonLisays)
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [filter, filter2, filter3, filter4])
            fetchRequest.predicate = compound
            
            let uusinRequest = NSFetchRequest<NSManagedObject>(entityName: "Sarja")
            let filter6 = NSPredicate(format: "nimi == %@", sarjaJohonErikoistekniikka)
            let predicate5 = NSPredicate(format: "liike.uusin_tunniste == %@", NSNumber(value: true))
            let compound2 = NSCompoundPredicate(andPredicateWithSubpredicates: [filter6, predicate5])
            uusinRequest.predicate = compound2
        
        do {
            let haettuSarja = try managedContext.fetch(fetchRequest)
            
            if(haettuSarja.count>0){
                let sarja = haettuSarja.first
                sarja?.setValue(valittuTekniikka, forKey: "sarja_erikoistekniikka")
                savekaikki()
            }else{
                do{
                    let haettuUusin = try managedContext.fetch(uusinRequest)
                    
                    if(haettuUusin.count>0){
                        let uusin = haettuUusin.first
                        uusin?.setValue(valittuTekniikka, forKey: "sarja_erikoistekniikka")
                        savekaikki()
                        valittuTekniikka = ""
                    }else{
                        print("ei löytynyt uuttakaan")
                    }
                    
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    @objc func textFieldEdited(sender: UITextField){ // lukee sarjalle syötetyn pituuden
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
        let text = sender.text
        sarjojenPituudet[sender.tag] = text!
        saveSarjaPituudet()
    }
    
    func savekaikki(){ // tallentaa dataan tehdyt muutokset
         
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
    
        do{
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func removeSarja(at offsets: IndexSet) { // poistaa sarjan taulukosta ja muistista

        if(sarjat.count>0){
        let indexPath = IndexPath(row: sarjat.count-1, section: 0)
        let poistosarja = sarjat[indexPath.row]
        managedObjectContext?.delete(poistosarja)
        sarjat.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        }else{
            print("Ei sarjoja joita poistaa")
        }
    }
    
    @objc func addSarja(_ sender: UIStepper) { // erottelee stepperin miinus ja plus painallukset ja käskee sen mukaan

        if(liikkeenNimi.text! != ""){
            
            if sender.value == 1.0{
                
                if(sarjat.count<6){
                    muuttunutSarjaMaara=muuttunutSarjaMaara+1
                    let sarjaToSave = "Sarja \(sarjat.count+1)"
                    saveSarjaLiikkeeseen(name: sarjaToSave)
                    tableView.reloadData()
                }else{
                    let alert = UIAlertController(title: "Sarjojen maksimimäärä on 6.", message: "", preferredStyle: UIAlertController.Style.alert)
                    alert.view.tintColor = UIColor.black
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }else if sender.value == 0.0 {
                removeSarja(at: [sarjat.count] )
                muuttunutSarjaMaara=muuttunutSarjaMaara-1
                self.savekaikki()
                tableView.reloadData()
            }
      }else{
        let alert = UIAlertController(title: "Syötä liikkeelle nimi ensin.", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = UIColor.black
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
      }
        sender.value = 0
        
        sarjaCellKoot()

    }
    
    @objc func addPerututSarja() { // lisää jo poistetut sarjat takaisin
                    
        if(sarjat.count<6){
                        
            let sarjaToSave = "Sarja \(sarjat.count+1)"
            self.saveSarjaLiikkeeseen(name: sarjaToSave)
            self.tableView.reloadData()
        }
            sarjaCellKoot()
    }
    
    func LiikeTreeniin() { // tallentaa liikkeen sen omaan treeniin

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Treeni")
        let predicate1 = NSPredicate(format: "ohjelma.nimi == %@", ohjelmaJohonLisays)
        let predicate2 = NSPredicate(format: "nimi == %@", treeniJohonLisays)
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        request.predicate = compound
        
        let liikeRequest = NSFetchRequest<NSManagedObject>(entityName: "Liike")
        let liikePredicate = NSPredicate(format: "nimi == %@", liikeJotaMuokataan)
        let liikePredicate2 = NSPredicate(format: "treeni.nimi == %@", treeniJohonLisays)
        let liikePredicate3 = NSPredicate(format: "treeni.ohjelma.nimi == %@", ohjelmaJohonLisays)
        let liikecompound = NSCompoundPredicate(andPredicateWithSubpredicates: [liikePredicate, liikePredicate2, liikePredicate3])
        liikeRequest.predicate = liikecompound
        
        do{
            let haettuLiike = try managedContext.fetch(liikeRequest)
                    
                if(haettuLiike.count > 0){
                    print("Ohjelma, Treeni sekä liike löytyi.")
                }else{
                    let uusinRequest = NSFetchRequest<NSManagedObject>(entityName: "Liike")
                    let predicate5 = NSPredicate(format: "uusin_tunniste == %@", NSNumber(value: true))
                    uusinRequest.predicate = predicate5
                    
                    do{
                        let haettuUusin = try managedContext.fetch(uusinRequest)
                        let haettuTreeni = try managedContext.fetch(request)

                        if(haettuUusin.count>0){
                            let uusinLiike = haettuUusin.first!
                            
                            if(haettuTreeni.count>0){
                                let treeniJohonLisataanUusin = haettuTreeni.first!
                                treeniJohonLisataanUusin.mutableSetValue(forKey: "liikkeet").add(uusinLiike)
                                uusinLiike.setValue(true, forKey: "poisto_tunniste")
                                uusinLiike.setValue(false, forKey: "uusin_tunniste")
                                muokattavanLiikkeenNimi=""
                                savekaikki()
                            }
                        }else{
                            print("ei löydy uusin tunnisteella")
                        }
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
                }
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
    }
    
    func saveSarjaPituudet() { // tallentaa sarjojen pituudet muistiin
        
        if(sarjat.count>0){
        let maara: Int = sarjat.count
            
            for index in 0...maara-1{
            let kohdesarja = sarjat[index]
            kohdesarja.setValue(sarjojenPituudet[index], forKey: "pituus")
            }
            savekaikki()

        }
    }
    
    func saveSarjaLiikkeeseen(name: String) { // tallentaa sarjan sen liikkeeseen
      
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      let managedContext = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSManagedObject>(entityName: "Liike")
      let predicate = NSPredicate(format: "nimi == %@", liikkeenNimi.text!)
      let predicate2 = NSPredicate(format: "treeni.nimi == %@", treeniJohonLisays)
      let predicate3 = NSPredicate(format: "treeni.ohjelma.nimi == %@", ohjelmaJohonLisays)
      let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2, predicate3])
      request.predicate = compound
        
      let uusinRequest = NSFetchRequest<NSManagedObject>(entityName: "Liike")
      let predicate5 = NSPredicate(format: "uusin_tunniste == %@", NSNumber(value: true))
      uusinRequest.predicate = predicate5
        
      let sarja = Sarja(context: managedContext)
      sarja.nimi = name
    
        do{
            let haettuLiike = try managedContext.fetch(request)
            
            if(haettuLiike.count > 0){
                let liikeMuutos = haettuLiike.first!
                liikeMuutos.mutableSetValue(forKey: "sarjat").add(sarja)
                tableView.reloadData()
                savekaikki()
            }
            else{
                
                if(sarjat.count>0){
                    let haettuUusiLiike = try managedContext.fetch(uusinRequest)
                    
                    if(haettuUusiLiike.count>0){
                        let uudeksiMerkittyLiike = haettuUusiLiike.first!
                        uudeksiMerkittyLiike.mutableSetValue(forKey: "sarjat").add(sarja)
                        savekaikki()
                    }
                }else{
                    let liike = Liike(context: managedContext)
                    liike.nimi = liikkeenNimi.text!
                    muokattavanLiikkeenNimi = liikkeenNimi.text!
                    liike.addToSarjat(sarja)
                    liike.uusin_tunniste = true
                    savekaikki()
                }
            }
          } catch let error as NSError {
             print("Could not fetch \(error), \(error.userInfo)")
          }
        sarjat.append(sarja)
    }
    
    
class Header: UITableViewHeaderFooterView { // luokka taulukon otsikolle
    
    var uusiLiikeController: UusiLiikeController?
        
    override init(reuseIdentifier: String?){
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let stepper: UIStepper = {
        
        let sarjastepper = UIStepper()
        sarjastepper.tintColor = UIColor(white: 0.5, alpha: 1.0)
        sarjastepper.value = 0
        sarjastepper.minimumValue = 0
        sarjastepper.maximumValue = 5
        sarjastepper.stepValue = 1
        sarjastepper.layer.borderWidth = 1
        return sarjastepper
    }()
    
    let sarjatLabel: UILabel = {
        
        let sarjatLabel =  UILabel()
        sarjatLabel.text = "Sarjat"
        sarjatLabel.font = UIFont(name: "Copperplate", size: 26)
        sarjatLabel.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        return sarjatLabel
    }()
    
    let viiva1: UILabel = {
        
        let viiva = UILabel()
        viiva.text = "______________________________________________________"
        viiva.textColor = UIColor.black
        viiva.font = UIFont(name: "CopperPlate-Bold", size: 38)
        return viiva
    }()
        
    func setupViews(){ // rakentaa otsikko näkymän
        
        addSubview(sarjatLabel)
        addSubview(stepper)
        addSubview(viiva1)
            
        stepper.addTarget(uusiLiikeController, action: #selector(addSarja), for: .touchUpInside)
        
        viiva1.translatesAutoresizingMaskIntoConstraints = false
        viiva1.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 7).isActive = true
        viiva1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        
        sarjatLabel.translatesAutoresizingMaskIntoConstraints = false
        sarjatLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -100).isActive = true
        sarjatLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 100).isActive = true
        stepper.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
    }
    
}
    
    func makeOhjelmaJohonLisaysLabel() -> UILabel { // tekee nimikkeen ohjelmalle johon liikettä lisätään
        
        let ohjelmaJohonLisaysLabel = UILabel()
        ohjelmaJohonLisaysLabel.text = ohjelmaJohonLisays
        ohjelmaJohonLisaysLabel.textColor = UIColor.black
        ohjelmaJohonLisaysLabel.font = UIFont(name: "CopperPlate-Bold", size: 20)
        return ohjelmaJohonLisaysLabel
    }
    
    func makeTreeniJohonLisaysLabel() -> UILabel { // tekee nimikkeen treenille johon liikettä lisätään
        
        let treeniJohonLisaysLabel = UILabel()
        treeniJohonLisaysLabel.text = treeniJohonLisays
        treeniJohonLisaysLabel.textColor = UIColor.black
        treeniJohonLisaysLabel.font = UIFont(name: "CopperPlate-Bold", size: 20)
        return treeniJohonLisaysLabel
    }
    
    let viiva: UILabel = {
        
        let viiva = UILabel()
        viiva.frame = CGRect(x: 0, y: 3, width: 600, height: 100)
        viiva.text = "__________________________________________________________"
        viiva.textColor = UIColor.black
        viiva.font = UIFont(name: "CopperPlate", size: 38)
        return viiva
    }()
    
    let paluuButton: UIButton = {
        
        let paluuNappi = UIButton(type: UIButton.ButtonType.system)
        paluuNappi.tag = 0
        paluuNappi.addTarget(self, action: #selector(PalaaUusiOhjelmaSivulle), for: .touchUpInside)
        return paluuNappi
    }()
    
    let imagePaluu: UIImageView = {
        
        let imagePaluu = UIImageView()
        imagePaluu.image = UIImage(systemName: "chevron.left")
        imagePaluu.image = imagePaluu.image?.resized(to: CGSize(width: 30, height: 30))
        imagePaluu.setImageColor(color: UIColor.black)
        imagePaluu.contentMode = .scaleAspectFit
        return imagePaluu
    }()
    
    let liikkeenLisaysOtsikko: UILabel = {
        
        let liikkeenLisaysOtsikko = UILabel()
        liikkeenLisaysOtsikko.text = "LIIKKEEN LISÄYS"
        liikkeenLisaysOtsikko.textColor = UIColor.black
        liikkeenLisaysOtsikko.font = UIFont(name: "CopperPlate", size: 20)
        return liikkeenLisaysOtsikko
    }()
    
    let kehikko: UILabel = {
        
        let kehikko = UILabel()
        kehikko.layer.borderWidth = 2.1
        return kehikko
    }()
    
    func makeLiikkeenNimiTxt(){ // tekee tekstikentän johon liikkeen nimi syötetään
    
        let vari = #colorLiteral(red: 0.3686, green: 0.6667, blue: 0.7569, alpha: 1) /* #5eaac1 */
        liikkeenNimi = UITextField()
        liikkeenNimi.backgroundColor = vari
        liikkeenNimi.borderStyle = .line
        liikkeenNimi.font = UIFont(name: "", size: 20)
        liikkeenNimi.keyboardAppearance = .dark
        liikkeenNimi.layer.borderWidth = 2.1
        liikkeenNimi.textAlignment = .center
        liikkeenNimi.becomeFirstResponder()
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkText]
        liikkeenNimi.attributedPlaceholder = NSAttributedString(string: "Syötä liikkeen nimi", attributes: attributes)
        self.hideKeyboardWhenTappedAround()
        view.addSubview(liikkeenNimi)
        
        liikkeenNimi.translatesAutoresizingMaskIntoConstraints = false
        liikkeenNimi.topAnchor.constraint(equalTo: kehikko.topAnchor, constant: 0).isActive = true
        liikkeenNimi.bottomAnchor.constraint(equalTo: kehikko.topAnchor, constant: 40).isActive = true
        liikkeenNimi.leadingAnchor.constraint(equalTo: kehikko.leadingAnchor, constant: 0).isActive = true
        liikkeenNimi.trailingAnchor.constraint(equalTo: kehikko.trailingAnchor, constant: 0).isActive = true
    }
    
    let tallennusNappi: UIButton = {
        
        let vari = #colorLiteral(red: 0.3137, green: 0.4667, blue: 0.3216, alpha: 1) /* #507752 */
        let tallennusNappi = UIButton(type: UIButton.ButtonType.system)
        tallennusNappi.frame = CGRect(x: 181, y: 550, width: 178, height: 80)
        tallennusNappi.setTitle("TALLENNA", for: .normal)
        tallennusNappi.setTitleColor(.black, for: .normal)
        tallennusNappi.titleLabel?.font = UIFont(name: "CopperPlate-Bold", size: 20)
        tallennusNappi.backgroundColor = vari
        tallennusNappi.layer.borderWidth = 1.0
        tallennusNappi.tag = 1
        tallennusNappi.addTarget(self, action: #selector(PalaaUusiOhjelmaSivulleTallennus), for: .touchUpInside)
        return tallennusNappi
    }()
           
    let peruutaNappi: UIButton = {
        
        let vari = #colorLiteral(red: 0.6784, green: 0.1529, blue: 0.1529, alpha: 1) /* #ad2727 */
        let peruutaNappi = UIButton(type: UIButton.ButtonType.system)
        peruutaNappi.frame = CGRect(x: 11, y: 550, width: 178, height: 80)
        peruutaNappi.setTitle("PERUUTA", for: .normal)
        peruutaNappi.setTitleColor(.black, for: .normal)
        peruutaNappi.titleLabel?.font = UIFont(name: "CopperPlate-Bold", size: 20)
        peruutaNappi.backgroundColor = vari
        peruutaNappi.layer.borderWidth = 1.0
        peruutaNappi.tag = 0
        peruutaNappi.addTarget(self, action: #selector(PalaaUusiOhjelmaSivulle), for: .touchUpInside)
        return peruutaNappi
    }()
    
    @objc func PalaaUusiOhjelmaSivulle(sender: UIButton){ // palaa uusiohjelma näkymään
        
        let uusiv = UusiOhjelmaController()
        uusiv.ohjelmaJaTreeniTakaisin = self
        uusiv.takaisinTullutOhjelma = ohjelmaJohonLisays
        uusiv.takaisinTullutTreeni = treeniJohonLisays
        uusiv.tyhjyysTunniste = tyhjyysTunniste
        uusiv.modalPresentationStyle = .fullScreen
        
        if(sender.tag == 0){
        let alert = UIAlertController(title: "Oletko varma, että haluat peruuttaa lisäyksen?", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.view.tintColor = UIColor.black
        self.present(alert, animated: true, completion: nil)
            
            func poisto(){
                
                if(uusiLiikeTunniste == true){
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    let managedContext = appDelegate.persistentContainer.viewContext
                    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Liike")
                    let filter = NSPredicate(format: "nimi == %@", liikkeenNimi.text! )
                    let predicate5 = NSPredicate(format: "uusin_tunniste == %@", NSNumber(value: true))
                    let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [filter, predicate5])
                    fetchRequest.predicate = compound
                      
                    do {
                        let haettuLiike = try managedContext.fetch(fetchRequest)
                        
                        if(haettuLiike.count>0){
                            let poistettavaLiike = haettuLiike.first
                            managedObjectContext?.delete(poistettavaLiike!)
                            savekaikki()
                            uusiLiikeTunniste = false
                            self.present(uusiv, animated: true, completion: nil)
                        }else{
                            self.present(uusiv, animated: true, completion: nil)
                        }
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                
                }else{
                print(muuttunutSarjaMaara)
                if(muuttunutSarjaMaara<0){
                    for _ in muuttunutSarjaMaara...(-1) {
                         addPerututSarja()
                    }
                }else if(muuttunutSarjaMaara>0){
                    for _ in 1...muuttunutSarjaMaara{
                        removeSarja(at: [sarjat.count])
                    }
                }
                self.present(uusiv, animated: true, completion: nil)
                }
            }
        
        alert.addAction(UIAlertAction(title: "Kyllä", style: UIAlertAction.Style.default, handler: { action in  poisto() }))
        alert.addAction(UIAlertAction(title: "Ei", style: UIAlertAction.Style.cancel, handler: nil))
        }else{
            self.present(uusiv, animated: true, completion: nil)
        }

    }
    
    @objc func PalaaUusiOhjelmaSivulleTallennus(){ // palaa uusiohjelma näkymään ja tallentaa tiedot ennen sitä
        
        var testi = false
        let uusiv = UusiOhjelmaController()
        uusiv.ohjelmaJaTreeniTakaisin = self
        uusiv.takaisinTullutOhjelma = ohjelmaJohonLisays
        uusiv.takaisinTullutTreeni = treeniJohonLisays
        uusiv.tyhjyysTunniste = tyhjyysTunniste
        uusiv.modalPresentationStyle = .fullScreen
        
        let alertController = UIAlertController(title: "Liike lisätty ohjelmaan.", message: "", preferredStyle: .alert)
        alertController.view.tintColor = UIColor.black
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in testi = true ; self.present(uusiv, animated: true, completion: nil) }))
                              
        present(alertController, animated: true) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if(testi == false){
                alertController.dismiss(animated: true, completion: nil) ; self.present(uusiv, animated: true, completion: nil)
            }
        }
        }
        savekaikki()
        saveSarjaPituudet()
        LiikeTreeniin()
    
    }
}
