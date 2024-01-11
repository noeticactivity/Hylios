//
//  RoomTypeViewController.swift
//  EtherealDimension
//
//  Created by Gurinder Singh on 1/4/24.
//

import UIKit

protocol SpaceType {
}

enum SpaceTypes: String, CaseIterable {
    case residential //(options: ResidentialSpaces)
    case commercial //(options: CommercialSpaces)
    case `public` //(options: PublicSpaces)
}

enum ResidentialSpaces: String, CaseIterable, SpaceType {
    case appartment
    case bedroom
    case livingRoom = "living room"
    case bathroom
    case kitchen
    case garage
    case outside
    case other
}

enum CommercialSpaces: String, CaseIterable, SpaceType {
    case office
    case restaurant
    case cafe
    case bar
    case gym
    case other
}

enum PublicSpaces: String, CaseIterable, SpaceType {
    case park
    case library
    case monument
    case school
    case metro
    case other
}

class RoomTypeViewController: UIViewController {
    @IBOutlet weak var spaceOptions: UIPickerView!
    
    @IBOutlet weak var spaceType: UISegmentedControl!
    
    lazy var currentSpaceType: SpaceTypes = {
        SpaceTypes.allCases[spaceType.selectedSegmentIndex]
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // overrideUserInterfaceStyle is available with iOS 13
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
    }
    
    @IBAction func spaceTypeChanged(_ sender: UISegmentedControl) {
        currentSpaceType = SpaceTypes.allCases[sender.selectedSegmentIndex]
        spaceOptions.reloadAllComponents()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RoomTypeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch currentSpaceType {
        case .commercial:
            return CommercialSpaces.allCases.count
        case .residential:
            return ResidentialSpaces.allCases.count
        case .public:
            return PublicSpaces.allCases.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentSpaceType == .commercial {
            return CommercialSpaces.allCases[row].rawValue
        } else if currentSpaceType == .residential {
            return ResidentialSpaces.allCases[row].rawValue
        } else {
            return PublicSpaces.allCases[row].rawValue
        }
    }
}
