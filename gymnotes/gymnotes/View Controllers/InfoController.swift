import UIKit

protocol InfoAvattunaOlevaOhjelma {}

class InfoController: UIViewController, InfoAvattunaOlevaOhjelma {
    
    var sivuTunniste: SivuTunniste?
    var tarkasteltavaTreeni: TarkasteltavaTreeni?
    var avattavaOhjelma: String = ""
    var numero: Int?
    
    override func viewDidLoad() { // luo näkyvän
        
        view.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        self.view.addSubview(imagePaluu)
        self.view.addSubview(paluuButton)
        self.view.addSubview(infoOtsikko)
        self.view.addSubview(otsikkoViiva1)
        self.view.addSubview(otsikkoViiva2)
        self.view.addSubview(ohjeTeksti)
        self.view.addSubview(ohjeTeksti2)
        self.view.addSubview(ohjeTeksti3)
        self.view.addSubview(viiva1)
        self.view.addSubview(viiva2)
        setUpConstraints()
    }
    
    func setUpConstraints(){ // tekee autolayoutit näkymälle
        
        paluuButton.translatesAutoresizingMaskIntoConstraints = false
        paluuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        paluuButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        imagePaluu.translatesAutoresizingMaskIntoConstraints = false
        imagePaluu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        imagePaluu.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        
        infoOtsikko.translatesAutoresizingMaskIntoConstraints = false
        infoOtsikko.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        infoOtsikko.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
        
        otsikkoViiva1.translatesAutoresizingMaskIntoConstraints = false
        
        otsikkoViiva1.topAnchor.constraint(equalTo: infoOtsikko.topAnchor, constant: 4).isActive = true
        otsikkoViiva1.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        otsikkoViiva2.translatesAutoresizingMaskIntoConstraints = false
        otsikkoViiva2.topAnchor.constraint(equalTo: infoOtsikko.topAnchor, constant: 8).isActive = true
        otsikkoViiva2.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        ohjeTeksti.translatesAutoresizingMaskIntoConstraints = false
        ohjeTeksti.topAnchor.constraint(equalTo: otsikkoViiva2.bottomAnchor, constant: 55).isActive = true
        ohjeTeksti.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        ohjeTeksti.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        ohjeTeksti2.translatesAutoresizingMaskIntoConstraints = false
        ohjeTeksti2.topAnchor.constraint(equalTo: viiva1.bottomAnchor, constant: 15).isActive = true
        ohjeTeksti2.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        ohjeTeksti2.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        ohjeTeksti3.translatesAutoresizingMaskIntoConstraints = false
        ohjeTeksti3.topAnchor.constraint(equalTo: viiva2.bottomAnchor, constant: 15).isActive = true
        ohjeTeksti3.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        ohjeTeksti3.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        viiva1.translatesAutoresizingMaskIntoConstraints = false
        viiva1.topAnchor.constraint(equalTo: ohjeTeksti.bottomAnchor, constant: -10).isActive = true
        
        viiva2.translatesAutoresizingMaskIntoConstraints = false
        viiva2.topAnchor.constraint(equalTo: ohjeTeksti2.bottomAnchor, constant: -10).isActive = true
        
    }
    
    @objc func PalaaEtusivulle(){ // palaa etusivulle
        
        if(numero == 1){
        let uusiv = TreeniohjelmanTreenitController()
        uusiv.infoAvattunaOlevaOhjelma = self
        uusiv.avattavaOhjelma = avattavaOhjelma
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
        }else{
        let uusiv = ViewController()
        uusiv.modalPresentationStyle = .fullScreen
        present(uusiv, animated: true, completion: nil)
        }
        numero=0
    }
    
