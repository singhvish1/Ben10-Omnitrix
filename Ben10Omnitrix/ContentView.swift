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
            Label("OMNITRIX", systemImage: "antenna.radiowaves.left.and.right")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
            Circle()
                .fill(isActivated ? Color.green : Color.yellow)
                .frame(width: 7, height: 7)
                .shadow(color: isActivated ? .green : .yellow, radius: 5)
        }
    }

    private var dial: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 2)
                    .frame(width: 154, height: 154)
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
                            colors: [selectedAlien.accent.opacity(0.28), Color(white: 0.08), .black],
                            center: .center,
                            startRadius: 2,
                            endRadius: 66
                        )
                    )
                    .overlay(Circle().stroke(.white.opacity(0.18), lineWidth: 1))
                    .frame(width: 116, height: 116)
                VStack(spacing: 3) {
                    Image(systemName: selectedAlien.symbol)
                        .font(.system(size: 29, weight: .bold))
                        .foregroundStyle(selectedAlien.accent)
                        .symbolEffect(.bounce, value: selectedIndex)
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
                    } else if value.translation.width > 0 {
                        selectedIndex = (selectedIndex - 1 + Alien.roster.count) % Alien.roster.count
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

#Preview {
    ContentView()
}
