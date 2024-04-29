//
//  ContentView.swift
//  Robot Controller
//
//  Created by Qiandao Liu on 4/27/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            TabView {
                RemoteControlView()
                    .tabItem {
                        Label("Controller", systemImage: "pencil")
                    }
                
                SecondView()
                    .tabItem {
                        Label("Robot", systemImage: "gear")
                    }
            }
            .navigationTitle("RCareWorld")
        }
    }
}
        
struct RemoteControlView: View {
    @EnvironmentObject var viewModel: RobotViewModel
    @State private var joystickLocation = CGPoint.zero
    @State private var isGripperClosed = true  // 跟踪夹子闭合
    
    var body: some View {
        GeometryReader { geometry in
            
            // Lift Button
            Button("🔼") {
                viewModel.startLifting()
            }
            .padding()
            .background(Color.ownRubyTran)
            .foregroundColor(.white)
            .font(.title)
            .cornerRadius(8)
            .frame(width: 100, height: 50)
            .position(x: geometry.size.width * 0.88, y: geometry.size.height * 0.48)
            
            // Drop Button
            Button("🔽") {
                viewModel.startDropping()
            }
            .padding()
            .background(Color.ownRubyTran)
            .foregroundColor(.white)
            .font(.title)
            .cornerRadius(8)
            .frame(width: 100, height: 50)
            .position(x: geometry.size.width * 0.88, y: geometry.size.height * 0.6)
            
            // extend Button
            Button("🫳") {
                viewModel.startExtending()
            }
            .padding()
            .background(Color.ownRiceTran)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            .frame(width: 100, height: 50)
            .position(x: geometry.size.width * 0.43, y: geometry.size.height * 0.53)
            
            // shrink Button
            Button("🤜") {
                viewModel.startShrinking()
            }
            .padding()
            .background(Color.ownRiceTran)
            .foregroundColor(.white)
            .cornerRadius(8)
            .frame(width: 100, height: 50)
            .position(x: geometry.size.width * 0.62, y: geometry.size.height * 0.53)
            
            // reset robot
            Button("set") {
                viewModel.storePositions()
            }
            .padding()
            .background(Color.ownDeepRed)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .cornerRadius(8)
            .frame(width: 100, height: 50)
            .position(x: geometry.size.width * 0.32, y: geometry.size.height * 0.27)
            
            // load robot
            Button("load") {
                viewModel.sendPositionsToServer()
            }
            .padding()
            .background(Color.ownDeepRed)
            .foregroundColor(.white)
            .fontWeight(.bold)
            .cornerRadius(8)
            .frame(width: 100, height: 50)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.27)
            
            // reset base
            Button("reset") {
                viewModel.resetRobot()
            }
            .padding()
            .background(Color.ownDeepRed)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .cornerRadius(8)
            .frame(width: 150, height: 50)
            .position(x: geometry.size.width * 0.7, y: geometry.size.height * 0.27)
            
            
            // gripper
            Button("🤌") {
                viewModel.toggleGrip()
            }
            .padding()
            .background(Color.ownDeepGreenTran)
            .foregroundColor(.white)
            .cornerRadius(8)
            .position(x: geometry.size.width * 0.16, y: geometry.size.height * 0.68)
            
            // rocker
            JoystickView(location: $joystickLocation)
                .frame(width: 200, height: 200)
                .onAppear {
                    viewModel.startSendingJoystickDirection()
                }
                .position(x: geometry.size.width * 0.57, y: geometry.size.height * 0.8)
                .onDisappear {
                    viewModel.stopSendingJoystickDirection()
                }
            
            Text("Gripper Position: \(format(position: viewModel.gripperPosition))")
                .bold()
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.13)
            Text("Base Position: \(format(position: viewModel.basePosition))")
                .bold()
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.18)
            
                .onAppear(perform: viewModel.startPolling)
                .onDisappear(perform: viewModel.stopPolling)
        }
    }
    
    private func format(position: [Double]) -> String {
        return position.map { String(format: "%.2f", $0) }.joined(separator: ", ")
    }

