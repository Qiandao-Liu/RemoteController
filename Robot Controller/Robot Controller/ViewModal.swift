//
//  ViewModal.swift
//  Robot Controller
//
//  Created by Qiandao Liu on 4/27/24.
//

import Foundation
import SwiftUI
import Combine


class RobotViewModel: ObservableObject {
    @Published var statusMessage: String = "Ready"  // ready for start monitoring rocker
    @Published var lastGripState: Bool = true  // true for catch, false for release
    @Published var gripperPosition = [0.0, 0.0, 0.0]
    @Published var basePosition = [0.0, 0.0, 0.0]
    private var timer: AnyCancellable?
    private var pollingTimer: Timer?
    private var lastDirection: String = ""

    // MARK: - Rocker
    func sendJoystickDirection(direction: String) {
        guard !direction.isEmpty else {
            print("Direction is empty, not sending request.")
            return
        }
        let urlString = "http://127.0.0.1:8000/joystick-direction/"
        guard let url = URL(string: urlString) else { return }

        let body: [String: String] = ["direction": direction]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.statusMessage = "Network error: \(error)"
                }
                return
            }
            DispatchQueue.main.async {
                self.statusMessage = "Joystick direction sent"
            }
        }.resume()
    }
    
    func startSendingJoystickDirection() {
        // 取消之前的计时器，以避免重复发送
        timer?.cancel()
        timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                self?.sendJoystickDirection(direction: self?.lastDirection ?? "")
            }
    }
    
    func stopSendingJoystickDirection() {
        timer?.cancel()
    }
    
    func updateDirection(direction: String) {
        // 更新最后一次的方向
        lastDirection = direction
    }
    
    // MARK: - fetch positions
    
    func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.fetchPositions()
        }
    }
    
    func stopPolling() {
        pollingTimer?.invalidate()
    }

    func fetchPositions() {
        let urlString = "http://127.0.0.1:8000/get-positions/"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.statusMessage = "Error fetching positions: \(error?.localizedDescription ?? "Unknown error")"
                }
                return
            }
            if let decodedResponse = try? JSONDecoder().decode(PositionsResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.gripperPosition = decodedResponse.gripperPosition
                    self.basePosition = decodedResponse.basePosition
                }
            }
        }.resume()
    }
    
    
    // MARK: - catch/release
    func toggleGrip() {
        lastGripState.toggle()
        let command = lastGripState ? "catch" : "release"
        sendGripCommand(command: command)
    }

    private func sendGripCommand(command: String) {
        let urlString = "http://127.0.0.1:8000/grip-command/"
        guard let url = URL(string: urlString) else { return }

        let body: [String: String] = ["command": command]
        sendPostRequest(url: url, body: body)
    }
    
    // MARK: - Storage for Positions
    
    func storePositions() {
        let defaults = UserDefaults.standard
        defaults.set(gripperPosition, forKey: "gripperPosition")
        defaults.set(basePosition, forKey: "basePosition")
        print("Positions stored: Gripper - \(gripperPosition), Base - \(basePosition)")
    }

    struct PositionsResponse: Codable {
        var gripperPosition: [Double]
        var basePosition: [Double]
    }

    // MARK: - Load Stored Positions
    
    func sendPositionsToServer() {
        let urlString = "http://127.0.0.1:8000/set-positions/"
        guard let url = URL(string: urlString) else { return }
        
        let positionsData = [
            "gripperPosition": gripperPosition,
            "basePosition": basePosition
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: positionsData) else {
            print("Error: Cannot encode data")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.statusMessage = "Network error: \(error)"
                }
                return
            }
            DispatchQueue.main.async {
                self.statusMessage = "Positions sent to server"
            }
        }.resume()
    }

    
    // MARK: - Arm commands
    
    func resetRobot() {
        sendArmCommand(command: "resetrobot")
    }
    
    func startExtending() {
        sendArmCommand(command: "extend")
    }

    func startShrinking() {
        sendArmCommand(command: "shrink")
    }
    
    func startLifting() {
        sendArmCommand(command: "lift")
    }

    func startDropping() {
        sendArmCommand(command: "drop")
    }
    
    private func sendArmCommand(command: String) {
        let urlString = "http://127.0.0.1:8000/arm-command/"
        guard let url = URL(string: urlString) else { return }

        let body: [String: String] = ["command": command]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.statusMessage = "Network error: \(error)"
                }
                return
            }
            DispatchQueue.main.async {
                self.statusMessage = "Command sent"
            }
        }.resume()
    }
    
    
    // MARK: - Helpers
    private func sendPostRequest(url: URL, body: [String: String]) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.statusMessage = "Network error: \(error)"
                }
                return
            }
            DispatchQueue.main.async {
                self.statusMessage = "Command sent"
            }
        }.resume()
    }
    
}