    let paluuButton: UIButton = {
           
        let paluuNappi = UIButton(type: UIButton.ButtonType.system)
        paluuNappi.tag = 0
        paluuNappi.addTarget(self, action: #selector(PalaaEtusivulle), for: .touchUpInside)
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
    
    let infoOtsikko: UILabel = {
           
        let infoOtsikko = UILabel()
        infoOtsikko.text = "Info"
        infoOtsikko.textColor = UIColor.black
        infoOtsikko.font = UIFont(name: "CopperPlate-Bold", size: 50)
        return infoOtsikko
    }()

    let otsikkoViiva1: UILabel = {
           
        let viiva1 = UILabel()
        viiva1.text = "______"
        viiva1.textColor = UIColor.black
        viiva1.font = UIFont(name: "CopperPlate-Bold", size: 45)
        return viiva1
    }()
           
    let otsikkoViiva2: UILabel = {
           
        let viiva2 = UILabel()
        viiva2.text = "_____"
        viiva2.textColor = UIColor.black
        viiva2.font = UIFont(name: "CopperPlate-Bold", size: 45)
        return viiva2
    }()
           
       
    let ohjeTeksti: UILabel = {
           
        let l4 = UILabel()
        l4.frame = CGRect(x: 20, y: 100, width: UIScreen.main.bounds.width-50, height: 200)
        l4.numberOfLines=0
        l4.text = "Aloitussivun oikean alareunan painike on uuden ohjelman lisäys-nappi\n\nSitä painamalla voit aloittaa uuden treeniohjelman lisäämisen"
        l4.textColor = UIColor.black
        
        if UIScreen.main.bounds.height > 1000{
            l4.font = UIFont(name: "CopperPlate-Bold", size: 30)
        }
        if UIScreen.main.bounds.height < 900 && UIScreen.main.bounds.height > 700{
            l4.font = UIFont(name: "CopperPlate-Bold", size: 20)
        }
        if UIScreen.main.bounds.height < 700{
            l4.font = UIFont(name: "CopperPlate-Bold", size: 15)
        }
        
        return l4
    }()
    
    let ohjeTeksti2: UILabel = {
              
        let l4 = UILabel()
        l4.frame = CGRect(x: 20, y: 200, width: UIScreen.main.bounds.width-50, height: 200)
        l4.numberOfLines=0
        l4.text = "Aloitussivun vasemman alareunan painike on muokkaus-nappi.\nSe aktivoituu klikkaamalla ja silloin voit valita mitä treeniohjelmaa haluat muokata\n\nValinnan jälkeen voit valita ohjelmasta treenin, jota haluat muokata"
        l4.textColor = UIColor.black
        
        if UIScreen.main.bounds.height > 1000{
            l4.font = UIFont(name: "CopperPlate-Bold", size: 30)
        }
        if UIScreen.main.bounds.height < 900 && UIScreen.main.bounds.height > 700{
            l4.font = UIFont(name: "CopperPlate-Bold", size: 20)
        }
        if UIScreen.main.bounds.height < 700{
            l4.font = UIFont(name: "CopperPlate-Bold", size: 15)
        }
        return l4
    }()
    
    let ohjeTeksti3: UILabel = {
                 
           let l4 = UILabel()
           l4.frame = CGRect(x: 20, y: 300, width: UIScreen.main.bounds.width-50, height: 200)
           l4.numberOfLines=0
           l4.text = "Treeniohjelmien, treenin ja liikkeiden poistaminen:\n\nPyyhkäise niitä vasemmalle, jolloin näkyviin tulee poisto-painike"
           l4.textColor = UIColor.black
        
           if UIScreen.main.bounds.height > 1000{
                l4.font = UIFont(name: "CopperPlate-Bold", size: 30)
           }
           if UIScreen.main.bounds.height < 900 && UIScreen.main.bounds.height > 700{
                l4.font = UIFont(name: "CopperPlate-Bold", size: 20)
           }
           if UIScreen.main.bounds.height < 700{
                l4.font = UIFont(name: "CopperPlate-Bold", size: 15)
           }
           return l4
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
    
    let viiva2: UILabel = {
        let viiva = UILabel()
        viiva.frame = CGRect(x: 0, y: -40, width: 600, height: 100)
        viiva.text = "_______________________________________________________"
        viiva.textColor = UIColor.black
        viiva.font = UIFont(name: "CopperPlate-Bold", size: 38)
        viiva.translatesAutoresizingMaskIntoConstraints = false
        return viiva
    }()

}
