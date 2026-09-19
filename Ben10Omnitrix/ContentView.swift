import SwiftUI
import WatchKit

struct ContentView: View {
    @State private var selectedIndex = 0
    @State private var isActivated = false
    @State private var pulse = false

    private var selectedAlien: Alien {
        Alien.roster[selectedIndex]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 8) {
                header
                Spacer(minLength: 2)
                dial
                Spacer(minLength: 2)
                status
                activateButton
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .preferredColorScheme(.dark)
        .onChange(of: selectedIndex) { _, _ in
            WKInterfaceDevice.current().play(.click)
        }
    }

    private var header: some View {
        HStack {
            Text("OMNITRIX")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(Color.green)
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(isActivated ? Color.green : Color.yellow)
                    .frame(width: 6, height: 6)
                Text(isActivated ? "ACTIVE" : "STANDBY")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private var dial: some View {
        VStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: 0.04))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(white: 0.2), lineWidth: 2))
                    .frame(width: 176, height: 126)
                    .shadow(color: .black, radius: 8, y: 5)
                Capsule()
                    .fill(Color(white: 0.12))
                    .frame(width: 6, height: 22)
                    .offset(x: -88)
                Capsule()
                    .fill(Color(white: 0.12))
                    .frame(width: 6, height: 22)
                    .offset(x: 88)
                Circle()
                    .fill(Color(white: 0.08))
                    .overlay(Circle().stroke(Color(white: 0.22), lineWidth: 2))
                    .frame(width: 164, height: 164)
                    .shadow(color: .black, radius: 5, y: 3)
                ForEach(0..<12, id: \.self) { marker in
                    Capsule()
                        .fill(marker.isMultiple(of: 3) ? Color.green : Color.white.opacity(0.25))
                        .frame(width: marker.isMultiple(of: 3) ? 3 : 2, height: marker.isMultiple(of: 3) ? 10 : 6)
                        .offset(y: -75)
                        .rotationEffect(.degrees(Double(marker) * 30))
                }
                Circle()
                    .trim(from: 0, to: 0.78)
                    .stroke(
                        AngularGradient(
                            colors: [.green, .green.opacity(0.2), .green],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 154, height: 154)
                    .rotationEffect(.degrees(-130))
                    .opacity(pulse ? 1 : 0.7)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [selectedAlien.accent.opacity(0.38), Color.green.opacity(0.12), .black],
                            center: .center,
                            startRadius: 2,
                            endRadius: 66
                        )
                    )
                    .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 1))
                    .frame(width: 116, height: 116)
                    .overlay {
                        Circle()
                            .stroke(Color.green.opacity(0.65), lineWidth: 3)
                            .padding(5)
                    }
                VStack(spacing: 3) {
                    OmnitrixEmblem()
                        .fill(selectedAlien.accent)
                        .frame(width: 36, height: 36)
                        .shadow(color: selectedAlien.accent, radius: 5)
                        .scaleEffect(isActivated ? 1.12 : 1)
                        .animation(.easeInOut(duration: 0.2), value: isActivated)
                    Text(selectedAlien.name.uppercased())
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .minimumScaleFactor(0.7)
                    Text(selectedAlien.species)
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            .scaleEffect(pulse ? 1.04 : 1)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

            Text("SWIPE TO SELECT")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(.green.opacity(0.8))
        }
        .gesture(
            DragGesture(minimumDistance: 12)
                .onEnded { value in
                    if value.translation.width < 0 {
                        selectedIndex = (selectedIndex + 1) % Alien.roster.count
                        SoundEffects.shared.playDialTick()
                    } else if value.translation.width > 0 {
                        selectedIndex = (selectedIndex - 1 + Alien.roster.count) % Alien.roster.count
                        SoundEffects.shared.playDialTick()
                    }
                }
        )
        .onAppear { pulse = true }
    }

    private var status: some View {
        HStack(spacing: 5) {
            Image(systemName: isActivated ? "bolt.fill" : "checkmark.shield.fill")
            Text(isActivated ? "TRANSFORMED" : "READY")
            Spacer()
            Text(selectedAlien.power.uppercased())
        }
        .font(.system(size: 9, weight: .bold, design: .rounded))
        .foregroundStyle(isActivated ? selectedAlien.accent : .green)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.white.opacity(0.07), in: Capsule())
    }

    private var activateButton: some View {
        Button {
            isActivated.toggle()
            WKInterfaceDevice.current().play(isActivated ? .success : .click)
            if isActivated {
                SoundEffects.shared.playActivation()
            } else {
                SoundEffects.shared.playReset()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isActivated ? "arrow.counterclockwise" : "power")
                Text(isActivated ? "RESET" : "ACTIVATE")
            }
            .font(.system(size: 12, weight: .black, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(isActivated ? .gray : .green)
    }
}

private struct OmnitrixEmblem: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let width = rect.width * 0.62
        let height = rect.height * 0.9
        var path = Path()
        path.move(to: CGPoint(x: center.x - width * 0.42, y: center.y - height * 0.5))
        path.addLine(to: CGPoint(x: center.x + width * 0.42, y: center.y - height * 0.5))
        path.addLine(to: CGPoint(x: center.x + width * 0.16, y: center.y - height * 0.08))
        path.addLine(to: CGPoint(x: center.x + width * 0.42, y: center.y + height * 0.5))
        path.addLine(to: CGPoint(x: center.x - width * 0.42, y: center.y + height * 0.5))
        path.addLine(to: CGPoint(x: center.x - width * 0.16, y: center.y + height * 0.08))
        path.addLine(to: CGPoint(x: center.x - width * 0.42, y: center.y - height * 0.5))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ContentView()
}
