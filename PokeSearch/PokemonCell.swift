//
//  PokemonCell.swift
//  PokeSearch
//
//  Created by Steven Santiago on 3/11/17.
//  Copyright © 2017 Steven Santiago. All rights reserved.
// Class will let me customize the cell in the collection view

import UIKit

class PokemonCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        layer.cornerRadius = 5.0
    }
    
    func configureCell (pokemon: String) {
        label.text = pokemon
        thumbImg.image = UIImage(named: String(describing: pokemonDict[pokemon]!) )
    }
    
}
