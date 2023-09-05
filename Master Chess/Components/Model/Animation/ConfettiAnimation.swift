/*
 RMIT University Vietnam
 Course: COSC2659 iOS Development
 Semester: 2022B
 Assessment: Assignment 2
 Author: Doan Huu Quoc
 ID: 3927776
 Created  date: 30/08/2023
 Last modified: 01/09/2023
 Acknowledgement:
 Kavsoft. SwiftUI Particle Effects - Animations - SwiftUI Tutorials (Apr. 23, 2023). Accessed 30/08/2023. [Online Video]. Available: https://www.youtube.com/watch?v=sLdQdOtpf7A
 */

import SwiftUI

// Confetty animation test
struct Test_ConfettiAnimation: View {
    @State var status = false
    var body: some View {
        Image("trumpet")
            .particleEffect(status: status)
            .onAppear {
                status = true
            }
    }
}

struct Test_ConfettiAnimation_Previews: PreviewProvider {
    static var previews: some View {
        Test_ConfettiAnimation()
    }
}

extension View {
    // Custom modifier
    @ViewBuilder
    func particleEffect(status: Bool) -> some View {
        // Apply the ParticleModifier to the view
        self.modifier(ParticleModifier(status: status))
    }
}

// Custom modifier
fileprivate struct ParticleModifier: ViewModifier {
    // Control state
    var status: Bool
    
    // Particles
    @State private var particles: [Particle] = []
    
    func body(content: Content) -> some View {
        // Apply the modifier to the content
        content
            .overlay(alignment: .top) { // Overlay with additional views
                ZStack {
                    // Loop through the 'particles' array
                    ForEach (particles) { particle in
                        Rectangle()
                            .fill(Color(hue: particle.color, saturation: 1, brightness: 1))
                            .frame(width: particle.width, height: particle.height)
                            .offset(x: particle.randomX, y: particle.randomY - 50)
                            .opacity(particle.opacity)
                            .opacity(status ? 1 : 0)
                            .rotationEffect(Angle.degrees(particle.rotation), anchor: .center)
                    }
                }
                .onAppear {
                    // If empty, add 100 new particles.
                    if particles.isEmpty {
                        for _ in 1...100 {
                            let particle = Particle()
                            particles.append(particle)
                        }
                    }
                }
                .onChange(of: status) { newValue in
                    // If 'status' is false (e.g., turning off the effect).
                    if !newValue {
                        for i in particles.indices {
                            particles[i].reset()
                        }
                    } else {
                        for i in particles.indices {
                            _ = particles[i]
                            let total = CGFloat(particles.count)
                            let progress = CGFloat(i) / total
                            let maxX: CGFloat = .random(in: -150...150) // Spread particles horizontally
                            let maxY = 500
                            let randomX = maxX
                            let randomY = progress * CGFloat(maxY)
                            let extraX: CGFloat = 0
                            let extraY: CGFloat = -400 * CGFloat(sin(25 * 3.14 / 180)) * progress // Shoot relatively higher
                            let randomWidth: CGFloat = .random(in: 5...20) // Random width
                            let randomHeight: CGFloat = .random(in: 10...30) // Random height
                            let randomRotation: Double = 0 // No initial rotation
                            let randomColor: Double = .random(in: 0...1) // Random hue value
                            let randomOpacity: Double = .random(in: 0.5...1)
                            
                            // Animation
                            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                particles[i].randomX = CGFloat(randomX) + extraX
                                particles[i].randomY = randomY + extraY
                                particles[i].opacity = randomOpacity
                            }
                            
                            withAnimation(.easeInOut(duration: 1)) { // Fire up for 1 second
                                particles[i].width = randomWidth
                                particles[i].height = randomHeight
                                particles[i].rotation = randomRotation
                                particles[i].color = randomColor
                            }
                            
                            withAnimation(.interpolatingSpring(stiffness: 0.5, damping: 0.8, initialVelocity: 0).delay(1)) {
                                particles[i].opacity = 0
                                particles[i].randomY += 400 // Larger fall down distance
                            }
                        }
                    }
                }
            }
    }
}

struct Particle: Identifiable {
    // Identify each particle with a UUID.
    var id: UUID = .init()
    
    // Attributes
    var randomY: CGFloat = 0     // Random Y position.
    var randomX: CGFloat = 0     // Random X position.
    var width: CGFloat = 15      // Width of the particle.
    var height: CGFloat = 15     // Height of the particle.
    var rotation: Double = 0     // Rotation angle in degrees.
    var color: Double = 0        // Color information (note: type should be clarified).
    var opacity: Double = 1      // Opacity of the particle (0 to 1).
    
    // Reset to initial state
    mutating func reset() {
        randomY = 0
        randomX = 0
        width = 15
        height = 15
        rotation = 0
        color = 0
        opacity = 1
    }
}
