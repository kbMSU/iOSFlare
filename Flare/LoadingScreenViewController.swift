//
//  LoadingScreenViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/24/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        moveToMapScene()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func moveToMapScene() {
        //let mapScene = self.storyboard?.instantiateViewControllerWithIdentifier("MapScreen") as! MapViewController
        //self.navigationController?.pushViewController(mapScene, animated: true)
        //self.navigationController?.navigationBarHidden = false
        //self.navigationController?.popViewControllerAnimated(true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("MapScreen") as UIViewController
        presentViewController(viewController, animated: true, completion: nil)
    }

}
