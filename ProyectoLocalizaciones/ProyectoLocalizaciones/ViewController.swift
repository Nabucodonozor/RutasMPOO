//
//  ViewController.swift
//  ProyectoLocalizaciones
//
//  Created by 2020-1 on 11/6/19.
//  Copyright © 2019 2020-1. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class ViewController: UIViewController{

    
    
    @IBOutlet weak var mapa: MKMapView!
    
    var pins = [Pin]()
    
    func Datos(){
        let nombreData = Bundle.main.path(forResource: "Venues", ofType: "json")
        let direccion = URL(fileURLWithPath: nombreData!)
        var data: Data?
        do{
            data = try Data(contentsOf: direccion, options: Data.ReadingOptions(rawValue: 0))
        }catch let error{
            data = nil
            print(":::::Error localizado en: \(error.localizedDescription)")
        }
        if let jsonData = data{
            let json = try? JSON(data: jsonData)
            if let pinJSONs = json?["response"]["venues"].array{
                for pinJSON in pinJSONs {
                    if let venue = Pin.from(json: pinJSON){
                        self.pins.append(venue)
                        
                    }
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        let initialLocation = CLLocation(latitude: 19.3272501, longitude: -99.1825469 )
        
        ZoomMapa(location: initialLocation)
        
        let ingenieria = Pin(title: "Facultad de Ingenieria", loc: "Facultad de Ingenieria, ciudad universitaria", coordinate: CLLocationCoordinate2D(latitude: 19.3272501, longitude: -99.1825469))
        
        mapa.addAnnotation(ingenieria)
        mapa.delegate = self
        Datos()
        mapa.addAnnotations(pins)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationServiceAuthenticationStatus()
    }
    private let parametroAmpliacion: CLLocationDistance = 1000//Parametro de ampliacion o zoom del mapa
    func ZoomMapa(location: CLLocation){
        
        let coordenadas = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: parametroAmpliacion * 2.0, longitudinalMeters: parametroAmpliacion * 2.0)
        
        mapa.setRegion(coordenadas, animated: true)
    }
    //Agregando la localizacion actual
    var localAct = CLLocationManager()
    
    func checkLocationServiceAuthenticationStatus(){
        localAct.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            //No le autorizamos siempre porque no es recomendable que se exhiban datos o localizaciones que puedan revelar las posiciones exactas de una persona es por ello que por ejemplo si la camara esta abiera aun da la autorizacion de que se ejecute en segundo plano los Status de localidad, por eso utilizamos el authorized  when in use
            mapa.showsUserLocation = true
        }else{
            localAct.requestWhenInUseAuthorization()
        }
    }
}
extension ViewController : CLLocationManagerDelegate{
    
}

extension ViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? Pin{
            let identificador = "Pin"
            var vista: MKAnnotationView
            if let dequeueView = mapa.dequeueReusableAnnotationView(withIdentifier: identificador) as? MKPinAnnotationView{
                dequeueView.annotation = annotation
                vista = dequeueView
                
            }else {
                vista = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identificador)
                vista.canShowCallout = true
                vista.calloutOffset = CGPoint(x: -5, y: 5)
                vista.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return vista
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let locacion = view.annotation as! Pin
        //Lo que hacemos aqui es obtener un metodo de ruta para que el usuario se pueda desplazar, en este caso en carro
        let viaje = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
        locacion.MapaItem().openInMaps(launchOptions: viaje)
    }
}
