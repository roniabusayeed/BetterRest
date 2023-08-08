//
//  ContentView.swift
//  BetterRest
//
//  Created by Abu Sayeed Roni on 2023-08-05.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false;
    
    var body: some View {
        NavigationView {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep")
                    .font(.headline)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                
                Text("Daily coffee intake")
                    .font(.headline)
                Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
            }
            .navigationTitle("Better Rest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculaor(configuration: config)
            
            // Read hour and minute of wake up time.
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = dateComponents.hour ?? 0
            let minute = dateComponents.minute ?? 0
            
            // Convert wake up hour and minute to seconds.
            let wakeUpTimeInSeconds = (hour * 60 * 60) + (minute * 60)
            
            // Predict bedtime.
            let prediction = try model.prediction(wake: Double(wakeUpTimeInSeconds), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let bedTime = wakeUp - prediction.actualSleep   // Returns a date with a given TimeInterval (typealias for Double representing seconds) subtracted from it.
            
            // Display bedtime.
            alertTitle = "Your ideal bedtime is..."
            alertMessage = bedTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // Something went wrong.
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true // Alert message is shown regardless of errors.
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