//    // Simulate polling function
//    private func startPolling() {
//        // Assuming an update function exists in your view model
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            fetchPositions()
//        }
//    }
//    
//    private func fetchPositions() {
//        let urlString = "http://127.0.0.1:8000/get-positions/"
//        guard let url = URL(string: urlString) else { return }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error fetching positions: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            if let decodedResponse = try? JSONDecoder().decode(PositionsResponse.self, from: data) {
//                DispatchQueue.main.async {
//                    self.gripperPosition = decodedResponse.gripperPosition
//                    self.basePosition = decodedResponse.basePosition
//                }
//            }
//        }.resume()
//    }
}

struct PositionsResponse: Codable {
    var gripperPosition: [Double]
    var basePosition: [Double]
}

// MARK: - second page

struct SecondView: View {
    var body: some View {
        GeometryReader { geometry in
            Image("robot")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.2)
            

            Text("model: stretch-3")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .position(x: geometry.size.width * 0.46, y: geometry.size.height * 0.4)
                .padding()
            
            Text("gripper: 1")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .position(x: geometry.size.width * 0.46, y: geometry.size.height * 0.46)
                .padding()
            
            Text("movable joints: 8")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .position(x: geometry.size.width * 0.46, y: geometry.size.height * 0.51)
                .padding()
            
            Text("max-speed: 0.004m/s")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .position(x: geometry.size.width * 0.46, y: geometry.size.height * 0.56)
                .padding()

            
            
            Button("Switch Robot") {
                // switch robot
            }
            .padding()
            .background(Color.ownDeepOrange)
            .foregroundColor(.white)
            .cornerRadius(8)
            .frame(width: 300, height: 50)
            .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.9)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(RobotViewModel())
    }
}

// MARK: - Rocker
struct JoystickView: View {
    @Binding var location: CGPoint
    @EnvironmentObject var viewModel: RobotViewModel
    
    let size: CGFloat = 200
    let knobSize: CGFloat = 50

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size, height: size)
            Circle()
                .fill(Color.ownBlue)
                .frame(width: knobSize, height: knobSize)
                .offset(x: location.x, y: location.y)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            change(location: value.location)
                        }
                        .onEnded { _ in
                            withAnimation {
                                location = .zero  // auto back
                                viewModel.updateDirection(direction: "center")
                            }
                        }
                )
        }
    }
    
    // change location x, y
    private func change(location: CGPoint) {
        let vector = CGVector(dx: location.x - size / 2, dy: location.y - size / 2)
        let distance = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
        let radius = size / 2 - knobSize / 2
        if distance > radius {
            let angle = atan2(vector.dy, vector.dx)
            self.location = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
        } else {
            self.location = CGPoint(x: vector.dx, y: vector.dy)
        }
        let direction = calculateDirection(location: location)
        viewModel.updateDirection(direction: direction)
    }
    
    // algrithem to decide direction
    private func calculateDirection(location: CGPoint) -> String {
        let dx = location.x - size / 2
        let dy = location.y - size / 2
        let threshold: CGFloat = 30  // threshold, area for decision

        switch (dx, dy) {
            case (_, let y) where abs(y) > threshold && y < 0: return "up"
            case (_, let y) where abs(y) > threshold && y > 0: return "down"
            case (let x, _) where abs(x) > threshold && x < 0: return "left"
            case (let x, _) where abs(x) > threshold && x > 0: return "right"
            case (let x, let y) where x < -threshold && y < -threshold: return "up-left"
            case (let x, let y) where x > threshold && y < -threshold: return "up-right"
            case (let x, let y) where x < -threshold && y > threshold: return "down-left"
            case (let x, let y) where x > threshold && y > threshold: return "down-right"
            default: return "center"
        }
    }
}

// MARK: - lift up/down button


// MARK: - catch/drop button
