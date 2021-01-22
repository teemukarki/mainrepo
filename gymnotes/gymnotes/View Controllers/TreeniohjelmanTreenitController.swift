import CoreData
import UIKit

protocol TarkasteltavaTreeni {}
protocol SivuTunniste {}
protocol MuokattavaOhjelma {}
protocol TarkastelunMuokkausTila {}

class TreeniohjelmanTreenitController: UIViewController, UITableViewDelegate, UITableViewDataSource, TarkasteltavaTreeni, SivuTunniste, MuokattavaOhjelma, TarkastelunMuokkausTila {
    
    let label = UILabel()
    var treenit: [Treeni] = []
    var treeniohjelmat: [Treeniohjelma] = []
    var valittuTreeni: ValittuTreeni?
    var tarkasteltavaOhjelma: TarkasteltavaOhjelma?
    var infoAvattunaOlevaOhjelma: InfoAvattunaOlevaOhjelma?
    var avattavaOhjelma: String = ""
    var muokkausTila: Bool = false
    var managedObjectContext: NSManagedObjectContext? { return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
    var ojaTjohonLisataanTreeni: OjaTjohonLisataanTreeni?
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    override func viewDidLoad() { // luo näkymän
    
        tableView.allowsSelection = true
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)

        makeOhjelmanTreenitOtsikko()
        self.view.addSubview(paluuButton)
        self.view.addSubview(paluuImage)
        self.view.addSubview(otsikko1)
        self.view.addSubview(otsikko1viiva1)
        self.view.addSubview(otsikko1viiva2)
        self.view.addSubview(infoButton)
        self.view.addSubview(infoImage)
        self.view.addSubview(uusiButton)
        self.view.addSubview(imageUusi)
        self.view.addSubview(paluuImage)

        makeTreenitTaulukko()
        setUpConstraints()
    }
    
