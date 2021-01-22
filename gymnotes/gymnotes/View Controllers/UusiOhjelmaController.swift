import UIKit
import CoreData

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

protocol OjaTjohonLisataanTreeni {}

class UusiOhjelmaController: UIViewController, UITableViewDelegate, UITableViewDataSource, OjaTjohonLisataanTreeni {
    
    var liikkeet: [NSManagedObject] = []
    var treeniohjelmaNimi_Syote = UITextField()
    var treeniNimi_Syote = UITextField()
    var takaisinTullutOhjelma: String = ""
    var takaisinTullutTreeni: String = ""
    var ohjelmaJaTreeniTakaisin: OhjelmaJaTreeniTakaisin?
    var muokattavaOhjelma: MuokattavaOhjelma?
    var edellisenTunniste: Int = 0
    var tyhjyysTunniste: Bool = false
    var summa: Int = 0
    var sarjaPituudet =  ["0","0","0","0","0","0"]
    var managedObjectContext: NSManagedObjectContext? { return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    override func viewDidLoad() { // luo näkymän
        
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        self.view.addSubview(paluuButton)
        self.view.addSubview(imagePaluu)
        self.view.addSubview(tallennusNappi)
        self.view.addSubview(lisaaLiikeNappi)
        self.view.addSubview(peruutaNappi)
        self.view.addSubview(liikkeetOtsikko)
        self.view.addSubview(tableView)
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LiikeCell")
        setUpConstraints()
    }
    
    func setUpConstraints(){ // tekee autolayoutit näkymään
        
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
        
        let treeniohjelmaNimi_Syote: UITextField = makeOhjelmaNimiTxt()
        self.view.addSubview(treeniohjelmaNimi_Syote)
        
        treeniohjelmaNimi_Syote.translatesAutoresizingMaskIntoConstraints = false
        treeniohjelmaNimi_Syote.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        treeniohjelmaNimi_Syote.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        treeniohjelmaNimi_Syote.leadingAnchor.constraint(equalTo: peruutaNappi.centerXAnchor, constant: -30).isActive = true
        treeniohjelmaNimi_Syote.trailingAnchor.constraint(equalTo: tallennusNappi.centerXAnchor, constant: 30).isActive = true
        treeniohjelmaNimi_Syote.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let treeniNimi_Syote: UITextField = makeTreeniNimiTxt()
        self.view.addSubview(treeniNimi_Syote)
        
        treeniNimi_Syote.translatesAutoresizingMaskIntoConstraints = false
        treeniNimi_Syote.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        treeniNimi_Syote.topAnchor.constraint(equalTo: treeniohjelmaNimi_Syote.bottomAnchor, constant: 5).isActive = true
        treeniNimi_Syote.leadingAnchor.constraint(equalTo: peruutaNappi.centerXAnchor, constant: -30).isActive = true
        treeniNimi_Syote.trailingAnchor.constraint(equalTo: tallennusNappi.centerXAnchor, constant: 30).isActive = true
        treeniNimi_Syote.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lisaaLiikeNappi.translatesAutoresizingMaskIntoConstraints = false
        lisaaLiikeNappi.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        lisaaLiikeNappi.topAnchor.constraint(equalTo: treeniNimi_Syote.bottomAnchor, constant: 5).isActive = true
        lisaaLiikeNappi.leadingAnchor.constraint(equalTo: peruutaNappi.centerXAnchor, constant: -30).isActive = true
        lisaaLiikeNappi.trailingAnchor.constraint(equalTo: tallennusNappi.centerXAnchor, constant: 30).isActive = true
        lisaaLiikeNappi.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        tableView.topAnchor.constraint(equalTo: lisaaLiikeNappi.bottomAnchor, constant: 45).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: peruutaNappi.topAnchor, constant: -8).isActive = true
        
        liikkeetOtsikko.translatesAutoresizingMaskIntoConstraints = false
        liikkeetOtsikko.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -5).isActive = true
        liikkeetOtsikko.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 5).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) { // tuo datan näkymään kun se avataan
          
        super.viewWillAppear(animated)
    
        treeniohjelmaNimi_Syote.text = takaisinTullutOhjelma
        treeniNimi_Syote.text = takaisinTullutTreeni
        
        if(treeniohjelmaNimi_Syote.text == "" && treeniNimi_Syote.text == ""){
            tyhjyysTunniste = true
            treeniohjelmaNimi_Syote.becomeFirstResponder()
        }
        if(treeniohjelmaNimi_Syote.text != "" && treeniNimi_Syote.text == ""){
            treeniNimi_Syote.becomeFirstResponder()
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Liike")
        let filter = NSPredicate(format: "treeni.nimi == %@", treeniNimi_Syote.text!)
        fetchRequest.predicate = filter

        do{
          liikkeet = try managedContext.fetch(fetchRequest) as! [NSManagedObject] as! [Liike]
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
      }
    
    @objc func treeninTallennus(){ // välifunktio treeniohjelman ja treenin muistiin tallentamiseen, tarkistaa syötteet
        
        let ohjelmanNimi: String = treeniohjelmaNimi_Syote.text!
        let treeninNimi: String = treeniNimi_Syote.text!
        
        if(ohjelmanNimi == "" && treeninNimi == ""){
            let alert = UIAlertController(title: "Syötä treeniohjelmalle ja treenille nimi ensin.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.view.tintColor = UIColor.black
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
        
        if(ohjelmanNimi == "" && treeninNimi != ""){
            let alert = UIAlertController(title: "Syötä treeniohjelmalle nimi ensin.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.view.tintColor = UIColor.black
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
        
        if(treeninNimi == "" && ohjelmanNimi != ""){
            let alert = UIAlertController(title: "Syötä treenille nimi ensin.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.view.tintColor = UIColor.black
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
        
        if(ohjelmanNimi != "" && treeninNimi != ""){
        saveOhjelmanJaTreeninNimi(ohjelmanNimi: ohjelmanNimi, treeninNimi: treeninNimi)
        PaluuEdelliseenTallennus()
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // rakentaa taulukon solut
            
        let liike = liikkeet[indexPath.row]
        let liikecell = tableView.dequeueReusableCell(withIdentifier: "LiikeCell", for: indexPath)
    
        liikecell.textLabel?.text = liike.value(forKeyPath: "nimi") as? String
        liikecell.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        liikecell.separatorInset = UIEdgeInsets.zero
        liikecell.layoutMargins = UIEdgeInsets.zero
        liikecell.selectionStyle = .none
        
        let liikkeenSarjat = UILabel()
        liikkeenSarjat.textAlignment = .right
        liikecell.addSubview(liikkeenSarjat)
        
        liikkeenSarjat.translatesAutoresizingMaskIntoConstraints = false
        liikkeenSarjat.centerYAnchor.constraint(equalTo: liikecell.centerYAnchor, constant: 0).isActive = true
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return liikecell }
        let managedContext = appDelegate.persistentContainer.viewContext
               
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sarja")
        let filter = NSPredicate(format: "liike.nimi == %@",  liikecell.textLabel!.text!)
        let filter2 = NSPredicate(format: "liike.treeni.nimi == %@",  takaisinTullutTreeni)
        let filter3 = NSPredicate(format: "liike.treeni.ohjelma.nimi == %@",  takaisinTullutOhjelma)
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [filter, filter2, filter3])
        fetchRequest.predicate = compound
        
        do{
            let haetutLiikkeenSarjat = try managedContext.fetch(fetchRequest)

            if(haetutLiikkeenSarjat.count > 0 && haetutLiikkeenSarjat.count < 7){
                
            for index in 0...haetutLiikkeenSarjat.count-1{
                
                let vertausSarja = haetutLiikkeenSarjat.first!
                let sarja = haetutLiikkeenSarjat[index]
                                
                let ekanPituus: String = vertausSarja.value(forKey: "pituus") as! String
                let eiEkanPituus = sarja.value(forKey: "pituus") as! String
        
                sarjaPituudet[index] = eiEkanPituus
                                
                if (eiEkanPituus == ekanPituus) {
                    summa = summa + 1
                }else{
                    summa = summa - 1
                }
            }
                
                if(summa == haetutLiikkeenSarjat.count){
                    
                    liikkeenSarjat.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0])"
                    summa=0
                    sarjaPituudet =  ["0","0","0","0","0","0"]
                    }else{
                                
                        if(haetutLiikkeenSarjat.count==1){
                        liikkeenSarjat.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0])"
                        }
                        if(haetutLiikkeenSarjat.count==2){
                            liikkeenSarjat.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0]), \(sarjaPituudet[1])"
                        }
                        if(haetutLiikkeenSarjat.count==3){
                            liikkeenSarjat.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0]), \(sarjaPituudet[1]), \(sarjaPituudet[2])"
                        }
                        if(haetutLiikkeenSarjat.count==4){
                            liikkeenSarjat.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0]), \(sarjaPituudet[1]), \(sarjaPituudet[2]), \(sarjaPituudet[3])"
                        }
                        if(haetutLiikkeenSarjat.count==5){
                            liikkeenSarjat.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0]), \(sarjaPituudet[1]), \(sarjaPituudet[2]), \(sarjaPituudet[3]), \(sarjaPituudet[4])"
                        }
                        if(haetutLiikkeenSarjat.count==6){
                            liikkeenSarjat.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0]), \(sarjaPituudet[1]), \(sarjaPituudet[2]), \(sarjaPituudet[3]), \(sarjaPituudet[4]), \(sarjaPituudet[5])"
                        }
                        summa=0
                        sarjaPituudet =  ["0","0","0","0","0","0"]
                    }
                            
                    }else{
                        liikkeenSarjat.text = "Ei lisättyjä sarjoja"
                        sarjaPituudet =  ["0","0","0","0","0","0"]
                    }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        liikkeenSarjat.trailingAnchor.constraint(equalTo: liikecell.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        return liikecell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? { // mahdollistaa solujen poistamisen pyyhkäisemällä
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
        let poistoLiike = self.liikkeet[indexPath.row]
        let alert = UIAlertController(title: "Oletko varma, että haluat poistaa liikkeen?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = UIColor.black
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Kyllä", style: UIAlertAction.Style.default, handler: { action in poista() }))
        alert.addAction(UIAlertAction(title: "Ei", style: UIAlertAction.Style.cancel, handler: nil))
                
            func poista(){
                self.liikkeet.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.managedObjectContext?.delete(poistoLiike)
                tableView.reloadData()
                self.savekaikki()
            }
            
        completionHandler(true)
        }
        deleteAction.image = UIImage(named: "Roskis")
        deleteAction.image = deleteAction.image?.resized(to: CGSize(width: 35, height: 35))
        deleteAction.image = deleteAction.image?.withRenderingMode(.alwaysTemplate)
        deleteAction.image = deleteAction.image?.imageWithColor(color1: UIColor.black)
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { // sallii rivien muokkaamisen
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // palauttaa taulukon rivien määrän
        return liikkeet.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { // palauttaa osien määrän
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // kutsutaan kun taulukon solua painetaan
        
        let cell = tableView.cellForRow(at: indexPath)
        let uusiv = UusiLiikeController()
        uusiv.ojaTjohonLisataanTreeni = self
        uusiv.ohjelmaJohonLisays = treeniohjelmaNimi_Syote.text!
        uusiv.treeniJohonLisays = treeniNimi_Syote.text!
        uusiv.liikeJotaMuokataan = (cell?.textLabel?.text!)!
        uusiv.modalPresentationStyle = .fullScreen
        self.present(uusiv, animated: true, completion: nil)
    }
    
    func savekaikki(){ // tallentaa tiedot muistiin
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveOhjelmanJaTreeninNimi(ohjelmanNimi: String, treeninNimi: String) { // tallentaa treeniohjelman ja treenin muistiin
      
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext        
        let request = NSFetchRequest<NSManagedObject>(entityName: "Treeniohjelma")
        let predicate = NSPredicate(format: "nimi == %@", ohjelmanNimi)
        request.predicate = predicate
        request.fetchLimit = 1
        
        do{
            let haettuOhjelma = try managedContext.fetch(request)
            
        if(haettuOhjelma.count > 0){
            let request2 = NSFetchRequest<NSManagedObject>(entityName: "Treeni")
            let predicate = NSPredicate(format: "ohjelma.nimi == %@", ohjelmanNimi)
            let predicate2 = NSPredicate(format: "nimi == %@", treeninNimi)
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
            request2.predicate = compound
            
            do{
                let haettuOhjelmanTreeni = try managedContext.fetch(request2)
                
                if(haettuOhjelmanTreeni.count > 0){
                }else{
                    let ohjelmaMuutos = haettuOhjelma.first!
                    let treeni = Treeni(context: managedContext)
                    treeni.nimi = treeninNimi
                    ohjelmaMuutos.mutableSetValue(forKey: "treenit").add(treeni)
                    savekaikki()
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
        }else{
            let treeniohjelma = Treeniohjelma(context: managedContext)
            treeniohjelma.nimi = ohjelmanNimi
            
            let treeni = Treeni(context: managedContext)
            treeni.nimi = treeninNimi
            treeniohjelma.addToTreenit(treeni)
            treeni.ohjelma = treeniohjelma
            savekaikki()
        }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    let liikkeetOtsikko: UILabel = {
        
        let otsikko = UILabel()
        otsikko.text = "Liikkeet"
        otsikko.textColor = UIColor.black
        otsikko.font = UIFont(name: "CopperPlate-Bold", size: 22)
        return otsikko
    }()
    
    
    @objc func LisaaUusiLiikeSivulle(){ // siirtää uuden liikkeen lisäys sivulle
        
        if(treeniohjelmaNimi_Syote.text == "" && treeniNimi_Syote.text == ""){
            let alert = UIAlertController(title: "Syötä treeniohjelmalle ja treenille nimi ensin.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.view.tintColor = UIColor.black
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
             
        if(treeniohjelmaNimi_Syote.text == "" && treeniNimi_Syote.text != ""){
            let alert = UIAlertController(title: "Syötä treeniohjelmalle nimi ensin.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.view.tintColor = UIColor.black
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
             
        if(treeniNimi_Syote.text == "" && treeniohjelmaNimi_Syote.text != ""){
            let alert = UIAlertController(title: "Syötä treenille nimi ensin.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.view.tintColor = UIColor.black
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
             
        if(treeniNimi_Syote.text != "" && treeniohjelmaNimi_Syote.text != ""){
        saveOhjelmanJaTreeninNimi(ohjelmanNimi: treeniohjelmaNimi_Syote.text! , treeninNimi: treeniNimi_Syote.text! )
        let uusiv = UusiLiikeController()
        uusiv.ojaTjohonLisataanTreeni = self
        uusiv.tyhjyysTunniste = tyhjyysTunniste
        uusiv.ohjelmaJohonLisays = treeniohjelmaNimi_Syote.text!
        uusiv.treeniJohonLisays = treeniNimi_Syote.text!
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
        }
    }
    
    let peruutaNappi: UIButton = {
        
        let vari = #colorLiteral(red: 0.6784, green: 0.1529, blue: 0.1529, alpha: 1) /* #ad2727 */
        let peruutaNappi = UIButton(type: UIButton.ButtonType.system)
        peruutaNappi.setTitle("PERUUTA", for: .normal)
        peruutaNappi.setTitleColor(.black, for: .normal)
        peruutaNappi.titleLabel?.font = UIFont(name: "CopperPlate-Bold", size: 20)
        peruutaNappi.backgroundColor = vari
        peruutaNappi.layer.borderWidth = 1.3
        peruutaNappi.addTarget(self, action: #selector(PaluuEdelliseen), for: .touchUpInside)
        return peruutaNappi
    }()
    
    let lisaaLiikeNappi: UIButton = {
        
        let vari = #colorLiteral(red: 0.3686, green: 0.6667, blue: 0.7569, alpha: 1) /* #5eaac1 */
        let lisaaLiikeNappi = UIButton(type: UIButton.ButtonType.system)
        lisaaLiikeNappi.layer.cornerRadius = 10
        lisaaLiikeNappi.setTitle("LISÄÄ UUSI LIIKE", for: .normal)
        lisaaLiikeNappi.setTitleColor(.black, for: .normal)
        lisaaLiikeNappi.titleLabel?.font = UIFont(name: "CopperPlate-Bold", size: 20)
        lisaaLiikeNappi.backgroundColor = vari
        lisaaLiikeNappi.layer.borderWidth = 1.0
        lisaaLiikeNappi.addTarget(self, action: #selector(LisaaUusiLiikeSivulle), for: .touchUpInside)
        return lisaaLiikeNappi
    }()
    
    let paluuButton: UIButton = {
        
        let paluuNappi = UIButton(type: UIButton.ButtonType.system)
        paluuNappi.addTarget(self, action: #selector(PaluuEdelliseen), for: .touchUpInside)
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
    
    let tallennusNappi: UIButton = {
        
        let vari = #colorLiteral(red: 0.3137, green: 0.4667, blue: 0.3216, alpha: 1) /* #507752 */
        let tallennusNappi = UIButton(type: UIButton.ButtonType.system)
        tallennusNappi.setTitle("TALLENNA", for: .normal)
        tallennusNappi.setTitleColor(.black, for: .normal)
        tallennusNappi.titleLabel?.font = UIFont(name: "CopperPlate-Bold", size: 20)
        tallennusNappi.backgroundColor = vari
        tallennusNappi.layer.borderWidth = 1.3
        tallennusNappi.addTarget(self, action: #selector(treeninTallennus), for: .touchUpInside)
        return tallennusNappi
    }()
    
    @objc func PaluuEdelliseenTallennus(){ // palaa edelliselle sivulle ja tallentaa tiedot samalla
        
        var testi = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Liike")
        let predicate = NSPredicate(format: "poisto_tunniste == %@", NSNumber(value: true))
        fetchRequest.predicate = predicate
        
        do {
            let haettuLiike = try managedContext.fetch(fetchRequest)
            
            if(haettuLiike.count>0){
                var summa = haettuLiike.count
                while summa > 0 {
                    let poistettavaLiike = haettuLiike[summa-1]
                    summa = summa - 1
                    poistettavaLiike.setValue(false, forKey: "poisto_tunniste")
                    savekaikki()
                }
            }else{
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if(tyhjyysTunniste == false){
            let uusiv = TreeniohjelmanTreenitController()
            uusiv.ojaTjohonLisataanTreeni = self
            uusiv.avattavaOhjelma = takaisinTullutOhjelma
            uusiv.modalPresentationStyle = .fullScreen
            
            let alertController = UIAlertController(title: "Treeniohjelman tiedot tallennettu.", message: "", preferredStyle: .alert)
            alertController.view.tintColor = UIColor.black
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in testi = true ; self.present(uusiv, animated: true, completion: nil) }))
                       
            present(alertController, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if(testi == false){
                        alertController.dismiss(animated: true, completion: nil) ; self.present(uusiv, animated: true, completion: nil)
                    }
                }
            }
            
        }else{
            let uusiv = ViewController()
            uusiv.modalPresentationStyle = .fullScreen
            
            let alertController = UIAlertController(title: "Treeniohjelman tiedot tallennettu.", message: "", preferredStyle: .alert)
            alertController.view.tintColor = UIColor.black
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in testi = true ; self.present(uusiv, animated: true, completion: nil) }))
            
            present(alertController, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if(testi == false){
                    alertController.dismiss(animated: true, completion: nil) ; self.present(uusiv, animated: true, completion: nil) 
                    }
                }
            }
            tyhjyysTunniste = false
        }
        
    }
    
    @objc func PaluuEdelliseen(){ // palaa edelliselle sivulle ilman tallennusta
           
        let alert = UIAlertController(title: "Oletko varma, että haluat peruuttaa lisäyksen?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = UIColor.black
    
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Kyllä", style: UIAlertAction.Style.default, handler: { action in self.poista() }))
        alert.addAction(UIAlertAction(title: "Ei", style: UIAlertAction.Style.cancel, handler: nil))
    }
        
        func poista(){ // poistaa peruutetut muutokset
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Liike")
            let predicate = NSPredicate(format: "poisto_tunniste == %@", NSNumber(value: true))
            fetchRequest.predicate = predicate
            
            do {
                let haettuLiike = try managedContext.fetch(fetchRequest)
                
                if(haettuLiike.count>0){
                    var summa = haettuLiike.count
                    while summa > 0 {
                        let poistettavaLiike = haettuLiike[summa-1]
                        summa = summa - 1
                        managedObjectContext?.delete(poistettavaLiike)
                        savekaikki()
                    }
                }else{
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if(tyhjyysTunniste == true){
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Treeniohjelma")
                let predicate = NSPredicate(format: "nimi == %@", treeniohjelmaNimi_Syote.text!)
                fetchRequest.predicate = predicate
                
                do {
                    let haettuOhjelma = try managedContext.fetch(fetchRequest)
                    print(haettuOhjelma.count)
                    
                    if(haettuOhjelma.count>0){
                            let poistettavaOhjelma = haettuOhjelma.first
                            managedObjectContext?.delete(poistettavaOhjelma!)
                            savekaikki()
                    }else{
                    }
                } catch let error as NSError {
                    print("Could not fetch. \(error), \(error.userInfo)")
                }
                
            }
            
            if(edellisenTunniste==1){
                let uusiv = TreeniohjelmanTreenitController()
                uusiv.ojaTjohonLisataanTreeni = self
                uusiv.avattavaOhjelma = takaisinTullutOhjelma
                uusiv.modalPresentationStyle = .fullScreen
                self.present(uusiv, animated: true, completion: nil)
            }else{
                let uusiv = ViewController()
                uusiv.modalPresentationStyle = .fullScreen
                self.present(uusiv, animated: true, completion: nil)
            }
    }
    
    func makeOhjelmaNimiTxt() -> UITextField { // tekee tekstikentän ohjelman nimen syöttämiselle
          
        treeniohjelmaNimi_Syote = UITextField()
        treeniohjelmaNimi_Syote.backgroundColor = UIColor.systemGray2
        treeniohjelmaNimi_Syote.layer.borderWidth = 1.0
        treeniohjelmaNimi_Syote.layer.cornerRadius = 10
        treeniohjelmaNimi_Syote.keyboardAppearance = .dark
        treeniohjelmaNimi_Syote.textAlignment = .center
          
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
          
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkText, .paragraphStyle: centeredParagraphStyle]
        treeniohjelmaNimi_Syote.attributedPlaceholder = NSAttributedString(string: "Syötä treeniohjelman nimi", attributes: attributes)
        self.hideKeyboardWhenTappedAround()
        return treeniohjelmaNimi_Syote
    }
    
    func makeTreeniNimiTxt() -> UITextField { // tekee tekstikentän treenin nimen syöttämiselle
         
        treeniNimi_Syote = UITextField()
        treeniNimi_Syote.backgroundColor = UIColor.systemGray2
        treeniNimi_Syote.layer.borderWidth = 1.0
        treeniNimi_Syote.layer.cornerRadius = 10
        treeniNimi_Syote.keyboardAppearance = .dark
        treeniNimi_Syote.textAlignment = .center
        
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
          
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkText, .paragraphStyle: centeredParagraphStyle]
        treeniNimi_Syote.attributedPlaceholder = NSAttributedString(string: "Syötä treenin nimi", attributes: attributes)
        self.hideKeyboardWhenTappedAround()
        return treeniNimi_Syote
    }
    
    
}

/*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
       if (editingStyle == .delete) {
   
       let poistoliike = liikkeet[indexPath.row]
       liikkeet.remove(at: indexPath.row)
       tableView.deleteRows(at: [indexPath], with: .fade)
       tableView.reloadData()
       managedObjectContext?.delete(poistoliike)
       self.savekaikki()
       }
   }*/
