//
//  DelayedRunner.swift
//  India’s fantasy
//
//  Created by admin on 14/07/23.
//

import Foundation

class DelayedRunner
{
    private var seconds:Double = 500
    private var timer:Timer?

    static func initWithDuration(seconds:Double) -> DelayedRunner {
        let obj = DelayedRunner()
        obj.seconds = seconds
        return obj
    }
    
    func run(action: @escaping (()->Void)) {
        if(timer != nil){
            timer?.invalidate()
            timer = nil
        }
        timer = Timer .scheduledTimer(withTimeInterval: seconds, repeats: false, block: { (t) in
            action()
        })
    }
}
