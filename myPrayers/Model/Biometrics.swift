//
//  Biometrics.swift
//  myPrayers
//
//  Created by Bill Clark on 4/22/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import Foundation
import LocalAuthentication

func checkIfDeviceBioCapable()->Bool{
    
    //Check to see if the device has biometric capabilities
    let context = LAContext()
    var result = false
    if #available(iOS 11, *) {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if context.biometryType == .faceID{
            result = true
        }else if context.biometryType == .touchID{
            result = true
        }else if context.biometryType == .none{
            result = false
        }
    }
    return result
}

func checkIfBioActivatedOnDevice()->Bool{
    let context = LAContext()
    var result =  false
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil ){
        //Device is capable, and turned on for this device
        result = true
    }else{
        //Device is capable, but not turned on for this device
        result = false
    }
    return result
}
