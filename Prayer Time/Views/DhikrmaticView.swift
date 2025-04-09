import SwiftUI

// Define a Dhikr struct with ID, name, subtitle and default max count
struct Dhikr: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let defaultMaxCount: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Dhikr, rhs: Dhikr) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DhikrmaticView: View {
    // Define the dhikr types with IDs, names, subtitles and default max counts
    let dhikrTypes: [Dhikr] = [
        Dhikr(id: "d1", name: "Lâ ilahe illallah", subtitle: "Allah'tan başka ilah yoktur.", defaultMaxCount: 100),
        Dhikr(id: "d2", name: "Subhânallâhi ve Bihamdihi", subtitle: "Allah'ı hamd ile tesbih ederim.", defaultMaxCount: 100),
        Dhikr(id: "d3", name: "Hasbünallahü ve ni'me'l-vekil", subtitle: "Allah bana yeter. O ne güzel vekilldir.", defaultMaxCount: 100),
        Dhikr(id: "d4", name: "Fatiha Suresi", subtitle: "", defaultMaxCount: 40),
        Dhikr(id: "d5", name: "Salavat", subtitle: "Allahümme salli ala seyyidinâ Muhammedin ve ala ali seyyidina Muhammed", defaultMaxCount: 100),
        Dhikr(id: "d6", name: "Tevbe", subtitle: "Şanı pek yüce olan Allah'tan  bağışllanmamı diliyorum.", defaultMaxCount: 100),
        Dhikr(id: "d7", name: "Esma-ül Hüsna", subtitle: "", defaultMaxCount: 1)
    ]
    
    // Use dictionaries to store counts and max counts for all dhikr types by ID
    @State private var dhikrCounts: [String: Int] = [:]
    @State private var dhikrMaxCounts: [String: Int] = [:]
    @State private var showingMaxCountSheet = false
    @State private var selectedDhikrId: String = ""
    @State private var tempMaxCount: String = ""
    
    // Initialize the data when the view is created
    init() {
        // Load saved values from UserDefaults
        let savedCounts = UserDefaults.standard.dictionaryRepresentation().filter { key, _ in
            key.starts(with: "DhikrCount_")
        }
        
        var initialCounts: [String: Int] = [:]
        var initialMaxCounts: [String: Int] = [:]
        
        // Initialize with default values
        for dhikr in dhikrTypes {
            let countKey = "DhikrCount_\(dhikr.id)"
            initialCounts[dhikr.id] = UserDefaults.standard.integer(forKey: countKey)
            
            let maxCountKey = "DhikrMaxCount_\(dhikr.id)"
            let savedMaxCount = UserDefaults.standard.integer(forKey: maxCountKey)
            initialMaxCounts[dhikr.id] = savedMaxCount > 0 ? savedMaxCount : dhikr.defaultMaxCount
        }
        
        // Use _dhikrCounts to set the initial state value
        _dhikrCounts = State(initialValue: initialCounts)
        _dhikrMaxCounts = State(initialValue: initialMaxCounts)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // ScrollView for dhikr counters
                ScrollView {
                    VStack(spacing: 12) {
                        // Dynamically create counters for each dhikr type
                        ForEach(dhikrTypes) { dhikr in
                            DhikrCounterView(
                                dhikrName: dhikr.name,
                                dhikrSubtitle: dhikr.subtitle,
                                count: Binding(
                                    get: { self.dhikrCounts[dhikr.id] ?? 0 },
                                    set: { self.dhikrCounts[dhikr.id] = $0; self.saveCounts() }
                                ),
                                maxCount: Binding(
                                    get: { self.dhikrMaxCounts[dhikr.id] ?? dhikr.defaultMaxCount },
                                    set: { self.dhikrMaxCounts[dhikr.id] = $0; self.saveMaxCounts() }
                                ),
                                onMaxCountTap: {
                                    self.selectedDhikrId = dhikr.id
                                    self.tempMaxCount = "\(self.dhikrMaxCounts[dhikr.id] ?? dhikr.defaultMaxCount)"
                                    self.showingMaxCountSheet = true
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Reset All Button
                Button(action: {
                    for dhikr in dhikrTypes {
                        dhikrCounts[dhikr.id] = 0
                    }
                    saveCounts()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Sıfırla")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private func saveCounts() {
        for (key, value) in dhikrCounts {
            UserDefaults.standard.set(value, forKey: "DhikrCount_\(key)")
        }
    }
    
    private func saveMaxCounts() {
        for (key, value) in dhikrMaxCounts {
            UserDefaults.standard.set(value, forKey: "DhikrMaxCount_\(key)")
        }
    }
}

// Separate view for each dhikr counter
struct DhikrCounterView: View {
    let dhikrName: String
    let dhikrSubtitle: String
    @Binding var count: Int
    @Binding var maxCount: Int
    var onMaxCountTap: () -> Void
    
    // Calculate progress
    private var progress: CGFloat {
        if maxCount <= 0 { return 0 }
        return min(CGFloat(count) / CGFloat(maxCount), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dhikrName)
                        .font(.headline)
                    
                    Text(dhikrSubtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Make the max count text tappable
                Button(action: onMaxCountTap) {
                    Text("\(count)/\(maxCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .foregroundColor(Color(.systemGray5))
                        .cornerRadius(4)
                    
                    // Fill
                    Rectangle()
                        .frame(width: geometry.size.width * progress, height: 8)
                        .foregroundColor(progressColor)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            .padding(.vertical, 8)
            
            HStack {
                // Minus button
                Button {
                    if count > 0 {
                        count -= 1
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemBackground))
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.primary.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        Image(systemName: "minus")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                // Count display
                Text("\(count)")
                    .font(.system(size: 36, weight: .bold))
                    .frame(minWidth: 60, alignment: .center)
                
                Spacer()
                
                // Plus button
                Button {
                    count += 1
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemBackground))
                            .frame(width: 50, height: 50)
                            .shadow(color: Color.primary.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.primary.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Color changes based on progress
    private var progressColor: Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return .orange
        } else {
            return .green
        }
    }
}
