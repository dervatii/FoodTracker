//
//  DataController.swift
//  FoodTracker
//
//  Created by Diego Valderrama on 6/16/15.
//  Copyright (c) 2015 Diego Valderrama. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    
    class func jsonAsUSDAIdAndNameSearchResults (json : NSDictionary) -> [(name: String, idValue: String)] {
        
        //Array to hold the tuples
        var usdaItemsSearchResults:[(name : String, idValue: String)] = []
        
        var searchResult: (name: String, idValue : String)
        
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as! [AnyObject]
            
            //itemDictionary will search in all the contents
            for itemDictionary in results {
                
                if itemDictionary["_id"] != nil {
                    if itemDictionary["fields"] != nil {
                        
                        let fieldsDictionary = itemDictionary["fields"] as! NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                        
                            let idValue:String = itemDictionary["_id"]! as! String
                            let name:String = fieldsDictionary["item_name"]! as! String
                            //Add the tuple to the var  searchResul
                            searchResult = (name : name, idValue : idValue)
                            usdaItemsSearchResults += [searchResult]
                        }
                    }
                }
            }
        }
        
        return usdaItemsSearchResults
    }
    
    func saveUSDAItemForId(idValue: String, json : NSDictionary) {
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as! [AnyObject]
            for itemDictionary in results {
                
                //Here we are just confirming our id, for our dictionary, is not nil as well as, confirm our idValue is the same as the value we are passing in.
                 if itemDictionary["_id"] != nil && itemDictionary["_id"] as! String == idValue { }
                
                //Now that we know we have the correct dictionary, we are going to create a managed object context which will allow us to do a search. We also, want to confirm we haven't already saved this dictionary.
                let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                
                var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
                let itemDictionaryId = itemDictionary["_id"]! as! String
                
                //Create an NSPredicate instance checks if idValue = %@, where %@ will be replaced for itemDictionaryId
                let predicate = NSPredicate(format: "idValue == %@", itemDictionaryId)
                
                requestForUSDAItem.predicate = predicate
                var error: NSError?
                var items = managedObjectContext?.executeFetchRequest(requestForUSDAItem, error: &error)
                
                //Using an if statement, we will determine if our item count does NOT equal zero, which means we have saved our item already, if not (else) we need to save it to core data.
                if items?.count != 0 {
                    //The item is already saved
                    println("The item was already saved")
                    return
                }
                else {
                    println("Lets Save this to CoreData!")
                    
                    let entityDescription = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: managedObjectContext!)
                    let usdaItem = USDAItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                    usdaItem.idValue = itemDictionary["_id"]! as! String
                    
                    usdaItem.dateAdded = NSDate()
                    
                    if itemDictionary["fields"] != nil {
                        
                        let fieldsDictionary = itemDictionary["fields"]! as! NSDictionary
                        
                        if fieldsDictionary["item_name"] != nil {
                            usdaItem.name = fieldsDictionary["item_name"]! as! String
                        }
                        
                        //Now that we are in the fields dictionary, we want to index into the usda_fields dictionary, so that we can retrieve even more info.
                        if fieldsDictionary["usda_fields"] != nil {
                            let usdaFieldsDictionary = fieldsDictionary["usda_fields"]! as! NSDictionary
                            
                            // Calcium Grouping (optional to add this comment)
                            if usdaFieldsDictionary["CA"] != nil {
                                let calciumDictionary = usdaFieldsDictionary["CA"]! as! NSDictionary
                                let calciumValue: AnyObject = calciumDictionary["value"]!
                                usdaItem.calcium = "\(calciumValue)"
                            }
                            else {
                                usdaItem.calcium = "0"
                            }
                            
                            // Carbohydrate Grouping (optional to add this comment)
                            if usdaFieldsDictionary["CHOCDF"] != nil {
                                let carbohydrateDictionary = usdaFieldsDictionary["CHOCDF"]! as! NSDictionary
                                if carbohydrateDictionary["value"] != nil {
                                    let carbohydrateValue: AnyObject = carbohydrateDictionary["value"]!
                                    usdaItem.carbohydrate = "\(carbohydrateValue)"
                                }
                            }
                            else {
                                usdaItem.carbohydrate = "0"
                            }
                            
                            // FAT Grouping (optional to add this comment)
                            if usdaFieldsDictionary["FAT"] != nil {
                                let fatTotalDictionary = usdaFieldsDictionary["FAT"]! as! NSDictionary
                                if fatTotalDictionary["value"] != nil {
                                    let fatTotalValue:AnyObject = fatTotalDictionary["value"]!
                                    usdaItem.fatTotal = "\(fatTotalValue)"
                                }
                            }
                            else {
                                usdaItem.fatTotal = "0"
                            }
                            
                            // Cholesterol Grouping (optional to add this comment)
                            if usdaFieldsDictionary["CHOLE"] != nil {
                                let cholesterolDictionary = usdaFieldsDictionary["CHOLE"]! as! NSDictionary
                                if cholesterolDictionary["value"] != nil {
                                    let cholesterolValue: AnyObject = cholesterolDictionary["value"]!
                                    usdaItem.cholesterol = "\(cholesterolValue)"
                                }
                            }
                            else {
                                usdaItem.cholesterol = "0"
                            }
                            // Protein Grouping (optional to add this comment)
                            if usdaFieldsDictionary["PROCNT"] != nil {
                                let proteinDictionary = usdaFieldsDictionary["PROCNT"]! as! NSDictionary
                                if proteinDictionary["value"] != nil {
                                    let proteinValue: AnyObject = proteinDictionary["value"]!
                                    usdaItem.protein = "\(proteinValue)"
                                }
                            }
                            else {
                                usdaItem.protein = "0"
                            }
                            
                            // Sugar Total
                            if usdaFieldsDictionary["SUGAR"] != nil {
                                let sugarDictionary = usdaFieldsDictionary["SUGAR"]! as! NSDictionary
                                if sugarDictionary["value"] != nil {
                                    let sugarValue:AnyObject = sugarDictionary["value"]!
                                    usdaItem.sugar = "\(sugarValue)"
                                }
                            }
                            else {
                                usdaItem.sugar = "0"
                            }
                            // Vitamin C
                            if usdaFieldsDictionary["VITC"] != nil {
                                let vitaminCDictionary = usdaFieldsDictionary["VITC"]! as! NSDictionary
                                if vitaminCDictionary["value"] != nil {
                                    let vitaminCValue: AnyObject = vitaminCDictionary["value"]!
                                    usdaItem.vitaminC = "\(vitaminCValue)"
                                }
                            }
                            else {
                                usdaItem.vitaminC = "0"
                            }
                            // Energy
                            if usdaFieldsDictionary["ENERC_KCAL"] != nil {
                                let energyDictionary = usdaFieldsDictionary["ENERC_KCAL"]! as! NSDictionary
                                if energyDictionary["value"] != nil {
                                    let energyValue: AnyObject = energyDictionary["value"]!
                                    usdaItem.energy = "\(energyValue)"
                                }
                            }
                            else {
                                usdaItem.energy = "0"
                            }
                            
                            //Save our information to care data.
                            (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()

                        }
                    }
                }
            }
        }
    }

}