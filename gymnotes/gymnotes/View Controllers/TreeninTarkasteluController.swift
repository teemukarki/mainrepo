import UIKit
import Foundation
import CoreData

protocol TarkasteltavaOhjelma {}

class TreeninTarkasteluController: UIViewController, UITableViewDelegate, UITableViewDataSource, TarkasteltavaOhjelma {

    var treenit: [NSManagedObject] = []
    var treeniohjelmat: [NSManagedObject] = []
    var tarkasteltavaTreeni: TarkasteltavaTreeni?
    var avattavaTreeni: String = ""
    var avattavaOhjelma: String = ""
    var liikeJohonLisataanPaino = ""
    var sarjat: [NSManagedObject] = []
    var liikkeet: [NSManagedObject] = []
    var summa: Int = 0
    var heightOfHeader: CGFloat = 23
    var managedObjectContext: NSManagedObjectContext? { return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
    var sarjaPituudet =  ["0","0","0","0","0","0"]
    var sarjaErikoisTekniikat = ["","","","","",""]
    var liikkeetString = [String]()
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    override func viewWillAppear(_ animated: Bool) { // tuo tiedot näkymään sen avautuessa
            
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Liike")
        let filter = NSPredicate(format: "treeni.nimi == %@", avattavaTreeni )
        let filter2 = NSPredicate(format: "treeni.ohjelma.nimi == %@", avattavaOhjelma )
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [filter, filter2])
        fetchRequest.predicate = compound
          
        do {
            liikkeet = try managedContext.fetch(fetchRequest) as! [Liike]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func viewDidLoad() { // luo näkymän
        
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        self.view.addSubview(paluuNappi)
        self.view.addSubview(imagePaluu)
        self.view.addSubview(viiva)
        self.view.addSubview(tableView)
        
        tableView.backgroundColor = UIColor.systemGray4
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LiikeCell")
        tableView.register(Header.self, forHeaderFooterViewReuseIdentifier: "sarja_otsikko")
        tableView.sectionHeaderHeight = 2
        tableView.rowHeight = 100.0
        tableView.sectionHeaderHeight = 50
        tableView.allowsSelection = true
        setUpContraints()
    }
    
    func setUpContraints(){ // tekee autolayoutit näkymään
        
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        
        let treeniJokaTarkastelussa: UILabel = makeTreeniJokaTarkastelussa()
        self.view.addSubview(treeniJokaTarkastelussa)
        
        let ohjelmaJokaTarkastelussa: UILabel = makeOhjelmaJokaTarkastelussa()
        self.view.addSubview(ohjelmaJokaTarkastelussa)
        
        ohjelmaJokaTarkastelussa.translatesAutoresizingMaskIntoConstraints = false
        ohjelmaJokaTarkastelussa.centerYAnchor.constraint(equalTo: imagePaluu.centerYAnchor, constant: 0).isActive = true
        ohjelmaJokaTarkastelussa.centerXAnchor.constraint(equalTo: imagePaluu.trailingAnchor, constant: 70).isActive = true
        
        treeniJokaTarkastelussa.translatesAutoresizingMaskIntoConstraints = false
        treeniJokaTarkastelussa.centerYAnchor.constraint(equalTo: imagePaluu.centerYAnchor , constant: 0).isActive = true
        treeniJokaTarkastelussa.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 70).isActive = true
        
        paluuNappi.translatesAutoresizingMaskIntoConstraints = false
        paluuNappi.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        paluuNappi.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        imagePaluu.translatesAutoresizingMaskIntoConstraints = false
        imagePaluu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        imagePaluu.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        viiva.translatesAutoresizingMaskIntoConstraints = false
        viiva.centerYAnchor.constraint(equalTo: tableView.topAnchor, constant: -15).isActive = true
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // rakentaa taulukon solut
            
            let liike = liikkeet[indexPath.row]
            let liikecell = tableView.dequeueReusableCell(withIdentifier: "LiikeCell", for: indexPath)
            liikecell.textLabel?.text = liike.value(forKeyPath: "nimi") as? String
            liikkeetString.insert( (liike.value(forKeyPath: "nimi") as? String)!, at: indexPath.row)
            liikecell.backgroundColor = UIColor.systemGray4
            liikecell.separatorInset = UIEdgeInsets.zero
            liikecell.layoutMargins = UIEdgeInsets.zero
            liikecell.textLabel?.font = UIFont(name: "Copperplate", size: 26)
            liikecell.selectionStyle = .none
        
            let liikkeenSarjaInfo = UILabel()
            liikkeenSarjaInfo.translatesAutoresizingMaskIntoConstraints = false
            liikkeenSarjaInfo.textColor = UIColor.black
            liikkeenSarjaInfo.font = UIFont(name: "CopperPlate", size: 20)
            liikecell.addSubview(liikkeenSarjaInfo)
        
            liikkeenSarjaInfo.topAnchor.constraint(equalTo: liikecell.textLabel!.bottomAnchor, constant: -30).isActive = true
            liikkeenSarjaInfo.leadingAnchor.constraint(equalTo: liikecell.textLabel!.leadingAnchor, constant: 0).isActive = true
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return liikecell }
            let managedContext = appDelegate.persistentContainer.viewContext
        
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sarja")
            let filter = NSPredicate(format: "liike.nimi == %@",  liikecell.textLabel!.text! )
            let filter2 = NSPredicate(format: "liike.treeni.nimi == %@",  avattavaTreeni)
            let filter3 = NSPredicate(format: "liike.treeni.ohjelma.nimi == %@",  avattavaOhjelma)
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
                        
                        if( sarja.value(forKey: "sarja_erikoistekniikka") != nil){
                            let eiEkanET = sarja.value(forKey: "sarja_erikoistekniikka") as! String
                            if( eiEkanET == "Pakkotoisto"){
                                sarjaErikoisTekniikat[index] = "pt"
                            }
                            if( eiEkanET == "Rest Pause"){
                                sarjaErikoisTekniikat[index] = "rp"
                            }
                            if( eiEkanET == "Drop"){
                                sarjaErikoisTekniikat[index] = "drop"
                            }
    
                        }
                        sarjaPituudet[index] = eiEkanPituus
                        
                        if (eiEkanPituus == ekanPituus) {
                            summa = summa + 1
                        }else{
                            summa = summa - 1
                        }
                    }
                    
