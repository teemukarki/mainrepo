import UIKit
import CoreData

extension UIImageView {
    
  func setImageColor(color: UIColor) { // asettaa kuvan värin
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}

extension UIImage {
    
    func imageWithColor(color1: UIColor) -> UIImage { // muuttaa kuvan värin
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func resized(to size: CGSize) -> UIImage { // muuttaa kuvan koon
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

protocol ValittuTreeni {}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ValittuTreeni {
    
    var treeniohjelmat: [NSManagedObject] = []
    var tarkastelunMuokkausTila: TarkastelunMuokkausTila?
    var muokkausTila: Bool = false
    var managedObjectContext: NSManagedObjectContext? { return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext }
    
    let tableView : UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    
    override func viewDidLoad() { // luo näkymän
           
        tableView.allowsSelection = true
        super.viewDidLoad()
        self.view.addSubview(otsikko1)
        self.view.addSubview(otsikko1viiva1)
        self.view.addSubview(otsikko1viiva2)
        self.view.addSubview(infoButton)
        self.view.addSubview(infoImage)
        self.view.addSubview(uusiButton)
        self.view.addSubview(otsikko2)
        self.view.addSubview(imageUusi)
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        makeTreeniohjelmatTaulukko()
        setUpConstraints()
    }
    
    func setUpConstraints(){ // tekee autolayoutit näkymälle
        
        otsikko1.translatesAutoresizingMaskIntoConstraints = false
        otsikko1.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        otsikko1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        
        otsikko1viiva1.topAnchor.constraint(equalTo: otsikko1.topAnchor, constant: 0).isActive = true
        otsikko1viiva1.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        otsikko1viiva2.topAnchor.constraint(equalTo: otsikko1.topAnchor, constant: 4).isActive = true
        otsikko1viiva2.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        infoButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: 180).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        infoButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        uusiButton.translatesAutoresizingMaskIntoConstraints = false
        uusiButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        uusiButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        uusiButton.heightAnchor.constraint(equalToConstant: 102).isActive = true
        uusiButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        infoImage.translatesAutoresizingMaskIntoConstraints = false
        infoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        infoImage.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: 180).isActive = true
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) { // tuo näkymään tiedot sen avautuessa
        
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Treeniohjelma")
      
        do {
          treeniohjelmat = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func makeTreeniohjelmatTaulukko(){ // tekee treeniohjelma taulukon
            
        self.view.addSubview(tableView)
            
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 180.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -110.0).isActive = true
            
        tableView.layer.borderWidth = 1
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OhjelmaCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // rakentaa taulukon solut
               
        let ohjelma = treeniohjelmat[indexPath.row]
        let ohjelmacell = tableView.dequeueReusableCell(withIdentifier: "OhjelmaCell", for: indexPath)
               
        ohjelmacell.textLabel?.text = ohjelma.value(forKeyPath: "nimi") as? String
        ohjelmacell.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        ohjelmacell.textLabel?.font = UIFont(name: "Copperplate", size: 30)
        ohjelmacell.separatorInset = UIEdgeInsets.zero
        ohjelmacell.layoutMargins = UIEdgeInsets.zero
        ohjelmacell.selectionStyle = .none
        tableView.rowHeight = 100.0
                      
        return ohjelmacell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) // mahdollistaa taulukon solujen poiston pyyhkäisyllä
            -> UISwipeActionsConfiguration? {
                
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
        let poistoOhjelma = self.treeniohjelmat[indexPath.row]
        let alert = UIAlertController(title: "Oletko varma, että haluat poistaa treeniohjelman?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = UIColor.black
                   
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Kyllä", style: UIAlertAction.Style.default, handler: { action in poista() }))
        alert.addAction(UIAlertAction(title: "Ei", style: UIAlertAction.Style.cancel, handler: nil))
                
            func poista(){ // poistaa treeniohjelman taulukosta
                self.treeniohjelmat.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
                self.managedObjectContext?.delete(poistoOhjelma)
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { // sallii taulukon rivien muokkaamisen
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // palauttaa taulukon rivien määrän
        return treeniohjelmat.count
    }
        
    func numberOfSections(in tableView: UITableView) -> Int { // palauttaa osien määrän
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // funktio jota kutsutaan kun taulukon solua painetaan
    
        let cell = tableView.cellForRow(at: indexPath)
        
        let uusiv = TreeniohjelmanTreenitController()
        uusiv.valittuTreeni = self
        if(muokkausTila==true){
        uusiv.muokkausTila = true
        }
        uusiv.avattavaOhjelma = (cell?.textLabel?.text!)!
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
    
    let infoButton: UIButton = {
        
        let infoButton = UIButton(type: UIButton.ButtonType.system)
        infoButton.addTarget(self, action: #selector(AvaaInfoSivu), for: .touchUpInside)
        return infoButton
    }()
    
    func makeButtonWithTextMuokkaus() -> UIButton { // tekee muokkaus-napin
        
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
    
    let uusiButton: UIButton = {
        
        let myButton = UIButton(type: UIButton.ButtonType.system)
        myButton.backgroundColor = UIColor.systemGray2
        myButton.layer.borderWidth = 1.0
        myButton.addTarget(self, action: #selector(AvaaUudenLisaysSivu), for: .touchUpInside)
        return myButton
    }()
    
    let imageUusi: UIImageView = {
        
        let imageUusi = UIImageView()
        imageUusi.image = UIImage(systemName: "plus")
        imageUusi.image = imageUusi.image?.resized(to: CGSize(width: 55, height: 55))
        imageUusi.setImageColor(color: UIColor.black)
        imageUusi.contentMode = .scaleAspectFit
        return imageUusi
    }()
    
    let imageMuokkaa: UIImageView = {
        
        let imageMuokkaa = UIImageView()
        imageMuokkaa.image = UIImage(systemName: "square.and.pencil")
        imageMuokkaa.image = imageMuokkaa.image?.resized(to: CGSize(width: 55, height: 55))
        imageMuokkaa.setImageColor(color: UIColor.black)
        imageMuokkaa.contentMode = .scaleAspectFit
        return imageMuokkaa
    }()
    
    let infoImage: UIImageView = {
        
        let imageV = UIImageView()
        imageV.image = UIImage(systemName: "info.circle")
        imageV.setImageColor(color: UIColor.black)
        imageV.contentMode = .scaleAspectFit
        imageV.image = imageV.image?.resized(to: CGSize(width: 45, height: 45))
        return imageV
    }()
    
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
    
    let otsikko2: UILabel = {
        
        let l = UILabel()
        l.frame = CGRect(x: 20, y: 85, width: 250, height: 150)
        l.text = "Treeniohjelmasi:"
        l.textColor = UIColor.black
        l.font = UIFont(name: "CopperPlate-Bold", size: 25)
        return l
    }()
    
    @objc func AvaaUudenLisaysSivu(){ // avaa uuden ohjelman lisäys sivun
        
        let uusiv = UusiOhjelmaController()
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
    }
    
    @objc func AvaaInfoSivu(){ // avaa info sivun
           
        let uusiv = InfoController()
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
    }
    
    @objc func MuokkausNappiAktiivinen( sender: UIButton){ // tekee muokkaus-napista aktiivisen
    
        let vari = #colorLiteral(red: 1, green: 0.698, blue: 0, alpha: 1) /* #ffb200 */
        if (sender.tag == 0) {
            sender.backgroundColor = vari
            sender.tag = 1
            muokkausTila = true
        }else{
            sender.backgroundColor = UIColor.systemGray2
            muokkausTila = false
            sender.tag = 0
        }
    }
    
}