    func setUpConstraints(){ // tekee autolayoutit näkymään
        
        otsikko1.translatesAutoresizingMaskIntoConstraints = false
        otsikko1.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        otsikko1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        
        otsikko1viiva1.topAnchor.constraint(equalTo: otsikko1.topAnchor, constant: 0).isActive = true
        otsikko1viiva1.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        otsikko1viiva2.topAnchor.constraint(equalTo: otsikko1.topAnchor, constant: 4).isActive = true
        otsikko1viiva2.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        infoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -13).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        infoButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        infoImage.translatesAutoresizingMaskIntoConstraints = false
        infoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        infoImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -13).isActive = true
        
        uusiButton.translatesAutoresizingMaskIntoConstraints = false
        uusiButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        uusiButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        uusiButton.heightAnchor.constraint(equalToConstant: 102).isActive = true
        uusiButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        imageUusi.translatesAutoresizingMaskIntoConstraints = false
        imageUusi.centerXAnchor.constraint(equalTo: uusiButton.centerXAnchor, constant: 0).isActive = true
        imageUusi.centerYAnchor.constraint(equalTo: uusiButton.centerYAnchor, constant: 0).isActive = true

        let muokkausButton: UIButton = makeButtonWithTextMuokkaus()
        self.view.addSubview(imageMuokkaa)
        muokkausButton.translatesAutoresizingMaskIntoConstraints = false
        muokkausButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        muokkausButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        muokkausButton.heightAnchor.constraint(equalToConstant: 102).isActive = true
        muokkausButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true

        imageMuokkaa.translatesAutoresizingMaskIntoConstraints = false
        imageMuokkaa.centerXAnchor.constraint(equalTo: muokkausButton.centerXAnchor, constant: 0).isActive = true
        imageMuokkaa.centerYAnchor.constraint(equalTo: muokkausButton.centerYAnchor, constant: 0).isActive = true
        
        paluuButton.translatesAutoresizingMaskIntoConstraints = false
        paluuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        paluuButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        paluuImage.translatesAutoresizingMaskIntoConstraints = false
        paluuImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        paluuImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) { // tuo datan näkymään sen avautuessa
           
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Treeni")
        let filter = NSPredicate(format: "ohjelma.nimi == %@", avattavaOhjelma)
        fetchRequest.predicate = filter
         
         do {
           treenit = try managedContext.fetch(fetchRequest) as! [NSManagedObject] as! [Treeni]
         } catch let error as NSError {
           print("Could not fetch. \(error), \(error.userInfo)")
         }
    }
    
    func makeTreenitTaulukko(){ // tekee treenitaulukon
        
        tableView.layer.borderWidth = 1
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TreeniCell")
        self.view.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 180.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110.0).isActive = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // rakentaa taulukon solut
                 
        let treeni = treenit[indexPath.row]
        let treenicell = tableView.dequeueReusableCell(withIdentifier: "TreeniCell", for: indexPath)
        treenicell.textLabel?.text = treeni.value(forKeyPath: "nimi") as? String
        treenicell.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        treenicell.textLabel?.font = UIFont(name: "Copperplate", size: 30)
        treenicell.separatorInset = UIEdgeInsets.zero
        treenicell.layoutMargins = UIEdgeInsets.zero
        treenicell.selectionStyle = .none
        tableView.rowHeight = 100.0
        return treenicell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) // mahdollistaa solujen poiston pyyhkäisyllä
            -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
        let poistotreeni = self.treenit[indexPath.row]
        let alert = UIAlertController(title: "Oletko varma, että haluat poistaa treenin?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = UIColor.black
                       
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Kyllä", style: UIAlertAction.Style.default, handler: { action in poista() }))
        alert.addAction(UIAlertAction(title: "Ei", style: UIAlertAction.Style.cancel, handler: nil))
                    
            func poista(){
                self.treenit.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
                self.managedObjectContext?.delete(poistotreeni)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // palauttaa rivien määrän
        return treenit.count
    }
        
    func numberOfSections(in tableView: UITableView) -> Int { // palauttaa osien määrän
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // kutsutaan kun taulukon solua painetaan
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if(muokkausTila==false){
            let uusiv = TreeninTarkasteluController()
            uusiv.tarkasteltavaTreeni = self
            uusiv.avattavaOhjelma = avattavaOhjelma
            uusiv.avattavaTreeni = (cell?.textLabel?.text!)!
            uusiv.modalPresentationStyle = .fullScreen
            self.present(uusiv, animated: true, completion: nil)
        }else{
            let uusiv = UusiOhjelmaController()
            uusiv.muokattavaOhjelma = self
            uusiv.edellisenTunniste = 1
            uusiv.takaisinTullutOhjelma = avattavaOhjelma
            uusiv.takaisinTullutTreeni = (cell?.textLabel?.text!)!
            uusiv.modalPresentationStyle = .fullScreen
            self.present(uusiv, animated: true, completion: nil)
        }
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
    
    let infoButton: UIButton = {
        
        let infoButton = UIButton(type: UIButton.ButtonType.system)
        infoButton.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        infoButton.addTarget(self, action: #selector(AvaaInfoSivu), for: .touchUpInside)
        return infoButton
    }()
    
    let paluuButton: UIButton = {
        
        let paluuNappi = UIButton(type: UIButton.ButtonType.system)
        paluuNappi.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        paluuNappi.addTarget(self, action: #selector(PalaaEtusivulle), for: .touchUpInside)
        return paluuNappi
    }()
    
    let paluuImage: UIImageView = {
        
        let paluuImage = UIImageView()
        paluuImage.image = UIImage(systemName: "chevron.left")
        paluuImage.setImageColor(color: UIColor.black)
        paluuImage.image = paluuImage.image?.resized(to: CGSize(width: 30, height: 30))
        paluuImage.contentMode = .scaleAspectFit
        return paluuImage
    }()
    
    @objc func PalaaEtusivulle(){ // palaa etusivulle
        
        let uusiv = ViewController()
        uusiv.tarkastelunMuokkausTila = self
        if(muokkausTila==true){
            uusiv.muokkausTila = true
        }else{
            uusiv.muokkausTila = false
        }
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
    }
    
    @objc func AvaaUudenLisaysSivu(){ // avaa uuden ohjelman lisäys sivun
        
        let uusiv = UusiOhjelmaController()
        uusiv.muokattavaOhjelma = self
        uusiv.takaisinTullutOhjelma = avattavaOhjelma
        uusiv.edellisenTunniste = 1
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
    }
    
    @objc func AvaaInfoSivu(){ // avaa infosivun
              
        let uusiv = InfoController()
        uusiv.sivuTunniste = self
        uusiv.avattavaOhjelma = avattavaOhjelma
        uusiv.numero = 1
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
    }
    
    @objc func MuokkausNappiAktiivinen( sender: UIButton ){ // aktivoi muokkausnapin
        
        let vari = #colorLiteral(red: 1, green: 0.698, blue: 0, alpha: 1) /* #ffb200 */
        if (sender.tag == 0) {
            sender.backgroundColor = vari
            sender.tag = 1
            muokkausTila = true
            makeOhjelmanTreenitOtsikko()
        }else{
            sender.backgroundColor = UIColor.systemGray2
            muokkausTila = false
            sender.tag = 0
            makeOhjelmanTreenitOtsikko()
        }
    }
    
    func makeOhjelmanTreenitOtsikko(){ // tekee otsikon alueen
           
        label.frame = CGRect(x: 20, y: 57, width: 350, height: 200)
        
        if(muokkausTila==false){
            showText()
            label.font = UIFont(name: "CopperPlate-Bold", size: 26)
        }else if(muokkausTila==true){
            label.numberOfLines = 2
            showText()
            label.font = UIFont(name: "CopperPlate-Bold", size: 20)
        }
        label.textColor = UIColor.black
        self.view.addSubview(label)
    }
    
    func showText(){ // lisää tekstin otsikkoon
        
        if(label.numberOfLines>1){
            label.text = "Valitse treeni, jota haluat muokata ohjelmasta \(avattavaOhjelma)"
        }else{
            label.text = "\(avattavaOhjelma) treenit:"
        }
        label.numberOfLines=0
    }
    
    let otsikko1: UILabel = {
        
        let l = UILabel()
        l.text = "GymNotes"
        l.textColor = UIColor.black
        l.font = UIFont(name: "CopperPlate-Bold", size: 42)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
             
    let otsikko1viiva1: UILabel = {
        
        let l2 = UILabel()
        l2.text = "__________"
        l2.textColor = UIColor.black
        l2.font = UIFont(name: "CopperPlate-Bold", size: 45)
        l2.translatesAutoresizingMaskIntoConstraints = false
        return l2
    }()
               
    let otsikko1viiva2: UILabel = {
        
        let l3 = UILabel()
        l3.text = "_________"
        l3.textColor = UIColor.black
        l3.font = UIFont(name: "CopperPlate-Bold", size: 45)
        l3.translatesAutoresizingMaskIntoConstraints = false
        return l3
    }()
    
    let infoImage: UIImageView = {
        
        let imageV = UIImageView()
        imageV.image = UIImage(systemName: "info.circle")
        imageV.setImageColor(color: UIColor.black)
        imageV.contentMode = .scaleAspectFit
        imageV.image = imageV.image?.resized(to: CGSize(width: 45, height: 45))
        return imageV
    }()
    
    let imageMuokkaa: UIImageView = {
        
        let imageMuokkaa = UIImageView()
        imageMuokkaa.image = UIImage(systemName: "square.and.pencil")
        imageMuokkaa.image = imageMuokkaa.image?.resized(to: CGSize(width: 55, height: 55))
        imageMuokkaa.setImageColor(color: UIColor.black)
        imageMuokkaa.contentMode = .scaleAspectFit
        return imageMuokkaa
    }()
    
    let imageUusi: UIImageView = {
        
        let imageUusi = UIImageView()
        imageUusi.image = UIImage(systemName: "plus")
        imageUusi.image = imageUusi.image?.resized(to: CGSize(width: 55, height: 55))
        imageUusi.setImageColor(color: UIColor.black)
        imageUusi.contentMode = .scaleAspectFit
        return imageUusi
    }()
    
    let uusiButton: UIButton = {
        
        let myButton = UIButton(type: UIButton.ButtonType.system)
        myButton.backgroundColor = UIColor.systemGray2
        myButton.layer.borderWidth = 1.0
        myButton.addTarget(self, action: #selector(AvaaUudenLisaysSivu), for: .touchUpInside)
        return myButton
    }()
    
    func makeButtonWithTextMuokkaus() -> UIButton { // tekee muokkausnapin
        
        let vari = #colorLiteral(red: 1, green: 0.698, blue: 0, alpha: 1) /* #ffb200 */
        let muokkausButton = UIButton(type: UIButton.ButtonType.system)
        muokkausButton.contentMode = .center
        muokkausButton.imageView?.contentMode = .scaleAspectFit
            
        if(muokkausTila==true){
            muokkausButton.tag = 1
        }else{
            muokkausButton.tag = 0
        }
        muokkausButton.layer.borderWidth = 1.0
        muokkausButton.addTarget(self, action: #selector(MuokkausNappiAktiivinen), for: .touchUpInside)
            
        if(muokkausTila==true){
            muokkausButton.backgroundColor = vari
        }else{
            muokkausButton.backgroundColor = UIColor.systemGray2
        }
        self.view.addSubview(muokkausButton)
        return muokkausButton
    }
    
}
