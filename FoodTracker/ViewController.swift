//
//  ViewController.swift
//  FoodTracker
//
//  Created by Diego Valderrama on 6/14/15.
//  Copyright (c) 2015 Diego Valderrama. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    
    var searchController:UISearchController!
    
    //Hold the strings of our food
    var suggestedSearchFoods:[String] = []
    
    //Hold the results of our search
    var filteredSuggestedSearchFoods:[String] = []
    
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    let kAppId = "c4184496"
    let kAppKey = "3e544633db50e3309acda8bbd5209706"
    
    //To access the functions in data controller
    var dataController = DataController()
    
    var favoritedUSDAItems: [USDAItem] = []
    
    //Used when the searchController is active
    var filteredFavoritedUSDAItems:[USDAItem] = []
    
    //Will store the json response
    var jsonResponse:NSDictionary!
    //An array of tuples
    var apiSearchForFoods:[(name: String, idValue: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        //This code will set our search bar into a new CGRect that we will create:
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
        
        //Update our tableview header with our new search bar:
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        //Update the scope ButtonTitles
        self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        //Now, we need to set the search controller delegate = self, which allows us to get access to callbacks that occur in the search bar.
        self.searchController.searchBar.delegate = self
        
        //Now, we need to set the presentation context to true, which will ensure the search results controller is presented inside the view controller:
        self.definesPresentationContext = true
        
        self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicken breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailVCSegue" {
            if sender != nil {
                var detailVC = segue.destinationViewController as! DetailViewController
                detailVC.usdaItem = sender as? USDAItem //We have to add the ? cause usdItem is an optional
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        var foodName : String
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {//We are in the search bar
                foodName = filteredSuggestedSearchFoods[indexPath.row]
            }
            else {
                foodName = suggestedSearchFoods[indexPath.row]
            }
        }
        else if selectedScopeButtonIndex == 1 {
            foodName = apiSearchForFoods[indexPath.row].name
        }
        else {//selectedScopeButtonIndex = 2 it means is on save button
            
            if self.searchController.active {
                foodName = self.filteredFavoritedUSDAItems[indexPath.row].name
            }
            else {
                foodName = self.favoritedUSDAItems[indexPath.row].name
            }
        }
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 0 {
            if self.searchController.active {//We are in the search bar
                return self.filteredSuggestedSearchFoods.count
            }
            else {
                return self.suggestedSearchFoods.count
            }
        }
        else if selectedScopeButtonIndex == 1 {
            return self.apiSearchForFoods.count
        }
        else {//selected button index = 2 it means saved button
            
            if self.searchController.active {
                return self.filteredFavoritedUSDAItems.count
            }
            else {
                return self.favoritedUSDAItems.count
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {//Recommended
            var searchFoodName:String
            
            if self.searchController.active {//Is on the search bar
                searchFoodName = filteredSuggestedSearchFoods[indexPath.row]
            }
            else {
                searchFoodName = suggestedSearchFoods[indexPath.row]
            }
            self.searchController.searchBar.selectedScopeButtonIndex = 1
            makeRequest(searchFoodName)
        }
        else if selectedScopeButtonIndex == 1 {//Search Results
            //self.performSegueWithIdentifier("toDetailVCSegue", sender: nil)
            let idValue = apiSearchForFoods[indexPath.row].idValue
            self.dataController.saveUSDAItemForId(idValue, json: self.jsonResponse)
        }
        else if selectedScopeButtonIndex == 2 {//Saved
            if self.searchController.active {
                let usdaItem = filteredFavoritedUSDAItems[indexPath.row]
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            }
            else {
                let usdaItem = favoritedUSDAItems[indexPath.row]
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            }
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    //This function is called everytime we make changes in the search bar
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchString = self.searchController.searchBar.text //Access the text is being typed
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        self.tableView.reloadData()
        
    }
    
    // MARK: - Helper Functions
    
    func filterContentForSearch (searchText: String, scope: Int) {
        
        if scope == 0{
            //Updates the filteredSuggestedSearchFoods
            self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food : String) -> Bool in
                //Look for the searchText in each element of suggestedSearchFoods
                var foodMatch = food.rangeOfString(searchText)
                //var foodMatch = food.lowercaseString.rangeOfString(searchText.lowercaseString)
                return foodMatch != nil
            })
        }else if scope == 2 {//We dont need to do filtering on SearchResults == 1
            self.filteredFavoritedUSDAItems = self.favoritedUSDAItems.filter({ (item: USDAItem) -> Bool in
                var stringMatch = item.name.rangeOfString(searchText)
                //An improve to find the searchText non case sensitive
                //var stringMatch = item.name.lowercaseString.rangeOfString(searchText.lowercaseString)
                return stringMatch != nil
            })
        }
        
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //Set the target on searchResults
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        makeRequest(searchBar.text)
    }
    
    //Update the table view when the index in search bar is changed
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //Calls the function of items saved if the scope is on Save button (0 1 2)
        if selectedScope == 2 {
            requestFavoritedUSDAItems()
        }
        self.tableView.reloadData()
    }
    
    //Set up a Request
    func makeRequest (searchString : String) {
        //How to make a HTTP GET Request
        /*
        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            //Convert our data to a readable string.
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(stringData)
            println(response)
        })
        task.resume()
        */
        
        //HTTP POST Request
        
        //A mutable NSURL request allows us to change the request and enter a single request and pass it over to be used with out post request
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        var params = [
            "appId" : kAppId,
            "appKey" : kAppKey,
            "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit"  : "50",
            "query"  : searchString,
            "filters": ["exists":["usda_fields": true]]]
        var error: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //To add the waiting icon beside the signal bar
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //Make the request. The completion Handler is like a Treath
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            
            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println(stringData)
            
            var conversionError: NSError?
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            println(jsonDictionary)
            
            //Managing errors
            if conversionError != nil {
                println(conversionError!.localizedDescription)
                let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error in Parsing \(errorString)")
            }
            else {
                if jsonDictionary != nil {
                    //Store the jsonDictionary in jsonResponse
                    self.jsonResponse = jsonDictionary!
                    //apiSearchForFoods will update the table view
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
                    
                    //Removing the waiting icon beside the signal bar
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    
                    //self.tableView.reloadData()
                    //Update the main thread instead of witing and letting it update in background thread
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                else {
                    let errorString = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error Could not Parse JSON \(errorString)")
                }                
            }
        })
        
        task.resume()
    }
    
    // MARK: - Setup CoreData
    func requestFavoritedUSDAItems () {
        let fetchRequest = NSFetchRequest(entityName: "USDAItem")
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        self.favoritedUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as! [USDAItem]
    }

}

