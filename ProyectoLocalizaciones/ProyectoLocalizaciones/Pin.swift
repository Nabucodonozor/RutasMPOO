//
//  Pin.swift
//  ProyectoLocalizaciones
//
//  Created by 2020-1 on 11/13/19.
//  Copyright © 2019 2020-1. All rights reserved.
//

import MapKit
import AddressBook
import SwiftyJSON

class Pin: NSObject, MKAnnotation{
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var loc: String?
    
    init(title: String, loc: String?, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.coordinate = coordinate
        self.loc = loc
        
        super.init()
    }
    var subtitle: String?{
        return loc
    }
    
    class func from(json: JSON)->Pin?{
        var titulo: String
        if let unTitulo = json["name"].string{
            titulo = unTitulo
        }else{
            titulo = ""
        }
        let localidad = json["location"]["address"].string
        let lat = json["location"]["lat"].doubleValue
        let long = json["location"]["lng"].doubleValue
        let coordenadas = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        return Pin(title: titulo, loc: localidad, coordinate: coordenadas)
    }
    func MapaItem() -> MKMapItem{
        let direccionProp = [String(kABPersonAddressStreetKey) : subtitle]
        let marca = MKPlacemark(coordinate: coordinate, addressDictionary: direccionProp)
        let mapItem = MKMapItem(placemark: marca)
        
        mapItem.name = "\(title) \(subtitle)"
        
        return mapItem
    }
}
