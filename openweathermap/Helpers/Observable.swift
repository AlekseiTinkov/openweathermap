import Foundation

@propertyWrapper
final class Observable<Value> {
    private var onChange: ((Value) -> Void)? = nil
    
    var wrappedValue: Value {
        didSet { // вызываем функцию после изменения обёрнутого значения
            onChange?(wrappedValue)
        }
    }
    
    var projectedValue: Observable<Value> { // возвращает экземпляр самого проперти враппера
        return self
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    func bind(action: @escaping (Value) -> Void) { // функция для добавления функции для вызова на изменение
        self.onChange = action
    }
}