                    if(summa == haetutLiikkeenSarjat.count){
                        liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0])"
                        
                        let ekaET = sarjaErikoisTekniikat[0]
                        var arvo = true
                        
                        for index in 0 ... haetutLiikkeenSarjat.count-1{
                            if(sarjaErikoisTekniikat[index] != ekaET){
                              arvo = false
                            }
                        }
                            if(arvo == true){
                                liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0]) \(ekaET)"
                            }else{
                                liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0])"
                            }
                        summa=0
                        sarjaPituudet =  ["0","0","0","0","0","0"]
                    }else{
                        
                        if(haetutLiikkeenSarjat.count==1){
                        liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0])\(sarjaErikoisTekniikat[0])"
                        }
                        if(haetutLiikkeenSarjat.count==2){
                             liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0]) \(sarjaErikoisTekniikat[0]), \(sarjaPituudet[1])\(sarjaErikoisTekniikat[1])"
                        }
                        if(haetutLiikkeenSarjat.count==3){
                            liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0])\(sarjaErikoisTekniikat[0]), \(sarjaPituudet[1])\(sarjaErikoisTekniikat[1]), \(sarjaPituudet[2])\(sarjaErikoisTekniikat[2])"
                        }
                        if(haetutLiikkeenSarjat.count==4){
                            liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0])\(sarjaErikoisTekniikat[0]), \(sarjaPituudet[1])\(sarjaErikoisTekniikat[1]), \(sarjaPituudet[2])\(sarjaErikoisTekniikat[2]), \(sarjaPituudet[3])\(sarjaErikoisTekniikat[3])"
                        }
                        if(haetutLiikkeenSarjat.count==5){
                            liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0])\(sarjaErikoisTekniikat[0]), \(sarjaPituudet[1])\(sarjaErikoisTekniikat[1]), \(sarjaPituudet[2])\(sarjaErikoisTekniikat[2]), \(sarjaPituudet[3])\(sarjaErikoisTekniikat[3]), \(sarjaPituudet[4])\(sarjaErikoisTekniikat[4])"
                        }
                        if(haetutLiikkeenSarjat.count==6){
                             liikkeenSarjaInfo.text = "\(haetutLiikkeenSarjat.count) x \(sarjaPituudet[0]) \(sarjaErikoisTekniikat[0]), \(sarjaPituudet[1])\(sarjaErikoisTekniikat[1]), \(sarjaPituudet[2])\(sarjaErikoisTekniikat[2]), \(sarjaPituudet[3])\(sarjaErikoisTekniikat[3]), \(sarjaPituudet[4])\(sarjaErikoisTekniikat[4]), \(sarjaPituudet[5])\(sarjaErikoisTekniikat[5])"
                        }
                        summa=0
                        sarjaPituudet =  ["0","0","0","0","0","0"]
                    }
                    
                }else{
                    liikkeenSarjaInfo.text = "Sarjoja ei löytynyt."
                    sarjaPituudet =  ["0","0","0","0","0","0"]
                }
                } catch let error as NSError {
                    print("Could not fetch \(error), \(error.userInfo)")
                }
            
            let liikePaino = UITextField()
            liikePaino.backgroundColor = UIColor.systemGray4
            liikePaino.keyboardAppearance = .dark
            liikePaino.textAlignment = .right
            liikePaino.keyboardType = UIKeyboardType.numbersAndPunctuation
            liikePaino.tag = indexPath.row
            liikeJohonLisataanPaino = liikecell.textLabel!.text!
            liikePaino.addTarget(self, action: #selector(textFieldEdited), for: UIControl.Event.editingDidEnd)

            let centeredParagraphStyle = NSMutableParagraphStyle()
            centeredParagraphStyle.alignment = .right
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkText, .paragraphStyle: centeredParagraphStyle]
            liikePaino.attributedPlaceholder = NSAttributedString(string: "0", attributes: attributes)
           
            let fetchRequest2 = NSFetchRequest<NSManagedObject>(entityName: "Liike")
            let filter6 = NSPredicate(format: "nimi == %@", liikecell.textLabel!.text!)
            let filter5 = NSPredicate(format: "treeni.nimi == %@",  avattavaTreeni)
            let filter4 = NSPredicate(format: "treeni.ohjelma.nimi == %@",  avattavaOhjelma)
            let compound2 = NSCompoundPredicate(andPredicateWithSubpredicates: [filter5, filter4, filter6])
            fetchRequest2.predicate = compound2
        
            do{
                let haettuLiike = try managedContext.fetch(fetchRequest2)
                if(haettuLiike.count > 0){
                    let liike = haettuLiike.first!
                    liikePaino.text = liike.value(forKey: "paino") as? String
                    savekaikki()
                }else{
                    
                }
            } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            }
        
            liikecell.addSubview(liikePaino)
        
            liikePaino.translatesAutoresizingMaskIntoConstraints = false
            liikePaino.centerYAnchor.constraint(equalTo: liikecell.textLabel!.centerYAnchor, constant: 0).isActive = true
            liikePaino.trailingAnchor.constraint(equalTo: liikecell.safeAreaLayoutGuide.trailingAnchor, constant: -37).isActive = true
            liikePaino.heightAnchor.constraint(equalToConstant: 50).isActive = true
            liikePaino.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
            return liikecell
        }
    
        @objc func textFieldEdited(sender: UITextField){ // tallentaa liikeen painoon tehdyt muutokset muistiin
            
            let indexPath = IndexPath(row: sender.tag, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
            
            let text = sender.text
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Liike")
            let filter = NSPredicate(format: "treeni.nimi == %@",  avattavaTreeni)
            let filter3 = NSPredicate(format: "nimi == %@", liikkeetString[sender.tag])
            let filter2 = NSPredicate(format: "treeni.ohjelma.nimi == %@",  avattavaOhjelma)
            let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [filter, filter2, filter3])
            fetchRequest.predicate = compound
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            do{
                let haettuLiike = try managedContext.fetch(fetchRequest)
                    if(haettuLiike.count > 0){
                        let liike = haettuLiike.first!
                        liike.setValue(text, forKey: "paino")
                        savekaikki()
                    }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { // sallii rivien muokkaamisen
            return true
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // palauttaa taulukon rivien määrän
            return liikkeet.count
        }

        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{ // yhdistää otsikon taulukkoon
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: "sarja_otsikko")
        }
        
        func numberOfSections(in tableView: UITableView) -> Int { // palauttaa osien määrän
            return 1
        }
    
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { // asettaa otsikolle korkeuden
            return heightOfHeader
        }
    
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) { // asettaa otsikolle värit
            (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
            (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor(white: 0.5, alpha: 1.0)
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // kutsutaan kun taulukon solua painetaan
    
        }
    
        func savekaikki(){ // tallentaa tiedot muistiin
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
    
            do{
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
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
        
        let liikeLabel: UILabel = {
            let liikeLabel =  UILabel()
            liikeLabel.text = "Liike"
            liikeLabel.font = UIFont(name: "Copperplate", size: 22)
            liikeLabel.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
            liikeLabel.translatesAutoresizingMaskIntoConstraints = false
            return liikeLabel
        }()
    
        let painoLabel: UILabel = {
            let painoLabel =  UILabel()
            painoLabel.text = "Paino"
            painoLabel.font = UIFont(name: "Copperplate", size: 22)
            painoLabel.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
            painoLabel.translatesAutoresizingMaskIntoConstraints = false
            return painoLabel
        }()
        
       let viiva1: UILabel = {
            let viiva = UILabel()
            viiva.frame = CGRect(x: 0, y: -40, width: 600, height: 100)
            viiva.text = "_______________________________________________________"
            viiva.textColor = UIColor.black
            viiva.font = UIFont(name: "CopperPlate-Bold", size: 38)
            viiva.translatesAutoresizingMaskIntoConstraints = false
            return viiva
        }()
            
       func setupViews(){ // luo otsikko näkymän
            
            addSubview(liikeLabel)
            addSubview(painoLabel)
            addSubview(viiva1)
            
            liikeLabel.translatesAutoresizingMaskIntoConstraints = false
            painoLabel.translatesAutoresizingMaskIntoConstraints = false
            
            viiva1.translatesAutoresizingMaskIntoConstraints = false
            viiva1.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 7).isActive = true
            viiva1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
            
            liikeLabel.translatesAutoresizingMaskIntoConstraints = false
            liikeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
            
            painoLabel.translatesAutoresizingMaskIntoConstraints = false
            painoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
            
        }

    }
    
    let paluuNappi: UIButton = {
                
        let paluuNappi = UIButton(type: UIButton.ButtonType.system)
        paluuNappi.addTarget(self, action: #selector(PalaaTreenienTarkasteluun), for: .touchUpInside)
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
    
    @objc func PalaaTreenienTarkasteluun(){ // siirtää treeniohjelman treenien tarkastelu sivulle
           
        let uusiv = TreeniohjelmanTreenitController()
        uusiv.tarkasteltavaOhjelma = self
        uusiv.avattavaOhjelma = avattavaOhjelma
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
    }
    
    func makeOhjelmaJokaTarkastelussa() -> UILabel{ // tekee tarkasteltavalle treeniohjelman nimelle paikan
         
         let ohjelma = UILabel()
         ohjelma.text = avattavaOhjelma
         ohjelma.textColor = UIColor.black
         ohjelma.font = UIFont(name: "CopperPlate-Bold", size: 20)
         return ohjelma
     }
     
    func makeTreeniJokaTarkastelussa() -> UILabel{ // tekee tarkasteltavalle treeniohjelman treenille nimelle paikan
         
         let treeni = UILabel()
         treeni.text = avattavaTreeni
         treeni.textColor = UIColor.black
         treeni.font = UIFont(name: "CopperPlate-Bold", size: 20)
         return treeni
    }
     
     let viiva: UILabel = {
         
         let viiva = UILabel()
         viiva.text = "__________________________________________________________"
         viiva.textColor = UIColor.black
         viiva.font = UIFont(name: "CopperPlate", size: 38)
         return viiva
     }()
    
}
