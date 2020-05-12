//
//  Biometrics.swift
//  myPrayers
//
//  Created by Bill Clark on 4/22/20.
//  Copyright © 2020 Bill Clark. All rights reserved.
//

import Foundation
import LocalAuthentication

func checkBioType()->LABiometryType{
    
    //Check to see if the device has biometric capabilities
    let context = LAContext()
    var result: LABiometryType!
    
    if #available(iOS 11, *) {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if context.biometryType == .faceID{
            result = LABiometryType .faceID
        }else if context.biometryType == .touchID{
            result = LABiometryType .touchID
        }else if context.biometryType == .none{
            result = LABiometryType .none
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
