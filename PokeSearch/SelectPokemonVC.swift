//
//  SelectPokemonVC.swift
//  PokeSearch
//
//  Created by Steven Santiago on 3/11/17.
//  Copyright © 2017 Steven Santiago. All rights reserved.
//

import UIKit

//UICollectionViewDataSource protocol responsible for providing the data and views required by a collection view(creation and configuration of cells


protocol PokemonDelegate : class {
    func pokemonSelected(pokemonSel: String)
}

class SelectPokemonVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate : PokemonDelegate? = nil
    
    
    var inSearch = false
    var filteredPokemon = [String]() // filteredPokemon
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonFound", for: indexPath) as? PokemonCell {
            let poke: String
            if inSearch{
                poke = filteredPokemon[indexPath.row]
            } else {
                poke = pokemon[indexPath.row]
            }
            cell.configureCell(pokemon: poke)
            return cell
        }   else {
            return UICollectionViewCell()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var poke: String
        
        if inSearch {
            poke = filteredPokemon[indexPath.row]
        } else {
            poke = pokemon[indexPath.row]
        }
        delegate?.pokemonSelected(pokemonSel: poke)
        dismiss(animated: true, completion: nil)
    }
    
    
    //Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearch {
            return filteredPokemon.count
        } else {
            return pokemon.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
 
 
    
    // Size of cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { // makes keyboard go away  after searching
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearch = false
            collectionView.reloadData()
            view.endEditing(true)
        } else {
            inSearch = true
            let uppercase = searchBar.text!.capitalized //
            filteredPokemon = pokemon.filter({$0.range(of: uppercase) != nil})
            collectionView.reloadData()
        }
    }
 
    


 


}
