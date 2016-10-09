//
//  TutorialViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 1/16/16.
//  Copyright © 2016 Mobile BR. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textHeading: UILabel!
    @IBOutlet weak var textContent: UILabel!
    @IBOutlet weak var imageContent: UIImageView!
    @IBOutlet var pageContol: UIPageControl!
    
    let textHeadingArray = [
        "Favoritar","Próximos a Mim",
        "Filtrar",
        "Mais Opções",
        "Postar Trabalho",
        "Categorias",
        "Facilite o Contato"
    ]
    
    let textContentArray = [
        "Arraste para a esquerda e veja as opções Favoritar, Publicar e Outros",
        "Um clique na bússola e você verá os trabalhos próximos a você. Clique e segure para definir a distância",
        "Clique no ícone do filtro ou no texto para filtrar os resultados, ou use o campo de busca",
        "Se for o criador do post, terá opções como: Entrar em contato, Ver Interessados, Editar ou Apagar o post",
        "Use a opção Quero Contratar para oferecer uma vaga de trabalho, ou Quero Trabalhar para procurar uma",
        "Defina categorias que combinam com o que você faz, ou acrescente uma nova clicando em Sugerir",
        "Cadastre um telefone e preencha seu perfil corretamente, isso aumenta as chances de ser contratado"
    ]
    
    var imagesArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Tutorial"
        self.addLeftNavItemOnView()
        self.addRightNavItemOnView()
        
        let leftswap = UISwipeGestureRecognizer(target: self, action: Selector("handleSwap:"))
        let rightswap = UISwipeGestureRecognizer(target: self, action: Selector("handleSwap:"))
        
        for (var i = 0; i < self.textHeadingArray.count; i++) {
            self.imagesArray.append(UIImage(named: "tutorial\(i + 1).png")!)
        }
        
        self.textHeading.text = self.textHeadingArray[0]
        self.textContent.text = self.textContentArray[0]
        self.imageContent.image = self.imagesArray[0]
        self.pageContol.numberOfPages = self.textHeadingArray.count
        
        leftswap.direction = .Left
        rightswap.direction = .Right
        self.view.addGestureRecognizer(leftswap)
        self.view.addGestureRecognizer(rightswap)
    }
    
    
    func handleSwap(sender:UISwipeGestureRecognizer){
        if (sender.direction == .Left) {
            pageContol.currentPage += 1
            textHeading.text = textHeadingArray[pageContol.currentPage]
            textContent.text = textContentArray[pageContol.currentPage]
            imageContent.image = imagesArray[pageContol.currentPage]
        }
        
        if (sender.direction == .Right) {
            pageContol.currentPage -= 1
            textHeading.text = textHeadingArray[pageContol.currentPage]
            textContent.text = textContentArray[pageContol.currentPage]
            imageContent.image = imagesArray[pageContol.currentPage]
        }
    }
    
    
    @IBAction func slideTheScreen(sender: AnyObject) {
        textHeading.text = textHeadingArray[pageContol.currentPage]
        textContent.text = textContentArray[pageContol.currentPage]
        imageContent.image = imagesArray[pageContol.currentPage]
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
}
