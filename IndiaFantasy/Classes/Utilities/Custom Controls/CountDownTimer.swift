//
//  CountDownTimer.swift
//  Ultrafair
//
//  Created by admin on 13/09/23.
//

import UIKit

public typealias CompletionHandler = () -> Void

protocol CountDown: NSObjectProtocol {

    var timeLeft: String? {get}
    var isFinished: Bool {get}
    var isRunning: Bool {get}
    
    /// Executed on completion
    var completion: CompletionHandler? {get set}
    /// Executed every iteration
    var repeatingTask: CompletionHandler? {get set}
    
    func start()
    func stop()
    func reset()
    func restart()
}

final class CountDownTimer: NSObject, CountDown {
    
    init(endsOn date: Date, repeatingTask: CompletionHandler?, completion: CompletionHandler?) {
        self.eventDate = date
        self.repeatingTask = repeatingTask
        self.completion = completion
        self.currentDate = Date()
    }
    
    deinit {
        displayLink?.invalidate()
        repeatingTask = nil
        completion = nil
    }

    var timeLeft: String?
    
    var eventDate: Date {
        didSet {
            // Reset
            reset()
        }
    }
    
    var isFinished: Bool {
        return currentDate >= eventDate
    }
    
    var isRunning: Bool {
        return !(displayLink?.isPaused ?? true)
    }
    
    var completion: CompletionHandler?
    var repeatingTask: CompletionHandler?
    
    private var currentDate: Date
    private weak var displayLink: CADisplayLink?
    
    func start() {
        self.currentDate = Date()
        let displayLink = CADisplayLink(target: self, selector: #selector(refreshStats))
        displayLink.add(to: .current, forMode: RunLoop.Mode.common)
        self.displayLink = displayLink
    }
    
    func stop() {
        displayLink?.invalidate()
    }
    
    func reset() {
        displayLink?.invalidate()
    }
    
    func restart() {
        self.reset()
        self.start()
    }
    
    @objc private func refreshStats() {
        guard !isFinished else {
            completion?()
            stop()  // stop timer
            return
        }
        
        let now = Date()
        timeLeft = self.timeRemeaning(eventDate: eventDate, currentDate: now)
        currentDate = now
        repeatingTask?()
    }
    
    func timeRemeaning(eventDate: Date, currentDate: Date) -> String {
        
        var leftTime = ""
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: currentDate.toLocalTime(), to: eventDate.toLocalTime())
        
        if(dateComponents.hour ?? 0 >= 0 && dateComponents.minute ?? 0 >= 0  && dateComponents.second ?? 0 >= 0 ) {
            
            if dateComponents.hour ?? 0 > 24 {
                let diffDayComponents = calendar.dateComponents([.day, .hour, .minute], from: currentDate.toLocalTime(), to: eventDate.toLocalTime())
                leftTime = "\(diffDayComponents.day ?? 0)d : \(diffDayComponents.hour ?? 0)h"
                
            }else if dateComponents.hour ?? 0 >= 1 {
                leftTime = "\(dateComponents.hour ?? 0)h : \(dateComponents.minute ?? 0)m"
                
            }else {
                leftTime = "\(dateComponents.minute ?? 0)m : \(dateComponents.second ?? 0)s"
            }
            
            return leftTime
        }
        return ""
    }
}

