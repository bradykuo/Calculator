import SwiftUI

struct ContentView: View {
    @State private var displayText = "0"
    @State private var currentInput = ""
    @State private var currentOperator: String? = nil
    @State private var previousNumber: Double? = nil
    @State private var newNumber = true
    
    let buttons: [[CalcButton]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Display
                HStack {
                    Spacer()
                    Text(displayText)
                        .bold()
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                }
                .padding()
                
                // Buttons
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            Button(action: {
                                self.tapButton(button: button)
                            }) {
                                Text(button.rawValue)
                                    .font(.system(size: 32))
                                    .frame(width: self.buttonWidth(button: button),
                                           height: self.buttonWidth(button: button))
                                    .background(button.backgroundColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(self.buttonWidth(button: button)/2)
                            }
                        }
                    }
                    .padding(.bottom, 3)
                }
            }
        }
    }
    
    func buttonWidth(button: CalcButton) -> CGFloat {
        if button == .zero {
            return ((UIScreen.main.bounds.width - (4*12)) / 4) * 2
        }
        return (UIScreen.main.bounds.width - (5*12)) / 4
    }
    
    func tapButton(button: CalcButton) {
        switch button {
        case .clear:
            displayText = "0"
            currentInput = ""
            currentOperator = nil
            previousNumber = nil
            newNumber = true
            
        case .add, .subtract, .multiply, .divide:
            if let current = Double(currentInput) {
                if let previous = previousNumber, let op = currentOperator {
                    let result = calculate(prev: previous, current: current, op: op)
                    displayText = formatResult(result)
                    previousNumber = result
                } else {
                    previousNumber = current
                }
                currentOperator = button.rawValue
                newNumber = true
            }
            
        case .equal:
            if let current = Double(currentInput),
               let previous = previousNumber,
               let op = currentOperator {
                let result = calculate(prev: previous, current: current, op: op)
                displayText = formatResult(result)
                previousNumber = result
                currentInput = formatResult(result)
                currentOperator = nil
                newNumber = true
            }
            
        case .decimal:
            if !currentInput.contains(".") {
                currentInput += currentInput.isEmpty ? "0." : "."
                displayText = currentInput
            }
            
        case .percent:
            if let current = Double(currentInput) {
                let result = current / 100
                currentInput = formatResult(result)
                displayText = currentInput
            }
            
        case .negative:
            if let current = Double(currentInput) {
                let result = -current
                currentInput = formatResult(result)
                displayText = currentInput
            }
            
        default:
            if newNumber {
                currentInput = button.rawValue
                newNumber = false
            } else {
                currentInput += button.rawValue
            }
            displayText = currentInput
        }
    }
    
    private func calculate(prev: Double, current: Double, op: String) -> Double {
        switch op {
        case "+": return prev + current
        case "-": return prev - current
        case "×": return prev * current
        case "÷": return current != 0 ? prev / current : 0
        default: return current
        }
    }
    
    private func formatResult(_ result: Double) -> String {
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", result)
        } else {
            return String(format: "%.8f", result)
                .trimmingCharacters(in: ["0"])
                .trimmingCharacters(in: ["."])
        }
    }
}

enum CalcButton: String, Hashable {
    case one = "1", two = "2", three = "3", four = "4", five = "5",
         six = "6", seven = "7", eight = "8", nine = "9", zero = "0"
    case add = "+", subtract = "-", multiply = "×", divide = "÷",
         equal = "=", decimal = "."
    case percent = "%", negative = "+/-", clear = "AC"
    
    var backgroundColor: Color {
        switch self {
        case .add, .subtract, .multiply, .divide, .equal:
            return .orange
        case .clear, .negative, .percent:
            return .gray
        default:
            return Color(.darkGray)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
